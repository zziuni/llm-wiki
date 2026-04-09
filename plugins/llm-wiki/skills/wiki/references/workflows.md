# Wiki Workflows

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
