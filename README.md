# LLM Wiki

Claude Code와 Codex가 Obsidian vault를 점진적으로 구축하고 유지하도록 하는 플러그인이다. 플러그인 소스와 실제 위키 데이터는 분리하며, vault 위치는 `$LLM_WIKI_ROOT`로 지정한다.

## Codex 설정

Codex CLI 0.147.0 이상을 기준으로 한다.

```bash
codex plugin marketplace add /absolute/path/to/llm-wiki
codex plugin add llm-wiki@llm-wiki-marketplace
```

설치 여부를 확인한다.

```bash
codex plugin marketplace list
codex plugin list --marketplace llm-wiki-marketplace
```

vault 경로를 설정한 뒤 새 Codex 세션을 시작한다.

```bash
export LLM_WIKI_ROOT="/absolute/path/to/wiki-vault"
codex
```

Codex에서는 plugin namespace가 붙은 다음 skills를 사용한다.

- `llm-wiki:wiki`
- `llm-wiki:ingest`
- `llm-wiki:query`
- `llm-wiki:lint`
- `llm-wiki:flashcard`
- `llm-wiki:save`
- `llm-wiki:autoresearch`

plugin 변경을 다시 로드하려면 marketplace가 Git source인 경우 먼저 갱신한 뒤 재설치하고 새 세션을 시작한다.

```bash
codex plugin marketplace upgrade llm-wiki-marketplace
codex plugin remove llm-wiki@llm-wiki-marketplace
codex plugin add llm-wiki@llm-wiki-marketplace
```

로컬 marketplace는 현재 작업 파일을 사용하므로 `upgrade`가 필요하지 않다. 캐시된 plugin을 갱신하려면 version cachebuster를 변경한 뒤 다시 `plugin add`하고 새 세션을 시작한다.

## Claude Code 설정

기존 `.claude-plugin/marketplace.json`을 marketplace로 등록하고 `llm-wiki` plugin을 설치한다. 명령은 `/llm-wiki:wiki`, `/llm-wiki:ingest`와 같은 namespace로 제공된다.

## Repository instructions

공통 저장소 지침은 `AGENTS.md`에 있다. Claude Code 호환성을 위해 `CLAUDE.md`는 `AGENTS.md`를 가리키는 심볼릭 링크다.
