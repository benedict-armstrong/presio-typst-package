// Shared helper for the media geometry tests.
//
// `media` places a zero-size `<_presio-media-anchor>` at the top-left corner
// of the block it renders, carrying the resolved `w` / `h`. That anchor is the
// single source of the `x_pt` / `y_pt` / `w_pt` / `h_pt` fields in the
// `media-slide-<N>-<id>.json` sidecar, so asserting on it asserts on exactly
// what the presio viewer receives.

// Every anchor in the document, as (id, page, x, y, w, h), in document order.
#let geometry() = query(<_presio-media-anchor>).map(el => {
  let pos = el.location().position()
  (
    id: el.value.id,
    page: el.location().page(),
    x: pos.x,
    y: pos.y,
    w: el.value.w,
    h: el.value.h,
  )
})

// Assert the geometry of the anchor with `id` (on `page`, default 1).
// Omitted fields are not checked.
#let check(id, page: 1, x: none, y: none, w: none, h: none) = {
  let hits = geometry().filter(g => g.id == id and g.page == page)
  assert.eq(
    hits.len(),
    1,
    message: "expected exactly one `" + id + "` on page " + str(page) + ", found " + str(hits.len()),
  )
  let g = hits.first()
  let want = (x: x, y: y, w: w, h: h)
  for field in ("x", "y", "w", "h") {
    if want.at(field) != none {
      assert.eq(
        g.at(field),
        want.at(field),
        message: id + "." + field + ": expected " + repr(want.at(field)) + ", got " + repr(g.at(field)),
      )
    }
  }
}
