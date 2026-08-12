---
name: wiki
description: Obsidian LLM Wiki를 부트스트랩하고 상태, 경로, schema migration을 관리하는 핵심 오케스트레이션이다. 사용자가 wiki 초기화, 상태 확인, vault 설정 또는 schema migration을 요청할 때 사용한다. 다른 llm-wiki skills의 공통 규칙도 제공한다.
---

# Wiki Orchestration Skill

이 스킬은 Karpathy LLM Wiki 패턴의 핵심 로직을 정의한다. 모든 위키 커맨드(/ingest, /query, /lint, /flashcard, /save, /autoresearch)가 이 스킬의 규칙을 따른다.

## 경로 규칙 (Path Resolution)

두 가지 경로 기준이 있다:

- **`$LLM_WIKI_ROOT`** — vault(데이터) 경로. 모든 `raw/`, `wiki/` 경로의 기준.
- **Plugin root** — 현재 `SKILL.md`에서 두 단계 위인 `plugins/llm-wiki/`. scaffold, schema, helper script 등 플러그인 리소스의 기준.

### Vault 경로

모든 위키 경로(`raw/`, `wiki/`)는 **`$LLM_WIKI_ROOT`** 환경변수 기준으로 해석한다.

- **설정됨**: `$LLM_WIKI_ROOT/wiki/index.md`, `$LLM_WIKI_ROOT/raw/` 등 절대경로 사용
- **미설정 → 즉시 중단**: 환경변수가 없으면 플러그인의 모든 동작을 중단하고, 설정 방법을 안내한다

### 가드 절차 (MANDATORY — 모든 커맨드 진입 시 최우선)

**위키 경로 해석은 반드시 `wiki-root.sh` 스크립트를 통한다.** 직접 경로를 구성하지 않는다.

1. 커맨드 진입 시 아래를 실행하여 위키 root를 확인한다:

```bash
PLUGIN_ROOT="<현재 SKILL.md에서 두 단계 위의 절대경로>"
ROOT=$(bash "$PLUGIN_ROOT/hooks/wiki-root.sh")
```

- 성공 → `$ROOT`를 이후 모든 경로의 base로 사용 (예: `$ROOT/wiki/index.md`)
- 실패 → 스크립트가 에러를 출력하고 종료. **즉시 동작 중단.**

2. 경로 해석이 필요할 때:

```bash
# 파일 경로 해석
bash "$PLUGIN_ROOT/hooks/wiki-root.sh" wiki/concepts/page.md
# → /absolute/path/to/wiki/concepts/page.md

# 디렉토리 생성 (mkdir 직접 사용 금지)
bash "$PLUGIN_ROOT/hooks/wiki-root.sh" --ensure-dir wiki/concepts/
# → 복수 인자 가능: --ensure-dir raw/ wiki/concepts/ wiki/entities/
```

> **금지**: `mkdir -p wiki/...`, `Write wiki/...` 같은 CWD 기준 상대경로 직접 사용
> **필수**: 항상 `wiki-root.sh`가 반환한 절대경로 사용
> **CWD fallback 없음**: 환경변수 없이 CWD를 root로 추론하지 않는다. 다른 프로젝트에서 호출 시 엉뚱한 디렉토리에 파일을 쓰는 사고를 방지하기 위함.

## 핵심 원칙

1. **raw/ 불변**: 원본 소스는 절대 수정하지 않는다
2. **wiki/ LLM 소유**: 위키 페이지는 LLM이 작성하고 유지한다
3. **index.md 우선**: 쿼리 시 항상 index.md를 먼저 읽는다
4. **Obsidian CLI 우선**: 파일 직접 조작보다 CLI 명령 우선
5. **로깅 필수**: 모든 작업을 log.md에 기록한다
6. **플래시카드 동반**: 수집 시 개념/엔티티 페이지에 플래시카드를 함께 생성한다
7. **핫캐시 유지**: 세션 시작/종료 시 hot.md를 읽고/갱신한다
8. **스키마 정합성**: /wiki 실행 시 vault 스키마 버전을 확인하고 필요시 마이그레이션한다

## 참조 문서

상세 규칙은 references/ 하위 파일을 참조:
- `vault-structure.md`: 아키텍처, 디렉토리 구조, Key Files
- `conventions.md`: 페이지 형식, 위키링크, 콜아웃, 운영 규칙
- `metadata.md`: frontmatter 스키마
- `flashcard.md`: 플래시카드 컨벤션 (카드 타입, 덱 구성)
- `obsidian-cli.md`: CLI 명령어 레퍼런스
- `workflows.md`: ingest/query/lint/부트스트랩 상세 절차

작업에 해당하는 reference만 선택하지 말고, 선택한 파일은 끝까지 읽는다. 부트스트랩과 schema migration에는 `vault-structure.md`, `conventions.md`, `workflows.md`, `obsidian-cli.md`를 읽는다.
