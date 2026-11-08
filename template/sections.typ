// One renderer per section type. Add a type: write a function, register it in `renderers`.

#import "lib.typ": t, md, fmt-range, select-items
#import "theme.typ": accent, muted, small-muted, section-heading

#let opt(v, f) = if v == none { none } else { f(v) }

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

// entry: normalized variant entry, e.g. (id: "projects", include_tags: ("dev",), limit: 3)
#let render-section(sec, entry, variant, ctx) = {
  let kind = sec.at("type", default: none)
  assert(
    kind != none and kind in renderers,
    message: "section '" + entry.id + "': unknown type " + repr(kind)
      + ". Known: " + renderers.keys().join(", "),
  )
  let items-key = if kind == "grouped" { "groups" } else { "items" }
  let items = select-items(sec.at(items-key, default: ()), entry, variant)
  if kind != "text" and items.len() == 0 { return }

  let title = entry.at("title", default: sec.at("title", default: entry.id))
  section-heading(md(title, ctx))
  renderers.at(kind)(sec, items, ctx)
}

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
