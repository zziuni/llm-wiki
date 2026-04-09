# Obsidian CLI Reference

Obsidian CLI (v1.12+) 명령어 레퍼런스. 직접 파일 I/O보다 CLI 우선 사용.

## 전제 조건
- Obsidian 데스크톱 앱 실행 중
- Settings → Core Plugins → CLI 활성화
- CLI 경로 등록 완료

## 파일 작업

```bash
obsidian files                              # 전체 파일 목록
obsidian read file="wiki/concepts/name"     # 파일 읽기
obsidian create name="wiki/concepts/new" content="..."  # 생성
obsidian append file="wiki/log" content="..." # 끝에 추가
obsidian prepend file="name" content="..."  # frontmatter 뒤에 삽입
obsidian move file="old" to="new/"          # 이동 (위키링크 자동 갱신)
obsidian delete file="name"                 # 휴지통으로 이동
```

## 속성/Frontmatter

```bash
obsidian properties file="name"                          # 속성 확인
obsidian property:set file="name" name="updated" value="2026-04-09"
obsidian property:remove file="name" name="old-field"
```

## 검색

```bash
obsidian search query="키워드" format=json        # 전체 텍스트 검색
obsidian search:context query="키워드" limit=10   # 컨텍스트 포함
```

## 링크 분석

```bash
obsidian links file="name"      # 발신 링크
obsidian backlinks file="name"  # 수신 링크 (역링크)
obsidian unresolved             # 깨진 링크 (대상 없음)
obsidian orphans                # 고아 페이지 (링크 없음)
```

## 태그

```bash
obsidian tags                       # 전체 태그 목록
obsidian tag tag="#flashcard"       # 특정 태그의 파일 목록
obsidian tags:rename old=x new=y   # 태그 일괄 변경
```

## 일일 노트

```bash
obsidian daily              # 오늘 일일 노트 열기/생성
obsidian daily:append content="- [ ] 할일"
obsidian daily:read         # 오늘 노트 읽기
```

## 출력 형식

```bash
format=json   # JSON (jq 파이핑용)
format=csv    # CSV
format=md     # 마크다운
format=paths  # 파일 경로만
format=text   # 기본 텍스트
```

## 멀티 볼트

```bash
obsidian search query="..." vault="VaultName"  # 특정 볼트 지정
```
