# Decisione — Piano package corrente dopo la physical validation K1

Date: 2026-09-11  
Status: **Accepted**

## Scopo e supersession

Questo documento supersede, esclusivamente per stato operativo e sequencing corrente:

```text
decisions/rumiai-os/2026-09-11-package-current-plan-after-k1-macos-validation-error.md
```

I contratti tecnici precedenti e le evidence storiche restano autorevoli nei rispettivi scope.

---

## K1b chiuso

La physical validation K1 è stata rieseguita dopo la correzione test-only di portabilità macOS sulla coppia:

```text
rumiai-os@bd167bbaa509dbbcb8b803152e22db3895c01a5d
rumiai-tests@fa2583d85121001d642f1f733f037c3f117ca4e5
selection: rumiai-os/pkg
```

Sono state pubblicate le evidence:

```text
Ubuntu ARM64  validation/20260911T093239+0200-174465
macOS ARM64   validation/20260911T093252+0200-21907
```

Entrambe le sessioni hanno eseguito:

```text
catalog-snapshot.test
default.test
facility.test
install.test
uninstall.test
versions.test
```

con risultato:

```text
PASS 6/6
runner exit status 0
```

La suite registrata da entrambe le sessioni è esattamente:

```text
rumiai-tests@fa2583d85121001d642f1f733f037c3f117ca4e5
```

La configurazione della suite pinna la revisione prodotto:

```text
rumiai-os@bd167bbaa509dbbcb8b803152e22db3895c01a5d
```

La physical validation K1 è quindi completata.

---

## Evidence precedenti

Le evidence precedenti restano immutabili e revision-specific:

```text
validation/20260911T092519+0200-117158
    Ubuntu ARM64
    rumiai-tests@4c018f7c577ba6c7d9f68f94ee55366334f15742
    PASS 6/6

validation/20260911T092532+0200-20189
    macOS ARM64
    rumiai-tests@4c018f7c577ba6c7d9f68f94ee55366334f15742
    ERROR facility.test per errore test-only di portabilità chmod
```

Non vengono reinterpretate, modificate o sostituite retroattivamente dalle nuove evidence.

---

## Stato acquisito K1

K1 è ora completato e fisicamente validato sui reference host.

Il prodotto validato implementa:

```text
validazione canonica del file facility
materializzazione byte-identica di <package-version>/facility
provider index derivato sotto $m_DATA_DIR/sys/pkg/providers
marker provider regolari vuoti nominati con la concrete package identity
provider generic e target-specific
rimozione marker durante pkg_deintegrate
rimozione della directory <compatibility>/ quando perde l'ultimo marker
```

Restano preservati:

```text
nessun nuovo comando pubblico pkg
nessuna dependency resolution in K1
nessun binding/ in K1
nessun provider ranking implicito
nessun uso di current/default come resolver
nessun confronto universale della versione upstream
nessuna resolution durante il normale launch
nessuno State Instance avanzato
```

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
K1b  physical validation facility + pkg regression                [completed]
K2   dependency resolution + resolved binding                     [current: planning]
```

---

## Confine K2 già fissato

Restano già Accepted per K2:

```text
validazione/materializzazione dependency
provider discovery attraverso provider index
compatibility matching numerico
scelta della massima compatibility compatibile
fallimento su più provider eleggibili alla compatibility selezionata
target eligibility già fissata
materializzazione binding/<facility>
normal launch senza resolution
```

La dependency resta astratta e distinta dal resolved binding.

Il provider index resta derivato dalle dichiarazioni package-local `facility`.

Nessuna regola K2 autorizza ranking impliciti basati su:

```text
current/default
versione upstream
ordine di installazione
ordine del filesystem
ordine lessicografico del provider
preferenza generic/target-specific non esplicitamente fissata
```

---

## Punti K2 ancora da fissare prima dell'implementazione completa

Restano aperti e non devono essere risolti per inferenza:

```text
semantica di rimozione di un provider già referenziato da binding esistenti
atomicità/recovery delle mutazioni dependency/binding quando materialmente richieste
```

La fase corrente è quindi progettazione K2.

Questo checkpoint non autorizza da solo modifiche K2 a `rumiai-os`.

---

## Invarianti correnti

```text
PKG-NOW-140  K1 product revision validata = rumiai-os@bd167bbaa509dbbcb8b803152e22db3895c01a5d
PKG-NOW-141  K1 suite revision validata = rumiai-tests@fa2583d85121001d642f1f733f037c3f117ca4e5
PKG-NOW-142  K1 Ubuntu evidence = validation/20260911T093239+0200-174465
PKG-NOW-143  K1 macOS evidence = validation/20260911T093252+0200-21907
PKG-NOW-144  entrambe le nuove evidence sono PASS 6/6 con runner status 0
PKG-NOW-145  K1b è completed
PKG-NOW-146  evidence precedenti restano immutabili e revision-specific
PKG-NOW-147  K2 è current: planning
PKG-NOW-148  dependency requirement != resolved binding
PKG-NOW-149  normal launch non effettua resolution
PKG-NOW-150  provider removal/reference semantics restano da fissare
PKG-NOW-151  dependency/binding atomicity/recovery restano da fissare quando richieste
PKG-NOW-152  nessuna modifica K2 a rumiai-os è autorizzata implicitamente da questo checkpoint
PKG-NOW-153  Git resta forward-only
```
