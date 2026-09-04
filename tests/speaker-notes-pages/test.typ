// One `notes-slide-<N>.json` per physical page, holding every `speaker-notes`
// call that lands on that page — including calls made from a page header,
// which re-run for each page — and none at all for a page without notes.
//
// The document deliberately introspects (`outline()`, plus the queries below)
// to force extra convergence passes: the counter-based dedup in
// `speaker-notes` must emit exactly once per page regardless.
#import "/src/lib.typ": media, speaker-notes
#import "/tests/_sidecar.typ": note-pages, notes-on

#set page(
  width: 400pt,
  height: 220pt,
  margin: 20pt,
  header: [hdr #speaker-notes[note from the header]],
)

= Slide one
#speaker-notes[first]
Prose between the calls.
#speaker-notes[second]
#speaker-notes[third]
#pagebreak()

= Slide two
// Notes and media coexist on one page without interfering.
#media("https://example.com/v.mp4", width: 60pt)
#speaker-notes[rich: #text(red)[colour], $x^2$, #box(width: 4pt, height: 4pt, fill: blue)]
#pagebreak()

= Slide three
Body only — but the header still contributes its note.
#pagebreak()

= Slide four
#outline()

#context {
  // header note + three body notes
  assert.eq(notes-on(1).len(), 4)
  // header note + one body note
  assert.eq(notes-on(2).len(), 2)
  // header note only
  assert.eq(notes-on(3).len(), 1)

  // Every page carries the header note, so every page gets a sidecar.
  assert.eq(note-pages(), (1, 2, 3, 4))

  // Body notes keep source order within a page.
  let body = notes-on(1).map(el => el.value.notes).filter(n => n != [note from the header])
  assert.eq(body, ([first], [second], [third]))
}
