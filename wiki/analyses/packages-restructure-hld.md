---
title: "Packages 구조 재편 HLD 분석"
type: analysis
created: 2026-04-09
updated: 2026-04-10
tags: [architecture, packages, barrel-index, migration, monorepo]
related: ["[[codebase-improvement-roadmap]]"]
---

# Packages 구조 재편 HLD 분석

packages/ 디렉토리(135개 패키지, 1,062개 barrel index)의 구조적 부채를 해소하기 위한 HLD 설계 과정에서 도출된 핵심 분석과 의사결정 기록.

## 1. 단일 앱 전용 패키지 전수 검증

### 기존 분석의 오류

packages-digest.md에서 21개를 "단일 앱 전용"으로 분류했으나, **package.json 의존성만 보고 cross-package 의존성을 검증하지 않았다.**

### 전수 조사 결과: 21개 → 5개

실제로 다른 packages/ 하위 패키지가 의존하지 않는 진짜 단일 앱 전용은 5개뿐:

- features-card-game (home), features-display-ad (home), features-navigation (home), features-space (home)
- contexts-membership (mypage)

**대표적 오분류 사례:**
- `apis-auth`: auth 전용으로 분류되었으나 실제로는 auth, mypage, order, product 4개 앱 + 4개 패키지에서 사용
- `contexts-feature-flags`: product 전용으로 분류되었으나 6개 앱 + 9개 패키지에서 사용
- `hooks-storage`: shop 전용으로 분류되었으나 7개 feature/context 패키지가 의존

**교훈:** "앱 package.json에서 1개만 참조"와 "다른 packages가 의존하지 않음"은 다른 조건. 전자만 보면 오분류됨.

## 2. Barrel Index 코드 분석 — 5가지 평면화 기준

depth 5+ barrel 782개를 분석하여 4가지 유형을 발견:

| 유형 | 비율 | 특징 |
|------|------|------|
| pass-through | 83.5% (653개) | `export * from './X'` 한 줄만 있는 순수 재수출 |
| selective | 15.3% (120개) | 단일 named export (컴포넌트 폴더 패턴) |
| component | 1.2% (9개) | React 컴포넌트 직접 정의 |

95%가 "chain-only" — 소비자가 부모 barrel 1개뿐이고 외부에서 직접 import하는 소비자가 없음.

### 도출된 5가지 판단 기준

1. **pass-through 삭제**: `export * from './X'`만 있는 barrel → 부모에서 직접 참조로 변경
2. **단일 컴포넌트 폴더**: 폴더 내 파일 수에 따라 폴더 해체(1개) / barrel만 삭제(2~3개) / 유지(4개+)
3. **compound component 통합**: 부모-자식 단방향 소비 관계 → flat 파일로 통합 (예: TasteSwiperModule 4단계 체인)
4. **도메인 형제 통합**: 같은 도메인의 형제 barrel → 부모에 귀속 (예: product-price-section 하위 4개)
5. **API 스키마/enum**: 진입점에 export 추가 → 소비자 변경 → 내부 barrel 삭제 (119건 deep import 해소)

**적용 순서:** 기준 5(deep import 해소) → 기준 1(pass-through) → 기준 2~4(잔여 정리)

### 실제 사례: features/display depth 17 체인

```
modules/TasteSwiperModule/TasteSwiper/TasteItem/ProgressBar/
```
각 단계에 barrel index가 존재하지만, ProgressBar→TasteItem→TasteSwiper→TasteSwiperModule 순 단방향 소비. 외부에서는 TasteSwiperModule만 import. → 기준 3 적용으로 barrel 4개 삭제.

## 3. HLD 핵심 설계 결정

### domain-service 독립 분리 (D1)

기존 HLD에서 services/를 infra/에 합쳤으나, 이는 [[codebase-improvement-roadmap]]의 핵심 문제인 "Features→APIs 직접 호출 331건"을 구조적으로 허용하게 됨.

**결정:** 6개 카테고리로 재편 — ui-component, **domain-service**, api, infra, helper, shared

**계층 규칙:**
```
apps → ui-component → domain-service → api + infra → helper + shared
```

### Barrel 평면화 최우선 (D5)

기존 Phase 순서: Quick Wins → 단일앱 이동 → Barrel 정리
**변경:** Quick Wins → **Barrel 평면화** → 분류 체계 적용 → Legacy

**근거:** 단일앱 이동이 21→5개로 축소되어 우선순위가 떨어지고, 1,062개 barrel이 모든 후속 작업의 복잡도를 결정하므로 먼저 정리해야 분류 체계 적용이 깔끔.

## 4. 수정된 수치

| 항목 | 기존 | 수정 |
|------|------|------|
| 독립 패키지 수 | 122 | **135** |
| barrel index 수 | 996 | **1,062** |
| 단일앱 전용 패키지 | 21 | **5** |
| legacy-sdui 참조 | 0건 | **3건** (admins/brand) |
| legacy-environments 의존 | 11개 | **10개** |

---

> 원본 문서: `_docs/goalArchitecture/packages-restructure/` (digest, HLD, migration-plan)
