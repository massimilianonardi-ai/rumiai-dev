# Decisione — `pkg_analyze` come strumento diagnostico per package definition

Date: 2026-09-09  
Updated: 2026-09-09  
Status: **Accepted**

## Contesto

Il piano corrente di `pkg` richiede come passo successivo il completamento della package definition DBeaver prima di `pkg_integrate`.

Per costruire una package definition reale è utile osservare sistematicamente proprietà che non sono affidabili da inferire dal nome dell'artifact o da una singola release, fra cui:

```text
candidate command/executable
pathname creati durante il primo launch
state scritto nella home o nelle directory controllabili tramite environment
variazioni funzionali fra release e target differenti
```

Il progetto storico `massimilianonardi/m` conteneva una discovery `find_deepest_dir`; il codice storico resta materiale di riferimento e non viene importato come autorità o copiato automaticamente.

L'utente fissa il nome del nuovo strumento come:

```text
pkg_analyze
```

L'underscore è quindi una spelling deliberatamente stabilita per questo comando diagnostico. Non introduce una nuova convenzione generale per i command RumiAI.

La correzione esplicita del 2026-09-09 fissa inoltre che `pkg_extract` deve consegnare direttamente la useful root normalizzata tramite structural discovery generica. Una successiva correzione chiarisce che `pkg_analyze` **deve continuare a usare `pkg_extract`** proprio per non esporre alla fase di analisi i wrapper/path interni variabili fra release.

---

## 1. Ruolo

`pkg_analyze` è uno strumento diagnostico per chi prepara o aggiorna package definition.

Non appartiene alla pipeline automatica di normale `pkg install` e non diventa una fase implicita dell'installazione.

Il suo output è evidence diagnostica human-readable che aiuta a scrivere o correggere la package definition. Non è esso stesso una package definition, un receipt, un lock o una nuova serializzazione normativa.

Il tool non contiene conoscenza di DBeaver o di altri prodotti specifici.

---

## 2. Input iniziali

Le forme iniziali restano:

```text
pkg_analyze <extracted-directory>
pkg_analyze <format> <artifact>
```

### Forma artifact

La forma:

```text
pkg_analyze <format> <artifact>
```

crea uno staging temporaneo e **deve riusare**:

```text
pkg_extract <artifact> <format> <staging-dir>
```

`pkg_analyze` riceve quindi il tree già normalizzato da `pkg_extract` e non replica né:

```text
format/backend selection
raw extraction
structural useful-root discovery
wrapper removal
```

Questo riuso è intenzionale e necessario: l'analisi deve osservare lo stesso payload normalizzato che verrà consegnato a `pkg_integrate` durante una vera installazione.

### Forma directory

La forma:

```text
pkg_analyze <extracted-directory>
```

analizza direttamente il tree fornito dall'utente e lo considera già come root utile/normalizzata. Non tenta di reinterpretarne wrapper o risalire a un artifact originario.

È una forma diagnostica esplicita per tree preparati esternamente e non modifica il contratto della forma artifact.

---

## 3. Useful root

Nella forma artifact la useful root **non viene scelta dall'utente** e non viene scoperta da `pkg_analyze`.

La root del tree restituito da `pkg_extract` è già la useful root normalizzata.

Di conseguenza non appartengono più al contratto futuro di `pkg_analyze`:

```text
suggested useful root
prompt di accettazione della useful root
override relativo della useful root
find_deepest_dir come responsabilità propria di pkg_analyze
```

La responsabilità strutturale equivalente a `find_deepest_dir` appartiene a `pkg_extract`.

Questo evita che pathname come:

```text
<product>-<version>/
<product>/<version>/
```

entrino nell'evidence normativa del catalogo o richiedano un nuovo range a ogni release.

`pkg_analyze` può riportare nel report che il payload analizzato è già normalizzato, ma non deve trasformare il wrapper originale in metadata della package definition.

---

## 4. Rapporto con `pkg_extract`, range e `latest`

Il confine corretto è:

```text
artifact
    -> pkg_extract
        -> raw materialization
        -> structural useful-root discovery
        -> wrapper removal
        -> normalized useful root
    -> pkg_analyze
        -> candidate discovery
        -> dynamic probe
        -> evidence funzionale
```

Una modifica del solo wrapper/path interno dell'artifact non deve produrre una differenza di package definition e non deve introdurre un nuovo range.

I range cambiano quando cambia un requisito semantico reale, per esempio:

```text
artifact selection/format
command mapping
runtime/environment requirements
state/path normalization
facility/dependency
altra integrazione effettivamente differente
```

non quando cambia soltanto un pathname strutturale eliminato da `pkg_extract`.

Questo conserva il comportamento già fissato di `latest`: le release successive continuano a ricadere nell'ultimo range finché il contratto reale del package resta compatibile.

---

## 5. Candidate command discovery

Sotto la root normalizzata il tool elenca file regolari candidati al launch.

Il baseline distingue:

```text
executable
    file con executable bit secondo il filesystem/host corrente

launch-like
    file senza executable bit ma con una estensione comunemente associata a script/programmi lanciabili
```

La lista iniziale `launch-like` comprende euristicamente:

```text
.sh .bash .zsh .ksh .command
.bat .cmd .ps1
.exe .com
.jar
.py .pl .rb
```

Questa classificazione è soltanto diagnostica e può evolvere con casi reali. Non diventa una regola di command discovery di `pkg install`: il package manager continua a non scansionare `root/` per decidere autonomamente i command pubblici.

I candidate vengono presentati in ordine deterministico per pathname relativo.

Pathname contenenti TAB/CR/LF non sono rappresentabili nella lista interattiva line-oriented corrente: vengono segnalati e saltati, senza rinomina o normalizzazione del pathname upstream.

---

## 6. Selezione dei command da studiare

L'utente seleziona esplicitamente uno o più candidate dalla lista.

La selezione rappresenta:

```text
candidate da considerare per l'export nella package definition
candidate da sottoporre, quando possibile e autorizzato, al dynamic probe
```

`pkg_analyze` non modifica direttamente `pkg-catalog` e non pubblica binding sotto `bin/ext*`.

---

## 7. Dynamic probe

L'esecuzione di software upstream non è implicita.

Dopo la selezione `pkg_analyze` mostra un warning e richiede una conferma separata prima di eseguire qualunque candidate.

Ogni candidate viene osservato separatamente con directory temporanee fresche.

Il probe reindirizza almeno:

```text
HOME
XDG_CONFIG_HOME
XDG_DATA_HOME
XDG_CACHE_HOME
XDG_STATE_HOME
XDG_RUNTIME_DIR
TMPDIR
TMP
TEMP
```

verso directory temporanee vuote appartenenti a quel singolo probe.

Il working directory del processo è la root normalizzata analizzata.

Un file già executable viene eseguito direttamente. Nel baseline iniziale un file `.sh` non-executable può essere provato tramite POSIX `sh`. Gli altri file `launch-like` non direttamente eseguibili dal contesto POSIX vengono comunque riportati come candidate ma non vengono avviati artificialmente tramite runtime non ancora fissati.

---

## 8. Il probe non è un sandbox

La redirezione dell'environment è osservazione diagnostica, non containment o security isolation.

Un programma selezionato gira con i privilegi normali dell'utente e può:

```text
ignorare HOME/XDG/tmp
accedere ad altri pathname
usare la rete
lanciare processi figli
modificare file non osservati dal report
```

Il warning prima dell'esecuzione è quindi obbligatorio.

Il tool non deve descrivere il dynamic probe come sandbox sicuro.

Il `launcher` package canonico non è ancora implementato nel runtime corrente. `pkg_analyze` non introduce una funzione alternativa chiamata `launcher` e non anticipa la firma del launcher definitivo. Quando il launcher reale esisterà, il riuso potrà essere valutato soltanto se il suo contratto coincide con le esigenze diagnostiche.

---

## 9. Snapshot e report

Per ogni candidate realmente sottoposto a probe, il tool confronta inventari di pathname prima/dopo per:

```text
root normalizzata del package
HOME originale osservata all'avvio del tool, quando disponibile
tree delle directory environment redirette
```

Il baseline registra tipo di entry e pathname relativo e riporta entry aggiunte/rimosse.

Non calcola digest di tutti i file e quindi una modifica in-place che non cambia pathname/type può non essere rilevata. Questa è una limitazione intenzionale del primo baseline per mantenere il probe proporzionato anche su package grandi.

Il report include inoltre l'exit status del candidate.

Dopo il ritorno del candidate il tool permette all'operatore di attendere la conclusione di eventuali figli prima di acquisire lo snapshot finale.

---

## 10. State e side effect del tool

Il solo state posseduto da `pkg_analyze` è temporaneo e vive sotto `m_TMP_DIR`.

Il tool non modifica intenzionalmente:

```text
$m_ROOT/pkg
selector current
bin/ext*
package state persistente
pkg-catalog
provider index
binding
```

Un tree passato direttamente dall'utente può naturalmente essere modificato dal software upstream che l'utente sceglie di eseguire; questa possibilità fa parte del warning del probe.

---

## 11. Testing e stato di riallineamento

La copertura permanente deve proteggere almeno:

```text
exit status per uso invalido
forma artifact delegata a pkg_extract
analisi della root già normalizzata restituita da pkg_extract
assenza di prompt/discovery useful-root nella forma artifact
forma directory trattata come root già normalizzata
classificazione executable/launch-like
ordine deterministico dei candidate
selezione esplicita prima del probe
nessuna esecuzione senza consenso separato
redirezione HOME/XDG/tmp per il candidate
report del package-root path delta
report dello state rediretto
assenza di path delta nella HOME originale quando il fixture rispetta la redirezione
preservazione dell'exit status del candidate nel report senza trasformarlo automaticamente in failure di pkg_analyze
cleanup dello staging/work temporaneo
```

I test di `pkg_analyze` non duplicano i test permanenti dei backend `extract` o della structural useful-root discovery interna a `pkg_extract`.

Alla data di questa correzione, l'implementazione corrente di `pkg_analyze` riusa già `pkg_extract` nella forma artifact, ma esegue ancora una seconda discovery interattiva della useful root tramite `pkg_analyze_find_deepest_dir`/prompt.

Quella parte dell'implementazione e i relativi test sono **pending realignment**: dopo il nuovo `pkg_extract`, la forma artifact deve usare direttamente la root normalizzata ricevuta e non ripetere la discovery.

---

## 12. Invarianti fissati

```text
PKG-ANALYZE-01  pkg_analyze è uno strumento diagnostico esplicito per costruire/verificare package definition, non una fase automatica di pkg install
PKG-ANALYZE-02  le forme iniziali restano pkg_analyze <extracted-directory> e pkg_analyze <format> <artifact>
PKG-ANALYZE-03  la forma artifact DEVE usare pkg_extract e analizzare il tree normalizzato che esso restituisce
PKG-ANALYZE-04  pkg_analyze non replica raw extraction, format/backend selection o structural useful-root discovery
PKG-ANALYZE-05  nella forma artifact non esiste scelta/override della useful root: la root di staging è già quella canonica per l'analisi
PKG-ANALYZE-06  la forma directory tratta il tree fornito come già normalizzato
PKG-ANALYZE-07  executable/launch-like sono euristiche diagnostiche e non command discovery automatica di pkg install
PKG-ANALYZE-08  l'utente seleziona esplicitamente i candidate da considerare/provare
PKG-ANALYZE-09  il dynamic probe richiede un consenso separato dopo un warning non-sandbox
PKG-ANALYZE-10  ogni probe usa directory environment temporanee fresche e redirige HOME/XDG/tmp
PKG-ANALYZE-11  il dynamic probe non introduce né sostituisce il launcher canonico
PKG-ANALYZE-12  il baseline confronta inventari di pathname/type e non promette rilevamento delle modifiche in-place
PKG-ANALYZE-13  pkg_analyze non modifica direttamente package store, selector, binding, state persistente o pkg-catalog
PKG-ANALYZE-14  variazioni del solo wrapper pathname non diventano evidence di un nuovo range
PKG-ANALYZE-15  la spelling pkg_analyze è fissata esplicitamente per questo command e non crea una convenzione generale sui nomi dei command RumiAI
PKG-ANALYZE-16  pkg_analyze_find_deepest_dir/prompt useful-root dell'implementazione corrente sono pending realignment come responsabilità superseded del tool
```
