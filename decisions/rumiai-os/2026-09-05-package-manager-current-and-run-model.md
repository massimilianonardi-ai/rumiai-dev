# Decisione — Package manager: selezione `current`, `pkg run` e baseline state/install

Date: 2026-09-05  
Status: **Accepted**

## Contesto

Il package manager progettato il 2026-08-30 aveva anticipato un modello molto ampio: Package Instance con struttura interna rigida, root immutabile, State Instance versionate, aree di stato tipizzate, resolver di capability, Desired/Resolved Integration Profile, generations, inventory di integrita e recovery transazionale.

Successivamente il runtime RumiAI OS ha fissato un nuovo layout degli executable root (`bin/sys*` e `bin/ext*`) e il progetto ha scelto di rivalutare il package manager cercando un compromesso piu piccolo, concreto e proporzionato alla complessita reale del software gestito.

Questa decisione fissa la baseline per selezione della versione, esposizione dei comandi third-party ed esecuzione mediata tramite `pkg run`. Le successive decisioni Accepted del 2026-09-05 hanno inoltre fissato `root/`, `cmd/`, `env`, State Instance minima, `var/`, `default/` e la responsabilita di `pkg install` sui pathname mutabili.

I documenti precedenti sotto:

```text
drafts/rumiai-os/package-manager-*
```

restano materiale storico e input di progettazione, ma **non sono piu autorita sul design corrente di `pkg`** quando introducono contratti non riaffermati da questa o da successive decisioni Accepted. Le diciture storiche come `fissato` o `formalizzato` contenute in quei draft descrivono lo stato del design al 2026-08-30 e non prevalgono sulle decisioni Accepted correnti.

La decisione non modifica il runtime/bootstrap corrente e non autorizza in questa unita di lavoro modifiche a `rumiai-os`.

---

## 1. Principio di complessita proporzionata

`pkg` non deve imporre a ogni software il massimo livello di gestione previsto per il caso piu difficile.

La baseline e:

> la complessita del package manager cresce soltanto quando una necessita concreta del software la richiede.

In particolare:

- un tool eseguibile direttamente non deve pagare il costo di dependency o launcher che non usa;
- un package con stato usa soltanto le state area necessarie;
- un'applicazione con pathname mutabili noti puo essere normalizzata durante `pkg install` senza imporre una mediazione runtime quando non serve;
- software difficilmente controllabile non deve complicare preventivamente il percorso normale di tutti gli altri package.

Le descrizioni conversazionali di questi casi non introducono nomi, classi o namespace di prodotto ulteriori.

---

## 2. Store locale e coesistenza di piu versioni

I package installati localmente appartengono al dominio:

```text
$m_ROOT/pkg/
```

Piu versioni concrete dello stesso package possono coesistere contemporaneamente.

La forma esatta del pathname di una versione installata **non e fissata da questa decisione**. In particolare non viene automaticamente mantenuta la precedente grammatica:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

ne il precedente percent encoding della versione.

Questi aspetti saranno definiti soltanto quando serviranno al primo layout concreto di `pkg`.

---

## 3. Selezione `current`

Per ogni package gestito che dispone di una versione selezionata per l'esecuzione normale, `pkg` mantiene una selezione persistente della versione predefinita, chiamata concettualmente **`current`**.

Il selector `current` esiste anche quando e installata una sola versione: in quel caso punta a quella versione. Quando piu versioni convivono, `current` identifica quale di esse e il default persistente.

La selezione e rappresentata da un **symbolic link relativo** sotto il dominio `pkg/` e punta alla versione concreta selezionata.

La selezione deve poter essere qualificata per il target RumiAI `<osarch>` quando necessario, cosi che una stessa root possa contenere software e default appropriati a target differenti senza ambiguita.

Questa decisione **non fissa ancora**:

- il pathname esatto del symlink `current`;
- se i package realmente indipendenti dal target possano condividere una selezione non qualificata;
- la grammatica esatta con cui package name e `<osarch>` compaiono nel pathname.

Principio fondamentale:

> **`current` seleziona una versione; non costruisce l'ambiente di esecuzione.**

Cambiare `current` cambia il default persistente. Un override usato per una singola esecuzione non deve modificare `current`.

---

## 4. `pkg` come comando RumiAI

Il package manager e esposto dal comando RumiAI:

```text
pkg
```

Quando verra implementato come comando platform-independent, la sua collocazione coerente con il runtime corrente e:

```text
bin/sys/pkg
```

Il sottocomando di esecuzione mediata fissato e:

```text
pkg run <package>
```

E inoltre fissata l'operazione/sottocomando:

```text
pkg install
```

per la responsabilita di installare/normalizzare una versione concreta, inclusa la conoscenza dei pathname upstream mutabili/state-bearing e la costruzione dei relativi routing symlink secondo `2026-09-05-package-state-var-default.md`.

La sintassi completa di `pkg install`, le sorgenti da cui acquisisce il payload, download/build e relativi exit status restano aperti. Il fatto che esista `pkg install` non fissa ancora un modello remoto o di store.

---

## 5. Binding pubblici dei comandi third-party

Il layout runtime corrente resta normativo:

```text
bin/ext/
bin/ext-<osarch>/
bin/ext-osarch -> ext-<osarch>
```

Queste directory devono essere interpretate come **binding pubblici di comandi third-party**.

Un binding puo essere realizzato in due forme:

1. symbolic link diretto;
2. wrapper/launcher minimale RumiAI che delega a `pkg run`.

La presenza di un wrapper RumiAI non trasforma il comando esposto in un comando di sistema RumiAI: il binding appartiene a `bin/ext*` perche espone software third-party.

La scelta fra `bin/ext/` e `bin/ext-<osarch>/` dipende dalla validita del binding rispetto al target, non dal linguaggio con cui un eventuale wrapper e implementato.

---

## 6. Binding diretto

Un comando third-party puo essere esposto tramite symbolic link diretto quando la sua esecuzione non richiede mediazione da parte di `pkg run`.

Il criterio non e semplicemente "non produce file". Il binding diretto e appropriato quando il launch reale si riduce sostanzialmente all'esecuzione dell'executable con gli argomenti dell'utente e non richiede, per esempio:

- environment package-specific da applicare a runtime;
- HOME o altra location da impostare tramite environment;
- dependency privata da selezionare;
- working directory speciale;
- argomenti fissi di launch;
- altra preparazione o adattamento dinamico richiesto da RumiAI.

La presenza di state non rende automaticamente necessaria la mediazione. Se `pkg install` ha gia normalizzato staticamente i pathname mutabili attraverso:

```text
root/<path> -> var/<area>/<path> -> State Instance
```

il command puo ancora usare binding diretto quando non serve altro lavoro al launch.

Il normale binding diretto del comando deve risolvere attraverso la selezione `current`, cosi che il nome pubblico esegua il default persistente senza pinning accidentale a una versione concreta.

L'esecuzione attraverso un binding diretto non coinvolge `pkg run` e quindi non applica override per-invocation che richiedono la mediazione del package manager.

---

## 7. Binding gestito tramite wrapper

Quando il launch richiede mediazione, il binding pubblico e un wrapper minimale che delega a `pkg run`.

Il wrapper non deve duplicare la logica di:

- selezione della versione;
- risoluzione del package concreto;
- costruzione dell'environment;
- selezione o routing runtime dello state quando realmente necessario;
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

## 8. Responsabilita di `pkg run`

Principio fondamentale:

> **`pkg run` costruisce un'esecuzione.**

Per l'invocazione corrente `pkg run` puo, quando necessario:

1. determinare il target RumiAI corrente;
2. usare la versione indicata da `current`;
3. applicare un override esplicito di versione per la sola invocazione;
4. individuare il command richiesto attraverso l'interfaccia package-local `cmd/`;
5. costruire environment e pathname necessari;
6. risolvere tramite `var/<area>` le aree di State Instance richieste dal launch;
7. selezionare o collegare dependency necessarie al launch;
8. applicare working directory, argomenti fissi o altri adattamenti dichiarati dal packaging;
9. eseguire il programma e inoltrare gli argomenti dell'utente.

Gli override di versione, state o environment usati da una singola invocazione non modificano automaticamente la selezione persistente `current`.

I nomi delle option e delle environment variables che realizzano questi override restano aperti. Eventuali environment variables proprie di RumiAI dovranno rispettare il namespace corrente `m_*`.

Quando la sintassi di `pkg run` accetta argomenti destinati al programma lanciato, il confine tra option/operandi di `pkg` e argomenti del programma deve essere esplicito; l'uso di `--` deve seguire le regole CLI RumiAI/POSIX gia fissate.

---

## 9. Package e comando sono concetti distinti

Un package puo offrire uno o piu comandi.

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

`pkg run <package>` resta la forma base fissata per un package con entrypoint predefinito, ma il modello deve poter identificare anche un entrypoint specifico quando il package ne espone piu di uno.

La sintassi CLI concreta per scegliere un command non-default resta aperta. Il mapping command -> executable non dipende da metadata: e normalizzato fisicamente tramite `cmd/<pkg-command>` secondo la decisione `root/cmd`.

---

## 10. Stato mutabile

Resta valido il principio generale:

```text
software != stato mutabile prodotto durante l'uso
```

Le aree canoniche sono:

```text
conf
data
home
cache
log
run
tmp
```

con classificazione:

```text
conf,data,home  persistent authoritative
cache,log       persistent non-authoritative
run,tmp         transient
```

`home` resta il compatibility bucket conservativo quando lo state non puo essere classificato meglio.

Non tutte le aree devono esistere per ogni package o State Instance.

Lo state fisico vive direttamente nelle root semantiche:

```text
$m_ROOT/conf/<pkg>/<state-instance>/
$m_ROOT/data/<pkg>/<state-instance>/
$m_ROOT/home/<pkg>/<state-instance>/
$m_ROOT/cache/<pkg>/<state-instance>/
$m_ROOT/log/<pkg>/<state-instance>/
$m_ROOT/run/<pkg>/<state-instance>/
$m_ROOT/tmp/<pkg>/<state-instance>/
```

`$m_ROOT/var/` e esplicitamente vietato e non appartiene al layout RumiAI.

Una versione concreta raggiunge la propria State Instance tramite package-local:

```text
var/<area>
```

che e un symbolic link relativo verso la corrispondente area fisica.

La State Instance e quindi riaffermata come raggruppamento fisico minimo. Restano invece aperti grammatica di `<state-instance>`, selezione, compatibilita, condivisione e lifecycle; la vecchia identity `@sN` e gli state scope del 2026-08-30 non tornano automaticamente.

`default/` resta factory/default state opzionale e separato dallo state mutabile.

---

## 11. Responsabilita di `pkg install` sullo state

`pkg install` conosce i file e le directory del tree upstream che:

- sono soggetti a modifica a runtime;
- rappresentano configurazione modificabile;
- rappresentano dati modificabili dall'utente;
- appartengono ad altre state area canoniche.

Per ciascun pathname dichiarato, il packaging associa:

```text
<root-relative-path> -> <state-area>
```

`pkg install` sostituisce quindi l'entry corrispondente sotto `root/` con un symbolic link relativo che risolve a:

```text
<package-version>/var/<area>/<root-relative-path>
```

La catena completa e:

```text
<package-version>/root/<path>
    -> <package-version>/var/<area>/<path>
        -> $m_ROOT/<area>/<pkg>/<state-instance>/<path>
```

Il formato dei metadata che porta questa conoscenza e le regole finali di validazione dei mapping restano aperti.

---

## 12. Dependency e runtime

`pkg run` deve poter preparare dependency necessarie a un launch quando un package ne ha bisogno, ma la baseline non richiede il precedente resolver universale di capability.

Non sono quindi attualmente obbligatori:

- capability contract generici;
- constraint resolver;
- `release-order`;
- provider ranking;
- Desired/Resolved dependency graph persistito;
- re-resolution/generation model.

Una prima implementazione puo usare riferimenti concreti e semplici quando il caso d'uso lo consente. Un resolver piu generale potra essere introdotto soltanto a fronte di requisiti concreti e con decisione esplicita.

---

## 13. Software difficilmente controllabile

Software che modifica pathname noti del proprio installation tree non e automaticamente un caso speciale: quando tali pathname sono dichiarabili dal packaging, `pkg install` li normalizza verso le State Instance secondo il modello corrente.

Restano difficili i casi in cui il software, per esempio:

- scrive in pathname non prevedibili o non dichiarabili;
- usa pathname host assoluti non redirigibili;
- esegue self-update che riscrive parti non separabili del tree;
- produce effetti non controllabili tramite mapping, environment o altre primitive effettivamente fissate.

Per tali casi si studiera, quando necessario, una strategia mirata con isolamento logico e/o adapter platform-specific per isolamento effettivo.

Questa decisione **non fissa** directory o classi chiamate `legacy`, `container` o equivalenti.

---

## 14. Costrutti del design 2026-08-30 non piu baseline

I seguenti meccanismi dei draft del 2026-08-30 non devono essere implementati come requisiti del package manager corrente senza una nuova decisione che ne dimostri la necessita:

```text
bin/@platforms
pathname Package Instance obbligatorio con @version@rN@platform-architecture
percent-encoded version-token obbligatorio
vecchia wrapper root/run-default/run
root immutabile come admission/rejection rule universale
inventory SHA-256 obbligatorie per ogni package
vecchia identity State Instance @sN
state scope shared/platform/architecture/platform-architecture
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

Sono invece state riaffermate selettivamente, con contratti correnti piu piccoli:

```text
root/ e cmd/
env
conf,data,home,cache,log,run,tmp
State Instance come raggruppamento fisico minimo
$m_ROOT/<area>/<pkg>/<state-instance>
var/ come routing view package-local
pkg install come responsabile dei pathname mutabili
root/<path> -> var/<area>/<path>
default/ al posto di run-default/
```

Per queste responsabilita valgono esclusivamente le decisioni Accepted correnti, non i contratti fisici storici del 2026-08-30.

Restano definitivamente incompatibili con il runtime corrente i vecchi riferimenti a `bin/` direttamente nel `PATH` e a `bin/@platforms`; valgono i current executable roots `bin/sys*` e `bin/ext*`.

---

## 15. Questioni intenzionalmente aperte

Non vengono fissati in questa decisione:

1. pathname esatto delle versioni concrete sotto `pkg/`;
2. pathname esatto e grammatica del selector `current`;
3. regola finale per selector target-qualified vs condivisi quando il package e realmente target-independent;
4. formato minimo dei metadata/descriptor del package;
5. grammatica, selezione, compatibilita, condivisione e lifecycle di `<state-instance>`;
6. formato e validazione dei mapping `<root-relative-path> -> <state-area>` usati da `pkg install`;
7. policy di collisione fra `<pkg>` e domini RumiAI gia presenti nelle root semantiche, in particolare `$m_ROOT/conf/`;
8. nomi delle option di `pkg run`;
9. nomi delle environment variables di override;
10. sintassi per scegliere un entrypoint non-default;
11. formato/interprete fisico dei wrapper in `bin/ext*`;
12. sintassi completa di `pkg install` e modello di acquisition/download/build;
13. eventuale resolver dependency piu generale;
14. eventuale sandbox/isolation model per software difficili;
15. semantica operativa completa di `default/`, inclusi initialization/reset/recovery.

Questi punti aperti non autorizzano a riutilizzare automaticamente i contratti del 2026-08-30.

---

## 16. Implementazione e test

Alla data di questa decisione non esiste ancora un comando `pkg` stabile in `rumiai-os` e non esiste un gruppo permanente di test `pkg` in `rumiai-tests`.

Questa unita di lavoro consolida soltanto il design in `rumiai-dev`.

L'implementazione in `rumiai-os` richiedera esplicita autorizzazione per la relativa fase. Quando saranno fissati i primi comportamenti osservabili, i test permanenti corrispondenti dovranno essere aggiunti in `rumiai-tests` secondo `TESTING.md`, con complessita proporzionata alle proprieta effettivamente implementate.

---

## 17. Invarianti fissati

```text
PKG-01 $m_ROOT/pkg e il dominio locale dei package gestiti
PKG-02 piu versioni concrete dello stesso package possono coesistere
PKG-03 ogni package con un default di esecuzione mantiene un selector current, anche con una sola versione installata
PKG-04 il selector current e un symlink relativo
PKG-05 current seleziona una versione; non costruisce l'esecuzione
PKG-06 pkg run e il punto di mediazione per launch che richiedono gestione runtime
PKG-07 un override per-invocation non modifica automaticamente current
PKG-08 un binding third-party pubblico vive in bin/ext o bin/ext-<osarch>
PKG-09 un binding puo essere direct symlink o minimal wrapper verso pkg run
PKG-10 il normale direct binding risolve attraverso current ed e ammesso quando non serve mediazione runtime
PKG-11 package != command; un package puo offrire piu entrypoint
PKG-12 software e stato mutabile restano semanticamente distinti quando lo stato esiste
PKG-13 State Instance esiste come raggruppamento fisico minimo; la vecchia identity @sN, gli state scope, migration/resolver/generation framework non sono baseline
PKG-14 la complessita specifica di un'app appartiene principalmente al suo packaging
PKG-15 software difficile non impone complessita preventiva al percorso normale
PKG-16 nessun namespace legacy/container e fissato
PKG-17 il vecchio bin/@platforms non appartiene al runtime corrente
PKG-18 i dettagli non esplicitamente riaffermati dei draft package-manager del 2026-08-30 sono da rivalutare, non da assumere
PKG-19 le aree canoniche dello state sono conf,data,home,cache,log,run,tmp ma ogni package/State Instance usa solo quelle necessarie
PKG-20 lo state fisico vive sotto $m_ROOT/<area>/<pkg>/<state-instance>; $m_ROOT/var e vietato
PKG-21 var/ e esclusivamente package-local ed espone tramite symlink relativi le aree della State Instance
PKG-22 pkg install conosce e normalizza i pathname upstream mutabili/state-bearing tramite root/<path> -> var/<area>/<path>
PKG-23 il routing statico dello state non obbliga di per se a usare pkg run
PKG-24 default/ e factory/default state opzionale e separato dallo state mutabile
```
