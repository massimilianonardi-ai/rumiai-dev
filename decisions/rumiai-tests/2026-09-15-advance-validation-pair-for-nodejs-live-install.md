# Decisione — Avanzamento della coppia di validation per Node.js live install

Date: 2026-09-15  
Status: **Accepted / Active — physical validation pending**

## 1. Scopo

Questa decisione apre il gate revision-specific separato per la live validation del package Node.js dopo la chiusura positiva della full-suite `rumiai-os` sui reference host ARM64.

Il gate verifica il percorso reale:

```text
GitHub release resolution
-> nodejs.org artifact resolution
-> http-fetch / pkg_download
-> pkg_extract
-> pkg_integrate
-> materializzazione della concrete package version
-> launch reale di node / npm / npx
```

Non modifica il contratto package Node.js e non introduce nuove primitive.

## 2. Coppia corrente

La coppia da validare è:

```text
rumiai-os    a5442e527f6bc7a70022f09330ba27770c0b5fb7
rumiai-tests a80de1c56b9073804e7b3ed994c208be5f40c43b
selection    external/nodejs
```

La configurazione versionata è:

```text
rumiai-os-commit<TAB>a5442e527f6bc7a70022f09330ba27770c0b5fb7
selection<TAB>external/nodejs
```

La revisione prodotto è la stessa appena validata dalla full-suite. La revisione test avanza esclusivamente per:

```text
- riallineare external/nodejs/install-live.test al resource model corrente res
- riallineare il quoting shell del test alle regole correnti
- cambiare rumiai-validate.conf dalla selection rumiai-os alla selection external/nodejs
```

## 3. Precondizione soddisfatta

La decisione:

```text
decisions/rumiai-tests/2026-09-15-resource-srv-full-validation-gate-closed.md
```

ha chiuso positivamente la full-suite per:

```text
rumiai-os@a5442e527f6bc7a70022f09330ba27770c0b5fb7
rumiai-tests@df36a9d359901fa16daa1c7b763a3d8ec85ca2a2
selection=rumiai-os
```

con PASS sui reference host Ubuntu ARM64 e macOS ARM64.

Il gate live Node.js può quindi essere eseguito senza riaprire la full-suite già chiusa.

## 4. Test selezionato

La selection:

```text
external/nodejs
```

contiene attualmente il permanent test:

```text
external/nodejs/install-live.test
```

Il test è indipendente e materializza una fixture isolata di `rumiai-os` usando il resource tree corrente:

```text
bin
lib
res
state
```

Non richiede né ripristina il superseded top-level `lang`.

## 5. Proprietà live esercitate

Il test verifica almeno:

```text
pkg install nodejs completa con successo
viene materializzata una sola concrete version per la osarch corrente
node, npm e npx hanno command entry eseguibili
i direct link corrispondono al mapping della osarch corrente
l'env della concrete package version è presente e non eseguibile
node --version restituisce la versione concreta installata
npm --version e npx --version sono eseguibili e restituiscono una versione valida
pkg install non seleziona automaticamente default o binding pubblici
la cache pkg-catalog live viene materializzata
repository/type = nodejs
repository/owner = nodejs
repository/repository = node
range digest_type = sha256
range env presente
```

Il test stampa inoltre:

```text
installed=<concrete-identity>
catalog-head=<sha>
node=<version>
npm=<version>
npx=<version>
```

Questi valori fanno parte della diagnostica/evidence della sessione e permettono di registrare quale release e quale revisione effettiva del catalogo sono state esercitate.

## 6. Catalogo

Al momento dell'apertura del gate, `pkg-catalog/main` è osservato a:

```text
cfd6a9f7934a1d9072bb80b39496b15c4deb9ffb
```

Questa osservazione non introduce un nuovo meccanismo di pin del catalogo: il contratto corrente resta invariato. La sessione live deve riportare il valore effettivo `catalog-head` usato durante il run; l'evidence finale deve riferirsi a quel valore reale e non presumere che sia rimasto invariato.

## 7. Reference host richiesti

Per chiudere il gate ARM64 corrente il test deve essere eseguito tramite:

```text
./rumiai-validate
```

almeno su:

```text
Ubuntu 26.04 ARM64
macOS ARM64
```

Questo esercita due artifact mapping distinti:

```text
linux-arm64
macos-arm64
```

La package definition Windows resta fuori da questo gate. La physical validation Windows richiede un host POSIX-compatible di riferimento e resta separata, in particolare per la verifica del requisito executable dei wrapper `npm` / `npx` estratti dallo ZIP.

## 8. Criterio di chiusura

Il gate è chiuso positivamente soltanto quando esistono sessioni pubblicate per la coppia esatta:

```text
rumiai-os@a5442e527f6bc7a70022f09330ba27770c0b5fb7
rumiai-tests@a80de1c56b9073804e7b3ed994c208be5f40c43b
selection=external/nodejs
```

con:

```text
FAIL   0
ERROR  0
runner-exit-status 0
```

su entrambi i reference host ARM64 sopra indicati.

Gli output `installed`, `catalog-head`, `node`, `npm`, `npx` devono essere conservati nelle sessioni e riportati nella decisione di chiusura.

## 9. Invarianti

```text
NODEJS-LIVE-01  coppia corrente = rumiai-os@a5442e527f6bc7a70022f09330ba27770c0b5fb7 + rumiai-tests@a80de1c56b9073804e7b3ed994c208be5f40c43b
NODEJS-LIVE-02  selection corrente = external/nodejs
NODEJS-LIVE-03  il prodotto non cambia per aprire il gate
NODEJS-LIVE-04  external/nodejs/install-live.test usa il resource model corrente res e non il top-level lang superseded
NODEJS-LIVE-05  il test esercita download/install/integration/launch reale di node, npm e npx
NODEJS-LIVE-06  il catalog-head effettivo deve essere registrato dall'evidence live; non viene inventato un nuovo catalog pin
NODEJS-LIVE-07  Ubuntu ARM64 e macOS ARM64 devono entrambi produrre evidence positiva per chiudere il gate ARM64
NODEJS-LIVE-08  Windows resta un gate fisico separato
NODEJS-LIVE-09  nessun LTS selector, SemVer nel core, URL template generico o workaround chmod viene introdotto
NODEJS-LIVE-10  Git resta forward-only
```
