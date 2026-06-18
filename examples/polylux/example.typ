// presio example: polylux deck.
// Compile with: typst compile examples/polylux/example.typ
#import "@preview/polylux:0.4.0": *
#import "@preview/presio:0.2.1": media, speaker-notes

#set page(paper: "presentation-16-9", margin: 1.5cm)
#set text(size: 24pt)

#slide[
  #set align(horizon)
  = Welcome

  A polylux deck wired up with `presio`.

  #speaker-notes[
    Remember to introduce yourself and thank the audience.
  ]

  #speaker-notes[
    Second notes block on the same slide — should be concatenated.
  ]
]

#slide[
  == Embedded GIF

  #media(path("demo.gif"), width: 60%)

  #speaker-notes[
    This GIF is embedded directly in the PDF.
  ]
]

#slide[
  == URL-sourced media

  #media(
    "https://upload.wikimedia.org/wikipedia/commons/2/2c/Rotating_earth_%28large%29.gif",
    width: 30%,
    aspect-ratio: 1,
  )

  // `#show: later` reveals everything after it on the next subslide —
  // polylux's equivalent of touying's `#pause`. presio attaches the
  // sidecar on each physical subslide page the media is visible on.
  #show: later

  Reveal content
]

#slide[
  == YouTube

  #media("https://www.youtube.com/watch?v=dQw4w9WgXcQ", width: 60%, aspect-ratio: 16 / 9)
]

#slide[
  == Vimeo

  #media("https://vimeo.com/76979871", width: 60%, aspect-ratio: 16 / 9)
]
