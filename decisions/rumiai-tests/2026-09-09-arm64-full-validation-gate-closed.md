# Decisione — Chiusura full validation ARM64 della revisione corrente

Date: 2026-09-09  
Status: **Accepted; physical validation complete on ARM64 reference hosts**

## Contesto

Le decisioni correnti hanno portato alla coppia candidata:

```text
rumiai-os@130944920b5dab5f9d25bd3515667f5cdff36a48
rumiai-tests@68e12c37dae9789bc44d966578e76e9530d7db95
selection=rumiai-os
```

La configurazione `rumiai-validate.conf` della suite candidata punta esattamente a questa revisione prodotto e mantiene `selection=rumiai-os`.

Questa coppia incorpora, oltre ai layer package già consolidati, anche il riallineamento del boundary runtime state Zsh e i riallineamenti dei test pathname canonicali emersi durante la validation macOS.

La stessa identica coppia è stata ora eseguita con successo su entrambi i reference host ARM64 correnti.

## 1. Ubuntu ARM64 — PASS

Sessione pubblicata:

```text
validation/20260909T214917+0200-36560
```

Evidence commit:

```text
3e80b9279f5df7b125afc23c294eddcbf9df260b
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

I due SKIP sono esclusivamente:

```text
rumiai-os/shell/zsh-alias-preservation.test
rumiai-os/shell/zsh-zdotdir-preservation.test
```

per indisponibilità di Zsh sull'host Ubuntu corrente.

Il test indipendente:

```text
rumiai-os/shell/zsh-runtime-state-boundary.test
```

è invece PASS anche su Ubuntu mediante la propria fixture deterministica.

## 2. macOS ARM64 — PASS

Sessione pubblicata:

```text
validation/20260909T214939+0200-38492
```

Evidence commit:

```text
b45aa723b3fb2add43c3fb25b55affd5f4baa04b
```

Host:

```text
Darwin 26.6.2
arm64
```

Risultato:

```text
PASS   63
FAIL   0
SKIP   0
ERROR  0
TOTAL  63
runner-exit-status 0
```

Tutti i test applicabili della selection `rumiai-os`, inclusi i test Zsh reali e il boundary runtime state, sono PASS.

## 3. Proprietà coperte dal gate

La physical validation revision-specific copre la revisione `rumiai-os@130944920b5dab5f9d25bd3515667f5cdff36a48` tramite l'intera selection:

```text
rumiai-os
```

Fra le proprietà esercitate con PASS rientrano quindi anche:

```text
bootstrap e command dispatch
semantic roots e canonicalizzazione pathname
shell startup e selection
boundary runtime state Zsh conf/home
digest
extract
http-fetch
json
lang
log
osarch
pkg-analyze
pkg_download
pkg_extract
pkg-repository-github
read-key
```

In particolare risultano fisicamente validati sui reference host ARM64 correnti i layer package implementati prima di `pkg_integrate`:

```text
digest
extract
pkg_download
pkg_extract
pkg-analyze
pkg-repository-github
```

## 4. Cosa questa validation non valida

Il gate non deve essere esteso oltre la revisione e le proprietà realmente esercitate.

Restano fuori da questa physical validation:

```text
pkg_integrate/pkg_deintegrate, non ancora implementati
orchestrazione reale pkg install, non ancora implementata
materializzazione/installazione reale della package definition DBeaver tramite pkg_integrate
launch DBeaver come package installato tramite il futuro launcher/integration path
baseline Windows/MSYS2, la cui physical validation resta separata
```

Le precedenti sessioni PASS/FAIL restano evidence immutabili delle rispettive revisioni e non vengono reinterpretate.

## 5. Relazione con le decisioni precedenti

Questa decisione supersede esclusivamente gli stati di gate/physical-validation ancora marcati come pending nelle decisioni:

```text
decisions/rumiai-os/2026-09-09-zsh-proxy-runtime-state-boundary.md
decisions/rumiai-tests/2026-09-09-macos-arm64-canonical-path-test-realignment.md
decisions/rumiai-tests/2026-09-09-macos-arm64-full-validation-realignment.md
decisions/rumiai-os/2026-09-09-package-implementation-plan-and-catalog-refresh-boundary.md
```

Non modifica i rispettivi contratti tecnici, invarianti, cause analysis o evidence storiche.

Il boundary Zsh implementato in `rumiai-os@130944920b5dab5f9d25bd3515667f5cdff36a48` è quindi ora fisicamente validato sui due reference host ARM64.

I riallineamenti pathname della suite `rumiai-tests@68e12c37dae9789bc44d966578e76e9530d7db95` sono anch'essi fisicamente validati sui due host.

## 6. Prossimo passo package

La chiusura del gate non cambia la sequenza package già fissata.

Il passo successivo resta:

```text
contratto + implementazione pkg_integrate/pkg_deintegrate
```

La futura implementazione dovrà continuare a rispettare il confine già fissato:

```text
pkg_extract
    -> useful root già normalizzata nella destination scelta dal caller
    -> pkg_integrate
```

`pkg_integrate` non deve ridiscoprire o correggere wrapper upstream.

## 7. Invarianti

```text
ARM64-GATE-01  coppia validata = rumiai-os@130944920b5dab5f9d25bd3515667f5cdff36a48 + rumiai-tests@68e12c37dae9789bc44d966578e76e9530d7db95
ARM64-GATE-02  selection validata = rumiai-os
ARM64-GATE-03  Ubuntu ARM64 PASS = validation/20260909T214917+0200-36560, evidence 3e80b9279f5df7b125afc23c294eddcbf9df260b
ARM64-GATE-04  macOS ARM64 PASS = validation/20260909T214939+0200-38492, evidence b45aa723b3fb2add43c3fb25b55affd5f4baa04b
ARM64-GATE-05  il gate cross-platform ARM64 della revisione corrente è chiuso
ARM64-GATE-06  gli SKIP Ubuntu dei due test Zsh reali non vengono reinterpretati; il test Zsh runtime-state-boundary è PASS
ARM64-GATE-07  la validation non promuove proprietà non esercitate, inclusi pkg_integrate/pkg_deintegrate, pkg install reale e Windows/MSYS2
ARM64-GATE-08  le evidence storiche precedenti restano immutabili e revision-specific
ARM64-GATE-09  il passo package successivo resta contratto + implementazione pkg_integrate/pkg_deintegrate
```