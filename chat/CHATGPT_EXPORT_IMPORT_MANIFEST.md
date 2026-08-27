# Manifest globale — import ChatGPT export

Fonte fornita dall'utente: `chatgpt_export.zip`.

## Integrità della fonte

- SHA-256 ZIP: `817eda8a071d013261e6fda8f18ae679794f2702f29f9ad3e79906829bb31bd2`
- `conversations.json`: 1179221 byte
- SHA-256 `conversations.json`: `7e2594f813d60eac9dae6013b1c8e5dbc96c1cc5d76298b3cc647a73f1254725`

## Conversazioni importate

Sono state escluse le conversazioni dedicate alla generazione di immagini, come richiesto.

| Cartella repository | Titolo nell'export | Inizio | Messaggi user/assistant ramo canonico | Stato trascrizione | Stato raw |
|---|---|---|---:|---|---|
| `2026-07-29 Architettura RumiAI` | `Architettura RumiAI` | 2026-07-29 07:58:21 +02:00 | 124 | completa 124/124 | v5 verificata |
| `2026-07-30 RumiAI architettura` | `[prj] RumiAI architettura` | 2026-07-30 08:12:23 +02:00 | 48 | completa 48/48 | v5 verificata con correzione 002a+002b |
| `2026-07-30 Tabella prodotti IA open source` | `Tabella prodotti IA open source` | 2026-07-30 11:45:05 +02:00 | 178 | completa 178/178 | v5 verificata con segmenti correttivi |

Totale: **350/350 messaggi user/assistant del ramo canonico**.

Per `Tabella prodotti IA open source`, 174 messaggi contengono testo e 4 sono messaggi senza testo ma con allegati/metadati. Il raw JSON conserva anche questi ultimi.

## Raw JSON originali

| Chat | Byte JSON | SHA-256 JSON |
|---|---:|---|
| Architettura RumiAI | 351457 | `605982b7c87a02d2a39ca587ff880c31f0a65dd28e42fddd6a6aabcb575f7b09` |
| RumiAI architettura | 120092 | `16f0fb276af65a35afb9ac8a2a62aad7fae1c90fec211471a03dc3fd55d65200` |
| Tabella prodotti IA open source | 409834 | `8e22f6acaa96567bb02990439093301eae095b90722360529d4148d64c32180e` |

I raw sono archiviati in `export-chatgpt/raw-authoritative-v5/` come bzip2 + Base64 segmentato. Ogni cartella contiene `MANIFEST.md` con la sequenza esatta da usare. Le versioni v2/v3/v4 e i segmenti v5 dichiarati non autorevoli sono mantenuti esclusivamente come storico e non devono essere usati per la ricostruzione.

## Cartella rinominata

La conversazione `[prj] RumiAI architettura` è stata successivamente rinominata dall'utente in `RumiAI architettura`. L'export dimostra che la data di inizio è il **30 luglio 2026**. La precedente cartella `2026-08-26 RumiAI architettura` non è stata cancellata o modificata distruttivamente.

## Politica di conservazione

Durante l'importazione non sono stati cancellati file preesistenti. Quando un trasferimento è risultato troncato o con SHA differente, il file è stato lasciato come storico e affiancato da una copia correttiva lossless esplicitamente indicata nel manifest autorevole.

Per una verifica automatica usare `chat/verify_chatgpt_export_archive.py`.