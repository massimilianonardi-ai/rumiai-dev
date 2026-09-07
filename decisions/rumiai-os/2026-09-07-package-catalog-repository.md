# Decisione — Repository concreto del package-definition catalog

Date: 2026-09-07  
Status: **Accepted**

## Contesto

La decisione `2026-09-07-package-definition-catalog-and-version-ranges.md` ha fissato che le package definition di RumiAI appartengono a un repository GitHub RumiAI dedicato, lasciando ancora aperti il nome e il repository concreto.

Il repository è stato ora creato esplicitamente dall'utente con nome:

```text
pkg-catalog
```

Il repository GitHub concreto è:

```text
massimilianonardi-ai/pkg-catalog
```

Alla data di questa decisione il repository è vuoto e non possiede ancora un commit/HEAD. Il suo stato iniziale non autorizza la creazione di placeholder, README, directory o altri file prima che i relativi contratti siano fissati.

Questa unità modifica soltanto `rumiai-dev`. Non modifica `pkg-catalog`, `rumiai-os` o `rumiai-tests`.

---

## 1. Ruolo di `pkg-catalog`

`pkg-catalog` è il repository RumiAI dedicato alle **package definition concrete** consumate dal package manager.

Contiene il catalogo conforme ai contratti definiti in `rumiai-dev`, inclusi quando materializzati:

```text
<pkg>/
    catalog/
    catalog-<osarch>/
```

con i rispettivi descriptor `repository` e range `nNNNN=<version-minimum>` secondo le decisioni correnti.

`pkg-catalog` non è un repository di artifact o payload software upstream.

---

## 2. Confine di autorità

`rumiai-dev` resta la fonte autorevole per:

```text
architettura del package manager
schema e semantica del catalogo
naming e filesystem contract
API repository
regole di range/version resolution
workflow e decisioni di sviluppo
```

`pkg-catalog` è invece la fonte autorevole per le **istanze concrete delle package definition** pubblicate secondo tali contratti.

Di conseguenza una package definition presente in `pkg-catalog` non può modificare implicitamente il contratto del catalogo. Se emerge la necessità di un nuovo campo, primitive, layout o semantica, il relativo contratto deve essere prima fissato in `rumiai-dev` secondo il workflow RumiAI.

---

## 3. Identità del repository

L'identità canonica del repository catalogo è:

```text
massimilianonardi-ai/pkg-catalog
```

Il punto precedentemente aperto:

```text
nome/URL concreto del repository
```

in `2026-09-07-package-definition-catalog-and-version-ranges.md` è quindi chiuso da questa decisione.

La scelta del protocollo operativo di clone/fetch e la relativa configurazione runtime non vengono dedotte dal clone URL GitHub e restano contratti separati.

Restano quindi ancora aperti:

```text
chiave/file di configurazione locale, se necessario
meccanismo di clone/fetch/cache/snapshot
policy di aggiornamento
pinning/snapshot usato da una singola operazione pkg
```

---

## 4. Stato iniziale vuoto

Il repository è stato verificato come Git repository vuoto: il default branch configurato è `main`, ma non esiste ancora un ref/HEAD finché non viene creato il primo commit.

Non viene creato un commit artificiale soltanto per inizializzare il repository.

Il primo commit di `pkg-catalog` deve essere prodotto quando esiste contenuto reale conforme ai contratti correnti, a partire dalla serializzazione concreta di:

```text
<stream>/repository
<stream>/nNNNN=<version-minimum>/
```

Non vengono anticipati ora nomi di file, formati o descriptor non ancora fissati.

---

## 5. Relazione con Git e provenance

Quando `pkg-catalog` possiederà commit, il commit Git continuerà a identificare lo snapshot esatto delle package definition usato da `pkg`.

Non viene introdotta una numerazione RumiAI separata per revisionare il catalogo.

Il repository segue il principio Git forward-only generale di RumiAI: la storia non deve essere riscritta o force-pushata salvo istruzione esplicita dell'utente.

---

## 6. Implementazione e test

Questa decisione assegna soltanto il repository concreto e il confine di autorità.

Non introduce ancora:

```text
file nel repository pkg-catalog
serializzazione del descriptor repository
serializzazione della range definition
backend di sync/cache
modifiche a rumiai-os
nuovi test permanenti
```

Non richiede physical validation separata.

---

## 7. Invarianti fissati

```text
PKG-CATALOG-REPO-01  il repository concreto delle package definition è massimilianonardi-ai/pkg-catalog
PKG-CATALOG-REPO-02  pkg-catalog contiene package definition concrete e non artifact/payload upstream
PKG-CATALOG-REPO-03  rumiai-dev resta autorità per schema, semantica e regole del catalogo
PKG-CATALOG-REPO-04  pkg-catalog è autorità per le istanze concrete delle package definition conformi ai contratti rumiai-dev
PKG-CATALOG-REPO-05  una definition concreta non può introdurre implicitamente nuove primitive o semantiche del catalogo
PKG-CATALOG-REPO-06  il precedente punto aperto sul nome/repository concreto del catalogo è chiuso
PKG-CATALOG-REPO-07  protocollo clone/fetch, cache, snapshot e policy di aggiornamento restano separati e non sono dedotti dal repository GitHub
PKG-CATALOG-REPO-08  il repository resta vuoto finché non esiste contenuto reale conforme alla serializzazione fissata
PKG-CATALOG-REPO-09  il primo commit non deve inventare placeholder o formati non ancora approvati
PKG-CATALOG-REPO-10  quando esisteranno commit, il commit Git identifica lo snapshot naturale del catalogo
```