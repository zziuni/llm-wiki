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
#flashcard

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

## 소스 인용

본문에서 소스를 인용할 때:
```markdown
According to [[sources/paper-name]], "직접 인용" (p.42).
```
