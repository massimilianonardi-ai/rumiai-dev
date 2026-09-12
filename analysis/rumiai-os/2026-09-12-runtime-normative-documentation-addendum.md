# Addendum — stato operativo e lingua della documentazione normativa runtime

Date: 2026-09-12  
Status: **EXPLORATORY / NON-NORMATIVE ADDENDUM**

Questo addendum corregge e precisa:

```text
analysis/rumiai-os/2026-09-12-runtime-normative-documentation.md
```

alla luce delle decisioni successive dello stesso giorno.

## 1. Il modello non è ancora operativo

L'idea di distribuire nel prodotto una documentazione normativa locale consultabile da terminale resta esplorativa.

Anche le altre riflessioni sul futuro substrato restano non operative finché non viene superato il gate definito da:

```text
decisions/rumiai-os/2026-09-12-substrate-exploration-activation-gate.md
```

Quindi il documento principale non deve essere interpretato come introduzione di:

```text
nuovo tool runtime
nuova semantic root
nuovo formato documentale
nuova pipeline di publish
nuovo workflow di sviluppo
nuovo boundary già attivo
```

## 2. Correzione sulla lingua di riferimento

La sezione del documento principale che lasciava aperta la scelta della lingua sorgente/riferimento è superata da:

```text
decisions/rumiai-os/2026-09-12-product-reference-language-and-development-language.md
```

La lingua di riferimento del prodotto distribuito è:

```text
English
```

Se la documentazione normativa locale verrà adottata, la rappresentazione inglese dovrà essere completa e corretta e costituirà la baseline semantica della documentazione pubblicata.

Le altre lingue saranno traduzioni/localizzazioni della stessa semantica e non fonti normative indipendenti.

## 3. `rumiai-dev` resta in italiano

Il fatto che il prodotto usi l'inglese come riferimento non modifica la lingua di lavoro corrente di `rumiai-dev`.

Regole, decisioni, specifiche, analisi, handoff e altre note di sviluppo continuano a essere mantenute principalmente in italiano finché non emergerà una partecipazione esterna attiva che renda opportuno riesaminare tale scelta.

La futura eventuale pipeline di pubblicazione dovrà quindi poter partire da fonti di sviluppo in italiano senza obbligare il repository interno a diventare prematuramente bilingue o inglese.

Questo implica che, se la documentazione runtime verrà adottata, il processo dovrà distinguere chiaramente:

```text
documentazione di sviluppo autorevole in rumiai-dev

projection inglese completa destinata al prodotto

ulteriori localizzazioni opzionali
```

senza creare fonti normative concorrenti.

## 4. Conseguenza sulla progettazione futura

La relazione da esplorare non è più semplicemente:

```text
fonte normativa
  -> traduzioni
```

ma più precisamente:

```text
rumiai-dev
  documentazione di sviluppo principalmente italiana
        |
        | processo di pubblicazione controllato
        v
prodotto
  English reference projection completa
        |
        +--> altre localizzazioni
```

Il modo concreto con cui garantire equivalenza semantica, completezza e provenance resta da definire.

Non viene ancora scelto se la projection inglese sia:

```text
scritta manualmente
tradotta e revisionata
prodotta da una sorgente strutturata
mantenuta con un workflow misto
```

## 5. Non-decisioni che restano aperte

Restano aperti:

```text
nome del tool
pathname e semantic root
formato sorgente
formato runtime
CLI
pager/rendering
search/index
metadata
provenance representation
versioning delle pagine
processo concreto di publish
controlli automatici di equivalenza/completeness
```

Non resta invece più aperta la lingua di riferimento del prodotto: è l'inglese.
