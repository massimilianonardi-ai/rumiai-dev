# Decisione — Package manager: file `en` per environment package-local

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

Questa decisione fissa il meccanismo package-local minimo con cui una versione concreta puo dichiarare le modifiche di environment necessarie al proprio launch, senza fissare ancora il layout dello state package-specific.

Non modifica `rumiai-os` e non autorizza modifiche al prodotto in questa unita di lavoro.

---

## 1. Struttura package-local

Per le responsabilita oggi fissate, una versione concreta puo avere:

```text
<package-version>/
├── root/
├── cmd/
└── en
```

Semantica:

```text
root/  tree upstream
cmd/   interfaccia RumiAI dei command
 en    dichiarazione RumiAI delle modifiche di environment richieste dal launch
```

`en` appartiene al packaging RumiAI e non al contenuto upstream.

Il file e opzionale. Un package che non richiede modifiche package-specific dell'environment non deve essere obbligato ad avere `en`.

La presenza di `en` non modifica la regola che qualunque pathname sotto `root/` appartiene all'upstream e non acquisisce automaticamente semantica package-manager.

---

## 2. Responsabilita di `en`

`en` descrive esclusivamente differenze necessarie rispetto all'environment di base usato da `pkg run`.

Il modello minimo deve poter rappresentare almeno:

```text
set <environment-variable> <value>
unset <environment-variable>
```

La sintassi fisica concreta non e fissata da questa decisione.

`en` non introduce un elenco universale di environment variables obbligatorie. Ogni package dichiara soltanto le modifiche che richiede realmente.

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
2. applica le operazioni dichiarate da `en`;
3. applica eventuali override espliciti per-invocation secondo la futura sintassi di `pkg run`;
4. esegue il command selezionato.

Questa decisione non fissa ancora una policy universale di sanitizzazione dell'environment host.

Il supporto a `unset` e necessario per evitare contaminazioni host quando una variabile ereditata cambierebbe la risoluzione di moduli, runtime, configurazione, dependency o altro comportamento rilevante del package.

---

## 4. Risoluzione dei valori a runtime

I pathname gestiti da RumiAI dichiarati tramite `en` devono essere relocatable.

Il package non deve persistere in `en` pathname assoluti host-specific derivati dall'installazione corrente, dalla posizione corrente di `$m_ROOT`, dalla versione selezionata, dallo state selezionato o da dependency risolte.

La semantica richiesta e:

```text
intenzione package-local in en
        ↓
pkg run determina package/versione/target/state/dependency correnti
        ↓
risolve i pathname e i valori runtime necessari
        ↓
materializza l'environment finale
        ↓
exec del command
```

La sintassi con cui `en` rappresentera riferimenti runtime, pathname relativi o riferimenti semantici resta aperta e dovra essere fissata separatamente.

Una eventuale variabile XDG che, secondo il proprio contratto esterno, richiede un pathname assoluto ricevera quindi il pathname assoluto soltanto dopo la risoluzione runtime effettuata da `pkg run`; tale pathname non viene hardcodato nel package.

---

## 5. `en` non descrive working directory o argv

`en` descrive environment variables.

Una working directory richiesta dal package resta una responsabilita distinta di `pkg run`; non viene simulata assegnando `PWD`.

Argomenti fissi di launch e user argv restano anch'essi responsabilita distinte dal file `en`.

Questa separazione evita di trasformare `en` in un generico launch descriptor prima che emergano requisiti concreti.

---

## 6. Relazione con binding diretto

Il binding pubblico diretto resta ammesso soltanto quando il launch effettivo non richiede mediazione di `pkg run`.

Quindi, se per il normale launch di un command devono essere applicate operazioni `set`/`unset` dichiarate da `en`, quel command non puo usare il normale binding diretto come unico percorso di esecuzione: deve passare attraverso la mediazione di `pkg run`.

La sola esistenza fisica di un file `en` privo di operazioni effettive non crea artificialmente una necessita di mediazione; conta il comportamento richiesto dal launch.

---

## 7. Relazione con state e isolamento

L'uso di `HOME`, XDG, `TMPDIR`, PATH e variabili specifiche puo isolare logicamente state, configurazione, cache, runtime lookup e dependency visibili al processo.

Questo meccanismo non e sandboxing o containment.

Software che ignora le variabili disponibili, usa pathname assoluti non redirigibili, modifica il proprio installation tree o produce altri effetti fuori dal controllo dell'environment puo richiedere una strategia separata.

La struttura fisica dello state package-specific resta intenzionalmente aperta. In particolare questa decisione non reintroduce automaticamente come baseline obbligatoria il precedente insieme:

```text
conf
data
home
cache
log
run
tmp
```

ne `run-default/`, State Instance `@sN`, migration framework o altri meccanismi del design 2026-08-30.

Tali idee possono essere riesaminate separatamente e riaffermate soltanto dove risultino utili al modello corrente.

---

## 8. Formato del file

Questa decisione fissa il ruolo e il pathname `en`, non il suo formato di serializzazione.

Restano aperti:

- grammatica esatta di `set` e `unset`;
- quoting/escaping;
- rappresentazione dei riferimenti risolti a runtime;
- eventuale comment syntax;
- gestione di liste come `PATH`;
- validazione e failure semantics;
- eventuali overlay command-specific se emergera un requisito concreto.

`en` non viene definito da questa decisione come script shell, file eseguibile o file da source.

---

## 9. Implementazione e test

Alla data di questa decisione non esiste ancora un comando `pkg` stabile in `rumiai-os` ne un gruppo permanente di test `pkg` in `rumiai-tests`.

Questa unita di lavoro consolida esclusivamente il design in `rumiai-dev`.

Quando il modello `en` verra implementato nel prodotto, i test permanenti dovranno proteggere almeno:

- applicazione corretta di `set`;
- applicazione corretta di `unset`;
- risoluzione runtime relocatable dei pathname gestiti;
- assenza di hardcoding host-specific;
- separazione fra `en`, working directory e argv;
- uso della mediazione quando l'environment deve essere modificato.

---

## 10. Invarianti fissati

```text
PKG-EN-01  en e un file opzionale package-local controllato da RumiAI
PKG-EN-02  en vive accanto a root/ e cmd/, non dentro root/
PKG-EN-03  en descrive soltanto differenze di environment necessarie al launch
PKG-EN-04  il modello en supporta almeno set e unset di environment variables
PKG-EN-05  non esiste un elenco universale obbligatorio di variabili per ogni package
PKG-EN-06  i pathname RumiAI-managed dipendenti dal runtime non sono hardcodati in en
PKG-EN-07  pkg run risolve a runtime i valori dipendenti da root/versione/state/dependency/target
PKG-EN-08  en non descrive working directory o argv
PKG-EN-09  modifiche environment necessarie al launch richiedono mediazione pkg run
PKG-EN-10  en non costituisce sandboxing o containment
PKG-EN-11  questa decisione non reintroduce State Instance, sette State Areas o run-default come baseline obbligatoria
PKG-EN-12  il formato fisico di en resta aperto e non e implicitamente uno script shell
```
