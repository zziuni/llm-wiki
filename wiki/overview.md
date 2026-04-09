---
type: overview
summary: "위키 전체를 관통하는 합성 요약 — 소스 축적에 따라 진화"
created: 2026-04-09
updated: 2026-04-09
status: active
---

# Overview

이 위키는 아직 초기 단계입니다. 소스가 수집되면 이 페이지에 전체 지식의 합성 요약이 작성됩니다.

## 현재 상태
- 소스: 4건
- 개념 페이지: 4건
- 엔티티 페이지: 1건

## 주요 테마

### 개발 도구 진화
Git의 merge 전략이 resolve → recursive → ort로 진화하고([[concepts/git-merge-strategies]]), 프론트엔드 린팅/포매팅 도구가 JavaScript 기반(ESLint+Prettier)에서 Rust 기반([[biome]], [[oxfmt]])으로 전환되는 흐름. 공통점은 **성능 병목이 도구 교체의 주된 동기**라는 것. 포매터 영역에서는 [[biome]](통합)과 [[oxfmt]](전용)의 경쟁 구도가 형성 중.

### 모노레포 환경의 도전
대규모 모노레포에서 패키지 수 증가에 따른 도구 성능 저하가 개발자 경험에 직접적 영향을 미침. [[monorepo-dx|모노레포 DX]] 문서에서 병목 패턴과 해결 전략 정리.

## 핵심 발견

- Rust 기반 도구 전환은 극적인 성능 개선을 가져옴: 에디터 저장 **189배**, CI **2.9배** 속도 향상 ([[sources/biome-migration-report]])
- Git도 성능 문제로 merge 전략을 교체함: ort는 recursive 대비 대규모 rename 시 **500배 이상** 빠름 ([[sources/git-merge-strategy-ort]])
- 포매터 성능 경쟁: [[oxfmt]]는 Prettier 대비 ~30배, [[biome]] 대비 ~2배 빠르지만, 린터 미포함으로 포지셔닝이 다름
