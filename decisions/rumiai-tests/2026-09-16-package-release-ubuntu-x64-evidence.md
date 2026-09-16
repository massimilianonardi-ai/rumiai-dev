# Evidence — Package release runtime analysis su Ubuntu x64

Date: 2026-09-16  
Status: **Accepted / Partial physical evidence — release gate still open**

## 1. Scope

Questa evidence registra i risultati fisici Ubuntu x64 del gate definito da:

```text
decisions/rumiai-tests/2026-09-15-package-release-runtime-analysis-gate.md
```

Riguarda esclusivamente:

```text
chrome
chromium
jq
micromamba
nodejs
pulsar
```

Non modifica le decisioni package-specifiche, non modifica `rumiai-os` o `pkg-catalog` e non reinterpreta retroattivamente alcuna sessione precedente.

## 2. Host

Le sessioni qui registrate sono state prodotte su:

```text
OS            Ubuntu 24.04.5 LTS
architecture  x86_64
kernel        Linux 7.0.0-30-generic
hostname      PRTL-GS-01
```

Ubuntu x64 resta un host periodico pertinente ai target esercitati; questa evidence non sostituisce le prove richieste sugli altri host/target applicabili.

## 3. Target product e suite

Gli scope package-release esercitati fissano:

```text
rumiai-os  0751add1a59f90d4a0fc19b36db9d4dbda0167ad
```

Le sessioni `pulsar`, `nodejs`, `micromamba`, `jq` e `chromium` hanno usato:

```text
rumiai-tests  3e5fb48413c75008ee04dd8f3d602217bac5d30a
```

La sessione `chrome` ha usato:

```text
rumiai-tests  146239a199a1ac6253b30ca73b9bdd97cf692e65
```

La differenza fra queste due revisioni riguarda soltanto `tests/rumiai-os/bootstrap/core-library-independence.test`; il helper package-release, i wrapper e i sei scope package-release restano semanticamente invariati.

## 4. Risultati per target

### 4.1 `pulsar/linux-x86_64`

Sessione release-live:

```text
20260916T084204+0200-692503
FAIL external/pulsar/release-live.test
```

L'installazione reale ha materializzato `pulsar@v1.132.1!linux-x86_64` e `pkg-analyze` ha individuato il candidate upstream `pulsar`.

L'operatore ha selezionato il candidate, ma il prompt:

```text
Run the selected candidates? [y/N]
```

non ha ricevuto approvazione positiva. Il report registra:

```text
Dynamic probes: skipped
```

Il successivo messaggio `pkg-analyze reported package-root pathname/type changes` non costituisce evidence di una mutazione del package root: il dynamic probe non e' stato eseguito e quindi le sezioni delta richieste non erano presenti.

Stato:

```text
PENDING
```

Motivo: manca la prova runtime richiesta; nessuna remediation package viene dedotta da questa sessione.

### 4.2 `nodejs/linux-x86_64`

Sessione release-live:

```text
20260916T084851+0200-908200
FAIL external/nodejs/release-live.test
```

La prova supera installazione, catalog-tree check e individuazione del candidate prima di fallire con:

```text
pkg-analyze reported package-root pathname/type changes
```

La revisione della suite esercitata conserva il report `pkg-analyze` soltanto alla fine di una run positiva. In caso di failure su uno dei delta, il file diagnostico viene eliminato dal cleanup senza essere pubblicato nella sessione.

Il test permanente `rumiai-tests/lib/package-release-reference.test` protegge la semantica del parser di delta, ma questa sessione non conserva i pathname osservati. Non viene quindi attribuita una remediation semantica a Node.js senza l'evidence mancante.

Stato:

```text
PENDING
```

Motivo: gate fallito, ma diagnostica insufficiente per distinguere con precisione una mutazione runtime da un problema della prova.

### 4.3 `micromamba/linux-x86_64`

Sessione release-live:

```text
20260916T085209+0200-989778
FAIL external/micromamba/release-live.test
```

Failure osservato:

```text
operation=extract
command=bzip2
format=tar.bz2
reason=extraction-failed
```

`pkg install micromamba` non completa l'estrazione perche' `bzip2` non e' disponibile sull'host. Il gate non raggiunge `pkg-analyze`.

Stato:

```text
BLOCKED
```

Motivo: il target non e' installabile sull'host esercitato con le capability correnti. La scelta della remediation deve essere consolidata prima di qualsiasi modifica semantica a prodotto o catalogo.

### 4.4 `jq/linux-x86_64`

Sessione release-live:

```text
20260916T085253+0200-991010
FAIL external/jq/release-live.test
```

La prova fallisce con:

```text
pkg-analyze reported package-root pathname/type changes
```

Come per Node.js, la suite esercitata non pubblica il report `pkg-analyze` prima del failure e il cleanup elimina l'evidence di dettaglio. Non viene quindi introdotta una correzione della package definition `jq` sulla sola base del messaggio aggregato.

Stato:

```text
PENDING
```

Motivo: gate fallito con diagnostica insufficiente; serve una nuova evidence che conservi il report prima di classificare una remediation package.

### 4.5 `chromium/linux-x86_64`

Sessione release-live:

```text
20260916T085328+0200-993507
FAIL external/chromium/release-live.test
```

L'installazione reale ha materializzato `chromium@1698667!linux-x86_64`; il setup setuid e il candidate discovery sono stati raggiunti. `pkg-analyze` ha individuato fra gli altri:

```text
1  chrome
2  chrome-wrapper
3  chrome_crashpad_handler
4  chrome_sandbox
```

Nessun candidate e' stato selezionato al prompt. Il report registra:

```text
Selected export candidates:
(none)
```

Il dynamic probe richiesto non e' quindi stato eseguito.

Stato:

```text
PENDING
```

Motivo: prova runtime incompleta; nessuna remediation Chromium viene dedotta da questa sessione.

### 4.6 `chrome/linux-x86_64`

Sessione release-live:

```text
20260916T085549+0200-1003614
FAIL external/chrome/release-live.test
```

Failure osservato:

```text
repository=chrome
reason=upstream-version-unavailable
version=153.0.8010.36-1
```

Questo comportamento e' coerente con `2026-09-15-google-chrome-package-integration.md`: una versione rimossa dall'indice APT Stable corrente deve fallire chiusa; RumiAI non usa archive o mirror fallback. La stessa decisione assegna alla manutenzione del `pkg-catalog` la rimozione o l'avanzamento di range/anchor non piu' pubblicati.

Stato:

```text
BLOCKED
```

Motivo: l'anchor catalogo corrente non e' piu' pubblicato dall'upstream autorevole e richiede manutenzione del catalogo prima di una nuova release validation.

## 5. Stato Ubuntu x64 dopo queste sessioni

```text
chrome/linux-x86_64      BLOCKED
chromium/linux-x86_64    PENDING
jq/linux-x86_64          PENDING
micromamba/linux-x86_64  BLOCKED
nodejs/linux-x86_64      PENDING
pulsar/linux-x86_64      PENDING
```

Nessuno dei sei target Ubuntu x64 e' `VALIDATED` da queste sessioni.

## 6. Limite diagnostico della suite rilevato

Le sessioni hanno evidenziato un limite reale di `rumiai-tests/lib/package-release.lib`:

1. il report `pkg-analyze` viene pubblicato soltanto alla fine di una run positiva;
2. un failure sui delta elimina quindi il report durante il cleanup;
3. per GUI, l'assenza del dynamic probe puo' essere diagnosticata successivamente come presunto `package-root pathname/type changes`, perche' il controllo dei delta precede la verifica che il candidate sia stato realmente eseguito.

Questo e' un difetto della diagnostica/evidence della suite, non una nuova semantica di prodotto. Deve essere corretto in `rumiai-tests` prima di usare una nuova run per diagnosticare Node.js/jq e prima di interpretare automaticamente un probe GUI saltato come mutazione del package root.

La correzione non autorizza a restringere alcuno dei sei scope esistenti.

## 7. Invarianti dell'evidence

```text
PKG-RELEASE-X64-01  host esercitato = Ubuntu 24.04.5 LTS / x86_64
PKG-RELEASE-X64-02  target rumiai-os degli scope = 0751add1a59f90d4a0fc19b36db9d4dbda0167ad
PKG-RELEASE-X64-03  nessuno dei sei target e' VALIDATED da queste sessioni
PKG-RELEASE-X64-04  chrome/linux-x86_64 e' BLOCKED dalla rimozione upstream dell'anchor corrente
PKG-RELEASE-X64-05  micromamba/linux-x86_64 e' BLOCKED dalla dipendenza di estrazione bzip2 non soddisfatta sull'host
PKG-RELEASE-X64-06  chromium e pulsar restano PENDING per dynamic probe non eseguito
PKG-RELEASE-X64-07  nodejs e jq restano PENDING finche' una nuova evidence conserva il report che ha causato il failure
PKG-RELEASE-X64-08  le sessioni precedenti e i loro risultati restano immutabili
PKG-RELEASE-X64-09  nessun target differente viene validato per analogia
PKG-RELEASE-X64-10  nessuna modifica a rumiai-os o pkg-catalog e' implicata da questa evidence
PKG-RELEASE-X64-11  Git resta forward-only
```
