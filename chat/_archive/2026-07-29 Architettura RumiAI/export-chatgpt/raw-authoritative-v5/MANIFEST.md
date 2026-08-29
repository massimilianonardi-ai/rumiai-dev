# Raw authoritative v5 — Architettura RumiAI

Fonte: `chatgpt_export.zip/conversations.json`.

Questa è la sequenza raw autorevole dell'oggetto conversazione completo, inclusi mapping, metadati e ramificazioni.

- Titolo export: `Architettura RumiAI`
- Inizio: `2026-07-29T07:58:21.927712+02:00`
- Nodi mapping: 126
- Messaggi user/assistant sul ramo canonico: 124
- Messaggi testuali sul ramo canonico: 124
- JSON raw: 351457 byte
- SHA-256 JSON raw: `605982b7c87a02d2a39ca587ff880c31f0a65dd28e42fddd6a6aabcb575f7b09`
- bzip2: 68023 byte
- SHA-256 bzip2: `b7a194b2c00a690636ce1c0827b9e97d0088dbf72b4730ddb6b7270f0c1b560a`
- Base64: 90700 caratteri

## Sequenza autorevole

Concatenare, senza separatori e in questo ordine:

`001 002 003 004 005 006 007 008 009 010 011 012 013`

I file si trovano in `segments/` e hanno prefisso `conversation.raw.json.bz2.b64.`.

## Ricostruzione

```bash
cat segments/conversation.raw.json.bz2.b64.{001,002,003,004,005,006,007,008,009,010,011,012,013} \
  | base64 --decode \
  | bzip2 --decompress > conversation.raw.json
sha256sum conversation.raw.json
```

L'hash risultante deve essere:

`605982b7c87a02d2a39ca587ff880c31f0a65dd28e42fddd6a6aabcb575f7b09`

Le directory raw precedenti v2/v3/v4 e gli eventuali tentativi v5 non elencati in questa sequenza sono conservati solo come storico e non sono sorgenti autorevoli.