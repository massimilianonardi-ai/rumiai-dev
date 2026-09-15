# Decisione — Gate di validation per remediation Content-Length Node.js

Date: 2026-09-15  
Status: **Accepted / Active — physical validation pending**

## 1. Scopo

Questa decisione apre il task validation gate della remediation definita in:

```text
decisions/rumiai-os/2026-09-15-http-fetch-content-length-and-nodejs-size-remediation.md
```

La remediation sostituisce la sorgente non affidabile della size Node.js basata sul directory index HTML con il `Content-Length` esatto dell'URL artifact finale ottenuto tramite la primitive esistente `http-fetch -l`.

Il gate verifica insieme:

```text
contratto CLI di http-fetch -l
normalizzazione curl / GNU Wget
regressione dell'adapter Node.js
live download/install/integration/launch Node.js
```

## 2. Revisione prodotto fissata

La revisione `rumiai-os` da validare è:

```text
e72d33b762ac14a773013ef1e6a0bb76a7dde043
```

Questa revisione contiene, in forward-only sopra il prodotto precedente:

```text
3cae84f1570a973a66926f435ea4e6e93f53767c  Add Content-Length mode to http-fetch
e72d33b762ac14a773013ef1e6a0bb76a7dde043  Use artifact Content-Length for Node.js size
```

I file prodotto modificati dal work unit sono esclusivamente:

```text
bin/sys/http-fetch
lib/sys/sh/pkg-repository-nodejs.lib.sh
```

Le integrazioni parallele Chrome, Chromium, NetBeans e altri package già presenti nel prodotto non vengono modificate da questo work unit.

## 3. Scope versionato

Lo scope nominato è:

```text
nodejs-live
```

ed è materializzato in:

```text
validation/nodejs-live.conf
```

La revisione `rumiai-tests` che apre il gate e materializza lo scope è:

```text
0c0650601c51df352b6af062e2b4a519e931724d
```

La configurazione fissa:

```text
kind<TAB>task
rumiai-os-commit<TAB>e72d33b762ac14a773013ef1e6a0bb76a7dde043
selection<TAB>rumiai-os/http-fetch/cli.test
selection<TAB>rumiai-os/http-fetch/backends.test
selection<TAB>rumiai-os/pkg-repository-nodejs/artifact.test
selection<TAB>external/nodejs/install-live.test
```

Le quattro selection sono state fissate prima della physical validation e non possono essere ristrette dopo un failure correlato.

## 4. Revisione della suite ed evidence

`rumiai-tests@0c0650601c51df352b6af062e2b4a519e931724d` è la revisione di apertura del gate.

Il launcher corrente si autoaggiorna prima dell'esecuzione. Se `rumiai-tests/main` avanza prima del run, la sessione deve registrare la revisione effettivamente esercitata come previsto da `TESTING.md`.

Una revisione successiva della suite è accettabile per questo gate soltanto se:

```text
validation/nodejs-live.conf continua a fissare rumiai-os@e72d33b762ac14a773013ef1e6a0bb76a7dde043
le quattro selection richieste restano tutte presenti
lo scope non viene ristretto o semanticamente indebolito
```

Se una modifica successiva cambia il validation scope o le aspettative pertinenti, il gate deve essere riesaminato prima di usare la nuova evidence.

## 5. Test permanenti del work unit

La suite di apertura contiene le modifiche permanenti proporzionate in:

```text
tests/rumiai-os/http-fetch/cli.test
tests/rumiai-os/http-fetch/backends.test
tests/rumiai-os/pkg-repository-nodejs/artifact.test
```

`tests/external/nodejs/install-live.test` non è stato indebolito o modificato dal work unit ed è incluso nello scope come regressione end-to-end del failure fisicamente osservato.

Le proprietà richieste comprendono almeno:

```text
-l restituisce il Content-Length finale dopo redirect
-l non richiede/materializza un response body
Content-Length assente, malformato o duplicato fallisce
-l + -o è invalid invocation
failure curl non provoca fallback verso wget
GNU Wget usa il probe senza body
BusyBox Wget resta escluso
Node.js ottiene la size tramite http-fetch -l sull'URL artifact esatto
il vecchio directory listing non viene consultato
SHASUMS256.txt resta sorgente di name + digest
le sei osarch conservano il mapping corrente
live install materializza e avvia node/npm/npx
```

## 6. Esecuzione

La sintassi diretta corrente del launcher è:

```text
./rumiai-validate <scope-name>
```

Per questo gate l'operatore esegue:

```text
./rumiai-validate nodejs-live
```

Il comportamento senza argomenti resta il selettore interattivo corrente e non è necessario per questo gate.

## 7. Reference host richiesti

La task validation corrente richiede evidence positiva su:

```text
Ubuntu 26.04 ARM64
macOS ARM64
```

Questi host esercitano rispettivamente:

```text
linux-arm64
macos-arm64
```

La validation Windows resta separata e non viene reinterpretata da questo gate.

## 8. Criterio di chiusura

Il work unit è validato su un host soltanto se tutte le selection di `nodejs-live` producono PASS.

In particolare:

```text
FAIL  -> NOT VALIDATED
ERROR -> TEST ERROR
SKIP  -> NOT VALIDATED
```

Il gate ARM64 è chiuso positivamente soltanto dopo evidence positiva su entrambi i reference host.

La sessione live deve continuare a conservare gli output dell'install test:

```text
installed=<concrete-identity>
catalog-head=<sha>
node=<version>
npm=<version>
npx=<version>
```

Il `catalog-head` effettivo viene registrato dall'evidence; non viene introdotto un nuovo meccanismo di pin del catalogo.

## 9. Evidence precedente

Le sessioni:

```text
20260915T160755+0200-405802  Ubuntu ARM64
20260915T160821+0200-75434   macOS ARM64
```

restano failure evidence immutabile per:

```text
rumiai-os@a5442e527f6bc7a70022f09330ba27770c0b5fb7
rumiai-tests@a80de1c56b9073804e7b3ed994c208be5f40c43b
selection=external/nodejs
```

Non costituiscono evidence della revisione prodotto corretta.

## 10. Invarianti

```text
NODEJS-LEN-VAL-01  target product revision = e72d33b762ac14a773013ef1e6a0bb76a7dde043
NODEJS-LEN-VAL-02  named task scope = nodejs-live
NODEJS-LEN-VAL-03  opening suite revision = 0c0650601c51df352b6af062e2b4a519e931724d
NODEJS-LEN-VAL-04  scope include cli.test, backends.test, artifact.test e install-live.test
NODEJS-LEN-VAL-05  scope non può essere ristretto dopo failure correlati
NODEJS-LEN-VAL-06  Ubuntu ARM64 e macOS ARM64 devono entrambi validare tutte le selection
NODEJS-LEN-VAL-07  SKIP richiesto non costituisce PASS
NODEJS-LEN-VAL-08  install-live.test resta regressione end-to-end non indebolita
NODEJS-LEN-VAL-09  catalog-head effettivo viene registrato ma non introdotto come pin
NODEJS-LEN-VAL-10  evidence precedenti restano immutabili e revision-specific
NODEJS-LEN-VAL-11  eventuale suite revision successiva deve preservare integralmente target e scope prima di poter essere usata
NODEJS-LEN-VAL-12  Git resta forward-only
```
