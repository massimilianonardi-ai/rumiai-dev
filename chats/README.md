# Public ChatGPT shared-link archives

Status: **Current / operator-authorized archival workflow**

This directory contains **non-authoritative** archives, not development rules.
The legacy automatic GitHub chat mirror remains disabled; the separate Google
Drive mirror is unaffected. This is an explicitly requested, individual
publication workflow for **public ChatGPT shared links** in a **public** Git
repository. Review each public share for sensitive content before requesting
publication; Git commits retain contents in history.

## Request from ChatGPT

Ask ChatGPT to export a supplied `https://chatgpt.com/share/...` URL to an
explicit topic. ChatGPT creates a GitHub issue in this repository through the
connected GitHub app:

- Issue title: `ChatGPT export request`
- Issue body: JSON with exactly `url` and `topic`, for example:

```json
{"url":"https://chatgpt.com/share/<share-id>","topic":"AI"}
```

Only an issue opened by the repository owner is authorized to start the
workflow. The request body is treated as untrusted data, never shell code.
The topic must be a single safe directory name. The original title and the
date of the **first user message** are read from the captured public share,
converted to `Europe/Rome` for naming, and verified; neither is supplied by
the caller. Generic HTML-renderer titles, shared-link creation dates and
export dates must not be used as substitutes.

## Result

```text
chats/
  <topic>/
    <YYYY-MM-DD> <original title>/
      index.html
      assets/
      ... other original local resources ...
```

The accepted PoC 068 exporter retains original CSS and local image/font
resources. The publisher copies the complete output directory **without
rewriting the HTML**, validates referenced resources and the script-blocking
policy, and commits forward-only. It never overwrites an existing archive at
the same path. If the layout or title/date evidence is not supported, the job
fails without publishing a partial archive. Raw HTML bodies, CDP evidence,
Chrome profiles and private diagnostics are not committed.

The issue receives a GitHub link on success or a failure notice. A GitHub
Actions Ubuntu runner uses the pinned source revision of
`massimilianonardi-ai/rumiai-dev-PoCs`; the workflow source is
`.github/workflows/chatgpt-export.yml`.

**Citation policy (operator correction, 2026-10-30):** Citations are
archived as visible controls where captured, but neither the reachability
of external sources nor citation click behavior is guaranteed or required.
The export **must not fail solely because citation URLs cannot be verified**;
no fixed number of grouped or singleton citations is assumed. Inert citation
controls are acceptable. The separate requirements for preserving visible
conversation content, local resource integrity, script blocking, valid
original title/date and safe Git publication remain in force. A successful
archive does not certify completeness of underlying raw conversation data.
