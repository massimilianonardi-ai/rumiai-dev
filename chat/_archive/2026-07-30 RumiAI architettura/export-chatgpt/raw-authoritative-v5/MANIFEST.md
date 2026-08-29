# Raw authoritative v5 — RumiAI architettura

Fonte: `chatgpt_export.zip/conversations.json`.

Titolo nell'export: `[prj] RumiAI architettura`. Titolo successivo indicato dall'utente: `RumiAI architettura`.

- Inizio: `2026-07-30T08:12:23.234577+02:00`
- Nodi mapping: 49
- Messaggi user/assistant sul ramo canonico: 48
- Messaggi testuali sul ramo canonico: 48
- JSON raw: 120092 byte
- SHA-256 JSON raw: `16f0fb276af65a35afb9ac8a2a62aad7fae1c90fec211471a03dc3fd55d65200`
- bzip2: 27135 byte
- SHA-256 bzip2: `ec4a5eb7b68e1aebd38dbcaf5ef2481fa34be0cc6e4cec59fdbcc1e8f2327742`
- Base64: 36180 caratteri

## Sequenza autorevole

Concatenare, senza separatori e in questo ordine:

`001 002a 002b 003 004 005`

Il file originale `002` presente nella cartella è conservato come storico ma **non va usato**: durante la verifica SHA Git risultava diverso dall'originale locale pur avendo la stessa dimensione. `002a` + `002b` ne costituiscono la copia lossless verificata.

## Ricostruzione

```bash
cat \
  segments/conversation.raw.json.bz2.b64.001 \
  segments/conversation.raw.json.bz2.b64.002a \
  segments/conversation.raw.json.bz2.b64.002b \
  segments/conversation.raw.json.bz2.b64.003 \
  segments/conversation.raw.json.bz2.b64.004 \
  segments/conversation.raw.json.bz2.b64.005 \
  | base64 --decode \
  | bzip2 --decompress > conversation.raw.json
sha256sum conversation.raw.json
```

L'hash risultante deve essere:

`16f0fb276af65a35afb9ac8a2a62aad7fae1c90fec211471a03dc3fd55d65200`

Le directory raw v2/v3/v4, il file v5 `002` e altri tentativi non elencati nella sequenza sopra sono conservati solo come storico.