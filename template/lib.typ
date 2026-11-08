// Data helpers: translation, dates, item filtering.
// ctx = (lang: "de", fallback: "en", labels: data.labels)

// Pick the value for ctx.lang from a {en: .., de: ..} dict.
// Plain values pass through unchanged.
#let t(v, ctx) = {
  if type(v) != dictionary { return v }
  if ctx.lang in v { v.at(ctx.lang) }
  else if ctx.fallback in v { v.at(ctx.fallback) }
  else { v.values().first() }
}

// Translate, then render strings as Typst markup (*bold*, #link(..)[..]).
#let md(v, ctx) = {
  let s = t(v, ctx)
  if s == none { none }
  else if type(s) == str { eval(s, mode: "markup") }
  else { [#s] }
}

// "2024-03" -> "Mar 2024", "2024" -> "2024", none -> "present".
#let fmt-date(d, ctx) = {
  if d == none { return t(ctx.labels.present, ctx) }
  let parts = str(d).split("-")
  if parts.len() >= 2 {
    let month = t(ctx.labels.months, ctx).at(int(parts.at(1)) - 1)
    month + " " + parts.at(0)
  } else { parts.at(0) }
}

// No start -> none. No end key -> single date. end: null -> "... – present".
#let fmt-range(item, ctx) = {
  if "start" not in item { return none }
  let start = fmt-date(item.start, ctx)
  if "end" in item { start + " – " + fmt-date(item.end, ctx) } else { start }
}

// Apply variant filters: hide_items (global), include_tags and limit (per section entry).
#let select-items(items, entry, variant) = {
  let hidden = variant.at("hide_items", default: none)
  if hidden == none { hidden = () }
  let out = items.filter(it => type(it) != dictionary or it.at("id", default: none) not in hidden)

  let tags = entry.at("include_tags", default: none)
  if tags != none {
    out = out.filter(it => type(it) == dictionary and it.at("tags", default: ()).any(tg => tg in tags))
  }

  let limit = entry.at("limit", default: none)
  if limit != none { out = out.slice(0, calc.min(limit, out.len())) }
  out
}
