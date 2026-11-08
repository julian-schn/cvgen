// Classic theme: sans-serif, accent color, dates right-aligned.
// Theme contract: apply, render-header, section-heading, renderers.

#import "../lib.typ": t, md, fmt-range

#let fonts = ("Helvetica Neue", "Libertinus Serif")
#let accent = rgb("#1f4e79")
#let muted = luma(95)

#let base-size = 10pt
#let small-size = 9pt

#let apply(lang: "en", paper: "a4", body) = {
  set page(paper: paper, margin: (x: 1.8cm, y: 1.6cm))
  set text(font: fonts, size: base-size, lang: lang)
  set par(justify: true, leading: 0.55em)
  set list(indent: 0.2em, body-indent: 0.5em, spacing: 0.45em, marker: text(fill: accent)[•])
  body
}

#let opt(v, f) = if v == none { none } else { f(v) }
#let small-muted(body) = text(size: small-size, fill: muted, body)

#let section-heading(title) = block(above: 1.3em, below: 0.7em, sticky: true, {
  text(size: 10.5pt, weight: "bold", fill: accent, tracking: 0.06em, upper(title))
  v(-0.65em)
  line(length: 100%, stroke: 0.5pt + accent)
})

#let render-header(person, show-photo, ctx) = {
  let contact = (
    opt(person.at("location", default: none), x => md(x, ctx)),
    opt(person.at("email", default: none), e => link("mailto:" + e, e)),
    opt(person.at("phone", default: none), p => link("tel:" + p.replace(" ", ""), p)),
    ..person.at("links", default: ()).map(l => link(l.url, t(l.label, ctx))),
  ).filter(x => x != none)

  let info = {
    text(size: 22pt, weight: "bold", person.name)
    v(0.75em, weak: true)
    opt(person.at("title", default: none), x => text(size: 12pt, fill: accent, md(x, ctx)))
    v(0.7em, weak: true)
    small-muted(contact.join([ #h(0.3em)·#h(0.3em) ]))
  }

  let photo = person.at("photo", default: none)
  if show-photo and photo != none {
    grid(columns: (1fr, auto), column-gutter: 1em, align: horizon,
      info, box(clip: true, radius: 3pt, image("/" + photo, width: 2.8cm)))
  } else { info }
}

#let render-text(sec, items, ctx) = md(sec.at("body", default: none), ctx)

#let render-timeline(sec, items, ctx) = for it in items {
  let role = md(it.at("role", default: none), ctx)
  let org = md(it.at("org", default: none), ctx)
  let loc = md(it.at("location", default: none), ctx)
  let bullets = it.at("bullets", default: none)
  if bullets == none { bullets = () }

  block(above: 1.1em, below: 1.1em, breakable: false, {
    let rows = (strong(role), opt(fmt-range(it, ctx), small-muted))
    if org != none or loc != none { rows += (emph(org), opt(loc, small-muted)) }
    grid(columns: (1fr, auto), column-gutter: 1em, row-gutter: 0.5em, align: (left, right), ..rows)
    if bullets.len() > 0 { block(above: 0.6em, list(..bullets.map(b => md(b, ctx)))) }
  })
}

#let render-grouped(sec, groups, ctx) = grid(
  columns: (auto, 1fr), column-gutter: 1.2em, row-gutter: 0.6em,
  ..groups.map(g => (
    strong(md(g.name, ctx)),
    g.at("items", default: ()).map(x => md(x, ctx)).join([ · ]),
  )).flatten(),
)

#let render-levels(sec, items, ctx) = grid(
  columns: (auto, 1fr), column-gutter: 1.2em, row-gutter: 0.6em,
  ..items.map(it => (strong(md(it.name, ctx)), text(fill: muted, md(it.level, ctx)))).flatten(),
)

#let render-list(sec, items, ctx) = items.map(x => md(x, ctx)).join([ · ])

#let renderers = (
  text: render-text,
  timeline: render-timeline,
  grouped: render-grouped,
  levels: render-levels,
  list: render-list,
)
