# Piano corrente — dopo physical validation package `env` e binding consumption

Date: 2026-09-11  
Status: **Current checkpoint — physical validation complete**

## 1. Unità chiusa

La unità descrittiva:

```text
package env materialization
+
resolved binding consumption at normal launch
```

è ora implementata e fisicamente validata.

La decisione autoritativa resta:

```text
decisions/rumiai-os/2026-09-11-package-env-materialization-and-binding-consumption.md
```

Il checkpoint precedente:

```text
decisions/rumiai-os/2026-09-11-package-current-plan-after-env-materialization-implementation.md
```

rimane storico e descrive correttamente lo stato precedente al gate fisico; non deve essere riscritto.

---

## 2. Coppia revision-specific validata

Prodotto:

```text
rumiai-os@6a7df568551032708b3d7f63056896e8be30365f
```

Suite permanente:

```text
rumiai-tests@90170bc07320d6ce49b7e647554e9a1b6bfb13a6
```

Configurazione:

```text
selection: rumiai-os/pkg
selected tests: 8
```

`rumiai-validate.conf` della suite validata pinna esattamente la revisione prodotto sopra indicata.

---

## 3. Evidence Ubuntu ARM64

Branch evidence immutabile:

```text
validation/20260911T144844+0200-239101
```

Evidence commit:

```text
5626b8efe2d142648a9531b3e1e1f831f5d32acc
```

Host:

```text
OS: Ubuntu 26.04.1 LTS
architecture: aarch64
kernel: Linux 7.0.0-31-generic
hostname: vmdev
```

Sessione:

```text
start: 2026-09-11T14:48:44+0200
selection: rumiai-os/pkg
rumiai-tests-commit: 90170bc07320d6ce49b7e647554e9a1b6bfb13a6
runner-exit-status: 0
```

Risultato:

```text
PASS  rumiai-os/pkg/catalog-snapshot.test
PASS  rumiai-os/pkg/default.test
PASS  rumiai-os/pkg/dependency.test
PASS  rumiai-os/pkg/env.test
PASS  rumiai-os/pkg/facility.test
PASS  rumiai-os/pkg/install.test
PASS  rumiai-os/pkg/uninstall.test
PASS  rumiai-os/pkg/versions.test
```

Totale:

```text
8 PASS / 8 selected
```

---

## 4. Evidence macOS ARM64

Branch evidence immutabile:

```text
validation/20260911T144902+0200-29372
```

Evidence commit:

```text
c08f4b5cc986acefad640f9d5a0e005132caa82a
```

Host:

```text
OS: Darwin 26.6.2
architecture: arm64
kernel: Darwin 25.6.0
hostname: MacBook-Air-di-Massimiliano.local
```

Sessione:

```text
start: 2026-09-11T14:49:02+0200
end: 2026-09-11T14:49:06+0200
selection: rumiai-os/pkg
rumiai-tests-commit: 90170bc07320d6ce49b7e647554e9a1b6bfb13a6
runner-exit-status: 0
```

Risultato:

```text
PASS  rumiai-os/pkg/catalog-snapshot.test
PASS  rumiai-os/pkg/default.test
PASS  rumiai-os/pkg/dependency.test
PASS  rumiai-os/pkg/env.test
PASS  rumiai-os/pkg/facility.test
PASS  rumiai-os/pkg/install.test
PASS  rumiai-os/pkg/uninstall.test
PASS  rumiai-os/pkg/versions.test
```

Totale:

```text
8 PASS / 8 selected
```

---

## 5. Proprietà fisicamente confermate

Le evidence revision-specific confermano sui due reference host correnti che:

```text
package env materialization funziona nel percorso permanente di integrazione
resolved dependency binding viene consumato al normal launch
normal launch non richiede il provider index per risolvere nuovamente la dependency
env.test passa insieme alla regressione completa rumiai-os/pkg
```

Le evidence precedenti, inclusa quella K2, restano immutabili e continuano a valere esclusivamente per le revisioni che esercitavano.

---

## 6. Stato operativo corrente

```text
K1 baseline                                  completed
K2 dependency resolution + binding lifecycle completed + physically validated
package env materialization                  completed + physically validated
resolved binding consumption at normal launch completed + physically validated
```

Non viene introdotto un nuovo nome di fase.

---

## 7. Prossimo tema di pianificazione

Il prossimo gap architetturale utile resta il baseline dello state package già previsto dalle decisioni Accepted:

```text
state non qualificato sotto $m_ROOT/<area>/<pkg>/
var/<area> come routing package-local
root/<path> -> var/<area>/<path> per pathname upstream state-bearing
```

Prima di qualsiasi implementazione prodotto devono essere chiusi almeno:

```text
serializzazione del mapping <root-relative-path> -> <state-area>
validazione dei mapping e degli overlap
inizializzazione del contenuto state-bearing
relazione con default/ senza perdita dei contenuti upstream sostituiti
rollback/lifecycle proporzionato
```

Restano fuori scope salvo decisione successiva esplicita:

```text
State Instance nominate
state migration
state compatibility framework
per-invocation state switching
transaction/recovery engine generale
```

Questo checkpoint autorizza la continuazione della pianificazione secondo le regole correnti, ma non costituisce di per sé autorizzazione a modificare `rumiai-os` per il prossimo tema.

---

## 8. Invarianti di continuità

```text
PKG-ENV-VAL-01  validated product = 6a7df568551032708b3d7f63056896e8be30365f
PKG-ENV-VAL-02  validated tests = 90170bc07320d6ce49b7e647554e9a1b6bfb13a6
PKG-ENV-VAL-03  selection = rumiai-os/pkg con 8/8 PASS su Ubuntu ARM64 e macOS ARM64
PKG-ENV-VAL-04  evidence branches e commits sono immutabili e revision-specific
PKG-ENV-VAL-05  package env materialization è fisicamente validata
PKG-ENV-VAL-06  normal launch consuma resolved binding senza dependency resolution runtime
PKG-ENV-VAL-07  nessun nuovo nome di fase è fissato
PKG-ENV-VAL-08  state/var è il prossimo tema di pianificazione
PKG-ENV-VAL-09  State Instance e migration restano fuori scope
PKG-ENV-VAL-10  prossimo cambiamento prodotto richiede il normale consenso esplicito previsto da RULES.md
PKG-ENV-VAL-11  Git resta forward-only
```
