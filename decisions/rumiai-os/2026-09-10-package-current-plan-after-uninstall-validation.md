# Decisione — Piano package corrente dopo physical validation di `pkg uninstall`

Date: 2026-09-10  
Status: **Accepted**

## Scopo e supersession

Questo documento supersede, esclusivamente per stato operativo e sequencing corrente, il checkpoint:

```text
decisions/rumiai-os/2026-09-10-package-current-plan-after-uninstall-consistency-fix.md
```

Il contratto `pkg uninstall` resta autorevolmente definito da:

```text
decisions/rumiai-os/2026-09-10-package-uninstall-contract.md
```

La correzione di portabilità e la relativa evidence restano documentate in:

```text
decisions/rumiai-os/2026-09-10-package-uninstall-macos-locale-validation-correction.md
decisions/rumiai-os/2026-09-10-package-uninstall-arm64-physical-validation.md
```

Nessuna semantica lifecycle viene modificata da questo checkpoint.

---

## Stato revision-specific acquisito

La revisione:

```text
rumiai-os@164fe1b058710a6871266aab7ca9dc4495cbe4bc
```

è fisicamente validata sul gruppo:

```text
rumiai-os/pkg
```

con:

```text
rumiai-tests@71963b08476ff5c4d5557ed593cd6c4c8414b63c
```

su entrambi i reference host ARM64.

Ubuntu ARM64:

```text
validation/20260910T220254+0200-111026
PASS 3
FAIL 0
SKIP 0
ERROR 0
```

macOS ARM64:

```text
validation/20260910T220311+0200-16234
PASS 3
FAIL 0
SKIP 0
ERROR 0
```

I tre permanent test selezionati risultano PASS su entrambi gli host:

```text
rumiai-os/pkg/catalog-snapshot.test
rumiai-os/pkg/install.test
rumiai-os/pkg/uninstall.test
```

Il gate J2 è quindi chiuso.

Le evidence della precedente revisione `rumiai-os@4aa3dbe...` restano immutabili e revision-specific: Ubuntu PASS, macOS FAIL. Non vengono attribuite alla revisione corretta.

---

## Stato fase lifecycle

```text
J1  contratto pkg uninstall                                      [completato]
J1  permanent test pkg uninstall                                 [completato]
J1  implementazione pkg uninstall + consistency fix              [completato]
J2  physical validation pkg uninstall + pkg command regression   [completato]
J3  lifecycle version/current: naming + public contract          [corrente]
K   dependency/facility/state avanzato quando richiesto          [successivo]
```

---

## Confine J3

`version/current` resta un **label di pianificazione**, non una API o una CLI già definita.

Il lavoro J3 deve quindi iniziare dalla progettazione, non dall'implementazione. Prima di modificare `rumiai-os` occorre fissare esplicitamente:

```text
responsabilità osservabili richieste
naming pubblico
forme CLI eventualmente necessarie
relazione con pkg_default e con i selector current già esistenti
semantica per generic e target-specific
output e status pubblici
confine local-only oppure eventuali dipendenze catalog/upstream
```

Non devono essere introdotti per inferenza sottocomandi quali:

```text
pkg version
pkg versions
pkg current
pkg default
```

né equivalenti, finché una decisione Accepted o una correzione esplicita dell'utente non ne abbia fissato nome e contratto.

Le primitive esistenti `pkg_default`, i selector current e il modello availability/current/default restano vincoli da riusare; J3 non deve duplicarne la responsabilità.

---

## Invarianti correnti

```text
PKG-NOW-60  rumiai-os@164fe1b + rumiai-tests@71963b0 è la coppia validata per rumiai-os/pkg
PKG-NOW-61  Ubuntu ARM64 e macOS ARM64 hanno entrambi PASS 3/3 sul gruppo rumiai-os/pkg
PKG-NOW-62  il gate J2 di pkg uninstall è chiuso
PKG-NOW-63  pkg uninstall resta local-only e conserva il contratto Accepted esistente
PKG-NOW-64  install e uninstall condividono i validator package autorevoli di pkg-integration
PKG-NOW-65  le evidence 4aa3dbe restano storiche e revision-specific
PKG-NOW-66  J3 version/current è il confine corrente di progettazione
PKG-NOW-67  version/current non fissa alcun nome CLI pubblico
PKG-NOW-68  le responsabilità esistenti di pkg_default/current selector devono essere riusate, non duplicate
PKG-NOW-69  Git resta forward-only
```
