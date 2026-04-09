---
name: wiki
description: 위키 부트스트랩 및 상태 확인
user_invocable: true
---

# /wiki — 위키 부트스트랩 & 상태

위키의 현재 상태를 확인하고, 필요시 초기 구조를 생성한다.

## 절차

1. **디렉토리 구조 확인**: `raw/`, `wiki/concepts/`, `wiki/entities/`, `wiki/sources/`, `wiki/analyses/` 존재 확인. 없으면 생성.

2. **핵심 파일 확인**: `wiki/index.md`, `wiki/log.md`, `wiki/hot.md`, `wiki/overview.md` 존재 확인. 없으면 초기 내용으로 생성.

3. **Obsidian CLI 연결 확인**: `obsidian help` 실행. 실패하면 사용자에게 Obsidian 실행 및 CLI 활성화 안내.

4. **핫캐시 복원**: `wiki/hot.md`를 읽어 이전 세션 컨텍스트 복원. 현재 focus, 미완료 작업, 최근 활동을 간략히 알려준다.

5. **위키 상태 리포트**:
   - 총 페이지 수 (concepts, entities, sources, analyses 각각)
   - 최근 수집 소스
   - 미처리 raw/ 파일 목록
   - `obsidian orphans` 결과 (고아 페이지 수)

6. **CLAUDE.md 확인**: schema가 현재 위키 구조와 일치하는지 확인.
