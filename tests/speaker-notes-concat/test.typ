// Compile-only test: multiple `speaker-notes` calls on one slide must
// not error (they get concatenated into a single `notes-slide-N.json`
// attachment via the labeled-metadata + last-context trick in
// `speaker-notes`). If two calls on the same slide produced two
// `pdf.attach` calls, Typst would reject the duplicate filename and
// compilation would fail.
//
// Dedup is counter-based, so it is stable under extra convergence passes;
// `tests/speaker-notes-pages` asserts that directly by querying the metadata
// trail (and by putting an `outline()` in the document). An earlier
// y-position-based dedup did double-emit under introspection.
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
