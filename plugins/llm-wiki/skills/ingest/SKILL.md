---
name: ingest
description: Obsidian LLM Wiki의 raw 소스를 source, concept, entity 페이지와 플래시카드로 수집한다. 사용자가 소스 수집, ingest, 새 raw 파일 처리 또는 미수집 문서 반영을 요청할 때 사용한다.
---

# Ingest into LLM Wiki

1. 먼저 `../wiki/SKILL.md`와 `workflows.md`, `metadata.md`, `conventions.md`, `flashcard.md`, `obsidian-cli.md` reference를 끝까지 읽는다.
2. wiki skill의 경로 가드로 `$LLM_WIKI_ROOT`를 검증한다. 실패하면 즉시 중단한다.
3. 인자가 없으면 `wiki/sources/*.md`의 `sources` wikilink 집합과 `raw/**/*.md`의 차집합으로 미수집 파일을 찾는다. 파일명 유사도로 판정하지 않는다.
4. frontmatter만 있거나 본문이 10줄 미만인 빈 소스는 제외하고 보고한다.
5. 대상 소스를 전부 읽고 핵심 발견, 강조 후보, 새 개념/엔티티 후보를 사용자와 확인한다.
6. 승인된 방향으로 source 요약과 관련 페이지를 작성하고 플래시카드·교차참조·index를 갱신한다.
7. `wiki/log.md`에 `## [YYYY-MM-DD] ingest | 제목` 형식으로 기록한다.

여러 소스는 분석과 개별 source 초안만 병렬화한다. `index.md`, `overview.md`, `log.md` 병합은 한 실행자가 직렬로 수행한다. `raw/`는 절대 수정하지 않는다.
