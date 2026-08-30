# RumiAI package manager — Package Instance internal layout

Data: 2026-08-30

Stato: **design draft — passo successivo al local package/command layout**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-v0/README.md
drafts/rumiai-os/package-manager-local-layout/README.md
```

Questo documento resta sul lato locale del confine già fissato: il software eseguibile è già stato prodotto/acquisito ed è candidato alla materializzazione come Package Instance locale.

---

# 1. Package Instance != software tree

Una **Package Instance** è il contenitore locale immutabile gestito da RumiAI.

Il software già prodotto è una sua parte, ma non coincide con la Package Instance.

Forma minima fissata:

```text
pkg/<package-instance-id>/
├── root/
│   └── <tree del software>
└── @package
    <descriptor dichiarativo RumiAI>
```

Esempio:

```text
pkg/pulsar@1.130.0@r1@jvm-any/
├── root/
│   ├── bin/
│   ├── lib/
│   └── ...
└── @package
```

Il pathname `<package-instance-id>` segue la convenzione già fissata:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

---

# 2. `root/`: root filesystem del software

`root/` contiene esclusivamente il software già prodotto che RumiAI deve rendere disponibile.

Il nome `root` indica la root filesystem del software contenuto nella Package Instance, indipendentemente dal fatto che si tratti di applicazione, runtime, libreria, script, JAR o altro.

Principio:

> l'integrazione non modifica `root/`.

Il package manager non deve inserire nel tree del software:

```text
metadata RumiAI
link di integrazione
configurazione runtime dell'utente
receipt mutabili
indici
stato applicativo
```

Se un software deve essere patchato, rilocato internamente, riscritto o trasformato per diventare ammissibile, tale trasformazione appartiene al lato di produzione/acquisizione posto prima del confine corrente. Il risultato trasformato arriva al package manager come nuovo software candidato, eventualmente con una nuova `revision` RumiAI.

Questo mantiene il confine:

```text
produzione / adattamento del software
        ↓
software pronto
════════ CONFINE ════════
Package Instance locale
        ↓
integrazione / utilizzo / rimozione
```

---

# 3. `@package`: descriptor RumiAI

`@package` è il descriptor dichiarativo della Package Instance.

È separato da `root/` e non viene eseguito tramite `source`, `eval` o meccanismi equivalenti.

Deve poter descrivere almeno, quando il modello sarà completato:

```text
identity
content/integrity
Package Interface
Execution Requirements
entrypoint/resource exports
state requirements
formato/schema del descriptor
```

I campi di identità minima sono intenzionalmente ridondanti rispetto al pathname:

```text
name
version
revision
platform
architecture
```

Regola:

```text
identity(pathname) == identity(@package)
```

Una divergenza è un errore di integrità.

Il formato concreto del descriptor NON viene ancora deciso in questo draft.

---

# 4. Un singolo descriptor iniziale

Nel v0 non viene introdotto preventivamente un intero albero metadata.

Forma iniziale:

```text
@package
```

anziché un namespace di più file.

Motivazione:

- meno namespace e file speciali;
- più semplice da verificare e recuperare;
- il formato logico può essere strutturato internamente senza imporre subito una struttura filesystem;
- se in futuro emergerà una reale necessità di più file, il metadata namespace potrà evolvere senza toccare `root/`.

`@package` è un nome riservato all'interno della Package Instance wrapper; non può collidere con file del software perché il software vive esclusivamente sotto `root/`.

---

# 5. Immutabilità della Package Instance

Dopo il commit locale, una Package Instance deve essere trattata come immutabile nel suo insieme:

```text
package-instance-id/
├── root/       immutable
└── @package    immutable
```

Se cambiano metadata che alterano il significato operativo del package, per esempio Execution Requirements, Package Interface, entrypoint o state compatibility, non si riscrive silenziosamente `@package`: si produce una nuova `revision` della Package Instance.

---

# 6. Stato mutabile escluso

Dentro una Package Instance NON devono vivere dati mutabili di utilizzo.

Sono esclusi almeno:

```text
home utente/applicazione
configurazione mutabile
data persistenti
cache runtime
log
PID
socket
temporary files
receipt di integrazione
indici del package manager
```

Questi appartengono ad altri domini:

```text
Package Instance
State Instance
Integration Profile / resolved integration state
runtime/transient state
```

La rimozione della Package Instance non deve quindi implicare automaticamente la distruzione dello stato persistente.

---

# 7. Relocatability

Tutti i riferimenti interni del descriptor verso il software devono essere relativi alla Package Instance o a `root/`.

Esempio concettuale:

```text
command java -> root/bin/java
entrypoint   -> root/app.jar
```

Il descriptor non deve incorporare il pathname assoluto della root RumiAI o della Package Instance.

La stessa directory deve poter essere spostata insieme all'environment senza riscrittura dei metadata.

---

# 8. Symlink e dipendenze

Nel v0 `root/` non deve dipendere da link o riferimenti filesystem creati durante l'integrazione per completare il proprio tree interno.

I link interni già appartenenti al software possono essere conservati se compatibili con il requisito di relocatability.

Le dipendenze verso altre Package Instance devono essere rappresentate come Execution Dependency e risolte dall'Execution Environment, non saldate fisicamente dentro `root/` durante l'installazione.

---

# 9. Materializzazione transazionale

Una Package Instance non deve apparire sotto `pkg/` in stato parzialmente costruito.

Flusso concettuale:

```text
candidate software
        ↓
validate
        ↓
build Package Instance in staging
        ↓
write @package
        ↓
verify identity / integrity / admission requirements
        ↓
atomic commit into pkg/<package-instance-id>
```

Lo staging NON usa una child directory ordinaria di `pkg/`, perché ogni child immediata di `pkg/` deve rappresentare una presenza fisica classificabile dal package manager.

---

# 10. Recovery e uninstall

Se `@package` viene perso o corrotto, il pathname permette comunque di ricostruire l'identità minima e classificare l'istanza come `RECOVERABLE`.

Se `root/` manca o è corrotto, la Package Instance resta identificabile ma è fisicamente inconsistente.

L'uninstall fisico, dopo aver rispettato dependency/integration constraints, rimuove l'intera directory:

```text
pkg/<package-instance-id>/
```

Non esegue un uninstaller vendor e non cerca file appartenenti al package sparsi nella root RumiAI.

---

# 11. Integrità

Il modello di integrità deve poter distinguere almeno:

```text
root content integrity
@package identity/integrity
```

Non viene ancora fissato come calcolare un digest di directory portabile tra filesystem differenti.

Principio:

> modificare `root/` o modificare semanticamente `@package` significa modificare la Package Instance.

Il pathname non contiene il digest; il digest resta metadata di verifica.

---

# 12. Invarianti fissate/candidate

```text
PI-01 Package Instance != software tree
PI-02 ogni Package Instance locale è una singola child directory immediata di pkg/
PI-03 il software prodotto vive esclusivamente sotto root/
PI-04 l'integrazione non modifica root/
PI-05 @package è descriptor dichiarativo RumiAI e non codice eseguibile
PI-06 pathname e @package ripetono l'identità minima e devono concordare
PI-07 root/ e @package sono immutabili dopo il commit della Package Instance
PI-08 una modifica semantica del packaging produce una nuova revision, non una mutazione in-place
PI-09 stato mutabile, integration state e runtime state non vivono nella Package Instance
PI-10 descriptor e riferimenti interni sono relocatable e non dipendono da pathname assoluti persistiti
PI-11 dependency package-to-package non vengono cablate dentro root/ tramite install-time mutation
PI-12 una Package Instance appare sotto pkg/ soltanto dopo il commit della materializzazione
PI-13 staging/transazioni non usano child directory ordinarie di pkg/
PI-14 @package mancante non rende invisibile la Package Instance
PI-15 uninstall fisico della Package Instance equivale alla rimozione della sua unica directory pkg/<id>, dopo aver rispettato dependency/integration constraints
```

---

# 13. Questioni successive

Questo draft non decide ancora:

- modello logico minimo di `@package`;
- formato e sintassi di `@package`;
- schema/versioning del descriptor;
- come rappresentare Package Interface e resource exports;
- come rappresentare Execution Requirement / dependency slot;
- algoritmo di integrity/digest per `root/`;
- location concreta dell'area staging/transazionale;
- permessi/ownership filesystem canonici;
- forma concreta delle Launch Specification e dei binding in `bin/`.

Il passo successivo naturale è definire il **modello logico minimo di `@package`**, senza ancora scegliere una sintassi serializzata definitiva.
