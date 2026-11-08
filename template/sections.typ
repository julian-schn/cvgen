// Theme-independent section dispatch. Rendering itself lives in template/themes/*.typ.

#import "lib.typ": md, select-items

// theme: module from template/themes/
// entry: normalized variant entry, e.g. (id: "projects", include_tags: ("dev",), limit: 3)
#let render-section(theme, sec, entry, variant, ctx) = {
  let kind = sec.at("type", default: none)
  assert(
    kind != none and kind in theme.renderers,
    message: "section '" + entry.id + "': unknown type " + repr(kind)
      + ". Known: " + theme.renderers.keys().join(", "),
  )
  let items-key = if kind == "grouped" { "groups" } else { "items" }
  let items = select-items(sec.at(items-key, default: ()), entry, variant)
  if kind != "text" and items.len() == 0 { return }

  let title = entry.at("title", default: sec.at("title", default: entry.id))
  (theme.section-heading)(md(title, ctx))
  theme.renderers.at(kind)(sec, items, ctx)
}
