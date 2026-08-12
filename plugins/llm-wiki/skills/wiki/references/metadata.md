# Metadata Standard

## YAML Frontmatter Schema

모든 위키 페이지에 필수:

```yaml
---
type: concept | entity | source | analysis | overview | context | fact | catalog | architecture | decision | operation | draft
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

## 회사 컨텍스트 확장 필드

`wiki/company/<company>/` 문서는 기본 필드에 다음 필드를 추가한다. 배열 값은 문서의 실제 범위만 기록한다.

```yaml
company: musinsa
services: [mss, 29cm]
clients: [ios, android, web, cross-client]
domains: [client-architecture]
authority: canonical # canonical | derived | reference
owner_role: client-architecture-staff
confidentiality: internal # internal | restricted | public
review_after: YYYY-MM-DD
verified_at: YYYY-MM-DD # fact에 권장
```

| 필드 | 필수 | 설명 |
|------|------|------|
| `company` | Y | 디렉터리 `<company>`와 같은 회사 식별자 |
| `services` | N | 적용 서비스 범위 |
| `clients` | N | 적용 클라이언트 플랫폼 범위 |
| `domains` | N | 업무·아키텍처 도메인 |
| `authority` | Y | canonical(현재 기준), derived(분석/초안), reference(근거) |
| `owner_role` | N | 개인 이름보다 지속 가능한 관리 역할 |
| `confidentiality` | Y | 정보 공개 범위 |
| `review_after` | N | 변동 가능한 회사 정보의 재검토 예정일 |
| `verified_at` | N | 원자적 fact의 마지막 검증일 |

`fact`는 하나의 명확한 주장만 포함하고 `sources`와 `verified_at`을 기록한다. `draft`와 `proposed` 문서는 현재 사실처럼 인용하지 않는다.

## Status 라이프사이클

- `draft`: 초기 생성, 내용 불완전
- `active`: 완성된 페이지, 최신 상태
- `archived`: 더 이상 유효하지 않음 (대체됨, 폐기됨)
- `proposed`: 회사 컨텍스트에서 검토 중이며 아직 확정되지 않음
- `deprecated`: 회사 컨텍스트에서 더 이상 신규 적용하지 않음

## Lint 기준

- `status: active` + `updated` 90일 이상 → stale 경고
- `summary` 없음 → 쿼리 라우팅 불가 경고
- `type` 없음 → 인덱스 분류 불가 경고
- 회사 문서에 `company`, `authority`, `confidentiality` 없음 → 컨텍스트 신뢰 수준 판별 불가 경고
- `type: fact`인데 `sources` 또는 `verified_at` 없음 → 검증 불가능 경고
- `review_after`가 지난 canonical 회사 문서 → 재검토 경고
