# Wiki Conventions

## 페이지 구조

모든 위키 페이지는 다음 순서로 구성:

```markdown
---
(YAML frontmatter)
---

# 페이지 제목

본문 내용...

## Related
- [[관련페이지1]]
- [[관련페이지2]]

## Flashcards
#flashcards

카드들...
```

## 위키링크

- 형식: `[[파일명]]` (shortest path)
- 표시 텍스트 변경: `[[파일명|표시할 텍스트]]`
- 제목 링크: `[[파일명#섹션]]`
- 모든 개념, 엔티티, 소스 언급 시 위키링크 사용

## 콜아웃 (Callout)

Obsidian 콜아웃으로 특수 정보 표시:

```markdown
> [!info] 핵심 발견
> 중요한 발견사항

> [!warning] 모순
> 기존 [[페이지]]와 모순되는 내용. 소스 [[sources/A]]는 X라고 하지만, [[sources/B]]는 Y라고 한다.

> [!question] 미해결 질문
> 추가 조사가 필요한 질문

> [!tip] 연결
> 다른 영역과의 흥미로운 연결점
```

## 파일명 규칙

- 소문자, 하이픈 구분: `machine-learning.md`, `andrej-karpathy.md`
- 한글 허용: `자기주의-메커니즘.md`
- 공백 대신 하이픈
- 너무 길지 않게 (50자 이하)

### 디렉토리별 네이밍 (충돌 방지)

Obsidian은 shortest path로 wikilink를 해석하므로, **서브디렉토리가 달라도 base filename이 같으면 링크가 모호해진다.** 이를 방지하기 위해 디렉토리별 네이밍 기준을 다르게 한다:

| 디렉토리 | 네이밍 기준 | 예시 |
|----------|-----------|------|
| `concepts/` | 개념 이름 | `compound-component-pattern.md` |
| `entities/` | 인물/조직 이름 | `junio-hamano.md` |
| `sources/` | **출처-주제** | `corca-compound-component.md` |
| `analyses/` | 질문/분석 주제 | `monorepo-vs-polyrepo.md` |
| `company/<company>/` | 회사 범위 안에서 충돌하지 않는 역할별 이름 | `29cm-web-deployment.md` |

**핵심 규칙**: `sources/` 파일명은 반드시 출처(저자, 사이트, 조직)를 포함하여 `concepts/`와 충돌을 방지한다.
회사 하위에서도 `overview.md`, `index.md` 외에는 서비스 또는 대상을 드러내는 이름을 사용해 전역 wikilink 충돌을 줄인다.

## 소스 인용

본문에서 소스를 인용할 때:
```markdown
According to [[sources/paper-name]], "직접 인용" (p.42).
```

## 운영 규칙

- **로그 형식**: `## [YYYY-MM-DD] verb | Title` — grep 파서블
- **이미지/첨부**: `raw/assets/`에 저장 (Obsidian `attachmentFolderPath` 설정과 일치)
- **`wiki/hot.md`**: gitignored — 없으면 새로 생성. 세션 시작 시 읽고, 종료 시 갱신
- **Obsidian CLI fallback**: CLI 실패 시 (앱 미실행 등) Read/Write/Edit tool로 fallback
