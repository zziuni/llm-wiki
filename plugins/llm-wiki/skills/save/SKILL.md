---
name: save
description: 현재 대화에서 재사용 가치가 있는 발견, 분석, 비교 또는 결정을 Obsidian LLM Wiki 페이지로 저장한다. 사용자가 현재 대화나 답변을 위키 노트로 저장해 달라고 요청할 때 사용한다.
---

# Save conversation to LLM Wiki

1. `../wiki/SKILL.md`와 `metadata.md`, `conventions.md`, `workflows.md` reference를 읽는다.
2. 경로 가드 후 대화에서 저장할 가치가 있는 내용만 식별한다.
3. 저장 범위, 추천 페이지명, analysis/concept/entity 유형과 변경 대상 파일을 사용자에게 제시한다.
4. 승인 후 frontmatter를 포함한 페이지를 생성하거나 기존 페이지에 통합한다.
5. 관련 wikilink와 `wiki/index.md`를 갱신하고 `wiki/log.md`에 `save` 기록을 남긴다.
6. 대화에 없는 사실을 보충해 쓰지 않는다.
