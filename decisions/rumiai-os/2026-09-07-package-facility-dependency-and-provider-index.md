# Decisione — Facility, dependency, provider index e resolved binding del package manager

Date: 2026-09-07  
Updated: 2026-09-07  
Status: **Accepted**

## Contesto

Il modello package corrente ha fissato:

- concrete package identity platform-independent `<pkg>@<version>` e target-specific `<pkg>@<version>!<osarch>`;
- selector `current` platform-independent `<pkg>` e target-specific `<pkg>!<osarch>`;
- package installati il più autosufficienti possibile e normale launch senza dipendenza dal comando `pkg`;
- `<package-version>/env` come frammento shell POSIX version-specific gestito/materializzato da `pkg install`;
- `cmd/<pkg-command>` come sede della logica di launch specifica del command;
- `link/<pkg-command>`, quando presente, come symlink relativo esclusivamente verso `root/` dello stesso package concreto;
- `data/sys/<component>/` come namespace di state/data dei componenti del sistema base RumiAI;
- il precedente resolver universale basato su Execution Capability contracts, release-order, provider ranking e Resolved Dependency Graph come design storico non appartenente alla baseline corrente.

Resta necessario permettere a un package di dipendere da una funzione/runtime/interfaccia compatibile senza legarsi semanticamente a una specifica versione upstream, al selector `current` di un altro package o a uno specifico provider quando il requisito reale è una compatibilità astratta.

La presente decisione fissa il modello corrente basato su `facility`, `provider`, `dependency`, compatibility numerica, provider index derivato, resolution esplicita da parte di `pkg` e resolved binding package-local consumato senza resolution durante il launch.

La correzione del 2026-09-07 sulle concrete identity target-independent viene propagata qui al provider index e ai resolved binding: un provider concreto può essere qualificato o non qualificato secondo il package da cui deriva.

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

Il termine `Capability` non viene usato per questo modello package-manager. Le precedenti `Execution Capability` dei draft del 2026-08-30 restano storiche e non vengono riattivate.

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

## 3. Versione upstream, target qualification e compatibility

La versione upstream del package è codificata nella concrete identity:

```text
platform-independent:
    <pkg>@<version>

target-specific:
    <pkg>@<version>!<osarch>
```

La compatibility version di una facility è invece un valore separato dichiarato dal provider.

Esempi concettuali:

```text
package concreto platform-independent:
    generic-tool@1.4

facility offerta:
    example-api

compatibility:
    3
```

```text
package concreto target-specific:
    temurin@21.0.8+9!macos-arm64

facility offerta:
    java

compatibility:
    21
```

Quindi la versione upstream, l'eventuale qualificazione target e la compatibility sono dimensioni distinte.

Non viene introdotto un comparatore universale delle versioni upstream.

---

## 4. File package-local `facility`

Una versione concreta che offre una o più facility può contenere il file opzionale:

```text
<package-version>/facility
```

Il file appartiene al packaging RumiAI ed è gestito/materializzato da `pkg install`.

Semanticamente dichiara per ogni facility almeno:

```text
facility
compatibility
```

Esempio concettuale non normativo per la serializzazione:

```text
java 21
```

Una singola versione concreta può offrire più facility quando ciò corrisponde realmente alle sue interfacce utilizzabili.

Il file `facility` è la dichiarazione package-local autorevole. Il provider index è un indice derivato e non la sostituisce.

La sintassi testuale esatta del file resta da fissare separatamente.

---

## 5. File package-local `dependency`

Una versione concreta che richiede una o più facility può contenere il file opzionale:

```text
<package-version>/dependency
```

Semanticamente dichiara, per ogni dependency, almeno:

```text
facility
compatibility constraint
```

Esempi concettuali non normativi per la serializzazione:

```text
java >=17 <22
python >=3.11 <3.14
```

Il file dichiara requisiti astratti e non sostituisce tali requisiti con il provider concreto risolto.

Nel baseline una versione concreta può dichiarare al massimo una dependency per ciascuna facility.

Non è quindi ammessa nel resolver generico una forma equivalente a:

```text
java >=17 <22
java =8
```

nello stesso consumer per ottenere due provider distinti della stessa facility.

Casi che richiedono più provider della stessa facility restano responsabilità esplicita del particolare package/configurazione e non introducono slot o multi-binding nel modello comune.

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

Più comparator riferiti alla stessa dependency rappresentano l'intersezione dei vincoli.

Esempio:

```text
java >=17 <22
```

Non vengono fissati nel baseline:

```text
OR
!=
wildcard
caret
tilde
constraint sulla versione upstream
```

La grammatica lessicale e le regole esatte di confronto delle compatibility numeriche multi-componente saranno fissate insieme alla serializzazione di `facility` e `dependency`.

---

## 7. Provider index del componente base `pkg`

Le facility offerte dalle versioni concrete installate vengono indicizzate sotto:

```text
$m_ROOT/data/sys/pkg/providers/<facility>/<compatibility>/
```

Per ogni facility dichiarata da una concrete version, `pkg` crea un file regolare vuoto il cui nome è esattamente la concrete package identity del provider.

Forme ammesse:

```text
platform-independent:
    $m_ROOT/data/sys/pkg/providers/<facility>/<compatibility>/<pkg>@<version>

target-specific:
    $m_ROOT/data/sys/pkg/providers/<facility>/<compatibility>/<pkg>@<version>!<osarch>
```

Esempi:

```text
$m_ROOT/data/sys/pkg/providers/example-api/3/
└── generic-tool@1.4
```

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

Il pathname del package corrispondente si ricostruisce direttamente come:

```text
$m_ROOT/pkg/<provider-basename>
```

senza `readlink`, `realpath` o altra risoluzione necessaria a recuperare l'identità.

Il provider index appartiene a `data/sys/pkg/`, non allo state del package consumer, ed è derivato dalle dichiarazioni package-local `facility`.

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

Il provider index non è un meccanismo di launch e non viene consultato dal launcher per effettuare resolution a ogni esecuzione.

---

## 9. Resolution e target eligibility

La resolution appartiene a `pkg` e avviene durante operazioni esplicite che richiedono la scelta o il riallineamento delle dependency.

Per una dependency, `pkg` considera provider che:

```text
offrono la stessa facility
hanno compatibility che soddisfa tutti i comparator del requirement
sono utilizzabili per il target/materialization class del consumer
```

Le regole di target eligibility sono:

```text
provider non qualificato <pkg>@<version>
    -> provider target-independent
    -> può soddisfare un consumer target-specific o target-independent, se facility/compatibility coincidono

provider qualificato <pkg>@<version>!<osarch>
    -> può soddisfare soltanto resolution per lo stesso <osarch>
```

Inoltre:

```text
consumer concreto non qualificato
    -> può materializzare soltanto binding verso provider non qualificati
```

perché un binding verso un provider specifico di un singolo target renderebbe target-specific l'intero consumer. Se una dependency richiede un provider qualificato, il consumer deve essere materializzato attraverso il relativo `catalog-<osarch>` e usare concrete identity qualificata.

Un consumer target-specific può invece essere legato sia a un provider non qualificato sia a un provider qualificato per lo stesso target.

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

`binding/<facility>` è un file regolare di dati, non un symbolic link e non shell code.

Il suo unico contenuto logico è il basename della concrete package identity del provider risolto, quindi una delle forme:

```text
<pkg>@<version>
<pkg>@<version>!<osarch>
```

La serializzazione canonica resta una singola riga terminata da newline:

```text
<provider-basename>\n
```

Esempi:

```text
binding/example-api:
    generic-tool@1.4
```

```text
binding/java:
    temurin@21.0.8+9!macos-arm64
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

La facility è già identificata dal nome del file e il provider concreto dal contenuto.

La regola di una sola dependency per facility rende univoco:

```text
dependency <facility>
    -> binding/<facility>
    -> un provider concreto
```

La directory storica `dep/` e i relativi symlink dependency restano esclusi.

---

## 11. Consumo del binding da `env`

`<package-version>/env` resta la sede naturale per trasformare il provider risolto nelle variabili/path richieste dal consumer.

L'`env` non dipende dalla current working directory per trovare `binding/` e può derivare il package directory dal pathname canonico `m_COMMAND_BIN` secondo la struttura:

```text
<package-version>/cmd/<pkg-command>
```

Esempio concettuale POSIX:

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

Lo stesso codice funziona con basename qualificati e non qualificati perché `binding/<facility>` conserva direttamente la concrete identity e `$m_ROOT/pkg/$java_binding` ne ricostruisce il pathname.

Un binding richiesto che non può essere letto/applicato correttamente deve impedire il normale launch secondo il contratto dell'`env` fallito.

---

## 12. Re-resolution

La dependency resta astratta e invariata durante una normale re-resolution.

Se `pkg` seleziona un provider concreto differente, modifica soltanto:

```text
binding/<facility>
```

La re-resolution deve continuare a rispettare le regole di target eligibility della sezione 9; non può trasformare silenziosamente un consumer non qualificato in un oggetto target-specific attraverso un binding qualificato.

Il normale riallineamento del provider non richiede di riscrivere il requirement `dependency`, la logica `env` o il command entry `cmd/` soltanto per cambiare l'identità concreta selezionata.

Transaction/atomic-replacement semantics generali restano da definire quando il lifecycle operativo le richiederà.

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

Il provider index sotto `data/sys/pkg/providers/` non diventa quindi un resolver implicito consultato a ogni esecuzione.

Questo preserva il principio secondo cui un package installato è il più autosufficiente possibile.

---

## 14. Relazione con `env`, `cmd/` e `link/`

Le dependency possono servire a costruire l'environment o una launch line specifica del consumer.

`<package-version>/env` resta la sede della preparazione environment version-specific e può leggere `binding/<facility>`.

`cmd/<pkg-command>` resta la sede della launch line command-specific.

`link/<pkg-command>`, quando presente, resta esclusivamente un symlink relativo verso `root/` della stessa versione concreta dello stesso package e non può puntare a un provider dependency.

Il resolved binding non modifica quindi la semantica di `link/` e non introduce binding cross-package tramite symlink package-local.

---

## 15. Relazione con il design storico 2026-08-30

I draft storici avevano introdotto `Execution Capability`, contract version, compatibility version, resource contract, provider ranking, `release-order`, exact binding e Resolved Dependency Graph.

Questa decisione recupera soltanto:

```text
versione upstream != compatibility
requirement != resolved binding
provider compatibile scelto durante resolution
execution senza re-resolution
```

Non riattiva automaticamente gli altri meccanismi storici.

Il termine package-manager `Execution Capability` è sostituito nel modello corrente da `facility` e non deve essere riproposto come alias.

L'ordinale `nNNNN` del package-definition catalog non è una reintroduzione delle `generations`: ordina esclusivamente i range delle definition e non interviene nella scelta fra provider facility.

---

## 16. Supersession e precisazioni

Questa decisione supersede/precisa la sezione dependency di `2026-09-05-package-manager-current-and-run-model.md` nella misura già fissata dal modello facility corrente.

Rispetto alla prima versione di questa decisione del 2026-09-07, sono inoltre superseded le sole assunzioni secondo cui:

```text
ogni provider marker deve chiamarsi <pkg>@<version>!<osarch>
ogni binding/<facility> deve contenere <pkg>@<version>!<osarch>
una concrete package identity è sempre qualificata da osarch
```

Restano superseded:

```text
provider index basato su symbolic link
forma provider entry diversa dalla concrete identity
resolved binding lasciato implicitamente aperto
più dependency della stessa facility nel baseline
Execution Capability model storico
```

---

## 17. Implementazione e test

Alla data di questa decisione il modello non è ancora implementato in `rumiai-os` e non esistono test permanenti `pkg`/facility/dependency/binding in `rumiai-tests`.

L'implementazione prodotto richiede una fase successiva esplicitamente autorizzata.

Quando implementato, il contratto dovrà essere protetto almeno per:

```text
provider marker non qualificato per provider target-independent
provider marker qualificato per provider target-specific
marker regolare di lunghezza zero e non symlink
rimozione marker e cleanup directory compatibility
matching facility exact
matching comparator supportati
separazione versione upstream / compatibility
rifiuto dependency duplicate per la stessa facility
materializzazione binding/<facility> con provider basename qualificato o non qualificato
consumer non qualificato -> solo provider non qualificato
consumer qualificato -> provider non qualificato oppure qualificato per lo stesso target
rifiuto provider qualificato per target diverso
contenuto binding limitato alla concrete identity risolta
consumo binding senza dipendenza dalla cwd
re-resolution senza cambiare requirement
nessuna resolution durante normale launch
nessun uso cross-package di link/
relocatability
```

Questa correzione documentale non dichiara physical validation del futuro resolver.

---

## 18. Invarianti fissati

```text
PKG-FAC-01  il package manager usa facility, non capability, per la funzionalità astratta fornita/richiesta fra package
PKG-FAC-02  provider = concrete version di package che offre una facility con una compatibility
PKG-FAC-03  <package-version>/facility è il file package-local opzionale e autorevole che dichiara le facility offerte
PKG-FAC-04  <package-version>/dependency è il file package-local opzionale che dichiara dependency astratte
PKG-FAC-05  dependency = facility + compatibility constraint
PKG-FAC-06  versione upstream, eventuale target qualification e compatibility sono identità distinte
PKG-FAC-07  comparator compatibility ammessi =, >, >=, <, <=
PKG-FAC-08  più comparator della stessa dependency sono congiunti per intersezione
PKG-FAC-09  nel baseline una versione concreta dichiara al massimo una dependency per facility
PKG-FAC-10  provider index = $m_ROOT/data/sys/pkg/providers/<facility>/<compatibility>/
PKG-FAC-11  ogni provider è un marker regolare vuoto chiamato con la concrete identity: <pkg>@<version> oppure <pkg>@<version>!<osarch>
PKG-FAC-12  il provider marker non è un symlink e l'identità concreta si ricava direttamente dal basename
PKG-FAC-13  provider index è derivato dai file package-local facility
PKG-FAC-14  la directory compatibility viene rimossa quando perde l'ultimo provider marker
PKG-FAC-15  resolution = scelta esplicita da parte di pkg di un provider compatibile
PKG-FAC-16  resolved binding è concreto ma semanticamente distinto dalla dependency
PKG-FAC-17  resolved binding vive in <package-version>/binding/<facility>
PKG-FAC-18  binding/<facility> è un file regolare dati con unica riga <pkg>@<version> oppure <pkg>@<version>!<osarch> del provider risolto
PKG-FAC-19  binding non contiene path assoluti, $m_ROOT, constraint, compatibility o selector current
PKG-FAC-20  env deriva il package directory da m_COMMAND_BIN e può leggere binding/<facility> con primitive POSIX
PKG-FAC-21  provider non qualificato è target-independent; provider qualificato è eleggibile solo per lo stesso osarch
PKG-FAC-22  consumer concreto non qualificato può avere soltanto binding verso provider non qualificati
PKG-FAC-23  consumer target-specific può usare provider non qualificati o provider qualificati per lo stesso target
PKG-FAC-24  normale launch non effettua provider discovery, compatibility matching o resolution
PKG-FAC-25  launcher non invoca pkg per risolvere dependency
PKG-FAC-26  link/<pkg-command> non viene usato come binding cross-package verso provider dependency
PKG-FAC-27  directory package-local dep/ e relativi symlink dependency non appartengono al modello corrente
PKG-FAC-28  re-resolution cambia il binding concreto senza cambiare automaticamente dependency/env/cmd e senza violare target eligibility
PKG-FAC-29  casi che richiedono più provider della stessa facility sono fuori dal resolver generico baseline
PKG-FAC-30  il vecchio Execution Capability model non viene riattivato; nNNNN del catalogo non è una generation del resolver
PKG-FAC-31  restano aperte sintassi esatta di facility/dependency, grammatica compatibility multi-componente e policy fra provider equivalenti
```
