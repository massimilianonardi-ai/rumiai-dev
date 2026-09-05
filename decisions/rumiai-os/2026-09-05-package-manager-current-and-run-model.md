# Decisione — Package manager: selezione `current` e `pkg run`

Date: 2026-09-05  
Status: **Accepted**

## Contesto

Il package manager progettato il 2026-08-30 aveva anticipato un modello molto ampio: Package Instance con struttura interna rigida, root immutabile, State Instance versionate, aree di stato tipizzate, resolver di capability, Desired/Resolved Integration Profile, generations, inventory di integrità e recovery transazionale.

Successivamente il runtime RumiAI OS ha fissato un nuovo layout degli executable root (`bin/sys*` e `bin/ext*`) e il progetto ha scelto di rivalutare il package manager cercando un compromesso più piccolo, concreto e proporzionato alla complessità reale del software gestito.

Questa decisione fissa la nuova baseline per selezione della versione, esposizione dei comandi third-party ed esecuzione mediata tramite `pkg run`.

I documenti precedenti sotto:

```text
drafts/rumiai-os/package-manager-*
```

restano materiale storico e input di progettazione, ma **non sono più autorità sul design corrente di `pkg`** quando introducono contratti non riaffermati da questa o da successive decisioni Accepted. Le diciture storiche come `fissato` o `formalizzato` contenute in quei draft descrivono lo stato del design al 2026-08-30 e non prevalgono su questa decisione.

La decisione non modifica il runtime/bootstrap corrente e non autorizza in questa unità di lavoro modifiche a `rumiai-os`.

---

## 1. Principio di complessità proporzionata

`pkg` non deve imporre a ogni software il massimo livello di gestione previsto per il caso più difficile.

La baseline è:

> la complessità del package manager cresce soltanto quando una necessità concreta del software la richiede.

In particolare:

- un tool eseguibile direttamente non deve pagare il costo di un modello di state, dependency o launcher che non usa;
- un'applicazione con stato facilmente controllabile può essere mediata da `pkg run` e dal proprio packaging;
- software difficilmente controllabile non deve complicare preventivamente il percorso normale di tutti gli altri package.

Le descrizioni conversazionali di questi casi non introducono nomi, classi o namespace di prodotto.

---

## 2. Store locale e coesistenza di più versioni

I package installati localmente appartengono al dominio:

```text
$m_ROOT/pkg/
```

Più versioni concrete dello stesso package possono coesistere contemporaneamente.

La forma esatta del pathname di una versione installata **non è fissata da questa decisione**. In particolare non viene automaticamente mantenuta la precedente grammatica:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

né il precedente percent encoding della versione.

Questi aspetti saranno definiti soltanto quando serviranno al primo layout concreto di `pkg`.

---

## 3. Selezione `current`

Per ogni package gestito che dispone di una versione selezionata per l'esecuzione normale, `pkg` mantiene una selezione persistente della versione predefinita, chiamata concettualmente **`current`**.

Il selector `current` esiste anche quando è installata una sola versione: in quel caso punta a quella versione. Quando più versioni convivono, `current` identifica quale di esse è il default persistente.

La selezione è rappresentata da un **symbolic link relativo** sotto il dominio `pkg/` e punta alla versione concreta selezionata.

La selezione deve poter essere qualificata per il target RumiAI `<osarch>` quando necessario, così che una stessa root possa contenere software e default appropriati a target differenti senza ambiguità.

Questa decisione **non fissa ancora**:

- il pathname esatto del symlink `current`;
- se i package realmente indipendenti dal target possano condividere una selezione non qualificata;
- la grammatica esatta con cui package name e `<osarch>` compaiono nel pathname.

Principio fondamentale:

> **`current` seleziona una versione; non costruisce l'ambiente di esecuzione.**

Cambiare `current` cambia il default persistente. Un override usato per una singola esecuzione non deve modificare `current`.

---

## 4. `pkg` come comando RumiAI

Il package manager è esposto dal comando RumiAI:

```text
pkg
```

Quando verrà implementato come comando platform-independent, la sua collocazione coerente con il runtime corrente è:

```text
bin/sys/pkg
```

Il sottocomando di esecuzione mediata fissato da questa decisione è:

```text
pkg run <package>
```

La sintassi completa di `pkg`, gli altri eventuali sottocomandi e i relativi exit status non sono fissati da questa decisione.

---

## 5. Binding pubblici dei comandi third-party

Il layout runtime corrente resta normativo:

```text
bin/ext/
bin/ext-<osarch>/
bin/ext-osarch -> ext-<osarch>
```

Queste directory devono essere interpretate come **binding pubblici di comandi third-party**.

Un binding può essere realizzato in due forme:

1. symbolic link diretto;
2. wrapper/launcher minimale RumiAI che delega a `pkg run`.

La presenza di un wrapper RumiAI non trasforma il comando esposto in un comando di sistema RumiAI: il binding appartiene a `bin/ext*` perché espone software third-party.

La scelta fra `bin/ext/` e `bin/ext-<osarch>/` dipende dalla validità del binding rispetto al target, non dal linguaggio con cui un eventuale wrapper è implementato.

Questa decisione affina quindi la precedente descrizione di `bin/ext*` come semplice insieme di third-party executable/symlink senza modificare il layout o la precedenza del `PATH`.

---

## 6. Binding diretto

Un comando third-party può essere esposto tramite symbolic link diretto quando la sua esecuzione non richiede mediazione da parte di `pkg run`.

Il criterio non è semplicemente "non produce file". Il binding diretto è appropriato quando il launch reale si riduce sostanzialmente all'esecuzione dell'executable con gli argomenti dell'utente e non richiede, per esempio:

- environment package-specific;
- HOME/data/cache private;
- dependency privata da selezionare;
- working directory speciale;
- argomenti fissi di launch;
- altra preparazione o adattamento richiesto da RumiAI.

Il normale binding diretto del comando deve risolvere attraverso la selezione `current`, così che il nome pubblico esegua il default persistente senza pinning accidentale a una versione concreta.

L'esecuzione attraverso un binding diretto non coinvolge `pkg run` e quindi non applica override per-invocation che richiedono la mediazione del package manager.

---

## 7. Binding gestito tramite wrapper

Quando il launch richiede mediazione, il binding pubblico è un wrapper minimale che delega a `pkg run`.

Il wrapper non deve duplicare la logica di:

- selezione della versione;
- risoluzione del package concreto;
- costruzione dell'environment;
- routing dello state;
- scelta delle dependency;
- altre regole package-specific gestite dal package manager o dai metadata del package.

Concettualmente:

```text
public command
    -> minimal wrapper
        -> pkg run <package>
            -> selected concrete package
            -> prepared execution
```

La forma fisica e l'interprete del wrapper saranno definiti durante il design concreto del launcher; questa decisione non introduce un nuovo formato di wrapper.

---

## 8. Responsabilità di `pkg run`

Principio fondamentale:

> **`pkg run` costruisce un'esecuzione.**

Per l'invocazione corrente `pkg run` può, quando necessario:

1. determinare il target RumiAI corrente;
2. usare la versione indicata da `current`;
3. applicare un override esplicito di versione per la sola invocazione;
4. individuare il comando/entrypoint richiesto nel package;
5. costruire environment e pathname necessari;
6. indirizzare HOME, data, cache o altre aree mutabili verso location controllate;
7. selezionare o collegare dependency necessarie al launch;
8. applicare working directory, argomenti fissi o altri adattamenti dichiarati dal packaging;
9. eseguire il programma e inoltrare gli argomenti dell'utente.

Gli override di versione, state o environment usati da una singola invocazione non modificano automaticamente la selezione persistente `current`.

I nomi delle option e delle environment variables che realizzano questi override restano aperti. Eventuali environment variables proprie di RumiAI dovranno rispettare il namespace corrente `m_*`.

Quando la sintassi di `pkg run` accetta argomenti destinati al programma lanciato, il confine tra option/operandi di `pkg` e argomenti del programma deve essere esplicito; l'uso di `--` deve seguire le regole CLI RumiAI/POSIX già fissate.

---

## 9. Package e comando sono concetti distinti

Un package può offrire uno o più comandi.

Esempio concettuale:

```text
package JDK
    java
    javac
    jar
    javadoc
```

Quindi:

```text
package != command
```

`pkg run <package>` resta la forma base fissata per un package con entrypoint predefinito, ma il modello deve poter identificare anche un entrypoint specifico quando il package ne espone più di uno.

La sintassi CLI concreta e il formato dei metadata che descrivono gli entrypoint restano aperti.

---

## 10. Stato mutabile

Resta valido il principio generale:

```text
software != stato mutabile prodotto durante l'uso
```

ma la nuova baseline **non impone** il precedente State Instance model a ogni package.

Non sono parte obbligatoria del baseline corrente:

```text
conf
data
home
cache
log
run
tmp
```

come sette aree universali del package manager, né identity `@sN`, state scope o migration framework generico.

Per software che necessita di stato, il packaging può descrivere come `pkg run` deve indirizzare HOME, configurazione, cache, data, moduli aggiuntivi o altre location verso aree controllate.

La struttura fisica canonica dello state package-specific resta da definire.

La conoscenza necessaria a controllare un'applicazione specifica appartiene principalmente al relativo packaging; `pkg` fornisce primitive comuni soltanto quando emergono responsabilità realmente condivise.

---

## 11. Dependency e runtime

`pkg run` deve poter preparare dependency necessarie a un launch quando un package ne ha bisogno, ma la nuova baseline non richiede il precedente resolver universale di capability.

Non sono quindi attualmente obbligatori:

- capability contract generici;
- constraint resolver;
- `release-order`;
- provider ranking;
- Desired/Resolved dependency graph persistito;
- re-resolution/generation model.

Una prima implementazione può usare riferimenti concreti e semplici quando il caso d'uso lo consente. Un resolver più generale potrà essere introdotto soltanto a fronte di requisiti concreti e con decisione esplicita.

---

## 12. Software difficilmente controllabile

Il precedente criterio:

```text
impossibile mantenere una root immutabile
    -> REJECTED
```

non è più una regola universale del package manager.

Software che scrive nel proprio installation tree, usa pathname host difficili da redirigere, esegue self-update o produce effetti difficili da governare può richiedere una strategia separata di isolamento o adattamento.

La baseline iniziale si concentra sui casi gestibili in modo semplice e deterministico. Per i casi difficili si studierà, quando necessario, una strategia universale mirata con isolamento logico e/o adapter platform-specific per isolamento effettivo.

Questa decisione **non fissa** directory o classi chiamate `legacy`, `container` o equivalenti.

---

## 13. Costrutti del design 2026-08-30 non più baseline

I seguenti meccanismi dei draft del 2026-08-30 non devono essere implementati come requisiti del package manager corrente senza una nuova decisione che ne dimostri la necessità:

```text
bin/@platforms
pathname Package Instance obbligatorio con @version@rN@platform-architecture
percent-encoded version-token obbligatorio
root/run-default/run wrapper obbligatoria
root immutabile come requisito universale di admission
inventory SHA-256 obbligatorie per ogni package
State Instance @sN
sette State Area universali
state migration framework universale
Execution Capability contracts universali
resolver generico con release-order/provider ranking
Desired/Resolved Integration Profile
generations gN e active generation
Resolved Dependency Graph persistito obbligatorio
anti-ghost classification HEALTHY/RECOVERABLE/IDENTITY_MISMATCH/UNKNOWN
schema @package v0 obbligatorio nella forma precedente
recovery/lifecycle transazionale completo come prerequisito del primo `pkg`
```

Questo non significa che ogni singola idea sia vietata definitivamente. Significa che **non appartiene più al contratto minimo corrente** e può essere reintrodotta soltanto quando un requisito reale la giustifica.

Restano inoltre definitivamente incompatibili con il runtime corrente i vecchi riferimenti a `bin/` direttamente nel `PATH` e a `bin/@platforms`; valgono i current executable roots `bin/sys*` e `bin/ext*`.

---

## 14. Questioni intenzionalmente aperte

Non vengono fissati in questa decisione:

1. pathname esatto delle versioni concrete sotto `pkg/`;
2. pathname esatto e grammatica del selector `current`;
3. regola finale per selector target-qualified vs condivisi quando il package è realmente target-independent;
4. formato minimo dei metadata/descriptor del package;
5. layout fisico dello state package-specific;
6. nomi delle option di `pkg run`;
7. nomi delle environment variables di override;
8. sintassi per scegliere un entrypoint non-default;
9. formato/interprete fisico dei wrapper in `bin/ext*`;
10. altri sottocomandi pubblici di `pkg` oltre a `run`;
11. modello di acquisition/download/build;
12. eventuale resolver dependency più generale;
13. eventuale sandbox/isolation model per software difficili.

Questi punti aperti non autorizzano a riutilizzare automaticamente i contratti del 2026-08-30.

---

## 15. Implementazione e test

Alla data di questa decisione non esiste ancora un comando `pkg` stabile in `rumiai-os` e non esiste un gruppo permanente di test `pkg` in `rumiai-tests`.

Questa unità di lavoro consolida soltanto il design in `rumiai-dev`.

L'implementazione in `rumiai-os` richiederà esplicita autorizzazione per la relativa fase. Quando saranno fissati i primi comportamenti osservabili, i test permanenti corrispondenti dovranno essere aggiunti in `rumiai-tests` secondo `TESTING.md`, con complessità proporzionata alle proprietà effettivamente implementate.

---

## 16. Invarianti fissati

```text
PKG-01 $m_ROOT/pkg è il dominio locale dei package gestiti
PKG-02 più versioni concrete dello stesso package possono coesistere
PKG-03 ogni package con un default di esecuzione mantiene un selector current, anche con una sola versione installata
PKG-04 il selector current è un symlink relativo
PKG-05 current seleziona una versione; non costruisce l'esecuzione
PKG-06 pkg run è il punto di mediazione per launch che richiedono gestione
PKG-07 un override per-invocation non modifica automaticamente current
PKG-08 un binding third-party pubblico vive in bin/ext o bin/ext-<osarch>
PKG-09 un binding può essere direct symlink o minimal wrapper verso pkg run
PKG-10 il normale direct binding risolve attraverso current ed è ammesso solo quando non serve mediazione di pkg run
PKG-11 package != command; un package può offrire più entrypoint
PKG-12 software e stato mutabile restano semanticamente distinti quando lo stato esiste
PKG-13 nessun State Instance/resolver/generation framework universale è prerequisito del baseline corrente
PKG-14 la complessità specifica di un'app appartiene principalmente al suo packaging
PKG-15 software difficile non impone complessità preventiva al percorso normale
PKG-16 nessun namespace legacy/container è fissato
PKG-17 il vecchio bin/@platforms non appartiene al runtime corrente
PKG-18 i dettagli non esplicitamente riaffermati dei draft package-manager del 2026-08-30 sono da rivalutare, non da assumere
```
