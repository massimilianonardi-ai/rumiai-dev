# Evidence — Release validation `jq/linux-x86_64`

Date: 2026-09-16  
Status: **Accepted / VALIDATED for the recorded target and revisions**

## 1. Scope

Questa evidence chiude il target:

```text
jq/linux-x86_64
```

nel gate definito da:

```text
decisions/rumiai-tests/2026-09-15-package-release-runtime-analysis-gate.md
```

Non modifica né reinterpreta le sessioni storiche precedenti. In particolare, l'evidence Ubuntu x64 precedente resta corretta per le revisioni allora esercitate e per il suo stato `PENDING` di `jq`.

## 2. Host e revisioni

Host fisico:

```text
OS            Ubuntu 24.04.5 LTS
architecture  x86_64
kernel        Linux 7.0.0-30-generic
hostname      PRTL-GS-01
```

Scope versionato:

```text
validation/package-release-jq.conf
```

Revisioni esercitate:

```text
rumiai-os     0751add1a59f90d4a0fc19b36db9d4dbda0167ad
rumiai-tests  eb3b4d9ab4230fd31e0c994c336e26654dd48f28
pkg-catalog   af4332445d8f6ad678ff7ec2a14e482358a43182
jq tree       4119740a4a92c4da21c772c3613a6144abd35611
```

## 3. Scope richiesto ed esiti

Lo scope `package-release-jq` richiede esattamente:

```text
rumiai-tests/lib/package-release-reference.test
rumiai-tests/lib/package-release-wrapper-reference.test
external/jq/release-live.test
```

Sessioni positive:

```text
20260916T114002+0200-1559418  PASS  rumiai-tests/lib/package-release-reference.test
20260916T114005+0200-1559802  PASS  rumiai-tests/lib/package-release-wrapper-reference.test
20260916T114008+0200-1559974  PASS  external/jq/release-live.test
```

Tutte le selection richieste hanno quindi PASS sul target esercitato.

## 4. Runtime evidence

La prova live ha installato realmente:

```text
jq@jq-1.8.2!linux-x86_64
```

Il candidate upstream osservato da `pkg-analyze` e' stato:

```text
jq-linux-amd64
```

Il dynamic probe e' stato realmente eseguito:

```text
Probe 1: jq-linux-amd64
exit-status: 0
```

Il report ha inoltre registrato:

```text
package-root path delta:             empty
redirected-environment path delta:  empty
original-HOME path delta:           empty
```

L'inventario supplementare del release gate ha confermato:

```text
package-root=runtime-immutable
```

proteggendo pathname/tipo, mode, contenuto SHA-256 dei regular file e target dei symlink secondo il contratto del helper di release.

Il concrete command RumiAI `jq` e' stato esercitato dal release-live test oltre al probe diretto del payload.

## 5. Stato

Per le esatte revisioni e il target sopra registrati:

```text
jq/linux-x86_64  VALIDATED
```

Questo stato non viene esteso per analogia agli altri target dichiarati di `jq`:

```text
linux-arm64
macos-arm64
macos-x86_64
windows-arm64
windows-x86_64
```

che richiedono le rispettive evidence fisiche applicabili.

## 6. Invarianti dell'evidence

```text
JQ-RELEASE-X64-01  jq/linux-x86_64 e' VALIDATED soltanto per le revisioni registrate
JQ-RELEASE-X64-02  tutte le selection del package-release-jq scope hanno PASS
JQ-RELEASE-X64-03  pkg-analyze ha eseguito realmente il candidate jq-linux-amd64 con exit status 0
JQ-RELEASE-X64-04  package-root path delta e original-HOME path delta sono vuoti
JQ-RELEASE-X64-05  redirected-environment path delta osservato e' vuoto
JQ-RELEASE-X64-06  la package root e' risultata runtime-immutable anche per contenuto/mode/symlink target
JQ-RELEASE-X64-07  il command RumiAI integrato resta evidence distinta ed e' stato esercitato
JQ-RELEASE-X64-08  nessun altro target jq viene validato per analogia
JQ-RELEASE-X64-09  evidence storiche precedenti restano immutabili
JQ-RELEASE-X64-10  nessuna modifica a rumiai-os o pkg-catalog deriva da questa chiusura
```
