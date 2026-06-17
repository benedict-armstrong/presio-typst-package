// Regression test: three (or more) `speaker-notes` calls stacked
// back-to-back on the same slide — with no content between them — must
// still produce exactly one `notes-slide-N.json` attachment.
//
// Earlier versions dedup'd by y-position, which broke when consecutive
// calls had identical or near-identical y-positions. The fix uses a
// counter stored in the metadata: only the call with the maximum
// counter value on a slide emits the `pdf.attach`.
#import "/src/lib.typ": speaker-notes

#set page(paper: "presentation-16-9", margin: 1cm)

= Stacked notes
#speaker-notes[First]
#speaker-notes[Second]
#speaker-notes[Third]
#speaker-notes[Fourth]
#speaker-notes[Fifth]

Body content below the notes.
