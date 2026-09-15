# Decisione — Chiusura validation remediation Content-Length Node.js

Date: 2026-09-15  
Status: **Accepted; physical validation complete on ARM64 reference hosts**

## 1. Gate chiuso

Questa decisione chiude positivamente il gate aperto da:

```text
decisions/rumiai-tests/2026-09-15-nodejs-content-length-remediation-validation-gate.md
```

per la remediation definita in:

```text
decisions/rumiai-os/2026-09-15-http-fetch-content-length-and-nodejs-size-remediation.md
```

Il target revision-specific validato è:

```text
rumiai-os    e72d33b762ac14a773013ef1e6a0bb76a7dde043
rumiai-tests 3ee23e33ed6953b92434b8271a1c557d72fffecf
scope        nodejs-live
```

La revisione `rumiai-tests@3ee23e33ed6953b92434b8271a1c557d72fffecf` conserva integralmente il target e le quattro selection dello scope fissato prima della validation:

```text
rumiai-os/http-fetch/cli.test
rumiai-os/http-fetch/backends.test
rumiai-os/pkg-repository-nodejs/artifact.test
external/nodejs/install-live.test
```

Il successivo avanzamento di `rumiai-os/main` non viene reinterpretato come parte di questa evidence: la chiusura vale per `rumiai-os@e72d33b762ac14a773013ef1e6a0bb76a7dde043`.

## 2. macOS ARM64 — VALIDATED

Host registrato:

```text
Darwin 26.6.2
arm64
kernel Darwin 25.6.0
```

Sessioni pubblicate:

```text
validation/20260915T214002+0200-77250  rumiai-os/http-fetch/cli.test
validation/20260915T214006+0200-77605  rumiai-os/http-fetch/backends.test
validation/20260915T214010+0200-77851  rumiai-os/pkg-repository-nodejs/artifact.test
validation/20260915T214015+0200-79062  external/nodejs/install-live.test
```

Tutte le sessioni registrano:

```text
PASS   1
FAIL   0
SKIP   0
ERROR  0
TOTAL  1
runner-exit-status 0
```

La live install registra:

```text
installed=nodejs@v26.8.2!macos-arm64
catalog-head=af4332445d8f6ad678ff7ec2a14e482358a43182
node=v26.8.2
npm=11.19.1
npx=11.19.1
```

L'evidence macOS era stata registrata separatamente in:

```text
decisions/rumiai-tests/2026-09-15-nodejs-content-length-remediation-macos-evidence.md
```

Il relativo stato `Ubuntu ARM64 pending` è ora superato da questa decisione di chiusura; l'evidence e le revisioni registrate in quel documento restano valide e immutabili.

## 3. Ubuntu 26.04 ARM64 — VALIDATED

Host registrato:

```text
Ubuntu 26.04.1 LTS
aarch64
kernel Linux 7.0.0-31-generic
```

Sessioni pubblicate:

```text
validation/20260915T214440+0200-409064  rumiai-os/http-fetch/cli.test
validation/20260915T214443+0200-409400  rumiai-os/http-fetch/backends.test
validation/20260915T214445+0200-409630  rumiai-os/pkg-repository-nodejs/artifact.test
validation/20260915T214449+0200-410607  external/nodejs/install-live.test
```

Tutte le sessioni registrano:

```text
PASS   1
FAIL   0
SKIP   0
ERROR  0
TOTAL  1
runner-exit-status 0
```

La live install registra:

```text
installed=nodejs@v26.8.2!linux-arm64
catalog-head=af4332445d8f6ad678ff7ec2a14e482358a43182
node=v26.8.2
npm=11.19.1
npx=11.19.1
```

## 4. Proprietà validate

La physical validation sui due reference host ARM64 conferma per la revisione prodotto fissata:

```text
http-fetch -l restituisce il Content-Length finale dopo redirect
la modalità length non materializza il response body
Content-Length assente, malformato o duplicato viene rifiutato
-l e -o non sono combinabili
un failure curl non provoca fallback verso wget
GNU Wget esercita il probe senza body
BusyBox Wget resta escluso dal backend supportato
l'adapter Node.js usa http-fetch -l sull'URL artifact esatto
il vecchio directory listing HTML non è richiesto per la size
SHASUMS256.txt resta la sorgente di name e digest
la live install reale completa download, installazione, integrazione e launch di node/npm/npx
```

Il `catalog-head` osservato è identico su entrambi gli host e resta un dato di evidence, non un nuovo meccanismo di pin.

## 5. Evidence precedenti

Le failure evidence precedenti restano immutabili e revision-specific:

```text
validation/20260915T160755+0200-405802  Ubuntu ARM64
validation/20260915T160821+0200-75434   macOS ARM64

rumiai-os    a5442e527f6bc7a70022f09330ba27770c0b5fb7
rumiai-tests a80de1c56b9073804e7b3ed994c208be5f40c43b
```

Non vengono reinterpretate come PASS e non vengono attribuite alla remediation validata.

## 6. Stato finale

```text
macOS ARM64         VALIDATED
Ubuntu 26.04 ARM64  VALIDATED
cross-host gate     CLOSED
```

La validation Windows resta separata e non è coperta da questa decisione.

Questa chiusura non estende l'evidence a revisioni prodotto successive a `e72d33b762ac14a773013ef1e6a0bb76a7dde043` né a proprietà non esercitate dallo scope `nodejs-live`.

## 7. Invarianti

```text
NODEJS-LEN-CLOSE-01  prodotto validato = rumiai-os@e72d33b762ac14a773013ef1e6a0bb76a7dde043
NODEJS-LEN-CLOSE-02  suite esercitata = rumiai-tests@3ee23e33ed6953b92434b8271a1c557d72fffecf
NODEJS-LEN-CLOSE-03  scope validato = nodejs-live con tutte e quattro le selection fissate
NODEJS-LEN-CLOSE-04  macOS ARM64 ha PASS su tutte le selection richieste
NODEJS-LEN-CLOSE-05  Ubuntu 26.04 ARM64 ha PASS su tutte le selection richieste
NODEJS-LEN-CLOSE-06  nessuna selection richiesta ha SKIP, FAIL o ERROR sui due reference host
NODEJS-LEN-CLOSE-07  catalog-head osservato su entrambi gli host = af4332445d8f6ad678ff7ec2a14e482358a43182
NODEJS-LEN-CLOSE-08  le failure evidence precedenti restano immutabili e revision-specific
NODEJS-LEN-CLOSE-09  revisioni prodotto successive non sono coperte automaticamente
NODEJS-LEN-CLOSE-10  Windows resta fuori dal gate ARM64 corrente
NODEJS-LEN-CLOSE-11  Git resta forward-only
```
