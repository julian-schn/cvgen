// Entry point.
// typst compile --root . cv.typ out/cv.pdf --input variant=default --input lang=de

#import "template/theme.typ": apply
#import "template/sections.typ": render-header, render-section

#let data = yaml("/data/cv.yaml")
#let variant-name = sys.inputs.at("variant", default: "default")
#let variant = yaml("/data/variants/" + variant-name + ".yaml")

#let fallback = data.meta.default_lang
#let lang = sys.inputs.at("lang", default: variant.at("lang", default: fallback))
#assert(
  lang in data.meta.languages,
  message: "unknown lang '" + lang + "'. Known: " + data.meta.languages.join(", "),
)
#let ctx = (lang: lang, fallback: fallback, labels: data.labels)

#set document(title: data.person.name + " – CV", author: data.person.name)
#show: apply.with(lang: lang)

#render-header(data.person, variant.at("photo", default: false), ctx)

#for entry in variant.sections {
  let e = if type(entry) == str { (id: entry) } else { entry }
  assert(
    e.id in data.sections,
    message: "variant '" + variant-name + "': unknown section '" + e.id
      + "'. Known: " + data.sections.keys().join(", "),
  )
  if e.at("enabled", default: true) {
    render-section(data.sections.at(e.id), e, variant, ctx)
  }
}
