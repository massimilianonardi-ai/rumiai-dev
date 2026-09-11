# Decisione — Piano package corrente dopo l'implementazione facility provider K1

Date: 2026-09-11  
Status: **Accepted**

## Scopo e supersession

Questo documento supersede, esclusivamente per stato operativo e sequencing corrente:

```text
decisions/rumiai-os/2026-09-11-package-current-plan-after-versions-default-validation.md
```

I contratti e le decisioni tecniche precedenti restano autorevoli nei rispettivi scope.

La serializzazione facility/dependency, la compatibility numerica e la policy di resolution approvate sono fissate in:

```text
decisions/rumiai-os/2026-09-11-package-facility-dependency-serialization-and-resolution-policy.md
```

---

## Stato acquisito

La fase K non parte più dal solo planning generale.

Sono ora consolidati:

```text
facility name grammar
facility serialization
dependency serialization
compatibility grammar canonica
compatibility numeric comparison
massima compatibility compatibile come compatibility selezionata
ambiguity/failure quando più provider eleggibili offrono la compatibility selezionata
```

La prima tranche implementativa K1 è stata realizzata nel prodotto come lifecycle provider-side di `facility`.

Revisioni correnti della tranche:

```text
rumiai-os@bd167bbaa509dbbcb8b803152e22db3895c01a5d
rumiai-tests@4c018f7c577ba6c7d9f68f94ee55366334f15742
selection: rumiai-os/pkg
```

La suite di validation è già pinning alla revisione prodotto K1 esatta.

---

## K1 implementato

K1 implementa esclusivamente:

```text
validazione canonica del file facility della range definition
materializzazione byte-identica di <package-version>/facility
provider index derivato sotto $m_DATA_DIR/sys/pkg/providers
marker provider regolari vuoti nominati con la concrete package identity
supporto a provider generic e target-specific senza cambiare la concrete identity
rimozione marker durante pkg_deintegrate
rimozione della directory <compatibility>/ quando perde l'ultimo marker
```

Il lifecycle riusa i punti canonici esistenti:

```text
pkg_integrate
pkg_deintegrate
```

Non è stato introdotto un secondo inventory/lifecycle.

La nuova libreria interna è:

```text
lib/sh/pkg-facility.lib.sh
```

ed è una normale libreria `lib/sh/*.lib.sh`: regular file non executable e senza shebang.

`pkg-integration.lib.sh` la usa soltanto per validazione/materializzazione facility e lifecycle del provider index.

---

## Confini K1 preservati

K1 non introduce:

```text
nuovi comandi pubblici pkg
dependency resolution
binding/
provider preference/ranking
selector current/default come resolver
SemVer o confronto della versione upstream
resolution durante il normale launch
State Instance avanzato
```

Una range definition contenente `dependency` resta intenzionalmente non supportata dal prodotto K1.

Questo evita che venga materializzato un consumer con requirement astratto ma senza resolved binding.

I package che non dichiarano `facility` mantengono il lifecycle precedente e non acquisiscono una dipendenza operativa dal provider index.

---

## Permanent test K1

È stato aggiunto:

```text
tests/rumiai-os/pkg/facility.test
```

Il test protegge almeno:

```text
materializzazione invariata del file facility
marker generic e target-specific
marker regular file vuoto e non symlink
coesistenza di più provider della stessa facility/compatibility
rimozione della compatibility directory soltanto dopo l'ultimo provider
rifiuto di facility name non canonico
rifiuto di compatibility con leading zero o trailing .0 canonico vietato
rifiuto di file non ordinati, duplicati, whitespace non canonico, LF finale mancante, file vuoto o executable
rifiuto di dependency durante K1
fallimento sicuro della deintegration davanti a provider marker corrotto
assenza di provider-index dependency per package senza facility
mode/shebang della nuova libreria
```

Il test è stato eseguito in development harness locale contro i blob esatti poi pubblicati ed è passato.

Questo risultato non sostituisce la physical validation sui reference host.

---

## Sequenza operativa corrente

```text
J1   pkg uninstall: contract/test/implementation                  [completed]
J2   physical validation pkg uninstall                            [completed]
J3a  pkg versions/default naming + public contract                [completed]
J3b  permanent test + implementation                              [completed]
J3c  physical validation versions/default + pkg regression       [completed]
K0   facility/dependency serialization + resolution policy        [completed]
K1a  facility provider lifecycle implementation + permanent test  [completed]
K1b  physical validation facility + pkg regression                [current: pending]
K2   dependency resolution + resolved binding                     [not started]
```

---

## Physical validation richiesta per K1

Poiché `rumiai-os@bd167b...` modifica semanticamente il package lifecycle, K1 non è chiuso finché non viene eseguita la validation fisica corrente sui reference host Ubuntu ARM64 e macOS ARM64.

La coppia da validare è esattamente:

```text
rumiai-os@bd167bbaa509dbbcb8b803152e22db3895c01a5d
rumiai-tests@4c018f7c577ba6c7d9f68f94ee55366334f15742
selection: rumiai-os/pkg
```

La suite deve comprendere i test package correnti incluso il nuovo `facility.test` e la regressione preesistente.

Nessuna evidence precedente viene reinterpretata come validation della nuova revisione.

---

## Confine K2

K2 resta separato da K1 e non è ancora autorizzato implicitamente da questo checkpoint.

Il contratto già Accepted per K2 comprende:

```text
validazione/materializzazione dependency
provider discovery attraverso provider index
compatibility matching numerico
scelta della massima compatibility compatibile
fallimento su più provider eleggibili alla compatibility selezionata
materializzazione binding/<facility>
target eligibility già fissata
normale launch senza resolution
```

Prima di completare il lifecycle K2 resta necessario fissare esplicitamente, davanti al requisito concreto, almeno:

```text
semantica di rimozione di un provider già referenziato da binding esistenti
atomicità/recovery delle mutazioni dependency/binding quando materialmente richieste
```

Questi punti non vengono risolti per inferenza durante K1.

---

## Invarianti correnti

```text
PKG-NOW-100  K0 serialization/compatibility/provider-selection policy è Accepted
PKG-NOW-101  K1 product revision = rumiai-os@bd167bbaa509dbbcb8b803152e22db3895c01a5d
PKG-NOW-102  K1 validation suite revision = rumiai-tests@4c018f7c577ba6c7d9f68f94ee55366334f15742
PKG-NOW-103  K1 validation selection resta rumiai-os/pkg
PKG-NOW-104  K1 riusa pkg_integrate/pkg_deintegrate e non introduce un lifecycle parallelo
PKG-NOW-105  K1 implementa facility/provider-index ma non dependency/binding
PKG-NOW-106  package senza facility non dipendono dal provider index
PKG-NOW-107  K1 non è fisicamente validato finché K1b non produce evidence sui due reference host
PKG-NOW-108  evidence J1-J3 restano storiche, immutabili e revision-specific
PKG-NOW-109  K2 non risolve implicitamente provider-removal/reference o transaction semantics ancora aperte
PKG-NOW-110  normale launch resta privo di resolution e pkg invocation
PKG-NOW-111  State Instance avanzato resta fuori da questa tranche
PKG-NOW-112  Git resta forward-only
```
