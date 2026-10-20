# Archive

Charts in `archive/charts/<name>` are retired from the catalog. They are kept in git history and on disk for reference, but:

- they are **not published** to the Helm repository (the publish workflow only iterates `charts/*`, staging and production alike),
- they are **not linted or built** (workflows only look at `charts/`),
- they are **not checked for dependency updates** (the deps checker skips `archive/`).

A chart is archived when it is abandoned upstream, experimental or hobby-grade, ships a broken or unmaintained image, or has no realistic use.

Archiving does not remove already published versions. To delete a chart from the Helm repository, add its name to `removed-charts.txt`.

## Restore a chart

```
git mv archive/charts/<name> charts/<name>
```

Then check that the chart still lints and installs (images, deprecated APIs, upstream state) and open a PR. Remove the name from `removed-charts.txt` if it was listed there.

## Archived charts

| Chart | Reason |
| --- | --- |
| maybe-finance | Upstream `maybe-finance/maybe` was archived in July 2025; the image is frozen at 0.6.0. |
