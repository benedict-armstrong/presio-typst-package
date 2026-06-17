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

// Non-YouTube URLs return none.
#assert.eq(_youtube-id("https://vimeo.com/76979871"), none)
#assert.eq(_youtube-id("https://example.com/foo.mp4"), none)

// Vimeo — supported URL shapes.
#assert.eq(_vimeo-id("https://vimeo.com/76979871"), "76979871")
#assert.eq(_vimeo-id("https://player.vimeo.com/video/76979871"), "76979871")
#assert.eq(_vimeo-id("https://vimeo.com/channels/staffpicks/76979871"), "76979871")

// Non-Vimeo URLs return none.
#assert.eq(_vimeo-id("https://www.youtube.com/watch?v=dQw4w9WgXcQ"), none)
#assert.eq(_vimeo-id("https://example.com/foo.mp4"), none)
