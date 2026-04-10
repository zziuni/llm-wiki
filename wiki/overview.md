---
type: overview
summary: "위키 전체를 관통하는 합성 요약 — 소스 축적에 따라 진화"
tags:
  - overview
created: 2026-04-09
updated: 2026-04-10
status: active
---

# Overview

프론트엔드 개발 도구와 패턴에 대한 지식 위키. 두 가지 주요 테마를 다룬다.

## 현재 상태
- 소스: 7건
- 개념 페이지: 7건
- 엔티티 페이지: 2건
- 플래시카드: 41장

## 주요 테마

### 1. 개발 도구 진화 — 성능이 교체의 동기

Git의 merge 전략이 resolve → recursive → ort로 진화하고([[git-merge-strategies]]), 프론트엔드 린팅/포매팅 도구가 JavaScript 기반(ESLint+Prettier)에서 Rust 기반([[biome]], [[oxfmt]])으로 전환되는 흐름. 공통점은 **성능 병목이 도구 교체의 주된 동기**라는 것. 포매터 영역에서는 [[biome]](통합)과 [[oxfmt]](전용)의 경쟁 구도가 형성 중.

대규모 [[monorepo-dx|모노레포]]에서 패키지 수 증가에 따른 도구 성능 저하가 개발자 경험에 직접적 영향을 미침.

### 2. React 컴포넌트 설계 패턴

[[compound-component-pattern]]을 중심으로 React 컴포넌트 설계 패턴 체계를 구축. 서브 컴포넌트 조합으로 유연한 UI를 구성하는 패턴의 구현 기법(Context API vs cloneElement), TypeScript 타입 설계, React Server Components 호환성까지 다룸.

[[headless-component]]는 Compound Component와 상호 보완적 — 스타일 없이 동작·접근성만 제공하여 Radix UI, shadcn/ui 등 현대 라이브러리의 기반이 됨.

두 테마의 교차점: Corca Design System의 테이블 컴포넌트 사례([[corca-compound-component]])가 실전 적용을 보여줌.

## 핵심 발견

- Rust 기반 도구 전환은 극적인 성능 개선: 에디터 저장 **189배**, CI **2.9배** 향상 ([[biome-migration-report]])
- Git ort는 recursive 대비 복잡한 머지 **500배**, rebase **9,000배** 빠름 ([[git-merge-strategy-ort]])
- [[oxfmt]]는 Prettier 대비 ~30배, [[biome]] 대비 ~2배 빠르지만, 린터 미포함으로 포지셔닝이 다름
- Compound Component 패턴은 Radix UI, shadcn/ui, Material UI 등 현대 React 라이브러리의 사실상 표준
- Context 기반 상태 공유의 성능 이슈는 Split Context(상태/액션 분리)로 해결
