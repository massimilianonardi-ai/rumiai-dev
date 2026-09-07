# Decisione — Catalogo delle package definition, stream per target e range ordinati

Date: 2026-09-07  
Status: **Accepted**

## Contesto

La pipeline corrente di `pkg` separa repository-specific discovery/resolution, download, extract e integrazione RumiAI. Per trasformare un operand pubblico come `foo`, `foo@1.2`, `foo!linux-arm64` o `foo@1.2!linux-arm64` in una installazione concreta serve una package definition autorevole che descriva repository upstream, artifact e regole di integrazione.

Le versioni upstream non possiedono nel modello RumiAI un comparatore universale. Uno stesso prodotto può cambiare convenzione di naming nel tempo oppure usare convenzioni differenti per target diversi, per esempio:

```text
1.0
2.0
v35
2026-Q1
v01-Kidding-Penguin
```

Il catalogo deve quindi poter ordinare le regioni di applicabilità delle package definition senza interpretare genericamente tali stringhe.

Questa decisione fissa il primo contratto di catalogo. Non fissa ancora la serializzazione interna completa di una singola package definition né il meccanismo locale di cache/sync del catalogo.

Questa unità modifica soltanto `rumiai-dev`. Non autorizza modifiche a `rumiai-os` o `rumiai-tests`.

---

## 1. Sorgente iniziale del catalogo

La sorgente iniziale delle package definition è un repository GitHub configurato appartenente a RumiAI e dedicato alle sole package definition.

Questa decisione non fissa ancora:

```text
nome/URL concreto del repository
chiave o file di configurazione locale
meccanismo di clone/fetch/cache/snapshot
policy di aggiornamento
```

Tali aspetti devono preservare relocatability e configurazione esplicita secondo le regole generali RumiAI.

La package definition resta distinta dall'artifact upstream e il catalogo non diventa un repository di payload software.

---

## 2. Lookup package-first

La prima chiave fisica del catalogo è il nome canonico del package:

```text
<pkg>/
```

Esempio concettuale:

```text
foo/
bar/
java/
```

Questo rende il lookup di `pkg install foo` diretto e non richiede una ricerca globale per target prima di identificare il package.

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

Non viene introdotto in questa baseline un livello intermedio `catalog-<platform>`.

`<osarch>` continua a usare il vocabulary canonico RumiAI `<platform>-<architecture>`.

---

## 4. Selezione dello stream

Per un target `T`, determinato dall'operand esplicito oppure dal target corrente quando l'operand non lo specifica, la selezione è:

```text
se <pkg>/catalog-T/ esiste
    -> usa esclusivamente catalog-T
altrimenti se <pkg>/catalog/ esiste
    -> usa catalog
altrimenti
    -> package non disponibile per il target richiesto
```

Quando `catalog-T` esiste, non esiste fallback per-versione o merge con `catalog`.

Quindi:

```text
catalog-T presente
    -> catalog-T è lo stream completo per T

catalog-T assente
    -> catalog è il solo fallback completo
```

Questa regola evita inheritance, override parziali e merge impliciti fra package definition.

Stream differenti dello stesso package possono avere storie di versioning upstream completamente differenti. Per esempio:

```text
foo/catalog-linux-x86_64/
    ... 2.3 ...

foo/catalog-windows-x86_64/
    ... v35 ...
```

non richiede che `2.3` e `v35` appartengano a una numerazione comune.

---

## 5. Relazione fra stream e identità installata

L'uso dello stream selezionato determina se la versione concreta è platform-independent oppure target-specific.

Se viene usato:

```text
catalog
```

la concrete package identity è non qualificata:

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

Un target esplicitamente richiesto sulla CLI serve a selezionare lo stream corretto; se per quel target non esiste `catalog-<osarch>` e viene quindi usato `catalog`, l'identità installata resta platform-independent e non acquisisce artificialmente il target richiesto.

La sola indipendenza dell'artifact upstream non è sufficiente a rendere platform-independent l'intero package RumiAI. Se la materializzazione, le dependency risolte, i command entry, l'env o altri elementi del package devono differire per target, il package deve usare lo stream `catalog-<osarch>` pertinente.

In particolare una versione concreta non qualificata non deve contenere resolved binding verso provider qualificati per un singolo `<osarch>`: ciò renderebbe target-specific un oggetto dichiarato platform-independent.

---

## 6. Directory dei range

Dentro ciascuno stream, ogni nuova package definition è introdotta da una directory con forma esatta:

```text
nNNNN=<version-minimum>
```

La parte `nNNNN` usa quattro cifre decimali e parte da:

```text
n0001
```

Esempio:

```text
foo/catalog/
├── n0001=1.0/
├── n0002=2.0/
├── n0003=v35/
├── n0004=2026-Q1/
└── n0005=v01-Kidding-Penguin/
```

`<version-minimum>` è la versione upstream esatta che introduce quella package definition e usa lo stesso dominio lessicale delle versioni upstream ammesse dal package manager:

```text
[A-Za-z0-9][A-Za-z0-9._+~-]*
```

Il carattere `=` è il separatore strutturale fra l'ordinale RumiAI e la versione upstream. Poiché `=` non appartiene al dominio di `<version>`, la separazione è non ambigua.

L'uso di `=` in questo pathname è una eccezione semantica limitata alle directory range del package-definition catalog e non modifica la naming convention generale di RumiAI.

---

## 7. Significato dell'ordinale `nNNNN`

`nNNNN` ordina le **package definition range** all'interno di un singolo stream.

Non è:

```text
versione upstream
compatibility version
package revision
provider ranking
release-order universale
generation del resolver storico
parte della concrete package identity
```

L'ordine normativo è quello numerico dell'ordinale, che coincide con l'ordine lessicografico del prefisso grazie alla larghezza fissa di quattro cifre.

La stringa upstream dopo `=` resta opaca e non viene usata per ordinare le directory.

Quindi un cambio arbitrario di naming upstream non altera l'ordine del catalogo:

```text
n0003=v35
n0004=2026-Q1
n0005=v01-Kidding-Penguin
```

resta ordinato esattamente come dichiarato dal maintainer del catalogo.

---

## 8. Continuità degli ordinali

Nella baseline gli ordinali presenti in uno stream sono contigui:

```text
n0001
n0002
n0003
...
```

senza duplicati o gap intenzionali.

Il limite della forma corrente è quindi `n9999`. Se un package reale dovesse richiedere più di 9999 cambi di package definition nello stesso stream, il formato verrà esteso con una decisione esplicita invece di cambiare silenziosamente la grammatica.

Non vengono adottati ora ordinali sparsi come `n0100`, `n0200`: la semplicità di validazione e lettura prevale sul risparmio di rename in un caso retroattivo raro.

---

## 9. Semantica del range

Una directory:

```text
nNNNN=<version-minimum>
```

introduce la package definition valida a partire da quella release nella lineage upstream dello stream.

La package definition resta applicabile fino alla release immediatamente precedente il `<version-minimum>` della directory successiva.

Quindi, concettualmente:

```text
n0001=1.0
n0002=3.0
n0003=5.0
```

rappresenta:

```text
n0001   da 1.0 fino a prima di 3.0
n0002   da 3.0 fino a prima di 5.0
n0003   da 5.0 in avanti
```

L'ultimo range è sempre aperto verso le release successive finché non viene aggiunta una nuova directory.

L'espressione "prima di" descrive la posizione nella lineage upstream dello specifico stream; non introduce un confronto lessicografico, SemVer o numerico universale fra stringhe `<version>`.

Le API repository devono fornire le informazioni repository-specific necessarie a risolvere versioni concrete e, quando serve, a collocarle rispetto agli anchor di range senza promuovere un comparatore universale nel core `pkg`.

La firma/serializzazione esatta con cui `pkg_repository_list_versions` rappresenterà la sequenza di versioni viene chiusa insieme al primo adapter concreto.

---

## 10. Aggiunta di un nuovo range in coda

Quando una nuova release introduce una package definition differente, viene aggiunta la directory con l'ordinale successivo.

Esempio:

```text
prima:
    n0004=2026-Q1

poi arriva una nuova famiglia:
    n0005=v01-Kidding-Penguin
```

L'aggiunta di `n0005` chiude strutturalmente il range di `n0004` alla release immediatamente precedente nella lineage upstream.

La precedente package definition può e, quando necessario, deve essere aggiornata nello stesso cambiamento per rendere esatti i requisiti ormai conosciuti del range chiuso.

Esempio concettuale:

```text
prima, ultimo range:
    java >=21

quando nasce il range successivo:
    range precedente -> java >=21 <=25
    nuovo range      -> nuovo constraint appropriato
```

Il catalogo rappresenta la conoscenza packaging corrente; non è immutabile. Git conserva la storia delle modifiche e permette di ricostruire la precedente conoscenza del catalogo.

---

## 11. Inserimento retroattivo

Può emergere in seguito che una differente package definition era necessaria in un punto storico intermedio.

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

In questo caso gli ordinali successivi possono essere rinumerati.

Questo è sicuro perché `nNNNN` è esclusivamente ordine interno del catalogo e **non deve essere persistito** in:

```text
concrete package identity
selector current
facility/provider marker
binding/<facility>
package state identity
public command binding
```

Il costo della rinumerazione è limitato al diff Git del catalogo e a eventuali conflitti di manutenzione nello stesso stream.

Se l'inserimento retroattivo diventasse frequente nella pratica, una futura decisione potrà valutare ordinali sparsi o un diverso indice senza cambiare le identità installate.

---

## 12. Lineage non lineari

La baseline dei range ordinati assume che ciascun singolo stream `catalog*` descriva una lineage upstream linearmente ordinabile per le release che deve supportare.

Branch paralleli, backport pubblicati fuori sequenza, linee LTS contemporanee o altri casi nei quali una singola successione di anchor non identifica univocamente l'applicabilità non vengono forzati dentro questo modello.

Quando emergerà un package concreto con tale necessità, dovrà essere introdotta una rappresentazione esplicita proporzionata del membership/routing di versione. Non vengono anticipati ora pattern, OR, branch labels o un comparatore universale.

---

## 13. Versione omessa e `latest`

Per `pkg install`, l'assenza di `@<version>` nell'operand significa sempre:

```text
ultima versione upstream disponibile
```

La versione viene risolta tramite:

```text
pkg_repository_resolve_version
```

usando la package definition dell'ultimo range dello stream selezionato.

`latest` è una richiesta di resolution e non diventa una pseudo-versione installata. Prima di download e integrazione deve esistere una versione upstream concreta.

Questa regola riguarda `install`. `uninstall` resta local-only e non deve trasformare l'assenza di versione in una query upstream per `latest`; la policy locale di rimozione senza versione esplicita resta parte del lifecycle uninstall da fissare separatamente.

---

## 14. Contenuto semantico di una package definition

La serializzazione fisica interna della directory range resta il prossimo contratto da chiudere, ma una package definition deve poter esprimere, quando applicabile, almeno:

```text
repository type
repository-specific project/artifact coordinates
artifact selection/materialization information
artifact format
integrity/provenance information quando disponibile o richiesta
facility
dependency
cmd/
link/
env
default/
state/path normalization information
altre informazioni di integrazione già previste dal modello package corrente
```

La package definition non deve essere sostituita da una composite string ad hoc nella CLI né da un manifest shell arbitrariamente sourced.

I file che il modello package ha già definito come shell code, come `env` e i command entry, mantengono il proprio contratto specifico; ciò non trasforma il catalog descriptor generale in shell code.

---

## 15. Revisionabilità e provenance

Il Git commit del repository catalogo identifica uno snapshot esatto delle package definition.

Non viene introdotta ora una seconda numerazione RumiAI di revisione delle package definition soltanto per duplicare la funzione già svolta da Git.

Una singola operazione multi-package dovrebbe risolvere le package definition rispetto a uno stesso snapshot del catalogo, così che il catalogo non cambi semanticamente a metà della stessa operazione. Il meccanismo operativo con cui lo snapshot viene acquisito/cacheato verrà fissato insieme al backend catalogo.

---

## 16. Testing futuro

Alla data di questa decisione il catalogo non è ancora implementato in `rumiai-os` e non esistono test permanenti `pkg`/catalogo in `rumiai-tests`.

Quando implementato, i test dovranno proteggere almeno:

```text
lookup package-first
precedenza completa catalog-<osarch> su catalog
fallback a catalog solo quando catalog-<osarch> è assente
assenza di merge per-versione fra i due stream
identità non qualificata quando viene usato catalog
identità qualificata quando viene usato catalog-<osarch>
assenza di any/any-any
validazione nNNNN=<version-minimum>
ordinali contigui da n0001
ordinamento indipendente dalla sintassi upstream
ultimo range aperto
chiusura del precedente quando viene aggiunto un nuovo range
rinumerazione retroattiva non propagata alle identità installate
rifiuto/gestione esplicita di lineage non lineari non rappresentabili
versione install omessa -> latest concreta
```

Questa decisione è documentale e non richiede physical validation separata.

---

## 17. Invarianti fissati

```text
PKG-CATALOG-01  la sorgente iniziale delle package definition è un repository GitHub RumiAI configurato e dedicato alle package definition
PKG-CATALOG-02  il lookup fisico parte da <pkg>/
PKG-CATALOG-03  <pkg>/catalog è lo stream completo platform-independent
PKG-CATALOG-04  <pkg>/catalog-<osarch> è lo stream completo specifico dell'esatto target <osarch>
PKG-CATALOG-05  se catalog-<osarch> esiste prevale interamente; non esiste merge/fallback per-versione con catalog
PKG-CATALOG-06  catalog è usato come fallback completo soltanto quando catalog-<osarch> è assente
PKG-CATALOG-07  non esiste nella baseline un catalog-<platform> intermedio
PKG-CATALOG-08  catalog produce concrete identity <pkg>@<version> e selector <pkg>
PKG-CATALOG-09  catalog-<osarch> produce concrete identity <pkg>@<version>!<osarch> e selector <pkg>!<osarch>
PKG-CATALOG-10  non viene introdotto alcun target fittizio any/any-any
PKG-CATALOG-11  una versione concreta non qualificata deve essere interamente target-independent, inclusi i resolved binding materializzati
PKG-CATALOG-12  ogni range directory usa esattamente nNNNN=<version-minimum>
PKG-CATALOG-13  nNNNN parte da n0001, usa quattro cifre ed è contiguo nello stream
PKG-CATALOG-14  <version-minimum> è una versione upstream esatta con grammatica [A-Za-z0-9][A-Za-z0-9._+~-]*
PKG-CATALOG-15  = è separatore semantico ammesso esclusivamente nel pathname range del catalogo
PKG-CATALOG-16  nNNNN ordina package-definition range e non è versione upstream, compatibility, revision, ranking, generation o concrete identity
PKG-CATALOG-17  la sintassi della versione upstream non determina l'ordine dei range
PKG-CATALOG-18  ogni range parte dal proprio version-minimum e termina prima del version-minimum del range successivo nella lineage dello stream
PKG-CATALOG-19  l'ultimo range è aperto fino all'introduzione di un range successivo
PKG-CATALOG-20  aggiungere un nuovo range può richiedere di correggere la package definition del range precedente ormai chiuso
PKG-CATALOG-21  un inserimento storico può rinumerare i range successivi perché nNNNN non è persistito fuori dal catalogo
PKG-CATALOG-22  la baseline non forza lineage upstream non lineari dentro una successione ambigua di range
PKG-CATALOG-23  per pkg install, versione omessa significa latest upstream e deve essere risolta a una versione concreta
PKG-CATALOG-24  lo snapshot Git del catalogo è la provenance naturale della revisione delle package definition; non viene introdotta una revision RumiAI duplicata
PKG-CATALOG-25  la serializzazione interna completa della singola package definition e il backend locale di catalog sync/cache restano il prossimo contratto separato
```
