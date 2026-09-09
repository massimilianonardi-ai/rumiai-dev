# Decisione — Riallineamento test pathname canonicali emerso su macOS ARM64

Date: 2026-09-09  
Status: **Accepted; test realigned, physical validation pending**

## Contesto

La coppia:

```text
rumiai-os@130944920b5dab5f9d25bd3515667f5cdff36a48
rumiai-tests@18cdcf231a1353a9cc903581030a6dc6a094df4c
selection=rumiai-os
```

è stata eseguita sui due reference host ARM64.

### Ubuntu ARM64

Sessione pubblicata:

```text
validation/20260909T205653+0200-28726
```

Evidence commit:

```text
7f95db79dcd14a4c58cae53caa5e2c29369be4e0
```

Host:

```text
Ubuntu 26.04.1 LTS
aarch64
```

Risultato:

```text
PASS   61
FAIL   0
SKIP   2
ERROR  0
TOTAL  63
runner-exit-status 0
```

### macOS ARM64

Sessione pubblicata:

```text
validation/20260909T205717+0200-29273
```

Evidence commit:

```text
0f7e7168a047265dc0b8f438661950893772b304
```

Host:

```text
Darwin 26.6.2
arm64
```

Risultato:

```text
PASS   61
FAIL   2
SKIP   0
ERROR  0
TOTAL  63
runner-exit-status 1
```

I due FAIL sono:

```text
rumiai-os/pkg-download/contract.test
rumiai-os/shell/zsh-runtime-state-boundary.test
```

La sessione macOS resta evidence immutabile FAIL della coppia esatta sopra e non viene reinterpretata come PASS.

Questa decisione supersede esclusivamente le formulazioni di "gate corrente" e "suite candidata corrente" presenti nelle decisioni precedenti quando riferite a revisioni anteriori. Non modifica i contratti di `pkg_download`, shell/Zsh o validation launcher.

## 1. `pkg-download/contract.test`: pathname atteso non canonicalizzato

Il log della sessione macOS riporta:

```text
rumiai-os/pkg-download/contract.test: pkg_download returned incorrect pathname
```

Il prodotto `pkg_download` canonicalizza intenzionalmente lo staging directory esistente tramite `readpathce` e costruisce il target a partire da quel pathname fisico:

```text
<canonical-staging-dir>/<name>
```

Il test passava invece a `pkg_download` un pathname derivato testualmente da `$TMPDIR` e confrontava l'output con:

```text
$stage/artifact.bin
```

senza canonicalizzare `$stage`.

Su macOS un pathname temporaneo può avere una forma logica sotto `/var/...` e una forma fisica sotto `/private/var/...`. Entrambe raggiungono lo stesso oggetto filesystem, ma il confronto stringa del test le considerava differenti.

Il comportamento del prodotto è coerente con il proprio uso di `readpathce`; il FAIL è quindi drift del test, non regressione di `pkg_download`.

La correzione permanente:

1. continua a passare al prodotto il pathname di staging originario, così la canonicalizzazione del target viene realmente esercitata;
2. calcola separatamente il pathname fisico atteso con `cd ... && pwd -P`;
3. confronta output di `pkg_download` e argomento passato a `digest` con il target costruito sullo staging canonicalizzato;
4. usa lo stesso target canonicalizzato nei guard di cleanup.

Implementazione suite:

```text
rumiai-tests@3e7a1fed7e793722933709eb2e45dedaadabbcf5
```

Il contratto `pkg_download` resta invariato.

## 2. `zsh-runtime-state-boundary.test`: fixture root non canonicalizzata

Il log della sessione macOS riporta:

```text
rumiai-os/shell/zsh-runtime-state-boundary.test: Zsh did not receive the runtime state ZDOTDIR
```

Questo messaggio non indica che il fake Zsh abbia rifiutato il `ZDOTDIR` ricevuto.

Il fake executable del test verifica prima di registrare il pathname:

```text
ZDOTDIR = $m_HOME_DIR/sys/shell/zsh
ZDOTDIR != $m_CONF_DIR/sys/shell/zsh
ZDOTDIR esiste come directory
```

Se una di queste proprietà fosse falsa, il fake Zsh terminerebbe con uno status dedicato e il test fallirebbe prima con la diagnostica `fake Zsh launch returned ...`.

Nella sessione macOS il fake Zsh termina invece con successo e il FAIL avviene nel confronto successivo fra:

```text
pathname ZDOTDIR registrato dal fake
runtime_zdotdir derivato testualmente da fixture_root
```

Il bootstrap RumiAI canonicalizza la propria root fisica. Il test aveva creato `fixture_root` sotto `$TMPDIR` ma non lo aveva successivamente canonicalizzato; su macOS questo riproduce la stessa divergenza logica/fisica `/var/...` ↔ `/private/var/...`.

La correzione permanente canonicalizza `fixture_root` con `pwd -P` immediatamente dopo la creazione della fixture e prima di derivare tutti i pathname attesi.

Il boundary di prodotto resta esattamente quello già fissato:

```text
configurazione canonica:
$m_CONF_DIR/sys/shell/zsh

runtime ZDOTDIR:
$m_HOME_DIR/sys/shell/zsh
```

Implementazione suite:

```text
rumiai-tests@68e12c37dae9789bc44d966578e76e9530d7db95
```

Non viene modificato `rumiai-os` e non viene riaperta la decisione sul runtime state Zsh.

## 3. Relazione con il precedente `pkg_extract` realignment

Il pattern osservato è lo stesso già emerso nella precedente full validation macOS per `pkg-extract/contract.test`:

```text
target canonicalizza pathname esistenti
+
test confronta pathname testuali non canonicalizzati
=
FAIL host-specific del test pur a parità di oggetto filesystem
```

La regola per i test resta quella generale di `TESTING.md`: quando la proprietà verificata riguarda pathname fisici/canonicalizzati, la fixture deve canonicalizzare le proprie aspettative e non hardcodare una particolare spelling host-specific equivalente.

Non viene introdotta una nuova primitive di test.

## 4. Coppia candidata corrente

Dopo i due riallineamenti della suite, il prodotto resta invariato:

```text
rumiai-os@130944920b5dab5f9d25bd3515667f5cdff36a48
```

La nuova suite candidata è:

```text
rumiai-tests@68e12c37dae9789bc44d966578e76e9530d7db95
```

La configurazione resta:

```text
selection=rumiai-os
```

`rumiai-validate.conf` non richiede modifica perché continua già a puntare a `rumiai-os@130944920b5dab5f9d25bd3515667f5cdff36a48` con `selection=rumiai-os`.

Per chiudere il gate cross-platform la nuova coppia esatta deve essere rieseguita su entrambi i reference host:

```text
1. Ubuntu 26.04 ARM64
2. macOS ARM64
```

Le due evidence precedenti restano valide soltanto per la suite `18cdcf231a1353a9cc903581030a6dc6a094df4c` che hanno effettivamente esercitato.

## 5. Invarianti

```text
MACOS-PATH-01  validation/20260909T205653+0200-28726 resta evidence immutabile PASS della coppia 1309449.../18cdcf2...
MACOS-PATH-02  validation/20260909T205717+0200-29273 resta evidence immutabile FAIL della stessa coppia
MACOS-PATH-03  i due FAIL macOS osservati sono drift di pathname expectation nei test, non modifiche richieste al prodotto
MACOS-PATH-04  pkg_download continua a canonicalizzare lo staging reale e il suo contratto/API non cambiano
MACOS-PATH-05  il boundary Zsh resta conf/sys/shell/zsh per configurazione canonica e home/sys/shell/zsh per runtime ZDOTDIR
MACOS-PATH-06  le fixture che confrontano pathname fisici canonicalizzano le proprie aspettative invece di assumere una spelling host-specific
MACOS-PATH-07  la nuova suite candidata è rumiai-tests@68e12c37dae9789bc44d966578e76e9530d7db95
MACOS-PATH-08  il prodotto candidato resta rumiai-os@130944920b5dab5f9d25bd3515667f5cdff36a48
MACOS-PATH-09  il gate cross-platform richiede PASS della coppia 1309449.../68e12c... sia su Ubuntu ARM64 sia su macOS ARM64 con selection=rumiai-os
```
