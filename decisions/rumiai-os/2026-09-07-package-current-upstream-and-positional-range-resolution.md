# Decisione — Repository upstream corrente e resolution posizionale dei range

Date: 2026-09-07  
Updated: 2026-09-07  
Status: **Accepted**

## Contesto

Il package-definition catalog di RumiAI usa stream:

```text
<pkg>/catalog/
<pkg>/catalog-<osarch>/
```

e range ordinati:

```text
nNNNN=<version-minimum>
```

Le versioni upstream restano stringhe opache e il core `pkg` non possiede un comparatore universale delle release.

La precedente decisione `2026-09-07-package-explicit-version-range-resolution.md` aveva ammesso la consultazione di repository adapter differenti dichiarati dalle package definition candidate per determinare il range di una versione esplicita.

La correzione corrente sostituisce quel modello con un contratto più semplice:

> ogni stream possiede un solo repository upstream corrente; `pkg_repository_list_versions` interroga quel repository corrente e restituisce la successione autorevole delle versioni attualmente installabili; i range vengono determinati dalla posizione delle versioni e degli anchor in tale successione.

La serializzazione fisica del repository descriptor è ora fissata da `2026-09-07-package-repository-descriptor-and-adapter-types.md` come directory dichiarativa:

```text
<stream>/repository/
```

con `repository/type` obbligatorio e file scalari repository-specific.

Se il produttore migra da un sistema di distribuzione a un altro, il sistema precedente non resta una sorgente RumiAI parallela. Le release storiche sono ancora installabili soltanto se il repository upstream corrente continua a esporle.

Questa unità modifica soltanto `rumiai-dev`. Non autorizza modifiche a `rumiai-os` o `rumiai-tests`.

---

## 1. Repository descriptor a livello di stream

Ogni stream disponibile contiene un'unica directory:

```text
repository/
```

quindi, concettualmente:

```text
<pkg>/catalog/
├── repository/
│   └── type
├── n0001=...
└── n0002=...
```

oppure:

```text
<pkg>/catalog-<osarch>/
├── repository/
│   └── type
├── n0001=...
└── n0002=...
```

`repository/` descrive il repository upstream **corrente** dello stream.

`repository/type` seleziona l'adapter RumiAI e gli altri file scalari contengono i campi repository-specific previsti da quell'adapter.

Il repository descriptor appartiene allo stream, non al singolo range, ed è dato dichiarativo: non viene source, eval o interpretato come shell/env.

---

## 2. Un solo repository corrente per stream

Tutti i range di uno stesso stream vengono risolti attraverso il medesimo repository upstream corrente descritto da:

```text
<stream>/repository/
```

Non esiste nel baseline:

```text
repository storico per range
repository fallback per vecchie versioni
catena di repository superseded
consultazione di adapter candidate differenti per determinare il range
```

Se l'upstream cambia sistema, `repository/` viene aggiornato al nuovo repository type/context.

Dopo la migrazione RumiAI interroga soltanto il repository corrente. Il precedente non resta automaticamente una sorgente valida.

Una vecchia release è ancora installabile solo se il repository corrente la espone e le API repository correnti riescono a risolverla.

---

## 3. Repository type e adapter

`repository/type` identifica l'adapter:

```text
<type>
    -> lib/sh/pkg-repository-<type>.lib.sh
```

I type comuni iniziali includono:

```text
github
sourceforge
maven
```

`custom` non appartiene al baseline corrente.

Quando un prodotto usa un upstream non aderente a un type comune già supportato, può essere introdotto un type/adapter product-specific dedicato. Non viene forzata una generalizzazione prima che esista un contratto realmente comune.

---

## 4. Ruolo di `pkg_repository_list_versions`

L'API già fissata:

```text
pkg_repository_list_versions
```

interroga direttamente, tramite l'adapter selezionato da `repository/type`, il repository upstream corrente.

La sua sorgente autorevole è l'upstream corrente; non è una lista statica mantenuta nel package-definition catalog e non consulta repository storici.

Semanticamente restituisce la successione completa delle versioni che l'upstream corrente rende installabili per lo stream corrente.

La successione è ordinata:

```text
dalla release più vecchia alla release più recente
```

secondo la lineage upstream rappresentata dall'adapter.

Ogni versione compare al massimo una volta e viene preservata nella propria stringa upstream canonica.

Esempio concettuale:

```text
1.0
1.1
1.5
2.0
2.7
v35
v36
v41
2026-Q1
2026-Q2
v01-Kidding-Penguin
v02-Happy-Otter
```

La serializzazione esatta dell'output resta da fissare con la firma concreta del primo adapter; l'ordine semanticamente significativo è invece fissato da questa decisione.

---

## 5. Nessun comparatore universale

Il core `pkg` non ordina le versioni usando genericamente:

```text
confronto lessicografico
confronto numerico
SemVer
prefisso v
calendar versioning
data ricavata dalla stringa
pattern package-specific
ordine del filesystem
```

Stringhe come:

```text
1.0
v35
2026-Q1
v01-Kidding-Penguin
```

restano opache.

L'unico ordine usato dal resolver dei range è la **posizione** nella successione restituita da `pkg_repository_list_versions`.

---

## 6. Anchor dei range

Ogni directory:

```text
nNNNN=<version-minimum>
```

continua a dichiarare la prima versione cui si applica quella package definition.

Per uno stream valido, ogni `<version-minimum>` deve:

1. comparire esattamente nella successione corrente di `pkg_repository_list_versions`;
2. comparire una sola volta;
3. rispettare lo stesso ordine degli ordinali `nNNNN`.

Esempio:

```text
catalog:
    n0001=1.0
    n0002=2.0
    n0003=v35
    n0004=2026-Q1
```

lista upstream corrente:

```text
1.0
1.1
2.0
2.7
v35
v36
2026-Q1
2026-Q2
```

Le posizioni degli anchor sono quindi strettamente crescenti.

Un anchor assente o fuori ordine rende il catalogo incoerente rispetto all'upstream corrente e richiede correzione del catalogo; non autorizza un'euristica nel resolver.

---

## 7. Resolution di una versione esplicita

Per:

```text
pkg install <pkg>@<version>
pkg install <pkg>@<version>!<osarch>
```

`pkg`:

1. seleziona lo stream `catalog-<osarch>` oppure il fallback `catalog` secondo le regole già fissate;
2. legge `<stream>/repository/type`;
3. carica in un contesto isolato l'adapter RumiAI `pkg-repository-<type>.lib.sh`;
4. l'adapter valida/legge i propri file scalari repository-specific;
5. esegue `pkg_repository_list_versions` sul repository upstream corrente;
6. verifica che la versione richiesta compaia nella successione;
7. localizza nella stessa successione gli anchor `nNNNN=<version-minimum>`;
8. seleziona il range il cui anchor è l'ultimo anchor che non viene dopo la versione richiesta nella successione;
9. usa la package definition di quel range per la successiva risoluzione/materializzazione.

Esempio:

```text
anchor:
    n0001=1.0          posizione 1
    n0002=2.0          posizione 4
    n0003=v35          posizione 6
    n0004=2026-Q1      posizione 9

versione richiesta:
    v36                posizione 7
```

Risultato:

```text
n0003=v35
```

Nessun confronto viene effettuato sulle stringhe `v35`, `v36` o `2026-Q1`.

Se la versione richiesta non compare nella lista corrente, non è installabile attraverso il repository corrente e la resolution fallisce.

---

## 8. Versione omessa e `latest`

Per:

```text
pkg install <pkg>
pkg install <pkg>!<osarch>
```

l'assenza di `@<version>` continua a significare:

```text
latest upstream disponibile
```

`pkg_repository_resolve_version` risolve `latest` attraverso il repository corrente.

Nel contratto corrente, la versione risolta come `latest` deve coincidere con l'ultima versione della successione che `pkg_repository_list_versions` restituirebbe per lo stesso repository/context.

Operativamente `pkg` non è obbligato a enumerare tutte le versioni soltanto per installare `latest`: può selezionare l'ultimo range `nNNNN`, leggere `repository/type`, caricare l'adapter e usare `pkg_repository_resolve_version`.

La coerenza fra ultimo range, anchor e successione upstream resta una proprietà validabile del catalogo.

---

## 9. Nuove versioni e ultimo range

Una nuova versione pubblicata upstream non richiede un aggiornamento del catalogo finché continua a usare la stessa package definition dell'ultimo range.

Esempio:

```text
ultimo range:
    n0005=v01-Kidding-Penguin

nuove release upstream:
    v02-Happy-Otter
    v03-Serious-Wombat
```

Finché non viene introdotta una nuova package definition, entrambe appartengono automaticamente a `n0005` perché compaiono dopo il suo anchor nella successione upstream.

Se `v03-Serious-Wombat` richiede una nuova definition, il catalogo aggiunge:

```text
n0006=v03-Serious-Wombat
```

Da quel momento `n0005` termina alla release immediatamente precedente nella successione corrente.

---

## 10. Manutenzione quando un anchor scompare upstream

Il catalogo descrive le versioni **attualmente installabili**, non conserva artificialmente versioni che l'upstream corrente non rende più disponibili.

Se il `<version-minimum>` di un range scompare dalla successione corrente ma versioni successive dello stesso range restano installabili, l'anchor deve essere aggiornato alla prima versione ancora disponibile che usa quella stessa package definition.

Esempio:

```text
prima:
    n0001=1.0
    n0002=3.0

upstream corrente:
    2.5
    3.0
    3.1
```

Il catalogo corrente diventa:

```text
n0001=2.5
n0002=3.0
```

Se nessuna versione attualmente installabile appartiene più a un range, quel range viene rimosso e gli ordinali successivi vengono rinumerati per mantenere la continuità `n0001`, `n0002`, ... già fissata.

Git conserva la storia degli anchor e dei range precedenti; non serve mantenere nel catalogo corrente una disponibilità che l'upstream non offre più.

---

## 11. Nessuna lista statica per range

Il baseline non mantiene dentro ciascun range una lista esaustiva delle versioni appartenenti al range.

Sono quindi esclusi modelli del tipo:

```text
n0001=1.0/
    versions = 1.0 1.1 1.2 ...
```

perché una nuova release valida dell'ultimo range diventerebbe invisibile a RumiAI fino a un aggiornamento manuale del catalogo.

L'upstream corrente resta la fonte delle versioni disponibili; il catalogo contiene soltanto gli anchor che separano package definition differenti.

---

## 12. Nessuna funzione `match` nel baseline

Non viene introdotta nel baseline una funzione, file eseguibile o API `match` package-specific per decidere se una versione appartiene a un range.

La resolution posizionale copre il caso corrente senza eseguire codice arbitrario proveniente dalla package definition e senza duplicare parser/comparator package-specific.

Una futura primitive di matching può essere valutata soltanto se emergerà un package reale la cui struttura delle release non sia rappresentabile dal contratto corrente.

Il termine `match` usato nella discussione non diventa quindi un nome di prodotto o un'interfaccia RumiAI corrente.

---

## 13. Lineage non lineari

La successione restituita da `pkg_repository_list_versions` deve rappresentare una lineage totale sufficiente a determinare senza ambiguità i range.

Se l'upstream espone branch paralleli, LTS concorrenti, backport o altre strutture per cui l'adapter non può produrre una successione totale semanticamente corretta, il caso resta fuori dal baseline.

`pkg` non deve inventare un ordine artificiale per farlo rientrare nel modello.

Quando emergerà un caso concreto sarà introdotta una rappresentazione esplicita proporzionata.

---

## 14. Relazione con `pkg_repository_resolve_version`

Le responsabilità restano distinte:

```text
pkg_repository_list_versions
    enumera e ordina la successione delle versioni installabili correnti

pkg_repository_resolve_version
    risolve latest oppure valida la versione esplicita nel repository corrente

pkg_repository_resolve_artifact
    risolve l'artifact concreto della versione già determinata
```

Per una versione esplicita, `pkg_repository_resolve_version` non può sostituirla silenziosamente con una release differente.

Le tre API operano tutte contro il repository corrente dello stream.

---

## 15. Relazione con package definition e artifact

`<stream>/repository/` possiede la conoscenza del repository upstream corrente.

Le directory `nNNNN=<version-minimum>/` possiedono invece la package definition specifica del range, inclusi quando necessari:

```text
artifact selection/materialization information
artifact format
integrity/provenance requirements
facility
dependency
cmd/
link/
env
default/
state/path normalization information
altre regole di integrazione già previste dal package model
```

In particolare:

```text
archive_regex
digest_regex
digest_type
```

sono semanticamente range-level e non repository-level.

La package definition di range può quindi cambiare il modo in cui una release viene materializzata/verificata senza cambiare la sorgente upstream corrente dello stream.

`pkg_repository_resolve_artifact` usa il repository corrente insieme alle informazioni range-specific necessarie alla selezione dell'artifact.

---

## 16. Pipeline risultante

Per una versione esplicita:

```text
parse operand
    -> select stream
    -> read <stream>/repository/type
    -> source selected RumiAI repository adapter in isolation
    -> adapter validates/reads repository-specific scalar fields
    -> pkg_repository_list_versions
    -> locate requested version and range anchors by position
    -> select exactly one range definition
    -> pkg_repository_resolve_version exact
    -> pkg_repository_resolve_artifact
    -> pkg_download
    -> pkg_extract
    -> pkg_integrate
```

Per `latest`:

```text
parse operand
    -> select stream
    -> select last range
    -> read <stream>/repository/type
    -> source selected RumiAI repository adapter in isolation
    -> adapter validates/reads repository-specific scalar fields
    -> pkg_repository_resolve_version latest
    -> pkg_repository_resolve_artifact
    -> pkg_download
    -> pkg_extract
    -> pkg_integrate
```

La separazione repository discovery/resolution -> download -> extract -> integration resta invariata.

---

## 17. Supersession

Questa decisione supersede integralmente `2026-09-07-package-explicit-version-range-resolution.md` per la resolution corrente dei range.

Sono inoltre superseded, ovunque compaiano nelle decisioni precedenti, le assunzioni secondo cui:

```text
range differenti dello stesso stream possono selezionare repository upstream differenti per la normale resolution
pkg deve consultare adapter candidate diversi per determinare il range
repository type e coordinate upstream correnti appartengono al singolo range
repository descriptor può essere un file shell/env sourced
custom è un repository type baseline
```

Restano invariati:

```text
catalog / catalog-<osarch>
nNNNN=<version-minimum>
ordinali contigui
identity generic e target-specific
CLI a quattro forme
le tre API repository già fissate
nessun comparatore universale delle versioni upstream
repository adapter isolati
separazione download/extract/integration
```

---

## 18. Implementazione e test

Alla data di questa decisione il nuovo package pipeline non è implementato in `rumiai-os` e non esistono test permanenti `pkg` in `rumiai-tests`.

Quando implementato, i test dovranno proteggere almeno:

```text
un solo repository/ corrente per stream
repository/type obbligatorio
repository descriptor dichiarativo/non sourced
adapter selezionato da type
assenza di custom baseline
supporto a type product-specific quando introdotti
pkg_repository_list_versions interroga il repository corrente
nessun repository storico consultato automaticamente
lista versioni ordinata oldest -> latest
versioni uniche nella successione
ogni anchor presente nella successione
ordine anchor coerente con nNNNN
versione esplicita mappata per posizione e non per confronto stringhe
versione non presente -> errore
nuova release dopo ultimo anchor -> ultimo range automaticamente
latest risolta coerentemente con l'ultima versione della successione
anchor scomparso -> catalogo da riallineare
range senza versioni disponibili -> rimozione e rinumerazione
nessuna lista statica per range
nessuna primitive match nel baseline
archive/digest selection range-level
nessun fallback SemVer/lessicografico/numerico/data
```

Questa decisione è documentale e non richiede physical validation separata.

---

## 19. Invarianti fissati

```text
PKG-UPSTREAM-01  ogni catalog stream possiede una sola directory repository/ del repository upstream corrente
PKG-UPSTREAM-02  repository/type seleziona l'adapter RumiAI; gli altri campi repository-specific sono scalari dichiarativi
PKG-UPSTREAM-03  repository/ non viene source/eval; il codice eseguibile appartiene all'adapter RumiAI
PKG-UPSTREAM-04  repository type e coordinate correnti appartengono allo stream e non al singolo range
PKG-UPSTREAM-05  una migrazione upstream sostituisce il repository corrente; i repository precedenti non restano fallback automatici
PKG-UPSTREAM-06  una release storica è installabile solo se il repository corrente continua a esporla e risolverla
PKG-UPSTREAM-07  pkg_repository_list_versions interroga il repository upstream corrente dello stream
PKG-UPSTREAM-08  pkg_repository_list_versions restituisce tutte le versioni attualmente installabili in successione dalla più vecchia alla più recente
PKG-UPSTREAM-09  il core pkg usa la posizione nella successione e non interpreta semanticamente le stringhe upstream
PKG-UPSTREAM-10  ogni version-minimum anchor deve comparire esattamente una volta nella successione corrente
PKG-UPSTREAM-11  le posizioni degli anchor devono essere strettamente crescenti nello stesso ordine degli nNNNN
PKG-UPSTREAM-12  una versione esplicita deve comparire nella successione corrente o la resolution fallisce
PKG-UPSTREAM-13  il range di una versione esplicita è quello dell'ultimo anchor che non viene dopo la versione nella successione
PKG-UPSTREAM-14  latest risolta da pkg_repository_resolve_version deve essere coerente con l'ultima versione della successione corrente
PKG-UPSTREAM-15  nuove release successive all'ultimo anchor appartengono automaticamente all'ultimo range finché non viene aggiunta una nuova definition
PKG-UPSTREAM-16  se un anchor scompare ma restano versioni del range, l'anchor viene spostato alla prima versione ancora disponibile dello stesso range
PKG-UPSTREAM-17  se un range non contiene più versioni installabili viene rimosso e gli ordinali successivi vengono rinumerati
PKG-UPSTREAM-18  il catalogo non mantiene liste statiche esaustive delle versioni per range
PKG-UPSTREAM-19  non esiste nel baseline una primitive package-specific match per la range membership
PKG-UPSTREAM-20  lineage non rappresentabili come successione totale restano fuori dal baseline e non ricevono un ordine artificiale
PKG-UPSTREAM-21  le tre API repository operano tutte contro il repository corrente dello stream
PKG-UPSTREAM-22  github/sourceforge/maven sono type comuni iniziali; custom non è baseline; upstream non standard può avere un type product-specific
PKG-UPSTREAM-23  artifact selection e integrazione restano range-specific anche quando il repository upstream è stream-level
PKG-UPSTREAM-24  archive_regex, digest_regex e digest_type sono range-level
```
