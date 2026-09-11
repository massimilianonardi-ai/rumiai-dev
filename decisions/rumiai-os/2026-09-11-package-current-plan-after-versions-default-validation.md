# Decisione — Piano package corrente dopo la validation `pkg versions` / `pkg default`

Date: 2026-09-11  
Status: **Accepted**

## Scopo e supersession

Questo documento supersede, esclusivamente per stato operativo e sequencing corrente:

```text
decisions/rumiai-os/2026-09-10-package-current-plan-after-versions-default-implementation.md
```

I contratti e le decisioni tecniche precedenti restano autorevoli nei rispettivi scope.

La chiusura del gate J3c è registrata in:

```text
decisions/rumiai-os/2026-09-11-package-versions-default-arm64-physical-validation.md
```

---

## Stato acquisito

La coppia:

```text
rumiai-os@59fc8d5945dd4ec8acc99e4c41628e5cfed37a13
rumiai-tests@e2dd1ac08b9e1167a7a20db12a01a4869b797376
selection: rumiai-os/pkg
```

è fisicamente validata sui reference host Ubuntu ARM64 e macOS ARM64.

Entrambi gli host hanno prodotto:

```text
PASS 5/5
runner exit status 0
```

per:

```text
catalog-snapshot.test
default.test
install.test
uninstall.test
versions.test
```

Evidence:

```text
Ubuntu ARM64  validation/20260911T063224+0200-114517
macOS ARM64   validation/20260911T063242+0200-18138
```

Ogni validation ref è un singolo commit di evidence direttamente sopra la revisione esatta della suite `e2dd1ac...`.

J3 è quindi chiuso senza reinterpretare le evidence precedenti.

---

## Sequenza operativa corrente

```text
J1  pkg uninstall: contratto/test/implementazione                    [completato]
J2  physical validation pkg uninstall                                [completato]
J3a pkg versions/default: naming e contratto pubblico                [completato]
J3b permanent test + implementazione                                 [completato]
J3c physical validation versions/default + regressione pkg           [completato]
K   dependency/facility/state avanzato soltanto quando richiesto     [corrente: pianificazione]
```

La fase K non parte da un design vuoto e non autorizza ancora modifiche a `rumiai-os`.

---

## Autorità già fissate per K

Il modello package di facility/dependency/provider è già Accepted in:

```text
decisions/rumiai-os/2026-09-07-package-facility-dependency-and-provider-index.md
```

Il confine delle State Instance rispetto a `var/` è già Accepted e ulteriormente precisato in:

```text
decisions/rumiai-os/2026-09-07-package-state-instance-runtime-eligibility.md
```

La sequenza generale che colloca dependency/facility/state dopo il lifecycle locale è fissata da:

```text
decisions/rumiai-os/2026-09-09-package-implementation-plan-and-catalog-refresh-boundary.md
```

Queste decisioni non vengono riaperte implicitamente.

---

## Invarianti K già fissati

Restano già decisi almeno i seguenti confini:

```text
facility è il termine canonico del package manager; Capability non viene riattivato
dependency = facility + compatibility constraint
provider = concrete package version che offre facility + compatibility
versione upstream, target qualification e compatibility sono dimensioni distinte
comparators compatibility ammessi: = > >= < <=
una concrete version dichiara al massimo una dependency per facility nel baseline
<package-version>/facility è dichiarazione package-local autorevole delle facility offerte
<package-version>/dependency dichiara requisiti astratti
provider index = $m_ROOT/data/sys/pkg/providers/<facility>/<compatibility>/
provider marker = file regolare vuoto nominato con la concrete package identity
provider index è derivato, non sostituisce il file package-local facility
resolution appartiene a pkg e produce un resolved binding concreto
resolved binding = <package-version>/binding/<facility>
binding/<facility> è un file regolare dati contenente una concrete package identity su una riga
normal launch non esegue provider discovery, compatibility matching o resolution
launcher non invoca pkg per risolvere dependency
provider non qualificato è target-independent
provider qualificato è eleggibile soltanto per lo stesso osarch
consumer non qualificato può avere soltanto binding verso provider non qualificati
consumer target-specific può usare provider non qualificati o provider dello stesso target
la directory storica dep/ e i symlink dependency non appartengono al modello corrente
il precedente Execution Capability model non viene riattivato
```

Per lo state restano inoltre fissati:

```text
package che usa var/ per lo state -> State Instance runtime/per-invocation vietata
package con var/ -> eventuale State Instance alternativa soltanto persistente package-level
package senza var/ + state -> tutto lo state rilevante deve essere controllabile via environment
package senza var/ + state -> State Instance runtime strutturalmente possibile
package senza var/ + nessuno state gestito -> State Instance non applicabile
pkg run non può bypassare questi confini
```

Non vengono reintrodotti resolver universale, generations, inventory obbligatorie o migration framework generale.

---

## Punti realmente aperti prima dell'implementazione K

La decisione facility/dependency lascia esplicitamente aperti:

```text
sintassi testuale esatta di <package-version>/facility
sintassi testuale esatta di <package-version>/dependency
grammatica lessicale e confronto delle compatibility numeriche multi-componente
policy di scelta fra più provider compatibili equivalenti
transaction/atomic-replacement semantics quando il lifecycle operativo le richiederà
```

La decisione sulle State Instance lascia separatamente aperti i meccanismi operativi della selezione persistente per package con `var/`, incluso aggiornamento coerente dei routing, esclusione durante esecuzione, atomicità e recovery.

Questi punti aperti non vengono colmati per inferenza o convenienza implementativa.

---

## Prossimo lavoro

Il prossimo lavoro sul package manager è quindi una fase di progettazione/consolidamento, non ancora una modifica del prodotto:

```text
1. fissare la serializzazione minima di facility e dependency;
2. fissare la grammatica/confronto della compatibility numerica necessaria a quella serializzazione;
3. fissare la policy deterministica per provider compatibili equivalenti;
4. solo dopo definire il primo confine implementativo e i permanent test proporzionati;
5. modificare rumiai-os soltanto dopo esplicita autorizzazione per quella fase di implementazione.
```

Lo state avanzato resta separabile: non deve essere implementato soltanto per completare facility/dependency se il primo caso d'uso concreto non lo richiede.

---

## Invarianti correnti

```text
PKG-NOW-90  J3c è chiuso con PASS 5/5 su Ubuntu ARM64 e macOS ARM64
PKG-NOW-91  product baseline validata per J3 = rumiai-os@59fc8d5
PKG-NOW-92  validation suite J3 = rumiai-tests@e2dd1ac + selection rumiai-os/pkg
PKG-NOW-93  K è il confine corrente di pianificazione, non un'autorizzazione implicita a modificare rumiai-os
PKG-NOW-94  K riusa integralmente il modello Accepted facility/dependency/provider/resolved-binding già fissato
PKG-NOW-95  i punti aperti di K non vengono risolti per inferenza
PKG-NOW-96  state avanzato viene introdotto soltanto quando richiesto da un caso d'uso concreto
PKG-NOW-97  resolver universale, generations, inventory obbligatorie e migration framework restano esclusi dal baseline
PKG-NOW-98  Git resta forward-only
```
