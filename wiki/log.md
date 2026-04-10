---
type: overview
summary: "시간순 작업 기록 — append-only"
updated: 2026-04-09
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

## [2026-04-10] save | 세션 저장

- **갱신**: overview.md — React 컴포넌트 패턴 테마 추가, 통계·핵심 발견 갱신
- **갱신**: hot.md — 세션 컨텍스트 캐시 갱신
- **갱신**: index.md — wikilink shortest path 통일