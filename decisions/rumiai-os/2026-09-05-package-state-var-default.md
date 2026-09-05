# Decisione — Package manager: `var/`, `default/` e aree di stato

Date: 2026-09-05  
Status: **Accepted**

## Contesto

Le decisioni Accepted correnti hanno gia fissato:

- `$m_ROOT/pkg/` come dominio locale dei package gestiti;
- `current` come selector persistente della versione predefinita;
- `pkg run` come punto di mediazione quando il launch richiede gestione;
- `root/` come tree upstream della versione concreta;
- `cmd/` come interfaccia RumiAI package-local dei command esposti;
- `env` come file opzionale package-local per le modifiche di environment necessarie al launch.

Il design storico del 2026-08-30 aveva inoltre introdotto:

- le aree `conf`, `data`, `home`, `cache`, `log`, `run`, `tmp`;
- una classificazione fra stato persistente autorevole, persistente non autorevole e transient;
- `run-default/` come contenitore dei factory defaults;
- `run/` come package-local routing view verso lo state attivo.

La decisione `2026-09-05-package-manager-current-and-run-model.md` aveva correttamente rimosso tali meccanismi dal baseline obbligatorio in attesa di rivalutazione.

Questa decisione li rivaluta e riafferma selettivamente nel modello corrente, con una semplificazione sostanziale:

- `run-default/` viene sostituito da `default/`;
- il vecchio package-local routing `run/` viene sostituito da `var/`;
- `run` resta disponibile esclusivamente come nome della categoria di stato transient `var/run`;
- non vengono reintrodotti State Instance `@sN`, state scope, migration framework, resolver, generations o altri meccanismi superseded non esplicitamente riaffermati qui.

Questa unita di lavoro modifica soltanto `rumiai-dev` e non autorizza modifiche a `rumiai-os`.

---

## 1. Struttura package-local estesa

Per una versione concreta che necessita di state o factory defaults, la struttura package-local puo comprendere:

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
root/     tree upstream
cmd/      interfaccia RumiAI dei command
env       modifiche package-local di environment
default/  factory/default state opzionale
var/      vista package-local dello state variabile
```

`root/` resta esclusivamente upstream.

`cmd/`, `env`, `default/` e `var/` appartengono invece al packaging RumiAI e non acquisiscono alcuna semantica da pathname omonimi eventualmente presenti sotto `root/`.

La presenza fisica di `default/` o `var/` non e obbligatoria per package che non ne hanno bisogno. Resta valido il principio di complessita proporzionata.

---

## 2. `var/` come package-local state view

`var/` significa **variable files/state** e costituisce il punto package-local unico da cui esplorare e raggiungere lo state variabile del package senza dover conoscere la collocazione fisica finale delle singole aree.

Il ruolo di `var/` e quindi distinto sia da `root/` sia da un eventuale namespace globale `$m_ROOT/var/`:

```text
<package-version>/var/
    vista state della specifica versione/package

$m_ROOT/var/
    eventuale dominio globale RumiAI, se e quando definito separatamente
```

Questa decisione non assegna alcuna nuova semantica a `$m_ROOT/var/` e non fissa il pathname finale del backing state.

---

## 3. Aree canoniche di stato

Le aree di stato riaffermate dal modello corrente sono esattamente:

```text
conf
data
home
cache
log
run
tmp
```

Quando usate da un package, sono esposte sotto `var/` con gli stessi nomi:

```text
<package-version>/var/conf
<package-version>/var/data
<package-version>/var/home
<package-version>/var/cache
<package-version>/var/log
<package-version>/var/run
<package-version>/var/tmp
```

Non tutte le aree devono esistere per ogni package. Devono essere presenti soltanto quelle realmente necessarie.

Non viene introdotta in questa decisione un'ulteriore area `state/` o altra categoria non esplicitamente fissata.

---

## 4. Classificazione semantica

La classificazione corrente e:

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

Il nome `run` in questa sezione identifica esclusivamente una **state area transient**. Non identifica piu il vecchio package-local routing view del design 2026-08-30.

---

## 5. Prima realizzazione fisica di `var/`

Per mantenere semplice la prima implementazione, `var/` puo inizialmente contenere direttamente lo state fisico usato dal package.

Esempio:

```text
<package-version>/var/
├── conf/
├── data/
├── home/
├── cache/
├── log/
├── run/
└── tmp/
```

con la sola subset realmente necessaria al package.

Questa forma iniziale e una realizzazione fisica semplice della stessa interfaccia `var/`; non introduce un secondo modello semantico.

La sua adozione iniziale non fissa ancora lifecycle, condivisione fra versioni, retention, backup, migration o comportamento di uninstall dello state.

---

## 6. Realizzazione finale di `var/`

Il modello finale mantiene `var/` come vista stabile package-local ma separa la vista dal backing storage.

Le entry di `var/` diventano symbolic link verso le directory fisiche delle rispettive aree:

```text
<package-version>/var/conf  -> <backing-conf>
<package-version>/var/data  -> <backing-data>
<package-version>/var/home  -> <backing-home>
<package-version>/var/cache -> <backing-cache>
<package-version>/var/log   -> <backing-log>
<package-version>/var/run   -> <backing-run>
<package-version>/var/tmp   -> <backing-tmp>
```

Il pathname esatto del backing storage resta intenzionalmente aperto.

La futura forma dei link dovra rispettare la relocatability RumiAI e non potra dipendere da pathname host-specific hardcoded.

Questo consente di mantenere stabile il punto di accesso package-local mentre la collocazione fisica dello state potra essere definita separatamente secondo requisiti di condivisione fra versioni, lifecycle, backup e cleanup.

---

## 7. `default/`

`default/` sostituisce il precedente nome `run-default/`.

`default/` e opzionale e contiene factory/default state necessario, quando esiste, per operazioni come:

```text
first initialization
factory reset
controlled recovery
```

`default/` appartiene al packaging RumiAI e resta distinto dallo state mutabile esposto tramite `var/`.

Questa decisione non fissa ancora:

- il layout interno esatto di `default/`;
- quali aree possano avere default;
- le regole di copia/merge/reset;
- la policy di recovery;
- mode/ownership finali;
- eventuali inventory o meccanismi di integrita.

Il solo nome `default/` non reintroduce il vecchio requisito universale di wrapper `root/run-default/run`.

---

## 8. Relazione con `env` e `pkg run`

`env` continua a descrivere soltanto modifiche di environment.

Quando una variabile come `HOME`, `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_CACHE_HOME`, `XDG_RUNTIME_DIR`, `TMPDIR` o altra variabile package-specific deve raggiungere state controllato, `pkg run` puo risolverne il valore runtime attraverso la vista package-local `var/`.

Esempio concettuale:

```text
env richiede HOME -> area home
        ↓
pkg run risolve <package-version>/var/home
        ↓
la entry e directory fisica iniziale oppure symlink nella realizzazione finale
        ↓
environment finale
```

La sintassi con cui `env` esprime questi riferimenti resta separata e ancora aperta.

`var/` non sostituisce `env`: `var/` espone lo state, `env` dichiara come il processo deve raggiungerlo quando serve.

---

## 9. Cosa non viene reintrodotto

Questa decisione riafferma soltanto le aree di stato, la loro classificazione, `var/` e `default/`.

Restano fuori dal baseline corrente, salvo futura decisione esplicita:

```text
State Instance identity @sN
state scope shared/platform/architecture/platform-architecture
migration framework universale
Package Instance identity del 2026-08-30
root immutabile come admission rule universale
writable-island mapping obbligatorio dentro root/
@package schema v0 obbligatorio
integrity inventories obbligatorie
Desired/Resolved profiles
generations
resolver universale
transaction/recovery framework completo
```

In particolare non viene ripristinata la vecchia catena:

```text
root/<path> -> ../run/<path> -> State Instance
```

Il nuovo package-local punto di accesso allo state e `var/`.

---

## 10. Questioni ancora aperte

Restano da definire separatamente:

1. pathname fisico finale del backing state;
2. regole di condivisione dello state fra versioni concrete dello stesso package;
3. lifecycle dello state rispetto a update/uninstall/purge;
4. backup, retention e cleanup;
5. eventuale specializzazione dello state per `<osarch>`;
6. formato finale dei symbolic link di `var/` una volta fissato il backing layout;
7. layout interno e semantica operativa di `default/`;
8. eventuali migration necessarie quando cambia la compatibilita dello state;
9. permission/ownership finali delle aree;
10. sintassi `env` per riferire le aree di `var/`.

Questi punti aperti non riattivano automaticamente i meccanismi superseded del 2026-08-30.

---

## 11. Implementazione e test

Alla data di questa decisione non esiste ancora un comando `pkg` stabile in `rumiai-os` ne un gruppo permanente di test `pkg` in `rumiai-tests`.

Questa unita di lavoro consolida esclusivamente il design in `rumiai-dev`.

Quando il modello verra implementato, i test permanenti dovranno proteggere in modo proporzionato almeno:

- separazione fra `root/` e strutture RumiAI;
- classificazione e pathname package-local delle aree usate;
- uso di `var/` come unico punto package-local di accesso allo state;
- distinzione fra `var/run` state area e vecchio routing `run/` superseded;
- comportamento della realizzazione fisica adottata in quella fase;
- relocatability dei link quando verra adottato il backing state separato;
- opzionalita di `default/` e `var/` per package che non ne hanno bisogno.

---

## 12. Invarianti fissati

```text
PKG-STATE-01  le aree canoniche sono conf,data,home,cache,log,run,tmp
PKG-STATE-02  non tutte le aree devono esistere per ogni package
PKG-STATE-03  conf,data,home sono persistent authoritative
PKG-STATE-04  cache,log sono persistent non-authoritative
PKG-STATE-05  run,tmp sono transient
PKG-STATE-06  home e il compatibility bucket conservativo ed e autorevole per default
PKG-VAR-01    var/ e la vista package-local dello state variabile
PKG-VAR-02    var/ e distinto da root/ e da un eventuale $m_ROOT/var/ globale
PKG-VAR-03    le aree usate sono esposte come var/<area>
PKG-VAR-04    nella prima realizzazione var/ puo contenere direttamente lo state fisico
PKG-VAR-05    nel modello finale le entry var/<area> sono symbolic link verso il backing state
PKG-VAR-06    il backing pathname finale resta aperto e deve preservare relocatability
PKG-VAR-07    var/run indica la state area transient run; il vecchio package-local routing run/ resta superseded
PKG-DEFAULT-01 default/ sostituisce il nome storico run-default/
PKG-DEFAULT-02 default/ e opzionale
PKG-DEFAULT-03 default/ contiene factory/default state quando necessario
PKG-DEFAULT-04 default/ resta distinto dallo state mutabile esposto tramite var/
PKG-STATE-07  questa decisione non reintroduce State Instance @sN, state scope, migration framework o resolver universale
```