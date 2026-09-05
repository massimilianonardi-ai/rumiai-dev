# Decisione — Package manager: file `env` per environment package-local

Date: 2026-09-05  
Status: **Accepted**

## Contesto

Le decisioni Accepted correnti hanno gia fissato:

- `$m_ROOT/pkg/` come dominio locale dei package gestiti;
- `current` come selector persistente della versione predefinita;
- `pkg run` come punto di mediazione quando il launch richiede gestione;
- `root/` come tree del software upstream della versione concreta;
- `cmd/` come interfaccia RumiAI package-local dei command esposti;
- binding diretto sotto `bin/ext*` soltanto quando il launch non richiede mediazione.

La decisione `2026-09-05-package-manager-current-and-run-model.md` ha inoltre gia assegnato a `pkg run` la responsabilita di costruire l'environment e, quando necessario, indirizzare HOME, data, cache o altre aree mutabili verso location controllate.

Questa decisione fissa il meccanismo package-local minimo con cui una versione concreta puo dichiarare le modifiche di environment necessarie al proprio launch.

La successiva decisione Accepted `2026-09-05-package-state-var-default.md` fissa separatamente le aree di stato, `var/` come package-local state view e `default/` come factory/default state opzionale. Il presente documento resta autoritativo esclusivamente per il ruolo di `env`.

Non modifica `rumiai-os` e non autorizza modifiche al prodotto in questa unita di lavoro.

---

## 1. Struttura package-local

Per le responsabilita fissate da questa decisione, una versione concreta puo avere:

```text
<package-version>/
├── root/
├── cmd/
└── env
```

Semantica:

```text
root/  tree upstream
cmd/   interfaccia RumiAI dei command
env    dichiarazione RumiAI delle modifiche di environment richieste dal launch
```

`env` appartiene al packaging RumiAI e non al contenuto upstream.

Il file e opzionale. Un package che non richiede modifiche package-specific dell'environment non deve essere obbligato ad avere `env`.

La presenza di `env` non modifica la regola che qualunque pathname sotto `root/` appartiene all'upstream e non acquisisce automaticamente semantica package-manager.

Le eventuali directory `var/` e `default/` sono definite dalla decisione state separata e non cambiano la responsabilita di `env`.

---

## 2. Responsabilita di `env`

`env` descrive esclusivamente differenze necessarie rispetto all'environment di base usato da `pkg run`.

Il modello minimo deve poter rappresentare almeno:

```text
set <environment-variable> <value>
unset <environment-variable>
```

La sintassi fisica concreta non e fissata da questa decisione.

`env` non introduce un elenco universale di environment variables obbligatorie. Ogni package dichiara soltanto le modifiche che richiede realmente.

Esempi di variabili che un package puo aver bisogno di impostare o rimuovere includono, secondo il software interessato:

```text
HOME
XDG_CONFIG_HOME
XDG_DATA_HOME
XDG_STATE_HOME
XDG_CACHE_HOME
XDG_RUNTIME_DIR
TMPDIR
PATH
XDG_CONFIG_DIRS
XDG_DATA_DIRS
```

oltre a variabili specifiche del runtime, toolchain o applicazione, come `JAVA_HOME`, `PYTHONPATH`, `NODE_PATH`, `GIT_CONFIG_GLOBAL` o equivalenti quando realmente necessarie.

Questa lista e esemplificativa e non costituisce uno schema universale obbligatorio.

---

## 3. Environment ereditato e overlay package-specific

Il baseline resta proporzionato:

1. `pkg run` parte dall'environment che il relativo launch contract decide di ereditare/sanitizzare;
2. applica le operazioni dichiarate da `env`;
3. applica eventuali override espliciti per-invocation secondo la futura sintassi di `pkg run`;
4. esegue il command selezionato.

Questa decisione non fissa ancora una policy universale di sanitizzazione dell'environment host.

Il supporto a `unset` e necessario per evitare contaminazioni host quando una variabile ereditata cambierebbe la risoluzione di moduli, runtime, configurazione, dependency o altro comportamento rilevante del package.

---

## 4. Risoluzione dei valori a runtime

I pathname gestiti da RumiAI dichiarati tramite `env` devono essere relocatable.

Il package non deve persistere in `env` pathname assoluti host-specific derivati dall'installazione corrente, dalla posizione corrente di `$m_ROOT`, dalla versione selezionata, dallo state selezionato o da dependency risolte.

La semantica richiesta e:

```text
intenzione package-local in env
        ↓
pkg run determina package/versione/target/state/dependency correnti
        ↓
risolve i pathname e i valori runtime necessari
        ↓
materializza l'environment finale
        ↓
exec del command
```

La sintassi con cui `env` rappresentera riferimenti runtime, pathname relativi o riferimenti semantici resta aperta e dovra essere fissata separatamente.

Una eventuale variabile XDG che, secondo il proprio contratto esterno, richiede un pathname assoluto ricevera quindi il pathname assoluto soltanto dopo la risoluzione runtime effettuata da `pkg run`; tale pathname non viene hardcodato nel package.

Quando il valore deve raggiungere una delle aree di stato correnti, `pkg run` puo risolverlo attraverso `<package-version>/var/<area>` secondo la decisione `2026-09-05-package-state-var-default.md`.

---

## 5. `env` non descrive working directory o argv

`env` descrive environment variables.

Una working directory richiesta dal package resta una responsabilita distinta di `pkg run`; non viene simulata assegnando `PWD`.

Argomenti fissi di launch e user argv restano anch'essi responsabilita distinte dal file `env`.

Questa separazione evita di trasformare `env` in un generico launch descriptor prima che emergano requisiti concreti.

---

## 6. Relazione con binding diretto

Il binding pubblico diretto resta ammesso soltanto quando il launch effettivo non richiede mediazione di `pkg run`.

Quindi, se per il normale launch di un command devono essere applicate operazioni `set`/`unset` dichiarate da `env`, quel command non puo usare il normale binding diretto come unico percorso di esecuzione: deve passare attraverso la mediazione di `pkg run`.

La sola esistenza fisica di un file `env` privo di operazioni effettive non crea artificialmente una necessita di mediazione; conta il comportamento richiesto dal launch.

---

## 7. Relazione con state e isolamento

L'uso di `HOME`, XDG, `TMPDIR`, PATH e variabili specifiche puo isolare logicamente state, configurazione, cache, runtime lookup e dependency visibili al processo.

Questo meccanismo non e sandboxing o containment.

Software che ignora le variabili disponibili, usa pathname assoluti non redirigibili, modifica il proprio installation tree o produce altri effetti fuori dal controllo dell'environment puo richiedere una strategia separata.

Il layout state corrente e definito separatamente da `2026-09-05-package-state-var-default.md`, che riafferma:

```text
conf
data
home
cache
log
run
tmp
```

come aree canoniche opzionali per-package, `var/` come package-local state view e `default/` come factory/default state opzionale.

Il presente file `env` non definisce il backing storage di tali aree e non reintroduce State Instance `@sN`, state scope, migration framework o altri meccanismi superseded del design 2026-08-30.

---

## 8. Formato del file

Questa decisione fissa il ruolo e il pathname `env`, non il suo formato di serializzazione.

Restano aperti:

- grammatica esatta di `set` e `unset`;
- quoting/escaping;
- rappresentazione dei riferimenti risolti a runtime;
- eventuale comment syntax;
- gestione di liste come `PATH`;
- validazione e failure semantics;
- eventuali overlay command-specific se emergera un requisito concreto.

`env` non viene definito da questa decisione come script shell, file eseguibile o file da source.

---

## 9. Implementazione e test

Alla data di questa decisione non esiste ancora un comando `pkg` stabile in `rumiai-os` ne un gruppo permanente di test `pkg` in `rumiai-tests`.

Questa unita di lavoro consolida esclusivamente il design in `rumiai-dev`.

Quando il modello `env` verra implementato nel prodotto, i test permanenti dovranno proteggere almeno:

- applicazione corretta di `set`;
- applicazione corretta di `unset`;
- risoluzione runtime relocatable dei pathname gestiti;
- assenza di hardcoding host-specific;
- separazione fra `env`, working directory e argv;
- uso della mediazione quando l'environment deve essere modificato;
- risoluzione coerente attraverso `var/<area>` quando il launch usa state package-local.

---

## 10. Invarianti fissati

```text
PKG-ENV-01  env e un file opzionale package-local controllato da RumiAI
PKG-ENV-02  env vive accanto alle altre strutture package-local RumiAI, non dentro root/
PKG-ENV-03  env descrive soltanto differenze di environment necessarie al launch
PKG-ENV-04  il modello env supporta almeno set e unset di environment variables
PKG-ENV-05  non esiste un elenco universale obbligatorio di variabili per ogni package
PKG-ENV-06  i pathname RumiAI-managed dipendenti dal runtime non sono hardcodati in env
PKG-ENV-07  pkg run risolve a runtime i valori dipendenti da root/versione/state/dependency/target
PKG-ENV-08  env non descrive working directory o argv
PKG-ENV-09  modifiche environment necessarie al launch richiedono mediazione pkg run
PKG-ENV-10  env non costituisce sandboxing o containment
PKG-ENV-11  il layout state e definito separatamente; env non reintroduce State Instance @sN, state scope o migration framework
PKG-ENV-12  il formato fisico di env resta aperto e non e implicitamente uno script shell
```