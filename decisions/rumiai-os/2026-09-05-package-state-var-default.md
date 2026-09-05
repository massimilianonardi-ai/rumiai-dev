# Decisione — Package manager: `var/`, `default/`, State Instance e routing dello state

Date: 2026-09-05  
Status: **Accepted**

## Contesto

Le decisioni Accepted correnti hanno gia fissato:

- `$m_ROOT/pkg/` come dominio locale dei package gestiti;
- `current` come selector persistente della versione predefinita;
- `pkg run` come punto di mediazione quando il launch richiede gestione;
- `root/` come tree di esecuzione upstream della versione concreta;
- `cmd/` come interfaccia RumiAI package-local dei command esposti;
- `env` come file opzionale package-local per le modifiche di environment necessarie al launch;
- `default/` come factory/default state opzionale;
- le aree `conf`, `data`, `home`, `cache`, `log`, `run`, `tmp` e la loro classificazione semantica.

Il design storico del 2026-08-30 aveva inoltre introdotto State Instance, writable-island mapping e una package-local routing view chiamata `run/`.

Il modello corrente recupera selettivamente la parte utile di quella logica con una struttura piu semplice:

- il package-local routing view si chiama `var/`, non `run/`;
- `run` resta esclusivamente il nome della state area transient;
- lo state fisico vive direttamente nelle root semantiche `$m_ROOT/conf`, `$m_ROOT/data`, `$m_ROOT/home`, `$m_ROOT/cache`, `$m_ROOT/log`, `$m_ROOT/run`, `$m_ROOT/tmp`;
- `$m_ROOT/var/` e esplicitamente escluso e non appartiene al layout RumiAI;
- `pkg install` conosce i pathname upstream che possono essere modificati a runtime o direttamente dall'utente e normalizza `root/` sostituendo tali entry con symbolic link relativi verso `var/`;
- `var/<area>` e a sua volta un symbolic link verso la State Instance fisica nella corrispondente root semantica.

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
var/      routing view package-local verso la State Instance
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

La scelta e intenzionale: RumiAI non adotta il significato eterogeneo che `/var` ha assunto nei sistemi Unix-like tradizionali.

---

## 3. Aree canoniche e root fisiche

Le aree canoniche restano esattamente:

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

La root `$m_ROOT/conf/` esiste gia nel prodotto corrente anche per configurazione RumiAI non appartenente ai package. La policy di collisione fra `<pkg>` e domini RumiAI gia presenti al primo livello delle root semantiche non viene inventata da questa decisione e resta da fissare separatamente prima dell'implementazione del relativo caso.

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

data  dati autorevoli non rigenerabili o che devono sopravvivere all'esecuzione

home  compatibility bucket conservativo per software il cui stato non puo essere classificato meglio
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

## 5. State Instance minima corrente

Il modello corrente riafferma il concetto di **State Instance** soltanto nella forma minima necessaria a identificare un insieme coerente di state area appartenenti allo stesso package.

La forma fisica e:

```text
$m_ROOT/<area>/<pkg>/<state-instance>/
```

quindi, per una stessa State Instance:

```text
$m_ROOT/conf/<pkg>/<state-instance>/
$m_ROOT/data/<pkg>/<state-instance>/
$m_ROOT/home/<pkg>/<state-instance>/
$m_ROOT/cache/<pkg>/<state-instance>/
$m_ROOT/log/<pkg>/<state-instance>/
$m_ROOT/run/<pkg>/<state-instance>/
$m_ROOT/tmp/<pkg>/<state-instance>/
```

con la sola subset di aree realmente necessaria.

Lo stesso `<state-instance>` identifica concettualmente le aree corrispondenti della medesima State Instance.

Questa decisione **non fissa ancora**:

- la grammatica di `<state-instance>`;
- una numerazione `s1`, `s2`, ...;
- qualifier platform/architecture;
- state scope;
- come una versione sceglie una State Instance quando ne esistono piu di una;
- regole di compatibilita, condivisione, migration o garbage collection.

In particolare la vecchia identity:

```text
<pkg-name>[@<platform>-<architecture>]@sN
```

non viene ripristinata automaticamente.

---

## 6. `var/` come routing view package-local

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

Ogni entry presente e un **symbolic link relativo** che deve risolvere alla directory fisica della State Instance nella corrispondente root semantica:

```text
<package-version>/var/conf  -> $m_ROOT/conf/<pkg>/<state-instance>/
<package-version>/var/data  -> $m_ROOT/data/<pkg>/<state-instance>/
<package-version>/var/home  -> $m_ROOT/home/<pkg>/<state-instance>/
<package-version>/var/cache -> $m_ROOT/cache/<pkg>/<state-instance>/
<package-version>/var/log   -> $m_ROOT/log/<pkg>/<state-instance>/
<package-version>/var/run   -> $m_ROOT/run/<pkg>/<state-instance>/
<package-version>/var/tmp   -> $m_ROOT/tmp/<pkg>/<state-instance>/
```

Le frecce sopra esprimono la destinazione semantica. Il target testuale del symbolic link deve essere relativo; la sua forma esatta dipende dal pathname finale della versione concreta sotto `$m_ROOT/pkg/` e verra fissata insieme a quel layout.

La precedente possibilita transitoria di conservare direttamente lo state fisico dentro `<package-version>/var/` e superseded da questa decisione: `var/<area>` e il routing layer, non il backing storage.

---

## 7. Responsabilita di `pkg install` sui pathname mutabili

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

## 8. Normalizzazione di `root/`

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

La catena completa e quindi:

```text
<package-version>/root/<path>
    -> <package-version>/var/<area>/<path>
        -> $m_ROOT/<area>/<pkg>/<state-instance>/<path>
```

Questo permette al software upstream di continuare a usare i pathname che si aspetta dentro il proprio installation tree, mentre i contenuti mutabili vivono fuori da `root/` nelle root semantiche RumiAI.

La normalizzazione puo essere file-level o directory-level. Le regole finali di validazione dei mapping, inclusi eventuali vincoli su overlap ancestor/descendant, restano da fissare separatamente e non vengono importate automaticamente dal draft del 2026-08-30.

---

## 9. `root/` dopo la normalizzazione

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

La vecchia regola universale "root immutabile oppure package rifiutato" non viene ripristinata come admission framework completo; e pero responsabilita del packaging separare dai contenuti di `root/` i pathname che l'esecuzione normale deve modificare quando tale separazione e possibile e dichiarata.

---

## 10. `default/`

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
- le regole di copia/merge/reset verso una State Instance;
- mode/ownership finali;
- inventory o meccanismi di integrita.

I contenuti upstream originari di un pathname che viene sostituito da un symlink non devono essere persi durante l'installazione; la regola definitiva che distingue inizializzazione della State Instance e conservazione dei factory defaults verra fissata insieme alla semantica operativa di `default/`.

---

## 11. Relazione con `env`, `pkg run` e binding diretto

`var/` espone la State Instance attraverso pathname package-local stabili.

Quando un software raggiunge il proprio state attraverso pathname interni al tree upstream normalizzati da `pkg install`, il routing e gia realizzato dalla catena di symbolic link e non richiede di per se una modifica dell'environment a runtime.

Quando invece una environment variable come `HOME`, `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_CACHE_HOME`, `XDG_RUNTIME_DIR`, `TMPDIR` o altra variabile package-specific deve puntare allo state, `pkg run` puo risolvere il valore tramite:

```text
<package-version>/var/<area>
```

La sintassi con cui `env` esprime questi riferimenti resta separata.

La sola presenza di routing statico tramite `root/ -> var/ -> State Instance` non rende necessario `pkg run`: un binding diretto resta possibile quando il launch non richiede ulteriori operazioni di mediazione.

Questo meccanismo non e sandboxing o containment.

---

## 12. Cosa non viene reintrodotto

Questa decisione riafferma:

```text
State Instance come raggruppamento fisico minimo
state area conf,data,home,cache,log,run,tmp
root semantiche $m_ROOT/<area>/
var/ come routing view package-local
pkg install come responsabile del mapping dei pathname mutabili
root/<path> -> var/<area>/<path>
default/ come factory/default state opzionale
```

Restano invece fuori dal baseline corrente, salvo futura decisione esplicita:

```text
identity State Instance @sN
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
```

Il recupero del mapping dei pathname mutabili non riattiva automaticamente gli altri contratti del vecchio modello.

---

## 13. Questioni ancora aperte

Restano da definire separatamente:

1. grammatica e lifecycle di `<state-instance>`;
2. regole di compatibilita e condivisione dello state fra versioni concrete dello stesso package;
3. modo con cui una versione seleziona la State Instance quando ne esistono piu di una;
4. eventuale specializzazione dello state per `<osarch>`;
5. formato dei metadata con cui `pkg install` conosce `<root-relative-path> -> <state-area>`;
6. regole di validazione dei mapping file/directory e degli overlap;
7. lifecycle dello state rispetto a update/uninstall/purge;
8. backup, retention e cleanup;
9. layout interno e semantica operativa di `default/`;
10. permission/ownership finali delle aree;
11. sintassi `env` per riferire le aree di `var/`;
12. policy di collisione fra `<pkg>` e altri domini RumiAI gia presenti sotto le root semantiche, in particolare `$m_ROOT/conf/`;
13. sintassi completa di `pkg install` e modello di acquisition/download/build.

Questi punti aperti non autorizzano a importare automaticamente le soluzioni del 2026-08-30.

---

## 14. Implementazione e test

Alla data di questa decisione non esiste ancora un comando `pkg` stabile in `rumiai-os` ne un gruppo permanente di test `pkg` in `rumiai-tests`.

Questa unita di lavoro consolida esclusivamente il design in `rumiai-dev`.

Quando il modello verra implementato, i test permanenti dovranno proteggere in modo proporzionato almeno:

- assenza di `$m_ROOT/var/`;
- layout fisico `$m_ROOT/<area>/<pkg>/<state-instance>`;
- relativita dei symlink sotto `var/`;
- relativita dei symlink che sostituiscono pathname mutabili sotto `root/`;
- risoluzione completa `root/<path> -> var/<area>/<path> -> State Instance`;
- conservazione dei pathname upstream attesi;
- classificazione corretta delle state area;
- distinzione fra `$m_ROOT/run/` state root e il vecchio routing `run/` superseded;
- relocatability dell'intera catena;
- opzionalita delle aree non necessarie;
- comportamento di `default/` quando la relativa semantica operativa sara fissata.

---

## 15. Invarianti fissati

```text
PKG-STATE-01   le aree canoniche sono conf,data,home,cache,log,run,tmp
PKG-STATE-02   non tutte le aree devono esistere per ogni package o State Instance
PKG-STATE-03   conf,data,home sono persistent authoritative
PKG-STATE-04   cache,log sono persistent non-authoritative
PKG-STATE-05   run,tmp sono transient
PKG-STATE-06   home e il compatibility bucket conservativo ed e autorevole per default
PKG-STATE-07   lo state fisico vive sotto $m_ROOT/<area>/<pkg>/<state-instance>
PKG-STATE-08   State Instance e riaffermata come raggruppamento minimo; la vecchia identity @sN e gli state scope restano superseded
PKG-VAR-01     var/ esiste soltanto package-local sotto una versione concreta
PKG-VAR-02     $m_ROOT/var/ e vietato e non appartiene al layout RumiAI
PKG-VAR-03     ogni var/<area> presente e un symbolic link relativo alla corrispondente State Instance fisica
PKG-VAR-04     var/ e routing view e non contiene direttamente il backing state
PKG-VAR-05     var/run indica la state area transient run; il vecchio routing package-local run/ resta superseded
PKG-INSTALL-01 pkg install conosce i pathname upstream mutabili/state-bearing del package
PKG-INSTALL-02 ogni pathname normalizzato e associato a una state area canonica
PKG-INSTALL-03 pkg install sostituisce il pathname mutabile sotto root/ con un symbolic link relativo verso var/<area>/<root-relative-path>
PKG-INSTALL-04 la catena finale risolve a $m_ROOT/<area>/<pkg>/<state-instance>/<root-relative-path>
PKG-LAYOUT-STATE-01 root/ conserva struttura e pathname logici upstream ma puo contenere i symlink di normalizzazione fissati da pkg install
PKG-DEFAULT-01 default/ sostituisce il nome storico run-default/
PKG-DEFAULT-02 default/ e opzionale
PKG-DEFAULT-03 default/ contiene factory/default state quando necessario
PKG-DEFAULT-04 default/ resta distinto dallo state mutabile raggiunto tramite var/
PKG-STATE-09   questa decisione non reintroduce migration framework, resolver, generations, inventory o @package v0
```
