# Audit di `massimilianonardi/m` — Primitive POSIX, deep dive iniziale

Data: 2026-08-27

Snapshot:

```text
e4faae1c1d9b27cc5503b987ba5e7bf2874c906c
```

## Scopo

Il repository `m` contiene diverse implementazioni nate per ottenere in shell POSIX funzionalità normalmente associate a Bash, GNU o linguaggi con strutture dati più ricche.

Questa direzione è coerente con il contratto di `rumiai-os`, ma **evitare Bash/GNU non basta a rendere una primitiva corretta o POSIX-portable**.

Ogni primitiva candidata deve quindi essere valutata su quattro assi distinti:

```text
POSIX syntax/API compliance
semantic correctness
exact data preservation
security / injection resistance
```

Questo documento avvia tale audit.

---

# 1. Principio generale emerso

Il valore più importante del codice esistente non è necessariamente la singola implementazione, ma l'idea di avere un piccolo **POSIX portability layer** con semantica definita da RumiAI OS.

La libreria non deve imitare Bash per principio. Deve fornire soltanto primitive realmente necessarie al sistema e deve farlo con un contratto verificabile.

Criterio proposto:

```text
se POSIX offre già una soluzione chiara
    usare POSIX direttamente

se manca una primitiva ma è realmente necessaria
    definire una nostra API minima
    implementarla con strumenti POSIX
    testarla su shell/host differenti

se la soluzione richiede una dipendenza esterna
    dichiarare la dipendenza/capability esplicitamente
```

---

# 2. `array.lib.sh`

API esistente:

```text
array NAME
array NAME size
array NAME get [INDEX]
array NAME put INDEX VALUE
array NAME add VALUE
array NAME ins INDEX VALUE
array NAME rem INDEX
array NAME set VALUES...
array NAME unset
```

L'implementazione simula un array attraverso variabili shell:

```text
<NAME>_TYPE
<NAME>_SIZE
<NAME>_0
<NAME>_1
...
```

ed usa `eval` per accesso indiretto.

## Aspetto valido

L'API dimostra che è possibile mantenere il core `/bin/sh` senza introdurre Bash solo per avere array.

## Problemi

### 2.1 `eval` è parte della rappresentazione

L'indirection non è confinata in un singolo punto: `eval` è usato per:

- type check;
- size;
- read;
- write;
- arithmetic;
- unset;
- ricostruzione degli argomenti.

Questo aumenta molto la superficie di quoting/injection.

### 2.2 Seconda interpretazione di alcuni valori

Alcuni rami costruiscono codice shell concatenando direttamente valori ricevuti prima di passarlo a `eval`.

Ad esempio `add` costruisce dinamicamente un'assegnazione contenente il valore. Un valore che contenga sintassi shell deve quindi essere considerato un caso di sicurezza prioritario: non possiamo assumere che venga conservato come puro dato.

### 2.3 Output non adatto a dati arbitrari

Alcuni `get` usano `echo` e ricostruiscono liste testuali. Un array capace di contenere dati generici deve avere una semantica chiara per:

- spazi;
- tab;
- newline;
- backslash;
- glob;
- stringhe vuote;
- quote;
- byte non rappresentabili in variabili shell (NUL).

## Classificazione preliminare

```text
requirement: KEEP
API idea: KEEP / REDESIGN
implementation: REIMPLEMENT or prove through tests
```

---

# 3. `map.lib.sh`

La mappa usa variabili shell dinamiche come storage e codifica le chiavi per trasformarle in identificatori.

Dipende da:

```text
arg.lib.sh
env.lib.sh
enc.lib.sh
```

ed eredita quindi la complessità di `eval`, enumeration dell'environment e encoding.

## Aspetto interessante

Una key/value abstraction può essere utile negli script complessi, ma non è automaticamente necessario che sia rappresentata nell'environment della shell.

## Problemi da testare

- collisioni nella codifica delle chiavi;
- chiavi vuote;
- unicode/locale;
- newline;
- caratteri shell;
- enumerazione affidabile;
- isolamento fra mappe e variabili normali;
- injection attraverso nome mappa/chiave;
- preservation esatta dei valori.

## Classificazione preliminare

**REDESIGN / REIMPLEMENT.**

Prima va stabilito se `rumiai-os` abbia davvero bisogno di una map generica in shell o se il problema possa essere modellato in modo più semplice.

---

# 4. `arg.lib.sh`: quote e serializzazione degli argomenti

`quote()` e `saveargs()` cercano di produrre una rappresentazione shell-riutilizzabile degli argomenti.

È una primitiva importante perché molte altre librerie dipendono dalla capacità di serializzare e ricostruire argv.

## Rischio semantico

La shell POSIX non può contenere NUL in una variabile; questo limite va dichiarato esplicitamente.

Vanno inoltre testati:

```text
""
" "
"a b"
"'"
"\""
"\\"
"$"
"`"
"$(...)"
"* ? ["
newline interno
newline finale
multi-linea
UTF-8
```

Il caso **newline finale** è particolarmente importante perché command substitution rimuove newline finali: un round-trip basato su `$(...)` può quindi essere lossy anche quando il quoting testuale appare corretto.

## Regola candidata

Qualunque funzione di serializzazione argv deve avere un test di proprietà:

```text
decode(encode(argv)) == argv
```

per tutto il dominio dichiarato.

---

# 5. `env.lib.sh`

Questa libreria non è un semplice helper: tenta di creare un protocollo per trasferire stato shell tra comandi/funzioni.

Concetti presenti:

```text
env_eval
env_return
env_import
env_export
env_read
env_read_state
env_main
```

## Aspetto architetturale interessante

Il problema affrontato è reale: una subshell non può modificare direttamente l'environment del processo padre.

La libreria cerca quindi di serializzare le modifiche e farle reinterpretare dal caller.

## Problema principale

La soluzione è fortemente basata su `eval` e su output che rappresenta codice shell.

`env_import()` esegue esplicitamente:

```sh
eval "$1"
```

Quindi **dati e codice diventano indistinguibili** se il trust boundary non è rigidamente controllato.

## Ulteriore fragilità

`env_list()` ricostruisce nomi di variabili analizzando l'output di `set` con `sed`.

Questa strategia deve essere testata sulle shell target, perché formato e quoting dell'output di `set` possono variare e valori multilinea complicano il parsing.

## Classificazione preliminare

```text
problem/requirement: KEEP
protocol idea: REDESIGN
implementation: REIMPLEMENT unless formally constrained and proven
```

Per `rumiai-os` è preferibile evitare di serializzare shell code quando è sufficiente un formato dati.

---

# 6. `realpaths.lib.sh`

La libreria recente tenta di sostituire il bisogno di `readlink -f` e calcola:

```text
CALL_DIR
THIS_PATH
THIS_FILE
THIS_DIR
```

## Aspetto valido

Eliminare una dipendenza GNU-specifica dal bootstrap è un requisito fondamentale.

## Bug/edge case importanti

### 6.1 Invocazione tramite PATH

La logica usa:

```sh
${0%/*}
```

Se `$0` non contiene `/` perché il comando è stato trovato tramite `PATH`, la parameter expansion non produce automaticamente la directory del comando. Questo caso deve essere gestito esplicitamente.

### 6.2 Symlink relativo

Quando `$0` è un symlink, il target viene estratto analizzando `ls -ld`.

Se il target del link è relativo, deve essere interpretato **relativamente alla directory contenente il symlink**, non relativamente alla current working directory del processo.

La funzione attuale non formalizza chiaramente questo passaggio e può risolvere il target nel luogo sbagliato.

### 6.3 Catene di symlink

La funzione esamina un singolo livello di link. Una catena:

```text
a -> b -> c
```

richiede iterazione e cycle detection se l'obiettivo è ottenere una canonical location.

### 6.4 Parsing di `ls -l`

Estrarre il target del symlink dal rendering testuale di `ls -l` è intrinsecamente delicato rispetto a:

- locale;
- nomi contenenti spazi;
- stringhe contenenti ` -> `;
- newline nei nomi;
- differenze implementative.

## Classificazione preliminare

```text
requirement: KEEP
current implementation: REIMPLEMENT
```

La semantica di `rumiai-os root discovery` deve essere specificata prima di scegliere la soluzione.

---

# 7. Comando storico `path`

`var/#_os/m/bin/path` mostra una versione più ampia dello stesso problema e implementa:

- existence;
- readlink;
- absolute path;
- link resolution;
- clean/canonicalization;
- relativize.

È utile perché raccoglie molti requisiti che il bootstrap moderno dovrà affrontare.

## Punto positivo

La separazione fra:

```text
absolute
resolve links
relativize
exist
```

è migliore di una generica funzione `realpath` con semantica implicita.

## Limiti

Anche questa implementazione estrae target symlink da `ls -ld` e contiene un TODO esplicito sulla risoluzione ricorsiva/cycle detection.

Usa inoltre opzioni/utilità che dovranno essere verificate puntualmente contro la versione POSIX scelta come baseline.

## Direzione

Il futuro portability layer dovrebbe definire **più operazioni con contratti precisi**, non necessariamente clonare il comportamento GNU di `readlink -f`.

---

# 8. `enc.lib.sh`: finding POSIX concreto

Le funzioni:

```text
rand
randint
```

sono commentate come POSIX-compliant, ma usano:

```sh
$RANDOM
```

`RANDOM` non fa parte delle variabili della shell POSIX. La rationale POSIX la indica esplicitamente tra le funzionalità non incluse.

Su una shell che non fornisce `RANDOM`, il seed può quindi risultare vuoto/zero e la funzione non ha la semantica casuale dichiarata.

### Classificazione

**BUG + non-POSIX dependency.**

---

# 9. `enc.lib.sh`: `printf` con dato usato come formato

`a2o()` contiene un pattern equivalente a:

```sh
printf "$1"
```

Il primo operando di `printf` è il **format string**, non un dato opaco.

Quindi `%`, backslash e conversion specification nel valore possono cambiare l'output o il comportamento.

La forma corretta per stampare dati non interpretati è concettualmente:

```sh
printf '%s' "$value"
```

### Classificazione

**BUG di data handling.**

Questa regola dovrebbe entrare nel lint statico di `rumiai-os`:

> il format operand di `printf` deve essere costante salvo casi deliberati e documentati.

---

# 10. `enc.lib.sh`: POSIX core vs external capability

Funzioni come:

```text
randh
rand64
randstr
encode
decode
```

dipendono da `openssl`.

Non è un problema in sé, ma `openssl` non è una primitiva POSIX garantita.

Quindi queste funzioni non possono essere classificate come **core POSIX primitive** senza dichiarare la capability/dependency.

Distinzione proposta:

```text
posix-core/
    solo shell + utilities richieste dal contratto POSIX scelto

optional-tools/
    primitive implementate tramite package/capability esterni
```

Il naming definitivo non è ancora deciso.

---

# 11. `encoded_file_import`: trust boundary

La funzione decodifica un file e ne esegue il contenuto tramite `eval`.

Questa può essere una funzionalità deliberata, ma deve essere modellata come:

```text
execute trusted encrypted shell code
```

non come semplice funzione di decoding.

Nel nuovo sistema il nome/API deve rendere esplicito che avviene **code execution** e il chiamante deve stabilire il trust della sorgente.

---

# 12. `echo` vs `printf`

Diverse librerie usano `echo` per restituire dati arbitrari.

Per un portability layer questo è rischioso, perché il trattamento di stringhe contenenti backslash o che assomigliano a opzioni non offre la stessa prevedibilità di:

```sh
printf '%s\n' "$value"
```

Regola candidata:

> nelle primitive di sistema, `printf` con formato costante è il default per emettere dati; `echo` è riservato a messaggi semplici quando la semantica esatta del dato non è rilevante.

---

# 13. `eval`: policy candidata

L'audit sta mostrando che molte primitive POSIX storiche sostituiscono feature Bash attraverso `eval`.

Non è realistico vietare `eval` a priori: in POSIX shell alcuni tipi di indirection possono richiederlo.

Ma va trattato come una **dangerous primitive**.

Proposta da validare:

1. `eval` non è vietato in assoluto;
2. ogni uso deve essere confinato in librerie primitive ben definite;
3. nessun dato non trusted deve diventare shell syntax;
4. i nomi dinamici devono essere validati contro una grammatica stretta;
5. i valori devono rimanere valori dopo la seconda parse;
6. ogni funzione che usa `eval` richiede test injection/round-trip specifici;
7. l'application code non dovrebbe usare `eval` direttamente se esiste una primitiva standardizzata.

---

# 14. Test matrix minima per le primitive

Le future primitive candidate devono essere testate almeno su più shell indipendenti.

Famiglie utili da considerare:

```text
dash
BusyBox ash
ksh implementation compatibile
shell di macOS usata come /bin/sh
Cygwin /bin/sh
```

La lista definitiva dipenderà dagli ambienti certificati.

Ogni test deve partire dalla stessa API e dagli stessi input.

## Data corpus comune

```text
empty
ASCII semplice
spazi iniziali/finali
multipli spazi
tab
newline interno
newline finale
quote singola
quote doppia
backslash
$ e backtick
command-substitution-looking text
glob characters
leading dash
percent sign
UTF-8
very long value
```

---

# 15. Static checks candidati

Il lint di `rumiai-os` dovrebbe poter segnalare almeno:

```text
#!/bin/bash
#!/usr/bin/env bash
[[ ... ]]
$'...'
${BASH_SOURCE...}
process substitution
readlink -f
grep -P
sort --version-sort
sed -i
$RANDOM
printf "$variable"
echo -e
```

La presenza non implica sempre automaticamente errore per tutte le stringhe trovate, ma il controllo deve almeno richiedere una classificazione/allowlist esplicita per le eccezioni ammesse.

---

# 16. Classificazione preliminare delle primitive analizzate

| Componente | Problema affrontato | Esito preliminare |
|---|---|---|
| `arg.lib.sh` | argv quoting/serialization | KEEP requirement / VERIFY-REDESIGN |
| `array.lib.sh` | array POSIX | KEEP requirement / REIMPLEMENT-VERIFY |
| `map.lib.sh` | map POSIX | REQUIREMENT TO VALIDATE / REDESIGN |
| `env.lib.sh` | state transfer | KEEP problem / REDESIGN |
| `realpaths.lib.sh` | root/path resolution | KEEP problem / REIMPLEMENT |
| storico `path` | path operations | KEEP requirements / REIMPLEMENT |
| `enc.lib.sh` encoding | crypto helper | optional capability, not POSIX core |
| `enc.lib.sh` random | random helper | current implementation contains non-POSIX bug |

---

# 17. Implicazione per `rumiai-os`

Non conviene importare `cmd/lib` come una generica standard library.

Conviene invece procedere così:

```text
inventario esigenze reali
        ↓
contratto di ogni primitiva
        ↓
smallest POSIX implementation
        ↓
conformance + edge-case tests
        ↓
security tests
        ↓
solo allora ingresso in rumiai-os
```

Questo ci permette di recuperare il lavoro e le intuizioni di `m` senza trasformare automaticamente workaround storici in API permanenti del nuovo sistema.

---

# 18. Prossimi passi specifici

1. completare l'inventario di `cmd/lib` e delle corrispondenti `m-*.lib` storiche;
2. identificare duplicazioni e generazioni successive della stessa primitiva;
3. definire il contratto di root/path resolution, perché serve immediatamente all'entrypoint `rumiai-os`;
4. creare in `rumiai-dev-PoCs` una harness POSIX cross-shell per le prime primitive candidate;
5. partire da `argv quoting`, `path/root resolution` e `array`, perché sono fondazioni usate da molti altri script;
6. aggiungere static checks POSIX prima di iniziare il codice stabile in `rumiai-os`.
