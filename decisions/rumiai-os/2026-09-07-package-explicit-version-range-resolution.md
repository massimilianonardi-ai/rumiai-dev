# Decisione — Resolution del range per versioni upstream esplicite

Date: 2026-09-07  
Status: **Accepted**

## Contesto

La decisione `2026-09-07-package-definition-catalog-and-version-ranges.md` ordina i range delle package definition con directory:

```text
nNNNN=<version-minimum>
```

senza introdurre un comparatore universale per le versioni upstream.

La decisione `2026-09-07-package-install-repository-pipeline-and-cli.md` fissa inoltre le API repository comuni:

```text
pkg_repository_list_versions
pkg_repository_resolve_version
pkg_repository_resolve_artifact
```

ed assegna a `pkg_repository_list_versions` anche il compito di fornire, quando necessario, informazioni repository-specific sulla lineage delle release.

Una verifica ulteriore ha evidenziato un'ambiguità nell'ordine concettuale precedente: per un operand con versione esplicita, come:

```text
foo@1.5
```

la selezione del range può richiedere proprio la conoscenza repository-specific dell'ordine delle release. Non è quindi corretto assumere sempre che il range venga selezionato completamente prima di poter consultare un repository adapter.

Questa decisione chiude l'ambiguità senza introdurre una nuova API, un comparatore universale o una nuova forma di package identity.

Questa unità modifica soltanto `rumiai-dev`. Non autorizza modifiche a `rumiai-os` o `rumiai-tests`.

---

## 1. Due casi distinti

### Versione omessa

Per:

```text
pkg install <pkg>
pkg install <pkg>!<osarch>
```

la versione richiesta è `latest`.

Dopo aver selezionato lo stream `catalog` oppure `catalog-<osarch>`, `pkg` seleziona direttamente l'ultimo range `nNNNN` dello stream e carica l'adapter dichiarato dalla relativa package definition.

Quindi:

```text
versione omessa
    -> ultimo range dello stream
    -> pkg_repository_resolve_version
    -> upstream version concreta
```

Non serve confrontare la versione risolta con gli anchor dei range precedenti: per definizione `latest` appartiene all'ultimo range corrente dello stream, salvo catalogo incoerente.

### Versione esplicita

Per:

```text
pkg install <pkg>@<version>
pkg install <pkg>@<version>!<osarch>
```

`pkg` deve determinare quale range dello stream contiene la versione upstream esplicita.

Poiché `<version>` è opaca al core, questa determinazione può richiedere discovery repository-specific prima della selezione definitiva della package definition.

---

## 2. Nessun comparatore universale nel core

Il core `pkg` non deve dedurre l'appartenenza a un range usando genericamente:

```text
confronto lessicografico
confronto numerico
SemVer
ordinamento per data ricavato dalla stringa
normalizzazione di prefissi v
pattern specifici del package
```

Esempi come:

```text
1.0
2.0
v35
2026-Q1
v01-Kidding-Penguin
```

restano versioni upstream opache.

L'ordine dei range è determinato soltanto dagli ordinali RumiAI `nNNNN`; l'ordine delle release all'interno della lineage è informazione repository-specific.

---

## 3. Consultazione degli adapter durante la range resolution

Le package definition candidate possono essere lette come metadata del catalogo prima che una di esse venga selezionata definitivamente per l'installazione.

Quando una versione esplicita richiede informazione di lineage, `pkg` può quindi consultare uno o più repository adapter dichiarati dalle package definition candidate.

Ogni consultazione:

- avviene in un contesto shell isolato, secondo la regola già fissata per gli adapter con API omonime;
- usa soltanto operazioni di discovery/resolution repository-specific;
- può usare `pkg_repository_list_versions` per ottenere l'ordine/membership necessario alla range resolution;
- non trasferisce artifact;
- non estrae artifact;
- non modifica il package store;
- non pubblica selector, binding o provider index.

Il fatto che un adapter venga consultato durante la selezione del range non rende quella package definition la definition finale dell'installazione.

---

## 4. Repository type differenti fra range

Range differenti dello stesso stream possono dichiarare repository type o coordinate upstream differenti.

La range resolution non deve quindi assumere che l'intero stream sia interrogabile attraverso un solo adapter o un solo repository context.

Quando necessario, `pkg` può consultare separatamente gli adapter dei range candidate, sempre in contesti isolati.

La firma concreta di `pkg_repository_list_versions` e il descriptor della package definition dovranno fornire informazioni sufficienti a stabilire la membership della versione richiesta nella lineage supportata dal relativo range.

Questa decisione non introduce una composite repository string né sposta repository coordinates fuori dalla package definition.

---

## 5. Risultato obbligatoriamente univoco

Per una versione esplicita, la range resolution deve terminare in esattamente uno dei seguenti risultati:

```text
un solo range applicabile
    -> continua

nessun range applicabile
    -> errore

più range plausibili / membership non determinabile
    -> errore di catalogo/resolution
```

`pkg` non deve scegliere arbitrariamente:

```text
il range più recente
il range più vecchio
il primo risultato del filesystem
il primo adapter che risponde
un range ottenuto con confronto lessicografico della versione
```

Se la lineage o i repository context non permettono di dimostrare in modo univoco la membership, il catalogo non contiene informazione sufficiente per quell'installazione e deve essere corretto/esteso invece di introdurre una euristica implicita.

---

## 6. Ruolo di `pkg_repository_resolve_version`

Dopo che il range è stato selezionato definitivamente, `pkg_repository_resolve_version` conserva il proprio contratto:

```text
versione omessa
    -> risolve latest a una upstream version concreta

versione esplicita
    -> valida/risolve esattamente quella upstream version nel context selezionato
```

Una versione esplicita non può essere sostituita silenziosamente con un'altra release.

`pkg_repository_resolve_artifact` viene chiamata soltanto dopo che esistono sia la package definition finale sia la versione upstream concreta.

---

## 7. Pipeline corretta

La pipeline concettuale aggiornata è:

```text
parse package operand
    -> determine requested/current target
    -> select catalog-<osarch> oppure fallback catalog
    -> determine package-definition range
        -> versione omessa: ultimo range
        -> versione esplicita: consultare repository discovery isolata quando necessaria
        -> membership deve risultare univoca
    -> source in isolation the adapter della package definition selezionata
        -> pkg_repository_resolve_version
        -> pkg_repository_resolve_artifact
    -> generic download
    -> generic extract
    -> RumiAI integration
```

Questa sequenza sostituisce esclusivamente l'interpretazione della sezione 9 di `2026-09-07-package-install-repository-pipeline-and-cli.md` secondo cui la selezione del range dovesse necessariamente precedere qualunque consultazione repository-specific.

La separazione fra repository discovery, download, extract e integration resta invariata.

---

## 8. Relazione con i range `nNNNN`

Questa decisione non cambia la semantica degli ordinali:

```text
nNNNN
    ordine RumiAI dei package-definition range

<version-minimum>
    anchor upstream opaco che introduce il range
```

Un nuovo range continua a chiudere quello precedente e un inserimento storico può continuare a rinumerare gli ordinali successivi.

`nNNNN` non viene persistito nell'identità installata e non diventa una release-order universale delle versioni upstream.

---

## 9. Lineage non lineari

Resta valido il limite già fissato: la baseline dei range assume una lineage rappresentabile linearmente nello stream.

Se `pkg_repository_list_versions` e le package definition candidate non possono produrre una membership univoca perché l'upstream espone branch paralleli, backport o linee LTS concorrenti, `pkg` deve fallire la range resolution per quel caso.

La futura estensione necessaria dovrà rappresentare esplicitamente quella struttura; non viene anticipata qui.

---

## 10. Implementazione e test

Alla data di questa decisione il catalogo e i repository adapter non sono ancora implementati nel prodotto e non esistono test permanenti `pkg` corrispondenti.

Quando implementati, i test dovranno proteggere almeno:

```text
versione omessa -> ultimo range senza confronto universale
versione esplicita -> adapter discovery consultabile prima della selection finale
adapter candidate sempre isolati
nessun download/extract/integration durante range discovery
repository type differenti fra range non assumono un adapter unico
membership univoca richiesta
nessun match -> errore
match ambiguo/non determinabile -> errore
nessun fallback SemVer/lessicografico/data
resolve_version finale non sostituisce una versione esplicita
```

Questa decisione è documentale e non richiede physical validation separata.

---

## 11. Invarianti fissati

```text
PKG-RANGE-RESOLVE-01  versione install omessa seleziona direttamente l'ultimo range dello stream e poi risolve latest
PKG-RANGE-RESOLVE-02  una versione esplicita richiede la determinazione univoca del range applicabile
PKG-RANGE-RESOLVE-03  il core pkg non usa un comparatore universale delle versioni upstream per scegliere il range
PKG-RANGE-RESOLVE-04  package definition candidate possono essere lette e i relativi adapter consultati prima della selezione definitiva
PKG-RANGE-RESOLVE-05  la discovery per range usa adapter in contesti shell isolati e non produce side effect di download/extract/integration
PKG-RANGE-RESOLVE-06  pkg_repository_list_versions è l'API repository esistente destinata a fornire l'informazione di lineage/membership necessaria
PKG-RANGE-RESOLVE-07  range differenti possono usare repository type/coordinate differenti; non si assume un unico repository context per stream
PKG-RANGE-RESOLVE-08  zero range applicabili è errore; membership ambigua o non determinabile è errore
PKG-RANGE-RESOLVE-09  non esiste fallback implicito basato su SemVer, lessicografico, numerico, date o ordine filesystem
PKG-RANGE-RESOLVE-10  dopo la selection del range, pkg_repository_resolve_version valida/risolve la versione nel context finale senza sostituzione silenziosa
PKG-RANGE-RESOLVE-11  pkg_repository_resolve_artifact avviene soltanto dopo package definition finale e upstream version concreta
PKG-RANGE-RESOLVE-12  questa decisione corregge soltanto l'ordine logico della range resolution e non modifica gli ordinali nNNNN, la CLI o la separazione dei layer
```
