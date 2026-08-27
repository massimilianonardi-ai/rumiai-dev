# Raw ChatGPT export — fonte autorevole v2

Fonte: oggetto originale della conversazione estratto da `conversations.json` dell'export ChatGPT caricato il 2026-08-27.

- Titolo nell'export: `[prj] RumiAI architettura`
- Titolo successivamente stabilito dall'utente: `RumiAI architettura`
- Inizio conversazione nell'export: 2026-07-30 08:12:23 +02:00

Questa cartella è aggiuntiva: non sostituisce e non cancella alcun artefatto precedente. La vecchia cartella `chat/2026-08-26 RumiAI architettura/` resta volutamente intatta.

## Contenuto

- `conversation.raw.json.gz` — oggetto JSON completo della conversazione, compresso con gzip. Conserva `mapping`, relazioni parent/children, `current_node`, messaggi, metadati e possibili ramificazioni.
- La trascrizione Markdown leggibile si trova in `../chat/` e copre 48 messaggi canonici.

## Integrità

- JSON non compresso: 120092 byte
- SHA-256 JSON: `16f0fb276af65a35afb9ac8a2a62aad7fae1c90fec211471a03dc3fd55d65200`
- gzip: 32721 byte
- SHA-256 gzip: `f8033fad552daebaca983fdbd1a238e9cf1fd1444d2ff87a24757cc2684d6adc`

## Ricostruzione

```bash
gzip -dc conversation.raw.json.gz > conversation.raw.json
sha256sum conversation.raw.json
```

L'hash risultante deve essere `16f0fb276af65a35afb9ac8a2a62aad7fae1c90fec211471a03dc3fd55d65200`.

Le directory `raw/`, `lossless/` o altri tentativi precedenti eventualmente presenti sono conservate come artefatti storici e non sono la fonte autorevole v2.