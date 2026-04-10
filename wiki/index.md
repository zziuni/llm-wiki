---
type: overview
summary: "위키 전체 페이지 카탈로그 — 쿼리 시 첫 번째로 참조"
updated: 2026-04-10
---

# Wiki Index

## Overview
- [[overview]] — 위키 전체 합성 요약

## Concepts
- [[biome]] — Rust 기반 웹 개발 통합 린터/포매터
- [[git-merge-strategies]] — Git merge 전략의 진화: resolve → recursive → ort
- [[monorepo-dx]] — 모노레포 환경의 개발자 경험과 성능 병목
- [[oxfmt]] — Oxc 기반 고성능 포매터 (Prettier ~30배, Biome ~2배 빠름)
- [[compound-component-pattern]] — React 합성 컴포넌트 패턴: 서브 컴포넌트 조합으로 유연한 UI 구성
- [[composition-two-axes]] — Composition의 두 축: Behavior(Hook)와 Structure(Compound Component)의 근본적 차이
- [[headless-component]] — 스타일 없이 동작·접근성만 제공하는 UI 컴포넌트 패턴 (Radix UI, Headless UI 기반)
- [[3-way-merge]] — 세 버전(공통 조상, 두 브랜치)을 비교하여 병합하는 알고리즘
- [[github-actions-reusable-workflow]] — GitHub Actions workflow_call 기반 Caller-Called 재사용 패턴
- [[harness-scoring-system]] — GitHub Actions reusable workflow 기반 PR 품질 스코어링 시스템 (HESS)
- [[saas]] — Software as a Service: 클라우드 기반 구독형 소프트웨어 배포 모델

## Entities
- [[elijah-newren]] — Git 핵심 개발자, ort merge 전략 설계·구현
- [[junio-hamano]] — Git 프로젝트 메인테이너(BDFL), 2005년부터 현재까지

## Sources
- [[biome-migration-guide]] — Biome 마이그레이션 실전 가이드 6단계 (수집일: 2026-04-09)
- [[biome-migration-report]] — ESLint+Prettier → Biome 마이그레이션 결과 보고서 (수집일: 2026-04-09)
- [[git-merge-strategy-ort]] — Git의 새로운 기본 Merge 전략 ort (수집일: 2026-04-09)
- [[oxfmt-official-docs]] — Oxfmt 공식 문서 (수집일: 2026-04-09)
- [[corca-compound-component]] — Corca 디자인 시스템 Compound Component 적용기 (수집일: 2026-04-09)
- [[compound-component-pattern-web]] — Compound Component 웹 소스 종합: patterns.dev, Kent C. Dodds, freeCodeCamp (수집일: 2026-04-09)
- [[headless-component-web]] — Headless Component & TypeScript 웹 소스: Alyssa Holland, Pasquale Favella (수집일: 2026-04-09)

- [[github-actions-reusable-workflow-docs]] — GitHub Actions Reusable Workflow 공식 문서 요약 (수집일: 2026-04-10)
- [[harness-scoring-pr6445]] — Harness Scoring 온보딩 PR #6445 분석 (수집일: 2026-04-10)
- [[saas-definition-web-sources]] — AWS, Google Cloud, Wikipedia 등 SaaS 정의 웹 소스 종합 (수집일: 2026-04-10)
- [[saas-metrics-maturity-web-sources]] — SaaS 비즈니스 메트릭·성숙도 모델 웹 소스 종합 (수집일: 2026-04-10)

## Analyses
- [[pdp-problem-analysis]] — PDP 현황 분석: 번들 908KB, fetchProductDetail 코드 7회 호출, Context 64개 구독자, 3가지 페칭 패턴 혼재
- [[pdp-restructure-hld]] — PDP 분리 HLD: home→pdp 앱 분리, product review 통합, mental model 기반 계층 개선
- [[hook-chaining-analysis]] — God Hook 현황, 깊이/관심사/방향 경계 조건, 피처 간 의존 문제
- [[codebase-improvement-roadmap]] — 5개 워크스트림 × 4단계 타임라인, 추가 식별 과제 10건
- [[mcp-atlassian-fakeredis-fix]] — fakeredis FakeConnection 호환성 버그 원인/패치/도메인 구조
- [[packages-restructure-hld]] — packages 구조 재편: barrel 평면화 5기준, 단일앱 21→5개 검증, domain-service 독립 분리
