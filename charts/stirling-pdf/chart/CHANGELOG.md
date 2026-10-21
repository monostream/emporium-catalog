# 0.1.0

- New chart: Stirling-PDF 3.2.0, official `stirlingtools/stirling-pdf` image, ultra-lite variant (MIT core only, no proprietary login/SSO module), requires Emporium v0.5.0.
- Stateless: scratch space is an emptyDir; no database or volume.
- Emporium login is the only access control (the open-source build has no accounts or SSO).
- Tested on Emporium 0.5.0-rc.12 (2026-10-21): install, Emporium login, merge of three PDFs through the UI, uninstall without leftovers.
