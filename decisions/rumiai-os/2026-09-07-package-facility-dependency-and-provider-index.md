# Decisione — Facility, dependency e provider index del package manager

Date: 2026-09-07  
Status: **Accepted**

## Contesto

Il modello package corrente ha già fissato:

- `$m_ROOT/pkg/<pkg>@<version>!<osarch>/` come pathname di una versione concreta;
- `$m_ROOT/pkg/<pkg>!<osarch>` come selector persistente della versione corrente;
- package installati il più autosufficienti possibile e normale launch senza dipendenza dal comando `pkg`;
- `<package-version>/env` come frammento shell POSIX version-specific gestito/materializzato da `pkg install`;
- `cmd/<pkg-command>` come sede della logica di launch specifica del command;
- `link/<pkg-command>`, quando presente, come symlink relativo esclusivamente verso `root/` dello stesso package concreto;
- `data/sys/<component>/` come namespace di state/data dei componenti del sistema base RumiAI;
- il precedente resolver universale basato su Execution Capability contracts, release-order, provider ranking e Resolved Dependency Graph come design storico non appartenente alla baseline corrente.

Resta però necessario permettere a un package di dipendere da una funzione/runtime/interfaccia compatibile senza legarsi direttamente:

- a una specifica versione upstream;
- al selector `current` di un altro package;
- a uno specifico provider quando il requisito reale è una compatibilità astratta.

La presente decisione introduce un modello più piccolo basato su `facility`, `provider`, `dependency`, compatibility numerica e resolution esplicita da parte di `pkg`.

Questa unità di lavoro modifica soltanto `rumiai-dev`. Non autorizza modifiche a `rumiai-os` o `rumiai-tests`.

---

## 1. Terminologia

Nel package manager il termine canonico è:

```text
facility
```

Una `facility` è un'identità astratta di una funzionalità/interfaccia utilizzabile come requisito fra package.

Un:

```text
provider
```

è una versione concreta di package che offre una determinata facility con una determinata compatibility version.

Una:

```text
dependency
```

è un requisito di un package consumer espresso come facility più constraint di compatibilità.

Un:

```text
resolved binding
```

è la scelta concreta di un provider che soddisfa una dependency.

Il termine `Capability` non viene usato per questo modello package-manager. Le precedenti `Execution Capability` dei draft del 2026-08-30 restano storiche e non vengono riattivate. Questa decisione non modifica né rinomina altri concetti RumiAI già denominati `Capability` in sottosistemi differenti.

---

## 2. Modello semantico

Il modello corrente è:

```text
facility
    nome astratto di ciò che viene fornito

compatibility
    versione semanticamente confrontabile della facility

dependency
    facility + constraint

resolution
    scelta di un provider compatibile effettuata da pkg

resolved binding
    provider concreto selezionato, distinto dalla dependency

launch
    nessuna resolution
```

Principio fondamentale:

```text
dependency requirement != resolved binding
```

Un consumer non dipende semanticamente dal pathname di una specifica versione upstream né dal selector `current` di un altro package. Dipende dalla facility e dalla compatibility richiesta.

---

## 3. Versione upstream e compatibility version sono distinte

La versione upstream del package resta quella codificata nell'identità concreta:

```text
<pkg>@<version>!<osarch>
```

La compatibility version di una facility è invece un valore separato dichiarato dal provider.

Esempio concettuale:

```text
package concreto:
    java@21.0.2+13!macos-arm64

facility offerta:
    java

compatibility:
    21
```

Quindi:

```text
21.0.2+13
    versione upstream del software

21
    compatibility della facility
```

Non viene introdotto un comparatore universale delle versioni upstream.

---

## 4. File package-local `facility`

Una versione concreta che offre una o più facility può contenere il file opzionale:

```text
<package-version>/facility
```

Il file appartiene al packaging RumiAI ed è gestito/materializzato da `pkg install`.

Semanticamente dichiara, per ogni facility offerta almeno:

```text
facility
compatibility
```

Esempio concettuale non ancora normativo per la serializzazione:

```text
java 21
```

Una singola versione concreta può offrire più facility quando ciò corrisponde realmente alle sue interfacce utilizzabili.

La sintassi testuale esatta del file resta da fissare separatamente; questa decisione ne fissa nome e semantica, non introduce ancora un formato di serializzazione definitivo.

---

## 5. File package-local `dependency`

Una versione concreta che richiede una o più facility può contenere il file opzionale:

```text
<package-version>/dependency
```

Il file appartiene al packaging RumiAI ed è gestito/materializzato da `pkg install`.

Semanticamente dichiara, per ogni dependency almeno:

```text
facility
compatibility constraint
```

Esempi concettuali non ancora normativi per la serializzazione:

```text
java >=17 <22
python >=3.11 <3.14
```

Il file dichiara requisiti astratti. Non contiene semanticamente il provider concreto risolto come sostituto della dependency.

La rappresentazione fisica del resolved binding resta separata e viene fissata successivamente.

La sintassi testuale esatta del file resta da fissare separatamente.

---

## 6. Compatibility e operatori

La compatibility version è numerica e separata dalla versione upstream.

I comparator ammessi dal modello corrente sono esclusivamente:

```text
=
>
>=
<
<=
```

Più comparator riferiti alla stessa dependency rappresentano l'intersezione dei vincoli richiesta dal consumer.

Esempio concettuale:

```text
java >=17 <22
```

significa una compatibility almeno 17 e inferiore a 22.

Non vengono fissati nel baseline corrente:

```text
OR
!=
wildcard
caret
tilde
constraint sulla versione upstream
```

La grammatica lessicale e le regole esatte di confronto delle compatibility numeriche multi-componente saranno fissate insieme alla serializzazione dei file `facility` e `dependency`; non devono essere inferite dalle versioni upstream.

---

## 7. Provider index del componente base `pkg`

Le facility offerte dalle versioni concrete installate vengono indicizzate dal componente base `pkg` sotto:

```text
$m_ROOT/data/sys/pkg/providers/<facility>/<compatibility>/
```

Esempio:

```text
$m_ROOT/data/sys/pkg/providers/java/21/
```

La directory di compatibility contiene symbolic link che identificano le versioni concrete installate che offrono esattamente quella facility con quella compatibility.

La struttura appartiene a:

```text
$m_ROOT/data/sys/pkg/
```

perché è data del componente base `pkg`, coerentemente con il namespace system state già fissato:

```text
$m_ROOT/<area>/sys/<component>/
```

Il provider index non introduce state di package sotto `data/<pkg>` e non è una Package State Instance.

La forma esatta dei nomi dei symlink provider e del loro target testuale verrà chiusa insieme al modello fisico del resolved binding. Ogni target dovrà comunque preservare relocatability e identificare una versione concreta installata, non una selezione runtime casuale.

---

## 8. Lifecycle del provider index

`pkg` aggiorna il provider index quando una versione concreta che dichiara facility viene installata, rimossa o altrimenti cessa di essere un provider disponibile.

Quando viene rimosso l'ultimo symlink dalla directory:

```text
$m_ROOT/data/sys/pkg/providers/<facility>/<compatibility>/
```

la directory `<compatibility>/` viene rimossa.

Il provider index non è un meccanismo di launch e non viene consultato dal launcher per effettuare resolution ad ogni esecuzione.

---

## 9. Resolution

La resolution appartiene al comando `pkg` e avviene durante operazioni esplicite che richiedono la scelta o il riallineamento delle dependency.

Per una dependency, `pkg` considera provider che:

```text
offrono la stessa facility
hanno compatibility che soddisfa tutti i comparator del requirement
sono utilizzabili per il target pertinente secondo il modello package/osarch corrente
```

La policy esatta per scegliere fra più provider compatibili equivalenti resta aperta. Non vengono reintrodotti implicitamente:

```text
release-order
provider ranking universale
ordine di installazione come tie-breaker
ordine del filesystem come tie-breaker
Desired/Resolved Integration Profile
generations
Resolved Dependency Graph obbligatorio
```

Una nuova policy di scelta richiederà una decisione esplicita.

---

## 10. Resolved binding

Il risultato di una resolution è un resolved binding concreto:

```text
dependency astratta
    -> provider concreto
```

Il binding è distinto dalla dependency originale.

La dependency continua quindi a poter essere rivalutata durante una futura operazione esplicita di `pkg` senza cambiare il requisito dichiarato dal consumer.

La rappresentazione fisica del resolved binding e il modo con cui `<package-version>/env` lo consuma senza incorporare una dipendenza fragile da dettagli riscrivibili restano il prossimo punto da fissare.

Questa decisione non introduce ancora:

```text
directory package-local dep/
symlink package-local di dependency
binding cross-package attraverso link/
resolution runtime nel launcher
```

---

## 11. Launch

Il normale launch non esegue resolution.

Regola:

```text
pkg operation
    -> resolve dependency
    -> materialize resolved binding

normal launch
    -> consume already-resolved binding
    -> no provider search
    -> no compatibility comparison
    -> no pkg invocation
```

Il provider index sotto `data/sys/pkg/providers/` non deve quindi diventare un resolver implicito consultato ad ogni esecuzione.

Questo preserva il principio corrente secondo cui un package installato è il più autosufficiente possibile e il normale runtime non dipende dal comando `pkg`.

---

## 12. Relazione con `env`, `cmd/` e `link/`

Le dependency possono servire a costruire l'environment o una launch line specifica del consumer.

`<package-version>/env` resta la sede della preparazione environment version-specific del consumer.

`cmd/<pkg-command>` resta la sede della launch line command-specific.

`link/<pkg-command>`, quando presente, resta esclusivamente un symlink relativo verso `root/` della stessa versione concreta dello stesso package e non può puntare a un provider dependency.

Il futuro meccanismo del resolved binding dovrà quindi rendere un provider già risolto utilizzabile da `env` e/o `cmd/` senza cambiare la semantica di `link/`.

---

## 13. Relazione con il design storico 2026-08-30

I draft storici avevano introdotto `Execution Capability`, contract version, compatibility version, resource contract, provider ranking, `release-order`, exact binding e Resolved Dependency Graph.

Questa decisione recupera soltanto i principi che risultano necessari nel modello corrente:

```text
versione upstream != compatibility
requirement != resolved binding
provider compatibile scelto durante resolution
execution senza re-resolution
```

Non riattiva automaticamente gli altri meccanismi storici.

Il termine package-manager `Execution Capability` è sostituito nel modello corrente da `facility` e non deve essere riproposto come alias.

---

## 14. Supersession mirata

Questa decisione supersede/precisa la sezione dependency di `2026-09-05-package-manager-current-and-run-model.md` nella misura in cui lasciava come unica baseline iniziale riferimenti concreti semplici e trattava un resolver più generale come interamente futuro.

È ora fissato il modello minimo:

```text
facility
provider
compatibility
dependency constraint
provider index
resolution esplicita
resolved binding distinto dal requirement
nessuna resolution nel launch
```

Restano superseded e non vengono riaffermati i meccanismi storici più ampi elencati sopra.

---

## 15. Implementazione e test

Alla data di questa decisione il modello non è ancora implementato in `rumiai-os` e non esistono test permanenti `pkg`/facility/dependency in `rumiai-tests`.

L'implementazione prodotto richiede una fase successiva esplicitamente autorizzata.

Quando implementato, il contratto dovrà essere protetto almeno per:

```text
indicizzazione provider installati per facility/compatibility
rimozione dell'entry provider durante uninstall/rimozione
rimozione della directory compatibility quando perde l'ultimo provider
matching facility exact
matching dei comparator supportati
separazione versione upstream / compatibility
nessuna resolution durante il normale launch
nessun uso cross-package di link/
relocatability dei provider symlink
```

---

## 16. Invarianti fissati

```text
PKG-FAC-01  il package manager usa il termine facility, non capability, per la funzionalità astratta fornita/richiesta fra package
PKG-FAC-02  provider = versione concreta di package che offre una facility con una compatibility
PKG-FAC-03  <package-version>/facility è il file package-local opzionale che dichiara le facility offerte
PKG-FAC-04  <package-version>/dependency è il file package-local opzionale che dichiara dependency astratte
PKG-FAC-05  dependency = facility + compatibility constraint
PKG-FAC-06  versione upstream e compatibility sono identità distinte
PKG-FAC-07  i comparator compatibility ammessi sono =, >, >=, <, <=
PKG-FAC-08  più comparator della stessa dependency sono congiunti per intersezione
PKG-FAC-09  il provider index vive sotto $m_ROOT/data/sys/pkg/providers/<facility>/<compatibility>/
PKG-FAC-10  la directory compatibility viene rimossa quando perde l'ultimo provider symlink
PKG-FAC-11  resolution = scelta esplicita da parte di pkg di un provider compatibile
PKG-FAC-12  resolved binding è concreto ma semanticamente distinto dalla dependency
PKG-FAC-13  il normale launch non effettua provider discovery, compatibility matching o resolution
PKG-FAC-14  il launcher non invoca pkg per risolvere dependency
PKG-FAC-15  link/<pkg-command> non viene usato come binding cross-package verso provider dependency
PKG-FAC-16  directory package-local dep/ e relativi symlink dependency non appartengono al modello corrente
PKG-FAC-17  il vecchio package-manager Execution Capability model non viene riattivato; il termine corrente è facility
PKG-FAC-18  sintassi esatta di facility/dependency, policy fra provider equivalenti e rappresentazione fisica del resolved binding restano aperte
```