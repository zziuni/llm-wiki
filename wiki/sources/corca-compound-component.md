---
type: source
summary: "Corca 디자인 시스템에서 Control Props → Compound Component 패턴으로 테이블 컴포넌트를 리팩터링한 사례"
tags:
  - react
  - design-pattern
  - component-architecture
  - design-system
sources:
  - "[[raw/디자인 시스템에 Compound Component Pattern 적용기]]"
created: 2026-04-09
updated: 2026-04-09
status: active
---

# 디자인 시스템에 Compound Component Pattern 적용기

**출처**: Corca Medium Blog (2024-07-09)
**작성자**: 손도희, 홍승연 (Frontend Engineer, Corca)

## 요약

Corca Design System(CDS)의 테이블 컴포넌트가 Control Props 패턴으로 인해 props 폭발, 가독성/확장성 저하 문제를 겪자, [[compound-component-pattern]] 을 도입하여 해결한 사례.

## 문제 상황

- 단일 `Table` 컴포넌트가 `format`, `width`, `height` 등 복잡한 중첩 props를 받음
- 요구사항 추가마다 props + 분기 처리 증가 → 내부 로직 복잡화
- 새 기능 추가가 기존 코드와 호환되기 어려움

## 해결: Compound Component 구조

```tsx
const Table = { Container, Thead, Th, Tbody, Tr, Td } as const;
```

- **Th**: `Default` (텍스트+아이콘) / `Checkbox` 2종
- **Td**: `Text`, `Img`, `Badge`, `Switch`, `Select`, `Checkbox`, `Radio`, `Icon` — 8종
- 사이즈(`s/m/l`)별 스타일 매핑을 각 서브 컴포넌트가 독립 관리

## 핵심 인용

> "이제 또 다른 데이터 셀 컴포넌트 디자인 요청이 들어오더라도 두렵지 않습니다. 000Td 컴포넌트만 개발하여 추가하고, 기존 코드는 전혀 수정할 필요가 없기 때문이죠!"

> "React has a powerful composition model, and we recommend using composition instead of inheritance to reuse code between components."

## 발견한 개념

- [[compound-component-pattern]] — 이 소스의 핵심 주제
