# Raw ChatGPT export — fonte autorevole v2

Fonte: oggetto originale della conversazione `Tabella prodotti IA open source` estratto da `conversations.json` dell'export ChatGPT caricato il 2026-08-27.

Questa cartella è aggiuntiva: non sostituisce e non cancella alcun artefatto precedente.

## Contenuto

- `conversation.raw.json.gz` — oggetto JSON completo della conversazione, compresso con gzip. Conserva `mapping`, relazioni parent/children, `current_node`, messaggi, metadati, riferimenti agli allegati e possibili ramificazioni.
- La trascrizione Markdown leggibile si trova in `../chat/` e copre 178 messaggi canonici.

## Integrità

- JSON non compresso: 409834 byte
- SHA-256 JSON: `8e22f6acaa96567bb02990439093301eae095b90722360529d4148d64c32180e`
- gzip: 118413 byte
- SHA-256 gzip: `71dfe8dda1cf4a58a8bc06e3cc6bd4603a782c3c9be14277ba658d362be2bf49`

## Ricostruzione

```bash
gzip -dc conversation.raw.json.gz > conversation.raw.json
sha256sum conversation.raw.json
```

L'hash risultante deve essere `8e22f6acaa96567bb02990439093301eae095b90722360529d4148d64c32180e`.

Le directory `raw/`, `lossless/` o altri tentativi precedenti eventualmente presenti sono conservate come artefatti storici e non sono la fonte autorevole v2.