# Decisione — Attivazione baseline `mk` per source materialization

Date: 2026-09-14  
Status: **Accepted / Active**

## 1. Scopo

Questa decisione avvia formalmente lo sviluppo di `mk` e attiva la specifica:

```text
specifications/rumiai-os/MK-SOURCE-MATERIALIZATION.md
```

come contratto corrente della prima tranche implementativa.

La decisione deriva dall'autorizzazione esplicita dell'utente del 2026-09-14 ad avviare lo sviluppo di `mk`, definire specifiche esatte e modificare direttamente `rumiai-os` esclusivamente per `mk` e le sue librerie dirette in questa fase.

## 2. Ambito autorizzato nel prodotto

In questa fase possono essere aggiunti o modificati in `rumiai-os` esclusivamente:

```text
bin/sys/mk
lib/sys/sh/mk-*.lib.sh
```

quando tali librerie sono responsabilità dirette di `mk` e sono richieste dal contratto attivo.

Non sono autorizzate in questa fase modifiche a:

```text
pkg
pkg internals
state-path
m bootstrap
core libraries non specifiche di mk
pkg-catalog
altri comandi o componenti di rumiai-os
```

Se l'implementazione di `mk` rivela la necessità di modificare uno di tali componenti, la necessità deve essere documentata e la modifica rinviata a una fase esplicitamente autorizzata.

## 3. Prima tranche

La prima tranche implementa soltanto:

```text
mk materialize <source-root> <definition-root> <useful-root>
```

con:

```text
core materialization library
copy materialization type
```

secondo la specifica attivata.

Non vengono implementati in questa tranche:

```text
mk build
mk test
mk install
project discovery
build environment resolution
build material acquisition
local package integration
source-only pkg install integration
```

## 4. Boundary con `pkg`

Il current `pkg` resta invariato.

La nuova primitive di `mk` è progettata perché una futura evoluzione di `pkg` possa inserire source materialization fra:

```text
pkg_extract
```

e:

```text
pkg_integrate
```

senza fondere la compilazione/materializzazione dentro `pkg_extract`.

Questa decisione non modifica la CLI pubblica di `pkg` e non reintroduce candidate-directory o local-path install.

## 5. Build environment

Restano acquisiti come direzione di design, ma non ancora come schema implementato:

```text
build tool/toolchain persistenti e condivisi
    -> normali package gestibili da pkg

build material privato della materializzazione
    -> non automaticamente package

runtime dependency
    -> current facility/dependency model
```

La futura serializzazione e resolution dei build requirement richiede una decisione successiva.

## 6. State

La tranche iniziale non introduce state persistente di `mk` perché il caller fornisce esplicitamente il pathname della useful root.

Ogni futura estensione stateful di `mk` deve usare `state-path` e il contratto corrente di selector semantici/user binding globale fissato da:

```text
decisions/rumiai-os/2026-09-14-semantic-state-selectors-and-global-user-binding.md
```

Non deve derivare identity da UID o host-id.

## 7. Testing

Il comportamento consolidato di questa tranche deve essere protetto da test permanenti in `rumiai-tests`.

I test possono essere aggiunti in questa fase secondo `TESTING.md`; la restrizione di scrittura sul prodotto riguarda `rumiai-os`, non il repository della suite permanente.

La physical validation resta revision-specific e verrà richiesta soltanto secondo la normale policy di testing quando proporzionata alla modifica.

## 8. Invarianti

```text
MK-ACT-01  MK-SOURCE-MATERIALIZATION.md è il contratto attivo della prima tranche
MK-ACT-02  mk appartiene al layer tecnico m
MK-ACT-03  in rumiai-os questa fase può modificare solo bin/sys/mk e librerie dirette lib/sys/sh/mk-*.lib.sh
MK-ACT-04  pkg e le sue internals restano immutati in questa fase
MK-ACT-05  la prima tranche implementa solo materialize e il tipo copy
MK-ACT-06  build/test/install e build-environment resolution restano tranche successive
MK-ACT-07  future estensioni stateful usano state-path e non UID/host-id
MK-ACT-08  i test permanenti della tranche appartengono a rumiai-tests
MK-ACT-09  Git resta forward-only
```
