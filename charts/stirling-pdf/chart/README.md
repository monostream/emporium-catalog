# Stirling-PDF

Stirling-PDF is a self-hosted toolbox for PDF files: merge, split, rotate, reorder, compress, convert, sign, redact, watermark, edit metadata and much more, all in your browser, on your own server. Your documents never leave your Emporium.

## Features

- 50+ tools: merge, split, organise pages, compress, convert PDF to and from images, add or remove passwords, watermark, sign, redact and flatten
- Automation pipelines and a REST API for every tool
- Works with files up to a configurable size (200 MB by default)
- Files are processed in temporary space and are not stored: nothing is kept after a restart
- Interface in 40+ languages

## Perfect for

Anyone who handles PDFs every day and does not want to upload contracts, invoices or scans to a free web service.

## Good to know

- This chart runs the **ultra-lite** image (`stirlingtools/stirling-pdf:<version>-ultra-lite`), which is built from the MIT-licensed core only. Upstream's default and fat images include a proprietary module (login, SSO, audit) under a separate commercial licence that requires a subscription for production use; this chart does not use them.
- The ultra-lite build has no accounts, roles or single sign-on of its own. Sign-in is the Emporium login in front of the app, so every Emporium user who may open the app can use all tools.
- Ultra-lite has no LibreOffice, OCR (Tesseract/OCRmyPDF) or Calibre, so Word/Excel/PowerPoint conversion, OCR and e-book conversion are unavailable. Everything else works.
- The REST API (`/api/v1/*`) has no API keys upstream, so it stays behind the Emporium login too; scripts need an Emporium session.
- Nothing is persisted. Uploads and results live in temporary space of the pod, capped at 4 GiB.
