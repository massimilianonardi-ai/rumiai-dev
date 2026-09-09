# Decisione — DBeaver: package integration definition e serializzazione minima del range

Date: 2026-09-09  
Status: **Accepted**

## Contesto

La sequenza corrente di sviluppo di `pkg` ha completato download, raw extraction, structural useful-root normalization e riallineamento di `pkg-analyze`; il passo successivo richiede una prima package definition reale sufficientemente completa da guidare `pkg_integrate`.

Il primo package concreto resta DBeaver Community. Il catalogo corrente possiede già gli stream target-specific e il contratto artifact/integrity a partire dall'anchor:

```text
n0001=26.1.5
```

Le release upstream 26.1.5 e 26.2.0 mantengono il modello di distribuzione corrente. Il README upstream delle distribuzioni archive indica l'avvio tramite executable `dbeaver` e descrive `-data <path>` come area in cui vengono conservati progetti/configurazione. DBeaver/Eclipse distingue inoltre la configuration area selezionata da `-configuration` dalla instance/workspace area selezionata da `-data`.

L'utente ha fornito inoltre evidence d'uso reale: la configuration area contiene essenzialmente state di configurazione Eclipse/Equinox, mentre la data/workspace area contiene state misto, inclusi driver aggiuntivi, connessioni configurate e configurazioni applicative.

La classificazione RumiAI già fissata è:

```text
conf  configurazione persistente

data  dati autorevoli classificabili come tali

home  compatibility bucket conservativo per software il cui state non può essere classificato meglio
```

La scelta esplicita dell'utente del 2026-09-09 fissa per DBeaver:

```text
-configuration -> $m_CONF_DIR/dbeaver/configuration
-data          -> $m_HOME_DIR/dbeaver/.workspace
```

Il pathname component `.workspace` è una scelta esplicita fornita dall'utente per questo package. Non introduce una convenzione generale per i nomi RumiAI-controlled e non modifica `FILESYSTEM-NAMING.md`.

Questa unità fissa inoltre la serializzazione minima della range definition necessaria a rappresentare il primo caso reale senza introdurre un nuovo mini-linguaggio di launch.

Questa decisione modifica soltanto `rumiai-dev`. La successiva applicazione al repository `pkg-catalog` è una modifica separata della stessa fase. Non autorizza modifiche a `rumiai-os` o `rumiai-tests`.

---

## 1. Package e command

Il package canonico resta:

```text
dbeaver
```

Il command pubblico/package-local iniziale è esattamente:

```text
dbeaver
```

DBeaver usa un executable diretto del proprio `root/`, quindi il command impiega il normale binding package-local:

```text
link/dbeaver
```

Non viene introdotta una launch line cross-package o una dependency Java: le distribuzioni DBeaver correnti selezionate dal catalogo includono il runtime necessario e non richiedono una dependency RumiAI Java artificiale.

---

## 2. State routing DBeaver

Il launch normale DBeaver deve aggiungere prima degli argomenti utente:

```text
-configuration "$m_CONF_DIR/dbeaver/configuration"
-data          "$m_HOME_DIR/dbeaver/.workspace"
```

Semantica:

```text
$m_CONF_DIR/dbeaver/configuration
    configuration area DBeaver/Eclipse persistente

$m_HOME_DIR/dbeaver/.workspace
    workspace/instance area DBeaver con state misto non opportunamente separabile nelle altre aree RumiAI
```

`-data` non viene mappato a `m_DATA_DIR` soltanto perché l'upstream usa il termine `data`: la state area RumiAI `data` conserva il proprio significato semantico e non è un contenitore generico.

Il file opzionale di override environment dell'utente resta indipendente:

```text
$m_CONF_DIR/dbeaver/env
```

quindi la configuration area DBeaver vive nel sottopercorso `configuration/` e non collide con il contratto package `env`.

---

## 3. Nessun `var/` mapping DBeaver nel range corrente

Per il range corrente non viene dichiarato alcun mapping:

```text
root/<path> -> var/<area>/<path>
```

Lo state DBeaver rilevante per questa prima integrazione viene indirizzato attraverso la launch line (`-configuration`, `-data`) e attraverso il normale environment di isolamento del futuro `launcher`.

Non è stata identificata la necessità di sostituire pathname mutabili interni al tree installato DBeaver con symlink verso `var/`.

Se una futura analisi fisica individuerà un pathname state-bearing dentro `root/` non controllabile tramite launch/environment, verrà aggiunto un mapping esplicito in un nuovo range soltanto quando la differenza semantica lo richiede.

---

## 4. Nessun `env` o `default/` package-specific richiesto

Il range DBeaver corrente non richiede:

```text
<package-version>/env
<package-version>/default/
```

per la prima integrazione.

Il normale isolamento environment appartiene al `launcher` e non deve essere duplicato in un `env` DBeaver soltanto per spostare HOME/XDG/tmp.

La configurazione iniziale viene creata dall'applicazione nelle aree state selezionate; non viene introdotto un factory state artificiale in `default/` senza un requisito concreto.

---

## 5. Serializzazione `format`

La range definition acquisisce il file scalare:

```text
format
```

Il valore è esattamente il token `format` già accettato da:

```text
pkg_extract <artifact> <format> <staging-dir>
```

Non viene introdotto un secondo vocabolario di formati.

Per DBeaver:

```text
linux-*   format = tar.gz
macos-*   format = dmg
windows-* format = zip
```

`format` segue il normale contratto dei file scalari del range:

```text
regular file
non executable
un valore non vuoto
una sola riga terminata da LF
nessuna interpretazione shell
```

---

## 6. Serializzazione `link/<pkg-command>` nel catalogo

Dentro una range definition, quando un command usa un executable diretto del proprio `root/`, il catalogo può contenere:

```text
link/<pkg-command>
```

Nel **catalogo** questa entry è un regular scalar file, non un symbolic link. Il suo contenuto è il pathname root-relative dell'executable upstream da esporre.

Esempio Linux DBeaver:

```text
link/dbeaver
```

contenuto:

```text
dbeaver
```

`pkg_integrate` dovrà materializzare nella versione concreta il vero symbolic link relativo:

```text
<package-version>/link/<pkg-command>
    -> <package-version>/root/<root-relative-target>
```

Il pathname serializzato:

- è relativo a `root/`;
- non è vuoto;
- non è assoluto;
- non contiene componenti `.` o `..`;
- viene trattato come pathname upstream, non come command da cercare nel `PATH`.

Questa rappresentazione evita symlink intenzionalmente dangling dentro la working copy del catalogo e conserva il significato già fissato di `link/` nel package materializzato.

---

## 7. Serializzazione `cmd/<pkg-command>` nel catalogo

La range definition può contenere:

```text
cmd/<pkg-command>
```

come **sorgente UTF-8 esatta del command entry package-local da materializzare**.

Nel catalogo il file resta regular/non-executable data. `pkg_integrate` dovrà materializzarlo come regular executable command file nella versione concreta.

Il contenuto non è un template e non viene sottoposto a sostituzioni testuali, `eval` o un nuovo parser RumiAI. È già il command source relocatable finale e può usare direttamente le semantic root/environment variables fornite dal runtime RumiAI.

Per DBeaver il source corrente è:

```sh
#!/usr/bin/env rumiai-os

launcher "dbeaver" \
  -configuration "$m_CONF_DIR/dbeaver/configuration" \
  -data "$m_HOME_DIR/dbeaver/.workspace" \
  "$@"
```

Questo riusa il command entry canonico e la primitive `launcher` già fissati. Non viene introdotta una seconda primitive di launch.

---

## 8. Forma `launcher` per command con `link/`

Per il caso già esistente di un command che usa:

```text
link/<pkg-command>
```

resta valida e viene riaffermata la firma:

```text
launcher <pkg> [command-arguments...]
```

La correzione command-specific del 2026-09-07 significa che `cmd/<pkg-command>` può costruire la sequenza di argomenti consegnata al launcher, includendo argomenti fissi prima di `"$@"`.

Il launcher continua a:

```text
identificare package-version e pkg-command da m_COMMAND_BIN
costruire il normale environment
risolvere <package-version>/link/<pkg-command>
exec del target con gli argomenti ricevuti
```

Questa decisione chiude soltanto il caso **direct-link** necessario a DBeaver. La firma/forma finale del caso composto senza `link/<pkg-command>` resta aperta secondo `2026-09-07-package-command-specific-launch.md`.

---

## 9. Target DBeaver correnti

Per i target POSIX-native correnti la definizione è:

```text
linux-x86_64
    format         tar.gz
    link/dbeaver   dbeaver

linux-arm64
    format         tar.gz
    link/dbeaver   dbeaver

macos-x86_64
    format         dmg
    link/dbeaver   DBeaver.app/Contents/MacOS/dbeaver

macos-arm64
    format         dmg
    link/dbeaver   DBeaver.app/Contents/MacOS/dbeaver
```

Tutti e quattro usano lo stesso `cmd/dbeaver` definito sopra.

Il pathname macOS dell'executable è coerente con la documentazione upstream corrente, che espone l'avvio diretto tramite:

```text
DBeaver.app/Contents/MacOS/dbeaver
```

Il target Windows x86_64 conserva per ora la sola parte artifact/materialization già verificata:

```text
format = zip
```

La materializzazione `cmd/link` Windows non viene ancora dichiarata perché RumiAI esegue in ambiente POSIX-compatible mentre DBeaver è un executable Windows nativo; la conversione/compatibilità dei pathname passati a `-configuration` e `-data` deve essere verificata prima di promuovere una launch definition Windows. Non viene introdotto preventivamente un adapter o `cygpath` package-specific senza evidence.

L'assenza temporanea di `cmd/link` nel solo stream Windows non modifica il contratto degli stream Linux/macOS e non dichiara supporto end-to-end Windows prima della relativa verifica.

---

## 10. Range e compatibilità 26.1.5 -> 26.2.0

Il primo anchor resta:

```text
n0001=26.1.5
```

Non viene aggiunto un range `26.2.0`: artifact naming, formato, executable/launch model e state routing rilevanti restano compatibili con il range corrente.

La variazione del wrapper dell'artifact, quando presente, continua a essere assorbita da `pkg_extract` e non entra nella package definition.

---

## 11. Testing e physical validation

Questa unità è principalmente una decisione/catalog definition e non costituisce physical validation del launch DBeaver.

Non esistono ancora test permanenti di `pkg_integrate` perché il layer non è implementato. La successiva implementazione dovrà verificare almeno:

```text
lettura di format
materializzazione cmd/ come executable command entry
materializzazione link/ come symlink relativo confinato in root/
assenza di template/eval del cmd source
DBeaver Linux fixture con link target dbeaver
preservazione degli argomenti fissi prima degli argomenti utente
assenza di var/env/default quando non dichiarati
```

La physical validation DBeaver sui reference host resta successiva all'implementazione dei layer necessari e deve essere revision-specific.

---

## 12. Invarianti fissati

```text
PKG-DBEAVER-01  il package canonico è dbeaver e il command iniziale è dbeaver
PKG-DBEAVER-02  -configuration punta a $m_CONF_DIR/dbeaver/configuration
PKG-DBEAVER-03  -data punta a $m_HOME_DIR/dbeaver/.workspace
PKG-DBEAVER-04  il nome upstream data non riclassifica lo state nella semantic root RumiAI data
PKG-DBEAVER-05  il range corrente non richiede root->var state mapping
PKG-DBEAVER-06  il range corrente non richiede package env o default/
PKG-DBEAVER-07  range/format usa direttamente i token già accettati da pkg_extract
PKG-DBEAVER-08  nel catalogo link/<pkg-command> è un scalar root-relative target; nel package installato diventa un symlink relativo verso root/
PKG-DBEAVER-09  nel catalogo cmd/<pkg-command> è il source UTF-8 esatto del command entry finale e non un template o mini-linguaggio
PKG-DBEAVER-10  il direct-link command può chiamare launcher <pkg> con argomenti fissi prepended a "$@"
PKG-DBEAVER-11  Linux usa link target dbeaver
PKG-DBEAVER-12  macOS usa link target DBeaver.app/Contents/MacOS/dbeaver
PKG-DBEAVER-13  Linux usa format tar.gz e macOS usa format dmg
PKG-DBEAVER-14  Windows x86_64 usa format zip ma cmd/link restano non dichiarati finché il pathname bridge POSIX/native non è verificato
PKG-DBEAVER-15  l'anchor resta n0001=26.1.5 e 26.2.0 non richiede un nuovo range per il contratto corrente
PKG-DBEAVER-16  .workspace è una scelta pathname esplicita dell'utente per DBeaver e non stabilisce una convenzione generale RumiAI
```
