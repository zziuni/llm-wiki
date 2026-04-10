---
type: overview
summary: "시간순 작업 기록 — append-only"
updated: 2026-04-10
---

# Wiki Log

## [2026-04-09] ingest | Oxfmt 공식 문서
- 소스: oxc.rs 공식 문서
- 생성: sources/oxfmt.md, concepts/oxfmt.md
- 갱신: concepts/biome.md (경쟁 도구 비교 추가), index.md, overview.md
- 플래시카드: 4장

## [2026-04-09] ingest | Biome 마이그레이션 가이드
- 소스: 무신사 코어 파트너프론트엔드 Confluence
- 생성: sources/biome-migration-guide.md
- 갱신: concepts/biome.md (마이그레이션 실무 + extends 제한 카드 추가), index.md, overview.md
- 플래시카드: 1장 (biome extends 제한)

## [2026-04-09] ingest | Biome 마이그레이션 리포트
- 소스: 무신사 코어 파트너프론트엔드 Confluence (Migrate to Biome Report)
- 생성: sources/biome-migration-report.md, concepts/biome.md, concepts/monorepo-dx.md
- 갱신: index.md, overview.md
- 플래시카드: 8장 (biome 5장, monorepo-dx 3장)
- 비고: AI 도구 정합성 섹션은 사용자 피드백으로 제외

## [2026-04-09] ingest | Git의 새로운 기본 Merge 전략 ort
- 소스: Outsider's Dev Story (2024-02-23)
- 생성: sources/git-merge-strategy-ort.md, concepts/git-merge-strategies.md, entities/elijah-newren.md
- 플래시카드: 7장 (concepts 5장, entities 2장)

## [2026-04-09] init | 위키 초기화
- 디렉토리 구조 생성: raw/, wiki/concepts/, wiki/entities/, wiki/sources/, wiki/analyses/
- 초기 파일 생성: index.md, log.md, hot.md, overview.md
- CLAUDE.md schema 작성
- Claude Code 플러그인 설치


## [2026-04-09] ingest | 디자인 시스템에 Compound Component Pattern 적용기

- **소스**: raw/디자인 시스템에 Compound Component Pattern 적용기.md (Corca Medium, 2024-07-09)
- **생성**: wiki/sources/compound-component-pattern.md, wiki/concepts/compound-component-pattern.md
- **갱신**: wiki/index.md
- **플래시카드**: 5장 (concepts/compound-component-pattern.md)

## [2026-04-09] autoresearch | Compound Component Pattern (2라운드)

### Round 1
- **웹 소스 3건**: patterns.dev, Kent C. Dodds, freeCodeCamp
- **갱신**: concepts/compound-component-pattern.md (구현 기법 2종, 트레이드오프, 라이브러리 사례, 플래시카드 확장)
- **생성**: sources/compound-component-pattern-web.md

### Round 2
- **웹 소스 2건**: Alyssa Holland (Headless Components), Pasquale Favella (TypeScript)
- **생성**: concepts/headless-component.md (플래시카드 4장), sources/headless-component-web.md
- **갱신**: concepts/compound-component-pattern.md (TypeScript 타입 설계, 관련 패턴, 플래시카드 +1)

### Round 3
- **웹 소스 2건**: patterns.dev (React 2026), Ben MVP (패턴 비교)
- **갱신**: concepts/compound-component-pattern.md (RSC 호환성, Hole in the Donut 패턴, 5패턴 비교표, 플래시카드 +2)

## [2026-04-10] lint | 위키 건강검진 및 자동 수정

- **깨진 링크 해소**: entities/junio-hamano.md 생성 (플래시카드 2장), concepts/3-way-merge.md 생성 (플래시카드 3장)
- **메타데이터 수정**: overview.md에 tags 필드 추가
- **통계 갱신**: overview.md 현재 상태 업데이트
- **인덱스 갱신**: index.md에 신규 2건 추가

## [2026-04-10] autoresearch | GitHub Actions Reusable Workflow & Harness Scoring (1라운드)

### Round 1
- **소스 2건**: GitHub 공식 문서 (Reusable Workflows, Workflow Syntax), PR #6445 diff
- **생성**: concepts/github-actions-reusable-workflow.md (플래시카드 4장), concepts/harness-scoring-system.md (플래시카드 3장)
- **생성**: sources/github-actions-reusable-workflow-docs.md, sources/harness-scoring-pr6445.md
- **raw 수집**: raw/github-actions-reusable-workflow-docs.md, raw/harness-scoring-pr6445.md
- **갱신**: index.md (concepts 2건, sources 2건 추가)
- **주제**: Caller-Called 패턴, workflow_call 구문, HESS 아키텍처, 온보딩 3파일 구조

## [2026-04-10] lint | 위키 건강검진 및 수정

- **Critical 3건 수정**: 자기참조 sources 2건 (harness-scoring-pr6445, github-actions-reusable-workflow-docs → raw/ 참조로 변경), overview.md 통계 갱신 (소스 11건, 개념 10건, 플래시카드 61장)
- **Warning 4건 수정**: oxfmt 대소문자 통일, Confluence 깨진 링크 2건 (wikilink → 평문), headless-component-web 빈 sources 보완
- **overview.md**: SaaS 클라우드 서비스 모델 테마 추가, 위키 설명 갱신
- **통계**: 총 27페이지, 고아 0, 깨진 링크 0, 플래시카드 61장

## [2026-04-10] autoresearch | SaaS의 정의 (2라운드)

### Round 1
- **웹 소스 5건**: AWS, Google Cloud, Wikipedia, Microsoft Azure, IBM
- **생성**: concepts/saas.md (플래시카드 6장), sources/saas-definition-web-sources.md
- **raw 수집**: raw/saas-definition-web-sources.md
- **주제**: SaaS 정의, 핵심 특성 6가지, 클라우드 모델 비교, 멀티테넌시 아키텍처, 수익 모델, 장단점

### Round 2
- **웹 소스 4건**: Baremetrics, re:cap, DiscoveringSaaS, Microsoft Learn
- **갱신**: concepts/saas.md (비즈니스 메트릭 + 성숙도 모델 섹션, 플래시카드 +5장 = 총 11장)
- **생성**: sources/saas-metrics-maturity-web-sources.md
- **raw 수집**: raw/saas-metrics-maturity-web-sources.md
- **주제**: MRR/ARR/LTV/CAC/NRR 메트릭 체계, 벤치마크, Microsoft 4단계 성숙도 모델, Rule of 40

## [2026-04-10] save | 세션 저장

- **갱신**: overview.md — React 컴포넌트 패턴 테마 추가, 통계·핵심 발견 갱신
- **갱신**: hot.md — 세션 컨텍스트 캐시 갱신
- **갱신**: index.md — wikilink shortest path 통일

## [2026-04-10] merge | CWD wiki/ → LLM_WIKI_ROOT 병합

프로젝트 CWD(`frontend-29cm-platform/wiki/`)에 잘못 생성된 위키 콘텐츠를 실제 위키 root로 병합:
- **복사**: concepts/composition-two-axes.md (1건)
- **복사**: analyses/ 5건 (pdp-problem-analysis, pdp-restructure-hld, hook-chaining-analysis, codebase-improvement-roadmap, mcp-atlassian-fakeredis-fix, packages-restructure-hld)
- **병합**: index.md (concepts 1건, analyses 6건 추가)
- **병합**: log.md (CWD 로그 엔트리 4건 추가)
- **갱신**: overview.md (통계·테마 갱신)
- **원인**: $LLM_WIKI_ROOT 규칙 이전에 CWD 기준으로 wiki/ 생성됨

## [2026-04-10] lint | 병합 파일 표준화

- **Critical 3건 수정**: composition-two-axes frontmatter 표준화 + Flashcards 4장 생성, analyses 6개 frontmatter 표준화(title 제거, summary/status 추가, source→sources, related→본문), overview 플래시카드 수 64→68장(+4 composition-two-axes)
- **Warning 3건 수정**: oxfmt-official-docs sources 필드 URL로 변경, index.md created 추가, analyses 3개 updated 추가
- **통계**: 총 34페이지, 고아 0, 깨진 링크 0, 플래시카드 68장