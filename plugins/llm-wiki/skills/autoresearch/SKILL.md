---
name: autoresearch
description: 주제의 위키 지식 공백을 찾고 웹 검색, source 수집, 합성을 반복해 Obsidian LLM Wiki를 확장한다. 사용자가 자율 연구, deep research, 반복 조사 또는 특정 주제의 위키 확장을 요청할 때 사용한다.
---

# Autoresearch for LLM Wiki

1. `../wiki/SKILL.md`와 모든 wiki reference를 읽고 ingest workflow를 따른다.
2. 경로 가드 후 기존 위키에서 주제의 현재 지식과 공백을 파악한다.
3. 기본 최대 5라운드로 계획하고 웹 접근, 범위, 중단 조건을 사용자에게 알린다.
4. 각 라운드에서 공백 식별 → 웹 검색 → 출처 평가 → ingest → 관련 합성 갱신을 수행한다.
5. 라운드마다 출처와 변경 파일을 보고하고 사용자의 방향 전환을 반영한다.
6. 완료 시 수집 출처, 생성/갱신 페이지, 남은 공백을 보고하고 `wiki/log.md`에 기록한다.
