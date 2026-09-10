# Decisione — Cursore windowed del parser JSON

Date: 2026-09-10  
Status: **Accepted**

## Contesto

Il gate live `pkg install dbeaver` ha evidenziato sul reference macOS ARM64 una durata anomala. Il PoC 007 ha isolato il costo nel parser JSON di `lib/sh/json.lib.sh` sul payload reale GitHub `dbeaver/dbeaver/releases?per_page=100&page=1` da 2,355,841 byte.

Baseline fisica sul reference macOS ARM64:

```text
HTTP fetch                 1.408512 s
awk lineare                0.06 s real
parser JSON corrente       100.02 s real / 99.67 s user
record emessi              100
```

Il parser corrente conserva l'intero documento nella stringa AWK `src` e legge ripetutamente singoli caratteri con `substr(src, pos, 1)`. Sul `/usr/bin/awk` del reference macOS questo accesso domina il costo.

Il PoC ha verificato un candidato che mantiene una finestra interna di 4096 byte e legge i caratteri correnti dalla finestra. Sullo stesso host e payload:

```text
semantic-smoke             PASS
awk lineare                0.05 s real
parser windowed            5.23 s real / 5.19 s user
record emessi              100
probe                       PASS
```

Il miglioramento osservato è circa 19.1x rispetto alla baseline corrente.

Evidence sperimentale:

```text
rumiai-dev-PoCs/pocs/007-macos-dbeaver-install-performance/
  sessions/2026-09-10-json-baseline-macos-arm64/result.md
  sessions/2026-09-10-json-windowed-macos-arm64/result.md
```

## Decisione

`lib/sh/json.lib.sh` mantiene invariata la propria superficie pubblica e la propria semantica. Viene modificato esclusivamente il meccanismo interno di accesso alla sorgente AWK:

- il documento continua a essere acquisito come singola stringa `src`;
- il cursore mantiene una piccola finestra interna della sorgente;
- la lettura carattere-per-carattere avviene normalmente sulla finestra, evitando `substr()` ripetuto sulla stringa multi-megabyte;
- accessi brevi che attraversano un confine di finestra possono leggere direttamente da `src`;
- la dimensione iniziale della finestra è 4096 byte ed è dettaglio implementativo interno, non API o formato persistente.

Non viene introdotta una nuova primitive shell pubblica, un nuovo parser, una query language o una dipendenza non POSIX.

## Semantica invariata

Restano invariati almeno:

```text
json_object_fields
json_array_object_fields
json_object_array_object_fields
json_object_read
```

Restano inoltre invariati:

- `POSIX sh + POSIX awk` come contratto runtime;
- typed scalar `s:`, `n:`, `b:true`, `b:false`, `z:`, `m:`;
- separazione TAB/LF dei record;
- rejection di TAB/CR/LF nelle stringhe selezionate;
- rejection corrente degli escape Unicode nelle stringhe selezionate;
- validazione sintattica di stringhe e chiavi ignorate, inclusi escape e Unicode;
- semantica dei campi mancanti e duplicati;
- forme strutturali supportate;
- assenza di source/eval dei dati JSON;
- comportamento dell'adapter GitHub e della paginazione.

## Testing permanente

Oltre ai test JSON esistenti, la promozione deve proteggere esplicitamente accessi che attraversano il confine interno della finestra, almeno per:

- una stringa ignorata lunga oltre 4096 byte;
- un escape `\\uXXXX` che attraversa il confine;
- token literal `true`, `false` o `null` posizionati attraverso il confine;
- una stringa selezionata che attraversa il confine mantenendo output identico.

Non viene introdotta una soglia temporale nei test permanenti: la performance fisica host-specific resta evidence diagnostica, mentre i test permanenti proteggono la correttezza semantica del nuovo percorso.

## Physical validation

La promozione genera una nuova revisione `rumiai-os` e richiede nuova validation revision-specific sui reference host correnti. I PASS precedenti di `rumiai-os@a253162` e del gate live DBeaver non vengono estesi automaticamente alla nuova revisione.

Dopo il gate completo del prodotto, il live DBeaver deve essere rieseguito sulla nuova revisione per verificare il percorso GitHub reale e osservare con i nuovi timing del runner la durata end-to-end aggiornata.

## Invarianti

```text
JSON-WINDOW-01  nessuna API JSON pubblica cambia
JSON-WINDOW-02  POSIX sh + POSIX awk resta il contratto
JSON-WINDOW-03  cambia soltanto il cursore interno di accesso alla sorgente
JSON-WINDOW-04  la finestra da 4096 byte è dettaglio implementativo, non concetto di prodotto
JSON-WINDOW-05  validazione sintattica e typed output restano invariati
JSON-WINDOW-06  i boundary crossing devono essere protetti da test permanenti
JSON-WINDOW-07  nessuna soglia prestazionale entra nei test permanenti
JSON-WINDOW-08  la nuova revisione richiede evidence physical propria
```
