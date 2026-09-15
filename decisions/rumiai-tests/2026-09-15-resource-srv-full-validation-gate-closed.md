# Decisione — Chiusura full validation resource / `srv`

Date: 2026-09-15  
Status: **Accepted; physical validation complete on ARM64 reference hosts**

## 1. Coppia validata

La coppia revision-specific chiusa da questa decisione è:

```text
rumiai-os    a5442e527f6bc7a70022f09330ba27770c0b5fb7
rumiai-tests df36a9d359901fa16daa1c7b763a3d8ec85ca2a2
selection    rumiai-os
```

La revisione prodotto è rimasta invariata durante la remediation test-side. La suite `df36a9d359901fa16daa1c7b763a3d8ec85ca2a2` incorpora il riallineamento delle fixture al resource model corrente, la correzione del digest SHA-256 atteso nel test Node.js, il riallineamento `pkg/setuid` a `res/sys/lang` e l'aspettativa canonicale del test `srv` su macOS.

La stessa identica coppia è stata esercitata con successo su entrambi i reference host ARM64 correnti.

## 2. Ubuntu 26.04 ARM64 — PASS

Sessione pubblicata:

```text
validation/20260915T155243+0200-389501
```

Host registrato:

```text
Ubuntu 26.04.1 LTS
aarch64
```

Revisioni e selection registrate:

```text
rumiai-os    a5442e527f6bc7a70022f09330ba27770c0b5fb7
rumiai-tests df36a9d359901fa16daa1c7b763a3d8ec85ca2a2
selection    rumiai-os
```

Risultato:

```text
PASS   83
FAIL   0
SKIP   2
ERROR  0
TOTAL  85
runner-exit-status 0
```

I due SKIP sono esclusivamente:

```text
rumiai-os/shell/zsh-alias-preservation.test
rumiai-os/shell/zsh-zdotdir-preservation.test
```

per indisponibilità di Zsh sull'host Ubuntu corrente. Il test indipendente:

```text
rumiai-os/shell/zsh-runtime-state-boundary.test
```

è PASS.

## 3. macOS ARM64 — PASS

Sessione pubblicata:

```text
validation/20260915T155321+0200-56557
```

Host registrato:

```text
Darwin 26.6.2
arm64
```

Revisioni e selection registrate:

```text
rumiai-os    a5442e527f6bc7a70022f09330ba27770c0b5fb7
rumiai-tests df36a9d359901fa16daa1c7b763a3d8ec85ca2a2
selection    rumiai-os
```

Risultato:

```text
PASS   85
FAIL   0
SKIP   0
ERROR  0
TOTAL  85
runner-exit-status 0
```

Tutti i test applicabili della selection `rumiai-os`, inclusi i test Zsh reali e `rumiai-os/srv/lifecycle.test`, sono PASS.

## 4. Proprietà coperte

Il gate chiude la physical validation della coppia esatta sopra indicata sui due reference host ARM64 correnti. La selection esercita, tra gli altri, i sottosistemi:

```text
bootstrap
command
digest
extract
http-fetch
json
lang
log
mk
osarch
pkg-analyze
pkg-download
pkg-extract
pkg-integration
pkg-launch
pkg-repository-github
pkg-repository-nodejs
pkg
read-key
shell
srv
state-path
```

La validation conferma in particolare che la remediation non richiedeva una modifica prodotto: `srv` mantiene il proprio contratto di canonicalizzazione e il resource model resta `res` / `res/sys/lang` senza ripristinare il top-level `lang` superseded.

## 5. Evidence precedente

Le sessioni fallite della coppia precedente restano evidence immutabile e revision-specific:

```text
validation/20260915T145047+0200-376171
validation/20260915T145126+0200-42022

rumiai-os    a5442e527f6bc7a70022f09330ba27770c0b5fb7
rumiai-tests 16f3926a224dd32d7d226a39234c779fa4ce1353
```

Non vengono reinterpretate come PASS e non vengono attribuite alla suite `df36a9d359901fa16daa1c7b763a3d8ec85ca2a2`.

Questa decisione chiude lo stato `physical validation pending` della decisione:

```text
decisions/rumiai-tests/2026-09-15-advance-validation-pair-after-resource-srv-remediation.md
```

senza modificarne i contratti tecnici o la storia della remediation.

## 6. Prossimo gate: Node.js live install

La decisione package Node.js richiede ancora la live validation revision-specific di download/install/launch reale.

Il gate successivo resta quindi:

```text
external/nodejs/install-live.test
```

come selection separata. La chiusura positiva della full-suite soddisfa la precondizione già fissata per avanzare a questo gate.

Questo documento non dichiara ancora fisicamente validata l'installazione reale Node.js e non estende l'evidence ARM64 corrente a Windows o a proprietà non esercitate dal test live.

## 7. Invarianti

```text
RESOURCE-SRV-GATE-01  coppia validata = rumiai-os@a5442e527f6bc7a70022f09330ba27770c0b5fb7 + rumiai-tests@df36a9d359901fa16daa1c7b763a3d8ec85ca2a2
RESOURCE-SRV-GATE-02  selection validata = rumiai-os
RESOURCE-SRV-GATE-03  Ubuntu ARM64 PASS = validation/20260915T155243+0200-389501
RESOURCE-SRV-GATE-04  macOS ARM64 PASS = validation/20260915T155321+0200-56557
RESOURCE-SRV-GATE-05  il gate full-suite ARM64 della coppia corrente è chiuso
RESOURCE-SRV-GATE-06  i due SKIP Ubuntu Zsh restano SKIP e non sono reinterpretati
RESOURCE-SRV-GATE-07  le failure evidence della suite 16f3926 restano immutabili e revision-specific
RESOURCE-SRV-GATE-08  rumiai-os resta invariato dalla remediation
RESOURCE-SRV-GATE-09  SRV-05 e il resource model corrente restano invariati
RESOURCE-SRV-GATE-10  external/nodejs/install-live.test è il gate separato successivo
RESOURCE-SRV-GATE-11  Git resta forward-only
```
