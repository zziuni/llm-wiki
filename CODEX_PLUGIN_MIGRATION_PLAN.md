# LLM Wiki Codex 플러그인 전환 실행계획

## 1. 목표

현재 Claude Code용 `llm-wiki` 플러그인의 위키 스키마와 워크플로우를 유지하면서 Codex에서도 설치·발견·실행할 수 있도록 호환 레이어를 추가한다.

사용자에게 노출되는 기능 이름은 두 호스트에서 동일한 네임스페이스를 사용한다.

| 기능 | Claude Code | Codex skill namespace |
|---|---|---|
| 부트스트랩/상태 | `llm-wiki:wiki` | `llm-wiki:wiki` |
| 소스 수집 | `llm-wiki:ingest` | `llm-wiki:ingest` |
| 위키 질의 | `llm-wiki:query` | `llm-wiki:query` |
| 건강검진 | `llm-wiki:lint` | `llm-wiki:lint` |
| 플래시카드 | `llm-wiki:flashcard` | `llm-wiki:flashcard` |
| 대화 저장 | `llm-wiki:save` | `llm-wiki:save` |
| 자율 연구 | `llm-wiki:autoresearch` | `llm-wiki:autoresearch` |

Codex에서는 플러그인 이름 `llm-wiki`와 각 skill 이름(`save`, `wiki`, `lint` 등)을 조합해 `llm-wiki:save` 형태의 namespace를 만든다. 따라서 skill 자체의 `name`에 `llm-wiki-`를 중복해서 넣지 않는다.

호스트별 실제 호출 UI는 다를 수 있다. Claude Code에서는 `/llm-wiki:save`, Codex에서는 skill picker 또는 `$llm-wiki:save` 형태로 명시 호출할 수 있도록 문서화한다. 자연어 요청에 의한 implicit invocation도 지원하되, 쓰기 작업은 실행 전에 대상 vault와 변경 범위를 보여준다.

## 2. 설계 원칙

1. 위키 규칙은 한 곳에서만 관리한다.
2. Claude의 `commands/`와 Codex의 `skills/`는 얇은 adapter로 유지한다.
3. 특정 호스트가 제공하는 plugin-root 환경변수에 의존하지 않는다.
4. `raw/` 불변, 절대경로 사용, 로깅 등 기존 안전 규칙을 유지한다.
5. `index.md`, `log.md`, `.llm-wiki-meta.json` 같은 공유 파일 갱신은 직렬화한다.
6. Claude와 Codex가 같은 fixture vault에 대해 동일한 결과를 내는 contract test를 둔다.

## 3. 목표 디렉터리 구조

```text
.
├── AGENTS.md
├── CLAUDE.md
├── plugins/
│   └── llm-wiki/
│       ├── .claude-plugin/plugin.json
│       ├── .codex-plugin/plugin.json
│       ├── schema.json
│       ├── commands/
│       ├── agents/
│       ├── skills/
│       │   ├── wiki/SKILL.md
│       │   ├── ingest/SKILL.md
│       │   ├── query/SKILL.md
│       │   ├── lint/SKILL.md
│       │   ├── flashcard/SKILL.md
│       │   ├── save/SKILL.md
│       │   └── autoresearch/SKILL.md
│       ├── hooks/
│       └── scaffold/
└── .agents/
    └── plugins/
        └── marketplace.json
```

Claude와 Codex adapter는 같은 `plugins/llm-wiki/` 패키지와 `skills/wiki/references/`를 공유한다. 루트 `CLAUDE.md`만 `AGENTS.md`를 가리키는 호환 심볼릭 링크로 유지한다.

## 4. 작업 단계

### Phase 0 — 기준선 고정

- [ ] 현재 Claude 명령 7개의 입력, 출력, 변경 파일을 fixture로 기록한다.
- [ ] 최소 테스트 vault를 만든다.
- [ ] `wiki-root.sh`의 정상/실패 동작을 shell test로 고정한다.
- [ ] 기존 Claude 플러그인 설치 및 명령 발견 여부를 smoke test로 기록한다.

완료 조건:

- 변경 전 Claude 동작을 재현하는 테스트 또는 실행 기록이 존재한다.
- 이후 구조 변경이 기존 기능을 깨뜨렸는지 비교할 수 있다.

### Phase 1 — 공통 core 정리

- [x] `skills/wiki/references/`를 두 호스트의 공통 reference로 유지한다.
- [x] `scaffold/`와 migrations를 하나의 plugin package에서 공유한다.
- [ ] Claude command 문서의 중복 규칙을 공통 reference 링크로 치환한다.
- [x] schema version을 호스트 manifest에서 분리하여 `schema.json`으로 관리한다.
- [x] Claude adapter가 공통 schema와 workflow를 사용하도록 경로를 갱신한다.

완료 조건:

- 위키 구조, metadata, flashcard, workflow 규칙의 source of truth가 각각 하나뿐이다.
- 기존 Claude 명령 smoke test가 통과한다.

### Phase 2 — 호스트 독립 경로 계층

- [x] 공통 reference에서 `${CLAUDE_PLUGIN_ROOT}` 직접 의존을 제거한다.
- [x] Codex skill이 자신의 위치에서 plugin root를 계산하도록 한다.
- [ ] `$LLM_WIKI_ROOT`를 canonical absolute path로 변환한다.
- [ ] 절대경로 인자, `..`, symlink escape 등 vault 밖으로 나가는 경로를 거부한다.
- [ ] 경로 조회와 디렉터리 생성 API를 분리한다.
- [ ] scaffold/migration 작업을 `wiki-bootstrap.sh`로 분리한다.

완료 조건:

- Claude/Codex 전용 plugin-root 환경변수 없이 모든 스크립트가 실행된다.
- 잘못된 경로가 vault 외부 파일을 읽거나 수정하지 못한다.

### Phase 3 — Codex plugin scaffold

- [x] `plugins/llm-wiki/.codex-plugin/plugin.json`을 생성한다.
- [x] manifest의 `name`을 `llm-wiki`로 고정한다.
- [x] `skills: "./skills/"`와 UI metadata를 설정한다.
- [x] repository marketplace `.agents/plugins/marketplace.json`을 추가한다.
- [x] Codex plugin validator로 manifest를 검사한다.

Codex manifest의 최소 형태:

```json
{
  "name": "llm-wiki",
  "version": "0.3.0",
  "description": "Build and maintain an Obsidian-based persistent LLM wiki",
  "author": {
    "name": "zziuni"
  },
  "keywords": [
    "obsidian",
    "wiki",
    "knowledge-management",
    "flashcards"
  ],
  "skills": "./skills/",
  "interface": {
    "displayName": "LLM Wiki",
    "shortDescription": "Build and query a persistent Obsidian wiki",
    "longDescription": "Ingest sources, maintain linked wiki pages, query accumulated knowledge, lint the vault, and generate flashcards.",
    "developerName": "zziuni",
    "category": "Productivity",
    "capabilities": ["Interactive", "Write"],
    "defaultPrompt": [
      "새 raw 소스를 위키에 수집해줘",
      "내 위키에서 이 주제를 찾아 답해줘",
      "위키 상태를 검사해줘"
    ]
  }
}
```

### Phase 4 — 핵심 Codex skills 구현

우선 사용 빈도가 높은 세 기능을 구현한다.

- [x] `skills/wiki/SKILL.md`
- [x] `skills/ingest/SKILL.md`
- [x] `skills/query/SKILL.md`

각 `SKILL.md`는 다음 기준을 따른다.

- 디렉터리 이름과 skill `name`을 동일하게 유지한다.
- `name`은 `wiki`, `ingest`, `query`처럼 기능명만 사용한다.
- plugin namespace가 붙은 최종 표시명은 `llm-wiki:wiki` 형태가 된다.
- description 첫 문장에 trigger를 명확하게 작성한다.
- 공통 규칙을 복사하지 않고 필요한 reference를 읽도록 지시한다.
- `Read`, `Write`, `AskUserQuestion` 같은 Claude 전용 도구명을 사용하지 않는다.
- 쓰기 전에 대상 파일과 변경 범위를 확인하고, 완료 후 변경 파일을 보고한다.

예시:

```yaml
---
name: ingest
description: Obsidian LLM Wiki의 raw 소스를 source, concept, entity 페이지와 플래시카드로 수집한다. 사용자가 위키 수집, ingest, 미수집 raw 처리를 요청할 때 사용한다.
---
```

완료 조건:

- Codex에서 `llm-wiki:wiki`, `llm-wiki:ingest`, `llm-wiki:query`로 발견된다.
- 명시 호출과 자연어 호출을 각각 테스트한다.
- 같은 입력에 대해 Claude adapter와 동일한 vault 구조를 생성한다.

### Phase 5 — 나머지 skills 구현

- [x] `llm-wiki:lint`
- [x] `llm-wiki:flashcard`
- [x] `llm-wiki:save`
- [x] `llm-wiki:autoresearch`

특별 안전 규칙:

- `lint`는 기본 read-only이며 수정은 별도 승인 후 수행한다.
- `save`는 현재 대화에서 저장할 범위와 페이지 유형을 먼저 제시한다.
- `autoresearch`는 최대 라운드, 웹 접근 여부, 수집 출처를 명시한다.
- `ingest` 병렬 처리 시 worker는 개별 source 초안까지만 만들고 `index.md`와 `log.md` 병합은 메인 실행자가 직렬로 수행한다.

### Phase 6 — `AGENTS.md` 및 개발 문서

- [x] 루트 `AGENTS.md`를 추가한다.
- [x] `CLAUDE.md`를 `AGENTS.md` 호환 심볼릭 링크로 변경한다.
- [x] 설치, 환경변수, namespace, 호출 예시를 README에 추가한다.
- [x] Claude와 Codex의 호출 표기 차이를 문서화한다.

`AGENTS.md`에는 다음만 둔다.

- 이 저장소와 실제 vault가 분리되어 있다는 사실
- `$LLM_WIKI_ROOT` 필수 조건
- `raw/` 불변 규칙
- 공통 source of truth 위치
- 경로 helper 사용 의무
- 양쪽 adapter validation/test 명령

위키 ingest/query의 상세 워크플로우는 `AGENTS.md`에 중복하지 않는다.

### Phase 7 — 검증 및 배포

- [x] Codex plugin manifest validation
- [x] 각 skill metadata validation
- [ ] Claude plugin regression test
- [ ] Codex plugin install/uninstall/reinstall smoke test
- [ ] 새 Codex 세션에서 7개 namespaced skill 발견 확인
- [ ] fixture vault contract test
- [ ] migration rollback/retry test
- [ ] 배포 artifact에 symlink가 없고 모든 reference가 포함되었는지 확인

## 5. 테스트 매트릭스

| 시나리오 | Claude | Codex | 기대 결과 |
|---|---:|---:|---|
| `LLM_WIKI_ROOT` 미설정 | 필수 | 필수 | 즉시 중단, 설정 안내 |
| 신규 vault bootstrap | 필수 | 필수 | 동일 scaffold 생성 |
| 미수집 raw 탐지 | 필수 | 필수 | `sources` 역참조 기준 동일 목록 |
| 단일 source ingest | 필수 | 필수 | 동일 page 유형과 frontmatter |
| query | 필수 | 필수 | index 우선, wikilink 출처 포함 |
| lint read-only | 필수 | 필수 | 승인 전 파일 변경 없음 |
| flashcard 생성 | 필수 | 필수 | 동일 문법, 중복 없음 |
| schema migration | 필수 | 필수 | 동일 버전 및 migration log |
| vault escape 입력 | 필수 | 필수 | 거부 |
| Obsidian CLI 미실행 | 필수 | 필수 | 안전한 filesystem fallback |

## 6. 예상 위험과 대응

### Skill 이름 충돌

개별 skill 이름은 `save`, `lint`처럼 일반적이지만 설치 후에는 plugin namespace가 적용된 `llm-wiki:save`, `llm-wiki:lint`를 사용자 기준 이름으로 사용한다. 테스트에서는 namespace가 실제 selector에 표시되는지 반드시 확인한다.

### Prompt 중복 및 drift

Claude command와 Codex skill에 전체 workflow를 복사하지 않는다. 두 adapter는 공통 reference를 로드하고 호스트별 호출 방식만 정의한다.

### 병렬 ingest 충돌

개별 source 분석은 병렬화할 수 있지만 `index.md`, `overview.md`, `log.md`, meta 파일 갱신은 한 실행자가 병합한다.

### Plugin root 불확실성

호스트 환경변수를 만들거나 추정하지 않는다. 모든 helper script는 자신의 실제 파일 위치에서 plugin root를 계산한다.

### 배포 시 symlink 손실

개발 tree와 배포 artifact를 분리한다. release script가 `shared/`의 필요한 파일을 plugin package 내부에 복사하고 누락 여부를 검증한다.

## 7. 완료 정의

다음 조건을 모두 만족하면 Codex 포팅을 완료한 것으로 본다.

- Codex에서 7개 기능이 모두 `llm-wiki:<기능>` 이름으로 발견된다.
- Claude의 기존 `/llm-wiki:<기능>` 호출이 계속 동작한다.
- 두 adapter가 같은 공통 reference와 실행 스크립트를 사용한다.
- `${CLAUDE_PLUGIN_ROOT}` 또는 가상의 `${CODEX_PLUGIN_ROOT}` 의존이 없다.
- fixture vault contract test가 양쪽에서 통과한다.
- `raw/` 불변과 vault 경로 격리 테스트가 통과한다.
- 설치 및 환경설정 절차가 문서화되어 있다.

## 8. 권장 구현 단위

리뷰하기 쉬운 변경 단위는 다음과 같다.

1. `refactor: extract shared wiki core`
2. `refactor: make wiki path helpers host independent`
3. `feat: add Codex llm-wiki plugin manifest`
4. `feat: add llm-wiki wiki ingest and query skills`
5. `feat: add remaining llm-wiki skills`
6. `docs: add AGENTS and cross-host usage guide`
7. `test: add Claude and Codex contract tests`
