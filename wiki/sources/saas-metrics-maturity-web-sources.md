---
type: source
summary: "SaaS 핵심 비즈니스 메트릭(MRR, LTV, CAC, Churn 등)과 성숙도 모델(Level 1~4) 웹 소스 종합"
tags:
  - saas
  - saas-metrics
  - maturity-model
  - business-model
sources:
  - "[[raw/saas-metrics-maturity-web-sources]]"
created: 2026-04-10
updated: 2026-04-10
status: active
---

# SaaS 메트릭 & 성숙도 모델 웹 소스 종합

## 소스 개요

| 소스 | 초점 | 수집일 |
|------|------|--------|
| Baremetrics — 15 KPIs Checklist | 15개 KPI 계산 공식·벤치마크 | 2026-04-10 |
| re:cap — 6 KPIs Founders Must Know | 투자자 관점 6대 KPI, 성장 단계별 우선순위 | 2026-04-10 |
| DiscoveringSaaS — Maturity Models | 4단계 성숙도, 레벨별 사례 | 2026-04-10 |
| Microsoft Learn — SaaS Maturity Model | Microsoft 2006년 원본 4단계 모델 | 2026-04-10 |

## 핵심 요약

### SaaS 비즈니스 메트릭 체계

메트릭은 크게 3영역으로 구분:

**1) 수익 메트릭**: MRR, ARR, ARPU, ACV, Expansion Revenue
**2) 획득 메트릭**: CAC, CAC Payback, LVR, 전환율
**3) 유지 메트릭**: Churn Rate, LTV, LTV:CAC, NRR/NDR, NPS

### 핵심 벤치마크

| 메트릭 | 건강한 기준 | 위험 신호 |
|--------|-----------|----------|
| LTV:CAC | ≥ 3:1 | < 1:1 |
| CAC Payback | < 12개월 | > 24개월 |
| 월간 Churn | < 5-7% | > 10% |
| NRR/NDR | > 100% | < 100% |
| 총수익 마진 | ≥ 75% | < 70% |
| Burn Multiple | < 2.0x | > 3.0x |
| Rule of 40 | 성장률+순이익률 ≥ 40% | < 40% |

### SaaS 성숙도 모델 (Microsoft, 2006)

| 레벨 | 멀티테넌시 | 확장성 | 구성 가능성 | 대표 사례 |
|------|-----------|--------|-----------|----------|
| L1 | 단일 테넌트 | 제한적 | 최소한 | 초기 스타트업 |
| L2 | 멀티테넌트 기초 | 향상 | 메타데이터 기반 | Dropbox |
| L3 | 최적화 멀티테넌트 | 분산 워크로드 | 고급 커스터마이징 | Salesforce |
| L4 | 완전 성숙 | 전사적 수준 | 완전 자동화 | Microsoft 365 |

> Level 4 도달 기업은 전체의 15-20%에 불과하다.

### 핵심 인용

> "NRR > 100%는 신규 고객 없이도 자체 성장 가능을 의미한다" — re:cap

> "LTV는 신규 고객 획득에 얼마를 쓸 수 있는지 결정한다" — Baremetrics

> "보유는 처음부터 주요 성장 동인이다" — ChartMogul 창업자
