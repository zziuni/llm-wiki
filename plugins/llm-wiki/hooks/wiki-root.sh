#!/usr/bin/env bash
# wiki-root.sh — $LLM_WIKI_ROOT 기반 경로 해석 유틸리티
#
# Usage:
#   wiki-root.sh                                 → $LLM_WIKI_ROOT 출력
#   wiki-root.sh wiki/concepts/page.md           → 절대경로 출력
#   wiki-root.sh --ensure-dir wiki/concepts/     → 디렉토리 생성 + 경로 출력
#   wiki-root.sh --ensure-dir raw/ raw/assets/ wiki/concepts/ wiki/entities/ wiki/sources/ wiki/analyses/
#                                                → 여러 디렉토리 일괄 생성 (부트스트랩용)
set -euo pipefail

if [[ -z "${LLM_WIKI_ROOT:-}" ]]; then
  cat >&2 <<'MSG'
⚠ $LLM_WIKI_ROOT 환경변수가 설정되지 않았습니다.

셸 프로필(~/.zshrc 등)에 아래를 추가하세요:
  export LLM_WIKI_ROOT="$HOME/path/to/llm-wiki-data"

또는 현재 세션에서만 설정:
  ! export LLM_WIKI_ROOT="$HOME/path/to/llm-wiki-data"
MSG
  exit 1
fi

if [[ ! -d "$LLM_WIKI_ROOT" ]]; then
  echo "ERROR: \$LLM_WIKI_ROOT ($LLM_WIKI_ROOT) 디렉토리가 존재하지 않습니다" >&2
  exit 1
fi

# 인자 없으면 root만 출력
if [[ $# -eq 0 ]]; then
  echo "$LLM_WIKI_ROOT"
  exit 0
fi

# --ensure-dir: 디렉토리 생성 후 경로 출력 (복수 인자 지원)
if [[ "$1" == "--ensure-dir" ]]; then
  shift
  for rel in "$@"; do
    DIR="$LLM_WIKI_ROOT/$rel"
    mkdir -p "$DIR"
    echo "$DIR"
  done
  exit 0
fi

# 상대경로 → 절대경로 해석
echo "$LLM_WIKI_ROOT/$1"
