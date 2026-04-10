---
title: "29CM Frontend Hook 체이닝 현황 분석"
type: analysis
created: 2026-04-10
tags: [react, hooks, god-hook, code-quality, anti-pattern]
related: ["[[composition-two-axes]]", "[[codebase-improvement-roadmap]]", "[[pdp-problem-analysis]]"]
---

# 29CM Frontend Hook 체이닝 현황 분석

## 분석 배경

codebase-mental-model.md의 원칙 3(Composition)이 "조합하라"만 말하고 "언제 조합이 과해지는가"를 말하지 않아, 실제 코드베이스에서 Hook 체이닝 문제의 규모를 측정함.

## God Hook 현황 (2026-04-10)

| Hook | 위치 | hook 수 | 깊이 | 혼재 관심사 |
|------|------|---------|------|------------|
| `usePurchase` | features-catalog | **21** | 3-4 | 구매+인증+UI+쿼리 |
| `useEventNotificationSubscription` | features-user | **18** | 3 | SnackBar+BottomSheet+Notification+앱상태 |
| `useFixedButtonHandlers` | features-catalog | **13+** | 2-3 | 재입고+구매+인증+Dialog 3종 |
| `useShareCatalog` | features-catalog | **8+** | 3 | 리워드+공유+인증 |
| `usePreuserNotificationSubscribe` | features-preuser | **8** | 3 | features-user 3건 의존 |

## 체인 깊이 예시 (usePurchase)

```
usePurchase (catalog)
  → usePurchaseFlow (local) — 깊이 2
    → useCachedFetch (contexts) — 깊이 3
    → usePurchaseValidDialog (local) — 깊이 3
    → useSendMessage (contexts) — 깊이 3
  → usePurchaseContextActions (local) — 깊이 2
    → usePurchaseContext (local Context) — 깊이 3
```

## 피처 간 의존 문제

```
features-preuser → features-user (3건 직접 import)
  ├── useNotificationAgreement
  ├── useNotificationAgreementFullScreen
  └── useAppNotificationAgreementFullScreen

features-catalog → features-runtime (useShare)
```

## 도출된 경계 조건 (3가지)

1. **깊이 ≤ 2단계**: 3단계 이상이면 중간 레이어 누락 신호
2. **관심사 1개/hook**: "그리고"가 들어가면 분리 대상
3. **피처 간 방향**: features-A → features-B 직접 금지, 공유 패키지 경유

## 해결 패턴: 컴포넌트 오케스트레이션

hook끼리 직접 호출하는 대신, 컴포넌트가 여러 hook의 결과를 받아서 조율.

```tsx
const PurchaseSection = ({ itemNo }) => {
  const { isValid, error } = usePurchaseValidation(itemNo);
  const { submit, isSubmitting } = usePurchaseSubmit(itemNo);
  const { showError } = usePurchaseUI();
  // 컴포넌트가 오케스트레이션
};
```

## Compound Component 현황

- 코드베이스 전체에서 **진짜 Compound Component는 InfoTable 1개뿐**
- 적용 후보: ShareTypeSelector(11 props), BffRecommendationCarouselMain(11 props), CommonLayout(7 hide props)
