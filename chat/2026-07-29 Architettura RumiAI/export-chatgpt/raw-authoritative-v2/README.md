# Raw ChatGPT export — fonte autorevole v2

Fonte: oggetto originale della conversazione `Architettura RumiAI` estratto da `conversations.json` dell'export ChatGPT caricato il 2026-08-27.

Questa cartella è aggiuntiva: non sostituisce e non cancella alcun artefatto precedente.

## Contenuto

- `conversation.raw.json.gz` — oggetto JSON completo della conversazione, compresso con gzip. Conserva `mapping`, relazioni parent/children, `current_node`, messaggi, metadati e possibili ramificazioni; è quindi più informativo della sola trascrizione canonica.
- La trascrizione Markdown leggibile si trova in `../chat/` e copre 124 messaggi canonici.

## Integrità

- JSON non compresso: 351457 byte
- SHA-256 JSON: `605982b7c87a02d2a39ca587ff880c31f0a65dd28e42fddd6a6aabcb575f7b09`
- gzip: 95417 byte
- SHA-256 gzip: `17559ab5a4f1f9a6f856cad5530730a3e9eaa1d511a5b61c43c828858145e990`

## Ricostruzione

```bash
gzip -dc conversation.raw.json.gz > conversation.raw.json
sha256sum conversation.raw.json
```

L'hash risultante deve essere `605982b7c87a02d2a39ca587ff880c31f0a65dd28e42fddd6a6aabcb575f7b09`.

Le directory `raw/`, `lossless/` o altri tentativi precedenti eventualmente presenti sono conservate come artefatti storici e non sono la fonte autorevole v2.