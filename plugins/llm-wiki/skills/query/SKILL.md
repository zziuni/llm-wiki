---
name: query
description: Obsidian LLM Wiki를 검색하고 축적된 지식과 wikilink 출처를 바탕으로 답변을 합성한다. 사용자가 위키 검색, 질의, 비교, 설명 또는 기존 지식의 분석을 요청할 때 사용한다.
---

# Query LLM Wiki

1. `../wiki/SKILL.md`와 `workflows.md`, `obsidian-cli.md`, `conventions.md` reference를 읽는다.
2. 경로 가드를 실행하고 `wiki/index.md`를 가장 먼저 읽는다.
3. Obsidian search와 index를 교차 대조해 관련 페이지를 고른다.
4. 관련 페이지와 backlinks를 필요한 깊이까지 읽는다.
5. `[[wikilink]]`와 원본 source를 명시해 답하고, 위키에 없는 내용은 구분한다.
6. 재사용 가치가 높은 분석인 경우에만 `wiki/analyses/` 저장을 제안한다. 승인 전에는 저장하지 않는다.
