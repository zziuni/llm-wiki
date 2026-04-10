---
type: concept
summary: "Oxc 컴파일러 스택 기반 고성능 JavaScript 포매터. Prettier 대비 ~30배, Biome 대비 ~2배 빠르며, 포매터 전용 도구"
tags:
  - oxfmt
  - formatter
  - rust
  - oxc
  - toolchain
sources:
  - "[[sources/oxfmt-official-docs]]"
created: 2026-04-09
updated: 2026-04-09
status: active
---

# Oxfmt

Oxc 컴파일러 스택 기반의 고성능 JavaScript/TypeScript 포매터. Rust로 작성되었으며, **포매터에 특화**된 단일 목적 도구.

## 핵심 특징

- **성능**: Prettier 대비 ~30배, [[biome]] 대비 ~2배 빠름
- **호환성**: Prettier JS/TS 호환 테스트 100% 통과. CLI도 Prettier 컨벤션을 따라 마이그레이션 비용 최소화
- **내장 기능**: Import sorting, Tailwind CSS class sorting, package.json field sorting, embedded formatting — 모두 플러그인 없이 기본 제공
- **지원 언어**: JS, JSX, TS, TSX, JSON, YAML, TOML, HTML, Vue, CSS, SCSS, Markdown, GraphQL 등

## Biome과 비교

| 비교 항목 | Oxfmt | [[biome]] |
|---|---|---|
| 범위 | 포매터 전용 | 포매터 + 린터 통합 |
| 기반 | Oxc 컴파일러 스택 | 자체 파서 |
| Prettier 대비 속도 | ~30배 | ~35배 (공식 벤치마크) |
| 상대 속도 | Biome 대비 ~2배 빠름 | — |
| Prettier 호환 | 100% JS/TS 테스트 통과 | 97% 호환 |
| 린팅 | 미지원 (별도 린터 필요) | 464개 규칙 내장 |

> [!info] 포지셔닝 차이
> Biome은 "하나의 도구로 린트+포맷"을 추구하고, Oxfmt는 "포매팅 하나를 극한까지 빠르게"를 추구한다. 린터가 필요하면 Oxfmt + oxlint 조합으로 사용.

## 사용법

```bash
pnpm add -D oxfmt
```

```json
{
  "scripts": {
    "fmt": "oxfmt",
    "fmt:check": "oxfmt --check"
  }
}
```

## Related

- [[biome]] — 경쟁 도구 (포매터+린터 통합)
- [[monorepo-dx]] — 대규모 코드베이스 포매팅 성능이 DX에 미치는 영향
- [[sources/oxfmt-official-docs]] — 원본 소스

## Flashcards
#flashcards

Oxfmt는 어떤 컴파일러 스택 기반인가?::Oxc (Rust 기반 JavaScript 컴파일러 스택)

Oxfmt의 Prettier/Biome 대비 속도::Prettier 대비 ==~30배==, Biome 대비 ==~2배== 빠름

Oxfmt과 Biome의 핵심 포지셔닝 차이:::Oxfmt은 포매터 전용 (린터 미포함), Biome은 포매터+린터 통합

Oxfmt가 플러그인 없이 내장 제공하는 기능 3가지는?::Import sorting, Tailwind CSS class sorting, embedded formatting (CSS-in-JS, GraphQL)
