---
type: source
summary: "Compound Component Pattern 웹 소스 3건 — patterns.dev, Kent C. Dodds, freeCodeCamp의 구현 기법·트레이드오프 정리"
tags:
  - react
  - design-pattern
  - component-architecture
sources:
  - "[[raw/디자인 시스템에 Compound Component Pattern 적용기]]"
created: 2026-04-09
updated: 2026-04-09
status: active
---

# Compound Component Pattern — 웹 소스 종합

autoresearch로 수집한 웹 소스 3건의 종합 정리.

## 소스 목록

1. **patterns.dev** — [Compound Pattern](https://www.patterns.dev/react/compound-pattern/)
   - Context API vs cloneElement 두 기법 비교
   - cloneElement의 한계: 직접 자식만 접근 가능, shallow merge 충돌
2. **Kent C. Dodds** — [Compound Components with React Hooks](https://kentcdodds.com/blog/compound-components-with-react-hooks)
   - Context + custom hook 패턴의 정석 구현
   - `useMemo`/`useCallback`을 활용한 불필요한 리렌더 방지
   - Provider 밖 사용 시 에러 던지기 패턴
3. **freeCodeCamp** — [How to Use the Compound Components Pattern](https://www.freecodecamp.org/news/compound-components-pattern-in-react/)
   - Radix UI, shadcn/ui, Material UI 등 실전 라이브러리 언급
   - 서브 컴포넌트 별도 re-export 금지 원칙
   - 깊은 중첩 구조 주의

## 핵심 발견

### Context API가 권장되는 이유
- cloneElement는 **직접 자식**만 props 주입 가능 → 중간에 래퍼 삽입 시 동작 안 함
- Context는 깊이 제한 없이 상태 공유 → 더 유연한 조합 가능
- custom hook에 에러 핸들링 추가 가능 → DX 향상

### 성능 고려사항
- Context 값 변경 시 모든 소비자 리렌더 → `useMemo`로 value 메모이제이션 필수
- 복잡한 컴포넌트에서는 Context 분리(상태 context / dispatch context) 고려

### 적용 중인 주요 라이브러리
Radix UI, Headless UI, Reach UI, shadcn/ui, Material UI — 현대 React 컴포넌트 라이브러리의 사실상 표준 패턴.

## 발견한 개념

- [[compound-component-pattern]] — 이 소스들의 핵심 주제
