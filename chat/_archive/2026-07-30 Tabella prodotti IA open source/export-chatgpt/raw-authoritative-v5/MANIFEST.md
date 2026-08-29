# Raw authoritative v5 — Tabella prodotti IA open source

Fonte: `chatgpt_export.zip/conversations.json`.

- Titolo export: `Tabella prodotti IA open source`
- Inizio: `2026-07-30T11:45:05.169658+02:00`
- Nodi mapping: 179
- Messaggi user/assistant sul ramo canonico: 178
- Messaggi testuali sul ramo canonico: 174
- Messaggi senza testo ma con allegati/metadati: 4
- JSON raw: 409834 byte
- SHA-256 JSON raw: `8e22f6acaa96567bb02990439093301eae095b90722360529d4148d64c32180e`
- bzip2: 81857 byte
- SHA-256 bzip2: `cf26e0bcb2e143e4e8a3db1d914947e9d53e48c3026ecd6c4c0f464b70829497`
- Base64: 109144 caratteri

## Sequenza autorevole

Concatenare, senza separatori e in questo ordine:

`001 002 003 004a 004b 005 006 007 008 009 010a 010b 011a 011b 012 013a 013b 014 015`

Correzioni verificate:

- `004` non è autorevole; usare `004a` + `004b`.
- `010` non è presente come segmento singolo autorevole; usare `010a` + `010b`.
- `011` è stato bloccato durante il trasferimento; `011a` + `011b` sono la divisione lossless dell'originale.
- `013` presente nella cartella non è autorevole; usare `013a` + `013b`.

## Ricostruzione

```bash
cat \
  segments/conversation.raw.json.bz2.b64.001 \
  segments/conversation.raw.json.bz2.b64.002 \
  segments/conversation.raw.json.bz2.b64.003 \
  segments/conversation.raw.json.bz2.b64.004a \
  segments/conversation.raw.json.bz2.b64.004b \
  segments/conversation.raw.json.bz2.b64.005 \
  segments/conversation.raw.json.bz2.b64.006 \
  segments/conversation.raw.json.bz2.b64.007 \
  segments/conversation.raw.json.bz2.b64.008 \
  segments/conversation.raw.json.bz2.b64.009 \
  segments/conversation.raw.json.bz2.b64.010a \
  segments/conversation.raw.json.bz2.b64.010b \
  segments/conversation.raw.json.bz2.b64.011a \
  segments/conversation.raw.json.bz2.b64.011b \
  segments/conversation.raw.json.bz2.b64.012 \
  segments/conversation.raw.json.bz2.b64.013a \
  segments/conversation.raw.json.bz2.b64.013b \
  segments/conversation.raw.json.bz2.b64.014 \
  segments/conversation.raw.json.bz2.b64.015 \
  | base64 --decode \
  | bzip2 --decompress > conversation.raw.json
sha256sum conversation.raw.json
```

L'hash risultante deve essere:

`8e22f6acaa96567bb02990439093301eae095b90722360529d4148d64c32180e`

I file raw precedenti e i segmenti v5 non elencati nella sequenza autorevole restano nel repository solo come storico, in conformità alla richiesta di non cancellare nulla.