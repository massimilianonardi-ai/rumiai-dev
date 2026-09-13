# Decisione — Checkpoint stabile dell'attuale `rumiai-os`

Date: 2026-09-13  
Status: **Accepted**

## 1. Scopo

Questa decisione dichiara il checkpoint stabile richiesto da:

```text
decisions/rumiai-os/2026-09-12-stabilize-current-rumiai-os-before-model-migration.md
```

Il checkpoint congela una baseline affidabile dell'attuale modello operativo di `rumiai-os` da usare come riferimento per l'assessment e per un'eventuale futura migrazione architetturale.

La stabilità qui dichiarata non significa completezza funzionale.

Non vengono introdotti nuovi contratti di prodotto e non viene modificato alcun repository operativo.

## 2. Revisioni del checkpoint

La baseline è identificata da:

```text
rumiai-os     96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
rumiai-tests  bb335ca567bf465ba08f203caa2e5258db670869
pkg-catalog   6443f265a922f7cff070f02e75d057727a6e5eb9
```

`rumiai-dev` resta la fonte autorevole per regole, specifiche e decisioni correnti; questa decisione entra a far parte di tale autorità dal proprio commit in avanti.

## 3. Perimetro stabile incluso

Il checkpoint include le fondamenta correnti già consolidate e necessarie a descrivere il sistema che una futura migrazione dovrà trasformare, fra cui:

```text
identity e bootstrap/runtime correnti `rumiai-os`
integrated shebang `#!/usr/bin/env rumiai-os`
runtime exposure corrente
semantic root e bootstrap environment correnti
PATH corrente
shell boundary corrente
lang/log e primitive base già consolidate
package store e package materialization correnti
package command binding e package launcher correnti
package environment layering corrente
package state/default/var routing corrente
State Instance eligibility contract corrente
filesystem state area-first corrente
permanent testing e validation workflow correnti
```

Il checkpoint non implica che ogni futura capability prevista da RumiAI esista già.

## 4. Stato del package runtime al checkpoint

Il commit prodotto:

```text
96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
```

chiude forward-only l'esperimento relativo a un explicit package launch mode che non era necessario al modello corrente.

La baseline non incorpora quindi come contratto una modalità di launch esplicita inutilizzata.

Restano operative le primitive package correnti già consolidate, incluso il launcher normale e il modello secondo cui state nativamente redirigibile e state pathname-routed vengono trattati secondo i contratti Accepted correnti.

## 5. Permanent test

La revisione:

```text
rumiai-tests@bb335ca567bf465ba08f203caa2e5258db670869
```

costituisce la suite permanente associata al checkpoint.

I permanent test restano l'autorità meccanica per le proprietà consolidate che non richiedono una prova fisica specifica dell'host.

Questa decisione non crea un nuovo runner, un nuovo tipo di sessione o una nuova classe di test.

## 6. Physical validation revision-specific

Le proprietà di package integration che dipendono materialmente dall'host sono state esercitate contro l'esatto:

```text
rumiai-os@96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
```

sui due reference host correnti.

### 6.1 Ubuntu 26.04 ARM64

Evidence ref:

```text
validation/20260912T220010+0200-319720
```

Evidence commit:

```text
2adb5227351880723c194298534aa112c8c3f5bd
```

Suite parent:

```text
d28b580b0745e7ae60a5226446767038fc40c21c
```

Validation configuration:

```text
rumiai-os-commit  96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
selection         external/electron
```

Host:

```text
Ubuntu 26.04.1 LTS
Linux aarch64
```

Risultati applicabili:

```text
PASS external/electron/install-live.test
PASS external/electron/linux-launch-live.test
SKIP external/electron/macos-launch-live.test
```

Il live log registra inoltre:

```text
pkg-catalog@6443f265a922f7cff070f02e75d057727a6e5eb9
Electron BrowserWindow ready
```

### 6.2 macOS ARM64

Una precedente validation del gruppo Electron ha correttamente prodotto FAIL sul launch macOS e l'evidence storica resta immutata.

Dopo la correzione del catalogo, la validation finale applicabile è:

```text
validation/20260912T224200+0200-78239
```

Evidence commit:

```text
9fb398443be45c5f1a53a974e21340ecdd95fdc5
```

Suite parent:

```text
bb335ca567bf465ba08f203caa2e5258db670869
```

Validation configuration:

```text
rumiai-os-commit  96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
selection         external/electron/macos-launch-live.test
```

Host:

```text
macOS 26.6.2
Darwin arm64
```

Risultato:

```text
PASS external/electron/macos-launch-live.test
```

Il test è self-contained e comprende installazione dal live catalog, binding pubblico e launch diretto del runtime package-local. Il live log registra:

```text
pkg-catalog@6443f265a922f7cff070f02e75d057727a6e5eb9
Electron BrowserWindow ready
launch direct-runtime
```

## 7. Interpretazione dell'evidence

L'evidence sopra non viene estesa oltre ciò che ha fisicamente esercitato.

In particolare:

```text
PASS su un host non viene reinterpretato come PASS dell'altro host
le sessioni storiche FAIL restano evidenza storica della revisione/configurazione esercitata
la correzione successiva non riscrive né relabella l'evidence precedente
le proprietà puramente meccaniche continuano a essere protette dai permanent test
```

La combinazione di permanent test correnti e physical evidence applicabile è ritenuta proporzionata al perimetro del checkpoint.

## 8. Limitazioni esplicitamente accettate

La baseline è intenzionalmente incompleta.

Non costituiscono blocker del checkpoint, perché non rendono ambiguo il comportamento incluso:

```text
assenza delle future capability AI non ancora implementate
State Instance management non ancora implementato
assenza di un futuro substrate/runtime `m` operativo
assenza del futuro state model comune e multi-user
assenza della futura stratificazione stable/development/private come contratto attivo
assenza di service/daemon contract futuri non ancora richiesti
explicit package launch mode non adottato
```

Queste aree possono essere oggetto della futura architettura o di successivo sviluppo, ma non sono precondizioni per avere una baseline affidabile dell'attuale modello.

## 9. Contratti che restano correnti

Alla revisione del checkpoint restano operative le fonti correnti e i relativi invarianti, incluso almeno:

```text
runtime tecnico: rumiai-os
bootstrap root:   /bin/sh
integrated shebang: #!/usr/bin/env rumiai-os
PATH: sys-osarch -> sys -> ext-osarch -> ext -> host PATH
semantic root correnti top-level
state package area-first
nessuna root globale state/
base component state sotto <area>/sys/<component>
package state sotto <area>/<pkg> o <area>/<pkg>@!<state-instance>
package-local var/ come routing corrente verso lo state selezionato
```

I documenti di esplorazione del futuro modello non modificano questi contratti.

## 10. Rapporto con l'assessment già svolto

Gli assessment non normativi del 2026-09-13 sono stati prodotti mentre mancava ancora una dichiarazione formale separata del checkpoint.

Questa decisione chiude tale prerequisito senza trasformare retroattivamente gli assessment in decisioni operative.

Gli assessment possono ora essere riletti contro la baseline esatta qui fissata e aggiornati forward-only quando necessario.

## 11. Nessuna attivazione del futuro modello

Questo checkpoint **non** supera il gate definito da:

```text
decisions/rumiai-os/2026-09-12-substrate-exploration-activation-gate.md
```

In particolare non autorizza:

```text
rename `rumiai-os` -> `m`
cambio degli integrated shebang
nuovo PATH RumiAI/m
nuovo filesystem state/
nuove environment variable future
nuova classificazione stable/development/private
migrazione di rumiai-os
migrazione di rumiai-tests
migrazione di pkg-catalog
```

Qualunque futura activation/migration resta subordinata a una decisione complessiva esplicita e all'approvazione dell'utente prevista dal gate.

## 12. Git e recuperabilità

Il checkpoint è identificato da revisioni committed e preserva la storia forward-only.

Per codice, specifiche, test e catalogo tracked, Git mantiene integralmente la baseline comparativa.

Questo non implica che Git sia backup dello state operativo ignorato o materializzato localmente. Un'eventuale futura migrazione dello state dovrà continuare a prevedere snapshot/backup indipendenti secondo l'assessment già documentato.

## 13. Invarianti del checkpoint

```text
CURRENT-STABLE-01  rumiai-os@96d399d0... è la baseline prodotto del checkpoint
CURRENT-STABLE-02  rumiai-tests@bb335ca... è la suite permanente corrente del checkpoint
CURRENT-STABLE-03  pkg-catalog@6443f26... è il catalogo qualificato dalla validation applicabile
CURRENT-STABLE-04  il checkpoint è stabile ma non implica completezza funzionale
CURRENT-STABLE-05  i contratti correnti restano operativi fino a esplicita supersession
CURRENT-STABLE-06  l'evidence resta revision-specific e non viene relabellata
CURRENT-STABLE-07  il checkpoint non attiva il futuro modello
CURRENT-STABLE-08  l'eventuale migrazione successiva resta Git forward-only
```

## 14. Decisione

La baseline corrente descritta sopra è dichiarata:

> **checkpoint stabile dell'attuale `rumiai-os`, sufficiente come punto di riferimento per completare la valutazione e preparare una eventuale decisione esplicita di migrazione.**

Questa dichiarazione soddisfa il prerequisito di stabilità fissato il 2026-09-12 senza modificare il modello operativo corrente e senza anticipare alcuna parte del futuro modello.
