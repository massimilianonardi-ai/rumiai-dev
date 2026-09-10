# Decisione — Piano package corrente dopo consistency fix di `pkg uninstall`

Date: 2026-09-10  
Status: **Accepted**

## Scopo e supersession

Questo documento supersede, esclusivamente per stato operativo e revision-specific validation target, il checkpoint:

```text
decisions/rumiai-os/2026-09-10-package-current-plan-after-uninstall-implementation.md
```

Il contratto `pkg uninstall` resta quello fissato da:

```text
decisions/rumiai-os/2026-09-10-package-uninstall-contract.md
```

Nessuna semantica lifecycle è modificata da questo checkpoint.

---

## Consistency fix

Il post-change consistency scan dell'implementazione iniziale:

```text
rumiai-os@339af91035a6fb2a5608b952e2af41f7bd4cd333
```

ha rilevato che `lib/sh/pkg-uninstall.lib.sh` duplicava tre validator già esistenti in `pkg-integration.lib.sh` per:

```text
package name
upstream version
osarch
```

La duplicazione era semanticamente equivalente ma contraddiceva la regola `existing primitive first` di `CONSISTENCY-GATE.md`.

La correzione forward-only è:

```text
rumiai-os@4aa3dbe1d7df6bd20a1f84c284a739bfcc197501
commit: Reuse package integration validators
parent: 339af91035a6fb2a5608b952e2af41f7bd4cd333
```

La correzione:

```text
elimina _pkg_uninstall_name_valid
elimina _pkg_uninstall_version_valid
elimina _pkg_uninstall_osarch_valid
riusa _pkg_integration_name_valid
riusa _pkg_integration_version_valid
riusa _pkg_integration_osarch_valid
```

Non cambia parsing, local resolution, current handling, deintegration, multi-package semantics o status pubblici.

La revisione intermedia `339af910...` non viene validata né riscritta; resta nella storia Git come parent della correzione.

---

## Product diff corrente rispetto alla baseline già validata

Rispetto a:

```text
rumiai-os@79cb5964428ca68c06c2f4eac98ac7350ae9561f
```

la revisione corrente introduce soltanto il lifecycle locale di uninstall nei file:

```text
bin/sys/pkg
lib/sh/pkg-uninstall.lib.sh
```

Il command entry mantiene `100755`.

La libreria shell mantiene `100644`, non ha shebang e source `pkg-integration.lib.sh`, riusando le primitive di validazione, current/default e deintegration già esistenti.

Non vengono introdotti accessi a catalogo/upstream, SemVer, generations, inventory, purge, resolver o transaction framework.

---

## Permanent test e validation target

Il permanent test resta:

```text
tests/rumiai-os/pkg/uninstall.test
```

introdotto da:

```text
rumiai-tests@cedc24ae2a6007588f3ea92867703173481b7616
```

ed è `100755`.

La configurazione di validation è stata riallineata alla revisione finale prodotto in:

```text
rumiai-tests@8e1e36740fdb1bc9a81c3546c1c34cb6ffc668a7
commit: Validate package uninstall final revision
```

con:

```text
rumiai-os-commit  4aa3dbe1d7df6bd20a1f84c284a739bfcc197501
selection         rumiai-os/pkg
```

La coppia revision-specific da validare sui reference host è quindi:

```text
rumiai-os@4aa3dbe1d7df6bd20a1f84c284a739bfcc197501
rumiai-tests@8e1e36740fdb1bc9a81c3546c1c34cb6ffc668a7
selection: rumiai-os/pkg
```

La selezione `rumiai-os/pkg` copre il nuovo `uninstall.test` e i test già esistenti del command/layer `pkg`, incluso `install.test`, proteggendo anche il riallineamento del caricamento subcommand-specific delle librerie.

La revisione `4aa3dbe...` resta **pending physical validation** fino a evidence positiva revision-specific sui reference Ubuntu ARM64 e macOS ARM64.

---

## Stato fase lifecycle

```text
J1  contratto pkg uninstall                                      [completato]
J1  permanent test pkg uninstall                                 [completato]
J1  implementazione pkg uninstall + consistency fix              [completato]
J2  physical validation pkg uninstall + pkg command regression   [corrente]
J3  lifecycle version/current: naming + public contract          [successivo]
K   dependency/facility/state avanzato quando richiesto          [successivo]
```

`version/current` resta un label di pianificazione e non definisce autonomamente nomi di CLI pubblica. Non devono quindi essere introdotti per inferenza sottocomandi quali `pkg version`, `pkg versions`, `pkg current` o `pkg default` senza una decisione Accepted o una correzione esplicita dell'utente.

---

## Invarianti correnti

```text
PKG-NOW-52  la revisione prodotto candidata alla validation è rumiai-os@4aa3dbe
PKG-NOW-53  339af910 resta revisione intermedia non validata e non viene riscritta
PKG-NOW-54  pkg-uninstall riusa i validator esistenti di pkg-integration; non ne mantiene duplicati
PKG-NOW-55  il contratto uninstall non cambia con il consistency fix
PKG-NOW-56  la validation usa rumiai-tests@8e1e367 + rumiai-os@4aa3dbe + selection rumiai-os/pkg
PKG-NOW-57  4aa3dbe non è ancora fisicamente validata
PKG-NOW-58  version/current resta un confine di design con naming pubblico non ancora fissato
PKG-NOW-59  Git resta forward-only
```
