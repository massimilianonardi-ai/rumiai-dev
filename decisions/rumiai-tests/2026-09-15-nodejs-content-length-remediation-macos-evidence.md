# Decisione — Evidence macOS ARM64 per remediation Content-Length Node.js

Date: 2026-09-15  
Status: **Accepted / Partial physical validation — Ubuntu ARM64 pending**

## 1. Scopo

Questa decisione registra l'evidence positiva macOS ARM64 del gate aperto da:

```text
decisions/rumiai-tests/2026-09-15-nodejs-content-length-remediation-validation-gate.md
```

Non chiude il gate cross-host: l'evidence Ubuntu 26.04 ARM64 resta obbligatoria.

## 2. Revisioni esercitate

La validation macOS ha esercitato:

```text
rumiai-os    e72d33b762ac14a773013ef1e6a0bb76a7dde043
rumiai-tests 3ee23e33ed6953b92434b8271a1c557d72fffecf
scope        nodejs-live
host         Darwin 26.6.2 / arm64
kernel       Darwin 25.6.0
```

La revisione `rumiai-tests@3ee23e33ed6953b92434b8271a1c557d72fffecf` è successiva alla revisione di apertura del gate e conserva integralmente:

```text
rumiai-os-commit e72d33b762ac14a773013ef1e6a0bb76a7dde043
selection rumiai-os/http-fetch/cli.test
selection rumiai-os/http-fetch/backends.test
selection rumiai-os/pkg-repository-nodejs/artifact.test
selection external/nodejs/install-live.test
```

Pertanto soddisfa `NODEJS-LEN-VAL-11` del gate attivo.

## 3. Evidence pubblicate

Le quattro selection richieste hanno prodotto PASS con runner exit status 0:

```text
20260915T214002+0200-77250  rumiai-os/http-fetch/cli.test
20260915T214006+0200-77605  rumiai-os/http-fetch/backends.test
20260915T214010+0200-77851  rumiai-os/pkg-repository-nodejs/artifact.test
20260915T214015+0200-79062  external/nodejs/install-live.test
```

Le branch di evidence sono:

```text
validation/20260915T214002+0200-77250
validation/20260915T214006+0200-77605
validation/20260915T214010+0200-77851
validation/20260915T214015+0200-79062
```

Per ciascuna sessione:

```text
PASS   1
FAIL   0
SKIP   0
ERROR  0
TOTAL  1
runner exit status 0
```

## 4. Evidence live Node.js

Il log della sessione live registra:

```text
installed=nodejs@v26.8.2!macos-arm64
catalog-head=af4332445d8f6ad678ff7ec2a14e482358a43182
node=v26.8.2
npm=11.19.1
npx=11.19.1
```

Questa evidence valida sul reference host macOS ARM64 il percorso reale di download, installazione, integrazione e avvio richiesto dal gate.

Il `catalog-head` è il valore osservato durante la sessione e non introduce alcun nuovo pin del catalogo.

## 5. Stato del gate

Lo stato complessivo resta:

```text
macOS ARM64         VALIDATED
Ubuntu 26.04 ARM64  PENDING
cross-host gate     OPEN
```

Il gate potrà essere chiuso positivamente soltanto dopo evidence positiva Ubuntu 26.04 ARM64 sulle stesse quattro selection, con il target prodotto e lo scope fissati dal gate attivo.

## 6. Invarianti

```text
NODEJS-LEN-MAC-01  questa decisione registra solo evidence macOS ARM64
NODEJS-LEN-MAC-02  target esercitato = rumiai-os@e72d33b762ac14a773013ef1e6a0bb76a7dde043
NODEJS-LEN-MAC-03  suite esercitata = rumiai-tests@3ee23e33ed6953b92434b8271a1c557d72fffecf
NODEJS-LEN-MAC-04  tutte e quattro le selection richieste hanno PASS
NODEJS-LEN-MAC-05  nessuna selection richiesta ha SKIP, FAIL o ERROR
NODEJS-LEN-MAC-06  catalog-head osservato = af4332445d8f6ad678ff7ec2a14e482358a43182
NODEJS-LEN-MAC-07  Ubuntu ARM64 resta obbligatorio prima della chiusura cross-host
NODEJS-LEN-MAC-08  evidence storiche precedenti restano immutabili
NODEJS-LEN-MAC-09  Git resta forward-only
```
