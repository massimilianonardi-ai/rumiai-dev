# Decisione — Indipendenza del repository per stream `osarch`

Date: 2026-09-08  
Status: **Accepted**

## Contesto

Il package-definition catalog di RumiAI è package-first e può contenere, per uno stesso package:

```text
<pkg>/catalog/
<pkg>/catalog-<osarch>/
```

Le decisioni correnti hanno già fissato che ogni stream disponibile è completo e indipendente, possiede il proprio `repository/` e può usare un repository upstream corrente diverso dagli altri stream dello stesso package.

Questa decisione rende esplicita una motivazione architetturale fondamentale di tale collocazione: la disponibilità di un package per target differenti può provenire da publisher e repository differenti.

---

## 1. `repository/` resta locale allo stream

Il repository descriptor resta fisicamente e semanticamente dentro ogni stream:

```text
<pkg>/catalog[-<osarch>]/repository/
```

Non viene sollevato a un livello package-global come:

```text
<pkg>/repository/
```

Il fatto che più stream appartengano allo stesso package RumiAI non implica che abbiano lo stesso publisher, repository type, repository upstream o successione di versioni installabili.

---

## 2. Caso vendor/community

Un vendor può pubblicare ufficialmente soltanto alcuni target, mentre target ulteriori possono essere mantenuti dalla community attraverso repository differenti.

Esempio concettuale:

```text
foo/
├── catalog-linux-x86_64/
│   └── repository/        -> repository ufficiale del vendor
├── catalog-macos-arm64/
│   └── repository/        -> repository ufficiale del vendor
└── catalog-linux-arm64/
    └── repository/        -> repository community distinto
```

La collocazione stream-local di `repository/` permette di rappresentare questo caso senza:

```text
repository multipli dentro lo stesso stream
fallback automatici fra repository
coordinate condizionali per target dentro un descriptor package-global
logica vendor/community nel core pkg
```

Ogni stream continua ad avere un solo repository upstream corrente.

---

## 3. Selezione dello stream e del repository

La selezione dello stream resta quella già fissata:

```text
se catalog-<osarch> esiste
    -> usa esclusivamente quello stream
altrimenti se catalog esiste
    -> usa catalog
altrimenti
    -> package non disponibile per il target
```

Selezionare uno stream seleziona anche il suo `repository/`.

Non viene introdotto alcun merge o fallback verso il repository di un altro stream dello stesso package.

In particolare, un eventuale repository community per un target non supportato dal vendor non diventa fallback implicito per altri target e un repository vendor non prevale automaticamente su un repository community attraverso una policy globale.

---

## 4. Autorità e trust

Questa decisione descrive dove viene risolto l'upstream di ciascun target; non introduce una classificazione normativa dei publisher come `vendor` o `community` e non introduce ranking o trust policy fra repository.

La package definition concreta continua a dichiarare il repository corrente dello stream attraverso il normale `repository/` e il relativo repository type.

Eventuali future regole di trust, firma, provenance o preferenza fra publisher restano decisioni separate e non vengono inferite dalla posizione del repository descriptor.

---

## 5. Relazione con le decisioni esistenti

Questa decisione non modifica:

```text
un solo repository upstream corrente per stream
assenza di repository storici per range
precedenza completa catalog-<osarch> su catalog
assenza di merge/fallback per-versione
indipendenza delle successioni upstream fra stream
repository descriptor dichiarativo/non eseguibile
```

Rende esplicito che l'indipendenza del repository per stream è necessaria anche per rappresentare correttamente target pubblicati da soggetti/upstream differenti.

---

## 6. Invarianti fissati

```text
PKG-STREAM-REPO-01  repository/ resta locale a ciascun catalog stream e non diventa package-global
PKG-STREAM-REPO-02  stream differenti dello stesso package possono usare repository upstream correnti e publisher differenti
PKG-STREAM-REPO-03  il modello supporta target ufficiali del vendor e target aggiuntivi pubblicati da repository community distinti
PKG-STREAM-REPO-04  selezionare uno stream seleziona esclusivamente il repository di quello stream
PKG-STREAM-REPO-05  non esiste merge o fallback automatico verso repository appartenenti ad altri stream dello stesso package
PKG-STREAM-REPO-06  non viene introdotta una policy globale di ranking o preferenza vendor/community
```

Questa decisione è documentale e non richiede physical validation separata.
