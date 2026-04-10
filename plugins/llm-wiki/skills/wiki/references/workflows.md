# Wiki Workflows

> **경로 규칙**: 아래 모든 경로(`raw/`, `wiki/`)는 `$LLM_WIKI_ROOT` 기준 상대경로. 환경변수 미설정 시 동작 중단 (wiki skill의 "가드 절차" 참조).
> **플러그인 경로**: scaffold, 마이그레이션 등 플러그인 리소스는 `${CLAUDE_PLUGIN_ROOT}` 기준.

## Vault 부트스트랩 절차

```
Trigger: /wiki 실행 시 $LLM_WIKI_ROOT/.obsidian/ 미존재

1. ${CLAUDE_PLUGIN_ROOT}/scaffold/.obsidian/ → $LLM_WIKI_ROOT/.obsidian/ 복사
2. ${CLAUDE_PLUGIN_ROOT}/scaffold/.gitignore → $LLM_WIKI_ROOT/.gitignore 복사 (이미 있으면 건너뜀)
3. 디렉토리 생성: raw/, raw/assets/, wiki/concepts/, wiki/entities/, wiki/sources/, wiki/analyses/
4. 핵심 파일 초기화: wiki/index.md, wiki/log.md, wiki/hot.md, wiki/overview.md
5. .llm-wiki-meta.json 생성 (현재 플러그인 schemaVersion)
6. 커뮤니티 플러그인 수동 설치 안내 출력
7. Obsidian에서 볼트 열기 안내
```

## 스키마 마이그레이션 절차

```
Trigger: /wiki Step 6에서 vault schemaVersion < plugin schemaVersion

1. ${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json에서 target schemaVersion 확인
2. $LLM_WIKI_ROOT/.llm-wiki-meta.json에서 current schemaVersion 확인
3. (current + 1) ~ target 까지 순차 마이그레이션:
   - ${CLAUDE_PLUGIN_ROOT}/scaffold/migrations/vN.md 읽기
   - 각 마이그레이션의 "절차" 섹션 실행
4. .llm-wiki-meta.json 갱신 (schemaVersion, pluginVersion, lastMigration)
5. 결과 리포트 출력
```

## Ingest 상세 절차

```
Input: raw/ 소스 파일
Output: wiki/sources/ 요약 + 개념/엔티티 페이지 갱신 + 플래시카드

1. 소스 파일 전체 읽기
2. 핵심 발견 3-5개 추출 → 사용자에게 제시
3. 사용자 피드백 수렴 (강조점, 무시할 부분)
4. wiki/sources/<name>.md 생성
   - frontmatter: type=source, summary, tags, created, updated, status=active
   - 본문: 요약, 핵심 인용, 관련 개념/엔티티 목록
5. obsidian search로 기존 관련 페이지 탐색
6. 기존 페이지 갱신 또는 새 페이지 생성
   - 모순 발견 시 > [!warning] 콜아웃
7. ## Flashcards 섹션에 카드 추가 (중복 확인)
8. [[wikilink]] 교차참조 추가
9. wiki/index.md 갱신
10. wiki/log.md에 append
```

## Query 상세 절차

```
Input: 자연어 질문
Output: [[wikilink]] 인용 답변 + (선택) analyses/ 저장

1. obsidian search + index.md에서 관련 페이지 탐색
2. 관련 페이지 읽기 + backlinks 추적
3. 답변 합성 (인용 포함)
4. 위키에 정보 부족하면 명시
5. (사용자 승인) analyses/ 저장 + index.md 갱신
6. log.md에 기록
```

## Lint 상세 절차

```
Input: (없음)
Output: 건강 리포트

1. obsidian orphans → 고아 페이지 목록
2. obsidian unresolved → 깨진 링크 목록
3. obsidian tags → 태그 일관성 검사
4. wiki/ 전체 스캔:
   - frontmatter 누락
   - summary 없음
   - stale (active + updated > 90일)
   - 빈약한 페이지 (200자 미만)
5. ## Flashcards 없는 active 개념/엔티티 페이지
6. index.md 정합성 (미등록/삭제된 페이지)
7. 리포트 생성 (Critical / Warning / Info)
8. 사용자 승인 후 수정
9. log.md에 기록
```

## 핫캐시 워크플로우

```
세션 시작:
  1. wiki/hot.md 읽기
  2. Current Focus, Pending, Key Decisions 확인
  3. 간략히 사용자에게 알림

세션 종료:
  1. wiki/hot.md 갱신
     - Current Focus: 이번 세션의 주요 작업 영역
     - Recent Activity: 이번 세션에서 한 일
     - Pending: 미완료 작업
     - Key Decisions: 사용자와 합의한 결정사항
  2. updated 타임스탬프 갱신
```
