---
title: "Migrate to Biome Report - 코어 파트너프론트엔드 - Confluence"
source: "https://wiki.team.musinsa.com/wiki/spaces/CPF/pages/332333858/Migrate+to+Biome+Report"
author:
published:
created: 2026-04-09
description:
tags:
  - "clippings"
---
## Migrate to Biome Report

## 1\. 배경 및 문제상황

모노레포(31개의 패키지)에서 Prettier, ESLint 기반으로 린트, 포맷팅 운영중 아래와 같은 문제가 발생했습니다.

### 1-1. 에디터 저장(File on Save) 30s 이상 소요

- VS Code에서 파일 저장 시 ESLint, Prettier 두 가지 도구가 실행
- 대규모 모노레포 환경에서 ESLint의 config resolution과 파일 탐색 비용이 파일 수에 비례하여 증가
- 개발자 체감 DX가 심각하게 저하되어 생산성에 직접적 영향

### 1-2. Github Action Runner OOM

- 셀프호스트 GitHub Actions 러너 기본 환경(Memory 4GB)에서 ESLint 실행 시 OOM(Out of Memory) 발생
- ESLint(v8)는 JavaScript 기반으로 Node.js 힙 메모리를 사용하며, 워크스페이스 수 증가에 따라 메모리 사용량이 선형적으로 증가

### 1-3. Format 설정 파편화

- Prettier, ESLint의 설정 파일을 별도로 관리하여, 규칙 충돌이나 중복 설정이 발생

### 1-4. AI 도구의 혼란

- Cursor, Claude Code 등 AI 코드 생성 도구가 ESLint 규칙과 Prettier 규칙을 동시에 파악하기 어려움
- 두 가지 다른 설정 파일을 참조해야 하므로 AI가 생성한 코드의 일관성 저하

## 2\. 해결 방안: Biome

> **“One toolchain for your web project”** — Format, lint, and more in a fraction of a second.

- Biome 공식문서: [Philosophy](https://biomejs.dev/internals/philosophy/)

### 2-1. 선택근거

<table><colgroup><col> <col> <col></colgroup><tbody><tr><th rowspan="1" colspan="1"><div><p><strong>비교 항목</strong></p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p><strong>ESLint(v8) + Prettier</strong></p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p><strong>Biome</strong></p><figure></figure></div></th></tr></tbody></table>

<table><colgroup><col> <col> <col></colgroup><tbody><tr><th rowspan="1" colspan="1"><div><p><strong>비교 항목</strong></p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p><strong>ESLint(v8) + Prettier</strong></p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p><strong>Biome</strong></p><figure></figure></div></th></tr><tr><td rowspan="1" colspan="1"><p>언어</p></td><td rowspan="1" colspan="1"><p>JavaScript (Node.js)</p></td><td rowspan="1" colspan="1"><p>Rust (네이티브 바이너리)</p></td></tr><tr><td rowspan="1" colspan="1"><p>도구 수</p></td><td rowspan="1" colspan="1"><p>2개 (린터 + 포매터)</p></td><td rowspan="1" colspan="1"><p>1개 (통합)</p></td></tr><tr><td rowspan="1" colspan="1"><p>설정 파일</p></td><td rowspan="1" colspan="1"><p>.eslintrc.json +.prettierrc +.lintstagedrc</p></td><td rowspan="1" colspan="1"><p>biome.json 단일</p></td></tr><tr><td rowspan="1" colspan="1"><p>메모리 사용</p></td><td rowspan="1" colspan="1"><p>Node.js 힙 (수백MB~GB)</p></td><td rowspan="1" colspan="1"><p>네이티브 메모리 (수십MB)</p></td></tr><tr><td rowspan="1" colspan="1"><p>내장 규칙</p></td><td rowspan="1" colspan="1"><p>플러그인 조합 필요</p></td><td rowspan="1" colspan="1"><p>464개 내장 (ESLint 97% 호환)</p></td></tr><tr><td rowspan="1" colspan="1"><p>포맷팅 호환성</p></td><td rowspan="1" colspan="1"><p>Prettier 기준</p></td><td rowspan="1" colspan="1"><p>Prettier 97% 호환</p></td></tr><tr><td rowspan="1" colspan="1"><p>벤치마크 (공식)</p></td><td rowspan="1" colspan="1"><p>기준</p></td><td rowspan="1" colspan="1"><p>Prettier 대비 ~35x 빠름</p></td></tr></tbody></table>

## 3\. 정량적 비교

### 3-1. CI

최근 7일간의 [CI Metrics](https://github.com/musinsa/core-partner-frontend/actions/workflows/01.ci.yml "https://github.com/musinsa/core-partner-frontend/actions/workflows/01.ci.yml") 를 기반으로 비교.

<table><tbody><tr><th rowspan="1" colspan="1"><div><p><strong>스코프</strong></p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p><strong>Before (ESLint + Prettier)</strong></p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p><strong>After (Biome)</strong></p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p><strong>Improvement</strong></p><figure></figure></div></th></tr></tbody></table>

<table><tbody><tr><th rowspan="1" colspan="1"><div><p><strong>스코프</strong></p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p><strong>Before (ESLint + Prettier)</strong></p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p><strong>After (Biome)</strong></p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p><strong>Improvement</strong></p><figure></figure></div></th></tr><tr><td rowspan="1" colspan="1"><p>전체 파일 (4,407개)</p></td><td rowspan="1" colspan="1"><p>235s (약 4분)</p></td><td rowspan="1" colspan="1"><p>81s (약 1분 21초)</p></td><td rowspan="1" colspan="1"><p><strong>2.9x</strong></p></td></tr></tbody></table>

### 3-2. 에디터 Format on save

Macbook M3 Pro, 36GB 기준으로 측정.

<table><tbody><tr><th rowspan="1" colspan="1"><div><p><strong>스코프</strong></p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p><strong>AS-IS (ESLint, Prettier)</strong></p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p><strong>TO-BE (Biome)</strong></p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p><strong>Improvement</strong></p><figure></figure></div></th></tr></tbody></table>

<table><tbody><tr><th rowspan="1" colspan="1"><div><p><strong>스코프</strong></p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p><strong>AS-IS (ESLint, Prettier)</strong></p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p><strong>TO-BE (Biome)</strong></p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p><strong>Improvement</strong></p><figure></figure></div></th></tr><tr><td rowspan="1" colspan="1"><p>단일 파일</p></td><td rowspan="1" colspan="1"><p>15.5s</p></td><td rowspan="1" colspan="1"><p>82ms</p></td><td rowspan="1" colspan="1"><p><strong>189x</strong></p></td></tr></tbody></table>

## 4\. 정성적 비교

### 4-1. 개발자 경험(DX) 개선

- **즉각적인 피드백**: 파일 저장시 즉각적 확인
- **단일 명령어**: `pnpm check` 하나로 lint + format 동시 실행 (이전: `pnpm lint` + `pnpm format` 별도)

### 4-2. CI/CD 안정성

- ESLint 기반 OOM 리스크 제거
- CI 파이프라인 병목 해소

### 4-3. 유지보수 비용 절감

- `@musinsa/eslint-config` 제거
- Prettier와 ESLint 간 규칙 충돌 디버깅 불필요
- 새 워크스페이스 추가 시 `biome.json` 에 `extends` 한 줄 추가로 설정 완료

### 4-4. AI 도구 일관성 확보

- AI 코드 생성 도구가 단일 설정 파일(`biome.json`)만 참조하면 되므로 AI 코드 생성 도구의 포맷팅 정확도 향상

## 5\. 마이그레이션 이후 이슈

[Biome 마이그레이션 가이드](https://wiki.team.musinsa.com/wiki/spaces/CPF/pages/333316352) 에 기록했습니다.

## 6\. 마무리

이번 Biome 마이그레이션은 단순한 도구 교체를 넘어, **개발 환경의 근본적인 구조 개선** 이었습니다.

에디터 저장 시간 189배 단축, OOM 리스크 완전 제거 외에도, CI 파이프라인은 PR 1회당 154초가 단축되었습니다. 레포 평균 하루 19개의 PR이 올라오는 것을 감안하면, **하루 약 49분, 연간 약 205시간의 CI 대기 시간이 사라진 셈** 입니다.

정량적 성과 외에도, 이번 마이그레이션이 갖는 중요한 의미 중 하나는 **AI 보조 개발 환경과의 정합성 확보** 입니다. Cursor, Claude Code 등 AI 코드 생성 도구는 이제 프론트엔드 개발 워크플로우에서 사실상 표준 도구로 자리잡고 있습니다. 기존의 ESLint + Prettier 구조에서는 AI 도구가 두 개의 분리된 설정 파일을 동시에 파악해야 했고, 규칙 충돌이 있는 영역에서는 AI가 생성한 코드가 일관성을 잃는 문제가 빈번하게 발생했습니다. 이는 AI가 제안한 코드를 그대로 사용하지 못하고 수동으로 수정해야 하는 비용으로 직결되었습니다.

`biome.json` 단일 설정 파일로 통합됨으로써, AI 도구는 하나의 Source of truth를 기준으로 일관된 코드를 생성할 수 있게 되었습니다. 코드 스타일 관련 AI 제안의 신뢰도가 높아지고, 리뷰 과정에서 불필요한 포맷 수정 코멘트도 줄어드는 효과를 기대할 수 있습니다.

AI 도구 활용이 더욱 확대될수록, **toolchain의 단순함과 명확함이 AI 협업의 품질을 결정하는 핵심 인프라** 가 됩니다. 이번 마이그레이션은 그 기반을 마련했다는 점에서, 단기 성능 개선 이상의 장기적 가치를 가집니다.

진행한 작업을 바탕으로 [Biome 마이그레이션 가이드](https://wiki.team.musinsa.com/wiki/spaces/CPF/pages/333316352) 를 작성했습니다. 마이그레이션을 하시고자 하는 분이 있다면 참고해주세요. 또한 마이그레이션에 어려움이 있다면 편하게 도움을 요청해주세요.

Related content