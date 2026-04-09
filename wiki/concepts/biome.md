---
type: concept
summary: "Rust 기반 웹 개발 통합 도구. 포매터 + 린터를 단일 바이너리로 제공하며 Prettier 대비 ~35배 빠름"
tags:
  - biome
  - linter
  - formatter
  - rust
  - toolchain
sources:
  - "[[sources/biome-migration-report]]"
  - "[[sources/biome-migration-guide]]"
created: 2026-04-09
updated: 2026-04-09
status: active
---

# Biome

**"One toolchain for your web project"** — Rust로 작성된 웹 개발 통합 도구. 포매팅과 린팅을 하나의 네이티브 바이너리로 수행한다.

## 핵심 특징

- **언어**: Rust (네이티브 바이너리) — Node.js 기반 도구 대비 메모리 사용 수십MB 수준
- **통합**: 린터 + 포매터를 단일 도구(`biome.json`)로 통합. ESLint + Prettier 2개 도구/설정 파일 분리 문제 해결
- **호환성**: ESLint 규칙 97% 호환 (464개 내장 규칙), Prettier 포맷 97% 호환
- **성능**: Prettier 대비 공식 벤치마크 ~35배 빠름

## ESLint + Prettier 대비

| 비교 항목 | ESLint + Prettier | Biome |
|---|---|---|
| 언어 | JavaScript (Node.js) | Rust (네이티브) |
| 도구 수 | 2개 | 1개 |
| 설정 파일 | `.eslintrc.json` + `.prettierrc` + `.lintstagedrc` | `biome.json` |
| 메모리 | 수백MB~GB (Node.js 힙) | 수십MB |

## 마이그레이션 실무

[[sources/biome-migration-guide|마이그레이션 가이드]] 핵심:

1. **자동 변환 CLI**: `biome migrate eslint --write` / `biome migrate prettier --write`
2. **모노레포**: 루트 `"root": true` + 워크스페이스 `"root": false, "extends": [...]`
3. **주의**: `extends`는 **1-depth만 지원** — 체이닝 불가, flat 구조 필수
4. **Group-Level Severity**: `"a11y": "warn"` 한 줄로 37개 규칙 일괄 설정

## 경쟁 도구: Oxfmt

[[oxfmt]]는 포매터 전용 도구로, Biome 대비 ~2배 빠르지만 린터 미포함.
Biome은 "린트+포맷 통합", Oxfmt은 "포매팅 극한 성능"으로 포지셔닝이 다름.

## 실측 사례

[[sources/biome-migration-report|무신사 코어 파트너프론트엔드]] 31개 패키지 [[monorepo-dx|모노레포]]에서:

- 에디터 저장: 15.5초 → 82ms (**189배** 개선)
- CI 전체 린트(4,407 파일): 235초 → 81초 (**2.9배** 개선)
- CI OOM 문제 완전 해결

## 관련

- [[monorepo-dx]] — Biome이 모노레포 DX를 개선한 사례
- [[oxfmt]] — 경쟁 도구 (포매터 전용, Biome 대비 ~2배 빠름)
- [[sources/biome-migration-report]] — 마이그레이션 결과 리포트
- [[sources/biome-migration-guide]] — 마이그레이션 실전 가이드
- 공식 문서: [biomejs.dev](https://biomejs.dev)

## Flashcards
#flashcards

Biome은 어떤 언어로 작성되었는가?::Rust (네이티브 바이너리)

Biome이 대체하는 기존 도구 조합은?::ESLint + Prettier (린터 + 포매터)

Biome의 설정 파일은?::biome.json 단일 파일 (ESLint+Prettier는 3개 설정 파일 필요)

무신사 모노레포에서 Biome 전환 후 에디터 저장 속도 개선 수치는?::15.5초 → 82ms (189배 개선)

Biome의 ESLint 규칙 호환율은?::97% (464개 내장 규칙)

Biome의 extends 설정 제한은?::1-depth만 지원. 체이닝(A extends B extends C) 불가, 각 설정 파일이 모든 규칙을 독립 포함하는 flat 구조 필수
