---
name: flashcard
description: 플래시카드 생성, 보강, 통계
user_invocable: true
args: "[페이지명|review-stats|generate-from 주제]"
---

# /flashcard — 플래시카드 관리

위키 페이지의 플래시카드를 생성, 보강, 관리한다.

> **경로 기준**: 모든 `raw/`, `wiki/` 경로는 `$LLM_WIKI_ROOT` 기준. 미설정 시 CWD. 상세는 wiki skill의 "경로 규칙" 참조.

## 사용법

### /flashcard [페이지명]
특정 페이지의 `## Flashcards` 섹션을 생성하거나 보강한다.
- 페이지 내용을 분석하여 적절한 카드 생성
- 기존 카드가 있으면 중복 방지하며 추가
- 카드 유형 자동 선택: 정의(::), 비교(:::), 핵심용어(==cloze==)

### /flashcard review-stats
위키 전체의 플래시카드 통계를 보여준다.
- 페이지별 카드 수
- 카드 유형별 분포 (Q&A, 양방향, Cloze)
- 카드 없는 active 페이지 목록
- 총 카드 수

### /flashcard generate-from [주제]
주제 관련 모든 페이지를 찾아 일괄로 카드를 생성한다.
- `obsidian search query="주제" format=json`으로 관련 페이지 탐색
- 각 페이지에 대해 카드 생성/보강
- 결과 요약 리포트

## 카드 작성 기준

- **정의/사실**: 싱글라인 Q&A (`질문::답변`)
- **비교/관계**: 양방향 (`A:::B`) — 양쪽에서 물어볼 수 있는 관계
- **핵심 용어**: Cloze (`문장에서 ==핵심용어==를 빈칸`) — 문맥 속 기억
- **복잡한 설명**: 멀티라인 Q&A (`?` 구분)
- 페이지당 3-7장 적정 (너무 많으면 리뷰 부담)
- 단순 암기보다 이해를 테스트하는 카드 선호

## 섹션 형식

```markdown
## Flashcards
#flashcard

카드1::답변1

카드2:::양방향답변2

문장에서 ==핵심용어==를 기억한다.
```
