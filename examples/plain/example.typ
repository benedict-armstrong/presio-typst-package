// presio example: plain Typst pages (no slide framework).
// Compile with: typst compile examples/plain/example.typ
#import "@preview/presio:0.2.0": media, speaker-notes

#set page(paper: "presentation-16-9", margin: 1.5cm)
#set text(size: 24pt)

= Welcome

A plain Typst deck using `presio` for notes and media.

#speaker-notes[
  Remember to introduce yourself and thank the audience.
]

Some intro prose.

#speaker-notes[
  Second notes block on the same slide — should be concatenated.
]

#pagebreak()

= Embedded GIF

#media(
  path("demo.gif"),
  width: 60%,
)

#speaker-notes[
  This GIF is embedded directly in the PDF.
]

#pagebreak()

= URL-sourced media

#media(
  "https://upload.wikimedia.org/wikipedia/commons/2/2c/Rotating_earth_%28large%29.gif",
  width: 40%,
  aspect-ratio: 1,
)

#pagebreak()

= YouTube

#media("https://www.youtube.com/watch?v=dQw4w9WgXcQ", width: 60%, aspect-ratio: 16/9)

#pagebreak()

= Vimeo

#media("https://vimeo.com/76979871", width: 60%, aspect-ratio: 16/9)
