# presio — Typst package

Framework-agnostic Typst package that attaches **speaker notes** and **embedded media** (GIF / MP4 / WebM, plus YouTube/Vimeo URLs) to a compiled PDF so it can be presented with the [presio.xyz](https://presio.xyz) viewer.

Published as `@preview/presio` on Typst Universe (PR'd through `typst/packages`).

## Repo layout

```
/Users/ben/Projects/slides_typst/
├── typst.toml              # package manifest
├── README.md               # user-facing docs
├── LICENSE                 # MIT
├── src/lib.typ             # entrypoint — exports `media` and `speaker-notes`
└── examples/
    ├── demo.gif            # shared media fixture
    ├── plain/example.typ   # raw Typst pages
    ├── polylux/example.typ # polylux deck
    └── touying/example.typ # touying deck (simple theme)
```

Local symlink for smoke testing: `~/Library/Application Support/typst/packages/local/presio/0.1.0` → this repo.

The `examples/*/example.typ` decks import `@preview/presio:<version>`, so out of the box they compile against the **published** package, not the working tree. To point them at local `src/`, symlink the repo into the preview namespace for the in-development version — Typst prefers a local directory over downloading:

```
ln -sfn "$PWD" "$HOME/Library/Application Support/typst/packages/preview/presio/0.2.3"
```

Without it, a version bump breaks the examples (the new version isn't on Universe yet) and `scripts/presio-check.sh` silently validates the old released code.

Smoke test: from the repo root, `typst compile --root . examples/plain/example.typ /tmp/out.pdf` (substitute `polylux` or `touying` for the framework-specific variants). `--root .` is required because Typst 0.15's `path` sandbox would otherwise treat the example's directory as the root and reject `../demo.gif`. Expected attachments: `notes-slide-*.json`, `media-slide-*-*.json`, embedded `.gif`.

## Tests

Tests live in `tests/` and use the [tytanic](https://typst-community.github.io/tytanic/) layout (one directory per test, `test.typ` inside). Install once with `cargo install tytanic`, then run `tt run` at the repo root. All current tests are **compile-only** (assertion-based, no `ref/` images) since presio's value is in side-effect `pdf.attach` calls that aren't visually verifiable.

Coverage:
- `tests/url-detection/` — `_youtube-id` / `_vimeo-id` across every supported URL shape, plus the cases that must *not* match (playlists, user pages, lookalike hosts, a video link embedded in another site's query string).
- `tests/mime-sniff/` — `_mime-for-ext` mapping.
- `tests/media-compile/` — smoke test that `media` accepts each source kind (path, plain URL, YouTube, Vimeo) without erroring.
- `tests/media-alignment/` — regression for issue #2: centre / right / `center + horizon`, plus the exact reported shape (ratio width + explicit placeholder).
- `tests/media-placement/` — geometry inside nested containers: `pad` + `block(inset:)`, `place`, `move`, a table cell, a second column, and a narrow `box` (ratio widths must resolve against the innermost region).
- `tests/media-flow/` — one sidecar per *physical* page: a repeating page header, and a block pushed to the next page by overflow.
- `tests/media-options/` — `width` / `height` / `aspect-ratio` / `placeholder` precedence, and `kind` + `mime` derivation (uppercase extension behind a query string, no extension at all, `name:` override).
- `tests/media-reuse/` — one local file on three slides: bytes attached once, one sidecar per page.
- `tests/speaker-notes-concat/` — multiple calls on one slide concatenate.
- `tests/speaker-notes-stacked/` — back-to-back calls with no separator content.
- `tests/speaker-notes-pages/` — one sidecar per physical page, notes emitted from a page header repeating on every page, and stability under introspection (`outline()` plus direct `query`).

The media suites share `tests/_sidecar.typ`: `sidecars()` / `check(id, page:, kind:, mime:, x:, y:, w:, h:)` over the `<_presio-media-anchor>` metadata, and `notes-on(page)` / `note-pages()` over `<_presio-notes>`. The anchor carries every field that reaches the sidecar, so asserting on it asserts on exactly what the viewer receives — no PDF parsing needed.

**Run the tests with `scripts/test.sh`, not `tt run`.** tytanic 0.3.4 bundles Typst **0.14.2**, which predates the file `path` type this package requires (`compiler = "0.15.0"`), so `tt` cannot parse any test that calls `path()` — `media-compile` and `media-reuse` both fail there for that reason alone, and the rest are being checked against a compiler older than the supported minimum. `scripts/test.sh` compiles each `tests/*/test.typ` with the real `typst` on PATH; every test is assertion-based, so a failed assert fails the compile. The tytanic layout is kept so `tt run` still works for the subset it can handle.

`tests/**` is in the manifest `exclude` list so it never ships to Universe.

## End-to-end checking against presio

`scripts/presio-check.sh` builds every deck in the repo (`scripts/visual-check.typ`, each `tests/*/test.typ`, each `examples/*/example.typ`) to `build/presio/`, POSTs each PDF to presio's own validator (`POST https://presio.xyz/api/check`), and then offers to open each in the viewer (`POST /api/present` returns a single-use handoff URL, valid 24h). `--check-only` skips the browser; a bare argument filters decks by name.

`scripts/visual-check.typ` is the deck worth eyeballing: every slide draws a red-outlined placeholder and passes `media` the identical width/height, so in the viewer the video overlay must land *exactly* on the red box. Any offset is a placement bug. It also covers the file-reuse, Vimeo and YouTube-`/live/` paths.

The presio API is documented at <https://presio.xyz/api.md> (also `/openapi.json`, and an MCP endpoint at `/mcp` with `present_pdf` / `check_pdf`).

## Public API

Two functions only — `media` and `speaker-notes`. No layout, no slide flow. Caller brings their own framework (polylux, touying, plain pages).

### `speaker-notes(notes)`
Emits one `notes-slide-<N>.json` per slide. Multiple calls on the same slide are concatenated in source order into a single attachment with a `notes` array.

Implementation: each call drops a labeled `metadata` element (`<_presio-notes>`) and a `context` block. Only the context block following the *last* metadata on a page emits the `pdf.attach`, detected via y-position comparison against `query(<_presio-notes>)` filtered to the current page. Guarantees exactly one attachment per slide regardless of call count.

### `media(source, name: none, width: auto, height: auto, autoplay: true, loop: true, placeholder: auto, aspect-ratio: none)`
- `source` is **either** a `path` (constructed with `path("figures/demo.gif")` at the call site, Typst 0.15+) **or** a `http(s)://` URL string.
- For paths, the package internally does `read(source, encoding: none)` for bytes and `image(source)` for the default placeholder. The path type carries its caller scope so this works from inside the package.
- `kind` is computed: `file` | `url` | `youtube` | `vimeo`. YouTube/Vimeo detected by regex against the URL; `video_id` is extracted and emitted in the sidecar.
- For `file` kind, the bytes are attached as `media-<safe-id>.<ext>`.
- For every call, a `media-slide-<N>-<safe-id>.json` sidecar with placement (`x_pt`, `y_pt`, `w_pt`, `h_pt`) and `kind`-specific extras is attached.
- `placeholder: auto` → `image(source)` for file mode, dark block for URLs. `placeholder: none` → force dark block. Any `content` → use it.

## Key design decisions

- **Caller passes a `path`.** Typst's `read()` / `image()` inside a package historically resolved relative to the *package* directory, not the caller — forcing v0.1 to take pre-read `bytes`. Typst 0.15's file `path` type (typst/typst#7555) fixes this: `path("figures/demo.gif")` constructed in the deck remembers its origin scope, so the package can `read()` and `image()` it directly. v0.2 requires Typst 0.15+. v0.1 (bytes API) is kept for users on older Typst.
- **`width` / `height` default to `auto`.** `auto` width prefers the placeholder's natural width (via `measure`), else the container width. `auto` height uses placeholder aspect ratio, else `aspect-ratio`, else 16:9.
- **Concatenate, don't collide.** Multiple `speaker-notes` on one slide → single sidecar, array of entries. Multiple `media` on one slide → distinct attachments keyed by `safe-id` (derived from `name` / URL).
- **YouTube/Vimeo are first-class.** Detected from URL, emitted with `kind` + `video_id` so the viewer can build an iframe instead of trying to fetch a binary.
- **Framework-agnostic.** No imports from polylux/touying. Only `here().page()`, `layout`, `here().position()`, `pdf.attach`, `measure`, `query`/`metadata`.
- **Key on the *physical* page, not the logical slide.** Both `media` and `speaker-notes` derive the slide number from `here().page()`. Touying's overlays (`#pause`) report the *same* `counter(page)` for every subslide of a group, so keying media on `counter(page)` collided two attachments on one name (Typst errors on a duplicate attachment) — the v0.2.0 bug. `here().page()` advances per physical PDF page, which is what the presio viewer flips through, so an element visible on N subslides gets one sidecar per subslide page. (In polylux the two counters agree; `#pause` isn't exported — incremental reveal is `#show: later` / `uncover`.) Fixed in v0.2.1.
- **Sidecar coordinates come from an anchor inside the block, not `here().position()`.** The `context` element sits where the `media` call appears in the flow; an enclosing `align(center)` (or any alignment/placement) moves the rendered block but not the context element, so `here().position()` reported the un-aligned origin and the viewer drew the video left-aligned under a centered placeholder (issue #2). `media` now `place`s a zero-size `<_presio-media-anchor>` metadata at the block's top-left corner and reads its position back via `query`, which reflects the final layout.
- **Media bytes are attached once per document, sidecars once per page.** `media-<id>.<ext>` has no page number in it, so re-attaching the same file on a second slide is a hard `attempted to attach file ... twice` error. That bites on any reused file (a logo on every slide) and — the reason v0.2.1's overlay fix was incomplete — on *any* file media in a touying overlay group, since `#pause` repeats the call across subslide pages. The bytes now attach on the lowest page that references them. Dedup is keyed on (id, source), not id alone: two different files whose names normalise to one `safe-id` (`a-b.gif` and `a_b.gif` → `a_b_gif`) still collide loudly rather than silently serving one in place of the other; the fix is `name:`. Detecting that clash with an explicit `panic` was tried and rejected — panicking inside the introspection loop destabilises it (`did not converge within five attempts`).
- **URL detection is anchored at the scheme.** `_youtube-id` / `_vimeo-id` match from `^https?://` through an optional subdomain chain, so a video link sitting inside another site's query string is not mistaken for the real host. YouTube `/live/` (streams and premieres) is a supported path alongside `watch`, `embed`, `shorts` and `youtu.be`.
- **Attachment-naming is the contract with the viewer.** Names (`notes-slide-<N>.json`, `media-slide-<N>-<id>.json`, `media-<id>.<ext>`) are stable — do not rename casually.

## Sidecar schemas

`notes-slide-<N>.json`:
```json
{ "slide": "3", "notes": ["<content>", "<content>"] }
```

`media-slide-<N>-<id>.json` — common: `kind`, `slide`, `id`, `mime`, `x_pt`, `y_pt`, `w_pt`, `h_pt`, `autoplay`, `loop`. Extras by `kind`:
- `file` → `filename`
- `url` → `url`
- `youtube` → `url`, `video_id`
- `vimeo` → `url`, `video_id`

## Publishing workflow (typst/packages)

Reference: <https://github.com/typst/packages/blob/main/README.md> and `docs/manifest.md`.

1. **Develop locally** with the preview-namespace symlink above. Smoke-test the three `examples/<framework>/example.typ` decks (compile each with `--root .`). Inspect attachments with `pdfdetach -list out.pdf`.
2. **Push to GitHub** (`benedict-armstrong/presio-typst-package`). Tag `v<version>` when cutting a release.
3. **Fork `typst/packages`** (already done at `benedict-armstrong/typst-packages`, cloned to `~/Projects/typst-packages/`). The fork's `upstream` remote points at `typst/packages`.
4. **Create release branch** `presio-<version>` in the fork. Copy `src/`, `typst.toml`, `README.md`, `LICENSE` into `packages/preview/presio/<version>/`. No `examples/`, no git artifacts.
5. **Push and open PR** against `typst/packages:main` from the fork branch. Use `gh pr create`.
6. **Watch CI** (`typst-package-check`). Bundler builds the package; the linter checks the manifest. Common issues:
   - Excluding `README.md` triggers a warning — **do not exclude README.md** in `typst.toml`.
   - Author email mismatch with the git committer can be flagged.
   - `categories` must come from the allowed list — we use `visualization`.
7. **Respond to maintainer review.** Once merged, `@preview/presio:<version>` becomes globally available (with some indexing delay).

For subsequent releases: bump `version` in `typst.toml`, create a new `packages/preview/presio/<new-version>/` directory in the fork (never edit a published version), open a new PR.

Active PR: <https://github.com/typst/packages/pull/4894> for `presio:0.1.0`. v0.2.0 (Typst 0.15+ `path` API) is a separate forthcoming PR. v0.2.1 (overlay/`#pause` fix — key sidecars on `here().page()` instead of `counter(page)`) is PR <https://github.com/typst/packages/pull/5105> (branch `presio-0.2.1` in the fork).

## Manifest essentials (`typst.toml`)

- `name = "presio"` — short, kebab-safe, not generic, no "typst" substring.
- `compiler = "0.15.0"` — minimum Typst version (required for the file `path` type).
- `categories = ["visualization"]` — must be from the allowed list.
- `exclude = ["examples/**"]` — keep the bundle small, but **never exclude README.md**.
- `repository`, `keywords`, `description`, `license` (SPDX), `authors` populated.
