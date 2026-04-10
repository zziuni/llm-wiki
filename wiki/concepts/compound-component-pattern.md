---
type: concept
summary: "React 합성 컴포넌트 패턴 — 하위 컴포넌트를 조합하여 유연한 UI를 구성하는 디자인 패턴"
tags:
  - react
  - design-pattern
  - component-architecture
sources:
  - "[[sources/corca-compound-component]]"
  - "[[sources/compound-component-pattern-web]]"
  - "[[sources/headless-component-web]]"
created: 2026-04-09
updated: 2026-04-10
status: active
---

# Compound Component Pattern

부모 컴포넌트가 상태·로직을 관리하고, 자식 컴포넌트들이 이를 **암묵적으로 공유**하며 조합되는 React 디자인 패턴. 각 서브 컴포넌트는 단일 책임 원칙(SRP)을 따르고, 사용자는 props 대신 **선언적 조합**으로 UI를 구성한다.

## 두 가지 구현 기법

### 1. Context API 방식 (권장)

부모가 Context Provider로 상태를 브로드캐스트하고, 자식이 `useContext`로 소비.

```tsx
const ToggleContext = React.createContext<ToggleContextType | null>(null)

function Toggle({ children }: { children: ReactNode }) {
  const [on, setOn] = useState(false)
  const toggle = useCallback(() => setOn(prev => !prev), [])
  const value = useMemo(() => ({ on, toggle }), [on])
  return (
    <ToggleContext.Provider value={value}>
      {children}
    </ToggleContext.Provider>
  )
}

// 안전한 소비자 훅 — Provider 밖에서 사용 시 에러
function useToggle() {
  const context = useContext(ToggleContext)
  if (!context) {
    throw new Error('Toggle 서브 컴포넌트는 <Toggle> 안에서만 사용 가능')
  }
  return context
}
```

**장점**: 깊이 제한 없음, 중간에 다른 컴포넌트 삽입 가능, 에러 바운더리 구현 용이.

### 2. React.Children.map + cloneElement 방식 (레거시)

부모가 직접 자식을 복제하면서 props를 주입.

```tsx
function FlyOut({ children }: { children: ReactNode }) {
  const [open, toggle] = useState(false)
  return (
    <div>
      {React.Children.map(children, child =>
        React.cloneElement(child as ReactElement, { open, toggle })
      )}
    </div>
  )
}
```

**한계**: **직접 자식만** props를 받을 수 있음 — 중간에 `<div>`로 감싸면 동작 안 함. 동일 이름 props가 있으면 덮어씀(shallow merge).

## 서브 컴포넌트 부착 패턴

```tsx
// 네임스페이스 객체로 노출
const Table = { Container, Thead, Th, Tbody, Tr, Td } as const;

// 또는 프로퍼티로 부착
Modal.Header = ModalHeader;
Modal.Body = ModalBody;
Modal.Footer = ModalFooter;
```

## 대표 사례

- **HTML 네이티브**: `<select>` + `<option>` — select는 UI/로직, option은 값(value)만 담당
- **오픈소스 라이브러리**: Radix UI, Headless UI, shadcn/ui, Material UI 모두 이 패턴 기반
- **실전 적용**: Corca Design System 테이블 — Td를 8종(Text, Img, Badge 등)으로 분리

## 다른 패턴과 비교

| 기준 | Control Props | Compound Component | Render Props |
|------|---------------|-------------------|--------------|
| API 형태 | 단일 컴포넌트에 많은 props | 서브 컴포넌트 조합 | 함수를 props로 전달 |
| 확장성 | props + 분기 증가 | 서브 컴포넌트 추가 (OCP) | 유연하지만 콜백 중첩 |
| 적합한 경우 | 단순/고정 요구사항 | 복잡/변경 가능성 높음 | 렌더링 로직 위임 필요 시 |

## Composition vs Inheritance

- **상속(Inheritance)**: `is-a` 관계. 부모-자식 수직 구조. 결합도 높음. 캡슐화 깨짐 우려.
- **합성(Composition)**: `has-a` 관계. 수평적 조합. 결합도 낮음. 변화에 유연.
- React 공식 문서: 상속 대신 합성 권장.

## TypeScript 타입 설계

### Context 타입 정의

```typescript
interface MenuContextType {
  isOpen: boolean;
  activeItem: string | null;
  toggle: () => void;
  selectItem: (id: string) => void;
}
```

### 제네릭 서브 컴포넌트

데이터 타입이 가변적인 경우(Table 등) 제네릭으로 타입 안전성 확보:

```typescript
interface TableData { id: string | number; [key: string]: any; }

interface TableContextType<T extends TableData> {
  data: T[];
  sort: (column: keyof T) => void;
}

function Table<T extends TableData>({ data, children }: TableProps<T>) { ... }
```

### Context 분리로 성능 최적화

상태와 액션을 별도 Context로 분리하면, 상태 변경 시 액션만 소비하는 컴포넌트는 리렌더되지 않음:

```typescript
const MenuStateContext = createContext<MenuState | undefined>(undefined);
const MenuActionsContext = createContext<MenuActions | undefined>(undefined);
```

## React Server Components와의 호환

RSC 환경에서 Compound Component를 사용하려면 서버/클라이언트 경계를 의식해야 한다.

### 핵심 제약
- **Context는 클라이언트 전용** — `createContext`/`useContext`는 Server Component에서 사용 불가
- Provider를 포함하는 루트 컴포넌트에 `'use client'` 지시어 필수

### "Hole in the Donut" 패턴

Provider(Client Component)가 children으로 Server Component를 렌더할 수 있다:

```tsx
// Dialog.Root — 'use client' (상태 관리)
// Dialog.Content의 children — Server Component 가능 (서버 렌더링 유지)

<Dialog.Root>           {/* Client Component */}
  <Dialog.Trigger />    {/* Client Component */}
  <Dialog.Content>      {/* Client Component */}
    <ServerRenderedForm /> {/* Server Component — 서버에서 렌더됨 */}
  </Dialog.Content>
</Dialog.Root>
```

**핵심**: 상태가 필요한 루트/인터랙션 컴포넌트만 Client로, 내부 콘텐츠는 Server Component로 유지 가능. 번들 크기를 줄이면서 패턴의 장점을 보존한다.

### 실전 가이드
- 상태 관리가 필요한 루트 컴포넌트(Root, Trigger)는 `'use client'`
- 콘텐츠 영역 children은 Server Component 가능
- Radix UI 등 라이브러리는 이미 이 구조를 따르고 있음

## 관련 패턴

- [[headless-component]] — 스타일 없이 동작·접근성만 제공. Compound Component와 상호 보완적으로 사용됨 (Radix UI, Headless UI)

## React 컴포넌트 패턴 비교

| 패턴 | 핵심 아이디어 | 장점 | 단점 | 적합한 경우 |
|------|-------------|------|------|------------|
| **Compound Component** | 서브 컴포넌트 조합 | 선언적 API, OCP | 단순 케이스도 서브 컴포넌트 필요 | 복잡한 UI 라이브러리 |
| **Render Props** | 함수를 prop으로 전달 | 유연한 렌더링 위임 | 콜백 중첩(wrapper hell) | 렌더 로직 완전 위임 |
| **Custom Hooks** | 로직을 훅으로 추출 | 로직 재사용, 간결 | UI 재사용 안 됨 | 상태/로직만 공유 |
| **HOC** | 컴포넌트를 감싸서 기능 추가 | 횡단 관심사 분리 | props 충돌, 디버깅 어려움 | 인증/로깅 등 횡단 관심사 |
| **Vanilla Props** | 기본 props 전달 | 가장 단순 | 복잡해지면 props 폭발 | 단순/고정 요구사항 |

> 기본 원칙: **필요한 만큼만 복잡한 패턴을 사용하라.** 대부분의 경우 Vanilla Props로 충분하다.

## 트레이드오프

**장점**
- 암묵적 상태 공유 → prop drilling 제거
- 선언적 API → 사용측 코드 가독성 향상
- 서브 컴포넌트 추가만으로 확장 (OCP)

**단점**
- Context 변경 시 모든 소비자 리렌더 — 복잡한 컴포넌트에서 성능 이슈 가능
- 깊은 중첩 구조가 될 수 있음
- 서브 컴포넌트를 Provider 밖에서 사용하면 무의미 — 반드시 에러 핸들링 필요
- 서브 컴포넌트를 별도 re-export하면 오용 가능 — export는 부모를 통해서만

## 도입 판단 기준

- 요구사항이 복잡하거나 변경 가능성이 높으면 → Compound Component
- 요구사항이 단순하고 고정적이면 → Control Props가 더 직관적
- 서브 컴포넌트가 SRP를 위반하면 합성 패턴이어도 무너진다
- 디자인 시스템이나 컴포넌트 라이브러리를 만들 때 → 거의 필수

## Flashcards
#flashcards

Compound Component Pattern이란?::부모 컴포넌트가 상태·로직을 관리하고, 자식 컴포넌트들이 이를 암묵적으로 공유하며 조합되는 React 디자인 패턴. 선언적 조합으로 UI를 구성한다.

Control Props 패턴의 한계:::Compound Component 패턴의 장점

합성(Composition)은 ==has-a== 관계, 상속(Inheritance)은 ==is-a== 관계이다.

Compound Component의 두 가지 구현 기법
?
1) Context API 방식 (권장) — Provider로 상태 브로드캐스트, useContext로 소비. 깊이 제한 없음.
2) cloneElement 방식 (레거시) — 직접 자식만 props 주입 가능. 중간 래핑 시 동작 안 함.

Compound Component에서 Context 소비자 훅의 에러 핸들링이 필요한 이유::서브 컴포넌트를 Provider 밖에서 사용하면 context가 null이 되어 조용히 실패함. `if (!context) throw new Error(...)` 패턴으로 즉시 감지해야 한다.

Compound Component 패턴을 사용하는 대표 오픈소스 라이브러리::Radix UI, Headless UI, shadcn/ui, Material UI

HTML에서 가장 대표적인 Compound Component 예시::select + option. select는 UI/로직 담당, option은 값(value)만 담당.

Compound Component의 Context 기반 상태 공유의 단점::Context 값이 변경되면 모든 소비자 컴포넌트가 리렌더된다. 복잡한 컴포넌트에서 성능 이슈 가능.

Compound Component에서 Context 리렌더 문제의 해결법::상태(State)와 액션(Actions)을 별도 Context로 분리. 액션만 소비하는 컴포넌트는 상태 변경 시 리렌더되지 않음.

RSC 환경에서 Compound Component 사용 시 핵심 제약::Context는 클라이언트 전용. Provider를 포함하는 루트 컴포넌트에 'use client' 지시어 필수. 단, children으로 Server Component를 렌더할 수 있다("Hole in the Donut" 패턴).

Render Props 패턴 vs Compound Component 패턴
?
Render Props: 함수를 prop으로 전달하여 렌더 로직 위임. 유연하지만 콜백 중첩(wrapper hell) 우려.
Compound Component: 서브 컴포넌트 조합으로 선언적 API. 단순 케이스도 서브 컴포넌트가 필요한 것이 단점.
