---
type: source
summary: "무신사 코어 파트너프론트엔드 모노레포의 ESLint+Prettier → Biome 마이그레이션 결과 보고서. 에디터 저장 189배, CI 2.9배 속도 개선"
tags:
  - biome
  - eslint
  - prettier
  - monorepo
  - dx
  - migration
sources:
  - "Migrate to Biome Report (코어 파트너프론트엔드 Confluence)"
created: 2026-04-09
updated: 2026-04-09
status: active
---

# Biome 마이그레이션 리포트

무신사 코어 파트너프론트엔드 팀이 31개 패키지 모노레포에서 ESLint(v8) + Prettier를 [[biome]]으로 전환한 보고서.

## 배경

모노레포 규모가 커지면서 기존 ESLint + Prettier 체제에 세 가지 문제 발생:

1. **에디터 저장 지연**: VS Code에서 파일 저장 시 ESLint + Prettier 두 도구 실행으로 **30초 이상** 소요. config resolution과 파일 탐색 비용이 파일 수에 비례 증가
2. **CI OOM**: 셀프호스트 GitHub Actions 러너(4GB)에서 ESLint 실행 시 Out of Memory 발생. Node.js 힙 메모리 사용이 워크스페이스 수에 비례 증가
3. **설정 파편화**: `.eslintrc.json` + `.prettierrc` + `.lintstagedrc` 별도 관리로 규칙 충돌/중복 발생

## 정량적 성과

### 에디터 Format on Save (Macbook M3 Pro, 36GB)

| 항목 | ESLint + Prettier | Biome | 개선 |
|---|---|---|---|
| 단일 파일 | 15.5s | 82ms | **189x** |

### CI (4,407 파일)

| 항목 | ESLint + Prettier | Biome | 개선 |
|---|---|---|---|
| 전체 린트 | 235s (약 4분) | 81s (약 1분 21초) | **2.9x** |

### 누적 효과

- PR 1회당 154초 단축
- 하루 평균 19 PR 기준 → **하루 49분, 연간 205시간** CI 대기 시간 절감

## 핵심 인용

> **"One toolchain for your web project"** — Format, lint, and more in a fraction of a second.

> 이번 Biome 마이그레이션은 단순한 도구 교체를 넘어, **개발 환경의 근본적인 구조 개선**이었습니다.

## 발견한 개념

- [[biome]] — Rust 기반 통합 린터/포매터
- [[monorepo-dx]] — 모노레포 환경의 개발자 경험

## 원본

- Confluence: [Migrate to Biome Report](https://wiki.team.musinsa.com/wiki/spaces/CPF/pages/332333858/Migrate+to+Biome+Report)
- 관련 가이드: [Biome 마이그레이션 가이드](https://wiki.team.musinsa.com/wiki/spaces/CPF/pages/333316352)
