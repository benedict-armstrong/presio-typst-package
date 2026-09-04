// Compile-only test: verify YouTube and Vimeo URL parsers.
#import "/src/lib.typ": _youtube-id, _vimeo-id

// YouTube — all officially supported URL shapes resolve to the same id.
#assert.eq(_youtube-id("https://www.youtube.com/watch?v=dQw4w9WgXcQ"), "dQw4w9WgXcQ")
#assert.eq(_youtube-id("https://youtube.com/watch?v=dQw4w9WgXcQ"), "dQw4w9WgXcQ")
#assert.eq(_youtube-id("https://youtu.be/dQw4w9WgXcQ"), "dQw4w9WgXcQ")
#assert.eq(_youtube-id("https://www.youtube.com/embed/dQw4w9WgXcQ"), "dQw4w9WgXcQ")
#assert.eq(_youtube-id("https://www.youtube.com/shorts/dQw4w9WgXcQ"), "dQw4w9WgXcQ")
#assert.eq(_youtube-id("https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ"), "dQw4w9WgXcQ")
#assert.eq(_youtube-id("https://www.youtube.com/watch?feature=share&v=dQw4w9WgXcQ"), "dQw4w9WgXcQ")
#assert.eq(_youtube-id("https://www.youtube.com/watch?list=PLxx&v=dQw4w9WgXcQ"), "dQw4w9WgXcQ")
#assert.eq(_youtube-id("https://youtube.com/watch?v=dQw4w9WgXcQ&t=42s"), "dQw4w9WgXcQ")
#assert.eq(_youtube-id("https://youtu.be/dQw4w9WgXcQ?t=42"), "dQw4w9WgXcQ")
// Live streams / premieres use a `/live/` path.
#assert.eq(_youtube-id("https://www.youtube.com/live/dQw4w9WgXcQ"), "dQw4w9WgXcQ")
// Any subdomain of the real host, including the mobile site.
#assert.eq(_youtube-id("https://m.youtube.com/watch?v=dQw4w9WgXcQ"), "dQw4w9WgXcQ")
#assert.eq(_youtube-id("http://www.youtube.com/watch?v=dQw4w9WgXcQ"), "dQw4w9WgXcQ")

// Non-YouTube URLs return none.
#assert.eq(_youtube-id("https://vimeo.com/76979871"), none)
#assert.eq(_youtube-id("https://example.com/foo.mp4"), none)
// A playlist carries no video id.
#assert.eq(_youtube-id("https://www.youtube.com/playlist?list=PLxxxxxxxxxxx"), none)
// The pattern is anchored at the scheme, so a YouTube link sitting inside
// someone else's query string is not treated as a YouTube video.
#assert.eq(
  _youtube-id("https://elsewhere.example.com/?next=youtube.com/watch?v=dQw4w9WgXcQ"),
  none,
)
// Lookalike hosts must not match.
#assert.eq(_youtube-id("https://notyoutube.com/watch?v=dQw4w9WgXcQ"), none)

// Vimeo — supported URL shapes.
#assert.eq(_vimeo-id("https://vimeo.com/76979871"), "76979871")
#assert.eq(_vimeo-id("https://player.vimeo.com/video/76979871"), "76979871")
#assert.eq(_vimeo-id("https://vimeo.com/channels/staffpicks/76979871"), "76979871")
#assert.eq(_vimeo-id("https://vimeo.com/video/76979871"), "76979871")
#assert.eq(_vimeo-id("https://vimeo.com/groups/abc/videos/76979871"), "76979871")
#assert.eq(_vimeo-id("https://vimeo.com/76979871?share=copy"), "76979871")

// Non-Vimeo URLs return none.
#assert.eq(_vimeo-id("https://www.youtube.com/watch?v=dQw4w9WgXcQ"), none)
#assert.eq(_vimeo-id("https://example.com/foo.mp4"), none)
// A user page has no numeric video id of its own.
#assert.eq(_vimeo-id("https://vimeo.com/user12345"), none)
// Same anchoring rule as YouTube.
#assert.eq(_vimeo-id("https://elsewhere.example.com/?next=vimeo.com/76979871"), none)
#assert.eq(_vimeo-id("https://notvimeo.com/76979871"), none)
