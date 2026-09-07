# Decisione — Catalogo delle package definition, stream per target e range ordinati

Date: 2026-09-07  
Updated: 2026-09-07  
Status: **Accepted**

## Contesto

La pipeline corrente di `pkg` separa catalog lookup, repository-specific discovery/resolution, download, extract e integrazione RumiAI.

Le versioni upstream non possiedono nel modello RumiAI un comparatore universale e possono cambiare convenzione di naming nel tempo:

```text
1.0
2.0
v35
2026-Q1
v01-Kidding-Penguin
```

Il catalogo ordina le regioni di applicabilità delle package definition senza interpretare genericamente tali stringhe.

Il repository upstream corrente e la resolution posizionale dei range sono fissati da `2026-09-07-package-current-upstream-and-positional-range-resolution.md`. La serializzazione di `repository/` e la policy dei repository type sono fissate da `2026-09-07-package-repository-descriptor-and-adapter-types.md`.

Questa unità modifica soltanto `rumiai-dev`. Non autorizza modifiche a `rumiai-os`, `rumiai-tests` o `pkg-catalog`.

---

## 1. Sorgente concreta del catalogo

Il repository concreto delle package definition è:

```text
massimilianonardi-ai/pkg-catalog
```

È un repository GitHub RumiAI dedicato alle sole package definition concrete.

La package definition resta distinta dall'artifact upstream e il catalogo non diventa un repository di payload software.

Restano separatamente aperti:

```text
chiave/file di configurazione locale, se necessario
meccanismo di clone/fetch/cache/snapshot
policy di aggiornamento
pinning/snapshot operativo durante una singola invocazione pkg
```

`rumiai-dev` resta autorevole per schema, semantica e regole del catalogo; `pkg-catalog` contiene le istanze concrete conformi a tali contratti.

---

## 2. Lookup package-first

La prima chiave fisica del catalogo è il nome canonico del package:

```text
<pkg>/
```

Esempio:

```text
foo/
bar/
java/
```

---

## 3. Stream `catalog` e `catalog-<osarch>`

Ogni package può possedere:

```text
<pkg>/catalog/
<pkg>/catalog-<osarch>/
```

Semantica:

```text
catalog
    stream completo delle package definition realmente platform-independent

catalog-<osarch>
    stream completo delle package definition specifiche dell'esatto target RumiAI <osarch>
```

Il naming segue deliberatamente la stessa distinzione semantica già presente fra:

```text
bin/ext/
bin/ext-<osarch>/
```

Non viene introdotto un livello intermedio `catalog-<platform>`.

---

## 4. Selezione dello stream

Per un target `T`:

```text
se <pkg>/catalog-T/ esiste
    -> usa esclusivamente catalog-T
altrimenti se <pkg>/catalog/ esiste
    -> usa catalog
altrimenti
    -> package non disponibile per il target richiesto
```

Quando `catalog-T` esiste, non esiste fallback per-versione o merge con `catalog`.

Stream differenti dello stesso package sono indipendenti e possono usare repository upstream correnti e storie di versioning differenti.

---

## 5. Relazione fra stream e identità installata

Se viene usato:

```text
catalog
```

la concrete package identity è:

```text
<pkg>@<version>
```

e il selector current è:

```text
<pkg>
```

Se viene usato:

```text
catalog-<osarch>
```

la concrete package identity è:

```text
<pkg>@<version>!<osarch>
```

e il selector current è:

```text
<pkg>!<osarch>
```

Non viene introdotto alcun target fittizio `any`, `any-any` o equivalente.

La target-independence riguarda l'intero package materializzato, inclusi dependency binding e altri elementi install-time.

---

## 6. Layout interno dello stream

Ogni stream disponibile contiene:

```text
repository/
nNNNN=<version-minimum>/
...
```

Esempio:

```text
foo/catalog/
├── repository/
│   └── type
├── n0001=1.0/
├── n0002=2.0/
├── n0003=v35/
├── n0004=2026-Q1/
└── n0005=v01-Kidding-Penguin/
```

`repository/` è il descriptor dichiarativo del repository upstream corrente dello stream.

Contiene file scalari e obbligatoriamente:

```text
repository/type
```

Gli altri campi di `repository/` sono repository-type-specific e vengono definiti dal relativo adapter.

`repository/` non è shell code e non viene source/eval.

I singoli range non selezionano repository upstream storici differenti.

---

## 7. Directory dei range

Ogni package definition di range è introdotta da una directory con forma esatta:

```text
nNNNN=<version-minimum>
```

`nNNNN` usa quattro cifre decimali, parte da `n0001` ed è contiguo nello stream.

`<version-minimum>` usa la grammatica upstream già fissata:

```text
[A-Za-z0-9][A-Za-z0-9._+~-]*
```

Il carattere `=` è il separatore strutturale fra l'ordinale RumiAI e la versione upstream ed è ammesso esclusivamente in questo ruolo.

---

## 8. Significato di `nNNNN`

`nNNNN` ordina le package definition all'interno dello stream.

Non è:

```text
versione upstream
compatibility version
package revision
provider ranking
release-order universale
generation
parte della concrete package identity
```

La stringa upstream dopo `=` resta opaca e non viene usata per ordinare le directory.

Il limite corrente è `n9999`; un'eventuale estensione richiede una decisione esplicita.

---

## 9. Successione upstream autorevole

La successione delle versioni attualmente installabili non è memorizzata nel catalogo.

Viene ottenuta dal repository upstream corrente dello stream tramite:

```text
pkg_repository_list_versions
```

che restituisce semanticamente tutte le versioni installabili correnti in ordine:

```text
oldest -> latest
```

Il core `pkg` usa soltanto la posizione nella successione e non confronta semanticamente le stringhe upstream.

---

## 10. Validità degli anchor

Ogni `<version-minimum>` deve comparire esattamente una volta nella successione corrente restituita da `pkg_repository_list_versions`.

Le posizioni degli anchor devono essere strettamente crescenti nello stesso ordine degli `nNNNN`.

Esempio:

```text
catalog:
    n0001=1.0
    n0002=2.0
    n0003=v35

upstream:
    1.0
    1.1
    2.0
    2.7
    v35
    v36
```

Un anchor assente o fuori ordine rende il catalogo incoerente rispetto all'upstream corrente.

---

## 11. Semantica del range

Per una versione concreta presente nella successione upstream, il range applicabile è quello dell'ultimo anchor che non viene dopo la versione nella successione.

Quindi:

```text
n0001=1.0
n0002=3.0
n0003=5.0
```

continua a rappresentare concettualmente:

```text
n0001   da 1.0 fino a prima di 3.0
n0002   da 3.0 fino a prima di 5.0
n0003   da 5.0 in avanti
```

ma "prima di" indica la posizione nella successione fornita dall'adapter, non un confronto lessicografico, numerico o SemVer.

---

## 12. Versione esplicita

Per una versione esplicita, `pkg`:

```text
seleziona stream
-> legge repository/type
-> carica in isolamento l'adapter RumiAI selezionato
-> l'adapter valida/legge gli altri campi scalari repository-specific
-> pkg_repository_list_versions
-> localizza versione richiesta e anchor per posizione
-> seleziona un solo range
```

Se la versione richiesta non compare nella successione corrente, non è installabile attraverso il repository corrente.

Non vengono consultati repository storici o adapter diversi per range.

---

## 13. Versione omessa e `latest`

Per `pkg install`, l'assenza di `@<version>` significa sempre:

```text
latest upstream disponibile
```

`pkg_repository_resolve_version` risolve `latest` attraverso il repository corrente.

La versione risolta deve essere coerente con l'ultima versione della successione di `pkg_repository_list_versions` per lo stesso repository/context.

Per installare `latest`, `pkg` può selezionare direttamente l'ultimo range e non è obbligato a enumerare tutte le versioni soltanto per questa operazione.

---

## 14. Nuove versioni e chiusura dei range

Una nuova release pubblicata dopo l'ultimo anchor appartiene automaticamente all'ultimo range finché non richiede una package definition differente.

Esempio:

```text
n0005=v01-Kidding-Penguin
```

copre automaticamente successive release come:

```text
v02-Happy-Otter
v03-Serious-Wombat
```

finché non viene aggiunto, per esempio:

```text
n0006=v03-Serious-Wombat
```

L'aggiunta del nuovo range chiude quello precedente alla release immediatamente precedente nella successione upstream.

La package definition del range precedente può e, quando necessario, deve essere aggiornata nello stesso cambiamento per rendere esatti i requisiti del range ormai chiuso.

---

## 15. Inserimento retroattivo

Può emergere che una package definition differente fosse necessaria in un punto storico intermedio.

Esempio:

```text
prima:
    n0001=1.0
    n0002=5.0

correzione:
    n0001=1.0
    n0002=3.0
    n0003=5.0
```

Gli ordinali successivi possono essere rinumerati perché `nNNNN` è esclusivamente ordine interno del catalogo e non viene persistito in package identity, selector, provider index, binding, state o command binding.

---

## 16. Anchor rimossi upstream

Il catalogo corrente descrive le versioni attualmente installabili.

Se un anchor non è più esposto dal repository corrente ma restano versioni dello stesso range, l'anchor viene spostato alla prima versione ancora disponibile di quel range.

Se nessuna versione installabile appartiene più al range, il range viene rimosso e gli ordinali successivi vengono rinumerati.

Git conserva la storia precedente.

---

## 17. Nessuna lista statica e nessun `match`

Il baseline non mantiene liste esaustive delle versioni dentro i range.

Non viene inoltre introdotta una funzione, API o file eseguibile `match` package-specific per la membership del range.

La successione upstream più gli anchor coprono il caso corrente senza duplicare il repository e senza eseguire codice arbitrario dalla package definition.

Una futura primitive di matching richiede un caso concreto e una nuova decisione esplicita.

---

## 18. Repository type

`repository/type` identifica l'adapter RumiAI per lo stream.

I repository type comuni iniziali includono:

```text
github
sourceforge
maven
```

Non esiste nel baseline corrente:

```text
custom
```

Per un prodotto con upstream non aderente a un repository type comune già supportato viene introdotto un type/adapter product-specific dedicato. La generalizzazione verso un type condiviso avviene soltanto quando emerge un contratto comune concreto.

---

## 19. Lineage non lineari

Il baseline richiede che `pkg_repository_list_versions` possa rappresentare una successione totale semanticamente valida per lo stream.

Branch paralleli, LTS concorrenti, backport o altre strutture non linearizzabili correttamente restano fuori dal baseline e richiederanno un'estensione esplicita quando emergerà un caso reale.

---

## 20. Contenuto semantico di una package definition di range

La directory `nNNNN=<version-minimum>/` contiene la package definition specifica del range e deve poter esprimere, quando applicabile:

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
altre informazioni di integrazione già previste dal modello package corrente
```

I dati semanticamente indicati come:

```text
archive_regex
digest_regex
digest_type
```

appartengono alla range definition e non a `repository/`.

Repository type e coordinate upstream correnti appartengono invece a `repository/`.

La serializzazione interna completa della range definition resta da fissare separatamente.

Il catalog descriptor `repository/` non diventa shell code arbitrariamente sourced.

---

## 21. Revisionabilità e provenance

Il Git commit del repository catalogo identifica uno snapshot esatto delle package definition.

Non viene introdotta una seconda numerazione RumiAI di revisione delle package definition.

Una singola operazione multi-package dovrebbe usare uno stesso snapshot Git del catalogo; il backend di sync/cache resta da fissare.

---

## 22. Implementazione e testing futuro

Alla data di questa decisione il catalogo non è implementato in `rumiai-os` e non esistono test permanenti `pkg`/catalogo in `rumiai-tests`.

Quando implementato, i test dovranno proteggere almeno:

```text
lookup package-first
precedenza completa catalog-<osarch> su catalog
assenza di merge per-versione
repository/ unico a livello stream
repository/type obbligatorio
repository descriptor dichiarativo/non sourced
assenza di repository storici per-range
assenza di custom baseline
supporto a type product-specific quando introdotti
identità generic/target-specific corrette
validazione nNNNN=<version-minimum>
ordinali contigui da n0001
pkg_repository_list_versions oldest -> latest
anchor presenti e ordinati nella successione
resolution esplicita per posizione
versione assente -> errore
nuove release -> ultimo range automaticamente
latest coerente con la successione
riallineamento anchor scomparsi
rimozione range senza versioni disponibili
nessuna lista statica per range
nessuna primitive match
nessun comparatore universale
archive/digest selection range-level
```

Questa decisione è documentale e non richiede physical validation separata.

---

## 23. Invarianti fissati

```text
PKG-CATALOG-01  il repository concreto delle package definition è massimilianonardi-ai/pkg-catalog
PKG-CATALOG-02  il lookup parte da <pkg>/
PKG-CATALOG-03  catalog è lo stream completo platform-independent
PKG-CATALOG-04  catalog-<osarch> è lo stream completo target-specific
PKG-CATALOG-05  catalog-<osarch> prevale interamente; nessun merge/fallback per-versione
PKG-CATALOG-06  catalog è fallback completo solo se catalog-<osarch> è assente
PKG-CATALOG-07  non esiste catalog-<platform> nel baseline
PKG-CATALOG-08  catalog produce <pkg>@<version> e selector <pkg>
PKG-CATALOG-09  catalog-<osarch> produce <pkg>@<version>!<osarch> e selector <pkg>!<osarch>
PKG-CATALOG-10  non esiste target fittizio any/any-any
PKG-CATALOG-11  ogni stream disponibile contiene una sola directory repository/ del repository upstream corrente
PKG-CATALOG-12  repository/type è obbligatorio; repository/ contiene file scalari dichiarativi e non viene eseguito
PKG-CATALOG-13  repository type e coordinate correnti appartengono allo stream, non al range
PKG-CATALOG-14  github, sourceforge e maven sono type comuni iniziali; custom non è baseline
PKG-CATALOG-15  upstream non standard può usare un type/adapter product-specific dedicato
PKG-CATALOG-16  ogni range usa nNNNN=<version-minimum>
PKG-CATALOG-17  nNNNN parte da n0001, usa quattro cifre ed è contiguo
PKG-CATALOG-18  version-minimum usa [A-Za-z0-9][A-Za-z0-9._+~-]*
PKG-CATALOG-19  = è separatore semantico esclusivo dei range del catalogo
PKG-CATALOG-20  nNNNN ordina package definition e non è release-order universale
PKG-CATALOG-21  la successione installabile viene dall'upstream corrente tramite pkg_repository_list_versions
PKG-CATALOG-22  ogni anchor deve comparire una volta e in ordine crescente nella successione
PKG-CATALOG-23  il range è determinato dalla posizione della versione rispetto agli anchor
PKG-CATALOG-24  nuove release successive all'ultimo anchor appartengono automaticamente all'ultimo range
PKG-CATALOG-25  un nuovo range chiude il precedente nella successione upstream
PKG-CATALOG-26  un inserimento storico può rinumerare range perché nNNNN non è persistito fuori dal catalogo
PKG-CATALOG-27  anchor scomparsi vengono riallineati alle versioni ancora installabili; range vuoti vengono rimossi
PKG-CATALOG-28  il catalogo non mantiene liste statiche esaustive per range
PKG-CATALOG-29  non esiste una primitive match nel baseline
PKG-CATALOG-30  lineage non linearizzabili correttamente restano fuori dal baseline
PKG-CATALOG-31  latest omessa è risolta a una versione upstream concreta tramite repository corrente
PKG-CATALOG-32  archive_regex, digest_regex e digest_type sono range-level e non repository-level
PKG-CATALOG-33  Git identifica la revisione naturale del catalogo
PKG-CATALOG-34  la serializzazione completa della range definition resta il prossimo contratto separato
```
