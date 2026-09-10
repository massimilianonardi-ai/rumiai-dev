# Decisione — Piano package corrente dopo implementazione `pkg uninstall`

Date: 2026-09-10  
Status: **Accepted**

## Scopo e supersession

Questo documento è il checkpoint operativo corrente della sequenza package e supersede, esclusivamente per stato di avanzamento e physical-validation status, il checkpoint:

```text
decisions/rumiai-os/2026-09-10-package-current-plan-after-dbeaver-normal-launch-validation.md
```

I contratti architetturali e tecnici restano nei rispettivi documenti autorevoli.

---

## Baseline precedente già validata

Restano revision-specific e immutate le validation già chiuse per:

```text
rumiai-os@79cb5964428ca68c06c2f4eac98ac7350ae9561f
pkg-catalog@514cb620075188ec9ad9090f6bd008fcec85913f
```

incluse:

```text
full rumiai-os validation
pkg install dbeaver live end-to-end
pkg_default dbeaver live
normal launch dbeaver con GUI realmente osservata su Ubuntu ARM64 e macOS ARM64
```

Tali evidence non vengono estese alla nuova revisione prodotto.

---

## `pkg uninstall`: contratto consolidato

Il lifecycle locale di uninstall è ora fissato da:

```text
decisions/rumiai-os/2026-09-10-package-uninstall-contract.md
```

In sintesi:

```text
pkg uninstall <package> [<package> ...]
```

resta local-only e usa soltanto il package store locale.

Le quattro forme operand restano:

```text
<pkg>
<pkg>@<version>
<pkg>!<osarch>
<pkg>@<version>!<osarch>
```

Semantica locale principale:

```text
!<osarch> esplicito
    -> esclusivamente quella classe target-specific, senza fallback generic

!<osarch> omesso
    -> classe target-specific del corrente m_OSARCH se presente
    -> altrimenti classe generic
    -> corruption della classe prioritaria è failure, non fallback

@<version> esplicito
    -> exact concrete version locale

@<version> omesso
    -> current se presente
    -> altrimenti unica availability se esattamente una
    -> più availability senza current = ambiguity/failure
```

Se la concrete version selezionata è current:

```text
pkg_default <pkg> '' [<osarch>]
-> pkg_deintegrate <pkg> <version> [<osarch>]
```

Non viene scelto automaticamente un nuovo default e lo state esterno alla concrete version non viene eliminato.

---

## Implementazione prodotto corrente

La nuova revisione prodotto è:

```text
rumiai-os@339af91035a6fb2a5608b952e2af41f7bd4cd333
commit: Implement local package uninstall
parent: 79cb5964428ca68c06c2f4eac98ac7350ae9561f
```

Il diff prodotto è limitato a:

```text
bin/sys/pkg
lib/sh/pkg-uninstall.lib.sh
```

`bin/sys/pkg` continua a essere `100755` e carica ora la libreria specifica soltanto nel branch del sottocomando:

```text
install   -> pkg-install.lib.sh
uninstall -> pkg-uninstall.lib.sh
```

La nuova:

```text
lib/sh/pkg-uninstall.lib.sh
```

è `100644`, non contiene shebang e source soltanto:

```text
pkg-integration.lib.sh
```

L'orchestrazione pubblica interna è:

```text
pkg_uninstall <package> [<package> ...]
```

La libreria non consulta catalogo/upstream e riusa le primitive già fissate:

```text
pkg_default
pkg_deintegrate
```

Non sono stati introdotti SemVer, resolver, inventory, generations, purge o transaction framework.

---

## Test permanente corrente

Il test permanente è:

```text
rumiai-tests/tests/rumiai-os/pkg/uninstall.test
```

introdotto da:

```text
rumiai-tests@cedc24ae2a6007588f3ea92867703173481b7616
commit: Test local package uninstall lifecycle
```

Il file è `100755`.

Protegge almeno:

```text
quattro forme operand
status invalid invocation/operand
prevalidation completa prima della prima mutazione
explicit target senza generic fallback
precedenza della classe target-specific del m_OSARCH
corruption della classe prioritaria senza fallback
exact version
current selection
single availability senza current
ambiguity con più availability senza current
rimozione current tramite default removal + deintegration
assenza di auto-selection residua
preservazione delle altre versioni
preservazione dello state esterno
stop-on-first-failure senza rollback globale
```

Sono stati eseguiti development check locali proporzionati su sintassi POSIX shell e fixture controllata; non costituiscono physical validation.

---

## Physical validation pendente

La configuration corrente di validation è stata aggiornata in:

```text
rumiai-tests@089d85e2549a7f63e3cd479151c6e8f8d1333e53
commit: Validate package uninstall lifecycle
```

con:

```text
rumiai-os-commit  339af91035a6fb2a5608b952e2af41f7bd4cd333
selection         rumiai-os/pkg
```

La selezione `rumiai-os/pkg` è intenzionale: oltre al nuovo `uninstall.test`, riesegue i test permanenti del command/layer `pkg` già presenti, incluso `install.test`, così il piccolo riallineamento del caricamento di `pkg-install.lib.sh` nel command entry viene coperto senza richiedere in questa fase l'intera suite `rumiai-os`.

La coppia da validare sui reference host è quindi:

```text
rumiai-os@339af91035a6fb2a5608b952e2af41f7bd4cd333
rumiai-tests@089d85e2549a7f63e3cd479151c6e8f8d1333e53
selection: rumiai-os/pkg
```

La revisione `339af910...` resta **pending physical validation** finché Ubuntu ARM64 e macOS ARM64 non producono evidence revision-specific positiva.

---

## Confine restante della fase lifecycle J

La parte `uninstall` della fase J è ora:

```text
contratto       completato
permanent test  completato
implementazione completata
validation      pendente
```

Restano invece aperte le responsabilità indicate nel label di piano come:

```text
version/current
```

Il label non definisce da solo nuovi sottocomandi pubblici.

Fino a quando una decisione Accepted o una correzione esplicita dell'utente non fissa naming e CLI, non devono essere introdotti per inferenza nomi quali:

```text
pkg version
pkg versions
pkg current
pkg default
```

Le semantiche già fissate restano disponibili internamente tramite il selector current e `pkg_default`, ma una nuova superficie pubblica richiede prima un contratto esplicito.

---

## Sequenza operativa corrente

```text
A  gate completo rumiai-os per revisione DMG a253162                  [completato]
B  gate live pkg install dbeaver Ubuntu ARM64                         [completato]
C  gate live pkg install dbeaver macOS ARM64                          [completato]
D  localizzazione performance macOS JSON                              [completato]
E  PoC correzione algoritmica JSON su macOS                           [completato]
F  promozione minima JSON + boundary test permanenti                  [completato]
G  validation revision-specific rumiai-os@79cb596                     [completato]
H  riesecuzione live DBeaver sulla nuova revisione JSON               [completato]
I  validazione separata default + normal launch                       [completato]
J1 contratto/test/implementazione pkg uninstall                        [completato]
J2 physical validation pkg uninstall + pkg command regression         [corrente]
J3 lifecycle version/current: naming + contratto pubblico              [successivo, naming non ancora fissato]
K  dependency/facility/state avanzato soltanto quando richiesto       [successivo]
```

---

## Invarianti correnti

```text
PKG-NOW-01  pkg install produce availability e non seleziona il default
PKG-NOW-02  pkg_default resta l'unico layer corrente per current e binding pubblici
PKG-NOW-03  normal launch di package già selezionato non passa da pkg e non consulta pkg-catalog
PKG-NOW-11  la precedente rumiai-os@79cb596 resta validata solo per le evidence già acquisite
PKG-NOW-35  pkg uninstall è CLI canonica local-only
PKG-NOW-41  il contratto uninstall corrente è 2026-09-10-package-uninstall-contract.md
PKG-NOW-42  la revisione prodotto uninstall è rumiai-os@339af910
PKG-NOW-43  il permanent test uninstall è stato introdotto da rumiai-tests@cedc24a ed è 100755
PKG-NOW-44  la validation configurata usa rumiai-tests@089d85e + rumiai-os@339af910 + selection rumiai-os/pkg
PKG-NOW-45  rumiai-os@339af910 non è ancora fisicamente validata
PKG-NOW-46  uninstall current usa pkg_default remove prima di pkg_deintegrate e non auto-seleziona un residuo
PKG-NOW-47  uninstall non è purge e non elimina automaticamente lo state esterno
PKG-NOW-48  explicit target non ha generic fallback; target corrente ha precedenza locale quando target è omesso
PKG-NOW-49  più availability senza current sono ambigue e non vengono ordinate implicitamente
PKG-NOW-50  version/current restano un confine di design: nessun nuovo nome pubblico viene inferito dal label del piano
PKG-NOW-51  Git resta forward-only e la physical validation deve essere revision-specific
```
