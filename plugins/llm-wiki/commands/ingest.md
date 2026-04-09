---
name: ingest
description: 소스 파일을 위키에 수집
user_invocable: true
args: "[파일경로]"
---

# /ingest — 소스 수집

raw/ 디렉토리의 소스 파일을 읽고 위키에 통합한다.

> **경로 기준**: 모든 `raw/`, `wiki/` 경로는 `$LLM_WIKI_ROOT` 기준. 미설정 시 CWD. 상세는 wiki skill의 "경로 규칙" 참조.

## 인자

- `파일경로` (선택): 수집할 파일 경로. 생략 시 raw/ 내 아직 수집되지 않은 파일을 자동 감지한다.
  - 미수집 판단: `wiki/sources/`에 대응하는 요약 페이지가 없는 raw/ 파일

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
