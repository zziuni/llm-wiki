# Flashcard Convention

Obsidian Spaced Repetition 플러그인 호환. 위키 페이지 안에 인라인 삽입 (별도 카드 파일 없음).

## 섹션 형식

각 개념/엔티티 페이지 하단에 `## Flashcards` 섹션:

```markdown
## Flashcards
#flashcards

정의/사실 질문::답변

비교/관계 질문:::양방향 답변

복잡한 질문
여러 줄
?
복잡한 답변
여러 줄

핵심 문장에서 ==핵심 용어==를 빈칸으로 만든다.
```

## 카드 유형 선택 기준

| 유형 | 문법 | 용도 |
|------|------|------|
| 싱글라인 Q&A | `질문::답변` | 정의, 사실 |
| 양방향 | `질문:::답변` | 비교, 관계 |
| 멀티라인 | `질문\n?\n답변` | 복잡한 설명 |
| Cloze | `==용어==` | 핵심 용어 빈칸 채우기 |

## 규칙

- 페이지당 **3-7장** 적정
- 중복 카드 방지: 기존 카드 확인 후 추가
- 덱 구성: **폴더 기반** (`wiki/concepts/` → Concepts 덱, `wiki/entities/` → Entities 덱)
- `## Flashcards` 없는 active 개념/엔티티 페이지는 lint에서 경고
