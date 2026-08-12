# AGENTS.md

This file provides repository guidance to Codex and Claude Code. `CLAUDE.md` is a compatibility symlink to this file.

## Project Overview

Karpathy의 "LLM Wiki" 패턴 구현체. LLM이 RAG처럼 매번 지식을 재발견하는 대신, 영구적인 위키를 점진적으로 구축/유지한다. 사람은 소스를 큐레이션하고 질문하며, LLM이 요약, 교차참조, 정리, 유지보수를 전담한다. 구축된 위키는 spaced repetition flashcard로도 활용된다.

## Obsidian Vault

**코드와 데이터가 분리되어 있다.** 이 저장소는 플러그인 코드만 포함. 위키 데이터(raw/, wiki/)는 `$LLM_WIKI_ROOT` 환경변수가 가리키는 별도 저장소에 위치한다.

- `raw/` — **사용자 영역**: Obsidian에서 소스 추가 (Web Clipper, 드래그&드롭). LLM은 읽기만.
- `wiki/` — **LLM 영역**: LLM이 작성/유지. 사용자는 Obsidian에서 브라우징.
- dev 파일 (`.claude-plugin/`, `.codex-plugin/`, `AGENTS.md`, `CLAUDE.md` 등)은 `userIgnoreFilters`로 Obsidian에서 숨김 처리.

## Architecture (Three Layers)

1. **Raw sources** (`raw/`) — 불변 원본 소스. LLM은 읽기만 하고 절대 수정하지 않는다.
2. **Wiki** (`wiki/`) — LLM이 소유하는 마크다운 위키. 요약, 엔티티, 개념, 분석 페이지.
3. **Schema** (플러그인의 `skills/wiki/SKILL.md`와 references) — LLM 행동 규칙, 컨벤션, 워크플로우 정의.

특정 회사에서만 유효한 사실과 운영 맥락은 일반 지식과 분리하여 `wiki/company/<company>/`에 둔다. 현재 대표 data vault는 `company/musinsa/`에서 MSS·29CM의 iOS·Android·Web Client Architecture를 관리한다.

```
(vault root)
├── raw/                ← Layer 1: 원본 소스 (사용자가 추가, LLM은 읽기만)
│   └── assets/         ← 이미지, PDF 등 첨부파일
├── wiki/               ← Layer 2: LLM 소유 위키 (사용자는 Obsidian에서 브라우징)
│   ├── index.md        ← 마스터 카탈로그 (쿼리 시 첫 번째로 읽기)
│   ├── log.md          ← 시간순 작업 기록 (append-only)
│   ├── hot.md          ← 핫캐시 (세션 간 컨텍스트 이월)
│   ├── overview.md     ← 위키 전체 합성 요약
│   ├── concepts/       ← 개념 페이지
│   ├── entities/       ← 엔티티 페이지 (인물, 조직 등)
│   ├── sources/        ← 소스별 요약 페이지
│   ├── analyses/       ← 회사와 무관한 쿼리 결과 중 가치 있는 것 저장
│   └── company/        ← 회사별 업무 컨텍스트
│       └── <company>/  ← context, architecture, facts, decisions, operations, drafts 등
├── AGENTS.md           ← 저장소 작업 지침
├── CLAUDE.md           ← AGENTS.md 호환 심볼릭 링크
└── .obsidian/          ← vault 설정
```

## Key Files

- `wiki/index.md` — 전체 페이지 카탈로그. 쿼리 시 반드시 첫 번째로 읽는다.
- `wiki/log.md` — Append-only 작업 기록. 형식: `## [YYYY-MM-DD] verb | Title`
- `wiki/hot.md` — 세션 간 컨텍스트 캐시. 세션 시작 시 읽고, 종료 시 갱신.
- `wiki/overview.md` — 위키 전체 합성 요약. 소스 축적에 따라 진화.
- `brainstorming.md` — Karpathy 아이디어 원문 (참조용, 수정 금지).

## Metadata Standard (Frontmatter)

모든 위키 페이지에 YAML frontmatter 필수:

```yaml
---
type: concept | entity | source | analysis | overview | context | fact | catalog | architecture | decision | operation | draft
summary: "50-100자 요약 — 쿼리 라우팅용"
tags:
  - tag1
sources:
  - "[[sources/원본파일명]]"
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: active | draft | archived
---
```

- `summary`: 전체 로드 없이 관련성 판단하는 한줄 요약
- `sources`: 이 페이지 내용의 원본 추적
- `status`: 라이프사이클 관리. lint에서 stale 감지 기준
- 회사 문서는 `company`, `authority`, `confidentiality`를 필수로 추가하고 서비스·클라이언트 범위를 배열로 기록한다. 상세 스키마는 `skills/wiki/references/metadata.md`가 SSOT다.

## Core Operations

### Ingest

소스를 `raw/`에 추가한 후 수집:

1. **소스 읽기**: raw/ 파일 전체 읽기, 이미지 참조 확인
2. **사용자와 토론**: 핵심 발견 3-5개 제시, 피드백 수렴
3. **소스 요약 생성**: `wiki/sources/<name>.md` — frontmatter + 요약 + 핵심 인용
4. **관련 페이지 갱신**: `obsidian search`로 기존 관련 페이지 찾기, 갱신/생성
5. **플래시카드 생성**: 개념/엔티티 페이지 `## Flashcards` 섹션에 카드 추가
6. **교차참조 & 인덱스**: `[[wikilink]]` 추가, `wiki/index.md` 갱신
7. **로깅**: `wiki/log.md`에 append

### Query

위키에 질문:

1. **탐색**: `obsidian search` + `wiki/index.md`에서 관련 페이지 찾기. 회사 질문이면 vault의 `AGENTS.md`와 company index도 읽기
2. **드릴다운**: 페이지 읽기, backlinks 따라가며 컨텍스트 수집
3. **합성**: `[[wikilink]]` 인용 포함 답변
4. **저장 제안**: 범용 분석은 `wiki/analyses/`, 회사 고유 분석은 `wiki/company/<company>/analyses/`에 저장 제안

### Lint

위키 건강검진:

1. **구조적**: `obsidian orphans` (고아), `obsidian unresolved` (깨진 링크), `obsidian tags` (태그 일관성)
2. **메타데이터**: frontmatter 누락, summary 없음, 90일 이상 미갱신 active 페이지
3. **내용**: 페이지 간 모순, 전용 페이지 없는 자주 언급 개념, 빈약한 페이지
4. **플래시카드**: `## Flashcards` 없는 active 개념 페이지, 카드 수 0인 페이지
5. **리포트 & 로깅**: 발견 사항 정리, 사용자 승인 후 수정, log.md 기록

## Flashcard Convention

Obsidian Spaced Repetition 플러그인 호환. 위키 페이지 안에 인라인 삽입 (별도 카드 파일 없음).

각 개념/엔티티 페이지 하단에 `## Flashcards` 섹션:

```markdown
## Flashcards
#flashcards

정의/사실 질문::답변

비교/관계 질문:::양방향 답변

복잡한 질문
여러 줄
?
복잡한 답변
여러 줄

핵심 문장에서 ==핵심 용어==를 빈칸으로 만든다.
```

카드 유형 선택 기준:
- 정의/사실 → 싱글라인 Q&A (`::`)
- 비교/관계 → 양방향 (`:::`)
- 핵심 용어 → Cloze (`==term==`)
- 페이지당 3-7장 적정

덱 구성: 폴더 기반 (`wiki/concepts/` → Concepts 덱).

## Obsidian CLI Usage

Obsidian CLI (v1.12+)를 적극 활용. 직접 파일 I/O보다 CLI 우선.

```bash
# 검색
obsidian search query="키워드" format=json

# 링크 분석
obsidian links file="페이지명"
obsidian backlinks file="페이지명"

# 구조 검사
obsidian orphans              # 고아 페이지
obsidian unresolved           # 깨진 링크

# 태그
obsidian tags                 # 전체 태그 목록
obsidian tag tag="#태그명"    # 특정 태그의 파일 목록

# 속성 관리
obsidian property:set file="페이지" name="updated" value="YYYY-MM-DD"

# 파일 작업 (자동 위키링크 갱신)
obsidian create name="wiki/concepts/이름" content="..."
obsidian append file="wiki/index.md" content="..."
obsidian move file="old" to="new"     # 위키링크 자동 갱신
obsidian read file="페이지명"
```

## Plugin

위키 작업은 `plugins/llm-wiki/` 플러그인이 담당한다. 스키마의 Single Source of Truth는 플러그인의 `skills/wiki/SKILL.md` + `references/`.

**위키 경로 해석**: 모든 `raw/`, `wiki/` 경로는 `wiki-root.sh` 스크립트를 통해 해석한다. CWD 기반 상대경로 사용 금지. Claude에서는 `${CLAUDE_PLUGIN_ROOT}`를 사용할 수 있고, Codex에서는 활성화된 skill의 경로에서 plugin root를 찾아 스크립트의 절대경로를 사용한다.
```bash
ROOT=$(bash "${CLAUDE_PLUGIN_ROOT}/hooks/wiki-root.sh")
# 이후 $ROOT/wiki/index.md, $ROOT/raw/ 등 절대경로 사용
```

## Conventions

- 파일명: 소문자, 하이픈 구분 (`machine-learning.md`), 한글 허용
- 위키링크: `[[파일명]]` (shortest path, Obsidian 호환)
- 모순 표시: `> [!warning] 모순` 콜아웃으로 페이지 간 충돌 표시
- 로그 형식: `## [YYYY-MM-DD] verb | Title` — grep 파서블
- 이미지/첨부: `raw/assets/`에 저장
- raw/ 파일은 절대 수정하지 않는다
- 세션 시작 시 `wiki/hot.md` 읽어 컨텍스트 복원
- 세션 종료 시 `wiki/hot.md` 갱신
- `wiki/hot.md`는 gitignored — 없으면 새로 생성
- Obsidian CLI 실패 시 (앱 미실행) Read/Write/Edit tool로 fallback

## Cross-host Plugin Development

- Claude manifest: `plugins/llm-wiki/.claude-plugin/plugin.json`
- Codex manifest: `plugins/llm-wiki/.codex-plugin/plugin.json`
- Claude commands: `plugins/llm-wiki/commands/*.md`
- Codex skills: `plugins/llm-wiki/skills/<operation>/SKILL.md`
- 공통 규칙: `plugins/llm-wiki/skills/wiki/references/`
- 회사 컨텍스트 규칙: `plugins/llm-wiki/skills/wiki/references/company-context.md`
- schema version source of truth: `plugins/llm-wiki/schema.json`
- 사용자 노출 namespace는 양쪽 모두 `llm-wiki:<operation>`으로 유지한다.
- Claude/Codex adapter에 공통 규칙을 복사하지 말고 wiki references를 읽게 한다.
- Codex plugin 변경 후 plugin validator와 각 skill validator를 실행한다.
