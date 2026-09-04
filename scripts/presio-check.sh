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
# every examples/*/example.typ.
#
# The example decks are rebuilt **in place**, over the committed
# `examples/*/example.pdf`. Those files are what the README's "Present the …
# demo" badges serve, so they have to be rebuilt on every release or the live
# demos show the previous version's behaviour. Builds are pinned with
# SOURCE_DATE_EPOCH so an unchanged deck rebuilds byte-identically and leaves no
# diff; anything that does show up in `git status` is a real content change and
# needs committing. Every other deck goes to build/presio/.
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

# Pin the PDF timestamp so rebuilding an unchanged deck is byte-identical and
# the committed example PDFs don't churn on every run.
export SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-0}"

# Release links have to track typst.toml (see scripts/_check_readme.py).
version=$(sed -n 's/^version = "\(.*\)"/\1/p' typst.toml)
if ! stale=$(python3 "$HERE/_check_readme.py" README.md "$version"); then
  printf '  \033[33m%-10s\033[0m README still points at %s, but typst.toml says %s\n' \
    "STALE" "$(tr '\n' ' ' <<<"$stale" | sed 's/ $//')" "$version"
  echo
fi

# name<TAB>source<TAB>output, most interesting first. Examples build over their
# committed PDF; everything else is throwaway.
sources() {
  printf 'visual-check\t%s/visual-check.typ\t%s/visual-check.pdf\n' "$HERE" "$OUT"
  for d in tests/*/; do
    n=$(basename "$d")
    [ -f "$d/test.typ" ] && printf '%s\t%s\t%s\n' "$n" "$d/test.typ" "$OUT/$n.pdf"
  done
  for d in examples/*/; do
    n=$(basename "$d")
    [ -f "$d/example.typ" ] && printf 'example-%s\t%s\t%s\n' "$n" "$d/example.typ" "$d/example.pdf"
  done
  return 0
}

status_line() { # colour label name detail
  printf '  \033[%sm%-10s\033[0m %-22s %s\n' "$1" "$2" "$3" "$4"
}

fail=0
decks=()
pdfs=()

while IFS=$'\t' read -r name src pdf; do
  if [ -n "$FILTER" ] && [[ "$name" != *"$FILTER"* ]]; then continue; fi

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
  pdfs+=("$pdf")
done < <(sources)

if [ ${#decks[@]} -eq 0 ]; then
  echo "no decks matched '$FILTER'"
  exit 1
fi

echo
echo "PDFs in $OUT/; example decks rebuilt in place."

# Rebuilding is byte-identical unless the deck really changed, so anything dirty
# here is a demo PDF that has drifted from source and needs committing.
if command -v git >/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
  drifted=$(git status --porcelain -- 'examples/*/example.pdf' | awk '{print $2}')
  if [ -n "$drifted" ]; then
    printf '  \033[33m%-10s\033[0m committed demo PDFs changed — commit them:\n' "REBUILT"
    sed 's/^/               /' <<<"$drifted"
  fi
fi

[ "$PRESENT" -eq 0 ] && exit $fail

echo "Handoff links are single-use and expire after 24h."
for i in "${!decks[@]}"; do
  name="${decks[$i]}"
  read -r -p "  open '$name' in presio? [Y/n/q] " reply </dev/tty
  case "${reply:-y}" in
    q|Q) break ;;
    n|N) continue ;;
  esac
  url=$(curl -sS --max-time 120 -F "file=@${pdfs[$i]}" "$API/api/present" \
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
