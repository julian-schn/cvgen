// Entry point.
// typst compile --root . cv.typ out/cv.pdf --input variant=default --input lang=de
// Optional inputs: data=<path to yaml>, theme=<classic|jake>

#import "template/sections.typ": render-section
#import "template/themes/classic.typ" as classic

#let themes = (classic: classic)

#let data = yaml("/" + sys.inputs.at("data", default: "data/cv.example.yaml"))
#let variant-name = sys.inputs.at("variant", default: "default")
#let variant = yaml("/data/variants/" + variant-name + ".yaml")

#let theme-name = sys.inputs.at("theme", default: variant.at("theme", default: "classic"))
#assert(
  theme-name in themes,
  message: "unknown theme '" + theme-name + "'. Known: " + themes.keys().join(", "),
)
#let theme = themes.at(theme-name)

#let fallback = data.meta.default_lang
#let lang = sys.inputs.at("lang", default: variant.at("lang", default: fallback))
#assert(
  lang in data.meta.languages,
  message: "unknown lang '" + lang + "'. Known: " + data.meta.languages.join(", "),
)
#let ctx = (lang: lang, fallback: fallback, labels: data.labels)

#set document(title: data.person.name + " – CV", author: data.person.name)
#show: theme.apply.with(lang: lang, paper: variant.at("paper", default: "a4"))

#(theme.render-header)(data.person, variant.at("photo", default: false), ctx)

#for entry in variant.sections {
  let e = if type(entry) == str { (id: entry) } else { entry }
  assert(
    e.id in data.sections,
    message: "variant '" + variant-name + "': unknown section '" + e.id
      + "'. Known: " + data.sections.keys().join(", "),
  )
  if e.at("enabled", default: true) {
    render-section(theme, data.sections.at(e.id), e, variant, ctx)
  }
}
