// Compile-only test: verify MIME sniffing from file extensions.
#import "/src/lib.typ": _mime-for-ext

#assert.eq(_mime-for-ext("gif"), "image/gif")
#assert.eq(_mime-for-ext("mp4"), "video/mp4")
#assert.eq(_mime-for-ext("webm"), "video/webm")
#assert.eq(_mime-for-ext("unknown"), "application/octet-stream")
#assert.eq(_mime-for-ext(""), "application/octet-stream")
