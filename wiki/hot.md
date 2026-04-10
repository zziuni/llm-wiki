---
type: cache
updated: 2026-04-10
---

## Current Focus
SaaS 정의 autoresearch 완료 (2라운드). 위키 lint 수정 완료. $LLM_WIKI_ROOT 필수화 적용.

## Recent Activity
- [2026-04-10] merge: CWD wiki/ → LLM_WIKI_ROOT 병합 (concepts 1건, analyses 6건)
- [2026-04-10] $LLM_WIKI_ROOT 환경변수 필수 조건화 (CWD fallback 제거, 9개 플러그인 파일 수정)
- [2026-04-10] lint 수정: Critical 3건 + Warning 4건 해소 (자기참조, 대소문자, 깨진 링크, 통계 불일치)
- [2026-04-10] autoresearch 2라운드: SaaS 정의 — 웹 소스 9건, saas.md (플래시카드 11장)
- [2026-04-10] autoresearch 1라운드: GitHub Actions Reusable Workflow & Harness Scoring
- [2026-04-10] lint 자동 수정: junio-hamano, 3-way-merge 페이지 생성

## Wiki Stats
- 개념: 11건, 엔티티: 2건, 소스: 11건, 분석: 6건
- 플래시카드: 61장
- 고아 (위키 콘텐츠): 0건, 깨진 링크: 0건

## Pending
- raw/3-way-merge.md — 빈 파일 (이미 개념 페이지 존재, 삭제 가능)
- SaaS autoresearch 추가 영역 가능: 보안/컴플라이언스, Vertical vs Horizontal SaaS, 가격 전략 상세

## Key Decisions
- $LLM_WIKI_ROOT 필수: 환경변수 없으면 모든 커맨드 즉시 중단 (CWD fallback 없음)
- Obsidian CLI 적극 활용 (단, obsidian move는 이름 충돌 시 부작용 있어 mv + 수동 갱신 권장)
- YAML frontmatter 메타데이터 표준 채택
- 위키 페이지 인라인 플래시카드 방식 채택
- sources/ 파일명에 출처 포함하여 concepts/와 base name 충돌 방지
- Confluence 원본 참조는 wikilink 대신 평문으로 (vault에 없는 대상)
