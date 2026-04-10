---
type: analysis
summary: "5개 워크스트림(아키텍처/코드품질/구조경량화/플랫폼현대화/AI Harness) × 4단계 타임라인, 추가 식별 과제 10건"
tags:
  - roadmap
  - architecture
  - codebase-optimization
  - planning
created: 2026-04-10
updated: 2026-04-10
status: active
---

# 코드베이스 개선 로드맵 구조

## 개요

6개 문서(mental-model, good-pattern, anti-pattern, problem-analysis, harness-eng, codebase-optimization)를 종합하여 코드베이스 개선 로드맵을 수립함.

## 5개 워크스트림

| WS | 이름 | 핵심 목표 | 근거 문서 |
|----|------|----------|-----------|
| A | 아키텍처 정합성 | 레이어 위반 840건 → 0건 | mental-model 원칙 1,5,6 |
| B | 코드 품질 체계화 | eslint-disable 985건, 에러 처리 22%→90% | guidelines 1,2,3 |
| C | 구조 경량화 | packages 135→~101개, barrel depth 10→3 | guidelines 3,4 |
| D | 플랫폼 현대화 | Node/TS 업그레이드, Emotion 제거 | problem-analysis |
| E | AI Harness | 팀 공통 플러그인, 전 레포 적용 | harness-eng |

## 4단계 타임라인

- **Phase 0** (4월): 진행중 과제 완료 (Node/TS 업그레이드, Storage 통합)
- **Phase 1** (5월): 린트로 신규 유입 차단 + Quick Wins
- **Phase 2** (6-7월): 아키텍처 위반 집중 제거 + barrel 평면화
- **Phase 3** (8-9월): 대규모 legacy 정리 + 전 레포 확산
- **Phase 4** (Q4~): Emotion 제거, App Router 전환

## 추가 식별 과제 10건

codebase-optimization에 없던 과제를 문서 분석에서 추출:
- NEW-01~02: 레이어 위반 제거 (Features→APIs 331건, Apps→APIs 509건)
- NEW-03: ACL 프로퍼티명 경계 (347건)
- NEW-04: eslint-disable 제거 (985건)
- NEW-05: 에러 처리 체계화 (~22%)
- NEW-06: God Component 분해 (8건)
- NEW-07: 중복 유틸 통합
- NEW-08: Barrel 평면화
- NEW-09: any 타입 제거 (204건)
- NEW-10: Emotion 마이그레이션 재개

## 핵심 의존성 체인

```
B-7(Query 어댑터) → A-1(Features→APIs) → A-2(Apps→APIs) → A-5(Legacy API)
C-1 → C-2 → C-3 → C-4 → C-5 (packages 순차)
D-3(Ruler 린트) → D-4(Emotion 마이그레이션)
```

## 상세 문서 위치

`_docs/goalArchitecture/codebase-improvement-roadmap.md`

## Related

- [[composition-two-axes]] — Composition의 두 축 개념
- [[hook-chaining-analysis]] — God Hook 현황 분석
- [[pdp-problem-analysis]] — PDP 현황 분석
- [[pdp-restructure-hld]] — PDP 분리 HLD
