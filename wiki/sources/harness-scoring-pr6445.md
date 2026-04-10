---
type: source
summary: "PR #6445 — Harness Scoring 온보딩 부트스트랩 (3개 설정 파일 구조 분석)"
tags:
  - harness
  - scoring
  - github-actions
  - pr-analysis
sources:
  - "[[raw/harness-scoring-pr6445]]"
created: 2026-04-10
updated: 2026-04-10
status: active
---

# Harness Scoring Onboarding — PR #6445

> 소스: [PR #6445](https://github.com/29CM-Developers/frontend-29cm-platform/pull/6445)
> 작성자: 이양호(Vader) / cloude-lee, Co-authored-by: Codex
> 수집일: 2026-04-10

## 핵심 요약

`frontend-29cm-platform` 레포에 Harness Engineering Scoring System을 온보딩하는 PR. 3개 파일(총 55줄)을 추가하여 PR 품질 자동 스코어링을 활성화한다.

## 파일 구조 분석

### 1. `.github/workflows/harness-scoring.yml` (14줄)

Caller workflow. PR 이벤트 4가지(opened, synchronize, edited, closed)를 감지하여 중앙 `musinsa/harness-engineering-scoring-system`의 reusable workflow를 호출한다.

- Job 이름 `submit-normalized-ingress`는 정규화된 PR 데이터를 중앙에 제출하는 역할
- `secrets: inherit`로 조직 secrets 상속

### 2. `.harness/scoring.yml` (4줄)

레포 프로필(`frontend/monorepo`)과 팀 매핑(`**` → "29CM-E Commerce Frontend")을 정의. `scripts/onboard_repo.py`로 자동 생성된다.

### 3. `.harness/pr-authoring.json` (37줄)

PR 작성 가이드라인. 8가지 힌트 카테고리(spec, guide, oracle, rollout, rollback, validation, review_notes, check)로 PR의 다양한 측면을 안내한다.

## 주요 인사이트

- **최소 침습 온보딩**: 14줄 workflow + 4줄 설정 + 37줄 힌트 = 총 55줄
- **중앙-분산 분리**: 스코어링 로직은 중앙 레포, 설정은 각 레포
- **자동화**: `onboard_repo.py` 스크립트로 PR까지 자동 생성

## 핵심 인용

> `system_context`: "This repository primarily matches the frontend/monorepo profile. Emphasize reviewer-readable evidence, concrete oracle signals, and the fastest safe rollback path."

## 관련 위키 페이지

- [[harness-scoring-system]] — HESS 개념 정리
- [[github-actions-reusable-workflow]] — 기반 기술
