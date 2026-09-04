#!/usr/bin/env bash
# Run the assertion suite with the Typst version the package actually targets.
#
#   scripts/test.sh            run every tests/*/test.typ
#   scripts/test.sh media      only tests whose name matches "media"
#
# Every test is compile-only: it asserts, and a failed assert fails the
# compile. Prefer this over `tt run` — tytanic 0.3.4 bundles Typst 0.14.2,
# which predates the file `path` type this package requires (see typst.toml
# `compiler = "0.15.0"`), so it cannot even parse the tests that use `path()`.
set -uo pipefail

cd "$(dirname "$0")/.."

FILTER="${1:-}"
fail=0
ran=0

echo "typst $(typst --version | awk '{print $2}')"

for d in tests/*/; do
  name=$(basename "$d")
  [ -f "$d/test.typ" ] || continue
  if [ -n "$FILTER" ] && [[ "$name" != *"$FILTER"* ]]; then continue; fi
  ran=$((ran + 1))
  if err=$(typst compile --root . -f pdf "$d/test.typ" /dev/null 2>&1); then
    printf '  \033[32mpass\033[0m  %s\n' "$name"
  else
    printf '  \033[31mFAIL\033[0m  %s\n' "$name"
    sed 's/^/        /' <<<"$err" | head -12
    fail=1
  fi
done

echo
if [ "$fail" -eq 0 ]; then
  printf '\033[32m%d/%d passed\033[0m\n' "$ran" "$ran"
else
  printf '\033[31msome of %d tests failed\033[0m\n' "$ran"
fi
exit $fail
