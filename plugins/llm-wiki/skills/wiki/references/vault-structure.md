# Vault Structure

## 아키텍처 (Three Layers)

1. **Raw sources** (`raw/`) — 불변 원본 소스. LLM은 읽기만 하고 절대 수정하지 않는다.
2. **Wiki** (`wiki/`) — LLM이 소유하는 마크다운 위키. 요약, 엔티티, 개념, 분석 페이지.
3. **Schema** (이 플러그인의 skill + references) — LLM 행동 규칙, 컨벤션, 워크플로우 정의.

## 디렉토리 구조

```
(vault root = $LLM_WIKI_ROOT)
├── raw/                ← 사용자 영역: 소스 추가 (Web Clipper, 드래그&드롭). LLM은 읽기만.
│   └── assets/         ← 이미지, PDF 등 첨부파일
├── wiki/               ← LLM 영역: LLM이 작성/유지. 사용자는 Obsidian에서 브라우징.
│   ├── index.md        ← 마스터 카탈로그 (쿼리 시 첫 번째로 읽기)
│   ├── log.md          ← 시간순 작업 기록 (append-only)
│   ├── hot.md          ← 핫캐시 (세션 간 컨텍스트 이월)
│   ├── overview.md     ← 위키 전체 합성 요약
│   ├── concepts/       ← 개념 페이지
│   ├── entities/       ← 엔티티 페이지 (인물, 조직 등)
│   ├── sources/        ← 소스별 요약 페이지
│   ├── analyses/       ← 회사와 무관한 쿼리 결과 중 가치 있는 것 저장
│   └── company/        ← 회사별 업무 컨텍스트 (선택 구조)
│       ├── index.md    ← 회사 컨텍스트 카탈로그
│       └── <company>/  ← 회사 단위 격리 경계 (예: musinsa/)
├── .obsidian/          ← vault 설정 (플러그인 scaffold로 초기화 가능)
└── .llm-wiki-meta.json ← 스키마 버전 메타
```

## Key Files

- **`wiki/index.md`** — 전체 페이지 카탈로그. 쿼리 시 반드시 첫 번째로 읽는다.
- **`wiki/log.md`** — Append-only 작업 기록. 형식: `## [YYYY-MM-DD] verb | Title` — grep 파서블.
- **`wiki/hot.md`** — 세션 간 컨텍스트 캐시. 세션 시작 시 읽고, 종료 시 갱신. gitignored — 없으면 새로 생성.
- **`wiki/overview.md`** — 위키 전체 합성 요약. 소스 축적에 따라 진화.
- **`.llm-wiki-meta.json`** — 스키마 버전 추적. `/wiki` 커맨드가 플러그인 schemaVersion과 비교하여 마이그레이션 판단.
- **`wiki/company/index.md`** — 회사별 업무 컨텍스트가 존재할 때의 진입점. 회사 질의는 해당 회사의 `index.md`를 추가로 읽는다.
- **`AGENTS.md`** — vault별 회사명·역할·서비스 범위와 로컬 규칙의 SSOT. 존재하면 플러그인의 일반 규칙보다 구체적인 지침으로 적용한다.

## 회사별 확장 구조

`wiki/company/`는 특정 회사에 종속되지 않는다. 각 회사는 `wiki/company/<company>/` 아래 독립적으로 보존하며, 이직 후 다른 회사를 추가해도 기존 컨텍스트를 재구성하지 않는다. 세부 구조와 배치 기준은 `company-context.md`를 따른다.

## Obsidian Vault 설정

`$LLM_WIKI_ROOT` = Obsidian vault root. `.obsidian/`이 vault root에 위치.

- `raw/` — **사용자 영역**: Obsidian에서 소스 추가 (Web Clipper, 드래그&드롭)
- `wiki/` — **LLM 영역**: LLM이 작성/유지. 사용자는 Obsidian에서 브라우징
- dev 파일 (`.claude`, `.gitignore`, `.llm-wiki-meta.json` 등)은 `userIgnoreFilters`로 Obsidian에서 숨김 처리
