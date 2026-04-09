---
type: source
summary: "Git의 기본 merge 전략이 recursive에서 ort로 교체된 배경, 최적화 원리, 성능 개선 정리"
tags:
  - git
  - merge
  - performance
sources:
  - "[[raw/Git의-새로운-기본-Merge-전략-ort----Outsider's-Dev-Story-3660a107-6aa7-4548-acb3-c2aeb7ddb1e1]]"
created: 2026-04-09
updated: 2026-04-09
status: active
---

# Git의 새로운 기본 Merge 전략 ort

원문: Outsider's Dev Story (2024-02-23)

## 요약

Git의 merge 전략이 `resolve` → `recursive` (2005) → `ort` (Git 2.33~2.34, 2021)로 진화했다. `ort`는 [[git-merge-strategies#ort 전략|Ostensibly Recursive's Twin]]의 약자로, `recursive`와 같은 개념이지만 처음부터 재작성되었다.

## 핵심 인용

> ort는 index와 working tree를 건드리지 않고 머지 결과를 트리로 만들어서 이 머지 결과가 나왔을 때만 ort가 체크아웃 로직을 이용해서 머지 결과로 이동하게 된다.

> 파일명 변경이 많고 복잡한 머지의 경우 500배가 빨라졌고 rebase 과정에서 비슷한 머지를 반복해서 하게 되면 ort가 일부 계산을 캐싱하기 때문에 9,000배 이상 빨라진다.

## 교체 동기

- `recursive`의 코드베이스가 패치 누적으로 수정 불가능한 상태에 도달
- 버그가 많고 엣지 케이스 해결이 어려워 개발자들이 코드 수정을 기피
- [[elijah-newren]]이 큰 변경을 시도하자 [[junio-hamano]]가 완전 재작성을 제안

## 핵심 최적화

1. **index/working tree 미사용**: 머지 결과를 인메모리 트리로 구성, 최종 결과만 체크아웃
2. **파일명 변경 탐지 개선**: 2개 커밋이 아닌 3개 커밋 정보를 활용하도록 추상화 경계 재설계
3. **인메모리 캐싱**: rebase/cherry-pick에서 반복되는 이름 변경 탐지를 캐싱
4. **`unpack_trees()` 제거**: 성능에 영향을 주던 저수준 함수 의존 제거

## GitHub 적용 결과

- 머지 속도: p50에서 10배, p99에서 5배 향상
- 리베이스: 512시간 → 33시간

## 관련 개념/엔티티

- [[git-merge-strategies]]
- [[elijah-newren]]
