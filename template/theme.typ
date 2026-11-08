// All styling in one place.

#let fonts = ("Helvetica Neue", "Libertinus Serif")
#let accent = rgb("#1f4e79")
#let muted = luma(95)

#let base-size = 10pt
#let small-size = 9pt

#let apply(lang: "en", body) = {
  set page(paper: "a4", margin: (x: 1.8cm, y: 1.6cm))
  set text(font: fonts, size: base-size, lang: lang)
  set par(justify: true, leading: 0.55em)
  set list(indent: 0.2em, body-indent: 0.5em, spacing: 0.45em, marker: text(fill: accent)[•])
  body
}

#let small-muted(body) = text(size: small-size, fill: muted, body)

#let section-heading(title) = block(above: 1.3em, below: 0.7em, sticky: true, {
  text(size: 10.5pt, weight: "bold", fill: accent, tracking: 0.06em, upper(title))
  v(-0.65em)
  line(length: 100%, stroke: 0.5pt + accent)
})
