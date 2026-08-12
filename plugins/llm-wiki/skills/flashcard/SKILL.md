---
name: flashcard
description: Obsidian Spaced Repetition 형식의 위키 플래시카드를 생성, 보강 또는 집계한다. 사용자가 특정 페이지 카드 생성, 주제별 일괄 생성, review stats 또는 flashcard 품질 점검을 요청할 때 사용한다.
---

# Manage LLM Wiki flashcards

1. `../wiki/SKILL.md`와 `flashcard.md`, `metadata.md`, `obsidian-cli.md` reference를 읽는다.
2. 경로 가드 후 대상 페이지와 기존 `## Flashcards` 섹션을 읽는다.
3. 정의/사실은 `::`, 비교/관계는 `:::`, 핵심 용어는 `==cloze==`, 복잡한 설명은 multiline 형식을 사용한다.
4. 의미가 중복되는 카드를 추가하지 않고 페이지당 3~7장을 목표로 한다.
5. `review-stats` 요청은 페이지별·유형별 수와 카드가 없는 active 페이지를 보고한다.
6. 변경한 경우 index 필요 여부를 확인하고 `wiki/log.md`에 기록한다.
