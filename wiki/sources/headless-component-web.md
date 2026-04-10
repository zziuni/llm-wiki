---
type: source
summary: "Headless Component 패턴 웹 소스 2건 — Alyssa Holland 블로그, Pasquale Favella의 TypeScript 가이드"
tags:
  - react
  - design-pattern
  - accessibility
  - typescript
sources: []
created: 2026-04-09
updated: 2026-04-09
status: active
---

# Headless Component & TypeScript — 웹 소스

autoresearch Round 2에서 수집한 웹 소스.

## 소스 목록

1. **Alyssa Holland** — [Headless Components](https://blog.alyssaholland.me/headless-components)
   - Headless Component의 정의와 핵심 철학
   - Radix UI, Headless UI, React Aria, Reach UI 비교
   - 컴포넌트 기반 vs 훅 기반 접근 구분
2. **Pasquale Favella** — [Mastering the Compound Pattern in React with TypeScript](https://pasquale-favella.github.io/blog/28)
   - Context 타입 정의, 제네릭 서브 컴포넌트 패턴
   - Split Context 전략으로 성능 최적화
   - custom hook 에러 핸들링 패턴

## 핵심 발견

### Headless = 철학, Compound = API 구조
두 패턴은 경쟁 관계가 아니라 **상호 보완적**. Radix UI는 Headless(스타일 없음) + Compound(서브 컴포넌트 조합)을 동시에 사용.

### TypeScript Split Context
상태와 액션을 별도 Context로 분리하면, 액션만 소비하는 컴포넌트는 상태 변경 시 리렌더 방지 — 실전 성능 최적화 핵심.

## 발견한 개념

- [[headless-component]] — 이 소스의 핵심 주제
- [[compound-component-pattern]] — TypeScript 타입 설계 보강
