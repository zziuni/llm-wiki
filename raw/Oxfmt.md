---
title: "Oxfmt"
source: "https://oxc.rs/docs/guide/usage/formatter.html"
author:
published:
created: 2026-04-09
description: "A collection of high-performance JavaScript tools written in Rust"
tags:
  - "clippings"
---
## Oxfmt

Oxfmt (`/oʊ-ɛks-fɔːr-mæt/`) is a high-performance formatter for the JavaScript ecosystem.

## Supported languages

Support includes JavaScript, JSX, TypeScript, TSX, JSON, JSONC, JSON5, YAML, TOML, HTML, Angular, Vue, CSS, SCSS, Less, Markdown, MDX, GraphQL, Ember, Handlebars, and more.

See the [compatibility matrix](https://oxc.rs/compatibility) for detailed framework and file type support.

## Built for scale

Oxfmt targets large codebases and CI environments, with an emphasis on high throughput and predictable performance.

It is built on the Oxc compiler stack and avoids architectural bottlenecks common in existing formatter implementations.

Our [benchmarks](https://github.com/oxc-project/bench-formatter) show Oxfmt to be approximately 30x faster than Prettier and 2x faster than Biome.

## Batteries included

Oxfmt includes built-in features that typically require external Prettier plugins:

- [Import sorting](https://oxc.rs/docs/guide/usage/formatter/sorting#sort-imports)
- [Tailwind CSS class sorting](https://oxc.rs/docs/guide/usage/formatter/sorting#tailwind-css-class-sorting)
- [package.json field sorting](https://oxc.rs/docs/guide/usage/formatter/sorting#sort-package-json-fields)
- [Embedded formatting](https://oxc.rs/docs/guide/usage/formatter/embedded-formatting) (CSS-in-JS, GraphQL, etc.)

## Prettier-compatible

Oxfmt integrates into existing Prettier-based workflows.

The Oxfmt CLI follows Prettier's conventions closely enough that most scripts and tooling require little or no modification, though some defaults and CLI options differ.

Oxfmt matches Prettier’s JavaScript formatting. When migrating from recent versions of Prettier, formatting differences should not occur; any formatting differences are considered bugs.

Oxfmt now passes 100% of Prettier's JavaScript and TypeScript conformance tests. For any remaining formatting inconsistencies, we have [reported them to the Prettier team](https://github.com/oxc-project/oxc/issues/18717) and are collaborating to converge on expected behavior.

No additional dependencies or configuration needed.

## Getting started

Install `oxfmt` as a dev dependency:

```sh
shpnpm add -D oxfmt
```

Add scripts to `package.json`:

```json
json{
  "scripts": {
    "fmt": "oxfmt",
    "fmt:check": "oxfmt --check"
  }
}
```

Format files:

```sh
shpnpm run fmt
```

Check formatting without writing files:

```sh
shpnpm run fmt:check
```