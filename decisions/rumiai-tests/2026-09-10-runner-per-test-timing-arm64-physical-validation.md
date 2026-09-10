# Decisione — Physical validation ARM64 del timing per-test del runner

Date: 2026-09-10  
Status: **Validated**

## Scope

Questa evidence registra la validation del contratto:

```text
decisions/rumiai-tests/2026-09-10-runner-per-test-timing.md
```

Revision esercitata:

```text
rumiai-tests@be92befb9342a164231c012df4e5245ec189a206
selection: runner
```

Il target configurato durante queste run resta:

```text
rumiai-os@a2531626b68e81c9df4e76a007e7f963b3f26343
```

ma il gruppo `runner` verifica l'infrastruttura `rumiai-test`; questa evidence non è una nuova validation del prodotto `rumiai-os`.

## Ubuntu ARM64

```text
run-id:              20260910T170320+0200-91979
validation ref:      validation/20260910T170320+0200-91979
evidence commit:     3dba2a26de433f41ef40b598dd36dc43262dceb0
rumiai-tests parent: be92befb9342a164231c012df4e5245ec189a206
OS:                  Ubuntu 26.04.1 LTS
architecture:        aarch64
runner status:       0
```

Results:

```text
PASS runner/cli-discovery.test
PASS runner/execution-persistence.test
PASS runner/snapshot.test
PASS runner/validation-publication.test
```

Persisted timings:

```text
runner/cli-discovery.test            0.04
runner/execution-persistence.test    0.04
runner/snapshot.test                 0.20
runner/validation-publication.test   0.04
```

## macOS ARM64

```text
run-id:              20260910T170355+0200-95426
validation ref:      validation/20260910T170355+0200-95426
evidence commit:     2f34accf9e52dc2c1f25a43cbfbff48ebc4119f7
rumiai-tests parent: be92befb9342a164231c012df4e5245ec189a206
OS:                  Darwin 26.6.2
architecture:        arm64
runner status:       0
```

Results:

```text
PASS runner/cli-discovery.test
PASS runner/execution-persistence.test
PASS runner/snapshot.test
PASS runner/validation-publication.test
```

Persisted timings:

```text
runner/cli-discovery.test            0.59
runner/execution-persistence.test    1.38
runner/snapshot.test                 1.57
runner/validation-publication.test   0.87
```

## Conclusione

Il nuovo file `timings` viene prodotto e pubblicato correttamente sui due reference host ARM64; i quattro test permanenti del runner passano su entrambi e il runner conserva status 0.

Questa evidence copre `rumiai-tests@be92bef`. Revisioni successive della suite che modificano soltanto test/configurazione senza modificare il runner non cambiano retroattivamente questa evidence; una futura modifica del runner richiederà valutazione proporzionata propria.

## Invarianti di evidence

```text
RUN-TIME-VAL-01  revision validata = rumiai-tests@be92bef
RUN-TIME-VAL-02  Ubuntu ARM64 runner = 4 PASS, status 0
RUN-TIME-VAL-03  macOS ARM64 runner = 4 PASS, status 0
RUN-TIME-VAL-04  timings è presente nelle evidence remote dei due host
RUN-TIME-VAL-05  results resta nel formato canonico a tre campi
RUN-TIME-VAL-06  questa evidence non viene promossa a validation di rumiai-os
RUN-TIME-VAL-07  modifiche future del runner richiedono evidence propria
```
