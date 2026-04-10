---
type: concept
summary: "세 버전(공통 조상, 두 브랜치)을 비교하여 병합하는 알고리즘 — Git merge의 기본 원리"
tags:
  - git
  - merge
  - algorithm
sources:
  - "[[sources/git-merge-strategy-ort]]"
created: 2026-04-10
updated: 2026-04-10
status: active
---

# 3-Way Merge

세 개의 버전 — **공통 조상(Base)**, **브랜치 A**, **브랜치 B** — 을 비교하여 병합하는 알고리즘. Git의 모든 merge 전략([[git-merge-strategies]])의 기본 원리.

## 동작 원리

```
        Base (C)
       /        \
    A (ours)   B (theirs)
```

1. Base와 A를 비교 → A에서 변경된 부분 파악
2. Base와 B를 비교 → B에서 변경된 부분 파악
3. **한 쪽만 변경**: 변경된 쪽을 자동 채택
4. **양쪽 다 변경, 같은 내용**: 자동 채택
5. **양쪽 다 변경, 다른 내용**: **충돌(conflict)** 으로 표시 → 수동 해결 필요

## 2-Way Merge와의 차이

| 비교 | 2-Way | 3-Way |
|------|-------|-------|
| 비교 대상 | A와 B만 | Base, A, B |
| 충돌 판단 | A ≠ B이면 모두 충돌 | Base 기준으로 누가 변경했는지 판단 |
| 자동 병합 | 거의 불가 | 한 쪽만 변경 시 자동 |

공통 조상(Base)의 존재가 핵심 — Base가 없으면 "누가 변경했는지" 판단 불가.

## Git에서의 활용

- `resolve` 전략: 단일 공통 조상으로 3-way merge 수행
- `recursive` 전략: 공통 조상이 여러 개이면 재귀적으로 3-way merge 반복
- `ort` 전략: recursive와 동일한 3-way merge 로직을 인메모리로 수행

## Flashcards
#flashcards

3-Way Merge에서 비교하는 세 버전::공통 조상(Base), 브랜치 A(ours), 브랜치 B(theirs)

3-Way Merge에서 충돌이 발생하는 조건::양쪽 브랜치가 같은 부분을 다르게 변경했을 때. 한 쪽만 변경하면 자동 채택된다.

3-Way Merge가 2-Way보다 우수한 이유::공통 조상(Base)이 있어 "누가 변경했는지" 판단 가능. 한 쪽만 변경 시 자동 병합할 수 있다.
