---
name: lint
description: Obsidian LLM Wiki의 링크, metadata, 내용, flashcard와 index 정합성을 검사한다. 사용자가 위키 건강검진, lint, 깨진 링크, 고아 페이지, stale 또는 품질 문제 점검을 요청할 때 사용한다.
---

# Lint LLM Wiki

1. `../wiki/SKILL.md`와 `workflows.md`, `metadata.md`, `flashcard.md`, `obsidian-cli.md` reference를 읽는다. `wiki/company/`가 있으면 `company-context.md`도 읽는다.
2. 경로 가드 후 기본적으로 read-only 검사를 수행한다.
3. orphans, unresolved links, tags, frontmatter, summary, stale active 페이지, 빈약한 페이지, 중복, flashcard 문법, index 정합성을 검사한다. 회사 문서는 company/authority/confidentiality, fact의 sources/verified_at, review_after 만료, draft를 canonical처럼 참조한 링크도 검사한다.
4. 결과를 Critical, Warning, Info와 통계로 분류한다.
5. 수정안을 먼저 제시한다. 사용자의 명시적 승인 전에는 파일을 수정하거나 log를 남기지 않는다.
6. 승인된 수정만 수행하고 `wiki/log.md`에 결과를 기록한다.
