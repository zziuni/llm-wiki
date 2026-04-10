---
title: "mcp-atlassian fakeredis 호환성 버그 해결"
type: analysis
created: 2026-04-10
tags: [mcp, atlassian, fakeredis, pydocket, bug-fix, devtools]
related: ["[[codebase-improvement-roadmap]]"]
---

# mcp-atlassian fakeredis 호환성 버그 해결

## 증상

Claude Code에서 Atlassian MCP 연결 실패: `Failed to reconnect to atlassian`

## 원인

`mcp-atlassian` (모든 버전) → `fastmcp ≥2.13` → `pydocket ≥0.17.2` → `fakeredis ≥2.32` 의존성 체인에서,
`fakeredis 2.32+`가 `FakeConnection`을 `FakeAsyncRedisConnection`으로 rename함.

```
ImportError: cannot import name 'FakeConnection' from 'fakeredis.aioredis'
```

관련 이슈: https://github.com/sooperset/mcp-atlassian/issues/868

## 해결 방법

`docket/_redis.py`의 import를 패치:

```bash
find ~/.cache/uv/archive-v0 -name "_redis.py" -path "*/docket/*" \
  -exec sed -i '' 's/from fakeredis.aioredis import FakeConnection, FakeServer/from fakeredis.aioredis import FakeAsyncRedisConnection as FakeConnection, FakeServer/' {} \;
```

**주의:** `uv cache clean` 후 재설치하면 패치가 날아감. 재패치 필요.

## Atlassian 도메인 구조 (무신사)

| 용도 | URL | 비고 |
|------|-----|------|
| Jira (커스텀) | jira.team.musinsa.com | CNAME → saas.atlassian.com |
| Confluence (커스텀) | wiki.team.musinsa.com | CNAME → saas.atlassian.com |
| Cloud (실제) | musinsa-oneteam.atlassian.net | MCP 설정에서 사용 |
| Cloud (미사용) | 29cm.atlassian.net | SUSPENDED_PAYMENT 상태 |

- MCP 설정(`claude.json`)은 `musinsa-oneteam.atlassian.net` 사용
- `.env`(confluence-publisher)도 `musinsa-oneteam.atlassian.net/wiki`로 맞춰야 함
- `id.atlassian.com`에서 발급한 API 토큰(ATATT3...)은 Cloud 전용

## 테스트 스크립트

`scripts/test-mcp-atlassian.py` — MCP stdio 프로토콜로 직접 JSON-RPC 통신 테스트
