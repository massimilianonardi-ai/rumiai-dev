# Decisione — Durata per-test nel runner `rumiai-test`

Date: 2026-09-10  
Status: **Accepted**

## Contesto

Durante il gate live DBeaver è emersa una differenza prestazionale ampia fra i due reference host ARM64:

```text
Linux/aarch64  17 s circa per external/dbeaver/install-live.test
Darwin/arm64   242 s circa per lo stesso test
```

Le sessioni correnti registrano `start` e `end` globali, mentre il log di ogni test contiene intenzionalmente soltanto lo stream combinato prodotto dal `.test`. Questo preserva correttamente il contratto di logging, ma non permette di attribuire a posteriori il tempo a ciascun test quando una selection contiene più test.

L'utente ha approvato l'aggiunta del tempo di esecuzione per ogni test al runner.

## Decisione

`rumiai-test` osserva e registra per ogni `.test` la durata wall-clock della sola esecuzione del processo testato.

La misura:

- inizia immediatamente prima dell'esecuzione diretta del `.test`;
- termina quando il processo `.test` termina;
- non comprende snapshot before/after, discovery, persistenza o altri costi del runner;
- non modifica l'ambiente ereditato dal test;
- non modifica il contratto runner -> test;
- non modifica il significato dell'exit status osservato.

Il runner usa il formato portabile di `time -p` previsto dal contratto POSIX. L'eventuale separatore decimale locale viene normalizzato a `.` soltanto nel valore persistito e mostrato dal runner; il processo `.test` continua a ereditare il locale originale.

## Persistenza

Il formato canonico di `results` resta invariato:

```text
result<TAB>test-id<TAB>observed-termination
```

I log restano invariati e contengono esclusivamente stdout+stderr combinati del test.

Le nuove run create da `rumiai-test` aggiungono il file:

```text
timings
```

con un record per ogni test eseguito, nello stesso ordine di `results`:

```text
test-id<TAB>real-seconds
```

Esempio:

```text
rumiai-os/json/structure.test	0.42
external/dbeaver/install-live.test	17.08
```

`real-seconds` è un numero decimale non negativo con `.` come separatore.

La struttura prodotta dalle nuove run diventa quindi:

```text
<run-id>/
├── session
├── results
├── timings
├── logs/
└── snapshots/        presente solo quando richiesto
```

## Compatibilità delle validation session precedenti

`timings` non viene aggiunto ai requisiti minimi con cui `rumiai-validate` riconosce una sessione completata pendente.

Motivo: il launcher deve poter continuare a pubblicare evidence già prodotta da revisioni precedenti di `rumiai-test`, nelle quali `timings` non esisteva. Quando una sessione nuova contiene `timings`, il publisher include normalmente il file nel tree di evidence insieme al resto della directory della sessione.

Le sessioni storiche non vengono modificate o reinterpretate.

## Output terminale

La riga per-test mostra anche la durata, senza cambiare il significato dell'esito. Forma iniziale:

```text
PASS   rumiai-os/json/structure.test  [0.42s]
FAIL   external/example.test  [3.17s]
```

Il riepilogo aggregato `PASS/FAIL/SKIP/ERROR/TOTAL` resta invariato.

## Failure semantics

L'impossibilità del runner di ottenere o persistere una misura valida per un test è un errore dell'infrastruttura del runner e rende la run incompleta (`RUNNER ERROR`), non un `FAIL` del test.

## Testing

I test permanenti del runner devono verificare almeno che:

- `results` conservi esattamente il formato a tre campi già fissato;
- `timings` contenga un record per ogni test eseguito nello stesso ordine di `results`;
- ogni valore persistito sia un numero decimale non negativo con `.` come separatore;
- il log combinato del test non contenga output prodotto da `time` o dal runner;
- l'exit status del test continui a essere classificato come prima;
- una validation session completata prodotta dal runner contenga `timings` senza modificare HEAD Git.

## Invarianti

```text
RUN-TIME-01  il log del test resta esclusivamente stdout+stderr del .test
RUN-TIME-02  results resta result<TAB>test-id<TAB>observed-termination
RUN-TIME-03  le nuove run producono timings = test-id<TAB>real-seconds
RUN-TIME-04  real-seconds usa punto decimale e rappresenta wall-clock della sola esecuzione del test
RUN-TIME-05  il normale ambiente del test non viene modificato per rendere deterministico il formato del timing
RUN-TIME-06  timing failure è RUNNER ERROR, non FAIL del test
RUN-TIME-07  il publisher resta compatibile con sessioni storiche prive di timings
RUN-TIME-08  sessioni storiche ed evidence remote non vengono riscritte
```
