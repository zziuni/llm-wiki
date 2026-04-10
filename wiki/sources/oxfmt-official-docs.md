---
type: source
summary: "Oxc 스택 기반 고성능 포매터. Prettier 대비 ~30배, Biome 대비 ~2배 빠름. Prettier 100% JS/TS 호환"
tags:
  - oxfmt
  - formatter
  - rust
  - oxc
sources:
  - "https://oxc.rs/docs/guide/usage/formatter.html"
created: 2026-04-09
updated: 2026-04-09
status: active
---

# Oxfmt 소스 요약

Oxc 프로젝트의 고성능 JavaScript 포매터 공식 문서.

## 요약

- **발음**: `/oʊ-ɛks-fɔːr-mæt/`
- Oxc 컴파일러 스택 기반, Rust로 작성
- Prettier 대비 **~30배**, [[biome]] 대비 **~2배** 빠름
- Prettier JS/TS 호환 테스트 **100% 통과**
- **포매터 전용** (린터 미포함) — Biome과 대비되는 포지셔닝

## 내장 기능 (플러그인 불필요)

- Import sorting
- Tailwind CSS class sorting
- package.json field sorting
- Embedded formatting (CSS-in-JS, GraphQL 등)

## 핵심 인용

> Our benchmarks show Oxfmt to be approximately 30x faster than Prettier and 2x faster than Biome.

> Oxfmt now passes 100% of Prettier's JavaScript and TypeScript conformance tests.

## 발견한 개념

- [[oxfmt]] — Oxc 기반 고성능 포매터

## 원본

- [Oxfmt 공식 문서](https://oxc.rs/docs/guide/usage/formatter.html)
