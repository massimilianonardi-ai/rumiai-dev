# RumiAI package manager — Package Instance internal layout

Data: 2026-08-30

Stato: **design draft — passo successivo al local package/command layout**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-v0/README.md
drafts/rumiai-os/package-manager-local-layout/README.md
```

Questo documento resta sul lato locale del confine già fissato: il payload eseguibile è già stato prodotto/acquisito ed è candidato alla materializzazione come Package Instance locale.

---

# 1. Package Instance != payload vendor

Una **Package Instance** è il contenitore locale gestito da RumiAI.

Il payload prodotto dal vendor/build system è una sua parte, ma non coincide con la Package Instance.

Forma minima proposta:

```text
pkg/<package-instance-id>/
├── payload/
│   └── <tree del software>
└── @package
    <descriptor dichiarativo RumiAI>
```

Esempio:

```text
pkg/pulsar@1.130.0@r1@jvm-any/
├── payload/
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

# 2. `payload/`: software già prodotto

`payload/` contiene il software che RumiAI deve rendere disponibile.

Principio:

> l'integrazione non modifica il payload.

Il package manager non deve inserire nel tree vendor:

```text
metadata RumiAI
link di integrazione
configurazione runtime dell'utente
receipt mutabili
indici
stato applicativo
```

Se un software deve essere patchato, rilocato internamente, riscritto o trasformato per diventare ammissibile, tale trasformazione appartiene al lato di produzione/acquisizione posto prima del confine corrente. Il risultato trasformato arriva al package manager come nuovo payload candidato, eventualmente con una nuova `revision` RumiAI.

Questo mantiene il confine:

```text
produzione / adattamento del software
        ↓
payload pronto
════════ CONFINE ════════
Package Instance locale
        ↓
integrazione / utilizzo / rimozione
```

---

# 3. `@package`: descriptor RumiAI

`@package` è il descriptor dichiarativo della Package Instance.

È separato dal payload e non viene eseguito tramite `source`, `eval` o meccanismi equivalenti.

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

# 4. Perché un singolo descriptor iniziale

Nel v0 non viene introdotto preventivamente un intero albero metadata.

Forma iniziale:

```text
@package
```

anziché:

```text
@meta/
├── identity
├── interface
├── dependencies
├── integrity
└── ...
```

Motivazione:

- meno namespace e file speciali;
- più semplice da verificare e recuperare;
- il formato logico può essere strutturato internamente senza imporre subito una struttura filesystem;
- se in futuro emergerà una reale necessità di più file, il metadata namespace potrà evolvere senza toccare `payload/`.

`@package` è un nome riservato all'interno della Package Instance wrapper; non può collidere con file vendor perché il vendor tree vive esclusivamente sotto `payload/`.

---

# 5. Immutabilità della Package Instance

Dopo il commit locale, una Package Instance deve essere trattata come immutabile nel suo insieme:

```text
package-instance-id/
├── payload/   immutable
└── @package   immutable
```

Non soltanto il payload, ma anche il descriptor appartiene all'identità concreta della Package Instance.

Se cambiano metadata che alterano il significato operativo del package, per esempio:

```text
Execution Requirements
Package Interface
entrypoint
state compatibility
```

non si riscrive silenziosamente `@package` dentro un'istanza esistente: si produce una nuova `revision` della Package Instance.

Questo mantiene stabile il significato di una identity come:

```text
foo@1.2.3@r2@linux-arm64
```

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

Questi appartengono ad altri domini già separati concettualmente:

```text
Package Instance
State Instance
Integration Profile / resolved integration state
runtime/transient state
```

La rimozione della Package Instance non deve quindi implicare automaticamente la distruzione dello stato persistente.

---

# 7. Relocatability

Tutti i riferimenti interni del descriptor verso il payload devono essere relativi alla Package Instance o a `payload/`.

Esempio concettuale:

```text
command java -> payload/bin/java
entrypoint   -> payload/app.jar
```

Il descriptor non deve incorporare il pathname assoluto della root RumiAI o della Package Instance.

La stessa directory deve poter essere spostata insieme all'environment senza riscrittura dei metadata.

Analogamente, l'integrazione deve referenziare la Package Instance tramite identity/path risolvibile localmente, non tramite pathname assoluti persistiti come parte del package.

---

# 8. Symlink e riferimenti dal payload

Nel v0 il payload non deve dipendere da link o riferimenti filesystem creati durante l'integrazione per completare il proprio tree interno.

I link interni già appartenenti al payload possono essere conservati se compatibili con il requisito di relocatability.

Un payload che richiede necessariamente symlink assoluti verso directory host/globali non soddisfa il contratto v0.

Le dipendenze verso altre Package Instance devono essere rappresentate come Execution Dependency e risolte dall'Execution Environment, non saldate fisicamente dentro `payload/` durante l'installazione.

---

# 9. Materializzazione transazionale

Una Package Instance non dovrebbe apparire sotto `pkg/` in stato parzialmente costruito.

Flusso concettuale:

```text
candidate payload
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

Lo staging NON dovrebbe usare una child directory ordinaria di `pkg/`, perché l'invariante anti-ghost stabilisce che ogni child immediata di `pkg/` rappresenta qualcosa che il package manager deve classificare come presenza fisica.

Quindi gli stati intermedi appartengono a un'area temporanea/transazionale separata, da definire successivamente.

Dopo il commit:

```text
pkg/<id>/
```

rappresenta una Package Instance locale completa o un'anomalia rilevabile, mai intenzionalmente un'installazione in corso.

---

# 10. Recovery

Se `@package` viene perso o corrotto:

```text
pkg/foo@1.2.3@r1@linux-arm64/
├── payload/
└── @package   missing/corrupt
```

il pathname permette comunque di ricostruire l'identità minima e classificare l'istanza come `RECOVERABLE` secondo il local layout.

Il payload non viene ignorato né trattato come package inesistente.

Il recovery dei metadata completi può in futuro usare:

```text
rumiai-store / source metadata
cache locale
receipt/provenance esterna
ricostruzione manuale/verificata
```

ma questi meccanismi sono fuori dalla decisione attuale.

---

# 11. Uninstall

L'uninstall della Package Instance deve poter essere concettualmente semplice:

```text
1. verificare che nessun integration/dependency state ne richieda ancora la presenza
2. rimuovere/deintegrare i binding derivati che la referenziano quando richiesto
3. rimuovere l'intera directory pkg/<package-instance-id>/
```

Non deve eseguire un uninstaller vendor e non deve cercare file appartenenti al package sparsi nella root RumiAI.

La struttura wrapper rende la proprietà fisica chiara:

```text
Package Instance physical ownership
    = esattamente una directory immediata sotto pkg/
```

Lo stato persistente resta separato e non viene cancellato implicitamente.

---

# 12. Conseguenze per l'integrità

Il digest/contenuto verificato dovrebbe distinguere almeno:

```text
payload identity/integrity
Package Instance metadata identity/integrity
```

Non viene ancora fissato come calcolare un digest di directory portabile tra filesystem differenti.

Principio già utile:

> modificare `payload/` o modificare semanticamente `@package` significa modificare la Package Instance.

Il pathname non contiene il digest; il digest resta metadata di verifica.

---

# 13. Invarianti candidate

```text
PI-01 Package Instance != payload vendor

PI-02 ogni Package Instance locale è una singola child directory immediata di pkg/

PI-03 il software prodotto vive esclusivamente sotto payload/

PI-04 l'integrazione non modifica payload/

PI-05 @package è descriptor dichiarativo RumiAI e non codice eseguibile

PI-06 pathname e @package ripetono l'identità minima e devono concordare

PI-07 payload/ e @package sono immutabili dopo il commit della Package Instance

PI-08 una modifica semantica del packaging produce una nuova revision, non una mutazione in-place

PI-09 stato mutabile, integration state e runtime state non vivono nella Package Instance

PI-10 descriptor e riferimenti interni sono relocatable e non dipendono da pathname assoluti persistiti

PI-11 dependency package-to-package non vengono cablate dentro payload/ tramite install-time mutation

PI-12 una Package Instance appare sotto pkg/ soltanto dopo il commit della materializzazione

PI-13 staging/transazioni non usano child directory ordinarie di pkg/

PI-14 @package mancante non rende invisibile il payload: l'identity minima resta recuperabile dal pathname

PI-15 uninstall fisico della Package Instance equivale alla rimozione della sua unica directory pkg/<id>, dopo aver rispettato dependency/integration constraints
```

---

# 14. Questioni successive

Questo draft non decide ancora:

- formato e sintassi di `@package`;
- schema/versioning del descriptor;
- come rappresentare Package Interface e resource exports;
- come rappresentare Execution Requirement / dependency slot;
- algoritmo di integrity/digest per payload directory;
- location concreta dell'area staging/transazionale;
- permessi/ownership filesystem canonici;
- gestione di payload costituiti da un singolo file;
- eventuali package che richiedono una struttura speciale come macOS `.app` bundle;
- forma concreta delle Launch Specification e dei binding in `bin/`.

Il passo successivo naturale è definire il **modello logico minimo di `@package`**, senza ancora scegliere una sintassi serializzata definitiva.