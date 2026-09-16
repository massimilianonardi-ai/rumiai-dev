# Decisione — `pkg-analyze` dynamic probe GUI

Date: 2026-09-16  
Status: **Accepted — explicit user correction**

## 1. Correzione esplicita

`pkg-analyze` non è soltanto un candidate-discovery tool.

Quando viene selezionato un candidato GUI per il dynamic probe:

```text
pkg-analyze DEVE eseguire realmente il candidato
la finestra DEVE essere osservabile dall'operatore
il probe DEVE poter osservare gli effetti filesystem/runtime prodotti dall'applicazione
```

La precedente interpretazione introdotta il 2026-09-16 secondo cui, nelle package release validation GUI, `pkg-analyze` avrebbe dovuto fare soltanto discovery è errata ed è superseded.

## 2. Modello di riferimento

La validazione fisica DBeaver è il riferimento operativo per il requisito di visibilità: una prova GUI non è valida se l'infrastruttura di test rende la sessione grafica irraggiungibile mentre contemporaneamente richiede all'operatore di confermare una finestra.

Questo non introduce una modalità, un comando o un namespace DBeaver-specific dentro `pkg-analyze`.

## 3. Session runtime

Il dynamic probe continua a isolare le aree di stato che possono essere sostituite senza interrompere la sessione grafica:

```text
HOME
XDG_CONFIG_HOME
XDG_DATA_HOME
XDG_CACHE_HOME
XDG_STATE_HOME
TMPDIR
TMP
TEMP
```

`XDG_RUNTIME_DIR` ha una responsabilità differente: identifica il runtime della sessione utente corrente e, su Wayland, contiene il socket referenziato da `WAYLAND_DISPLAY`.

Sostituirlo con una directory vuota rende il probe incapace di collegarsi alla sessione Wayland pur lasciando impostato `WAYLAND_DISPLAY`.

Per questo `pkg-analyze`:

```text
non sostituisce XDG_RUNTIME_DIR durante il dynamic probe
eredita l'XDG_RUNTIME_DIR della sessione chiamante
se il path è disponibile come directory reale, ne acquisisce snapshot prima/dopo
riporta separatamente il relativo path delta
```

La preservazione della sessione non implica che `XDG_RUNTIME_DIR` venga ignorato: i cambiamenti di pathname osservabili in quel runtime vengono riportati separatamente.

## 4. Nessuna nuova modalità `--gui`

Non viene introdotto un flag `--gui`, una environment variable di controllo o una seconda primitive di probe.

Il comportamento corrente del dynamic probe resta unico. I candidati CLI conservano il normale comportamento esistente; i candidati GUI possono usare la sessione grafica reale perché il runtime sessione non viene più spezzato dall'isolamento.

## 5. Package release validation GUI

Per una package release validation configurata come GUI:

```text
pkg-analyze candidate discovery      obbligatoria
pkg-analyze dynamic probe            obbligatorio
GUI realmente visibile nel probe     obbligatoria e confermata dall'operatore
filesystem/runtime delta             obbligatorio
```

La package release validation non deve sostituire il dynamic probe GUI con una semplice discovery.

Un eventuale launch successivo attraverso il command RumiAI integrato verifica una proprietà distinta — l'integrazione runtime finale — e non autorizza a saltare il probe `pkg-analyze`.

## 6. Testing permanente

Il test permanente `tests/rumiai-os/pkg-analyze/workflow.test` deve proteggere almeno:

```text
HOME/XDG config/data/cache/state/TMP continuano a essere rediretti
XDG_RUNTIME_DIR viene preservato dal chiamante
una modifica nel runtime dir preservato viene osservata nel report
package-root delta continua a essere osservato
original HOME non viene usato al posto dell'HOME isolato
```

La visibilità reale di una finestra non viene simulata nel test deterministico: resta una proprietà di physical validation su una sessione grafica reale.

## 7. Physical validation

La modifica richiede una prova fisica GUI su host applicabile.

Su Linux Wayland la prova deve verificare specificamente che:

```text
WAYLAND_DISPLAY resta utilizzabile durante il probe
la finestra del candidato selezionato appare realmente
l'operatore può chiuderla normalmente
pkg-analyze prosegue e stampa i delta dopo la chiusura
```

La physical validation non è ancora registrata da questa decisione; deve riferirsi alle revisioni esatte effettivamente esercitate.

## 8. Invarianti

```text
PKG-ANALYZE-GUI-01  un candidato GUI selezionato viene realmente eseguito
PKG-ANALYZE-GUI-02  la finestra deve essere osservabile dall'operatore
PKG-ANALYZE-GUI-03  HOME/XDG persistent state/TMP restano isolati
PKG-ANALYZE-GUI-04  XDG_RUNTIME_DIR della sessione viene preservato
PKG-ANALYZE-GUI-05  i delta di XDG_RUNTIME_DIR vengono osservati separatamente quando disponibili
PKG-ANALYZE-GUI-06  nessuna modalità --gui o seconda primitive viene introdotta
PKG-ANALYZE-GUI-07  package-release GUI usa il dynamic probe, non discovery-only
PKG-ANALYZE-GUI-08  il comportamento CLI esistente non viene riaperto
```
