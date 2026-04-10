---
type: analysis
summary: "PDP 현황 분석: 번들 908KB, fetchProductDetail 코드 7회 호출, ProductDetailContext 64개 구독자, 3가지 페칭 패턴 혼재"
domain: pdp
tags:
  - pdp
  - performance
  - architecture
  - product-detail
sources:
  - "_docs/goalArchitecture/pdp-restructure/pdp-problem-analysis.md"
created: 2026-04-09
updated: 2026-04-10
status: active
---

# PDP 현황 분석

## 목차
- [개요](#개요)
- [핵심 발견사항](#핵심-발견사항)
- [Server Component 데이터 호출 구조](#server-component-데이터-호출-구조)
- [CSR 데이터 페칭](#csr-데이터-페칭)
- [렌더링 전파 문제](#렌더링-전파-문제)
- [번들 사이즈](#번들-사이즈)
- [페칭 패턴 혼재](#페칭-패턴-혼재)
- [force-dynamic 전략](#force-dynamic-전략)
- [관련 PR](#관련-pr)
- [남은 구조적 문제](#남은-구조적-문제)

---

## 개요

- **분석 대상**: `apps/home/src/app/(home)/products/[id]/page.tsx`
- **핵심 패키지**: `@29cm/features-catalog` (434파일), `@29cm/features-review`, `@29cm/apis-bff`
- **분석 시점**: 2026-04-09 (main 브랜치 기준)

home 앱의 PDP(상품 상세 페이지)는 코드베이스에서 가장 복잡한 페이지다. 번들 908KB, features-catalog 434파일 모놀리스, 64개 컴포넌트가 단일 Context를 구독하는 구조로, 반복적인 성능/사이드이펙트 이슈의 근원이다.

---

## 핵심 발견사항

| 순위 | 문제 | 위반 원칙 | 영향 |
|------|------|-----------|------|
| 1 | home과 PDP 결합 배포 | 아키텍처 결정 | 장애 전파, 배포 리스크 |
| 2 | Server Component 간 데이터 공유 부재 (코드 7회, HTTP ~2회) | 원칙 2: One Level of Abstraction | 낭비적 추상화, 프레임워크 의존 |
| 3 | force-dynamic으로 CDN 캐시 무효화 | 아키텍처 결정 | 서버 부하, 응답 지연 |
| 4 | ProductDetailContext 80+ props를 64개 컴포넌트 구독 | 가이드라인 3: Narrow Interface | 불필요한 리렌더링 |
| 5 | 번들 908KB, 동적 임포트 미사용 | 가이드라인 3: Narrow Interface (exports) | 초기 로드 지연 |
| 6 | 3가지 페칭 패턴 혼재 | 원칙 1: Abstraction Barrier | 캐시 불일치, 디버깅 복잡도 |
| 7 | features-catalog 434파일 모놀리스 | 원칙 3: Composition | 변경 영향 범위 과대 |
| 8 | product 앱 review 분리 상태 | 아키텍처 결정 | 하드 네비게이션, 코드 중복 |
| 9 | WebView 감지 로직 분산 (8+개소) | 원칙 6: Anti-Corruption Layer | 플랫폼 로직 일관성 부족 |

---

## Server Component 데이터 호출 구조

`fetchProductDetail`이 **코드 레벨 7회** 호출되지만, Next.js Request Memoization으로 **HTTP 레벨은 ~2회**.

| # | 호출 위치 | 함수 | 비고 |
|---|-----------|------|------|
| 1 | `generateMetadata` | `getProductDetail(itemId)` | |
| 2 | `Page` | `getProductDetail(itemNo, { cookie })` | **유일하게 Cookie 포함 — 별도 HTTP 요청** |
| 3 | `SummaryInfoSection` | `getProductDetail(itemNo)` | |
| 4 | `SummaryInfoSection` | `getSummaryInfoData(itemNo)` | 내부에서 fetchProductDetail → 3개 필드만 추출 |
| 5 | `SummaryInfoSection` | `getOptionsData(itemNo)` | 내부에서 fetchProductDetail → 옵션 필드만 추출 |
| 6 | `FixedMobileButtonsSection` | `getOptionsData(itemNo)` | 동일 패턴 |
| 7 | `FixedMobileButtonsSection` | `getProductDetail(itemNo)` | |

**진짜 문제는 HTTP 중복이 아니라:**
1. **낭비적 추상화** — `getSummaryInfoData`는 전체 productDetail을 가져와 `frontBrand`, `itemNo`, `itemName` 3개 필드만 추출. [[composition-two-axes]]의 관점에서 "API 호출"과 "필드 추출"이라는 서로 다른 추상화 수준의 혼합
2. **프레임워크 암묵적 동작 의존** — `createFetcher` 내부 구현이 바뀌면 중복 제거가 깨질 수 있음
3. **파싱/변환 중복 실행** — HTTP는 중복 제거되어도 응답 파싱/변환/에러 처리는 7회 모두 실행

---

## CSR 데이터 페칭

| 카테고리 | API 수 | 호출 시점 |
|----------|--------|-----------|
| 상품 부가정보 | 1 | 즉시 (fetchProductDetailAdditional) |
| 프로모션/쿠폰 | 3 | 즉시 |
| 리뷰 | 1 | IdleRender 후 |
| QnA | 2 | IdleRender 후 |
| 추천 캐러셀 | 3~5 | IdleRender 후 |
| 배너/포스트 | 2 | IdleRender 후 |
| 조건부 | 2~3 | 즉시 (조건 충족 시) |
| **총계** | **14~19** | — |

Feature Flag 5개 운영 중 (`PDP_OPTION_API_SEPARATION`, `AVAILABLE_PURCHASE_PRICE_SECTION_VISIBLE`, `PDP_IS_ORDER_CHECK`, `ENABLE_CURATOR_LINK`, `PDP_EXTERNAL_CHANNEL_BLOCK_INFO`) + 레거시 1건 (`TICKET_APP_UPDATE_POPUP` — `@29cm/contexts-feature-flags` 사용, 마이그레이션 필요)

---

## 렌더링 전파 문제

`ProductDetailContext`가 80+ 프로퍼티를 가진 거대 객체를 통째로 공유. `setFrontItemStockStatus()` 호출 시 실제 변경은 1개 필드인데 **64개 구독 컴포넌트 전부 리렌더링**.

`itemStatus`와 `isSoldOut`만 별도 메모이제이션. 나머지 프로퍼티 접근은 전부 전체 객체 구독.

---

## 번들 사이즈

| 항목 | 사이즈 | 비고 |
|------|--------|------|
| PDP 페이지 번들 | **908KB** | home 앱 최대 |
| features-catalog | 434파일 | 모든 섹션 정적 임포트 |
| 순환 의존성 | 112개 | 트리 쉐이킹 차단 |

page.tsx에서 45개 컴포넌트를 직접 import. `IdleRender`로 렌더링은 지연하지만 번들은 이미 포함. 동적 임포트(`next/dynamic`, `React.lazy`) 미사용.

---

## 페칭 패턴 혼재

| 패턴 | 사용 위치 | 특징 |
|------|-----------|------|
| Server Component 직접 호출 | `getProductDetail`, `getOptionsData` 등 | 캐시 없음 (`no-store`) |
| useCachedFetch (레거시) | `fetchProductDetailAdditional` 등 44건 | 인메모리 캐시, React Query와 별개 |
| useFetcherQuery (React Query) | `fetchReviewSummary` 등 | staleTime/cacheTime, devtools 지원 |

동일 페이지에서 캐시 전략 3가지 분산 → 데이터 일관성/디버깅 복잡도 문제.

---

## force-dynamic 전략

```typescript
// apps/home/src/app/(home)/products/[id]/page.tsx:61
export const dynamic = 'force-dynamic';
```

home 앱 기본 전략은 Static Rendering + ISR (`revalidate = 180`)이지만 PDP만 `force-dynamic`. 쿠키 기반 개인화(쿠폰가 실험군)가 이유이나, 클라이언트 사이드로 분리 가능.

---

## 관련 PR

- **PR #6393 (Merged)**: CSR에서 fetchProductDetail 중복 호출 2건 제거. Context 단일 소스 관리로 일관성 향상. Server Component 구조 문제는 미해결.
- **PR #6379 (Open)**: PDP 옵션 v6 API 분리, 옵션 CSR 전환 (Feature Flag: `PDP_OPTION_API_SEPARATION`). 코드 레벨 호출 7→5회 감소. `getSummaryInfoData` 등 나머지 구조적 문제는 여전.

---

## 남은 구조적 문제

두 PR 적용 후에도 남는 문제:

| 문제 | 해결 여부 |
|------|-----------|
| Server Component 간 데이터 공유 부재 | ❌ |
| ProductDetailContext 64개 구독자 리렌더링 | ❌ |
| 번들 908KB, 동적 임포트 미사용 | ❌ |
| 페칭 패턴 혼재 (v6으로 4가지로 확대) | ❌ |
| force-dynamic 전략 | ❌ |
| features-catalog 434파일 모놀리스 | ❌ |
| home/PDP 배포 결합 | ❌ |

→ 구조적 해결을 위한 HLD: [[pdp-restructure-hld]]

> 상세 원문: `_docs/goalArchitecture/pdp-restructure/pdp-problem-analysis.md`
> 관련: [[hook-chaining-analysis]], [[codebase-improvement-roadmap]]
