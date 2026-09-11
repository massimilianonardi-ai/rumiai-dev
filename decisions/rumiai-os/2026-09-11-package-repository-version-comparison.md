# Decisione — Confronto repository-native delle versioni per `pkg install`

Date: 2026-09-11  
Status: **Accepted**

## 1. Contesto

L'orchestrazione corrente di `pkg install` usa la successione completa prodotta da:

```text
pkg_repository_list_versions <repository-dir>
```

per:

```text
verificare la versione risolta
validare l'ordine degli anchor dei range
selezionare il range applicabile
```

Questa strategia è corretta ma può avere costo sproporzionato per repository con una lunga cronologia. Il primo caso reale che rende il problema operativo è Electron: il repository GitHub upstream contiene oltre duemila release e l'installazione della latest richiede attualmente la paginazione completa delle release prima ancora del download dell'artifact.

La decisione `2026-09-09-package-install-orchestration-and-catalog-snapshot.md` aveva già fissato che l'enumerazione completa per `latest` era una scelta iniziale di semplicità e che una successiva ottimizzazione poteva evitarla. Questa decisione realizza tale ottimizzazione senza introdurre ordinamento SemVer, lessicografico, numerico o package-specific nel core.

---

## 2. Responsabilità dell'ordinamento invariata

L'ordine delle versioni upstream resta responsabilità del repository adapter.

Il core package continua a trattare le versioni come identificatori opachi conformi alla grammatica RumiAI già fissata e non interpreta il loro significato.

Non vengono introdotti nel core:

```text
SemVer
confronto lessicografico
confronto numerico
parsing di major/minor/patch
ordinamento per nome tag
regole package-specific
```

---

## 3. Nuova API repository adapter

La superficie repository adapter viene estesa con:

```text
pkg_repository_compare_versions <repository-dir> <left-version> <right-version>
```

Questa funzione confronta due versioni installabili secondo la stessa successione autorevole usata dall'adapter per `pkg_repository_list_versions`.

Entrambe le versioni devono esistere come versioni installabili secondo il contratto dell'adapter. Una versione inesistente, draft/prerelease quando tali release non sono installabili, ambigua oppure non rappresentabile produce failure operativo.

Output su successo, terminato da LF:

```text
-1   left precede right
0    left e right identificano la stessa versione
1    left segue right
```

Exit status:

```text
0   confronto riuscito
1   failure operativa/semantica o ordine non determinabile
2   numero di argomenti invalido
```

Non viene introdotta una seconda primitive di ordinamento nel core.

---

## 4. Semantica GitHub

Per l'adapter GitHub il confronto usa release esatte ottenute tramite:

```text
GET /repos/{owner}/{repository}/releases/tags/{tag}
```

Le release confrontabili restano full release:

```text
draft=false
prerelease=false
```

L'ordine resta quello già usato dalla successione GitHub corrente:

```text
created_at
-> published_at come disambiguazione deterministica corrente
```

Per due tag distinti:

```text
created_at diverso
    -> ordina per created_at

created_at uguale e published_at diverso
    -> ordina per published_at

created_at uguale e published_at uguale
    -> failure: ordine non determinabile autorevolmente
```

Il confronto non usa il nome del tag come tie-breaker.

Quando `left-version` e `right-version` sono identici, l'adapter deve comunque verificare che la release esatta sia installabile prima di restituire `0`.

---

## 5. Uso da parte di `pkg install`

`pkg install` non deve più enumerare obbligatoriamente l'intera successione upstream per risolvere un singolo operand.

Il nuovo flusso di resolution è:

```text
validazione strutturale stream/range
-> pkg_repository_resolve_version
-> validazione versione risolta
-> confronto repository-native degli anchor
-> selezione del range tramite confronto repository-native
-> pkg_repository_resolve_artifact
-> pkg_download
-> pkg_extract
-> pkg_integrate
```

Per tutti gli anchor dichiarati:

1. ogni anchor deve essere una versione installabile;
2. anchor consecutivi devono risultare strettamente crescenti secondo `pkg_repository_compare_versions`;
3. la versione risolta viene confrontata con gli anchor per determinare l'ultimo range il cui anchor non segue la versione richiesta;
4. se la versione richiesta precede il primo anchor, l'installazione fallisce.

La validazione considera l'intera sequenza degli anchor anche quando il range applicabile è stato già individuato, così un range successivo invalido o fuori ordine non viene ignorato.

---

## 6. Enumerazione upstream e `pkg versions` invariati

La primitive repository adapter:

```text
pkg_repository_list_versions <repository-dir>
```

mantiene il proprio contratto corrente e continua a produrre l'intera successione installabile upstream:

```text
oldest -> latest
```

Questa ottimizzazione non modifica tale API: `pkg install` semplicemente non la usa più per risolvere un singolo operand.

Il comando pubblico:

```text
pkg versions <pkg>[!<osarch>]
```

resta invece il comando local-only già fissato per osservare le concrete version disponibili nel package store locale. Non consulta catalogo o repository upstream, non rappresenta la successione restituita da `pkg_repository_list_versions` e non viene modificato da questa unità.

---

## 7. Latest ed exact version

La risoluzione resta affidata a:

```text
pkg_repository_resolve_version <repository-dir>
pkg_repository_resolve_version <repository-dir> <version>
```

L'assenza della versione continua a significare latest secondo l'adapter.

`pkg install` non verifica più la latest confrontandola con l'ultima riga di una enumerazione completa appena effettuata: il contratto di `pkg_repository_resolve_version` resta la fonte repository-specific della resolution latest/exact, mentre la nuova primitive verifica soltanto le relazioni d'ordine necessarie ai range.

---

## 8. Isolamento degli adapter

Resta valido il confine già fissato: ogni invocazione di una API repository viene eseguita in un contesto che carica esclusivamente l'adapter selezionato.

La nuova funzione non autorizza un adapter a contaminare il core con dati o primitive repository-specific.

---

## 9. Testing

La copertura permanente deve proteggere almeno:

```text
compare_versions left < right -> -1
compare_versions left = right -> 0 dopo validazione della release
compare_versions left > right -> 1
versione inesistente -> failure
release draft/prerelease -> failure
tie created_at+published_at fra tag distinti -> failure
nessun ordinamento per nome tag
pkg_repository_list_versions mantiene l'enumerazione upstream completa
pkg install non chiama pkg_repository_list_versions per la resolution dell'operand
anchor consecutivi strettamente crescenti
anchor inesistente -> failure
anchor fuori ordine -> failure
versione richiesta precedente al primo anchor -> failure
selezione corretta del range per exact e latest
nessun SemVer/confronto lessicografico introdotto nel core
pkg versions resta local-only e invariato
```

La physical validation Electron deve essere ripetuta su una revisione committed che includa questa modifica; l'evidenza precedente non viene riutilizzata come prova della nuova revisione.

---

## 10. Invarianti fissati

```text
PKG-REPOSITORY-COMPARE-01  l'ordine delle versioni resta responsabilità del repository adapter
PKG-REPOSITORY-COMPARE-02  API = pkg_repository_compare_versions <repository-dir> <left-version> <right-version>
PKG-REPOSITORY-COMPARE-03  output = -1, 0 o 1 terminato da LF; altro output è invalido
PKG-REPOSITORY-COMPARE-04  entrambe le versioni devono essere installabili e validate dall'adapter
PKG-REPOSITORY-COMPARE-05  il core non introduce SemVer o altri ordinamenti propri
PKG-REPOSITORY-COMPARE-06  GitHub confronta created_at e quindi published_at; tie residuo fra tag distinti -> failure
PKG-REPOSITORY-COMPARE-07  pkg install usa il confronto repository-native per validare anchor e scegliere il range
PKG-REPOSITORY-COMPARE-08  pkg install non richiede più l'enumerazione completa delle versioni per un operand
PKG-REPOSITORY-COMPARE-09  pkg_repository_list_versions mantiene la successione upstream completa oldest -> latest
PKG-REPOSITORY-COMPARE-10  tutti gli anchor vengono comunque validati e devono essere strettamente crescenti
PKG-REPOSITORY-COMPARE-11  versione precedente al primo anchor -> failure
PKG-REPOSITORY-COMPARE-12  nessun comportamento di download, extract, integrate o default viene modificato da questa unità
PKG-REPOSITORY-COMPARE-13  pkg versions resta local-only sulle concrete version installate ed è invariato
```
