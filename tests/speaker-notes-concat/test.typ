// Compile-only test: multiple `speaker-notes` calls on one slide must
// not error (they get concatenated into a single `notes-slide-N.json`
// attachment via the labeled-metadata + last-context trick in
// `speaker-notes`). If two calls on the same slide produced two
// `pdf.attach` calls, Typst would reject the duplicate filename and
// compilation would fail.
//
// We deliberately avoid `#context { query(...) ... }` introspection in
// the test body: that forces Typst into extra convergence passes which
// race with the dedup logic and double-emit. Real callers don't
// typically introspect the metadata trail, so the example deck and
// real decks compile cleanly.
#import "/src/lib.typ": speaker-notes

#set page(paper: "presentation-16-9", margin: 1cm)

= Slide one

#speaker-notes[First]

Some prose between notes.

#speaker-notes[Second]

More prose.

#speaker-notes[Third]

#pagebreak()

= Slide two — single call
#speaker-notes[Only one here]

#pagebreak()

= Slide three — no notes
Body only.
