# Decisione — Package autosufficienti, launcher runtime e state di default

Date: 2026-09-06  
Status: **Accepted**

## Contesto

Le decisioni precedenti del package manager hanno fissato il dominio `$m_ROOT/pkg/`, la selezione `current`, il tree upstream `root/`, l'interfaccia package-local `cmd/`, il routing state package-local `var/`, le aree semantiche `conf`, `data`, `home`, `cache`, `log`, `run`, `tmp`, i file `env` e la separazione fra sistema base e package di espansione.

Il modello precedente attribuiva pero a `pkg run` la responsabilita normale di costruire l'esecuzione quando erano necessari environment, dependency o altra mediazione runtime. Inoltre `cmd/<pkg-command>` era fissato come symbolic link relativo verso l'executable upstream e l'environment standard di isolamento veniva risolto attraverso `var/<area>`.

La presente decisione semplifica il launch path secondo un principio diverso:

> `pkg install` deve rendere ogni package il piu autosufficiente possibile; il normale launch di un package deve dipendere dal sistema base RumiAI, non dal comando `pkg`.

Il package manager resta responsabile dell'installazione, della normalizzazione, della selezione delle versioni e delle future funzioni di gestione avanzata, ma non deve essere una dipendenza runtime obbligatoria del normale command path di un package gia installato.

Questa decisione conserva `var/`: la package-local state view resta necessaria per separare lo state dal software upstream quando il programma non permette di redirigere completamente il proprio state tramite environment.

Questa decisione modifica soltanto `rumiai-dev`. Non autorizza modifiche a `rumiai-os` o `rumiai-tests`.

---

## 1. Principio di autosufficienza del package

Una versione concreta installata da `pkg` deve contenere tutto cio che e ragionevolmente materializzabile durante l'installazione per poter essere lanciata senza richiamare nuovamente il package manager nel percorso normale.

La dipendenza runtime RumiAI minima del command package-local e il sistema base necessario a interpretare il command entry, in particolare:

```text
rumiai-os
core.lib.sh
```

Il normale launch non deve avere la forma:

```text
public command
    -> pkg run
        -> package
        -> command
```

La forma corrente e invece concettualmente:

```text
public command
    -> current
        -> <package-version>/cmd/<pkg-command>
            -> launcher del sistema base
                -> executable upstream
```

`pkg` resta il meccanismo di espansione e gestione del sistema base, ma non e il runtime engine obbligatorio di ogni esecuzione.

---

## 2. Binding pubblico e `current`

I binding pubblici third-party restano sotto:

```text
bin/ext/
bin/ext-<osarch>/
```

secondo il runtime corrente.

Per un package gestito il binding pubblico normale resta un symbolic link relativo che risolve attraverso il selector `current` e termina sul command package-local:

```text
bin/ext*/<pkg-command>
    -> <package-current-selector>/cmd/<pkg-command>
```

`current` continua esclusivamente a selezionare la versione persistente predefinita. Non costruisce l'esecuzione.

Il pathname esatto del selector `current` e la sua qualificazione target-specific restano regolati dalle decisioni precedenti e dai punti ancora aperti gia documentati.

---

## 3. `cmd/<pkg-command>` come command entry package-local

La regola precedente secondo cui ogni:

```text
<package-version>/cmd/<pkg-command>
```

doveva essere necessariamente un symbolic link relativo all'executable upstream e superseded.

Nel baseline corrente `cmd/<pkg-command>` e il **command entry package-local** del command esposto.

Quando il command usa il normale launch RumiAI del package, tale entry e un command file interpretabile dal runtime canonico:

```text
#!/usr/bin/env rumiai-os
```

che delega la preparazione comune alla funzione `launcher` del sistema base.

La chiamata esatta e i parametri con cui il command entry indica al launcher l'executable upstream restano da fissare durante il design fisico del package layout. In particolare questa decisione non introduce automaticamente una directory `link/` o un nuovo metadata format.

Restano validi:

```text
package != command
<pkg-command> corrisponde esattamente a cmd/<pkg-command>
pkg non scopre command scandendo root/
un pathname upstream non sostituisce <pkg-command>
```

Il package-local `cmd/` continua a non riaprire il vecchio command-entry shadow/multicall model superseded.

---

## 4. Funzione `launcher` nel sistema base

Il sistema base RumiAI espone in:

```text
lib/sh/core.lib.sh
```

la funzione shell:

```text
launcher
```

come primitive comune per il launch dei command package-local.

`launcher` viene resa disponibile dal normale bootstrap `rumiai-os`, che carica `core.lib.sh` prima di interpretare il command file.

La funzione riusa il pathname canonico del command gia esposto dal runtime tramite:

```text
m_COMMAND_BIN
```

per identificare il command package-local e il package concreto senza dipendere dal pathname di invocazione non risolto.

Responsabilita concettuali del launcher:

1. identificare il package/versione concreta gia raggiunti dal binding `current`;
2. identificare il command package-local corrente;
3. costruire l'environment standard di isolamento;
4. applicare l'environment aggiuntivo installato con la versione;
5. applicare la personalizzazione/override environment dello state corrente;
6. applicare eventuali override espliciti gia forniti dal caller quando una futura interfaccia li prevedera;
7. eseguire l'executable upstream corrispondente inoltrando gli argomenti del command.

`launcher` non seleziona normalmente una versione al posto di `current` e non diventa un secondo package manager.

La firma esatta della funzione, il formato con cui riceve il target upstream e le failure semantics finali restano aperti fino alla prima implementazione.

---

## 5. `pkg run`

Il comando/sottocomando `pkg run` non e piu il runtime engine obbligatorio del normale launch di un package installato.

La sua esistenza come interfaccia esplicita di `pkg` puo essere mantenuta per casi come:

```text
selezione esplicita di una versione diversa da current
invocazioni amministrative o diagnostiche
future selezioni/override supportati dal package manager
```

ma non deve duplicare il launch engine.

Se `pkg run` esegue un command package-local, deve raggiungere la versione/command richiesti e delegare allo stesso `cmd/<pkg-command>` e allo stesso `launcher` usati dal percorso normale.

La sintassi completa e gli override di `pkg run` restano aperti. La gestione runtime per-invocation delle State Instance non appartiene al baseline iniziale fissato da questa decisione.

---

## 6. Root semantiche esportate dal bootstrap

Il launcher deve ricevere dal sistema base i pathname semantici delle sette state area, senza duplicare localmente la conoscenza del layout fisico.

Il contratto richiesto dal package launch e:

```text
m_CONF_DIR=$m_ROOT/conf
m_DATA_DIR=$m_ROOT/data
m_HOME_DIR=$m_ROOT/home
m_CACHE_DIR=$m_ROOT/cache
m_LOG_DIR=$m_ROOT/log
m_RUN_DIR=$m_ROOT/run
m_TMP_DIR=$m_ROOT/tmp
```

`m_CONF_DIR` esiste gia nel runtime corrente. Le altre environment variables sopra estendono il contratto semantico necessario al launcher e dovranno essere materializzate dal bootstrap quando il modello verra implementato.

Sono environment variables proprie di RumiAI e quindi rispettano il namespace `m_*`.

Questa decisione non autorizza un fallback silenzioso a directory package-local alternative quando tali variabili mancano durante un launch RumiAI supportato. L'assenza di una variabile che il bootstrap e tenuto a garantire e un errore del runtime/contratto, non un motivo per creare uno state parallelo implicito.

Non viene fissata alcuna directory package-local `work/` come fallback dello state.

---

## 7. Environment standard di isolamento

L'environment standard di isolamento viene costruito dal `launcher`, non da `pkg run`.

Le environment variables standard di isolamento che verranno fissate devono puntare **direttamente** alle root semantiche dello state selezionato e non attraverso `var/<area>`.

Esempio fissato per `HOME`:

```text
HOME=$m_HOME_DIR/<state>
```

Nel baseline corrente `<state>` e il pathname component non qualificato del package:

```text
<pkg>
```

quindi:

```text
HOME=$m_HOME_DIR/<pkg>
```

Quando in futuro una State Instance nominata sara realmente selezionabile, il pathname fisico corrispondente restera:

```text
$m_HOME_DIR/<pkg>@!<state-instance>
```

ma tale selezione non appartiene al baseline iniziale.

Lo stesso principio vale per le altre variabili di isolamento che verranno associate alle state area canoniche.

L'elenco esatto delle variabili standard (`HOME`, variabili XDG, `TMPDIR` o altre) e il loro mapping area-per-area restano da fissare separatamente.

L'environment di isolamento e logical isolation, non sandboxing o containment.

---

## 8. Layering dell'environment

Il layering corrente diventa:

```text
environment host ereditato/sanitizzato secondo il launch contract
        ↓
environment standard di isolamento costruito da launcher
        ↓
<package-version>/env
        ↓
env utente dello state selezionato
        ↓
eventuali override espliciti del caller
        ↓
exec del command upstream
```

`<package-version>/env` conserva la responsabilita gia fissata:

```text
configurazione version-specific gestita da pkg install
compatibilita/interazione con altri package, runtime o toolchain
```

per esempio riferimenti a una specifica Java, modifiche a `PATH`, `JAVA_HOME`, `PYTHONPATH` o analoghi quando necessari.

La personalizzazione persistente dell'utente resta configurazione sotto `conf`.

Nel baseline state non qualificato il file fisico e:

```text
$m_CONF_DIR/<pkg>/env
```

ed e anche raggiungibile attraverso la vista package-local:

```text
<package-version>/var/conf/env
```

quando `var/conf` e presente.

Il launcher deve pero costruire e leggere lo state selezionato tramite le root semantiche, non usare `var/conf` come sorgente dell'identita dello state.

I file `env` restano dichiarativi. Non diventano shell script, file eseguibili o file da `source`. Restano validi almeno i requisiti `set`/`unset`, la relocatability e la separazione da working directory e argv.

---

## 9. `var/` resta parte necessaria del modello

`var/` non viene rimosso ne deprecato.

Il suo ruolo non e costruire l'environment standard di isolamento. Il suo ruolo e fornire una **routing view package-local dello state** per i pathname upstream che il software usa direttamente dentro il proprio installation tree.

Questo e necessario per software che:

- non usa environment variables per tutto il proprio state;
- usa environment variables soltanto per una parte dello state;
- scrive o legge configurazione/dati/cache/log/run/tmp attraverso pathname relativi al proprio tree upstream;
- deve continuare a vedere i pathname upstream originari anche dopo la separazione fisica fra software e state.

Resta quindi valido il modello:

```text
<package-version>/var/<area>
    -> $m_ROOT/<area>/<pkg>/
```

nel baseline corrente, con symbolic link relativo.

E resta valido il routing install-time:

```text
<package-version>/root/<path>
    -> <package-version>/var/<area>/<path>
        -> $m_ROOT/<area>/<pkg>/<path>
```

`pkg install` continua a conoscere i pathname upstream mutabili/state-bearing e a sostituirli con symbolic link relativi verso `var/<area>/<root-relative-path>`.

Quindi environment e `var/` sono meccanismi complementari:

```text
environment
    redirige lo state che lo upstream permette di controllare tramite environment

var/
    redirige lo state raggiunto attraverso pathname upstream nel tree di installazione
```

Nessuno dei due sostituisce automaticamente l'altro.

---

## 10. Baseline state: solo state di default

La baseline operativa iniziale considera ogni package con il solo state non qualificato:

```text
$m_ROOT/<area>/<pkg>/
```

Non viene introdotto un suffisso `default`, `s1` o equivalente.

La sintassi gia riservata per eventuali State Instance nominate resta:

```text
$m_ROOT/<area>/<pkg>@!<state-instance>/
```

ma il semplice fatto che tale pathname sia definito non obbliga la prima implementazione di `pkg` a supportare:

```text
creazione di State Instance nominate
selezione di State Instance
switch per-invocation
migrazione fra State Instance
compatibilita automatica fra State Instance e versioni
prompt di update per creare/selezionare una State Instance
```

Queste funzioni sono rimandate a una fase successiva e devono essere introdotte soltanto quando il relativo comportamento viene progettato e testato.

La regola precedente secondo cui `pkg install` doveva necessariamente proporre, in un update con compatibilita non determinata, la scelta fra riuso dello state e creazione/selezione di una State Instance separata non appartiene piu al baseline iniziale.

---

## 11. Compatibilita futura con State Instance

Il package manager dovra poter distinguere, quando questa funzione verra progettata, almeno due condizioni semantiche.

### State completamente controllabile a runtime tramite environment

Se per uno specifico package tutto lo state rilevante all'esecuzione puo essere indirizzato in modo completo tramite environment e non esiste routing statico `root/ -> var/` che vincoli lo stesso state, una futura State Instance potra in linea di principio essere selezionata a runtime dal launcher modificando le destinazioni environment.

Questo rende possibile una futura selezione anche per singola invocazione senza cambiare symbolic link package-local.

La decisione corrente non fissa sintassi, metadata o option per farlo.

### State non completamente controllabile tramite environment

Se parte dello state dipende da pathname upstream normalizzati attraverso:

```text
root/ -> var/ -> state
```

la State Instance non puo essere cambiata in modo corretto per una singola invocazione modificando soltanto l'environment.

Una futura selezione alternativa dovra quindi essere una **selezione persistente a livello del package**, effettuata da `pkg` quando il package non e in esecuzione, aggiornando in modo coerente tutte le rappresentazioni package-local necessarie, inclusi i routing `var/`.

L'esatto meccanismo che garantisce coerenza, atomicita, assenza di divergenza, rilevamento del package in esecuzione e recovery resta aperto e non viene anticipato da questa decisione.

Questa gestione e opzionale rispetto alla prima implementazione: il baseline puo limitarsi allo state di default.

Non vengono introdotte classi o nomi di prodotto per distinguere i due casi; si tratta di proprieta concrete del routing state del singolo package.

---

## 12. Ruolo di `pkg install`

`pkg install` resta il punto che materializza il package e conosce le sue esigenze concrete.

In particolare continua a essere responsabile di:

```text
installazione della versione concreta
costruzione dei binding package-local
materializzazione dei command entry sotto cmd/
installazione di <package-version>/env
conoscenza dei pathname upstream mutabili/state-bearing
costruzione dei routing root/ -> var/
inizializzazione dello state di default quando necessaria
materializzazione delle dependency/interazioni che possono essere risolte install-time
```

Il package manager deve preferire materializzazione install-time quando evita risoluzioni ripetitive a ogni launch senza compromettere relocatability o correttezza.

Il formato dei metadata/descriptor che porta queste informazioni resta aperto.

---

## 13. Relocability

Il nuovo launch path non autorizza hardcoding del pathname corrente di `$m_ROOT` nei package installati.

I pathname persistiti dal packaging devono restare relocatable. Le root fisiche dipendenti dall'installazione corrente vengono ottenute a runtime dalle environment variables semantiche garantite dal bootstrap.

I symbolic link package-local, inclusi `current`, i binding pubblici e `var/<area>`, restano relativi secondo le decisioni correnti.

---

## 14. Supersession mirata

Questa decisione supersede, nelle decisioni Accepted precedenti, esclusivamente le regole incompatibili seguenti.

Da `2026-09-05-package-manager-current-and-run-model.md`:

```text
PKG-06  pkg run come punto obbligato di mediazione del launch normale
PKG-09  wrapper pubblico verso pkg run come normale forma mediata
le parti di PKG-23 che assumono pkg run come unico launch mediato
la sezione che attribuisce a pkg run la responsabilita esclusiva di costruire l'esecuzione
```

`pkg run` resta una possibile interfaccia esplicita, ma non e piu il launch engine obbligatorio.

Da `2026-09-05-package-root-cmd-and-direct-binding.md`:

```text
PKG-CMD-02  cmd/<pkg-command> obbligatoriamente symbolic link relativo
PKG-CMD-03  cmd/<pkg-command> obbligatoriamente risolto direttamente verso root/
PKG-DIRECT-03 nella parte che presuppone cmd/ come semplice symlink terminale
PKG-DIRECT-06 nella parte che lega ogni mediazione a pkg run
PKG-DIRECT-07 nella distinzione direct-vs-pkg-run come unico criterio di launch
```

Restano invece validi namespace e mapping logico `cmd/<pkg-command>`, divieto di scansione di `root/`, binding pubblico attraverso `current` e separazione `package != command`.

Da `2026-09-06-package-environment-layering.md`:

```text
PKG-ENV-01  pkg run costruisce l'isolamento
PKG-ENV-12  pkg run come unico runtime resolver
PKG-ENV-13  layering che nomina pkg run come costruttore dell'isolamento
PKG-ENV-14  obbligo di mediazione pkg run per ogni launch con environment
PKG-ENV-16 nella parte che presuppone mapping attraverso var/
```

Restano validi ruolo di `<package-version>/env`, ruolo dell'env utente sotto `conf`, formato dichiarativo, `set`/`unset`, relocatability e precedenza dei layer.

Da `2026-09-05-package-state-var-default.md`:

```text
PKG-STATE-09  attivazione immediatamente prevista di State Instance da utente/regole/package
PKG-STATE-10  obbligo update-time di proporre riuso o nuova State Instance
la sezione 13 nella parte che usa var/<area> come destinazione dell'environment
```

Non sono superseded:

```text
PKG-STATE-07  state normale sotto $m_ROOT/<area>/<pkg>/
PKG-STATE-08  forma riservata delle State Instance nominate
PKG-STATE-12  separatore @!
PKG-VAR-01..05
PKG-INSTALL-01..04, limitatamente al baseline state di default
PKG-LAYOUT-STATE-01
PKG-DEFAULT-01..04
```

La forma `@!` resta quindi definita e riservata, ma la gestione operativa delle State Instance nominate e posticipata.

---

## 15. Implementazione e test

Alla data di questa decisione `rumiai-os` non contiene ancora il package manager/launcher qui descritto e `rumiai-tests` non contiene test permanenti `pkg`.

L'implementazione prodotto richiede una fase successiva esplicitamente autorizzata.

Quando verra implementato il modello, i test permanenti dovranno proteggere in modo proporzionato almeno:

```text
binding pubblico -> current -> cmd/<command>
assenza di pkg run dal normale launch path
uso di m_COMMAND_BIN da parte del launcher
costruzione dell'environment tramite root semantiche dirette
HOME e altri mapping fissati verso $m_<AREA>_DIR/<pkg>
layering isolation -> env versione -> env utente
persistenza di var/ come routing state package-local
root/<path> -> var/<area>/<path> -> state di default
assenza di State Instance nominate nel baseline iniziale
relativita dei symlink package-local
relocatability
```

I test per State Instance alternative verranno introdotti soltanto insieme alla relativa funzione.

---

## 16. Invarianti fissati

```text
PKG-LAUNCH-01  un package installato deve essere il piu autosufficiente possibile e il normale launch non dipende dal comando pkg
PKG-LAUNCH-02  il normale binding pubblico risolve attraverso current verso cmd/<pkg-command>
PKG-LAUNCH-03  cmd/<pkg-command> e il command entry package-local e non e piu obbligatoriamente un symlink all'upstream executable
PKG-LAUNCH-04  i command entry package-local usano il runtime canonico rumiai-os e delegano la preparazione comune alla funzione launcher
PKG-LAUNCH-05  launcher e una funzione del sistema base in core.lib.sh e riusa m_COMMAND_BIN per identificare il command package-local concreto
PKG-LAUNCH-06  launcher costruisce l'environment, applica env versione e utente e lancia l'executable upstream
PKG-LAUNCH-07  pkg run non e il runtime engine obbligatorio; quando usato deve delegare allo stesso command entry/launcher
PKG-RUNTIME-STATE-01  il bootstrap garantisce m_CONF_DIR,m_DATA_DIR,m_HOME_DIR,m_CACHE_DIR,m_LOG_DIR,m_RUN_DIR,m_TMP_DIR come root semantiche
PKG-RUNTIME-STATE-02  l'environment standard di isolamento punta direttamente a $m_<AREA>_DIR/<state>, non attraverso var/<area>
PKG-RUNTIME-STATE-03  nel baseline <state> e <pkg> e quindi lo state usato a runtime e quello non qualificato
PKG-RUNTIME-STATE-04  non esiste fallback implicito package-local work/<area> per assenza delle root semantiche bootstrap
PKG-VAR-CURRENT-01  var/ resta parte necessaria del modello per routing di pathname upstream mutabili/state-bearing
PKG-VAR-CURRENT-02  nel baseline var/<area> e un symlink relativo allo state non qualificato $m_ROOT/<area>/<pkg>/
PKG-VAR-CURRENT-03  root/<path> -> var/<area>/<path> resta il meccanismo install-time per state non completamente controllabile via environment
PKG-STATE-BASELINE-01  la prima baseline operativa usa soltanto lo state non qualificato $m_ROOT/<area>/<pkg>/
PKG-STATE-BASELINE-02  la forma <pkg>@!<state-instance> resta riservata ma la sua gestione operativa e rimandata
PKG-STATE-BASELINE-03  la prima implementazione non deve introdurre automaticamente switch, migration o prompt State Instance
PKG-STATE-FUTURE-01  una futura selezione runtime e possibile solo quando tutto lo state rilevante e controllabile tramite environment senza routing statico concorrente
PKG-STATE-FUTURE-02  quando lo state dipende anche da var/, una futura selezione alternativa deve essere persistente a livello package e avvenire con package non in esecuzione
PKG-STATE-FUTURE-03  il meccanismo di coerenza/atomicita della futura selezione package-level resta aperto
```
