---
description: 위키를 검색하고 답변을 합성
user_invocable: true
args: "[질문]"
---

# /query — 위키 질의

위키를 검색하여 축적된 지식 기반으로 답변을 합성한다.

> **경로 기준**: 모든 `raw/`, `wiki/` 경로는 `$LLM_WIKI_ROOT` 기준. **미설정 시 동작 중단** — wiki skill의 "가드 절차" 참조.

## 인자

- `질문`: 위키에 대한 질문. 자연어로 입력.

## 워크플로우

### 1. 위키 탐색
- `obsidian search query="질문 키워드" format=json`으로 관련 페이지 탐색
- `wiki/index.md`에서 관련 카테고리 확인
- 회사·조직·서비스·내부 아키텍처 관련 질문은 vault root `AGENTS.md` → `wiki/company/index.md` → `wiki/company/<company>/index.md` 순서로 추가 확인
- 두 결과를 교차 대조하여 관련 페이지 목록 확정

### 2. 페이지 드릴다운
- 발견된 페이지들 순차 읽기
- `obsidian backlinks file="페이지"`로 추가 컨텍스트 수집
- 필요시 연관 페이지 체인을 따라가며 깊이 탐색

### 3. 합성 & 응답
- `[[wikilink]]` 인용 포함한 답변 합성
- 출처(소스) 명시
- 회사 문서는 `authority`, `status`, 검증일을 확인하고 draft/proposed 여부를 명시
- 위키에 정보가 부족한 부분은 명시적으로 표시

### 4. 결과 저장 (선택)
- 범용 분석은 `wiki/analyses/<topic>.md`, 회사 고유 분석은 `wiki/company/<company>/analyses/<topic>.md`로 저장 제안
- 사용자 승인 시:
  - analyses/ 페이지 생성 (frontmatter 포함)
  - `wiki/index.md` Analyses 섹션에 추가
  - `wiki/log.md`에 기록: `## [YYYY-MM-DD] query | 질문 요약`
