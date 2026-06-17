// Compile-only smoke test: `media` accepts each supported source kind
// (path, plain URL, YouTube, Vimeo) without erroring. The actual PDF
// attachments aren't visible in tytanic's PNG output — this catches
// regressions in the call surface and the placement maths.
#import "/src/lib.typ": media

#set page(paper: "presentation-16-9", margin: 1cm)

= File (path)
#media(path("demo.gif"), width: 50%)

#pagebreak()

= File with explicit name and no placeholder
#media(
  path("demo.gif"),
  name: "renamed.gif",
  placeholder: none,
  width: 30%,
  aspect-ratio: 1,
)

#pagebreak()

= Plain URL
#media(
  "https://example.com/clip.mp4",
  width: 40%,
  aspect-ratio: 16 / 9,
)

#pagebreak()

= YouTube
#media("https://www.youtube.com/watch?v=dQw4w9WgXcQ", width: 60%, aspect-ratio: 16 / 9)

#pagebreak()

= Vimeo
#media("https://vimeo.com/76979871", width: 60%, aspect-ratio: 16 / 9)
