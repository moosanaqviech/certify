Official vendor logos for the catalog's vendor headers and card fallbacks.

Expected files (mapped in `lib/widgets/cert_visuals.dart`, `BrandMark.logoAssets`):

- `databricks.png`
- `aws.png`

Use the vendor's official asset from its brand page, in the variant meant for
dark backgrounds; it is rendered as supplied (not recoloured). Square-ish PNGs
at 3x (~90px) or larger. If a file is missing the UI falls back to the
monogram from `catalog.json`.
