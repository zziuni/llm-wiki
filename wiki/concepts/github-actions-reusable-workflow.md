---
type: concept
summary: "GitHub Actions에서 workflow_call로 중앙 워크플로우를 여러 레포에서 재사용하는 Caller-Called 패턴"
tags:
  - github-actions
  - ci-cd
  - devops
  - reusable-workflow
sources:
  - "[[sources/github-actions-reusable-workflow-docs]]"
  - "[[sources/harness-scoring-pr6445]]"
created: 2026-04-10
updated: 2026-04-10
status: active
---

# GitHub Actions Reusable Workflow

GitHub Actions의 **Reusable Workflow**는 하나의 워크플로우를 여러 레포에서 호출하여 재사용하는 패턴이다. DRY 원칙을 CI/CD 파이프라인에 적용한다.

## 핵심 개념: Caller와 Called

```
[Caller Workflow]                    [Called Workflow]
레포 A의 .github/workflows/ci.yml    중앙 레포의 .github/workflows/shared.yml
  └── jobs:                            └── on: workflow_call:
        uses: org/central/.../shared.yml@main       inputs: ...
        with: ...                                   secrets: ...
        secrets: inherit                            outputs: ...
```

- **Called Workflow**: `on: workflow_call` 트리거를 선언한 워크플로우. 다른 워크플로우에 의해 호출됨
- **Caller Workflow**: `uses:`로 Called workflow를 호출하는 워크플로우
- Called는 job 수준에서 참조됨 (step 수준이 아님)

## YAML 구조

### Called Workflow (중앙 레포)

```yaml
on:
  workflow_call:
    inputs:
      config-path:
        required: true
        type: string    # string | boolean | number
    secrets:
      token:
        required: true
    outputs:
      result:
        value: ${{ jobs.main.outputs.data }}

jobs:
  main:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "${{ inputs.config-path }}"
```

### Caller Workflow (각 레포)

```yaml
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  call-shared:
    uses: org/central-repo/.github/workflows/shared.yml@main
    with:
      config-path: .github/config.yml
    secrets: inherit    # 또는 명시적 전달
```

## 호출 경로 형식

| 형식 | 예시 |
|------|------|
| 다른 레포 | `{owner}/{repo}/.github/workflows/{file}@{ref}` |
| 같은 레포 | `./.github/workflows/{file}` |
| ref 권장순위 | commit SHA > tag > branch |

## Secrets 전달 방식

1. **명시적**: `secrets: { token: ${{ secrets.TOKEN }} }` — 필요한 것만 선택 전달
2. **상속**: `secrets: inherit` — 조직/레포의 모든 secrets 자동 전달. 간편하지만 최소권한 원칙과 상충

## 실전 패턴: Harness Scoring

[[harness-scoring-system]]에서 이 패턴을 활용한다:

```
[각 레포]
.github/workflows/harness-scoring.yml  ← Caller (14줄)
  └── uses: musinsa/harness-engineering-scoring-system/
            .github/workflows/harness-scoring-ingress.yml@main
      secrets: inherit

.harness/scoring.yml                   ← 레포별 설정 파일
.harness/pr-authoring.json             ← PR 작성 가이드 힌트
```

Caller는 단 14줄로, 실제 로직은 중앙의 Called workflow에 있다.

## 제한사항

| 항목 | 제한 |
|------|------|
| 중첩 깊이 | 최대 10레벨 |
| 고유 워크플로우 수 | 파일당 최대 50개 |
| 권한 | 유지/축소만 가능, 상승 불가 |
| private repo | 같은 레포 내에서만 호출 가능 |
| Expression | `jobs.<id>.uses`에서 사용 불가 |

## 관련 개념

- [[harness-scoring-system]] — Reusable workflow를 활용한 PR 품질 스코어링 시스템
- [[monorepo-dx]] — 모노레포에서의 CI/CD 파이프라인 설계

## Flashcards
#flashcards

GitHub Actions Reusable Workflow에서 Caller와 Called의 차이::Caller는 `uses:`로 호출하는 쪽, Called는 `on: workflow_call`을 선언하여 호출받는 쪽. Called는 job 수준에서 참조됨

Reusable Workflow의 secrets 전달 방식 2가지::1) 명시적 전달: `secrets: { token: ${{ secrets.TOKEN }} }` 2) 상속: `secrets: inherit`로 모든 secrets 자동 전달

GitHub Actions Reusable Workflow 호출 경로 형식::다른 레포: `{owner}/{repo}/.github/workflows/{file}@{ref}`, 같은 레포: `./.github/workflows/{file}`. ref는 ==commit SHA== > tag > branch 순 권장

Reusable Workflow의 중첩 깊이 제한::최대 ==10레벨==, 파일당 최대 50개 고유 워크플로우. 권한은 유지/축소만 가능
