#!/usr/bin/env bash
# Minimal test runner: compile each tests/*/test.typ with the system `typst`.
# Assertion failures (`assert.eq`, etc.) panic compilation, so a non-zero
# exit means a test failed.
#
# Tytanic (https://typst-community.github.io/tytanic) is the canonical
# Typst test runner, but as of tytanic 0.3.4 it links Typst 0.14 and can't
# compile this package, which requires Typst 0.15+. Switch to `tt run`
# once tytanic ships a 0.15-compatible release.
set -euo pipefail

cd "$(dirname "$0")"
ROOT="$(cd .. && pwd)"
pass=0
fail=0
failed_tests=()

for t in */test.typ; do
  name="$(dirname "$t")"
  printf '  %-30s ' "$name"
  if typst compile --root "$ROOT" -f pdf "$t" /dev/null 2>/tmp/presio-test-stderr.log; then
    echo "PASS"
    pass=$((pass + 1))
  else
    echo "FAIL"
    sed 's/^/      /' /tmp/presio-test-stderr.log
    fail=$((fail + 1))
    failed_tests+=("$name")
  fi
done

echo
echo "  $pass passed, $fail failed"
if [ "$fail" -gt 0 ]; then
  exit 1
fi
