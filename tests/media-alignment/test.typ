// Regression for issue #2: an enclosing `align` must move the sidecar
// coordinates, not just the rendered placeholder. Before the fix `media`
// recorded `here().position()` — the position of the *context element*, which
// alignment never moves — so a centered video was reported at the left margin.
#import "/src/lib.typ": media
#import "/tests/_sidecar.typ": check

// content box: 560pt x 300pt at (20pt, 20pt)
#set page(width: 600pt, height: 340pt, margin: 20pt)

#align(center)[
  #media("https://example.com/center.mp4", width: 50%)
]
#pagebreak()

#align(right)[
  #media("https://example.com/right.mp4", width: 200pt)
]
#pagebreak()

#align(center + horizon)[
  #media("https://example.com/middle.mp4", width: 50%)
]
#pagebreak()

// The exact shape reported in issue #2: centered, ratio width, explicit
// placeholder. The placeholder was centered but the video was not.
#align(center)[
  #media(
    "https://www.youtube.com/watch?v=doIN9QpDQMI",
    width: 60%,
    placeholder: box(width: 100pt, height: 50pt, fill: luma(200)),
  )
]

#context {
  // 50% of 560 = 280 wide, 16:9 -> 157.5 tall; centered at 20 + (560-280)/2
  check("https___example_com_center_mp4", page: 1, x: 160pt, y: 20pt, w: 280pt, h: 157.5pt)

  // flush right: 20 + 560 - 200
  check("https___example_com_right_mp4", page: 2, x: 380pt, y: 20pt, w: 200pt, h: 112.5pt)

  // also vertically centered: 20 + (300 - 157.5)/2
  check("https___example_com_middle_mp4", page: 3, x: 160pt, y: 91.25pt, w: 280pt, h: 157.5pt)

  // 60% of 560 = 336; height follows the placeholder's 2:1 aspect, not 16:9
  check(
    "https___www_youtube_com_watch_v_doIN9QpDQMI",
    page: 4,
    x: 132pt,
    y: 20pt,
    w: 336pt,
    h: 168pt,
  )
}
