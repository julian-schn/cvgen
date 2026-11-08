# cvgen

CV content lives in `data/cv.yaml`, rendered with Typst.

- `data/cv.yaml` — all content. Text fields are either a plain string or `{en: ..., de: ...}`.
- `data/variants/*.yaml` — which sections appear, in which order, with optional item filters.
- `template/` — Typst template (`theme.typ` for styling, `sections.typ` for section renderers).

## Build

```sh
make                      # all variants × languages into out/
make de                   # all variants in German
make one VARIANT=short LANG_=de
make watch                # live preview of default/en
```

Raw command:

```sh
typst compile --root . cv.typ out/cv.pdf --input variant=short --input lang=de
```

Variant file names must not contain `-` (the Makefile splits `cv-<variant>-<lang>` on it).
