# Decisione — Facility, dependency, provider index e resolved binding del package manager

Date: 2026-09-07  
Updated: 2026-09-07  
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

Resta però necessario permettere a un package di dipendere da una funzione/runtime/interfaccia compatibile senza legarsi semanticamente:

- a una specifica versione upstream;
- al selector `current` di un altro package;
- a uno specifico provider quando il requisito reale è una compatibilità astratta.

La presente decisione fissa il modello corrente basato su `facility`, `provider`, `dependency`, compatibility numerica, provider index derivato, resolution esplicita da parte di `pkg` e resolved binding package-local consumato senza resolution durante il launch.

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
    temurin@21.0.8+9!macos-arm64

facility offerta:
    java

compatibility:
    21
```

Quindi:

```text
21.0.8+9
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

Il file `facility` è la dichiarazione package-local autorevole delle facility offerte dalla versione concreta. Il provider index descritto sotto è un indice derivato da queste dichiarazioni e non le sostituisce.

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

Nel baseline corrente una versione concreta può dichiarare **al massimo una dependency per ciascuna facility**.

Quindi non è ammessa nel modello generico una forma equivalente a:

```text
java >=17 <22
java =8
```

nello stesso consumer per ottenere due provider distinti della stessa facility.

Se un particolare package necessita realmente di più istanze/provider della stessa facility, tale requisito resta fuori dal resolver generico corrente e deve essere gestito esplicitamente dal package stesso e/o dalla relativa configurazione `env`/command-specific, senza introdurre implicitamente slot o multi-binding nel modello comune.

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

Per ogni facility dichiarata da una versione concreta, `pkg` materializza nella corrispondente directory un **file regolare vuoto** il cui nome è esattamente l'identità concreta del provider:

```text
$m_ROOT/data/sys/pkg/providers/<facility>/<compatibility>/<pkg>@<version>!<osarch>
```

Esempio:

```text
$m_ROOT/data/sys/pkg/providers/java/21/
└── temurin@21.0.8+9!macos-arm64
```

L'entry provider:

- è un file regolare;
- ha lunghezza zero;
- non è un symbolic link;
- non contiene metadata duplicati;
- identifica il provider esclusivamente tramite il proprio basename concreto.

Il pathname concreto del package corrispondente si ricostruisce direttamente come:

```text
$m_ROOT/pkg/<provider-basename>
```

Non è quindi necessario eseguire `readlink`, `realpath`, `readpathce` o altra risoluzione di pathname per ricavare l'identità del provider dall'indice.

La struttura appartiene a:

```text
$m_ROOT/data/sys/pkg/
```

perché è data del componente base `pkg`, coerentemente con il namespace system state già fissato:

```text
$m_ROOT/<area>/sys/<component>/
```

Il provider index non introduce state di package sotto `data/<pkg>` e non è una Package State Instance.

Il provider index è **derivato** dalle dichiarazioni `<package-version>/facility`: i marker vuoti sono un indice di discovery/resolution, non una seconda sorgente autorevole della facility dichiarata.

---

## 8. Lifecycle del provider index

`pkg` aggiorna il provider index quando una versione concreta che dichiara facility viene installata, rimossa o altrimenti cessa di essere un provider disponibile.

Per ogni facility offerta:

```text
install/provider admission
    -> crea il marker regolare vuoto del provider

remove/provider withdrawal
    -> rimuove il marker del provider
```

Quando viene rimosso l'ultimo marker dalla directory:

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

L'insieme dei provider candidati è enumerabile direttamente attraverso i marker sotto:

```text
$m_ROOT/data/sys/pkg/providers/<facility>/<compatibility>/
```

senza dereferenziare symlink per recuperare l'identità concreta.

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

## 10. Directory package-local `binding/`

Il risultato concreto della resolution viene materializzato sotto la versione consumer nella directory opzionale:

```text
<package-version>/binding/
```

Per ogni dependency risolta esiste esattamente:

```text
<package-version>/binding/<facility>
```

Il nome del file è quindi la stessa facility dichiarata nel file `dependency`.

Esempio:

```text
<consumer-package-version>/dependency
    java >=17 <22

<consumer-package-version>/binding/java
    temurin@21.0.8+9!macos-arm64
```

`binding/<facility>` è un **file regolare di dati**, non un symbolic link e non shell code.

Il suo unico contenuto logico è il basename della versione concreta del provider risolto:

```text
<pkg>@<version>!<osarch>
```

La serializzazione canonica del file è una singola riga terminata da newline:

```text
<provider-basename>\n
```

Non contiene:

```text
$m_ROOT
pathname assoluti
constraint
compatibility duplicata
facility duplicata
shell assignment
selector current
```

La facility è già identificata dal nome del file e il provider concreto è già identificato dal contenuto.

La regola baseline di una sola dependency per facility rende univoco il mapping:

```text
dependency <facility>
    -> binding/<facility>
    -> un provider concreto
```

La directory storicamente proposta `dep/` e i relativi symlink dependency restano esclusi.

---

## 11. Consumo del binding da `env`

`<package-version>/env` resta la sede naturale per trasformare il provider risolto nelle variabili/path richieste dal particolare consumer.

L'`env` non deve dipendere dalla current working directory per trovare `binding/`.

Quando necessita del package directory corrente, lo deriva dal pathname canonico già disponibile:

```text
m_COMMAND_BIN
```

secondo la struttura:

```text
<package-version>/cmd/<pkg-command>
```

Esempio concettuale POSIX per una dependency `java`:

```sh
package_dir=${m_COMMAND_BIN%/*}
package_dir=${package_dir%/*}

java_binding=$(cat "$package_dir/binding/java") || return 1
java_provider="$m_ROOT/pkg/$java_binding"

JAVA_HOME="$java_provider/root"
PATH="$JAVA_HOME/bin:$PATH"
export JAVA_HOME PATH

unset package_dir java_binding java_provider
```

Il command substitution rimuove il newline terminale canonico del file `binding/java`; il basename concreto non può contenere newline secondo la grammatica package-store già fissata.

L'esempio non introduce una nuova primitive runtime: usa direttamente il file dati materializzato da `pkg`, `m_COMMAND_BIN`, `$m_ROOT` e normali primitive shell POSIX già ammesse nel file `env`.

Un binding richiesto che non può essere letto/applicato correttamente deve impedire il normale launch secondo il contratto già fissato per un package `env` fallito. I codici di errore finali restano parte della futura implementazione del launcher/pkg.

---

## 12. Re-resolution

La dependency resta astratta e invariata durante una normale re-resolution:

```text
dependency/java requirement
    invariato
```

Se `pkg` seleziona un provider concreto differente, modifica il solo resolved binding pertinente:

```text
binding/<facility>
```

Esempio:

```text
prima:
    binding/java = temurin@21.0.8+9!macos-arm64

dopo explicit re-resolution:
    binding/java = altro-jdk@21.0.9+10!macos-arm64
```

Il normale riallineamento del provider non richiede di riscrivere il requirement `dependency`, la logica shell di `env` o il command entry `cmd/` soltanto per cambiare l'identità concreta selezionata.

Questa decisione non fissa ancora transaction/atomic-replacement semantics generali per le operazioni `pkg`; tali proprietà verranno definite quando il lifecycle operativo le richiederà.

---

## 13. Launch

Il normale launch non esegue resolution.

Regola:

```text
pkg operation
    -> discover compatible providers through provider index
    -> resolve dependency
    -> materialize binding/<facility>

normal launch
    -> consume binding/<facility>
    -> no provider search
    -> no compatibility comparison
    -> no pkg invocation
```

Il provider index sotto `data/sys/pkg/providers/` non deve quindi diventare un resolver implicito consultato ad ogni esecuzione.

Questo preserva il principio corrente secondo cui un package installato è il più autosufficiente possibile e il normale runtime non dipende dal comando `pkg`.

---

## 14. Relazione con `env`, `cmd/` e `link/`

Le dependency possono servire a costruire l'environment o una launch line specifica del consumer.

`<package-version>/env` resta la sede della preparazione environment version-specific del consumer e può leggere `binding/<facility>` quando deve configurare un provider risolto.

`cmd/<pkg-command>` resta la sede della launch line command-specific.

`link/<pkg-command>`, quando presente, resta esclusivamente un symlink relativo verso `root/` della stessa versione concreta dello stesso package e non può puntare a un provider dependency.

Il resolved binding non modifica quindi la semantica di `link/` e non introduce binding cross-package tramite symlink package-local.

---

## 15. Relazione con il design storico 2026-08-30

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

## 16. Supersession e precisazioni

Questa decisione supersede/precisa la sezione dependency di `2026-09-05-package-manager-current-and-run-model.md` nella misura in cui lasciava come unica baseline iniziale riferimenti concreti semplici e trattava un resolver più generale come interamente futuro.

Rispetto alla prima versione di questa stessa decisione del 2026-09-07, sono inoltre superseded:

```text
provider index basato su symbolic link
forma/nome provider entry lasciati aperti
rappresentazione fisica del resolved binding lasciata aperta
possibilità implicita di più dependency della stessa facility nel baseline
```

È ora fissato il modello minimo:

```text
facility
provider
compatibility
dependency constraint
provider index a marker file vuoti
resolution esplicita
binding/<facility> con provider concreto
una dependency per facility
nessuna resolution nel launch
```

Restano superseded e non vengono riaffermati i meccanismi storici più ampi elencati sopra.

---

## 17. Implementazione e test

Alla data di questa decisione il modello non è ancora implementato in `rumiai-os` e non esistono test permanenti `pkg`/facility/dependency/binding in `rumiai-tests`.

L'implementazione prodotto richiede una fase successiva esplicitamente autorizzata.

Quando implementato, il contratto dovrà essere protetto almeno per:

```text
indicizzazione provider installati per facility/compatibility
provider marker regolare di lunghezza zero con basename concreto
assenza di provider-index symlink
rimozione dell'entry provider durante uninstall/rimozione
rimozione della directory compatibility quando perde l'ultimo provider marker
matching facility exact
matching dei comparator supportati
separazione versione upstream / compatibility
rifiuto di dependency duplicate per la stessa facility nel baseline
materializzazione di binding/<facility>
contenuto binding limitato al basename concreto risolto
consumo del binding senza dipendenza dalla cwd
re-resolution che cambia il binding senza cambiare il requirement
nessuna resolution durante il normale launch
nessun uso cross-package di link/
relocatability del modello
```

---

## 18. Invarianti fissati

```text
PKG-FAC-01  il package manager usa il termine facility, non capability, per la funzionalità astratta fornita/richiesta fra package
PKG-FAC-02  provider = versione concreta di package che offre una facility con una compatibility
PKG-FAC-03  <package-version>/facility è il file package-local opzionale e autorevole che dichiara le facility offerte
PKG-FAC-04  <package-version>/dependency è il file package-local opzionale che dichiara dependency astratte
PKG-FAC-05  dependency = facility + compatibility constraint
PKG-FAC-06  versione upstream e compatibility sono identità distinte
PKG-FAC-07  i comparator compatibility ammessi sono =, >, >=, <, <=
PKG-FAC-08  più comparator della stessa dependency sono congiunti per intersezione
PKG-FAC-09  nel baseline una versione concreta dichiara al massimo una dependency per facility
PKG-FAC-10  il provider index vive sotto $m_ROOT/data/sys/pkg/providers/<facility>/<compatibility>/
PKG-FAC-11  ogni provider indicizzato è rappresentato da un file regolare vuoto chiamato <pkg>@<version>!<osarch>
PKG-FAC-12  il provider marker non è un symlink e l'identità concreta si ricava direttamente dal basename
PKG-FAC-13  il provider index è derivato dai file package-local facility e non li sostituisce come dichiarazione autorevole
PKG-FAC-14  la directory compatibility viene rimossa quando perde l'ultimo provider marker
PKG-FAC-15  resolution = scelta esplicita da parte di pkg di un provider compatibile
PKG-FAC-16  resolved binding è concreto ma semanticamente distinto dalla dependency
PKG-FAC-17  il resolved binding vive in <package-version>/binding/<facility>
PKG-FAC-18  binding/<facility> è un file regolare dati con unica riga <pkg>@<version>!<osarch> del provider risolto
PKG-FAC-19  binding non contiene path assoluti, $m_ROOT, constraint, compatibility o selector current
PKG-FAC-20  env deriva il package directory da m_COMMAND_BIN e può leggere binding/<facility> con normali primitive POSIX
PKG-FAC-21  il normale launch non effettua provider discovery, compatibility matching o resolution
PKG-FAC-22  il launcher non invoca pkg per risolvere dependency
PKG-FAC-23  link/<pkg-command> non viene usato come binding cross-package verso provider dependency
PKG-FAC-24  directory package-local dep/ e relativi symlink dependency non appartengono al modello corrente
PKG-FAC-25  re-resolution cambia il binding concreto senza cambiare automaticamente dependency/env/cmd
PKG-FAC-26  casi che richiedono più provider della stessa facility sono fuori dal resolver generico baseline e vanno gestiti esplicitamente dal package/utente
PKG-FAC-27  il vecchio package-manager Execution Capability model non viene riattivato; il termine corrente è facility
PKG-FAC-28  restano aperte la sintassi esatta di facility/dependency, la grammatica numerica multi-componente della compatibility e la policy fra provider equivalenti
```
