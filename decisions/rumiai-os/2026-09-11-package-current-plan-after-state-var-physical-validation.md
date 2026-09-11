# Piano corrente — dopo physical validation package state / `var`

Date: 2026-09-11  
Status: **Accepted — implementation physically validated**

## 1. Scopo

Questo checkpoint registra la physical validation riuscita della materializzazione package state / `var` definita da:

```text
decisions/rumiai-os/2026-09-11-package-state-var-default-materialization.md
```

Sostituisce `decisions/rumiai-os/2026-09-11-package-current-plan-after-state-var-materialization-implementation.md` esclusivamente come stato operativo corrente. Le evidence precedenti restano immutabili e revision-specific.

Non viene introdotto un nuovo nome di fase.

---

## 2. Coppia validata

Prodotto:

```text
rumiai-os@3bbeefcaf6f25b4b2d22dcb9ff497f0b5b6810e6
```

Suite permanente:

```text
rumiai-tests@a10d9eb484590d71e2a8424da45cdac9fb722caa
```

Selection:

```text
rumiai-os/pkg
```

`rumiai-validate.conf` alla revisione suite validata pinna esattamente:

```text
rumiai-os-commit	3bbeefcaf6f25b4b2d22dcb9ff497f0b5b6810e6
selection	rumiai-os/pkg
```

La selection contiene 9 test.

---

## 3. Evidence Ubuntu ARM64

Validation branch:

```text
validation/20260911T172246+0200-242953
```

Evidence commit:

```text
f976f825b9d6a031586bba358851419f3ce7cd5c
```

Parent dell'evidence commit:

```text
a10d9eb484590d71e2a8424da45cdac9fb722caa
```

Host:

```text
Ubuntu 26.04.1 LTS
aarch64
Linux 7.0.0-31-generic
```

Suite revision registrata dalla sessione:

```text
a10d9eb484590d71e2a8424da45cdac9fb722caa
```

Risultato:

```text
PASS rumiai-os/pkg/catalog-snapshot.test
PASS rumiai-os/pkg/default.test
PASS rumiai-os/pkg/dependency.test
PASS rumiai-os/pkg/env.test
PASS rumiai-os/pkg/facility.test
PASS rumiai-os/pkg/install.test
PASS rumiai-os/pkg/state.test
PASS rumiai-os/pkg/uninstall.test
PASS rumiai-os/pkg/versions.test
```

Runner exit status:

```text
0
```

---

## 4. Evidence macOS ARM64

Validation branch:

```text
validation/20260911T172302+0200-32608
```

Evidence commit:

```text
fc693222b175c4ad431cacfb50bc2ca1863d7ecf
```

Parent dell'evidence commit:

```text
a10d9eb484590d71e2a8424da45cdac9fb722caa
```

Host:

```text
macOS 26.6.2
arm64
Darwin 25.6.0
```

Suite revision registrata dalla sessione:

```text
a10d9eb484590d71e2a8424da45cdac9fb722caa
```

Risultato:

```text
PASS rumiai-os/pkg/catalog-snapshot.test
PASS rumiai-os/pkg/default.test
PASS rumiai-os/pkg/dependency.test
PASS rumiai-os/pkg/env.test
PASS rumiai-os/pkg/facility.test
PASS rumiai-os/pkg/install.test
PASS rumiai-os/pkg/state.test
PASS rumiai-os/pkg/uninstall.test
PASS rumiai-os/pkg/versions.test
```

Runner exit status:

```text
0
```

---

## 5. Chiusura della unità

La coppia esatta prodotto/suite passa quindi l'intera selection `rumiai-os/pkg` sui due reference host correnti:

```text
Ubuntu ARM64   9/9 PASS   runner 0
macOS ARM64    9/9 PASS   runner 0
```

La materializzazione package state / `var`, inclusi routing relativo, factory preservation, inizializzazione dello state, preservazione dello state tra versioni, uninstall/deintegrate non distruttivi e rollback sincrono coperto dal test permanente, è ora fisicamente validata per la revisione prodotto sopra indicata.

Non è richiesta alcuna ulteriore modifica a `rumiai-os` o `rumiai-tests` per chiudere questa unità.

---

## 6. Confini che restano invariati

Restano fuori dallo scope e non sono stati implicitamente autorizzati:

```text
State Instance nominate operative
state compatibility policy
migration
purge
factory reset CLI
backup/retention
state switch runtime o persistente
transaction/recovery engine generale
range/default dichiarativo indipendente dai mapping var
```

Restano inoltre invarianti:

```text
state baseline = $m_ROOT/<area>/<pkg>
aree = conf,data,home,cache,log,run,tmp
nessun $m_ROOT/var
var/ esclusivamente package-local
uninstall/deintegrate preservano backing state esterno
nessun nuovo nome di fase fissato
Git forward-only
```

---

## 7. Stato operativo corrente

La unità package state / `var` è:

```text
contract                 completed
implementation           completed
permanent test           completed
Ubuntu ARM64 validation  completed
macOS ARM64 validation   completed
```

Il package manager ritorna ora alla pianificazione. Nessuna feature successiva e nessun nome di fase successivo vengono fissati da questo checkpoint; il prossimo lavoro deve iniziare con il normale authority preflight e con la definizione esplicita del nuovo scope.

---

## 8. Invarianti di continuità

```text
PKG-STATE-VAL-01  product revision validated = rumiai-os@3bbeefcaf6f25b4b2d22dcb9ff497f0b5b6810e6
PKG-STATE-VAL-02  permanent-suite revision validated = rumiai-tests@a10d9eb484590d71e2a8424da45cdac9fb722caa
PKG-STATE-VAL-03  Ubuntu evidence = validation/20260911T172246+0200-242953 @ f976f825b9d6a031586bba358851419f3ce7cd5c
PKG-STATE-VAL-04  macOS evidence = validation/20260911T172302+0200-32608 @ fc693222b175c4ad431cacfb50bc2ca1863d7ecf
PKG-STATE-VAL-05  both evidence sessions = PASS 9/9, runner status 0
PKG-STATE-VAL-06  package state / var unit is completed and physically validated
PKG-STATE-VAL-07  old evidence remains immutable and revision-specific
PKG-STATE-VAL-08  no product or permanent-suite change was required after validation
PKG-STATE-VAL-09  no subsequent package feature or phase name is fixed
PKG-STATE-VAL-10  Git remains forward-only
```
