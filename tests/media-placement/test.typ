// `media` must report where the block actually lands, whatever container it
// sits in — padding, insets, out-of-flow placement, translation, table cells
// and multi-column flow all shift it. `layout`'s `container` also has to be
// the *innermost* region so ratio widths resolve against the right box.
#import "/src/lib.typ": media
#import "/tests/_sidecar.typ": check

// content box: 560pt x 300pt at (20pt, 20pt)
#set page(width: 600pt, height: 340pt, margin: 20pt)

#pad(x: 50pt, block(inset: 15pt, media("https://example.com/pad.mp4", width: 100pt)))
#pagebreak()

#place(bottom + right, media("https://example.com/place.mp4", width: 100pt))
#pagebreak()

#move(dx: 40pt, dy: 30pt, media("https://example.com/move.mp4", width: 100pt))
#pagebreak()

#table(columns: (1fr, 1fr), [x], media("https://example.com/cell.mp4", width: 100%))
#pagebreak()

#columns(2)[
  a
  #colbreak()
  #media("https://example.com/col.mp4", width: 100%)
]
#pagebreak()

#box(width: 150pt, media("https://example.com/box.mp4", width: 100%))

#context {
  // 20 + 50 (pad) + 15 (inset) on both axes
  check("https___example_com_pad_mp4", page: 1, x: 85pt, y: 35pt, w: 100pt)

  // out-of-flow, pinned to the bottom-right of the content box
  check("https___example_com_place_mp4", page: 2, x: 480pt, y: 263.75pt, w: 100pt)

  // translated out of its flow position
  check("https___example_com_move_mp4", page: 3, x: 60pt, y: 50pt, w: 100pt)

  // second cell of a 2-col table: 280pt columns, default 5pt cell inset,
  // so the ratio width resolves against 270pt, not the 560pt page
  check("https___example_com_cell_mp4", page: 4, x: 305pt, y: 25pt, w: 270pt)

  // second of two columns: (560 - 22.4 gutter) / 2 = 268.8 wide
  check("https___example_com_col_mp4", page: 5, x: 311.2pt, y: 20pt, w: 268.8pt)

  // 100% resolves against the enclosing box, not the page
  check("https___example_com_box_mp4", page: 6, x: 20pt, y: 20pt, w: 150pt)
}
