---
type: concept
summary: "Git merge 전략의 진화 — resolve, recursive, ort의 차이와 동작 원리"
tags:
  - git
  - merge
  - algorithm
sources:
  - "[[sources/git-merge-strategy-ort]]"
created: 2026-04-09
updated: 2026-04-09
status: active
---

# Git Merge Strategies

Git이 브랜치를 머지할 때 사용하는 전략의 진화사.

## resolve 전략

Git 초기의 기본 전략. [[3-way-merge]] 알고리즘을 사용하여 두 브랜치의 공통 조상(C)과 각 브랜치의 최신 커밋(A, B)을 비교한다. A, B, C 모두 다른 경우 충돌로 표시.

## recursive 전략

2005년에 `resolve`를 교체. 16년간 기본 전략으로 사용 (2005~2021).

**개선점**:
- 공통 조상이 없는 경우에도 재귀적으로 머지 가능
- 한 브랜치에서 파일 수정 + 다른 브랜치에서 파일명 변경 시 감지 가능

**한계**:
- 코드베이스가 패치 누적으로 수정 불가능한 상태에 도달
- index와 working tree에 직접 의존하여 최적화 어려움
- `unpack_trees()` 저수준 함수에 의존

## ort 전략

Git 2.33 (2021-08)에 도입, Git 2.34 (2021-11)에서 기본 전략으로 채택. [[elijah-newren]]이 주도하여 처음부터 재작성.

**이름**: Ostensibly Recursive's Twin — "표면적으로 recursive의 쌍둥이"

**핵심 차이**:
- index/working tree를 건드리지 않고 머지 결과를 **인메모리 트리**로 구성
- 최종 결과만 체크아웃 → 불필요한 트리 탐색 제거
- 파일명 변경 탐지를 3개 커밋 정보로 수행 (2개 → 3개)
- rebase/cherry-pick에서 이름 변경 탐지 결과를 **인메모리 캐싱**

**성능**:
- 복잡한 머지: ~500배 향상
- 반복 rebase: ~9,000배 향상
- GitHub 적용: p50 10배, 리베이스 512시간 → 33시간

**사용법**:
```bash
git merge branch-name                    # 기본 ort
git merge --strategy recursive branch    # 명시적으로 recursive 지정
```

## Related

- [[sources/git-merge-strategy-ort]]
- [[elijah-newren]]

## Flashcards
#flashcard

ort는 무엇의 약자인가?::Ostensibly Recursive's Twin (표면적으로 recursive의 쌍둥이)

Git merge 전략의 진화 순서:::resolve → recursive (2005) → ort (Git 2.33, 2021)

ort가 recursive보다 빠른 핵심 이유::index/working tree를 건드리지 않고 머지 결과를 인메모리 트리로 구성한 뒤, 최종 결과만 체크아웃

ort의 복잡한 머지 성능 향상 배수::==500==배, rebase는 ==9,000==배

Git 2.34부터 기본 merge 전략은 ==ort==이다.
