---
type: concept
summary: "스타일 없이 동작·접근성만 제공하는 UI 컴포넌트 패턴 — Radix UI, Headless UI 등의 기반 철학"
tags:
  - react
  - design-pattern
  - component-architecture
  - accessibility
sources:
  - "[[sources/compound-component-pattern-web]]"
  - "[[sources/headless-component-web]]"
created: 2026-04-09
updated: 2026-04-09
status: active
---

# Headless Component

스타일 없이 **동작(behavior)과 접근성(accessibility)만 제공**하는 UI 컴포넌트 패턴. 로직과 프레젠테이션을 분리하여, 개발자가 자유롭게 스타일링하면서도 복잡한 인터랙션·WAI-ARIA·키보드 내비게이션을 내장으로 제공받는다.

## 핵심 철학

> "Unopinionated, unstyled components that handle a majority of the tricky implementation details."

- **관심사 분리**: 동작/접근성 ↔ 스타일링을 완전히 분리
- **개발자에게 렌더링 제어권 반환**: preset CSS 없이 자체 디자인 시스템 적용 가능
- **복잡한 패턴의 민주화**: date picker, autocomplete, dialog 등의 접근성 구현을 라이브러리가 담당

## [[compound-component-pattern]]과의 관계

Headless Component는 **철학**, Compound Component는 **API 구조**:

| 구분 | Headless Component | Compound Component |
|------|-------------------|-------------------|
| 관심사 | 스타일 없이 동작만 제공 | 서브 컴포넌트 조합으로 유연한 API |
| 초점 | What (무엇을 제공하나) | How (어떻게 구성하나) |
| 관계 | 상호 보완적 — 함께 사용됨 | 상호 보완적 — 함께 사용됨 |

Radix UI, Headless UI는 **둘 다** 사용: Headless(스타일 없음) + Compound(서브 컴포넌트 조합).

## 두 가지 구현 접근

### 1. 컴포넌트 기반 (Radix UI, Headless UI)

```tsx
// Radix UI Tabs
<Tabs.Root defaultValue="tab1">
  <Tabs.List>
    <Tabs.Trigger value="tab1">One</Tabs.Trigger>
    <Tabs.Trigger value="tab2">Two</Tabs.Trigger>
  </Tabs.List>
  <Tabs.Content value="tab1">Content 1</Tabs.Content>
  <Tabs.Content value="tab2">Content 2</Tabs.Content>
</Tabs.Root>
```

### 2. 훅 기반 (React Aria)

```tsx
// React Aria — 훅으로 동작을 주입
const { tabListProps } = useTabList(props, state, ref);
return <div {...tabListProps} ref={ref}>{/* custom rendering */}</div>;
```

## 주요 Headless 라이브러리

| 라이브러리 | 접근 방식 | 특징 |
|-----------|----------|------|
| Radix UI | 컴포넌트 | 종합 프리미티브, shadcn/ui의 기반 |
| Headless UI | 컴포넌트 | Tailwind CSS 팀 제작, 경량 |
| React Aria | 훅 | Adobe, 적응형 인터랙션 |
| Reach UI | 컴포넌트 | 접근성 중심 (React Router 작성자) |

## 트레이드오프

**장점**: 접근성 내장, 스타일 자유도, 디자인 시스템 기반으로 적합
**단점**: 스타일링과 일부 렌더링 로직을 개발자가 직접 구현해야 함 — 추가 작업 필요

## Flashcards
#flashcards

Headless Component란?::스타일 없이 동작(behavior)과 접근성(accessibility)만 제공하는 UI 컴포넌트 패턴. 개발자가 자유롭게 스타일링하면서 복잡한 인터랙션·WAI-ARIA를 내장으로 받는다.

Headless Component와 Compound Component의 관계
?
상호 보완적. Headless는 "무엇을 제공하나"(스타일 없이 동작만), Compound는 "어떻게 구성하나"(서브 컴포넌트 조합).
Radix UI, Headless UI는 둘 다 함께 사용한다.

Headless 컴포넌트의 두 가지 구현 접근::1) 컴포넌트 기반 (Radix, Headless UI) — 서브 컴포넌트 조합. 2) 훅 기반 (React Aria) — 동작을 훅으로 주입하고 렌더링은 완전히 위임.

shadcn/ui의 기반이 되는 headless 라이브러리::Radix UI Primitives
