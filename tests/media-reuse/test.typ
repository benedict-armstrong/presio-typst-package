// One local file used on several slides must attach its bytes exactly once.
//
// The binary's attachment name (`media-<id>.<ext>`) carries no page number, so
// re-attaching it per slide is a hard "attempted to attach file ... twice"
// error. That fires whenever a file is reused — a logo on every slide — and,
// less obviously, whenever file media sits in a touying overlay group, since
// `#pause` repeats the same call across subslide pages. v0.2.1 keyed the
// *sidecar* on the physical page but left the binary colliding; the bytes are
// now attached on the first page that references them.
//
// Compiling at all is the regression check. That exactly one copy of the bytes
// is embedded is verified end-to-end by `scripts/presio-check.sh`, which runs
// the PDF through presio's own validator.
#import "/src/lib.typ": media
#import "/tests/_sidecar.typ": check, sidecars

#set page(width: 400pt, height: 240pt, margin: 20pt)

#media(path("demo.gif"), width: 80pt)
#pagebreak()
#align(right, media(path("demo.gif"), width: 80pt))
#pagebreak()
#align(center, media(path("demo.gif"), width: 120pt))

#context {
  // One sidecar per page, all pointing at the same id, each with its own
  // position — that shared id is exactly what used to collide.
  check("demo_gif", page: 1, kind: "file", mime: "image/gif", x: 20pt, w: 80pt)
  check("demo_gif", page: 2, kind: "file", mime: "image/gif", x: 300pt, w: 80pt)
  check("demo_gif", page: 3, kind: "file", mime: "image/gif", x: 140pt, w: 120pt)
  assert.eq(sidecars().len(), 3)
}
