// Visual check deck for presio placement — not a tytanic test.
//
// Every slide draws a red-outlined placeholder box and hands `media` the exact
// same width/height. In the presio viewer the video overlay must land *exactly*
// on the red box. Any offset is a placement bug (issue #2 was the video sitting
// at the left margin under a centred box).
//
// Build & open with `scripts/presio-check.sh`.

#import "/src/lib.typ": media, speaker-notes

#set page(paper: "presentation-16-9", margin: 30pt)
#set text(size: 16pt)

#let demo(caption, w, h, name) = media(
  "https://www.youtube.com/watch?v=doIN9QpDQMI",
  name: name,
  width: w,
  height: h,
  placeholder: box(
    width: w,
    height: h,
    stroke: 2pt + red,
    fill: luma(240),
    align(center + horizon, text(size: 14pt, caption)),
  ),
)

#let slide(title, body) = {
  heading(level: 2, title)
  body
  pagebreak(weak: true)
}

#slide[1 — `align(center)`][
  #align(center, demo("video must cover this box", 400pt, 225pt, "centered"))
]

#slide[2 — `align(right)`][
  #align(right, demo("flush right", 300pt, 169pt, "right"))
]

#slide[3 — `align(center + horizon)`][
  #align(center + horizon, demo("centred both ways", 400pt, 225pt, "middle"))
  #speaker-notes[Video should be dead centre, covering the red box.]
]

#slide[4 — two on one slide][
  #grid(
    columns: (1fr, 1fr),
    gutter: 20pt,
    demo("left cell", 340pt, 191pt, "cell-left"),
    demo("right cell", 340pt, 191pt, "cell-right"),
  )
]

#slide[5 — `place(bottom + right)`][
  #place(bottom + right, demo("pinned bottom-right", 300pt, 169pt, "pinned"))
]

#slide[6 — nested `pad` + `block(inset:)`][
  #pad(x: 80pt, block(inset: 20pt, stroke: 0.5pt + blue, demo("inside padding", 300pt, 169pt, "nested")))
]

#slide[7 — same local file, reused (1/2)][
  #align(center, media(path("demo.gif"), name: "reused.gif", width: 260pt))
  The bytes are attached once for the whole document; each slide gets its own
  sidecar. Reusing a file used to be a hard compile error.
]

#slide[8 — same local file, reused (2/2)][
  #align(right, media(path("demo.gif"), name: "reused.gif", width: 200pt))
]

#slide[9 — Vimeo, and a plain remote URL][
  #grid(
    columns: (1fr, 1fr),
    gutter: 20pt,
    media("https://vimeo.com/76979871", width: 340pt, height: 191pt),
    media(
      "https://upload.wikimedia.org/wikipedia/commons/2/2c/Rotating_earth_%28large%29.gif",
      width: 340pt,
      height: 191pt,
    ),
  )
  #speaker-notes[Left is a Vimeo embed, right is a plain URL fetched by the viewer.]
]

#slide[10 — YouTube `/live/` URL][
  #align(center + horizon, media(
    "https://www.youtube.com/live/doIN9QpDQMI",
    width: 400pt,
    height: 225pt,
  ))
]
