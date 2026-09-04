#!/usr/bin/env bash
# Build every presio deck in this repo to PDF, validate its sidecars against
# presio's own checker (POST /api/check), and open each one in the viewer.
#
#   scripts/presio-check.sh                 build + check + present everything
#   scripts/presio-check.sh --check-only    build + check only, no browser
#   scripts/presio-check.sh visual          only decks whose name matches "visual"
#
# Decks: scripts/visual-check.typ (the one worth eyeballing — every slide draws
# a red box the video overlay must land exactly on), every tests/*/test.typ, and
# every examples/*/example.typ. PDFs are written to build/presio/.
set -uo pipefail

cd "$(dirname "$0")/.."

OUT=build/presio
API=https://presio.xyz
HERE=scripts
PRESENT=1
FILTER=""

for arg in "$@"; do
  case "$arg" in
    --check-only) PRESENT=0 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) FILTER="$arg" ;;
  esac
done

mkdir -p "$OUT"

# name<TAB>source, most interesting first
sources() {
  printf 'visual-check\t%s/visual-check.typ\n' "$HERE"
  for d in tests/*/; do
    [ -f "$d/test.typ" ] && printf '%s\t%s\n' "$(basename "$d")" "$d/test.typ"
  done
  for d in examples/*/; do
    [ -f "$d/example.typ" ] && printf 'example-%s\t%s\n' "$(basename "$d")" "$d/example.typ"
  done
  return 0
}

status_line() { # colour label name detail
  printf '  \033[%sm%-10s\033[0m %-22s %s\n' "$1" "$2" "$3" "$4"
}

fail=0
decks=()

while IFS=$'\t' read -r name src; do
  if [ -n "$FILTER" ] && [[ "$name" != *"$FILTER"* ]]; then continue; fi
  pdf="$OUT/$name.pdf"

  if ! err=$(typst compile --root . "$src" "$pdf" 2>&1); then
    status_line 31 "BUILD FAIL" "$name" "$(grep -m1 '^error' <<<"$err")"
    fail=1
    continue
  fi

  report=$(curl -sS --max-time 60 -F "file=@$pdf" "$API/api/check")
  line=$(printf '%s' "$report" | python3 "$HERE/_check_report.py")
  rc=$?
  if [ $rc -eq 0 ]; then
    status_line 32 "OK" "$name" "$line"
  else
    status_line 31 "CHECK FAIL" "$name" "$line"
    fail=1
  fi
  decks+=("$name")
done < <(sources)

if [ ${#decks[@]} -eq 0 ]; then
  echo "no decks matched '$FILTER'"
  exit 1
fi

echo
echo "PDFs in $OUT/"
[ "$PRESENT" -eq 0 ] && exit $fail

echo "Handoff links are single-use and expire after 24h."
for name in "${decks[@]}"; do
  read -r -p "  open '$name' in presio? [Y/n/q] " reply </dev/tty
  case "${reply:-y}" in
    q|Q) break ;;
    n|N) continue ;;
  esac
  url=$(curl -sS --max-time 120 -F "file=@$OUT/$name.pdf" "$API/api/present" \
        | python3 -c 'import json,sys; print(json.load(sys.stdin).get("url",""))')
  if [ -z "$url" ]; then
    status_line 31 "PRESENT" "$name" "failed to start a session"
    fail=1
    continue
  fi
  echo "    $url"
  command -v open >/dev/null && open "$url"
done

exit $fail
