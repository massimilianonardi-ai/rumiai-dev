# Decisione — Messaggi `lang` e campi strutturati

Date: 2026-08-28  
Status: **Accepted event model; terminology updated 2026-09-02**

## Decisione invariata

Gli eventi di log RumiAI separano sempre:

```text
severity
domain
message-id
structured fields
```

Il testo localizzato è una presentazione dell'evento e non la sua identità canonica.

I messaggi bootstrap sono dati statici UTF-8. Non contengono codice da eseguire e il logger/language resolver non usa `eval` per interpretarli.

I valori dinamici vengono forniti come structured fields separati.

Esempio concettuale:

```text
severity:   warn
domain:     bootstrap
message-id: example
requested:  value-a
selected:   value-b
```

## Terminologia corrente

Il sottosistema/API bootstrap che risolve il testo è ora:

```text
lang
```

Il precedente nome `i18n` è superseded.

La forma canonica minimale è:

```sh
lang "$domain" "$message_id"
```

## Logger

La forma pubblica preferita del logger resta concettualmente:

```sh
log severity domain message-id [field-name field-value]...
```

La severity è un argomento esplicito e validato; non deve essere convertita ciecamente in un nome di funzione derivato da input arbitrario.

`fatal` resta una severity e non implica da sola la terminazione del processo.

## Interpolazione futura

Un futuro renderer può supportare template/interpolazione soltanto mantenendo questi invarianti:

- i valori provengono dagli stessi structured fields dell'evento canonico;
- non nasce un secondo canale di valori dinamici;
- `domain.message-id` resta stabile e non localizzato;
- i campi restano parte dell'evento strutturato;
- il catalogo resta data e non codice eseguibile.

La sintassi di eventuali placeholder resta non definita.

## Autorità corrente

```text
specifications/rumiai-os/LANG-BOOTSTRAP.md
decisions/rumiai-os/2026-09-02-bootstrap-runtime-standards.md
```
