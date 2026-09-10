# Decisione — Piano package corrente dopo implementazione `pkg versions` / `pkg default`

Date: 2026-09-10  
Status: **Accepted**

## Scopo e supersession

Questo documento supersede, esclusivamente per stato operativo e sequencing corrente:

```text
decisions/rumiai-os/2026-09-10-package-current-plan-after-uninstall-validation.md
```

Il contratto pubblico J3 è definito da:

```text
decisions/rumiai-os/2026-09-10-package-versions-and-default-cli.md
```

Le decisioni precedenti su concrete identity, selector current, availability/default, `pkg_default`, install e uninstall restano normative.

---

## Stato acquisito

Resta fisicamente validata la baseline precedente:

```text
rumiai-os@164fe1b058710a6871266aab7ca9dc4495cbe4bc
rumiai-tests@71963b08476ff5c4d5557ed593cd6c4c8414b63c
selection: rumiai-os/pkg
```

con PASS sui reference Ubuntu ARM64 e macOS ARM64 per:

```text
catalog-snapshot.test
install.test
uninstall.test
```

Tale evidence non viene attribuita alla nuova revisione J3.

---

## J3 — contratto

Sono ora nomi pubblici Accepted:

```text
pkg versions
pkg default
```

Non sono introdotti:

```text
pkg version
pkg current
pkg use
```

`pkg versions` osserva availability locale; `pkg default` osserva/modifica il default persistente; `current` resta selector interno/concezionale.

Entrambi i sottocomandi sono local-only.

---

## Implementazione candidata

La revisione semantica J3 è stata introdotta in:

```text
rumiai-os@a47e34c4ce735697b197d4ed6c3e357fbfd95067
commit: Add local package versions and default lifecycle
parent: 164fe1b058710a6871266aab7ca9dc4495cbe4bc
```

Il diff rispetto alla baseline precedente è limitato a:

```text
bin/sys/pkg
lib/sh/pkg-local.lib.sh
lib/sh/pkg-versions.lib.sh
lib/sh/pkg-default.lib.sh
lib/sh/pkg-uninstall.lib.sh
```

Successivamente la regola canonica sull'option delimiter è stata riallineata in:

```text
rumiai-os@59fc8d5945dd4ec8acc99e4c41628e5cfed37a13
commit: Use required option delimiter in local package scan
parent: a47e34c4ce735697b197d4ed6c3e357fbfd95067
```

La modifica successiva è limitata a una sola invocazione in:

```text
lib/sh/pkg-local.lib.sh
```

con passaggio da:

```text
command -p -- readlink "$pkg_local_selector"
```

a:

```text
command -p -- readlink -- "$pkg_local_selector"
```

Non modifica il contratto lifecycle J3; riallinea l'implementazione alla regola generale che rende obbligatorio `--` quando il tool lo supporta come terminatore delle option e riceve operandi dati.

La revisione prodotto candidata corrente per J3c è quindi:

```text
rumiai-os@59fc8d5945dd4ec8acc99e4c41628e5cfed37a13
```

`pkg-integration.lib.sh` resta byte-per-byte invariato rispetto alla baseline J3; il suo blob continua a essere:

```text
96a456ffc943641b429014c1f31a0bcb809122ad
```

### Responsabilità interne

`pkg-local.lib.sh` contiene esclusivamente la responsabilità condivisa resa reale da tre consumer:

```text
parse della package identity locale
scan/validazione della classe generic o target-specific
selezione della classe locale con precedenza current-$m_OSARCH -> generic
```

Non introduce un secondo store, un indice o metadata aggiuntivi.

`pkg-uninstall.lib.sh` riusa il nuovo boundary locale invece di conservare copie di parse/scan. La semantica pubblica `pkg uninstall` resta invariata.

`pkg-versions.lib.sh` espone `pkg_versions` e produce concrete identity complete, in ordine bytewise deterministico con locale `C`, senza marker current/default.

`pkg-default.lib.sh` espone l'orchestrazione CLI interna `pkg_default_command`; ogni mutazione di selector/binding delega alla primitive esistente `pkg_default` e non ne duplica la logica.

### Mode

```text
bin/sys/pkg                    100755
lib/sh/pkg-local.lib.sh        100644
lib/sh/pkg-versions.lib.sh     100644
lib/sh/pkg-default.lib.sh      100644
lib/sh/pkg-uninstall.lib.sh    100644
```

Le librerie non hanno shebang.

---

## Permanent test

La suite J3 è stata inizialmente estesa in:

```text
rumiai-tests@5c0c6bf7448a9aa1c4d92aa78717deb4817f6210
commit: Add package versions and default tests
```

con:

```text
tests/rumiai-os/pkg/versions.test   100755
tests/rumiai-os/pkg/default.test    100755
```

I test proteggono tra l'altro:

```text
output concrete identity complete
ordine C deterministico senza SemVer
class precedence e no-fallback dopo corruption
target esplicito isolato
query/set/remove default
binding e selector reali prodotti da pkg_default
query senza default = status 1 + stdout vuoto
-u idempotente
-u su classe totalmente assente = status 0
-- option terminator
status 0/1/2
nessun accesso catalog/cache
```

La regressione `pkg uninstall` resta nel medesimo gruppo e protegge il refactoring della scansione comune.

### Allineamento dei test alla regola `--`

Prima della physical validation J3c è stata completata la propagazione della regola canonica sull'option delimiter nei due nuovi test J3:

```text
rumiai-tests@3db5040885a5471a6ba340a1dc5ebf6e1fd7162d
commit: Apply required option delimiters to versions test

rumiai-tests@a3c90a2e09fa91727ae16cd0b1fdc931c9b86f5f
commit: Complete option delimiter alignment in versions test

rumiai-tests@a48d8d31bc0ebc629bbf8e2bf8914e1021afe689
commit: Align default test option delimiters
```

Le modifiche sono meccaniche e limitate all'inserimento di `--` nelle invocazioni dei tool già verificati come appartenenti alla regola applicabile; non cambiano gli scenari, gli expected result o il contratto dei test.

Il riallineamento è intenzionalmente limitato ai nuovi test J3 coinvolti in questa fase. Non costituisce una riformattazione opportunistica dei test storici del package subsystem.

---

## Development checks

Prima della prima configurazione di physical validation erano stati eseguiti sul candidato semantico J3 i seguenti controlli:

```text
POSIX /bin/sh syntax check delle librerie, command entry e nuovi test   PASS
harness locale versions/default/uninstall                              PASS
versions.test contro fixture Git isolato                               PASS
default.test contro fixture Git isolato                                PASS
```

Il consistency scan aveva inoltre verificato:

```text
assenza della vecchia _pkg_uninstall_class_scan
assenza di pkg current nel prodotto
nessuna dipendenza pkg-catalog nelle nuove operazioni locali
pkg-integration.lib.sh invariato
mode corretti
Git forward-only
```

Dopo tali check sono intervenute esclusivamente le correzioni meccaniche di option delimiter sopra registrate e il nuovo pin di validation. I diff di tali correzioni sono stati riletti e non introducono modifiche alla semantica J3.

I development check precedenti non vengono reinterpretati come physical validation della revisione corrente. La revisione corrente resta soggetta al gate J3c revision-specific sui reference host.

---

## Physical validation corrente

La configurazione corrente è:

```text
rumiai-tests@e2dd1ac08b9e1167a7a20db12a01a4869b797376
rumiai-os-commit  59fc8d5945dd4ec8acc99e4c41628e5cfed37a13
selection         rumiai-os/pkg
```

Il commit `e2dd1ac...` pinna esplicitamente la revisione prodotto corrente dopo il riallineamento dei due test J3.

La selezione contiene:

```text
catalog-snapshot.test
install.test
uninstall.test
versions.test
default.test
```

È il gate proporzionato perché la modifica riguarda il command/lifecycle package locale e `pkg-integration.lib.sh` non è cambiato.

La revisione:

```text
rumiai-os@59fc8d5945dd4ec8acc99e4c41628e5cfed37a13
```

resta **pending physical validation** finché Ubuntu ARM64 e macOS ARM64 non producono evidence revision-specific positiva con:

```text
rumiai-tests@e2dd1ac08b9e1167a7a20db12a01a4869b797376
selection: rumiai-os/pkg
```

Le evidence J2 precedenti restano storiche e immutabili e non vengono attribuite alla revisione J3 corrente.

---

## Sequenza operativa corrente

```text
J1  pkg uninstall: contratto/test/implementazione                    [completato]
J2  physical validation pkg uninstall                                [completato]
J3a pkg versions/default: naming e contratto pubblico                [completato]
J3b permanent test + implementazione                                 [completato]
J3c physical validation versions/default + regressione pkg           [corrente]
K   dependency/facility/state avanzato soltanto quando richiesto     [successivo]
```

---

## Invarianti correnti

```text
PKG-NOW-70  pkg versions osserva availability locale e produce concrete identity complete
PKG-NOW-71  pkg default osserva/modifica il default persistente
PKG-NOW-72  current resta selector interno/concezionale e non è un sottocomando pubblico
PKG-NOW-73  pkg_default resta l'unica primitive che muta selector current e binding pubblici
PKG-NOW-74  pkg-local centralizza soltanto parse/scan/class selection condivisa
PKG-NOW-75  uninstall riusa pkg-local senza modifica del proprio contratto pubblico
PKG-NOW-76  versions/default sono local-only e non consultano catalog/upstream
PKG-NOW-77  target esplicito non fa fallback; target omesso usa current-$m_OSARCH -> generic
PKG-NOW-78  corruption della classe prioritaria produce failure senza fallback
PKG-NOW-79  nessun SemVer/latest viene introdotto nelle operazioni locali
PKG-NOW-80  candidate product = rumiai-os@59fc8d5
PKG-NOW-81  validation target = rumiai-tests@e2dd1ac + selection rumiai-os/pkg
PKG-NOW-82  rumiai-os@59fc8d5 non è ancora fisicamente validata per J3
PKG-NOW-83  Git resta forward-only
PKG-NOW-84  rumiai-os@a47e34c resta la revisione semantica J3; 59fc8d5 aggiunge soltanto il delimiter richiesto a readlink
PKG-NOW-85  i due nuovi test J3 sono riallineati alla regola -- prima della physical validation
```
