# Decisione — Package manager: layering dell'environment e override utente

Date: 2026-09-06  
Status: **Accepted**

## Contesto

Le decisioni correnti del package manager hanno gia fissato:

- `pkg run` come punto di mediazione quando il launch richiede gestione runtime;
- `<package-version>/env` come meccanismo package-local dichiarativo per modifiche di environment;
- `var/` come routing view package-local verso lo state selezionato;
- `conf` come state area persistente autorevole per configurazione;
- state standard sotto `$m_ROOT/<area>/<pkg>/` e State Instance nominate sotto `$m_ROOT/<area>/<pkg>@!<state-instance>/`;
- `pkg install` come responsabile dell'installazione e normalizzazione della versione concreta.

Il modello precedente lasciava pero nello stesso file `<package-version>/env` sia l'eventuale isolamento standard del processo sia le modifiche specifiche del package. Questa decisione separa tali responsabilita e introduce esplicitamente l'override persistente dell'utente sotto `var/conf/env`.

Questa decisione supersede `2026-09-05-package-environment-file.md` per il contratto corrente di `env`, pur mantenendo le parti compatibili relative a dichiarativita, `set`/`unset`, relocatability, separazione da working directory/argv e assenza di semantica shell implicita.

Non modifica `rumiai-os` e non autorizza modifiche al prodotto in questa unita di lavoro.

---

## 1. Tre livelli distinti

L'environment di un package gestito distingue tre responsabilita:

```text
1. environment standard di isolamento
   responsabilita runtime di pkg run

2. <package-version>/env
   configurazione installata con la versione concreta
   per compatibilita e interazione con altri package/runtime

3. <package-version>/var/conf/env
   configurazione persistente dello state selezionato
   per personalizzazioni e override dell'utente
```

Questi livelli non devono essere fusi in un unico file o responsabilita.

---

## 2. Environment standard di isolamento

Una volta fissato quali environment variables RumiAI usa per l'isolamento logico del package, `pkg run` le imposta autonomamente a runtime in base a:

- package/versione selezionati;
- State Instance selezionata;
- package-local `var/<area>`;
- target e altre informazioni runtime realmente necessarie.

Esempio concettuale:

```text
HOME -> <package-version>/var/home
```

La freccia esprime la destinazione semantica. Se il contratto della variabile richiede un pathname assoluto, `pkg run` materializza il pathname assoluto soltanto a runtime dopo la risoluzione della root e dello state selezionato.

Le variabili di isolamento standard non devono essere ripetute in `<package-version>/env` soltanto per applicare il modello RumiAI normale.

L'elenco esatto delle variabili di isolamento e il mapping verso le state area restano da fissare separatamente. In particolare questa decisione non decide ancora il trattamento finale di `HOME`, `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_STATE_HOME`, `XDG_CACHE_HOME`, `XDG_RUNTIME_DIR`, `TMPDIR` o altre variabili candidate.

L'impostazione di environment variables per isolamento logico non costituisce sandboxing o containment.

---

## 3. `<package-version>/env`

Il file:

```text
<package-version>/env
```

appartiene al packaging RumiAI della versione concreta ed e gestito/installato da `pkg install` insieme a quella versione.

E opzionale.

La sua responsabilita e descrivere modifiche di environment **aggiuntive** necessarie per compatibilita, integrazione o interazione con altri package, runtime o toolchain.

Esempi concettuali includono:

```text
JAVA_HOME
PATH
PYTHONPATH
NODE_PATH
GIT_CONFIG_GLOBAL
```

quando il particolare package ne ha realmente bisogno.

Un requisito come "usa questa specifica versione di Java" appartiene semanticamente a questo livello. Il file non deve pero persistere pathname assoluti host-specific: deve esprimere l'intento package-local e lasciare a `pkg run` la risoluzione runtime del package/versione/dependency e del pathname finale.

`<package-version>/env` non e il luogo in cui duplicare l'environment standard di isolamento gestito autonomamente da `pkg run`.

Il file e version-specific: due versioni concrete dello stesso package possono quindi avere `env` differenti anche quando condividono lo stesso state persistente.

---

## 4. `<package-version>/var/conf/env` come override utente

La personalizzazione persistente dell'environment da parte dell'utente appartiene alla state area `conf`.

Il pathname package-local e:

```text
<package-version>/var/conf/env
```

Poiche `var/conf` e il symbolic link relativo verso la configurazione dello state selezionato, il backing fisico e normalmente:

```text
$m_ROOT/conf/<pkg>/env
```

oppure, con una State Instance nominata:

```text
$m_ROOT/conf/<pkg>@!<state-instance>/env
```

Questo file e quindi state persistente autorevole, non parte immutabile della versione concreta.

Serve per personalizzazioni e override dell'utente rispetto alla configurazione environment fornita dal packaging.

Il file usa lo stesso modello dichiarativo di `<package-version>/env`; non viene introdotto un secondo linguaggio di configurazione per lo stesso tipo di operazioni.

La policy finale su quali eventuali variabili runtime-owned di isolamento possano essere sovrascritte dall'override utente resta aperta fino a quando non sara fissato l'elenco esatto delle variabili di isolamento e il relativo contratto.

---

## 5. Operazioni dichiarative minime

Entrambi i file `env` devono poter rappresentare almeno:

```text
set <environment-variable> <value>
unset <environment-variable>
```

La sintassi fisica concreta resta da fissare.

I file `env` non sono implicitamente:

- script shell;
- file eseguibili;
- file da `source`;
- contenitori di command substitution o codice arbitrario.

Restano inoltre separati da:

- working directory;
- fixed argv;
- user argv.

---

## 6. Layering dell'environment

Il layering concettuale corrente e:

```text
environment host ereditato/sanitizzato secondo il launch contract
        ↓
environment standard di isolamento costruito da pkg run
        ↓
<package-version>/env
        ↓
<package-version>/var/conf/env
        ↓
override espliciti per-invocation
        ↓
exec del command
```

L'override utente deve poter prevalere sulla configurazione package-version per le variabili che appartengono al suo dominio configurabile.

Gli override per-invocation restano l'ultimo livello e non modificano automaticamente ne la configurazione persistente dello state ne il selector `current`.

La policy universale di sanitizzazione dell'environment host resta aperta.

---

## 7. Risoluzione runtime e relocatability

Nessun file `env` deve hardcodare pathname dipendenti dall'installazione corrente di RumiAI, dalla posizione corrente di `$m_ROOT`, dalla versione selezionata, dallo state selezionato o da dependency risolte.

La semantica e:

```text
intento dichiarato
        ↓
pkg run determina package/versione/state/target/dependency
        ↓
risolve riferimenti e pathname runtime
        ↓
materializza l'environment finale
        ↓
exec
```

La sintassi con cui i file `env` esprimeranno riferimenti a package, versioni, dependency, state area o altri valori runtime resta aperta.

---

## 8. Relazione con `pkg run` e binding diretto

Qualunque launch che richieda:

- environment standard di isolamento;
- operazioni effettive da `<package-version>/env`;
- operazioni effettive da `<package-version>/var/conf/env`;
- altra preparazione environment runtime;

richiede mediazione di `pkg run`.

La sola esistenza fisica di un file `env` vuoto o no-op non crea artificialmente una necessita di mediazione.

Un binding diretto resta possibile soltanto quando il launch non richiede nessuna di queste modifiche runtime e le altre condizioni del modello direct-binding sono soddisfatte.

---

## 9. Relazione con lo state

`<package-version>/var/conf/env` non introduce una nuova state area.

Resta valido l'elenco canonico:

```text
conf
data
home
cache
log
run
tmp
```

`env` e un file di configurazione sotto `conf`, non una area `var/env` separata.

`home` resta il compatibility bucket conservativo per software che non permette una classificazione migliore e non viene usato come destinazione predefinita della configurazione RumiAI quando `conf` e semanticamente appropriato.

---

## 10. Formato ancora aperto

Questa decisione non fissa ancora:

- grammatica esatta di `set` e `unset`;
- quoting/escaping;
- comment syntax;
- riferimenti runtime e dependency;
- operazioni su liste come `PATH`;
- eventuali `set-if-unset`, `prepend`, `append` o equivalenti;
- validazione e failure semantics;
- eventuali overlay command-specific;
- policy di override delle variabili standard di isolamento.

Questi punti non autorizzano a trattare `env` come shell code.

---

## 11. Implementazione e test

Alla data di questa decisione non esiste ancora un comando `pkg` stabile in `rumiai-os` ne un gruppo permanente di test `pkg` in `rumiai-tests`.

Questa unita di lavoro consolida esclusivamente il design in `rumiai-dev`.

Quando verra implementato il modello, i test permanenti dovranno proteggere almeno:

- costruzione automatica dell'environment standard di isolamento da parte di `pkg run`;
- assenza della necessita di duplicare tale isolamento in `<package-version>/env`;
- applicazione di `<package-version>/env` dopo l'isolamento runtime;
- applicazione di `var/conf/env` come configurazione persistente dello state selezionato;
- precedenza dell'override utente sulla configurazione package-version nel dominio consentito;
- precedenza degli override per-invocation;
- risoluzione relocatable dei riferimenti runtime;
- assenza di hardcoding host-specific;
- separazione da working directory e argv;
- assenza di una state area `var/env`.

---

## 12. Invarianti fissati

```text
PKG-ENV-01  pkg run costruisce autonomamente l'environment standard di isolamento secondo il mapping runtime fissato separatamente
PKG-ENV-02  le variabili di isolamento standard non devono essere duplicate in <package-version>/env per applicare il normale modello RumiAI
PKG-ENV-03  <package-version>/env e opzionale, version-specific e gestito da pkg install
PKG-ENV-04  <package-version>/env descrive environment aggiuntivo per compatibilita/interazione con package, runtime o toolchain
PKG-ENV-05  <package-version>/var/conf/env e configurazione persistente autorevole dello state selezionato
PKG-ENV-06  var/conf/env rappresenta personalizzazioni e override utente rispetto all'env della versione
PKG-ENV-07  i due file env usano lo stesso modello dichiarativo
PKG-ENV-08  il modello env supporta almeno set e unset
PKG-ENV-09  env non descrive working directory o argv
PKG-ENV-10  env non e implicitamente shell code, executable o file da source
PKG-ENV-11  i pathname runtime-managed non sono hardcodati nei file env
PKG-ENV-12  pkg run risolve a runtime valori dipendenti da root/versione/state/dependency/target
PKG-ENV-13  il layering e host base -> isolamento pkg run -> env versione -> var/conf/env -> override per-invocation
PKG-ENV-14  un launch che richiede uno dei livelli environment gestiti richiede mediazione pkg run
PKG-ENV-15  env sotto var/conf non introduce una nuova state area; resta configurazione nella area conf
PKG-ENV-16  l'elenco esatto delle variabili di isolamento e il loro mapping alle state area restano aperti
PKG-ENV-17  la policy di override delle variabili runtime-owned di isolamento resta aperta fino alla definizione del mapping di isolamento
```
