"""Summarise a presio CheckReport read from stdin.

Prints one line per deck plus any sidecar that isn't valid; exits non-zero
when the report contains invalid entries.
"""

import json
import sys


def main() -> int:
    try:
        report = json.load(sys.stdin)
    except Exception as exc:  # noqa: BLE001 - any parse failure is a check failure
        print(f"unreadable response from /api/check ({exc})")
        return 2

    summary = report.get("summary", {})
    bad = []
    for page in report.get("pages", []):
        entries = list(page.get("media") or [])
        if page.get("notes"):
            entries.append(page["notes"])
        for entry in entries:
            if entry.get("validity") == "valid":
                continue
            issues = "; ".join(str(i) for i in (entry.get("issues") or []))
            bad.append(
                f"p{page['page']} {entry.get('filename')}: "
                f"{issues or entry.get('validity')}"
            )

    print(
        f"{summary.get('valid', 0)}/{summary.get('total', 0)} valid, "
        f"{summary.get('warning', 0)} warn, {summary.get('invalid', 0)} invalid  "
        f"({report.get('pageCount', '?')} pages)"
    )
    for line in bad:
        print("    " + line)

    return 1 if (summary.get("invalid") or bad) else 0


if __name__ == "__main__":
    sys.exit(main())
