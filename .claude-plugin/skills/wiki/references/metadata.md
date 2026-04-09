# Metadata Standard

## YAML Frontmatter Schema

모든 위키 페이지에 필수:

```yaml
---
type: concept | entity | source | analysis | overview
summary: "50-100자 요약"
tags:
  - tag1
  - tag2
sources:
  - "[[sources/원본파일명]]"
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: active | draft | archived
---
```

## 필드 설명

| 필드 | 필수 | 설명 |
|------|------|------|
| `type` | Y | 페이지 유형. index 카테고리 결정 |
| `summary` | Y | 쿼리 라우팅용 한줄 요약 |
| `tags` | N | 보조 검색/분류 |
| `sources` | N | 이 페이지의 근거 소스 |
| `created` | Y | 최초 생성일 |
| `updated` | Y | 최종 갱신일. 내용 변경 시 갱신 |
| `status` | Y | 라이프사이클 |

## Status 라이프사이클

- `draft`: 초기 생성, 내용 불완전
- `active`: 완성된 페이지, 최신 상태
- `archived`: 더 이상 유효하지 않음 (대체됨, 폐기됨)

## Lint 기준

- `status: active` + `updated` 90일 이상 → stale 경고
- `summary` 없음 → 쿼리 라우팅 불가 경고
- `type` 없음 → 인덱스 분류 불가 경고
