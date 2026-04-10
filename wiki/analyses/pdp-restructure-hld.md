---
type: analysis
summary: "PDP 분리 HLD: home→pdp 앱 분리, product review 통합, mental model 기반 계층 개선"
domain: pdp
tags:
  - pdp
  - hld
  - architecture
  - migration
  - app-separation
sources:
  - "_docs/goalArchitecture/pdp-restructure/hdl.md"
created: 2026-04-09
updated: 2026-04-10
status: active
---

# PDP 분리 및 구조 개선 HLD

## 목차
- [배경](#배경)
- [목표](#목표)
- [목표가 아닌 것](#목표가-아닌-것)
- [앱 분리 설계](#앱-분리-설계)
- [계층 구조 개선](#계층-구조-개선)
- [product 앱 review 통합](#product-앱-review-통합)
- [개선 원칙 매핑](#개선-원칙-매핑)
- [제약 조건](#제약-조건)

---

## 배경

[[pdp-problem-analysis]]에서 도출된 핵심 문제:

| 현상 | 근본 원인 |
|------|-----------|
| Server Component에서 동일 API 코드 레벨 7회 호출 | 원칙 2 위반: `getSummaryInfoData`/`getOptionsData`가 "API 호출"과 "필드 추출" 혼합 |
| ProductDetailContext 80+ props → 64개 구독자 리렌더링 | 가이드라인 3 위반: 거대 객체를 통째로 Context 노출 |
| 3가지 페칭 패턴 혼재 | 원칙 1 위반: 데이터 페칭 추상화 장벽 불일치 |
| features-catalog 434파일 정적 임포트 → 908KB | 가이드라인 3 위반: 번들 팽창 |
| PDP와 home 동일 앱 배포 | 트래픽 격리 부재, 장애 전파 |
| product 앱 review가 Pages Router 별도 앱 | 하드 네비게이션, 코드 중복 |

---

## 목표

### 1. home에서 PDP를 별도 앱(apps/pdp)으로 분리
- **트래픽 분리**: 홈페이지와 PDP 트래픽 물리적 격리, 장애 전파 차단
- **배포 독립성**: PDP 변경이 홈에 영향 없는 독립 배포 파이프라인
- **렌더링 전략 독립**: force-dynamic vs ISR 분리 선택 가능

### 2. product 앱의 PDP review를 신규 앱으로 통합
- Pages Router → App Router 전환
- 하드 네비게이션 제거

### 3. codebase mental model 기반 계층 개선
- 원칙 2(One Level of Abstraction): getSummaryInfoData/getOptionsData 제거
- 가이드라인 3(Narrow Interface): ProductDetailContext 관심사별 분리
- 가이드라인 4(Composable UI): 'use client' 경계를 인터랙션 최소 범위로

---

## 목표가 아닌 것

- **API endpoint/schema 개선**: BFF v5→v6 전환은 별도 이니셔티브 (PR #6379)
- **Provider 의존/legacy query adapter 개선**: `@29cm/contexts-*` 전면 마이그레이션, `useCachedFetch` → React Query 전환은 별도
- **Context 근본적 재설계**: `PurchaseProvider`, `ProductDetailProvider` 재설계는 스코프 외

---

## 앱 분리 설계

```
현재                                    목표
──────                                ──────
apps/home/                            apps/home/
  ├── (home)/(main)/    홈페이지         ├── (home)/(main)/    홈페이지
  ├── (home)/products/  PDP  ← 제거     └── ...               (PDP 제거)
  └── ...
                                      apps/pdp/              ← 신규 앱
apps/product/                           ├── products/[id]/    PDP (home에서 이전)
  ├── catalog/[id]/     PDP (Deprecated)  ├── products/[id]/review/  (product에서 통합)
  ├── catalog/[id]/review  리뷰 목록      └── 독립 배포 파이프라인
  └── ...
```

**분리 기준**:
- PDP는 `force-dynamic`이 필요한 유일한 페이지 — home의 ISR과 충돌
- 트래픽 프로파일이 다름 — 홈은 넓고 얕은 트래픽, PDP는 깊고 집중된 트래픽
- 도메인 복잡도 — features-catalog 434파일이 PDP 전용

---

## 계층 구조 개선

Server Component/Client Component 경계를 재설계 (가이드라인 4):

```
현재 page.tsx                          목표 page.tsx
──────────────                        ──────────────

Page (Server Component)               Page (Server Component)
  └── productDetail = await fetch        └── productDetail = await fetch
      │                                      │
      ├── ProductDetailProvider              ├── SummaryInfoSection
      │     (Client, Context에 80+props)     │     summaryData={pick(productDetail, ...)}
      │     └── 45개 컴포넌트                │     optionsData={derive(productDetail)}
      │         모두 Context 구독             │
      └── SummaryInfoSection                 ├── FixedMobileButtonsSection
            (Server, 독립 3회 fetch)          │     optionsData={derive(productDetail)}
                                             │
                                             └── ClientSections (Client 경계)
                                                   └── 인터랙션 필요한 영역만
```

- **원칙 2**: `getSummaryInfoData`/`getOptionsData` 제거. Page에서 productDetail 파생 후 prop 전달
- **가이드라인 3**: 각 섹션은 전체 productDetail이 아닌 필요한 필드만 prop 수신
- **가이드라인 4**: `'use client'` 경계를 인터랙션 최소 범위로 제한

---

## product 앱 review 통합

```
현재                                    목표
──────                                ──────
apps/product/                         apps/pdp/
  src/pages/catalog/[id]/review.tsx     src/app/products/[id]/review/page.tsx
    ├── getServerSideProps (SSR)          ├── Server Component (데이터 페칭)
    └── reviewApi.getReviewSummary        └── ReviewListPage (App Router)

apps/product/                         packages/features/review/
  src/apps/review-list/                 ├── ReviewSection (PDP 내 요약)
    ├── ReviewListPage.tsx              └── ReviewListPage (전체 리뷰)
    └── ReviewSection.tsx
```

**마이그레이션 전략**:
1. product 앱의 `review-list` 모듈 내 순수 UI 컴포넌트를 `features-review`로 이동
2. Pages Router `getServerSideProps` → App Router Server Component 전환
3. 레거시 `itemDetailApiService` → `@29cm/apis-bff` 표준 패턴 전환
4. product 앱의 `/catalog/[id]/review` → 신규 PDP 앱으로 리다이렉트

---

## 개선 원칙 매핑

| 개선 항목 | 적용 원칙 | 구체적 행동 |
|-----------|-----------|-------------|
| Page → Section prop drilling | 원칙 2: One Level of Abstraction | getSummaryInfoData/getOptionsData 제거, Page에서 파생 후 prop 전달 |
| ProductDetailContext 축소 | 가이드라인 3: Narrow Interface | 전체 객체 대신 관심사별 좁은 인터페이스 분리 |
| 'use client' 경계 내리기 | 가이드라인 4: Composable UI | Server Component 비중 확대, 인터랙션 최소 범위만 Client |
| 번들 분할 | 가이드라인 3: Narrow Interface (exports) | 추천 섹션 동적 임포트, IdleRender 영역 코드 분할 |
| 앱 분리 | 아키텍처 결정 | 트래픽/배포/렌더링 전략 독립 |
| review 통합 | 아키텍처 결정 | Pages Router → App Router, 하드 네비게이션 제거 |

---

## 제약 조건

1. **점진적 마이그레이션**: 빅뱅 전환이 아닌, 기능별 점진적 이전
2. **기존 URL 호환**: `/products/[id]` URL 유지 (리버스 프록시 또는 rewrites로 라우팅)
3. **Provider 구조 유지**: PurchaseProvider, ProductDetailProvider 근본 재설계는 스코프 외
4. **API 호환**: BFF API v5/v6 엔드포인트 변경 없이, FE 레이어 구조 개선에 집중

> 문제 분석 상세: [[pdp-problem-analysis]]
> 관련: [[codebase-improvement-roadmap]], [[hook-chaining-analysis]], [[composition-two-axes]]
> 원문: `_docs/goalArchitecture/pdp-restructure/hdl.md`
