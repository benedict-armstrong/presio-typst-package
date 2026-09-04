// Shared helper for the media sidecar tests.
//
// `media` places a zero-size `<_presio-media-anchor>` at the top-left corner
// of the block it renders, carrying the resolved `w` / `h`. That anchor is the
// single source of the `x_pt` / `y_pt` / `w_pt` / `h_pt` fields in the
// `media-slide-<N>-<id>.json` sidecar, so asserting on it asserts on exactly
// what the presio viewer receives.

// Every anchor in the document, in document order, as the full set of fields
// that reach the sidecar.
#let sidecars() = query(<_presio-media-anchor>).map(el => {
  let pos = el.location().position()
  (
    id: el.value.id,
    page: el.location().page(),
    kind: el.value.kind,
    mime: el.value.mime,
    x: pos.x,
    y: pos.y,
    w: el.value.w,
    h: el.value.h,
  )
})

// Assert the sidecar fields of the anchor with `id` (on `page`, default 1).
// Omitted fields are not checked.
#let check(id, page: 1, kind: none, mime: none, x: none, y: none, w: none, h: none) = {
  let hits = sidecars().filter(g => g.id == id and g.page == page)
  assert.eq(
    hits.len(),
    1,
    message: "expected exactly one `" + id + "` on page " + str(page) + ", found " + str(hits.len()),
  )
  let g = hits.first()
  let want = (kind: kind, mime: mime, x: x, y: y, w: w, h: h)
  for field in ("kind", "mime", "x", "y", "w", "h") {
    if want.at(field) != none {
      assert.eq(
        g.at(field),
        want.at(field),
        message: id + "." + field + ": expected " + repr(want.at(field)) + ", got " + repr(g.at(field)),
      )
    }
  }
}

// Speaker notes are keyed on the physical page too. The attachment itself
// isn't queryable, but the `<_presio-notes>` metadata that feeds it is: one
// element per `speaker-notes` call, and a page emits one sidecar holding all
// of that page's elements in document order.
#let notes-on(page) = query(<_presio-notes>).filter(el => el.location().page() == page)

#let note-pages() = {
  let pages = ()
  for el in query(<_presio-notes>) {
    let p = el.location().page()
    if p not in pages { pages.push(p) }
  }
  pages
}
