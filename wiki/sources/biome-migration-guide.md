---
type: source
summary: "ESLint+Prettier → Biome 실전 마이그레이션 6단계 가이드. 자동 변환 CLI, 모노레포 설정 설계, CI 전환, 레거시 정리까지"
tags:
  - biome
  - eslint
  - prettier
  - migration
  - monorepo
sources:
  - "[[Biome 마이그레이션 가이드 - 코어 파트너프론트엔드 - Confluence]]"
created: 2026-04-09
updated: 2026-04-09
status: active
---

# Biome 마이그레이션 가이드

무신사 코어 파트너프론트엔드 팀의 ESLint+Prettier → [[biome]] 전환 실전 가이드. [[sources/biome-migration-report|마이그레이션 리포트]]의 실무 보완판.

## 6단계 절차

### Step 1: 설치 및 자동 변환

Biome CLI가 기존 설정을 자동 변환:

```bash
pnpx @biomejs/biome migrate eslint --write
pnpx @biomejs/biome migrate prettier --write
biome check --write .    # 전체 코드 포맷팅 일괄 변환
```

> git blame 오염 방지: `.git-blame-ignore-revs`에 마이그레이션 커밋 해시 등록

### Step 2: 모노레포 설정 구조

- 모노레포 루트: `"root": true` — 설정 탐색 최상위 경계
- 각 워크스페이스: `"root": false` + `"extends": ["@musinsa/biome-config/react"]`
- 공유 설정 패키지로 프로젝트 유형별 분리 (`base`, `react`, `nextjs`)

> [!warning] extends 1-depth 제한
> Biome의 `extends`는 1-depth만 지원. `nextjs → react → base` 체이닝 불가. 각 설정 파일이 모든 규칙을 독립 포함해야 함 (flat 구조).

### Step 3: CI 파이프라인

- `pnpm lint` + `pnpm format` → `pnpm check` 단일 명령으로 통합
- Turbo 태스크: `lint` → `check`로 변경

### Step 4: 레거시 정리

- `lint-staged`, `@musinsa/eslint-config`, `.eslintrc*`, `.eslintignore` 제거
- `.husky/pre-commit`을 `pnpm check`로 변경

### Step 5: 규칙 튜닝

- **Group-Level Severity**: `"a11y": "warn"` 한 줄로 37개 규칙 일괄 설정
- Biome가 ESLint 미탐지 이슈 발견: React Hooks 위반, Optional Chaining 누락 등

### Step 6: 에디터 설정

VS Code Biome 확장 설치 및 Format on Save 설정.

## 핵심 인용

> `.gitignore`에 등록된 경로는 자동으로 제외됩니다. `.biomeignore`에는 git에는 포함되지만 Biome에서는 제외할 파일만 추가하면 됩니다.

## Trouble Shooting

- `useExhaustiveDependencies` 설정으로 dependency array 자동 수정 주의
- extends 중첩 미지원 이슈 ([biomejs/biome#1867](https://github.com/biomejs/biome/issues/1867))

## 발견한 개념

- [[biome]] — 마이그레이션 대상 도구
- [[monorepo-dx]] — 모노레포 설정 구조 설계

## 원본

- Confluence: [Biome 마이그레이션 가이드](https://wiki.team.musinsa.com/wiki/spaces/CPF/pages/333316352)
