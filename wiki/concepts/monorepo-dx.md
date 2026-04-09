---
type: concept
summary: "모노레포 환경에서의 개발자 경험(DX) — 패키지 수 증가에 따른 도구 성능 저하, OOM, 설정 파편화 문제와 해결 패턴"
tags:
  - monorepo
  - dx
  - ci
  - performance
sources:
  - "[[sources/biome-migration-report]]"
created: 2026-04-09
updated: 2026-04-09
status: active
---

# 모노레포 DX (Developer Experience)

모노레포(monorepo)에서 패키지 수와 파일 수가 증가하면 개발 도구의 성능이 비선형적으로 저하되는 현상. 에디터 반응 속도, CI 소요 시간, 메모리 사용량이 핵심 지표다.

## 주요 병목

### 에디터 성능

- 파일 저장 시 린터/포매터 실행 시간이 패키지 수에 비례 증가
- Node.js 기반 도구는 config resolution과 파일 탐색 비용이 특히 큼
- 실측: 31개 패키지 모노레포에서 ESLint+Prettier 기반 저장이 **15.5초** 소요 → 개발자 체감 DX 심각하게 저하

### CI/CD OOM

- JavaScript 기반 린터가 Node.js 힙 메모리를 과다 사용
- 워크스페이스 수 증가 시 메모리 사용량이 선형 증가 → 제한된 CI 러너 환경(4GB)에서 OOM 발생
- 러너 스펙 증가는 비용 문제로 한계

### 설정 파편화

- 린터 + 포매터 + lint-staged 등 도구별 설정 파일이 분리되면 규칙 충돌/중복 발생
- 새 패키지 추가 시 설정 복사/조정 비용

## 해결 패턴

| 패턴 | 설명 |
|---|---|
| **네이티브 도구 전환** | Node.js → Rust/Go 기반 도구로 교체. [[biome]], oxlint, swc 등 |
| **도구 통합** | 린터+포매터를 단일 도구로 합쳐 설정 파편화 해결 |
| **증분 실행** | 변경된 파일만 린트/빌드 (nx, turbo의 캐시 활용) |

## 실측 사례

[[sources/biome-migration-report|무신사 코어 파트너프론트엔드]] — [[biome]] 전환으로:

- 에디터 저장: 15.5s → 82ms (189x)
- CI: 235s → 81s (2.9x)
- 연간 CI 대기 시간 **205시간** 절감 (하루 19 PR 기준)

## 관련

- [[biome]] — 모노레포 DX 개선에 활용된 통합 도구
- [[sources/biome-migration-report]] — 실측 데이터 원본

## Flashcards
#flashcards

모노레포에서 Node.js 기반 린터의 주요 병목 2가지는?::1) 파일 수에 비례하는 config resolution 비용 증가 2) 워크스페이스 수에 비례하는 메모리(힙) 사용량 증가로 OOM 위험

모노레포 DX 개선의 핵심 해결 패턴 3가지는?::1) 네이티브 도구 전환(Rust/Go) 2) 도구 통합(린터+포매터) 3) 증분 실행(변경 파일만 처리)

무신사 모노레포에서 Biome 전환으로 연간 절감된 CI 대기 시간은?::약 205시간 (PR당 154초 × 하루 19 PR)
