"""Check that README version references track typst.toml.

Two kinds of reference have to move on every release:

  * `/blob/v<version>/…` permalinks — the README pins its example links to a
    tag so they always match the released package. Leaving them behind ships
    links to the previous version's examples, and the typst/packages linter
    flags it.
  * the `@preview/presio:<version>` import in a fenced code block — the
    copy-paste install snippet.

Prose mentions of older versions are deliberate (the README points users on
Typst 0.13-0.14 at 0.1.0), so only fenced blocks are checked for imports.

Usage: _check_readme.py <readme> <version>; exits 1 if anything is stale.
"""

import re
import sys


def fenced_blocks(text: str) -> str:
    out, inside = [], False
    for line in text.splitlines():
        if line.lstrip().startswith("```"):
            inside = not inside
            continue
        if inside:
            out.append(line)
    return "\n".join(out)


def main() -> int:
    readme, version = sys.argv[1], sys.argv[2]
    text = open(readme, encoding="utf-8").read()

    stale = set()
    stale.update(
        m for m in re.findall(r"/blob/v(\d+\.\d+\.\d+)", text) if m != version
    )
    stale.update(
        m
        for m in re.findall(r"@preview/presio:(\d+\.\d+\.\d+)", fenced_blocks(text))
        if m != version
    )

    for v in sorted(stale):
        print(v)
    return 1 if stale else 0


if __name__ == "__main__":
    sys.exit(main())
