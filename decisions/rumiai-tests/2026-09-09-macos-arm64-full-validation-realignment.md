# Decisione — Riallineamento dopo la full validation macOS ARM64

Date: 2026-09-09  
Status: **Accepted**  
Updated: 2026-09-09

## Contesto

La physical validation macOS ARM64 della coppia:

```text
rumiai-os@b02965a91efdeb8f9609b432d635430ac9dba209
rumiai-tests@7d6c1459343fb5a9c99267d6e2e33ca9b34dbe40
selection=rumiai-os
```

ha prodotto la sessione pubblicata:

```text
validation/20260909T195202+0200-20156
```

su:

```text
Darwin 26.6.2
arm64
```

con risultato:

```text
PASS   55
FAIL   3
SKIP   0
ERROR  0
TOTAL  58
```

I tre FAIL sono:

```text
rumiai-os/pkg-download/contract.test
rumiai-os/pkg-extract/contract.test
rumiai-os/shell/selection.test
```

La stessa revisione prodotto e la stessa suite avevano precedentemente prodotto su Ubuntu 26.04.1 ARM64:

```text
validation/20260909T194807+0200-13517
PASS 60 / FAIL 0 / SKIP 2 / ERROR 0
```

La sessione macOS resta evidence immutabile della divergenza osservata e non viene reinterpretata come validation riuscita.

## 1. `pkg-extract`: drift del test, non del prodotto

`pkg_extract` canonicalizza intenzionalmente sia artifact sia destination tramite `readpathce` prima di delegare a `extract`.

Il test precedente confrontava invece gli argomenti osservati dal fake `extract` con i pathname testuali originari del fixture.

Su macOS il temporary path può attraversare un alias/symlink di sistema, per esempio da un pathname sotto `/var/...` al pathname fisico sotto `/private/var/...`. Il comportamento prodotto resta corretto: la delega usa i pathname canonicalizzati.

Il test viene quindi riallineato a confrontare contro artifact e destination canonicalizzati.

Implementazione suite:

```text
rumiai-tests@3e5f1c6b412c29c2042f3edd9f653f7ee2af0eb9
```

Questo cambiamento non modifica il contratto `pkg_extract` e non richiede modifica di `rumiai-os`.

## 2. `shell/selection`: fallback deterministico rispetto al valore visibile al bootstrap

Il contratto shell corrente resta:

```text
$SHELL se impostata e non vuota
sh altrimenti
```

Il precedente test tentava di verificare il fallback eseguendo il bootstrap dopo `unset SHELL` nel processo padre.

Questa precondizione non è portabile attraverso l'interprete del bootstrap: un'implementazione `sh` può inizializzare autonomamente la variabile `SHELL` prima dell'esecuzione del body dello script. Nella sessione macOS osservata il bootstrap ha infatti visto la login shell `zsh` e ha seguito correttamente il ramo `$SHELL` visibile al runtime.

Il test deve esercitare deterministicamente il ramo fallback fornendo al bootstrap:

```text
SHELL=""
```

come environment variable esportata. In questo caso la condizione `unset or null` osservabile dal bootstrap è stabile fra gli host e il comportamento richiesto resta `sh`.

Questo chiarimento non introduce una nuova shell-selection policy e non autorizza il bootstrap a leggere database utenti, passwd entry o altra fonte host-specific per ricostruire un ipotetico valore pre-interprete di `SHELL`.

Implementazione suite:

```text
rumiai-tests@0779c4c15f1e9922c525f6acbdf6f9644cb7975c
```

`rumiai-os` non viene modificato per questo FAIL.

## 3. `pkg-download`: divergenza reale del prodotto

Il contratto `pkg_download` richiede che la dimensione effettiva in byte coincida con il valore decimale canonico `size` del descriptor.

L'implementazione precedente acquisiva la size tramite:

```sh
pkg_download_actual_size="$(LC_ALL=C command -p -- wc -c < "$pkg_download_target")"
```

e confrontava direttamente la rappresentazione testuale con `pkg_download_size`.

Questo assumeva accidentalmente che `wc -c` rendesse il numero senza whitespace di padding. La full validation macOS ha dimostrato che tale assunzione non è portabile fra gli host di riferimento: il valid-download path falliva pur avendo payload della size prevista.

La semantica corretta non cambia: deve essere confrontato il valore numerico dei byte, non la formattazione host-specific dell'output di `wc`.

L'utente ha autorizzato esplicitamente la correzione prodotto. È stata applicata in:

```text
rumiai-os@52454b4d679bd6b49596ecdf5c8f4535e20bb5c7
```

La correzione preserva separatamente il failure di `wc -c`, poi normalizza il suo output a rappresentazione decimale tramite la primitive POSIX `awk` già utilizzata nello stesso layer, prima del confronto con `pkg_download_size`.

Non vengono introdotti backend, API, branch Darwin o nuove primitive RumiAI.

Il test `pkg-download/contract.test` non viene indebolito: un download valido deve continuare a produrre PASS su entrambi i reference host.

## 4. Stato del gate corrente

La coppia candidata post-correzione è:

```text
rumiai-os@52454b4d679bd6b49596ecdf5c8f4535e20bb5c7
rumiai-tests@17f307165810e328ef2e44b2ca447a09575623f2
selection=rumiai-os
```

La configurazione `rumiai-validate.conf` punta esattamente a questa revisione prodotto.

### Ubuntu ARM64 — PASS

La coppia candidata è stata fisicamente validata su:

```text
Ubuntu 26.04.1 LTS
aarch64
```

con sessione pubblicata:

```text
validation/20260909T201747+0200-21089
```

e commit evidence:

```text
74f4712bd560987fb84e742eaf4f0a119302b631
```

Risultato:

```text
PASS   60
FAIL   0
SKIP   2
ERROR  0
TOTAL  62
runner-exit-status 0
```

I due SKIP sono esclusivamente:

```text
rumiai-os/shell/zsh-alias-preservation.test
rumiai-os/shell/zsh-zdotdir-preservation.test
```

Tutti gli altri test applicabili, incluso `rumiai-os/pkg-download/contract.test`, sono PASS.

### macOS ARM64 — pending

Il gate cross-platform non è ancora chiuso: la stessa identica coppia candidata deve ora essere validata su macOS ARM64 senza modificare `rumiai-os`, `rumiai-tests` o `selection` nel mezzo.

Le evidence precedenti restano valide esclusivamente per le revisioni effettivamente esercitate.

## 5. Invarianti

```text
MACOS-REALIGN-01  la sessione validation/20260909T195202+0200-20156 resta evidence immutabile FAIL
MACOS-REALIGN-02  pkg_extract continua a delegare pathname canonicalizzati; il test deve aspettare pathname canonicalizzati
MACOS-REALIGN-03  il fallback shell viene testato con SHELL vuota esportata, non tentando di preservare SHELL unset attraverso un interprete che può inizializzarla
MACOS-REALIGN-04  nessuna nuova policy host-specific di selezione shell viene introdotta
MACOS-REALIGN-05  pkg_download confronta la size numerica, non la formattazione testuale host-specific di wc -c
MACOS-REALIGN-06  la correzione prodotto autorizzata è rumiai-os@52454b4d679bd6b49596ecdf5c8f4535e20bb5c7 e non cambia API o contratto
MACOS-REALIGN-07  la coppia post-correzione ha PASS fisico Ubuntu ARM64 in validation/20260909T201747+0200-21089
MACOS-REALIGN-08  il gate cross-platform si chiude solo dopo PASS macOS ARM64 della stessa coppia rumiai-os@52454b4d... + rumiai-tests@17f3071... con selection=rumiai-os
```