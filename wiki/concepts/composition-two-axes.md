---
title: "Composition의 두 축: Behavior와 Structure"
type: concept
created: 2026-04-10
tags: [react, composition, compound-component, hook, mental-model]
related: ["[[hook-chaining-analysis]]", "[[codebase-improvement-roadmap]]"]
---

# Composition의 두 축: Behavior와 Structure

## 핵심 발견

React의 Composition 원칙은 단일 개념이 아니라, **조합 대상**과 **인터페이스 가시성**이 다른 두 축으로 나뉜다.

## Behavior Composition (Hook 조합)

- **조합 대상**: 로직 (상태, 효과, 비즈니스 규칙)
- **인터페이스**: 내부적 — 소비자에게 보이지 않음 (블랙박스)
- **제어권**: 작성자가 내부 조합을 결정
- **과도해지면**: 보이지 않는 의존 그래프 → 디버깅 불능

```tsx
// 소비자는 내부를 모른다
const { toggleHeart } = useBrandHeart({ brandNo });
```

## Structure Composition (Component 조합)

- **조합 대상**: UI 구조 (시각적 계층, 렌더링)
- **인터페이스**: 외부적 — 소비자의 JSX에 드러남 (화이트박스)
- **제어권**: 소비자가 조합을 결정 (Inversion of Control)
- **과도해질 위험**: 적음 (소비자가 통제하므로)

```tsx
// 소비자가 구조를 결정한다
<InfoTable>
  <InfoTable.Header>주문 정보</InfoTable.Header>
  <InfoTable.Row label="주문번호">{orderNo}</InfoTable.Row>
</InfoTable>
```

## 같은 것으로 취급하면 안 되는 이유

| | Hook Composition | Compound Component |
|---|---|---|
| 과도해지면 | 보이지 않는 의존 그래프 | 발생하지 않음 |
| 부족하면 | 로직 중복 | God Component, Props 폭발 |
| 방어 규칙 | 깊이 제한, 관심사 수 제한 | Props 수 제한, hide props 금지 |

## God Component는 두 축이 동시에 부재할 때 발생

```
PaymentCheckoutButton.tsx (1,528줄)
├── Hook Composition 부재 → 로직이 inline으로 존재
└── Structure Composition 부재 → UI 전체가 하나의 렌더 함수
```

## 적용 위치

- `codebase-mental-model.md` 원칙 3에 "두 축" 개념 추가
- `good-pattern-guidelines.md`에 가이드라인 4 (Composable UI) 추가
- `good-pattern-guidelines.md`에 원칙 3 보강 (Hook 건강 조건) 추가
