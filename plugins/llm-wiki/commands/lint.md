---
name: lint
description: 위키 건강검진
user_invocable: true
---

# /lint — 위키 건강검진

위키의 구조적/내용적 건강 상태를 점검하고 개선점을 리포트한다.

> **경로 기준**: 모든 `raw/`, `wiki/` 경로는 `$LLM_WIKI_ROOT` 기준. 미설정 시 CWD. 상세는 wiki skill의 "경로 규칙" 참조.

## 검사 항목

### 1. 구조적 검사 (Obsidian CLI)
- `obsidian orphans` → 고아 페이지 (인바운드 링크 없음)
- `obsidian unresolved` → 깨진 링크 (존재하지 않는 대상)
- `obsidian tags` → 태그 일관성 (유사한 태그 통합 제안)

### 2. 메타데이터 검사
- frontmatter 누락 페이지
- `summary` 필드 없는 페이지
- `status: active`인데 `updated`가 90일 이상 된 페이지 (stale)
- `type` 필드가 없거나 잘못된 페이지

### 3. 내용 검사
- 페이지 간 모순 탐지 (같은 주제 페이지들 교차 비교)
- 자주 언급되지만 전용 페이지가 없는 개념 (미생성 링크)
- 빈약한 페이지 (200자 미만)
- 중복 페이지 (유사한 제목/내용)

### 4. 플래시카드 검사
- `## Flashcards` 섹션 없는 active 개념/엔티티 페이지
- 카드 수가 0인 페이지 (내용은 풍부한데 카드 없음)
- 카드 문법 오류 (`::` 누락, 빈 답변 등)

### 5. 인덱스 정합성
- `wiki/index.md`에 등록되지 않은 페이지
- `wiki/index.md`에 등록되었지만 삭제된 페이지

## 리포트 형식

```markdown
## Lint Report [YYYY-MM-DD]

### Critical (즉시 수정 필요)
- ...

### Warning (개선 권장)
- ...

### Info (참고)
- ...

### 통계
- 총 페이지: N개
- 고아 페이지: N개
- 깨진 링크: N개
- 플래시카드 총 수: N장
```

## 후속 조치
- 리포트를 사용자에게 제시
- 사용자 승인 시 자동 수정 (고아 링크 추가, frontmatter 보완 등)
- `wiki/log.md`에 기록: `## [YYYY-MM-DD] lint | 결과 요약`
