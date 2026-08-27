# Audit di `massimilianonardi/m` — `mk`, profili e target

Data: 2026-08-27

Snapshot:

```text
e4faae1c1d9b27cc5503b987ba5e7bf2874c906c
```

## Scopo

Questo documento analizza il sottosistema storico `mk` per capire quali concetti possano contribuire alla futura composizione e materializzazione di `rumiai-os`.

È importante non proiettare sul codice storico la terminologia attuale: il significato di `target` in `mk` è diverso dal significato che stiamo usando oggi per hosted/container/image/device.

---

# 1. Struttura individuata

Il comando principale è:

```text
var/#_os/m/bin/mk
```

con moduli in:

```text
var/#_os/m/bin/include/mk/
```

Fra i moduli rilevati:

```text
mk_conf
mk_conf_project
mk_targets
mk_type_multi
mk_type_composer
mk_type_cpp
mk_type_electron
mk_type_file
mk_type_java
mk_type_javascript
...
```

Quindi `mk` è un framework di build/composizione con dispatch per **tipo di progetto**.

---

# 2. Modello concettuale storico

La struttura ricostruita è approssimativamente:

```text
PROJECT
   ↓
PROFILE(s)
   ↓
TYPE
   ↓
TARGET(s)
   ↓
TYPE/TARGET hooks
```

## `PROJECT`

Identifica il progetto o sotto-progetto da elaborare.

## `PROFILE`

Applica configurazioni/varianti del progetto.

## `TYPE`

Identifica la famiglia di progetto/artifact, ad esempio:

```text
multi
cpp
java
javascript
electron
file
composer
```

## `TARGET`

Nel codice storico è una **operazione/lifecycle action**, ad esempio:

```text
clean
build
install
run
test
depend
...
```

---

# 3. Distinzione terminologica importante per `rumiai-os`

Nella discussione corrente di `rumiai-os` usiamo spesso "target" per indicare il **substrato di materializzazione/deployment**:

```text
hosted
Podman container
OS image
device
bare metal
```

In `mk`, invece, target significa soprattutto:

```text
operation/lifecycle step
```

Questi concetti non devono essere confusi nel nuovo sistema.

### Proposta terminologica da approfondire

Potremmo distinguere, senza ancora fissare i nomi definitivi:

```text
operation/action
    build, install, test, deploy, run

deployment target / environment target
    hosted, podman, image, device, bare-metal

profile
    variante/configurazione della composizione

component/artifact type
    software/package/project kind
```

La distinzione va consolidata prima della specifica di `rumiai-os`.

---

# 4. Dispatch type/target

`mk` implementa un pattern molto interessante.

Per ogni target cerca progressivamente handler specializzati:

```text
mk_type_<TYPE>_target_<TARGET>_ante
mk_type_<TYPE>_target_ante
mk_target_<TARGET>_ante
```

poi il corpo:

```text
mk_type_<TYPE>_target_<TARGET>
mk_type_<TYPE>_target
mk_target_<TARGET>
```

poi il post:

```text
mk_type_<TYPE>_target_<TARGET>_post
mk_type_<TYPE>_target_post
mk_target_<TARGET>_post
```

Questa è una forma di **fallback dispatch / specialization hierarchy**.

## Valore architetturale

Il pattern consente:

- comportamento generale;
- override per tipo;
- override per singola combinazione tipo/operazione;
- hook ante/post.

### Classificazione preliminare

**KEEP il pattern concettuale; REDESIGN l'implementazione.**

Può essere utile anche nel futuro deployment engine, ma non va necessariamente implementato tramite nomi funzione costruiti dinamicamente.

---

# 5. Configurazione stratificata

`mk_conf` carica configurazioni sovrapposte per:

```text
base project
profile
operation target
profile + target
type
profile + type
```

Questa è una forma di configuration overlay.

## Aspetto utile

Un sistema che deve produrre environment differenti ha effettivamente bisogno di una gerarchia di default e override.

Esempio futuro concettuale:

```text
base profile
  + desktop profile
  + geospatial capability pack
  + podman deployment adapter
  + host/user overrides
```

## Problema storico

Le configurazioni `mk` sono shell code sourced direttamente:

```sh
. "$MKCONF_FILE"
```

Quindi configurazione e codice hanno lo stesso livello di potere.

### Direzione `rumiai-os`

**KEEP overlay semantics; REDESIGN data format/trust model.**

---

# 6. Multi-project composition

`mk_type_multi` gestisce una composizione di più progetti e supporta:

```text
PROJECTS
PROJECTS_HI_PRI
PROJECTS_LO_PRI
```

oltre alla possibilità di scoprire automaticamente i progetti presenti nella directory.

Il sistema processa:

1. high-priority projects;
2. progetti normali;
3. low-priority projects.

## Valore

Esiste già il concetto di **composizione di più componenti** in un'unica operazione.

## Limite

La priorità lineare non è equivalente a un dependency graph.

Per `rumiai-os` la composizione dovrebbe dipendere da relazioni esplicite e da un resolver, non dall'ordine implicito della directory o da tre bucket di priorità.

### Classificazione

```text
composition concept: KEEP
priority-list implementation: REDESIGN
```

---

# 7. Dipendenze di progetto, package, source e build

`mk_targets` distingue più tipi di dipendenza:

```text
DEPEND_PKG
DEPEND_PRJ
DEPEND_SRC
DEPEND_BUILD
```

Questo è molto interessante perché riconosce che non tutte le dipendenze hanno la stessa semantica.

## Interpretazione preliminare

- `DEPEND_PKG`: package runtime/build richiesti;
- `DEPEND_PRJ`: altri progetti da processare;
- `DEPEND_SRC`: sorgenti/import da altri progetti;
- `DEPEND_BUILD`: output build richiesti.

La semantica precisa deve ancora essere ricostruita.

## Valore per `rumiai-os`

La distinzione può diventare un modello più generale di dependency/capability edges.

### Classificazione

**KEEP il requisito di tipi di dipendenza; REDESIGN il grafo e il resolver.**

---

# 8. Lifecycle storico

Il default osservato in `mk` include una sequenza simile a:

```text
dependclean
clean
depend
build
install
```

Altri target gestiscono:

```text
run
test
testenv
testenvdeep
```

## Aspetto importante

Il sistema non considera "install" come un'operazione isolata: costruisce prima dipendenze e artifact.

Questo anticipa un concetto utile di **plan/lifecycle pipeline**.

## Limite

L'ordine è ancora fortemente imperativo e il target runner esegue side effect durante la risoluzione.

Per `rumiai-os` vogliamo invece distinguere:

```text
resolve plan
validate plan
execute plan
commit state
```

---

# 9. Build state / incremental execution

`mk_targets` usa marker come:

```text
task-build.done
task-run.done
```

insieme a controlli `newer` per determinare se build/run devono essere aggiornati.

## Valore

Riconosce il requisito di evitare operazioni inutili e di mantenere stato di esecuzione.

## Limite

Timestamp/marker sono insufficienti come modello generale per un sistema riproducibile e content-addressed.

### Direzione futura

Da valutare almeno:

```text
input digest
resolved dependency graph
configuration digest
toolchain identity
artifact digest
```

prima di decidere se un output è realmente riutilizzabile.

---

# 10. Install come bridge verso package manager

`mk_target_install_post()` importa la distribuzione prodotta nel `PKG_DIR` e poi chiama:

```text
pkg integrate
```

Questo crea già una separazione interessante:

```text
build system
    produce artifact

package system
    materializza/integrate artifact
```

## Valutazione

**KEEP il confine concettuale.**

Il futuro `rumiai-os` dovrebbe evitare che build system e package manager diventino lo stesso componente.

---

# 11. Test environment come root temporanea

`mk_target_testenv_export`, `testenvdeep` e `test` possono creare una directory di installazione e chiamare:

```text
sys_root <dir>
```

Quindi il sistema storico possiede già il concetto di **materializzare una nuova root per testare l'installazione**.

Questo è molto vicino a un requisito fondamentale per `rumiai-os`:

```text
same system definition
    ↓
materialize into isolated root
    ↓
validate
```

### Valutazione

**KEEP fortemente il concetto.**

Potrebbe diventare la base dei test di relocatability e dei futuri environment target.

---

# 12. Relazione con i futuri deployment target

`mk` non implementa direttamente la visione moderna:

```text
hosted
container
image
device
bare-metal
```

ma contiene tre pattern utili per costruirla:

1. **configuration overlays**;
2. **type/action specialization**;
3. **materializzazione verso una root arbitraria**.

Questi tre concetti possono essere generalizzati in un futuro deployment engine.

Esempio puramente concettuale:

```text
System Definition
      ↓
Profile Resolution
      ↓
Deployment Environment Resolver
      ↓
Plan
      ↓
Materializer
      ├── directory-root
      ├── podman
      ├── disk-image
      └── device
```

Questa non è ancora una decisione architetturale definitiva.

---

# 13. Configurazione come codice: problema ricorrente

Come nel package manager, `mk` usa shell sourced come configurazione.

Il pattern è molto potente ma produce gli stessi problemi:

```text
config == arbitrary code
no schema
no static validation
harder reproducibility
harder security review
implicit global state
```

La nuova architettura dovrebbe mantenere l'espressività solo dove realmente necessaria.

La configurazione ordinaria dovrebbe essere dati validabili.

---

# 14. Global mutable environment

`mk` comunica fra molti moduli tramite variabili globali/exported:

```text
PROJECT
PROFILE
TYPE
TARGET
BUILD_DIR
DIST_DIR
RUN_DIR
TASK_DIR
INST_DIR
...
```

Questo semplifica shell scripting ma aumenta il coupling e rende più difficile ragionare su:

- nesting;
- parallelism;
- reentrancy;
- test isolati;
- provenance dei valori;
- override involontari.

### Direzione

Il futuro modello dovrebbe distinguere uno **state/context esplicito** dalla semplice global environment mutation.

In shell POSIX questo non implica necessariamente oggetti complessi, ma richiede disciplina di API e ownership delle variabili.

---

# 15. Classificazione preliminare

| Elemento storico `mk` | Classificazione |
|---|---|
| project composition | KEEP / REDESIGN |
| profiles | KEEP |
| config overlays | KEEP / REDESIGN |
| project `TYPE` | KEEP concept |
| operation `TARGET` | KEEP concept, rename/clarify |
| type/action fallback dispatch | KEEP / REDESIGN |
| ante/main/post hooks | KEEP selectively / REDESIGN |
| `PROJECTS_HI_PRI/LO_PRI` | REDESIGN into dependency graph |
| distinct dependency kinds | KEEP / formalize |
| timestamp task markers | REDESIGN |
| install → package integration bridge | KEEP |
| test root materialization | KEEP strongly |
| sourced shell config | REDESIGN |
| global mutable environment | REDESIGN |

---

# 16. Terminologia da non confondere nel nuovo progetto

Prima di progettare le directory di `rumiai-os`, dobbiamo fissare termini distinti per almeno:

```text
component/project type
operation/lifecycle action
profile
host/platform adapter
deployment environment/target
system definition
materialization plan
```

In particolare, usare semplicemente `target` sia per `build/install/run` sia per `podman/device/image` creerebbe ambiguità strutturale.

---

# 17. Conclusione

`mk` non è direttamente il futuro deployment engine di `rumiai-os`, ma contiene una parte significativa della sua genealogia.

Le idee più forti da preservare sono:

```text
composizione di componenti
configuration overlays
profili
specializzazione per tipo
lifecycle esplicito
separazione build/install/integration
root di test/materializzazione arbitraria
```

La nuova architettura deve però sostituire:

```text
ordine imperativo
priorità lineari
global state
shell config eseguibile
timestamp-only state
```

con contratti e piani più espliciti e verificabili.
