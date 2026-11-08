# AGENTS.md

Guide for coding agents (and humans) changing this repo. Read this before editing
the data schema, a theme, or adding a template.

## Core idea

**One data file, many renderings.** All CV content and render presets live in a single
YAML file. Typst templates (themes) only decide *how* things look, never *what* is shown.

```
data/cv.example.yaml   # committed example (fictional John Doe)
data/cv.yaml           # the user's real CV — gitignored, NEVER commit or print it
cv.typ                 # entry point: loads data, picks variant + theme + lang, renders
template/lib.typ       # shared helpers: t, md, fmt-date, fmt-range, select-items
template/sections.typ  # render-section: filters items, draws heading, calls theme renderer
template/themes/*.typ  # one file per theme (classic, jake)
Makefile               # builds every variant × language into out/
```

`make` uses `data/cv.yaml` if present, else the example. Direct call:
`typst compile --root . cv.typ out.pdf --input data=data/cv.yaml --input variant=jake --input lang=de [--input theme=classic]`

## Data model

### Text values
Any text field is either a plain string (all languages) or a per-language dict:
`{ en: Experience, de: Berufserfahrung }`. Missing language → `meta.default_lang`.
Strings are evaluated as Typst markup (`*bold*`, `_italic_`, `#link("url")[text]`),
so escape `#`, `$`, `@`, `<` with `\` when they are literal.
Dates are quoted `"YYYY-MM"` or `"YYYY"`. `end: null` = "present"; no `end` key = single date.

### Top-level keys
| key | purpose |
| --- | --- |
| `meta` | `default_lang`, `languages` (allowed `lang` inputs) |
| `labels` | translatable UI strings (`present`, `months`). Add new ones here, not in themes |
| `person` | header: `name`, `title`, `email`, `phone`, `location`, `photo`, `links[{label,url}]` |
| `sections` | map of section id → section (see types below) |
| `variants` | map of preset name → render config (see below) |

### Section types
Every section has `type` and `title`. The type decides which renderer runs and which fields it reads:

| type | fields read | typical use |
| --- | --- | --- |
| `text` | `body` | summary, objective |
| `timeline` | `items[]`: `id`, `role`, `org`, `location`, `start`, `end`, `tech`, `bullets[]`, `tags[]` | experience, education, projects, volunteering, awards |
| `grouped` | `groups[]`: `name`, `items[]` | skills by category |
| `levels` | `items[]`: `name`, `level` | spoken languages, proficiency |
| `list` | `items[]` (text values) | interests, certifications |

All item fields are optional; renderers must use `.at(key, default: none)` and skip what is missing.

### Variants
```yaml
variants:
  jake:
    theme: jake               # classic | jake; CLI --input theme= overrides
    lang: en                  # CLI --input lang= overrides
    paper: a4                 # a4 | us-letter
    photo: false
    sections:                 # order = PDF order; omitted = hidden
      - education
      - { id: projects, include_tags: [dev], limit: 3, title: { en: Selected Projects } }
      - { id: skills, enabled: false }
    hide_items: [tutor]       # item ids dropped everywhere
```
Variant names must not contain `-` (the Makefile splits `cv-<variant>-<lang>`).
`make` discovers variants by reading the keys under `variants:` — keep that block at
top level with two-space indented names.

## How to extend

Pick the **smallest** change that works. In order of preference:

### 1. New section (data only)
The resume needs "Awards", "Publications", "Volunteering", "Certifications"…
Add it under `sections` using an existing type, then list its id in the variants that should show it.
No template change. Example:
```yaml
awards:
  type: timeline
  title: { en: Awards, de: Auszeichnungen }
  items:
    - { id: hackathon, role: 1st Place, org: Example Hackathon, start: "2023-05" }
```

### 2. New optional field on an existing type
E.g. a `url` on projects, a `gpa` on education, a `subtitle` on the person.
1. Add the field to `data/cv.example.yaml` (both languages if it is text).
2. Read it in **every** theme's renderer with `.at("field", default: none)` and render
   nothing when it is `none`. Themes may choose to ignore a field, but must not crash.
3. Document it in the "Section types" table above.

### 3. New section type
Only when no existing type fits the shape (e.g. a two-column `table`, `publications` with authors/venue).
1. Write `render-<type>(sec, items, ctx)` in **every** theme and register it in that theme's `renderers` dict.
   Missing in one theme → that theme panics with "unknown type".
2. If the type stores its items under a key other than `items`, update `items-key` in
   `template/sections.typ` (currently only `grouped` → `groups`).
3. Add an example section to `data/cv.example.yaml` and the table above.

### 4. New UI label
Text a theme prints itself (e.g. "References available on request") goes into `labels`
with all languages and is read via `t(ctx.labels.<key>, ctx)`. Never hardcode language-specific text in a theme.

## Theme contract

A theme is one file in `template/themes/` exporting exactly these names:

| export | signature | job |
| --- | --- | --- |
| `apply` | `(lang: "en", paper: "a4", body) -> content` | page size, margins, fonts, global set/show rules |
| `render-header` | `(person, show-photo, ctx) -> content` | name, title, contact line, optional photo |
| `section-heading` | `(title) -> content` | section title; use `block(sticky: true)` so it stays with its content |
| `renderers` | dict `type → (sec, items, ctx) -> content` | one entry per section type (see table) |

`ctx` is `(lang, fallback, labels)`. `items` are already filtered by the variant.
Import helpers from `"../lib.typ"`:

- `t(v, ctx)` — pick the language value (use for labels, URLs' display text)
- `md(v, ctx)` — `t` + evaluate as Typst markup (use for any user text)
- `fmt-range(item, ctx)` — `"Mar 2024 – present"` from `start`/`end`
- `fmt-date(d, ctx)` — single date

Register the theme in `cv.typ`: add `#import "template/themes/<name>.typ" as <name>` and add it to the `themes` dict.

Rules for themes:
- Prefer fonts bundled with Typst (New Computer Modern, Libertinus Serif, DejaVu Sans Mono)
  or list a bundled fallback; unknown fonts produce warnings on other machines.
- Image paths are root-relative: `image("/" + person.photo)`.
- Keep entries `breakable: false` so an entry never splits across pages.

## Porting a template (LaTeX, Word, another Typst package)

1. **Map the original's building blocks onto the contract.** Most resume templates have the same four:
   | original (LaTeX example) | here |
   | --- | --- |
   | preamble: geometry, fonts, `\titleformat` | `apply`, `section-heading` |
   | heading block with name + contacts | `render-header` |
   | `\resumeSubheading{a}{b}{c}{d}` | `timeline` renderer: `role`, `start/end`, `org`, `location` |
   | `\resumeProjectHeading{name \| tech}{date}` | `timeline` with `tech` set |
   | `\resumeItem{...}` | `bullets` |
   | skills `\textbf{Cat}: a, b` | `grouped` renderer |
2. **Copy the measurements, not the code.** Translate margins, font sizes, spacing (`\vspace{-4pt}` →
   `block(above:/below:)`), small caps (`smallcaps()`), rules (`line(length: 100%)`).
3. **Fill every renderer**, even for types the original never shows (a compact fallback is fine).
4. **Field the original needs but the data lacks?** Add it as an optional field (extension path 2),
   never a theme-specific data file.
5. Add a variant using the theme to `data/cv.example.yaml`, render, compare side by side with the original.
6. Credit the original author and license at the top of the theme file and in README "Credits".

## Verify every change

```sh
make clean && make 2>&1 | grep -iE "warn|error"       # must print nothing
typst compile --root . cv.typ out/check.png --ppi 100 --input variant=<v> --input lang=de
```
Look at the PNG for both languages and every theme you touched. When the example
content changes, regenerate `docs/preview-*.png` (`--ppi 80`, variants `jake` and `default`).

## Conventions

- Conventional commits: `type(scope): subject`, lowercase, imperative. One logical change per commit.
- Never commit `data/cv.yaml`, PDFs, or anything with the user's real personal data.
- The example person stays fictional (John Doe, example.com).
