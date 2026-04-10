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

소프트웨어 엔지니어링 지식 위키. 개발 도구, 컴포넌트 패턴, CI/CD, 클라우드 서비스 모델을 다룬다.

## 현재 상태
- 소스: 11건
- 개념 페이지: 11건
- 엔티티 페이지: 2건
- 분석 페이지: 6건
- 플래시카드: 68장

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

### 3. 29CM 코드베이스 분석

[[pdp-problem-analysis]]에서 PDP 번들 908KB, fetchProductDetail 코드 7회 호출, ProductDetailContext 64개 구독자 등 정량 분석. [[pdp-restructure-hld]]로 home→pdp 앱 분리와 product review 통합 설계. [[hook-chaining-analysis]]에서 God Hook 패턴(usePurchase 21 hooks 등)과 3가지 경계 조건 도출.

[[composition-two-axes]]는 Hook Composition(내부/블랙박스)과 Compound Component(외부/화이트박스)의 근본적 차이를 개념화. [[packages-restructure-hld]]에서 barrel 평면화 5기준과 단일앱 패키지 21→5개 검증. 전체를 [[codebase-improvement-roadmap]]로 5개 워크스트림 × 4단계 타임라인으로 종합.

### 4. 클라우드 서비스 모델

[[saas]]를 중심으로 클라우드 서비스 모델(IaaS/PaaS/SaaS)의 정의와 특성을 정리. SaaS 비즈니스 메트릭(MRR, LTV, CAC, NRR 등)과 Microsoft의 4단계 성숙도 모델(멀티테넌시·확장성·구성 가능성 축)까지 다룸.
