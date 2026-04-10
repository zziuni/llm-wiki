---
name: wiki
description: LLM Wiki 핵심 오케스트레이션 — 위키 구조, 컨벤션, 워크플로우를 정의하는 메인 스킬
references:
  - references/conventions.md
  - references/metadata.md
  - references/obsidian-cli.md
  - references/workflows.md
---

# Wiki Orchestration Skill

이 스킬은 Karpathy LLM Wiki 패턴의 핵심 로직을 정의한다. 모든 위키 커맨드(/ingest, /query, /lint, /flashcard, /save, /autoresearch)가 이 스킬의 규칙을 따른다.

## 경로 규칙 (Path Resolution)

모든 위키 경로(`raw/`, `wiki/`)는 **`$LLM_WIKI_ROOT`** 환경변수 기준으로 해석한다.

- **설정됨**: `$LLM_WIKI_ROOT/wiki/index.md`, `$LLM_WIKI_ROOT/raw/` 등 절대경로 사용
- **미설정 → 즉시 중단**: 환경변수가 없으면 플러그인의 모든 동작을 중단하고, 설정 방법을 안내한다

### 가드 절차 (모든 커맨드 진입 시 필수)

1. `echo $LLM_WIKI_ROOT`로 환경변수 확인
2. 비어 있으면 아래 메시지를 출력하고 **동작을 중단**한다:

```
⚠ $LLM_WIKI_ROOT 환경변수가 설정되지 않았습니다.

셸 프로필(~/.zshrc 등)에 아래를 추가하세요:
  export LLM_WIKI_ROOT="$HOME/path/to/llm-wiki"

또는 현재 세션에서만 설정:
  ! export LLM_WIKI_ROOT="$HOME/path/to/llm-wiki"
```

> **CWD fallback 없음**: 환경변수 없이 CWD를 root로 추론하지 않는다. 다른 프로젝트에서 호출 시 엉뚱한 디렉토리에 파일을 쓰는 사고를 방지하기 위함.

## 핵심 원칙

1. **raw/ 불변**: 원본 소스는 절대 수정하지 않는다
2. **wiki/ LLM 소유**: 위키 페이지는 LLM이 작성하고 유지한다
3. **index.md 우선**: 쿼리 시 항상 index.md를 먼저 읽는다
4. **Obsidian CLI 우선**: 파일 직접 조작보다 CLI 명령 우선
5. **로깅 필수**: 모든 작업을 log.md에 기록한다
6. **플래시카드 동반**: 수집 시 개념/엔티티 페이지에 플래시카드를 함께 생성한다
7. **핫캐시 유지**: 세션 시작/종료 시 hot.md를 읽고/갱신한다

## 참조 문서

상세 규칙은 references/ 하위 파일을 참조:
- `conventions.md`: 페이지 형식, 위키링크, 콜아웃 규칙
- `metadata.md`: frontmatter 스키마
- `obsidian-cli.md`: CLI 명령어 레퍼런스
- `workflows.md`: ingest/query/lint 상세 절차
