// The option surface of `media`: how `width` / `height` / `aspect-ratio` /
// `placeholder` resolve, and how `kind` + `mime` are derived from a URL or
// from a `name:` override.
#import "/src/lib.typ": media
#import "/tests/_sidecar.typ": check

// content box: 360pt x 200pt at (20pt, 20pt)
#set page(width: 400pt, height: 240pt, margin: 20pt)

#media("https://example.com/ar.mp4", width: 200pt, aspect-ratio: 4 / 3)
#pagebreak()

#media("https://example.com/hr.mp4", width: 50%, height: 25%)
#pagebreak()

// `placeholder: none` forces the dark block; height falls back to 16:9
#media("https://example.com/pn.mp4", width: 100pt, placeholder: none)
#pagebreak()

// A content placeholder drives the height when `height` is auto...
#media(
  "https://example.com/ph.mp4",
  width: 200pt,
  placeholder: box(width: 40pt, height: 10pt, fill: luma(200)),
)
#pagebreak()

// ...but an explicit `aspect-ratio` does not override a placeholder-derived
// height only when height is auto and no placeholder exists; here height wins.
#media(
  "https://example.com/hx.mp4",
  width: 200pt,
  height: 30pt,
  aspect-ratio: 4 / 3,
  placeholder: box(width: 40pt, height: 10pt, fill: luma(200)),
)
#pagebreak()

// Uppercase extension behind a query string and a fragment.
#media("https://cdn.example.com/Clip.MP4?token=abc&x=1#t=10", width: 100pt)
#pagebreak()

// No extension at all -> generic binary type, still a plain `url`.
#media("https://example.com/stream", width: 100pt)
#pagebreak()

// `name:` overrides both the id and the sniffed MIME type.
#media("https://example.com/stream", name: "intro.webm", width: 100pt)
#pagebreak()

#media("https://www.youtube.com/live/dQw4w9WgXcQ", width: 100pt)
#pagebreak()

#media("https://player.vimeo.com/video/76979871", width: 100pt)

#context {
  // aspect-ratio drives the height when nothing else does
  check("https___example_com_ar_mp4", page: 1, w: 200pt, h: 150pt)

  // ratios resolve against the container: 50% of 360, 25% of 200
  check("https___example_com_hr_mp4", page: 2, w: 180pt, h: 50pt)

  // dark block, default 16:9
  check("https___example_com_pn_mp4", page: 3, w: 100pt, h: 56.25pt)

  // placeholder is 4:1, so 200pt wide -> 50pt tall (not 16:9)
  check("https___example_com_ph_mp4", page: 4, w: 200pt, h: 50pt)

  // an explicit height beats both the placeholder and `aspect-ratio`
  check("https___example_com_hx_mp4", page: 5, w: 200pt, h: 30pt)

  // `.MP4?token=...#t=10` sniffs as mp4, case-insensitively
  check("https___cdn_example_com_Clip_MP4_token_abc_x_1_t_10", page: 6, kind: "url", mime: "video/mp4")

  check("https___example_com_stream", page: 7, kind: "url", mime: "application/octet-stream")

  check("intro_webm", page: 8, kind: "url", mime: "video/webm")

  // YouTube / Vimeo are `text/html` regardless of any extension
  check("https___www_youtube_com_live_dQw4w9WgXcQ", page: 9, kind: "youtube", mime: "text/html")
  check("https___player_vimeo_com_video_76979871", page: 10, kind: "vimeo", mime: "text/html")
}
