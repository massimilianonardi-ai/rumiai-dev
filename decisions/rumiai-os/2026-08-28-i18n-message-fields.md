# Decisione — Messaggi i18n bootstrap e campi strutturati

Date: 2026-08-28
Status: **Accepted**

## Decisione

Gli eventi di log RumiAI separano sempre:

```text
severity
domain
message-id
structured fields
```

Il testo localizzato è una presentazione dell'evento e non la sua identità canonica.

## Bootstrap i18n

Il resolver i18n minimale del bootstrap usa messaggi statici UTF-8.

I messaggi bootstrap NON contengono placeholder, nomi di variabili shell o espressioni da valutare.

Il bootstrap NON usa `eval` per internazionalizzazione o logging.

I valori dinamici vengono forniti esclusivamente come campi strutturati separati.

Esempio concettuale:

```text
severity:   warn
domain:     bootstrap
message-id: language-fallback
requested:  xx_YY
selected:   en_US
```

## API logger

La forma pubblica preferita è:

```sh
log warn bootstrap language-fallback requested "$requested" selected "$selected"
```

La severity è un argomento del comando/funzione `log`; non è necessario esporre funzioni pubbliche separate `log_warn`, `log_info`, ecc.

Il dispatch della severity deve essere esplicito e validato; non deve dipendere dalla costruzione arbitraria di un nome di funzione da input non validato.

## Interpolazione futura

Un renderer/i18n avanzato PUÒ in futuro supportare template con placeholder.

Questa capability deve usare come sorgente gli stessi structured fields dell'evento canonico. Non deve introdurre un secondo canale di valori dinamici e non deve richiedere modifiche alla chiamata `log`.

Quindi l'evoluzione prevista è:

```text
bootstrap renderer
    static localized message + structured fields

advanced renderer
    static message OR template interpolated from structured fields
```

L'eventuale sintassi dei placeholder non è definita da questa decisione e verrà scelta solo quando il renderer avanzato verrà progettato.

## Proprietà invarianti

Anche quando un renderer avanzato interpola un campo nel testo localizzato:

- il campo resta parte dell'evento strutturato canonico;
- `domain.message-id` resta stabile e non localizzato;
- l'interpolazione è una scelta di presentation/rendering;
- il logger core non esegue codice contenuto nei cataloghi;
- un catalogo non può trasformare un valore in codice shell da eseguire.

## Motivazione

Questa scelta mantiene il bootstrap semplice e verificabile, evita `eval` e template engine prematuri, ma conserva la possibilità di ottenere in futuro la flessibilità tipica dei sistemi i18n maturi senza cambiare l'API degli eventi di log.
