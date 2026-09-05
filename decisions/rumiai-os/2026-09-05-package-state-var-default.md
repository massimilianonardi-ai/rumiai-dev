# Decisione — Package manager: `var/`, `default/`, state e State Instance

Date: 2026-09-05  
Status: **Accepted**

## Contesto

Le decisioni Accepted correnti hanno gia fissato:

- `$m_ROOT/pkg/` come dominio locale dei package gestiti;
- `current` come selector persistente della versione predefinita;
- `pkg run` come punto di mediazione quando il launch richiede gestione runtime;
- `pkg install` come responsabile dell'installazione/normalizzazione della versione concreta;
- `root/` come tree di esecuzione upstream della versione concreta;
- `cmd/` come interfaccia RumiAI package-local dei command esposti;
- `env` come file opzionale package-local per le modifiche di environment necessarie al launch;
- `default/` come factory/default state opzionale;
- le aree `conf`, `data`, `home`, `cache`, `log`, `run`, `tmp` e la loro classificazione semantica.

Il design storico del 2026-08-30 aveva introdotto State Instance, writable-island mapping e una package-local routing view chiamata `run/`.

Il modello corrente recupera selettivamente la parte utile di quella logica con una struttura piu semplice:

- il package-local routing view si chiama `var/`, non `run/`;
- `run` resta esclusivamente il nome della state area transient;
- lo state fisico vive direttamente nelle root semantiche `$m_ROOT/conf`, `$m_ROOT/data`, `$m_ROOT/home`, `$m_ROOT/cache`, `$m_ROOT/log`, `$m_ROOT/run`, `$m_ROOT/tmp`;
- `$m_ROOT/var/` e esplicitamente escluso e non appartiene al layout RumiAI;
- normalmente lo state di un package vive direttamente sotto `$m_ROOT/<area>/<pkg>/`, senza suffisso State Instance;
- State Instance nominate vengono create soltanto quando richieste dall'utente, dalle regole di `pkg` o dal packaging del particolare package e vivono sotto `$m_ROOT/<area>/<pkg>@!<state-instance>/`;
- `pkg install` conosce i pathname upstream che possono essere modificati a runtime o direttamente dall'utente e normalizza `root/` sostituendo tali entry con symbolic link relativi verso `var/`;
- `var/<area>` e un symbolic link relativo verso lo state fisico selezionato nella corrispondente root semantica;
- i componenti del sistema base RumiAI non sono package gestiti da `pkg`: sono componenti non rimovibili tramite `pkg`, mentre `pkg` e il meccanismo di espansione del sistema base.

Questa decisione non reintroduce automaticamente la precedente grammatica `@sN`, gli state scope platform/architecture, migration framework, inventory, resolver, generations o altri meccanismi del design 2026-08-30 non esplicitamente riaffermati qui.

Questa unita di lavoro modifica soltanto `rumiai-dev` e non autorizza modifiche a `rumiai-os`.

---

## 1. Struttura package-local

Una versione concreta puo comprendere:

```text
<package-version>/
├── root/
├── cmd/
├── env
├── default/
└── var/
```

Semantica:

```text
root/     tree di esecuzione upstream normalizzato da pkg install
cmd/      interfaccia RumiAI dei command
env       modifiche package-local di environment
default/  factory/default state opzionale
var/      routing view package-local verso lo state selezionato
```

`cmd/`, `env`, `default/` e `var/` sono strutture RumiAI esterne al namespace upstream.

`root/` conserva invece i pathname e la struttura logica attesi dall'upstream. La normalizzazione descritta in questa decisione puo sostituire entry upstream gia esistenti o previste dal package con symbolic link, ma non autorizza a introdurre arbitrariamente dentro `root/` nuovi namespace RumiAI.

---

## 2. Nessun `$m_ROOT/var/`

RumiAI non usa e non usera:

```text
$m_ROOT/var/
```

come dominio globale di state.

Il nome `var/` ha esclusivamente scope package-local:

```text
<package-version>/var/
```

ed e una vista/routing layer verso le aree fisiche dello state.

---

## 3. Aree canoniche e root fisiche

Le aree canoniche sono esattamente:

```text
conf
data
home
cache
log
run
tmp
```

Le corrispondenti root fisiche RumiAI sono:

```text
$m_ROOT/conf/
$m_ROOT/data/
$m_ROOT/home/
$m_ROOT/cache/
$m_ROOT/log/
$m_ROOT/run/
$m_ROOT/tmp/
```

Non viene introdotta una root intermedia comune.

Non tutte le aree devono essere materializzate per ogni package o per ogni State Instance: esistono soltanto quelle necessarie.

---

## 4. Classificazione semantica

### Persistent authoritative

```text
conf
data
home
```

Semantica:

```text
conf  configurazione persistente

data   dati autorevoli non rigenerabili o che devono sopravvivere all'esecuzione

home   compatibility bucket conservativo per software il cui stato non puo essere classificato meglio
```

`home` viene trattata come autorevole per default.

### Persistent non-authoritative

```text
cache
log
```

Semantica:

```text
cache  contenuto rigenerabile ma utile fra esecuzioni

log    diagnostica e storia operativa persistente, non sorgente autorevole dello stato applicativo
```

### Transient

```text
run
tmp
```

Semantica:

```text
run  PID, socket, lock e coordinamento runtime

tmp  scratch e intermedi temporanei
```

`run` identifica soltanto la state area transient. Il vecchio package-local routing view `run/` resta superseded.

---

## 5. State di default

La forma normale non aggiunge alcun identificatore State Instance al pathname.

Per un package `<pkg>`, lo state di default vive direttamente in:

```text
$m_ROOT/<area>/<pkg>/
```

quindi, quando le aree sono usate:

```text
$m_ROOT/conf/<pkg>/
$m_ROOT/data/<pkg>/
$m_ROOT/home/<pkg>/
$m_ROOT/cache/<pkg>/
$m_ROOT/log/<pkg>/
$m_ROOT/run/<pkg>/
$m_ROOT/tmp/<pkg>/
```

La stessa identita package `<pkg>` raggruppa concettualmente le aree appartenenti allo state di default.

Non deve essere introdotto un suffisso artificiale come `default`, `s1` o equivalente soltanto per rappresentare il caso normale.

---

## 6. State Instance nominate

`pkg` puo creare state separate quando emerge un requisito concreto.

Una State Instance nominata usa la forma:

```text
$m_ROOT/<area>/<pkg>@!<state-instance>/
```

Esempio concettuale con una State Instance `work`:

```text
$m_ROOT/conf/example@!work/
$m_ROOT/data/example@!work/
$m_ROOT/home/example@!work/
$m_ROOT/cache/example@!work/
$m_ROOT/log/example@!work/
$m_ROOT/run/example@!work/
$m_ROOT/tmp/example@!work/
```

con la sola subset di aree realmente necessaria.

Lo stesso `<state-instance>` identifica concettualmente le aree corrispondenti della medesima State Instance.

Le State Instance nominate non sono obbligatorie per ogni package. Possono essere attivate, per esempio:

1. su richiesta esplicita dell'utente, per mantenere profili/state separati;
2. in base a regole di `pkg` quando una nuova installazione/versione non deve necessariamente condividere lo state esistente;
3. perche il particolare package dichiara di usare State Instance fin dalla prima installazione e gestisce la propria compatibilita di state fra versioni.

La sequenza `@!` e il separatore strutturale fisso fra `<pkg>` e `<state-instance>`. E una eccezione semantica esplicita alla convenzione filesystem generale ed e documentata anche da `specifications/rumiai-os/FILESYSTEM-NAMING.md`.

`@!` non e un separatore generale per altri pathname RumiAI. `<pkg>` e `<state-instance>` restano identificatori separati e seguono le rispettive regole di naming. Poiche il normale naming RumiAI non ammette `@` o `!` nei singoli identificatori, la forma composta e strutturalmente distinguibile dai normali nomi package e non collide semanticamente con i trattini interni ai nomi.

La grammatica esatta di `<state-instance>` oltre alle regole generali di naming resta aperta.

---

## 7. Selezione e riuso dello state durante `pkg install`

Quando `pkg install` installa una nuova versione di un package e trova gia lo state di default:

```text
$m_ROOT/<area>/<pkg>/
```

non deve assumere silenziosamente che la nuova versione debba necessariamente condividerlo se la compatibilita non e gia determinata dal packaging o da una regola fissata di `pkg`.

Nel caso non determinato automaticamente, `pkg install` deve permettere all'utente di scegliere fra:

```text
riutilizzare lo state esistente
creare/selezionare una State Instance separata
```

Un package puo invece dichiarare regole proprie di compatibilita dello state e richiedere l'uso di State Instance fin dalla prima installazione. In quel caso `pkg` applica il contratto del package invece di imporre il caso standard non qualificato.

Restano da fissare separatamente:

- il formato con cui il packaging dichiara compatibilita e policy di state;
- la UX/sintassi esatta della scelta utente;
- la generazione o scelta del nome `<state-instance>`;
- eventuali regole di migrazione.

---

## 8. `var/` come routing view package-local

Per ogni area usata dalla versione concreta, `var/` espone una entry con lo stesso nome:

```text
<package-version>/var/conf
<package-version>/var/data
<package-version>/var/home
<package-version>/var/cache
<package-version>/var/log
<package-version>/var/run
<package-version>/var/tmp
```

Ogni entry presente e un **symbolic link relativo**.

Nel caso normale risolve a:

```text
<package-version>/var/conf  -> $m_ROOT/conf/<pkg>/
<package-version>/var/data  -> $m_ROOT/data/<pkg>/
<package-version>/var/home  -> $m_ROOT/home/<pkg>/
<package-version>/var/cache -> $m_ROOT/cache/<pkg>/
<package-version>/var/log   -> $m_ROOT/log/<pkg>/
<package-version>/var/run   -> $m_ROOT/run/<pkg>/
<package-version>/var/tmp   -> $m_ROOT/tmp/<pkg>/
```

Quando e selezionata una State Instance nominata, risolve invece a:

```text
<package-version>/var/conf  -> $m_ROOT/conf/<pkg>@!<state-instance>/
<package-version>/var/data  -> $m_ROOT/data/<pkg>@!<state-instance>/
<package-version>/var/home  -> $m_ROOT/home/<pkg>@!<state-instance>/
<package-version>/var/cache -> $m_ROOT/cache/<pkg>@!<state-instance>/
<package-version>/var/log   -> $m_ROOT/log/<pkg>@!<state-instance>/
<package-version>/var/run   -> $m_ROOT/run/<pkg>@!<state-instance>/
<package-version>/var/tmp   -> $m_ROOT/tmp/<pkg>@!<state-instance>/
```

Le frecce sopra esprimono la destinazione semantica. Il target testuale del symbolic link deve essere relativo; la sua forma esatta dipende dal pathname finale della versione concreta sotto `$m_ROOT/pkg/`.

`var/<area>` e il routing layer, non il backing storage.

---

## 9. Responsabilita di `pkg install` sui pathname mutabili

`pkg install` e responsabile di conoscere, per il package che installa, quali file e directory del tree upstream:

- sono soggetti a modifica durante il runtime;
- rappresentano configurazione modificabile;
- rappresentano dati modificabili direttamente dall'utente;
- oppure appartengono a un'altra delle state area canoniche.

Per ogni pathname di questo tipo, il packaging associa:

```text
<root-relative-path> -> <state-area>
```

Esempi concettuali:

```text
etc/       -> conf
workspace/ -> data
logs/      -> log
temp/      -> tmp
```

La forma del descriptor o del metadata che porta questa conoscenza non e fissata qui.

---

## 10. Normalizzazione di `root/`

Durante `pkg install`, ogni file o directory upstream dichiarato mutabile viene sostituito sotto `root/` da un **symbolic link relativo**.

Il link deve risolvere al pathname corrispondente sotto:

```text
<package-version>/var/<state-area>/<root-relative-path>
```

La stessa path relativa upstream viene quindi preservata dentro la state area.

Esempio concettuale:

```text
root/etc       -> var/conf/etc
root/workspace -> var/data/workspace
root/logs      -> var/log/logs
root/temp      -> var/tmp/temp
```

Le frecce esprimono la destinazione semantica; il target testuale reale deve essere calcolato relativamente alla posizione del link e puo contenere un numero diverso di `..` in funzione della profondita di `<root-relative-path>`.

Nel caso normale la catena completa e:

```text
<package-version>/root/<path>
    -> <package-version>/var/<area>/<path>
        -> $m_ROOT/<area>/<pkg>/<path>
```

Con una State Instance nominata diventa:

```text
<package-version>/root/<path>
    -> <package-version>/var/<area>/<path>
        -> $m_ROOT/<area>/<pkg>@!<state-instance>/<path>
```

Questo permette al software upstream di continuare a usare i pathname che si aspetta dentro il proprio installation tree, mentre i contenuti mutabili vivono fuori da `root/` nelle root semantiche RumiAI.

La normalizzazione puo essere file-level o directory-level. Le regole finali di validazione dei mapping, inclusi eventuali vincoli su overlap ancestor/descendant, restano da fissare separatamente e non vengono importate automaticamente dal draft del 2026-08-30.

---

## 11. `root/` dopo la normalizzazione

`root/` resta il tree di esecuzione del software upstream, ma non deve essere descritto come copia fisicamente intatta del payload upstream.

La distinzione corretta e:

```text
struttura e pathname logici upstream
        +
normalizzazione mirata dei soli pathname mutabili
        =
<package-version>/root/
```

RumiAI non attribuisce semantica package-manager ai nomi upstream in base al loro basename. Un pathname viene normalizzato soltanto perche il packaging lo dichiara come state-bearing/mutabile e gli assegna una state area.

---

## 12. `default/`

`default/` resta il nome corrente del factory/default state opzionale e sostituisce il precedente nome `run-default/`.

Serve, quando necessario, per responsabilita come:

```text
first initialization
factory reset
controlled recovery
```

`default/` resta distinto sia da `root/` sia dallo state mutabile raggiunto tramite `var/`.

Questa decisione non fissa ancora:

- il layout interno esatto di `default/`;
- se ogni pathname normalizzato debba avere obbligatoriamente un counterpart sotto `default/`;
- le regole di copia/merge/reset verso lo state selezionato;
- mode/ownership finali;
- inventory o meccanismi di integrita.

I contenuti upstream originari di un pathname che viene sostituito da un symlink non devono essere persi durante l'installazione; la regola definitiva che distingue inizializzazione dello state e conservazione dei factory defaults verra fissata insieme alla semantica operativa di `default/`.

---

## 13. Relazione con `env`, `pkg run` e binding diretto

`var/` espone lo state selezionato attraverso pathname package-local stabili.

Quando un software raggiunge il proprio state attraverso pathname interni al tree upstream normalizzati da `pkg install`, il routing e gia realizzato dalla catena di symbolic link e non richiede di per se una modifica dell'environment a runtime.

Quando invece una environment variable come `HOME`, `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_CACHE_HOME`, `XDG_RUNTIME_DIR`, `TMPDIR` o altra variabile package-specific deve puntare allo state, `pkg run` puo risolvere il valore tramite:

```text
<package-version>/var/<area>
```

La sola presenza di routing statico tramite `root/ -> var/ -> state` non rende necessario `pkg run`: un binding diretto resta possibile quando il launch non richiede ulteriori operazioni di mediazione.

Questo meccanismo non e sandboxing o containment.

---

## 14. Sistema base RumiAI e dominio di `pkg`

Le root semantiche `conf`, `data`, `home`, `cache`, `log`, `run`, `tmp` sono strutture generali del sistema RumiAI e non appartengono esclusivamente ai package.

I componenti e gli eseguibili che costituiscono il **sistema base RumiAI** non sono package gestiti da `pkg` e non sono rimovibili tramite `pkg`.

`pkg` ha una responsabilita differente: e il meccanismo con cui il sistema base viene **espanso** mediante package aggiuntivi installabili e gestibili separatamente dal sistema base.

Di conseguenza il prodotto corrente puo usare direttamente le root semantiche per i propri componenti base. Per esempio:

```text
$m_ROOT/conf/shell/
```

rappresenta normalmente configurazione del componente base `shell`; non e una eccezione, non richiede un package e non rappresenta implicitamente un package virtuale.

Non viene introdotto un virtual package per rappresentare i componenti base RumiAI.

Questa distinzione non definisce ancora una policy per una eventuale collisione fra il nome di un package di espansione e il nome di un componente base gia presente nella stessa root semantica; tale caso dovra essere affrontato quando emergera il relativo requisito di installazione.

---

## 15. Cosa non viene reintrodotto

Questa decisione riafferma:

```text
state di default sotto $m_ROOT/<area>/<pkg>/
State Instance nominate opzionali sotto $m_ROOT/<area>/<pkg>@!<state-instance>/
state area conf,data,home,cache,log,run,tmp
root semantiche $m_ROOT/<area>/
var/ come routing view package-local
pkg install come responsabile del mapping dei pathname mutabili
root/<path> -> var/<area>/<path>
default/ come factory/default state opzionale
sistema base RumiAI fuori dal dominio dei package rimovibili
pkg come meccanismo di espansione del sistema base
```

Restano invece fuori dal baseline corrente, salvo futura decisione esplicita:

```text
identity State Instance @sN obbligatoria
state scope shared/platform/architecture/platform-architecture
migration framework universale
Package Instance identity del 2026-08-30
@package schema v0 obbligatorio
integrity inventories obbligatorie
Desired/Resolved profiles
generations
resolver universale
transaction/recovery framework completo
vecchia package-local routing view run/
virtual package per rappresentare componenti del sistema base
```

Il recupero del mapping dei pathname mutabili e delle State Instance opzionali non riattiva automaticamente gli altri contratti del vecchio modello.

---

## 16. Questioni ancora aperte

Restano da definire separatamente:

1. grammatica esatta di `<state-instance>` oltre al separatore strutturale gia fissato `@!`;
2. formato con cui un package dichiara compatibilita e policy dello state;
3. UX/sintassi con cui `pkg install` propone riuso o separazione dello state;
4. regole di generazione/selezione di una State Instance nominata;
5. eventuale specializzazione dello state per `<osarch>`;
6. formato dei metadata con cui `pkg install` conosce `<root-relative-path> -> <state-area>`;
7. regole di validazione dei mapping file/directory e degli overlap;
8. lifecycle dello state rispetto a update/uninstall/purge;
9. backup, retention e cleanup;
10. layout interno e semantica operativa di `default/`;
11. permission/ownership finali delle aree;
12. sintassi `env` per riferire le aree di `var/`;
13. sintassi completa di `pkg install` e modello di acquisition/download/build;
14. policy di collisione fra nomi package di espansione e nomi di componenti base nelle root semantiche.

Questi punti aperti non autorizzano a importare automaticamente le soluzioni del 2026-08-30.

---

## 17. Implementazione e test

Alla data di questa decisione non esiste ancora un comando `pkg` stabile in `rumiai-os` ne un gruppo permanente di test `pkg` in `rumiai-tests`.

Questa unita di lavoro consolida esclusivamente il design in `rumiai-dev`.

Quando il modello verra implementato, i test permanenti dovranno proteggere in modo proporzionato almeno:

- assenza di `$m_ROOT/var/`;
- state standard sotto `$m_ROOT/<area>/<pkg>/`;
- State Instance nominate sotto `$m_ROOT/<area>/<pkg>@!<state-instance>/` quando usate;
- uso strutturale e non ambiguo del separatore `@!`;
- relativita dei symlink sotto `var/`;
- relativita dei symlink che sostituiscono pathname mutabili sotto `root/`;
- risoluzione completa `root/<path> -> var/<area>/<path> -> state selezionato`;
- conservazione dei pathname upstream attesi;
- classificazione corretta delle state area;
- distinzione fra `$m_ROOT/run/` state root e il vecchio routing `run/` superseded;
- relocatability dell'intera catena;
- opzionalita delle aree non necessarie;
- comportamento di `default/` quando la relativa semantica operativa sara fissata;
- comportamento di selezione/riuso State Instance quando verra implementato;
- separazione fra componenti del sistema base e package gestiti da `pkg`.

---

## 18. Invarianti fissati

```text
PKG-STATE-01   le aree canoniche sono conf,data,home,cache,log,run,tmp
PKG-STATE-02   non tutte le aree devono esistere per ogni package/state
PKG-STATE-03   conf,data,home sono persistent authoritative
PKG-STATE-04   cache,log sono persistent non-authoritative
PKG-STATE-05   run,tmp sono transient
PKG-STATE-06   home e il compatibility bucket conservativo ed e autorevole per default
PKG-STATE-07   lo state normale vive sotto $m_ROOT/<area>/<pkg>/ senza suffisso State Instance
PKG-STATE-08   State Instance nominate sono opzionali e vivono sotto $m_ROOT/<area>/<pkg>@!<state-instance>/
PKG-STATE-09   State Instance possono essere attivate su richiesta utente, da regole pkg o dal contratto del particolare package
PKG-STATE-10   pkg install non riusa silenziosamente state preesistente quando la compatibilita non e gia determinata
PKG-STATE-11   la vecchia identity @sN e gli state scope restano superseded
PKG-STATE-12   @! e il separatore strutturale fisso e riservato fra pkg e state-instance
PKG-VAR-01     var/ esiste soltanto package-local sotto una versione concreta
PKG-VAR-02     $m_ROOT/var/ e vietato e non appartiene al layout RumiAI
PKG-VAR-03     ogni var/<area> presente e un symbolic link relativo allo state selezionato
PKG-VAR-04     var/ e routing view e non contiene direttamente il backing state
PKG-VAR-05     var/run indica la state area transient run; il vecchio routing package-local run/ resta superseded
PKG-INSTALL-01 pkg install conosce i pathname upstream mutabili/state-bearing del package
PKG-INSTALL-02 ogni pathname normalizzato e associato a una state area canonica
PKG-INSTALL-03 pkg install sostituisce il pathname mutabile sotto root/ con un symbolic link relativo verso var/<area>/<root-relative-path>
PKG-INSTALL-04 la catena finale risolve allo state standard o alla State Instance nominata selezionata
PKG-LAYOUT-STATE-01 root/ conserva struttura e pathname logici upstream ma puo contenere i symlink di normalizzazione fissati da pkg install
PKG-DEFAULT-01 default/ sostituisce il nome storico run-default/
PKG-DEFAULT-02 default/ e opzionale
PKG-DEFAULT-03 default/ contiene factory/default state quando necessario
PKG-DEFAULT-04 default/ resta distinto dallo state mutabile raggiunto tramite var/
PKG-BASE-01    i componenti del sistema base RumiAI non sono package gestiti da pkg e non sono rimovibili tramite pkg
PKG-BASE-02    pkg e il meccanismo di espansione del sistema base mediante package aggiuntivi
PKG-BASE-03    i componenti base possono usare direttamente le root semantiche appropriate senza package o virtual package
PKG-STATE-13   questa decisione non reintroduce migration framework, resolver, generations, inventory o @package v0
```
