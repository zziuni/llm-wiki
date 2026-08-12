---
description: 위키 부트스트랩 및 상태 확인
user_invocable: true
---

# /wiki — 위키 부트스트랩 & 상태

위키의 현재 상태를 확인하고, 필요시 초기 구조를 생성한다.

## 절차

### 0. 위키 Root 확인 (필수)

환경변수 `$LLM_WIKI_ROOT`로 위키 프로젝트 경로를 결정한다.

```bash
echo $LLM_WIKI_ROOT
```

- **설정됨**: 해당 경로를 위키 root로 사용. 이후 모든 경로는 이 root 기준.
- **미설정 → 즉시 중단**: 아래 메시지를 출력하고 동작을 멈춘다.

```
⚠ $LLM_WIKI_ROOT 환경변수가 설정되지 않았습니다.

셸 프로필(~/.zshrc 등)에 아래를 추가하세요:
  export LLM_WIKI_ROOT="$HOME/path/to/llm-wiki"

또는 현재 세션에서만 설정:
  ! export LLM_WIKI_ROOT="$HOME/path/to/llm-wiki"
```

위키 root가 확인되면 이후 모든 `raw/`, `wiki/` 경로는 해당 root 기준으로 절대경로를 사용한다.

### 0.5. Vault 부트스트랩 (신규 볼트 감지)

`$LLM_WIKI_ROOT/.obsidian/` 존재 여부를 확인한다.

- **존재함**: 이 단계를 건너뛴다.
- **존재하지 않음**: 신규 볼트로 판단하고 scaffold를 적용한다.

  1. `${CLAUDE_PLUGIN_ROOT}/scaffold/.obsidian/` 내용을 `$LLM_WIKI_ROOT/.obsidian/`로 복사
  2. `${CLAUDE_PLUGIN_ROOT}/scaffold/.gitignore`를 `$LLM_WIKI_ROOT/.gitignore`로 복사 (이미 있으면 건너뜀)
  3. 사용자에게 Obsidian 커뮤니티 플러그인 수동 설치를 안내:
     - dataview, templater-obsidian, obsidian-spaced-repetition, tag-wrangler, obsidian-auto-link-title, recent-files-obsidian
  4. 사용자에게 Obsidian에서 볼트를 열어달라고 안내

### 1. 디렉토리 구조 확인

`raw/`, `wiki/concepts/`, `wiki/entities/`, `wiki/sources/`, `wiki/analyses/`, `wiki/company/` 존재 확인. 없으면 생성. `wiki/company/`는 선택적 회사 컨텍스트의 상위 경계이며 특정 회사 디렉터리를 임의 생성하지 않는다.

### 2. 핵심 파일 확인

`wiki/index.md`, `wiki/log.md`, `wiki/hot.md`, `wiki/overview.md` 존재 확인. 없으면 초기 내용으로 생성.

`.llm-wiki-meta.json` 존재 확인. 없으면 `${CLAUDE_PLUGIN_ROOT}/schema.json`의 schemaVersion으로 생성:

```json
{
  "schemaVersion": <plugin의 schemaVersion>,
  "pluginVersion": "<plugin의 version>",
  "bootstrappedAt": "<오늘 날짜>",
  "lastMigration": null
}
```

### 3. Obsidian CLI 연결 확인

`obsidian help` 실행. 실패하면 사용자에게 Obsidian 실행 및 CLI 활성화 안내.

### 4. 핫캐시 복원

`wiki/hot.md`를 읽어 이전 세션 컨텍스트 복원. 현재 focus, 미완료 작업, 최근 활동을 간략히 알려준다.

### 5. 위키 상태 리포트

- 총 페이지 수 (concepts, entities, sources, analyses 각각)
- 회사 컨텍스트가 있으면 회사별 페이지 수와 canonical/draft/proposed 상태
- 최근 수집 소스
- 미처리 raw/ 파일 목록
- `obsidian orphans` 결과 (고아 페이지 수)

### 6. 스키마 정합성 확인

1. `${CLAUDE_PLUGIN_ROOT}/schema.json`에서 `schemaVersion` 읽기
2. `$LLM_WIKI_ROOT/.llm-wiki-meta.json`에서 현재 볼트 `schemaVersion` 읽기
   - 파일 없으면 schemaVersion = 0으로 간주
3. 버전이 일치하면 건너뜀
4. 볼트 버전 < 플러그인 버전이면:
   - `${CLAUDE_PLUGIN_ROOT}/scaffold/migrations/vN.md`를 순차적으로 읽기 (현재 볼트 버전 + 1 부터 플러그인 버전까지)
   - 각 마이그레이션의 절차를 실행
   - `.llm-wiki-meta.json`의 `schemaVersion`과 `lastMigration` 갱신
5. 사용자에게 마이그레이션 결과 리포트
