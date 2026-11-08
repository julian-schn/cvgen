// Jake's Resume theme, a Typst port of the LaTeX template by Jake Gutierrez
// (https://github.com/jakegut/resume, MIT), itself based on sb2nov/resume.
// Theme contract: apply, render-header, section-heading, renderers.

#import "../lib.typ": t, md, fmt-range

#let font = "New Computer Modern" // bundled with Typst
#let opt(v, f) = if v == none { none } else { f(v) }

#let apply(lang: "en", paper: "a4", body) = {
  set page(paper: paper, margin: (x: 0.5in, y: 0.5in))
  set text(font: font, size: 11pt, lang: lang)
  set par(justify: false, leading: 0.5em)
  set list(indent: 0.15in, body-indent: 0.5em, spacing: 0.45em)
  show link: underline
  body
}

#let section-heading(title) = block(above: 1em, below: 0.6em, sticky: true, {
  text(size: 13pt, smallcaps(title))
  v(-0.75em)
  line(length: 100%, stroke: 0.5pt)
})

#let render-header(person, show-photo, ctx) = {
  let contact = (
    opt(person.at("phone", default: none), p => p),
    opt(person.at("email", default: none), e => link("mailto:" + e, e)),
    ..person.at("links", default: ()).map(l => link(l.url, t(l.label, ctx))),
  ).filter(x => x != none)

  align(center, {
    text(size: 25pt, weight: "bold", smallcaps(person.name))
    v(0.6em, weak: true)
    text(size: 10pt, contact.join([ #h(0.2em)|#h(0.2em) ]))
  })
}

#let render-text(sec, items, ctx) = text(size: 10pt, md(sec.at("body", default: none), ctx))

// Row 1: **role** (| _tech_)  ... dates
// Row 2: _org_                ... _location_
#let render-timeline(sec, items, ctx) = for it in items {
  let role = md(it.at("role", default: none), ctx)
  let tech = md(it.at("tech", default: none), ctx)
  let org = md(it.at("org", default: none), ctx)
  let loc = md(it.at("location", default: none), ctx)
  let bullets = it.at("bullets", default: none)
  if bullets == none { bullets = () }

  let head = if tech != none { [*#role* #h(0.2em)|#h(0.2em) #emph(text(size: 10pt, tech))] } else { strong(role) }
  let date = opt(fmt-range(it, ctx), d => text(size: 10pt, d))

  block(above: 0.75em, below: 0.75em, breakable: false, {
    let rows = (head, date)
    if org != none or loc != none {
      rows += (opt(org, o => emph(text(size: 10pt, o))), opt(loc, l => emph(text(size: 10pt, l))))
    }
    grid(columns: (1fr, auto), column-gutter: 1em, row-gutter: 0.45em, align: (left, right), ..rows)
    if bullets.len() > 0 {
      block(above: 0.5em, text(size: 10pt, list(..bullets.map(b => md(b, ctx)))))
    }
  })
}

// **Languages**: Python, TypeScript, Rust
#let render-grouped(sec, groups, ctx) = block(inset: (left: 0.15in), text(size: 10pt, {
  for g in groups {
    [*#md(g.name, ctx)*: #g.at("items", default: ()).map(x => md(x, ctx)).join([, ])]
    linebreak()
  }
}))

#let render-levels(sec, items, ctx) = block(inset: (left: 0.15in), text(size: 10pt,
  items.map(it => [*#md(it.name, ctx)*: #md(it.level, ctx)]).join([ #h(0.2em)|#h(0.2em) ]),
))

#let render-list(sec, items, ctx) = block(inset: (left: 0.15in), text(size: 10pt,
  items.map(x => md(x, ctx)).join([, ]),
))

#let renderers = (
  text: render-text,
  timeline: render-timeline,
  grouped: render-grouped,
  levels: render-levels,
  list: render-list,
)
