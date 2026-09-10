# Decisione — Correzione locale-independent dopo il FAIL macOS di `pkg uninstall`

Date: 2026-09-10  
Status: **Accepted**

## Contesto

La revisione candidata del lifecycle package era:

```text
rumiai-os    4aa3dbe1d7df6bd20a1f84c284a739bfcc197501
rumiai-tests 8e1e36740fdb1bc9a81c3546c1c34cb6ffc668a7
selection    rumiai-os/pkg
```

La physical validation è stata eseguita sui due reference host ARM64.

## Evidence immutabili della revisione `4aa3dbe...`

Ubuntu ARM64:

```text
validation/20260910T210033+0200-108576
rumiai-os/pkg/catalog-snapshot.test PASS
rumiai-os/pkg/install.test          PASS
rumiai-os/pkg/uninstall.test        PASS
```

macOS ARM64:

```text
validation/20260910T210052+0200-14630
rumiai-os/pkg/catalog-snapshot.test PASS
rumiai-os/pkg/install.test          PASS
rumiai-os/pkg/uninstall.test        FAIL
```

Il log macOS registra esattamente:

```text
rumiai-os/pkg/uninstall.test: expected status 2, got 1 from pkg_uninstall Bad
```

Le due evidence restano immutabili e revision-specific. Il PASS Ubuntu non rende globalmente validata la revisione `4aa3dbe...`; il candidate resta non validato perché il reference host macOS ha prodotto un FAIL.

## Diagnosi

`pkg-uninstall.lib.sh` riusava correttamente il validator condiviso `_pkg_integration_name_valid`, che però validava il nome package mediante range di bracket expression:

```sh
[a-z]
```

I range delle bracket expression dipendono dalle regole di locale/collation e non sono una base portabile per imporre un alfabeto ASCII esatto. Sul reference host macOS il valore `Bad` superava quindi la validazione lessicale e raggiungeva la risoluzione operativa, producendo status `1` invece dello status lessicale `2`.

La stessa semantica lessicale era duplicata anche in `pkg-install.lib.sh`, nonostante tale libreria caricasse già `pkg-integration.lib.sh`.

## Invarianti applicabili

La correzione mantiene invariati:

- grammatica operand `<pkg>`, `<pkg>@<version>`, `<pkg>!<osarch>`, `<pkg>@<version>!<osarch>`;
- package name ASCII lowercase secondo il contratto esistente;
- version vocabulary già accettato;
- status `2` per invocation/operand lessicalmente invalido;
- prevalidazione di `pkg install` prima di qualsiasi catalog snapshot;
- assenza di accesso remoto in `pkg uninstall`;
- distinzione availability/current/default;
- semantica di `pkg_default` e `pkg_deintegrate`;
- nessun SemVer, generation, inventory o resolver nuovo;
- Git forward-only.

Non viene introdotta alcuna nuova primitive, alias pubblico o namespace.

## Correzione prodotto

### `rumiai-os@4077bfab7602577644f384a1112c529ce74ace30`

`lib/sh/pkg-integration.lib.sh` sostituisce i range ASCII dei validator condivisi con insiemi di caratteri letterali:

```text
name:
  ABC... non ammesso
  abcdefghijklmnopqrstuvwxyz0123456789
  successivi anche . _ -

version:
  ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789
  successivi anche . _ + ~ -
```

Questo rende la validazione indipendente dalla collation locale senza imporre globalmente `LC_ALL=C` al comando.

### `rumiai-os@164fe1b058710a6871266aab7ca9dc4495cbe4bc`

`lib/sh/pkg-install.lib.sh` elimina i tre validator privati duplicati per package name, version e osarch e usa direttamente:

```text
_pkg_integration_name_valid
_pkg_integration_version_valid
_pkg_integration_osarch_valid
```

La modifica non altera snapshot, resolver, download, extract o integration flow. `install` e `uninstall` condividono ora la stessa semantica lessicale autorevole.

La revisione prodotto candidata corrente è quindi:

```text
164fe1b058710a6871266aab7ca9dc4495cbe4bc
```

## Regressione permanente

`rumiai-tests@97b5e5e9caee4959f70c4034884adb79cd65b193` estende `tests/rumiai-os/pkg/install.test` con il caso:

```text
pkg_install Bad
    -> status 2
    -> nessun catalog snapshot
```

`tests/rumiai-os/pkg/uninstall.test` conteneva già il caso che ha rilevato il problema su macOS:

```text
pkg_uninstall Bad
    -> status 2
```

La configuration di validation è poi stata aggiornata in `rumiai-tests@71963b08476ff5c4d5557ed593cd6c4c8414b63c` a:

```text
rumiai-os-commit  164fe1b058710a6871266aab7ca9dc4495cbe4bc
selection         rumiai-os/pkg
```

## Stato

```text
4aa3dbe...   physical validation: Linux PASS, macOS FAIL
164fe1b...   corrected candidate: pending physical validation
71963b0...   current validation configuration/tests revision
```

Il gate J2 resta aperto finché `164fe1b...` non produce evidence PASS revision-specific sia su Ubuntu ARM64 sia su macOS ARM64.

Solo dopo tale doppio PASS si può chiudere la physical validation di `pkg uninstall` e riprendere il passo lifecycle successivo senza inventare una nuova superficie pubblica per `version/current`.
