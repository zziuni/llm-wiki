---
title: "Biome 마이그레이션 가이드 - 코어 파트너프론트엔드 - Confluence"
source: "https://wiki.team.musinsa.com/wiki/spaces/CPF/pages/333316352/Biome"
author:
published:
created: 2026-04-09
description:
tags:
  - "clippings"
---
## Biome 마이그레이션 가이드

> Biome 공식 마이그레이션 문서: [Migrate from ESLint and Prettier](https://biomejs.dev/guides/migrate-eslint-prettier/)

## Step 1: Biome 설치 및 자동 마이그레이션

### 1-1. Biome 설치

```shell
pnpm add -D --save-exact @biomejs/biome@2.4.4
```

### 1-2. 기존 설정 자동 변환

Biome CLI가 ESLint/Prettier 설정을 `biome.json` 으로 자동 변환합니다.

```shell
# ESLint 설정 변환

pnpx @biomejs/biome migrate eslint --write

# Prettier 설정 변환

pnpx @biomejs/biome migrate prettier --write
```

주요 매핑:

<table><tbody><tr><th rowspan="1" colspan="1"><div><p>Prettier 옵션</p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p>Biome 옵션</p><figure></figure></div></th></tr></tbody></table>

<table><tbody><tr><th rowspan="1" colspan="1"><div><p>Prettier 옵션</p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p>Biome 옵션</p><figure></figure></div></th></tr><tr><td rowspan="1" colspan="1"><p><code>useTabs</code></p></td><td rowspan="1" colspan="1"><p><code>formatter.indentStyle: "tab"</code></p></td></tr><tr><td rowspan="1" colspan="1"><p><code>tabWidth</code></p></td><td rowspan="1" colspan="1"><p><code>formatter.indentWidth</code></p></td></tr><tr><td rowspan="1" colspan="1"><p><code>singleQuote</code></p></td><td rowspan="1" colspan="1"><p><code>javascript.formatter.quoteStyle: "single"</code></p></td></tr><tr><td rowspan="1" colspan="1"><p><code>trailingComma</code></p></td><td rowspan="1" colspan="1"><p><code>javascript.formatter.trailingCommas</code></p></td></tr><tr><td rowspan="1" colspan="1"><p><code>semi</code></p></td><td rowspan="1" colspan="1"><p><code>javascript.formatter.semicolons</code></p></td></tr></tbody></table>

> **주의**: YAML 형식의 ESLint 설정은 미지원입니다. `.eslintrc.json` (레거시)과 `eslint.config.js` (flat config)는 모두 지원합니다.

### 1-3. 전체 코드 포맷팅 일괄 변환

```shell
npx biome check --write .
```

대부분의 파일이 변경됩니다. `git blame` 오염을 방지하려면:

```shell
echo "# Biome migration formatting" >> .git-blame-ignore-revs

echo "<commit-hash>" >> .git-blame-ignore-revs

git config blame.ignoreRevsFile .git-blame-ignore-revs
```

---

## Step 2: 모노레포 설정 구조 설계

> 단일 레포라면 이 단계를 건너뛰고 Step 3으로 진행하세요.
> 
> (`@musinsa/biome-config` 는 레포내에서 사용했던 패키지 명입니다. 패키지 export가 필요하신 경우 문의해주세요.)

### 2-1. root 설정

모노레포에서 Biome의 설정 탐색 경계를 올바르게 설정하는 것이 핵심입니다.

**모노레포 루트** `biome.json`:

```json
{

  "root": true

}
```

**각 워크스페이스** `biome.json`:

```json
{

  "root": false,

  "extends": ["@musinsa/biome-config/react"]

}
```

<table><tbody><tr><th rowspan="1" colspan="1"><div><p>옵션</p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p>위치</p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p>역할</p><figure></figure></div></th></tr></tbody></table>

<table><tbody><tr><th rowspan="1" colspan="1"><div><p>옵션</p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p>위치</p><figure></figure></div></th><th rowspan="1" colspan="1"><div><p>역할</p><figure></figure></div></th></tr><tr><td rowspan="1" colspan="1"><p><code>"root": true</code></p></td><td rowspan="1" colspan="1"><p>모노레포 루트</p></td><td rowspan="1" colspan="1"><p>설정 탐색 최상위 경계. Biome가 이 위로 올라가지 않음</p></td></tr><tr><td rowspan="1" colspan="1"><p><code>"root": false</code></p></td><td rowspan="1" colspan="1"><p>각 워크스페이스</p></td><td rowspan="1" colspan="1"><p>이 파일 설정을 우선 적용하고, 상위 루트 설정을 fallback으로 상속</p></td></tr></tbody></table>

### 2-2. 공유 설정 패키지 생성

프로젝트 유형별로 설정을 분리합니다.

```
packages/biome-config/

├── base.json     # TS/JS 공통

├── react.json    # React 프로젝트

├── nextjs.json   # Next.js 앱

└── package.json
```

```json
// packages/biome-config/package.json

{

  "name": "@musinsa/biome-config",

  "exports": {

    "./base": "./base.json",

    "./react": "./react.json",

    "./nextjs": "./nextjs.json"

  },

  "peerDependencies": {

    "@biomejs/biome": "^2.4.4"

  }

}
```

### 2-3. extends 1-depth 제한 주의

Biome의 `extends` 는 **1-depth만 지원** 합니다.

```
❌ nextjs.json extends react.json extends base.json  → base 설정 누락

✅ 각 파일이 모든 규칙을 독립적으로 포함 (flat 구조)
```

`base.json`, `react.json`, `nextjs.json` 각각이 필요한 모든 규칙을 직접 포함해야 합니다.

### 2-4. 워크스페이스에 배포

```json
// layers/apis/curator/biome.json

{

  "root": false,

  "extends": ["@musinsa/biome-config/base"]

}
```

```json
// layers/features/curator/biome.json

{

  "root": false,

  "extends": ["@musinsa/biome-config/react"]

}
```

```json
// layers/apps/curator/biome.json

{

  "root": false,

  "extends": ["@musinsa/biome-config/nextjs"]

}
```

워크스페이스별 오버라이드가 필요하면 `extends` 아래에 추가합니다:

```json
{

  "root": false,

  "extends": ["@musinsa/biome-config/react"],

  "linter": {

    "rules": {

      "suspicious": {

        "noExplicitAny": "off"

      }

    }

  }

}
```

---

## Step 3: CI 파이프라인 전환

### 3-1. Turbo 태스크 변경

```
// turbo.json

{

  "tasks": {

-   "lint": {

-     "dependsOn": ["^lint"],

+   "check": {

+     "dependsOn": ["^check"],

      "inputs": ["$TURBO_DEFAULT$"],

      "outputs": []

    }

  }

}
```

### 3-2. package.json 스크립트 변경

```
{

  "scripts": {

-   "lint": "eslint . --ext .ts,.tsx",

-   "lint:fix": "eslint . --ext .ts,.tsx --fix",

-   "format": "prettier --check \"**/*.{ts,tsx}\"",

-   "format:write": "prettier --write \"**/*.{ts,tsx}\"",

+   "check": "biome check",

+   "check:fix": "biome check --write",

+   "lint": "biome lint",

+   "lint:fix": "biome lint --write",

+   "format": "biome format",

+   "format:write": "biome format --write"

  }

}
```

### 3-3. GitHub Actions 수정

```
- - name: Lint

-   run: pnpm lint

- - name: Format check

-   run: pnpm format

+ - name: Check code quality (lint + format)

+   run: pnpm check
```

---

## Step 4: 레거시 도구 정리

### 4-1. lint-staged 제거

```shell
rm .lintstagedrc

pnpm remove lint-staged
```

`.husky/pre-commit` 업데이트:

```
- pnpm lint-staged

+ pnpm check
```

### 4-2. ESLint 의존성 제거

```shell
# 각 워크스페이스에서

pnpm remove @musinsa/eslint-config eslint
```

### 4-3. 설정 파일 삭제

```shell
# ESLint 설정 파일 일괄 삭제

find . -name ".eslintrc*" -not -path "*/node_modules/*" -delete

# ESLint ignore 파일 삭제

rm .eslintignore

# 공유 ESLint 설정 패키지 제거 (모노레포)

rm -rf packages/eslint-config/
```

### 4-4. lockfile 정리

```shell
pnpm install
```

---

## Step 5: 규칙 튜닝 및 코드 수정

### 5-1. Group-Level Severity

개별 규칙을 나열하는 대신, 그룹 단위로 설정합니다.

```json
{

  "linter": {

    "rules": {

      "a11y": "warn"

    }

  }

}
```

이 한 줄로 37개의 a11y 규칙이 모두 `warn` 으로 설정됩니다.

### 5-2. Biome가 발견한 코드 이슈 수정

ESLint에서 잡지 못했던 이슈를 Biome가 발견하는 경우가 있습니다.

```
// React Rules of Hooks 위반

- const [count, setCount] = isEnabled ? useState(0) : [0, () => {}];

+ const [count, setCount] = useState(0);
```

```
// Optional Chaining 누락 (잠재 런타임 에러)

- availableMonthsData.map(...)

+ availableMonthsData?.map(...)
```

### 5-3..biomeignore 설정

```
# .biomeignore

node_modules

dist

.next

*.generated.ts
```

> `.gitignore` 에 등록된 경로는 자동으로 제외됩니다. `.biomeignore` 에는 git에는 포함되지만 Biome에서는 제외할 파일만 추가하면 됩니다.

## Step 6: 에디터 환경 구성

[Biome 사용자 가이드](https://wiki.team.musinsa.com/wiki/spaces/CPF/pages/333316345) 참고

---

## Trouble Shooting

- `useExhaustiveDependencies` ([설명](https://biomejs.dev/linter/rules/use-exhaustive-dependencies/ "https://biomejs.dev/linter/rules/use-exhaustive-dependencies/")) 설정으로 인해 dependecy array 가 자동으로 수정되는 경우를 확인해야합니다. (수정한 PR: )
- package extends 중첩 반영이 안되는 이슈([🐛 cannot extend configurations that extend other configurations (2+ nesting)closed](https://github.com/biomejs/biome/issues/1867#issuecomment-1953600042))가 있습니다. 설정파일은 Flat하게 만들어 extends 해야합니다.

Related content