# Decisione — Text encoding interno e transcoding al boundary

Date: 2026-08-28  
Status: **Partially superseded 2026-09-02**

## Invarianti ancora validi

Resta accettato che:

- lingua e encoding siano concetti distinti;
- i cataloghi RumiAI siano UTF-8;
- il codeset non faccia parte dell'identità `language_TERRITORY` né del pathname del catalogo;
- il testo controllato internamente da RumiAI usi UTF-8;
- un eventuale futuro supporto a encoding esterni differenti appartenga al boundary/adattamento e non richieda cataloghi duplicati.

## Contratto bootstrap superseded

Non esiste più una preferenza/configurazione bootstrap dell'encoding.

Sono superseded:

```text
RumiAI_LANGUAGE
RumiAI_TEXT_ENCODING
conf/bootstrap/i18n/text-encoding
selector i18n dell'encoding
fallback da un encoding richiesto
```

Il runtime corrente fissa:

```text
m_TEXT_ENCODING=UTF-8
```

La lingua corrente è selezionata indipendentemente mediante:

```text
lang/current -> <language_TERRITORY>
```

Il bootstrap non negozia né normalizza encoding esterni.

## Autorità corrente

```text
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/LANG-BOOTSTRAP.md
decisions/rumiai-os/2026-09-02-bootstrap-runtime-standards.md
```

Il precedente modello di encoding configurabile resta rationale storico per una possibile futura capability di boundary, non contratto bootstrap corrente.
