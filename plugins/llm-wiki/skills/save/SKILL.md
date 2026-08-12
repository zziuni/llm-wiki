---
name: save
description: 현재 대화에서 재사용 가치가 있는 발견, 분석, 비교 또는 결정을 Obsidian LLM Wiki 페이지로 저장한다. 사용자가 현재 대화나 답변을 위키 노트로 저장해 달라고 요청할 때 사용한다.
---

# Save conversation to LLM Wiki

1. `../wiki/SKILL.md`와 `metadata.md`, `conventions.md`, `workflows.md` reference를 읽는다. 회사 관련 내용이면 `company-context.md`도 읽는다.
2. 경로 가드 후 대화에서 저장할 가치가 있는 내용만 식별한다.
3. 일반 지식인지 특정 회사에서만 유효한 컨텍스트인지 먼저 판별한다. 회사 컨텍스트이면 root `AGENTS.md`와 company index에서 회사·서비스·클라이언트 범위를 확인한다.
4. 저장 범위, 추천 페이지명, 문서 유형과 변경 대상 파일을 사용자에게 제시한다. 회사 문서는 context/fact/catalog/architecture/decision/analysis/operation/draft/source 중 의미에 맞게 라우팅한다.
5. 승인 후 frontmatter를 포함한 페이지를 생성하거나 기존 페이지에 통합한다.
6. 관련 wikilink와 `wiki/index.md` 및 해당 company index를 갱신하고 `wiki/log.md`에 `save` 기록을 남긴다.
7. 대화에 없는 사실을 보충해 쓰지 않는다. draft·proposal을 canonical fact로 승격하지 않는다.
