# Decisione — Package `env` come frammento shell sourced

Date: 2026-09-06  
Status: **Accepted**

## Contesto

Il modello corrente dei package ha gia fissato:

- `launcher` come funzione comune del sistema base in `lib/sh/core.lib.sh`;
- `cmd/<pkg-command>` come command entry RumiAI eseguito tramite `rumiai-os`;
- environment standard di isolamento costruito dal launcher usando direttamente le root semantiche;
- `<package-version>/env` come configurazione version-specific per compatibilita/interazione con altri package, runtime o toolchain;
- `$m_CONF_DIR/<pkg>/env`, raggiungibile anche tramite `<package-version>/var/conf/env`, come personalizzazione/override persistente dell'utente;
- layering `isolamento -> env package -> env utente -> exec`;
- `var/` come routing dello state raggiunto tramite pathname upstream, indipendente dal routing via environment.

La precedente decisione `2026-09-06-package-environment-layering.md` aveva introdotto per i file `env` un formato dichiarativo separato dalla shell, con una futura grammatica propria almeno per `set` e `unset`.

Questa separazione non e necessaria nel modello di launch corrente: i file `env` fanno parte della preparazione del comando, sono consumati da un launcher shell gia eseguito nel runtime POSIX RumiAI e devono poter usare direttamente le primitive della shell invece di richiedere un parser o un mini-linguaggio equivalente.

Questa decisione modifica soltanto `rumiai-dev`. Non autorizza modifiche a `rumiai-os` o `rumiai-tests`.

---

## 1. Semantica di `env`

I file:

```text
<package-version>/env
$m_CONF_DIR/<pkg>/env
```

sono **frammenti di shell POSIX da caricare con il dot command `.`** nel processo del `launcher`.

La forma canonica di consumo e semanticamente:

```sh
. "$package_env"
. "$user_env"
```

quando i rispettivi file esistono.

Il termine colloquiale `source` indica questa operazione, ma l'implementazione canonica usa il dot command POSIX `.` e non dipende dalla keyword non-POSIX `source`.

I file non richiedono:

- shebang;
- bit executable;
- un interprete separato;
- un parser RumiAI;
- una grammatica RumiAI per assegnazioni, unset o liste.

---

## 2. Shell semantics, non mini-linguaggio

Dentro `env` valgono direttamente le normali primitive e regole della shell POSIX applicabili al launch, incluse quando necessarie:

```text
assegnazioni
export
unset
parameter expansion
command substitution
case
if
for/while
funzioni shell
invocazioni di comandi
```

RumiAI non introduce una sintassi parallela come:

```text
set <name> <value>
unset <name>
prepend <name> <value>
append <name> <value>
```

quando la stessa responsabilita puo essere espressa direttamente dalla shell.

Le normali regole di export restano normative. Per esempio una nuova variabile destinata al processo upstream deve essere esportata esplicitamente secondo la semantica shell:

```sh
JAVA_HOME="..."
export JAVA_HOME
```

oppure con altra forma POSIX equivalente.

Il launcher non applica implicitamente `set -a` e non trasforma automaticamente ogni assegnazione in una environment variable esportata.

---

## 3. `<package-version>/env`

Il file:

```text
<package-version>/env
```

resta opzionale, version-specific e gestito/materializzato da `pkg install`.

Serve per la preparazione environment richiesta da compatibilita, integrazione e interazione con altri package, runtime o toolchain.

Esempi concettuali:

```text
JAVA_HOME
PATH
PYTHONPATH
NODE_PATH
GIT_CONFIG_GLOBAL
```

quando necessari al package concreto.

Essendo parte del packaging RumiAI, il contenuto installato deve rispettare il contratto POSIX corrente e le regole di relocatability del progetto. Non deve incorporare accidentalmente pathname host-specific o dipendenze non previste.

Il fatto che il file sia shell code elimina la necessita di una futura sintassi speciale per riferimenti, quoting, escaping, assegnazioni o manipolazioni di `PATH`; tali operazioni usano direttamente la shell.

---

## 4. Env utente

La personalizzazione persistente dell'utente resta:

```text
$m_CONF_DIR/<pkg>/env
```

nel baseline state non qualificato ed e raggiungibile anche tramite:

```text
<package-version>/var/conf/env
```

quando `var/conf` e presente.

Anche questo file e un frammento shell POSIX sourced dal `launcher`.

Viene caricato dopo `<package-version>/env`, quindi puo modificare o sovrascrivere il risultato dell'env installato secondo le normali regole shell.

Il file e state persistente autorevole sotto `conf`, non parte della versione concreta.

---

## 5. Layering

Il layering corrente resta:

```text
environment host ereditato/sanitizzato secondo il launch contract
        ↓
environment standard di isolamento costruito da launcher
        ↓
source <package-version>/env
        ↓
source $m_CONF_DIR/<pkg>/env
        ↓
eventuali override espliciti gia forniti dal caller
        ↓
exec <package-version>/link/<pkg-command>
```

L'environment standard di isolamento resta responsabilita del `launcher` e non deve essere duplicato nel package `env` soltanto per applicare il normale modello RumiAI.

Le variabili di isolamento continuano a usare direttamente le root semantiche, per esempio:

```text
HOME=$m_HOME_DIR/<pkg>
```

nel baseline state non qualificato.

`var/` non viene usato come sorgente dell'identita dello state per l'environment e resta indipendentemente responsabile del routing dei pathname upstream mutabili.

---

## 6. Effetti della semantica sourced

Poiche `env` viene caricato nello stesso processo shell del `launcher`, le modifiche shell effettuate dal file persistono nel contesto del launch secondo le normali regole POSIX.

Questo e intenzionale per le modifiche di environment.

Non viene introdotto un sandbox o un interprete ristretto per `env`: un frammento sourced dispone delle capacita della shell con cui viene eseguito. Di conseguenza il package `env` appartiene allo stesso dominio di fiducia del command/package installato e l'env utente appartiene al dominio di controllo dell'utente.

La responsabilita semantica del file resta la preparazione del launch environment. L'uso di primitive shell non trasforma `env` in un secondo command entry e non cambia le responsabilita separate di `cmd/`, `launcher`, `link/`, `root/` o `var/`.

---

## 7. Relocability

La sostituzione del formato dichiarativo con shell POSIX non modifica il requisito di relocatability.

Il package `env` deve usare le root/path semantiche e le informazioni runtime messe a disposizione dal sistema base invece di persistere path assoluti dipendenti dall'installazione corrente.

Se in futuro un package necessita di una nuova informazione runtime per costruire correttamente il proprio env, tale informazione deve essere aggiunta esplicitamente al contratto runtime appropriato; non viene introdotta ora una nuova environment variable o un nuovo namespace soltanto per anticipare casi non ancora concreti.

---

## 8. Error handling

La presenza di un file `env` implica che esso faccia parte della preparazione necessaria al launch.

Se un file presente non puo essere letto, contiene un errore di sintassi che impedisce il caricamento o il caricamento fallisce secondo la semantica adottata dal `launcher`, il command upstream non deve essere eseguito come se l'env fosse stato applicato correttamente.

I codici e la classificazione finale degli errori del `launcher` restano da fissare insieme all'implementazione e ai test permanenti.

Un file assente resta semplicemente un layer opzionale non applicato.

---

## 9. Supersession

Questa decisione supersede integralmente `2026-09-06-package-environment-layering.md` per il formato e la semantica operativa dei file `env`, mantenendone soltanto le responsabilita riaffermate qui:

```text
isolamento standard separato dall'env package
<package-version>/env version-specific e gestito da pkg install
$m_CONF_DIR/<pkg>/env come override persistente utente
ordine package env -> user env
nessuna nuova state area var/env
relocatability
```

Sono superseded in particolare:

```text
env come formato dichiarativo non-shell
grammatica RumiAI set/unset
necessita di parser/interprete RumiAI per env
divieto di source
divieto di shell code
punti aperti relativi a quoting/escaping/prepend/append di un mini-linguaggio env
```

Sono inoltre superseded le sole frasi incompatibili nelle decisioni Accepted successive `2026-09-06-package-self-contained-launch-and-default-state.md` e `2026-09-06-package-command-entry-link-and-launcher.md` che affermano che i file `env` siano dichiarativi e non sourced. Tutte le altre parti compatibili di tali decisioni restano valide.

---

## 10. Implementazione e test

Alla data di questa decisione `rumiai-os` non implementa ancora il package `launcher` qui descritto e `rumiai-tests` non contiene test permanenti `pkg`/`launcher`.

L'implementazione prodotto richiede una fase successiva esplicitamente autorizzata.

Quando il modello verra implementato, i test permanenti dovranno proteggere almeno:

```text
source POSIX di <package-version>/env quando presente
source POSIX di $m_CONF_DIR/<pkg>/env quando presente
ordine isolation -> package env -> user env -> exec
persistenza nel processo launcher delle variabili/modifiche sourced
normale semantica export/unset senza auto-export implicito
assenza di parser o mini-linguaggio env RumiAI
assenza di requisito shebang/executable bit per env
failure del launch se un env presente non puo essere applicato correttamente
relocatability del package env installato
```

---

## 11. Invarianti fissati

```text
PKG-ENV-SH-01  <package-version>/env e un frammento shell POSIX opzionale sourced dal launcher
PKG-ENV-SH-02  $m_CONF_DIR/<pkg>/env e un frammento shell POSIX opzionale sourced dal launcher come override persistente utente
PKG-ENV-SH-03  il caricamento canonico usa il dot command POSIX . e non richiede la keyword source
PKG-ENV-SH-04  env non richiede shebang o bit executable
PKG-ENV-SH-05  RumiAI non definisce un mini-linguaggio env parallelo alla shell
PKG-ENV-SH-06  assegnazione, export, unset, espansioni e altre primitive necessarie seguono direttamente la semantica POSIX shell
PKG-ENV-SH-07  il launcher non usa set -a e non auto-esporta assegnazioni non esportate
PKG-ENV-SH-08  <package-version>/env resta version-specific e gestito da pkg install
PKG-ENV-SH-09  l'env utente resta state persistente autorevole sotto conf e viene applicato dopo l'env package
PKG-ENV-SH-10  il layering e host -> isolation launcher -> source package env -> source user env -> override caller -> exec
PKG-ENV-SH-11  l'environment standard di isolamento resta costruito dal launcher direttamente sulle root semantiche
PKG-ENV-SH-12  var/ resta separato e continua a gestire il routing dei pathname upstream mutabili
PKG-ENV-SH-13  il package env installato resta soggetto a POSIX e relocatability
PKG-ENV-SH-14  un env presente che non puo essere applicato correttamente impedisce il normale exec upstream
PKG-ENV-SH-15  questa decisione supersede il precedente contratto env dichiarativo/non-shell
```
