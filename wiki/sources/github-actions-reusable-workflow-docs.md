---
type: source
summary: "GitHub Actions Reusable Workflow 공식 문서 요약 — workflow_call, caller/called 패턴, YAML 구문"
tags:
  - github-actions
  - reusable-workflow
  - devops
sources:
  - "[[raw/github-actions-reusable-workflow-docs]]"
created: 2026-04-10
updated: 2026-04-10
status: active
---

# GitHub Actions Reusable Workflow 공식 문서

> 소스: [Reuse workflows - GitHub Docs](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows)
> 소스: [Workflow syntax - GitHub Docs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
> 수집일: 2026-04-10

## 핵심 요약

GitHub Actions Reusable Workflow는 `on: workflow_call` 트리거로 워크플로우를 다른 워크플로우에서 호출 가능하게 만드는 기능이다. Caller(호출측)와 Called(피호출측)로 구분되며, inputs/secrets/outputs를 통해 데이터를 주고받는다.

## 주요 인사이트

### 1. Caller-Called 분리
- Called workflow는 `on: workflow_call`을 선언하여 재사용 가능
- Caller는 `jobs.<id>.uses:`로 호출 (step이 아닌 job 수준)
- 호출 경로: `{owner}/{repo}/.github/workflows/{file}@{ref}`

### 2. 데이터 전달 3축
- **inputs**: `with:` 키워드로 전달. type은 string, boolean, number
- **secrets**: 명시적 전달 또는 `secrets: inherit`로 상속
- **outputs**: Called에서 정의, Caller에서 `needs.<job>.outputs.<name>`으로 참조

### 3. YAML 트리거 구문
- Activity types: `types: [opened, synchronize, edited, closed]`
- Branch/path 필터: `branches:`, `paths:`, `*-ignore` 변형
- 스케줄: POSIX cron 표현식 + timezone 지원

### 4. 제한사항
- 중첩 최대 10레벨, 파일당 50개 고유 워크플로우
- 권한은 유지/축소만 가능
- `uses:`에서 expression/context 사용 불가
- private repo는 같은 레포 내에서만 호출 가능

## 관련 위키 페이지

- [[github-actions-reusable-workflow]] — 개념 정리
- [[harness-scoring-system]] — 이 패턴의 실전 적용 사례
