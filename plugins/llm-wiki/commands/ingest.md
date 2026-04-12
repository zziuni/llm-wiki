---
description: 소스 파일을 위키에 수집
user_invocable: true
args: "[파일경로]"
---

# /ingest — 소스 수집

raw/ 디렉토리의 소스 파일을 읽고 위키에 통합한다.

> **경로 기준**: 모든 `raw/`, `wiki/` 경로는 `$LLM_WIKI_ROOT` 기준. **미설정 시 동작 중단** — wiki skill의 "가드 절차" 참조.

## 인자

- `파일경로` (선택): 수집할 파일 경로. 생략 시 raw/ 내 아직 수집되지 않은 파일을 자동 감지한다.

### 미수집 판단 (표준 알고리즘)

**원칙**: 파일명 매칭이 아니라 **참조 무결성** 기반으로 판정한다.

- `wiki/sources/*.md`는 frontmatter `sources:` 필드에 원본 raw 경로를 wikilink로 기록한다:
  ```yaml
  sources:
    - "[[raw/frameworks/Nest.js-d65854e4-080c-43b9-9ab0-e253074abd66]]"
  ```
- 이 wikilink 집합이 "이미 수집된 raw 파일"의 공식 정의이다.

**판정 절차**:

1. 모든 `wiki/sources/*.md`의 frontmatter를 파싱하여 `sources:` 필드의 `[[raw/...]]` wikilink를 추출 → `collected` 집합 생성
2. `raw/**/*.md` 전체 파일 목록 생성 → `all_raw` 집합
3. `uncollected = all_raw - collected` — 이 차집합이 진짜 미수집 파일

**왜 파일명 매칭은 안 되나**:

raw 파일명과 source 페이지 이름은 임의적으로 축약/변형되어 규칙화가 불가능하다:

| raw 파일명 | source 페이지명 |
|---|---|
| `Nest.js-<uuid>.md` | `nestjs-notion.md` |
| `Next.js-<uuid>.md` | `nextjs-notion.md` |
| `Prettier-and-ESLint-(feat.-EditorConfig)-<uuid>.md` | `prettier-eslint-notion.md` |
| `디자인 시스템에 Compound Component 적용기.md` | `corca-compound-component.md` |

소문자·특수문자 정규화로도 매칭이 깨지므로 반드시 frontmatter 역추적 방식을 사용할 것.

**추가 확인**:
- 콘텐츠가 거의 없는 빈 raw 파일(frontmatter만 있고 본문 10줄 미만)은 수집 대상에서 제외한다. 원본에 없는 내용을 LLM이 채우면 hallucination이므로, ingest는 "요약"이지 "생성"이 아니다. 빈 파일은 별도로 웹 소스를 수집(`/autoresearch`)한 뒤 개념 페이지로 편입하는 경로를 고려한다.

## 워크플로우

### 1. 소스 읽기
- Read tool로 raw/ 파일 전체 읽기
- 이미지 참조가 있으면 `raw/assets/`에서 이미지도 확인

### 2. 사용자와 토론 (AskUserQuestion 활용)

소스를 읽은 뒤, AskUserQuestion 도구로 수집 방향을 구조화하여 확인한다.

**질문 구성** (최대 4개 질문을 한 번에):

1. **수집 대상 선택** (미수집 소스가 여러 건일 때): 어떤 소스를 수집할지 multiSelect로 선택
2. **강조점**: 소스에서 발견한 핵심 주제 3-5개를 옵션으로 제시, 사용자가 강조할 항목을 multiSelect
3. **새 개념 페이지 생성**: 새로 만들 개념/엔티티 페이지 후보를 옵션으로 제시, multiSelect로 선택
4. **무시할 부분** (필요시): 신빙성 낮은 주장이나 불필요한 섹션을 옵션으로 제시

사용자 선택에 따라 수집 방향을 조정한다. "Other"를 통해 자유 텍스트 피드백도 가능.

### 3. 소스 요약 페이지 생성
- `wiki/sources/<source-name>.md` 생성
- frontmatter 포함 (type: source, summary, tags, created, updated, status: active)
- 구성: 요약, 핵심 인용, 발견한 개념/엔티티 목록

### 4. 관련 페이지 탐색 & 갱신
- `obsidian search query="핵심키워드" format=json`으로 기존 관련 페이지 탐색
- 기존 개념/엔티티 페이지에 새 정보 통합
- 새 소스가 기존 내용과 모순되면 `> [!warning] 모순` 콜아웃으로 표시
- 필요시 새 개념/엔티티 페이지 생성

### 5. 플래시카드 생성
- 각 개념/엔티티 페이지의 `## Flashcards` 섹션에 카드 추가
- 기존 카드 확인하여 중복 방지
- 카드 유형: 정의(::), 비교(:::), 핵심용어(==cloze==)
- 페이지당 3-7장 적정

### 6. 교차참조 & 인덱스
- 모든 관련 페이지에 `[[wikilink]]` 교차참조 추가
- `wiki/index.md`에 새 페이지 항목 추가
- `obsidian backlinks`로 링크 검증

### 7. 로깅
- `wiki/log.md`에 append: `## [YYYY-MM-DD] ingest | 소스 제목`
- 갱신된 페이지 목록, 생성된 페이지 목록, 추가된 플래시카드 수 기록
