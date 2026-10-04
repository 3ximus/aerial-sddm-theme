#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <input-playlist> <output-playlist>" >&2
  exit 1
fi

input="$1"
output="$2"

if [ ! -f "$input" ]; then
  echo "Input playlist not found: $input" >&2
  exit 1
fi

: > "$output"

while IFS= read -r line || [ -n "$line" ]; do
  line="${line%$'\r'}"
  [ -z "${line//[[:space:]]/}" ] && continue
  [[ "$line" =~ ^# ]] && continue

  if [[ "$line" =~ ^https?:// ]]; then
    if curl -fsSL --max-time 15 --head "$line" >/dev/null 2>&1; then
      printf '%s\n' "$line" >> "$output"
    fi
  else
    p="${line#./}"
    if [ -f "$p" ] || [ -f "$PWD/$p" ]; then
      printf '%s\n' "$line" >> "$output"
    fi
  fi
done < "$input"

echo "Wrote valid entries to $output"
