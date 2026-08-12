# Company Context

## 목적과 경계

회사에서만 유효한 조직·서비스·아키텍처·소유권·운영 사실과 게시 문서를 일반 기술 지식에서 분리한다.

- 일반 원리와 재사용 가능한 기술 지식 → `wiki/concepts/`, `wiki/analyses/`, `wiki/playbooks/`, `wiki/sources/`
- 특정 회사에서만 유효한 정보 → `wiki/company/<company>/`
- 현재 vault가 별도 구조를 정의하면 root `AGENTS.md`를 SSOT로 따른다.
- 현재 대표 vault는 `wiki/company/musinsa/` 아래에서 MSS와 29CM의 iOS·Android·Web Client Architecture를 관리한다.

## 권장 구조

```text
wiki/company/<company>/
├── index.md                 회사 컨텍스트 진입점
├── context/                 조직·역할·서비스 지도·용어·소유권
├── architecture/
│   ├── shared/              서비스 공통 아키텍처
│   └── <service>/           서비스별 구조
├── catalog/                 앱·저장소·라이브러리·API·파이프라인
├── facts/                   질의용 원자적이고 검증된 사실
├── decisions/
│   ├── adr/                 확정된 결정
│   └── proposals/           검토 중인 제안
├── analyses/                회사 시스템의 조사·진단·로드맵
├── operations/              배포·릴리스·장애·거버넌스 절차
├── drafts/                  inbox → working → review → ready
├── publications/            게시 URL·버전·게시일
└── sources/                 Confluence·Jira·GitHub·회의 등 내부 근거
```

폴더는 문서 역할과 생명주기를 나타낸다. 회사·서비스·클라이언트 범위는 frontmatter에도 명시한다. 모든 회사에 빈 전체 트리를 강제하지 않고 실제 필요가 생긴 디렉터리만 생성한다.

## 배치 결정

| 질문 | 위치 |
|---|---|
| 회사 밖에서도 그대로 유효한가? | 일반 `wiki/` 영역 |
| 특정 회사의 조직·서비스·현재 구조인가? | `company/<company>/context` 또는 `architecture` |
| 하나의 검증된 주장인가? | `company/<company>/facts` |
| 앱·저장소·API 등 식별 가능한 대상인가? | `company/<company>/catalog` |
| 확정된 결정 또는 검토 중 제안인가? | `company/<company>/decisions` |
| 진단·비교·로드맵인가? | `company/<company>/analyses` |
| 현재 실행 기준인 절차인가? | `company/<company>/operations` |
| 게시 전 문서인가? | `company/<company>/drafts` |
| 내부 원문과 판단 근거인가? | `company/<company>/sources` |

일반 개념은 중복 설명하지 않고 회사 문서에서 wikilink로 조합한다.

## Query 라우팅과 신뢰 수준

회사·조직·서비스·내부 아키텍처·배포·소유권이 질문에 포함되면 다음 순서로 탐색한다.

1. `wiki/index.md`
2. `wiki/company/index.md`
3. 해당 `wiki/company/<company>/index.md`
4. 검색 결과와 backlinks
5. 연결된 내부 `sources/`와 일반 `concepts/`

충돌 시 `authority: canonical` + `status: active` + 최신 `verified_at/updated` 문서를 우선한다. `draft`, `proposed`, `derived`, `reference`는 그 상태를 답변에 명시한다. `confidentiality`를 유지하고 내부 정보를 외부 게시용 답변에 자동 포함하지 않는다.

## 저장과 게시 생명주기

회사 관련 대화 저장은 일반 `wiki/analyses/`로 보내지 않고 의미에 맞는 회사 하위 디렉터리를 선택한다. 회사가 불명확하면 root `AGENTS.md`, 기존 company index, 대화 순서로 판별하며 안전하게 판별할 수 없을 때만 사용자에게 확인한다.

```text
sources/facts → drafts/inbox → drafts/working → drafts/review → drafts/ready
                                                            ↓ 게시
                                                    publications/index.md
                                                            ↓
                                  architecture/decisions/operations/facts 갱신
```

게시된 초안을 곧바로 canonical 사실로 간주하지 않는다. 게시 결과에 따라 공식 문서를 별도로 갱신한다.
