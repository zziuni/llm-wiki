# GitHub Actions Reusable Workflow — 공식 문서 요약

> 수집일: 2026-04-10
> 소스: https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows
> 소스: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions

## Reusable Workflow 개념

- **Called Workflow**: `on: workflow_call` 트리거를 가진 워크플로우. 다른 워크플로우에 의해 호출됨
- **Caller Workflow**: Called workflow를 `uses:`로 호출하는 워크플로우
- Caller 하나가 여러 Called workflow를 호출 가능
- Called workflow는 job 내부가 아닌, job 수준에서 참조됨

## Called Workflow 작성 (workflow_call)

```yaml
on:
  workflow_call:
    inputs:
      config-path:
        required: true
        type: string  # string, boolean, number 지원
    secrets:
      token:
        required: true
    outputs:
      result:
        description: "결과 값"
        value: ${{ jobs.example.outputs.output1 }}

jobs:
  example:
    runs-on: ubuntu-latest
    outputs:
      output1: ${{ steps.step1.outputs.firstword }}
    steps:
      - id: step1
        run: echo "firstword=hello" >> $GITHUB_OUTPUT
```

## Caller Workflow에서 호출

```yaml
jobs:
  call-workflow:
    uses: octo-org/example-repo/.github/workflows/workflow-B.yml@main
    with:
      config-path: .github/labeler.yml
    secrets:
      token: ${{ secrets.GITHUB_TOKEN }}
```

### 호출 경로 형식
- 다른 저장소: `{owner}/{repo}/.github/workflows/{filename}@{ref}`
- 같은 저장소: `./.github/workflows/{filename}`
- ref는 commit SHA 권장 (안정성), tag > branch 우선순위

### Secrets 전달 방식
1. **명시적**: `secrets: { token: ${{ secrets.TOKEN }} }`
2. **상속**: `secrets: inherit` — 조직/엔터프라이즈 내 모든 secrets 자동 전달

## 제한사항

| 항목 | 제한 |
|------|------|
| 중첩 깊이 | 최대 10레벨 |
| 고유 워크플로우 | 단일 파일에서 최대 50개 |
| 권한 | 유지 또는 축소만 가능, 상승 불가 |
| 순환 참조 | 불허 |
| environment secrets | workflow_call에서 미지원 |
| Context/Expression | `jobs.<id>.uses`에서 불허 |
| 서브디렉토리 | `.github/workflows` 하위 디렉토리 미지원 |
| private repo | 같은 레포 내에서만 호출 가능 |

## Workflow YAML 핵심 구문

### 트리거 (on:)

```yaml
# 단일/다중 이벤트
on: push
on: [push, pull_request]

# Activity types
on:
  pull_request:
    types: [opened, synchronize, edited, closed]

# 브랜치/경로 필터
on:
  push:
    branches: [main, 'release/**']
    paths: ['**.js']
```

### Jobs 구조

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    needs: [lint, test]  # 선행 작업
    if: github.event_name == 'push'
    timeout-minutes: 30
    permissions:
      contents: read
      pull-requests: write
```

### Matrix 전략과 결합

```yaml
jobs:
  deploy:
    strategy:
      matrix:
        target: [dev, stage, prod]
    uses: org/repo/.github/workflows/deploy.yml@main
    with:
      target: ${{ matrix.target }}
```
