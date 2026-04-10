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

### 1. 디렉토리 구조 확인

`raw/`, `wiki/concepts/`, `wiki/entities/`, `wiki/sources/`, `wiki/analyses/` 존재 확인. 없으면 생성.

### 2. 핵심 파일 확인

`wiki/index.md`, `wiki/log.md`, `wiki/hot.md`, `wiki/overview.md` 존재 확인. 없으면 초기 내용으로 생성.

### 3. Obsidian CLI 연결 확인

`obsidian help` 실행. 실패하면 사용자에게 Obsidian 실행 및 CLI 활성화 안내.

### 4. 핫캐시 복원

`wiki/hot.md`를 읽어 이전 세션 컨텍스트 복원. 현재 focus, 미완료 작업, 최근 활동을 간략히 알려준다.

### 5. 위키 상태 리포트

- 총 페이지 수 (concepts, entities, sources, analyses 각각)
- 최근 수집 소스
- 미처리 raw/ 파일 목록
- `obsidian orphans` 결과 (고아 페이지 수)

### 6. CLAUDE.md 확인

schema가 현재 위키 구조와 일치하는지 확인.
