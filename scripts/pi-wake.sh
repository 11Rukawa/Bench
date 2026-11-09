#!/usr/bin/env bash
# Usage: pi-wake.sh SESSION_ID MESSAGE
# Run one turn of a pi session headlessly and print its answer; the room posts
# it back as that seat. Hand pi the session file path: sessions are grouped by
# working directory, and a bare id only finds the current directory's one.
set -euo pipefail

session="${1:?缺少 session id}"
shift
[[ "$session" =~ ^[A-Za-z0-9._-]+$ ]] || { echo "session id 不对：$session" >&2; exit 2; }

bin="$(command -v pi || true)"
[[ -n "$bin" ]] || bin="$HOME/.pi/agent/bin/pi"
[[ -x "$bin" ]] || { echo "找不到 pi 可执行文件" >&2; exit 127; }

file="$(ls "$HOME"/.pi/agent/sessions/*/*_"$session".jsonl 2>/dev/null | head -1 || true)"
if [[ -z "$file" ]]; then
  echo "找不到 pi 会话 $session" >&2
  exit 2
fi
# Windows 上 pi 是 node 程序，路径要换成 Windows 写法。
if command -v cygpath >/dev/null 2>&1; then
  file="$(cygpath -w "$file")"
fi

# 这一轮新起的 bench MCP 进程靠 BENCH_UUID 认回这个会话。
export BENCH_UUID="$session"
exec "$bin" --session "$file" --print "$@"
