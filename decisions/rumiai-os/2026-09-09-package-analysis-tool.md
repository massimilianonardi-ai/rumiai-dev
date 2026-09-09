# Decisione — `pkg_analyze` come strumento diagnostico per package definition

Date: 2026-09-09  
Updated: 2026-09-09  
Status: **Accepted**

## Contesto

Il piano corrente di `pkg` richiede come passo successivo il completamento della package definition DBeaver prima di `pkg_integrate`.

Per costruire una package definition reale è utile osservare sistematicamente proprietà che non sono affidabili da inferire dal nome dell'artifact o da una singola release, fra cui:

```text
prefix directory introdotti dall'archivio
root realmente utile del payload
candidate command/executable
pathname creati durante il primo launch
state scritto nella home o nelle directory controllabili tramite environment
variazioni fra release e target differenti
```

Il progetto storico `massimilianonardi/m` conteneva una discovery `find_deepest_dir`; il codice storico resta materiale di riferimento e non viene importato come autorità o copiato automaticamente.

L'utente fissa il nome del nuovo strumento come:

```text
pkg_analyze
```

L'underscore è quindi una spelling deliberatamente stabilita per questo comando diagnostico. Non introduce una nuova convenzione generale per i command RumiAI.

La correzione esplicita del 2026-09-09 fissa inoltre che `pkg_extract` dovrà consegnare direttamente la useful root normalizzata. Di conseguenza `pkg_analyze` resta il tool che **scopre e documenta** la root utile sui payload grezzi, mentre `pkg_extract` diventa il consumer della normalization information consolidata nella package definition.

---

## 1. Ruolo

`pkg_analyze` è uno strumento diagnostico per chi prepara o aggiorna package definition.

Non appartiene alla pipeline automatica di normale `pkg install` e non diventa una fase implicita dell'installazione.

Il suo output è evidence diagnostica human-readable che aiuta a scrivere o correggere la package definition. Non è esso stesso una package definition, un receipt, un lock o una nuova serializzazione normativa.

Il tool non contiene conoscenza di DBeaver o di altri prodotti specifici.

---

## 2. Input iniziali e raw materialization

Le forme implementate inizialmente sono:

```text
pkg_analyze <extracted-directory>
pkg_analyze <format> <artifact>
```

La prima forma analizza un tree già materializzato e non ne assume la proprietà.

La seconda forma, nell'implementazione iniziale, crea uno staging temporaneo e riusa:

```text
pkg_extract <artifact> <format> <staging-dir>
```

Questa dipendenza è ora **pending realignment**.

Il nuovo contratto semantico di `pkg_extract` richiede infatti che esso consumi l'informazione di useful-root normalization già determinata dalla package definition e restituisca un tree normalizzato. `pkg_analyze`, al contrario, deve poter osservare il payload **prima** che tale informazione esista, proprio per scoprirla.

Non deve quindi essere introdotta una dipendenza circolare del tipo:

```text
pkg_analyze
    -> pkg_extract richiede useful-root normalization
        -> useful-root normalization dovrebbe essere scoperta da pkg_analyze
```

La modalità fisica con cui la forma `<format> <artifact>` otterrà in futuro la raw materialization deve essere fissata nel successivo riallineamento senza duplicare arbitrariamente backend o introdurre una nuova primitive non necessaria. La forma `<extracted-directory>` resta semanticamente valida e indipendente da questo punto aperto.

---

## 3. Discovery della useful root

Dopo la raw materialization, il tool costruisce una catena partendo dalla root del tree analizzato.

Finché il livello corrente contiene esattamente una entry e tale entry è una real directory, non symlink, la catena può proseguire dentro quella directory.

Il livello più profondo così ottenuto è soltanto una:

```text
suggested useful root
```

Non è autorità automatica.

Il tool mostra la catena e chiede all'utente di accettare la proposta o indicare una directory relativa differente. La scelta deve risolversi a una directory esistente confinata dentro il tree analizzato.

Questa euristica serve in particolare a rilevare wrapper come:

```text
<release-name>/
<product>/<version>/
app-bundle prefix
altri prefix variabili fra target/release
```

senza assumere che la stessa profondità o lo stesso nome valgano per tutte le release.

---

## 4. Rapporto con `pkg_extract`

Il confine corretto è:

```text
pkg_analyze
    -> osserva payload/raw extraction
    -> identifica useful root e variazioni fra release/target
    -> evidence per la package definition

package definition
    -> conserva la normalization information applicabile

pkg_extract
    -> raw materialization
    -> applica la normalization information
    -> consegna direttamente la useful root normalizzata

pkg_integrate
    -> integra il payload già normalizzato
```

`pkg_integrate` non deve ripetere la discovery dei wrapper upstream.

`pkg_analyze` non decide la serializzazione finale della normalization information e non genera automaticamente un campo normativo del catalogo. Tale serializzazione viene fissata dai casi reali.

---

## 5. Candidate command discovery

Sotto la useful root selezionata il tool elenca file regolari candidati al launch.

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

Il working directory del processo è la useful root selezionata.

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
useful root del package
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
suggested useful root tramite catena single-directory
possibilità di accettare/override della useful root
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
assenza di dipendenza circolare dalla future useful-root normalization di pkg_extract
```

I test di `pkg_analyze` non duplicano i test permanenti dei backend `extract` o del contratto interno di `pkg_extract`.

L'implementazione e i test correnti della forma `<format> <artifact>` riusano ancora il precedente `pkg_extract` a staging grezzo. Tale parte è **pending realignment** prima dell'implementazione del nuovo contratto `pkg_extract`.

---

## 12. Invarianti fissati

```text
PKG-ANALYZE-01  pkg_analyze è uno strumento diagnostico esplicito per costruire/verificare package definition, non una fase automatica di pkg install
PKG-ANALYZE-02  le forme iniziali implementate sono pkg_analyze <extracted-directory> e pkg_analyze <format> <artifact>
PKG-ANALYZE-03  pkg_analyze deve osservare la raw materialization per scoprire la useful root e non può dipendere circolarmente dal futuro pkg_extract già normalizzato
PKG-ANALYZE-04  la useful root suggerita è la directory più profonda della catena di livelli con una sola real-directory entry
PKG-ANALYZE-05  la useful root suggerita richiede accettazione/override dell'utente e deve restare confinata nel tree analizzato
PKG-ANALYZE-06  executable/launch-like sono euristiche diagnostiche e non command discovery automatica di pkg install
PKG-ANALYZE-07  l'utente seleziona esplicitamente i candidate da considerare/provare
PKG-ANALYZE-08  il dynamic probe richiede un consenso separato dopo un warning non-sandbox
PKG-ANALYZE-09  ogni probe usa directory environment temporanee fresche e redirige HOME/XDG/tmp
PKG-ANALYZE-10  il dynamic probe non introduce né sostituisce il launcher canonico
PKG-ANALYZE-11  il baseline confronta inventari di pathname/type e non promette rilevamento delle modifiche in-place
PKG-ANALYZE-12  pkg_analyze non modifica direttamente package store, selector, binding, state persistente o pkg-catalog
PKG-ANALYZE-13  pkg_analyze produce evidence per la normalization information; pkg_extract la consuma e consegna la useful root normalizzata a pkg_integrate
PKG-ANALYZE-14  la spelling pkg_analyze è fissata esplicitamente per questo command e non crea una convenzione generale sui nomi dei command RumiAI
PKG-ANALYZE-15  il riuso corrente di pkg_extract nella forma artifact è pending realignment e non deve sopravvivere come dipendenza circolare al nuovo contratto
```
