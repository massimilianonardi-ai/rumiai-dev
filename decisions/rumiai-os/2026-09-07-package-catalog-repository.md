# Decisione — Repository concreto del package-definition catalog

Date: 2026-09-07  
Updated: 2026-09-07  
Status: **Accepted**

## Contesto

La decisione `2026-09-07-package-definition-catalog-and-version-ranges.md` ha fissato che le package definition di RumiAI appartengono a un repository GitHub RumiAI dedicato.

Il repository è stato creato esplicitamente dall'utente con nome:

```text
pkg-catalog
```

Il repository GitHub concreto è:

```text
massimilianonardi-ai/pkg-catalog
```

Alla data di questa decisione il repository è vuoto e non possiede ancora un commit/HEAD.

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

con, per ogni stream disponibile:

```text
repository/
nNNNN=<version-minimum>/
```

`repository/` è il descriptor dichiarativo del repository upstream corrente ed è serializzato secondo `2026-09-07-package-repository-descriptor-and-adapter-types.md`.

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

Il catalogo può selezionare tramite `repository/type` un adapter già previsto dal prodotto e fornire dati dichiarativi, ma non può introdurre codice arbitrario da source/eval/eseguire.

---

## 3. Identità del repository

L'identità canonica del repository catalogo è:

```text
massimilianonardi-ai/pkg-catalog
```

Restano ancora aperti:

```text
chiave/file di configurazione locale, se necessario
meccanismo di clone/fetch/cache/snapshot
policy di aggiornamento
pinning/snapshot usato da una singola operazione pkg
```

La scelta del protocollo operativo di clone/fetch e la relativa configurazione runtime non vengono dedotte dal clone URL GitHub.

---

## 4. Stato iniziale vuoto

Il repository è stato verificato come Git repository vuoto: il default branch configurato è `main`, ma non esiste ancora un ref/HEAD finché non viene creato il primo commit.

Non viene creato un commit artificiale soltanto per inizializzare il repository.

La serializzazione di:

```text
<stream>/repository/
```

è ora fissata come directory di file scalari dichiarativi con `repository/type` obbligatorio.

Resta ancora da chiudere la serializzazione completa di:

```text
<stream>/nNNNN=<version-minimum>/
```

oltre ai campi concreti e alle firme del primo repository adapter da usare.

Il primo commit di `pkg-catalog` deve essere prodotto quando esiste una prima package definition reale conforme ai contratti correnti; non vengono creati placeholder o file anticipatori.

---

## 5. Repository type nel catalogo concreto

I repository type comuni iniziali includono:

```text
github
sourceforge
maven
```

Non viene introdotto nel catalogo corrente un type:

```text
custom
```

Per un prodotto con upstream non standard può essere aggiunto, dopo la relativa decisione/adapter nel prodotto, un type product-specific dedicato.

Una package definition concreta non può incorporare funzioni repository-specific per aggirare l'assenza di un adapter RumiAI.

---

## 6. Relazione con Git e provenance

Quando `pkg-catalog` possiederà commit, il commit Git continuerà a identificare lo snapshot esatto delle package definition usato da `pkg`.

Non viene introdotta una numerazione RumiAI separata per revisionare il catalogo.

Il repository segue il principio Git forward-only generale di RumiAI: la storia non deve essere riscritta o force-pushata salvo istruzione esplicita dell'utente.

---

## 7. Implementazione e test

Questa decisione assegna il repository concreto e il confine di autorità.

Non introduce ancora:

```text
file nel repository pkg-catalog
serializzazione completa della range definition
campi concreti dei singoli repository type oltre a type
backend di sync/cache
modifiche a rumiai-os
nuovi test permanenti
```

Non richiede physical validation separata.

---

## 8. Invarianti fissati

```text
PKG-CATALOG-REPO-01  il repository concreto delle package definition è massimilianonardi-ai/pkg-catalog
PKG-CATALOG-REPO-02  pkg-catalog contiene package definition concrete e non artifact/payload upstream
PKG-CATALOG-REPO-03  rumiai-dev resta autorità per schema, semantica e regole del catalogo
PKG-CATALOG-REPO-04  pkg-catalog è autorità per le istanze concrete delle package definition conformi ai contratti rumiai-dev
PKG-CATALOG-REPO-05  una definition concreta non può introdurre implicitamente nuove primitive o semantiche del catalogo
PKG-CATALOG-REPO-06  repository/ è directory dichiarativa e repository/type seleziona soltanto adapter RumiAI già previsti
PKG-CATALOG-REPO-07  pkg-catalog non può introdurre codice repository-specific da source/eval/eseguire
PKG-CATALOG-REPO-08  protocollo clone/fetch, cache, snapshot e policy di aggiornamento restano separati
PKG-CATALOG-REPO-09  il repository resta vuoto finché non esiste una prima package definition reale conforme ai contratti correnti
PKG-CATALOG-REPO-10  non vengono creati placeholder per inizializzare artificialmente il repository
PKG-CATALOG-REPO-11  custom non è un repository type baseline; upstream non standard usa un type product-specific solo dopo relativo contratto/adapter
PKG-CATALOG-REPO-12  quando esisteranno commit, il commit Git identifica lo snapshot naturale del catalogo
```
