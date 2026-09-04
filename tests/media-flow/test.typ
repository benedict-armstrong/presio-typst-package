// Sidecars are keyed on the *physical* page and the anchor is looked up on
// that page, so the two must never disagree:
//   - the same source repeated across pages (a page header, or a touying
//     overlay group) gets one sidecar per page rather than colliding;
//   - a block pushed to the next page by overflow is reported on the page it
//     lands on, not the page the call was written on.
#import "/src/lib.typ": media
#import "/tests/_sidecar.typ": check, sidecars

// content box: 520pt x 120pt at (40pt, 40pt)
#set page(
  width: 600pt,
  height: 200pt,
  margin: 40pt,
  header: align(right, media("https://example.com/logo.mp4", width: 60pt)),
)

// 100pt of the 120pt content box; the 56.25pt media no longer fits and is
// pushed onto page 2.
#block(height: 100pt, width: 100%)[filler]
#media("https://example.com/pushed.mp4", width: 100pt)

#context {
  // The header runs on both pages: same id, one anchor per page, same spot.
  // 600 - 40 margin - 60 width. (y is font-metric dependent, so not asserted.)
  check("https___example_com_logo_mp4", page: 1, x: 500pt, w: 60pt)
  check("https___example_com_logo_mp4", page: 2, x: 500pt, w: 60pt)

  // Overflowed onto page 2, and reported there — at the top of that page,
  // not at the bottom of page 1.
  check("https___example_com_pushed_mp4", page: 2, x: 40pt, y: 40pt, w: 100pt, h: 56.25pt)

  // Exactly three anchors total: two header runs plus the pushed block.
  assert.eq(sidecars().len(), 3)
}
