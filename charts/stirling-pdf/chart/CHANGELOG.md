# 0.1.1

Published on 22 October 2026

- stirling-pdf from 3.2.0 to 3.2.1 (patch release; image repository is written without the `docker.io/` prefix, same image, so `emporium chart updates` can track it).

# 0.1.0

- New chart: Stirling-PDF 3.2.0, official `stirlingtools/stirling-pdf` image, ultra-lite variant (MIT core only, no proprietary login/SSO module), requires Emporium v0.5.0.
- Stateless: scratch space is an emptyDir; no database or volume.
- Emporium login is the only access control (the open-source build has no accounts or SSO).
- Ingress proxy-body-size follows the maximum upload size (limit 1 to 999 MB, as upstream accepts).
- README lists the ultra-lite limits (no WeasyPrint, qpdf, Ghostscript); temp files are deleted with the pod.
- Tested on Emporium 0.5.0-rc.12 (2026-10-21): install, Emporium login, merge of three PDFs through the UI, uninstall without leftovers.
