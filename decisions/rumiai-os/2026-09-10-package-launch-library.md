# Decisione — Libreria package launch e collocazione di `launcher`

Date: 2026-09-10  
Status: **Accepted**

## Contesto

Il modello package corrente ha già fissato:

```text
cmd/<pkg-command>    command entry RumiAI package-local
launcher             primitive comune del runtime package
link/<pkg-command>   quando presente, binding relativo verso root/ dello stesso package concreto
root/                 payload upstream
```

Le decisioni del 2026-09-06 collocavano `launcher` in `lib/sh/core.lib.sh`, rendendolo disponibile a ogni command perché `core.lib.sh` è caricato dal bootstrap `rumiai-os`.

La correzione esplicita dell'utente del 2026-09-10 stabilisce che questa collocazione non è appropriata: il launch package-specific non è una responsabilità general-purpose del bootstrap/core e deve poter gestire preparazione environment e stato relativi ai package senza allargare il contratto globale del bootstrap.

La stessa correzione proponeva `pkg-run.lib.sh` come possibile sede. Tale nome non viene adottato perché `pkg run` è già un concetto distinto: il normale launch di un package installato non passa dal package manager e un futuro `pkg run` deve delegare allo stesso command entry/launcher senza diventare un secondo engine.

---

## 1. File canonico

La primitive `launcher` appartiene ora a:

```text
lib/sh/pkg-launch.lib.sh
```

Il file è una libreria shell RumiAI:

```text
regular file
non executable
nessuno shebang
POSIX sh
```

`launcher` conserva il proprio nome canonico. Non vengono introdotte primitive alternative `launch`, `pkg_run` o alias equivalenti.

`core.lib.sh` e il bootstrap non caricano automaticamente `pkg-launch.lib.sh`.

---

## 2. Caricamento esplicito dal command entry

Un `cmd/<pkg-command>` che usa `launcher` deve caricare esplicitamente la libreria:

```sh
#!/usr/bin/env rumiai-os

. "$m_LIB_DIR/sh/pkg-launch.lib.sh"

launcher "<pkg>" "$@"
```

Il command entry continua a possedere la minima logica command-specific, inclusi eventuali argomenti fissi e composizione argv.

La libreria package launch non viene inserita nel bootstrap soltanto per evitare una riga di dot command nei command entry che la richiedono.

Per DBeaver la command source corrente diventa esattamente:

```sh
#!/usr/bin/env rumiai-os

. "$m_LIB_DIR/sh/pkg-launch.lib.sh"

launcher "dbeaver" \
  -configuration "$m_CONF_DIR/dbeaver/configuration" \
  -data "$m_HOME_DIR/dbeaver/.workspace" \
  "$@"
```

Questa forma supersede l'omonima source del documento `2026-09-09-dbeaver-package-integration-definition.md` che invocava `launcher` senza caricare esplicitamente la nuova libreria. Argomenti fissi, ordine e state routing DBeaver restano invariati.

---

## 3. API direct-link corrente

Il primo contratto implementato è quello realmente richiesto dal package DBeaver corrente:

```text
launcher <pkg> [command-arguments...]
```

`<pkg>` usa la grammatica canonica del package name.

La primitive usa `m_COMMAND_BIN` come autorità per identificare il command entry corrente e deriva da esso:

```text
<pkg-command>
<package-version>/cmd/
<package-version>/
```

Non ricava il package logico o la versione parsando il basename della concrete identity. `<pkg>` continua a essere ricevuto esplicitamente dal command entry.

Il command entry deve appartenere direttamente a:

```text
$m_PKG_DIR/<concrete>/cmd/<pkg-command>
```

e il target direct-link deve essere:

```text
$m_PKG_DIR/<concrete>/link/<pkg-command>
```

come symbolic link relativo che risolve a un regular executable confinato dentro:

```text
$m_PKG_DIR/<concrete>/root/
```

Non viene eseguita scansione di `root/`, PATH lookup dell'upstream o chiamata runtime a `pkg`.

La firma per command composti senza `link/<pkg-command>` resta da chiudere quando un package concreto la richiederà; non viene anticipata in questa implementazione.

---

## 4. Environment standard corrente

`launcher` costruisce la parte comune dell'environment package runtime.

L'unico mapping standard già fissato in modo completo dal baseline corrente è:

```text
HOME=$m_HOME_DIR/<pkg>
```

quindi la prima implementazione applica ed esporta `HOME` secondo questa regola.

Non vengono inventati ora mapping per XDG, `TMPDIR` o altre variabili ancora non fissate da una decisione concreta.

L'isolamento environment resta logical isolation e non sandboxing.

---

## 5. Layering `env`

Dopo l'environment standard vengono applicati, quando presenti, nell'ordine:

```text
<package-version>/env
$m_CONF_DIR/<pkg>/env
```

secondo `2026-09-06-package-env-shell-source.md`.

Entrambi sono frammenti POSIX shell caricati con il dot command `.` nello stesso processo del launcher.

Il launcher non usa `set -a`: soltanto le variabili esplicitamente esportate secondo la normale semantica shell entrano nell'environment dell'upstream.

Un pathname `env` presente ma non regular/readable, un symlink, oppure un file con sintassi shell non valida impedisce il launch. Il baseline esegue una verifica `sh -n` prima del dot command per evitare di eseguire l'upstream dopo un errore sintattico noto.

---

## 6. Final execution e failure

Dopo validazione, isolamento ed env layering, il direct-link baseline termina con:

```text
exec <resolved-link-target> [command-arguments...]
```

L'upstream sostituisce il processo shell e riceve direttamente exit status e segnali secondo la normale semantica `exec`.

Prima del tentativo finale di `exec`:

```text
2  invocazione API invalida: argomenti mancanti o <pkg> invalido
1  runtime/layout/env/target failure rilevato dal launcher
```

Dopo l'invocazione dello special builtin POSIX `exec` non viene introdotta una normalizzazione artificiale: se il kernel/shell rifiuta l'esecuzione nonostante i controlli preliminari, vale il relativo comportamento shell/system, normalmente espresso da status come 126/127. Il successo non ritorna dalla funzione perché l'`exec` sostituisce il processo.

---

## 7. Separazione da `pkg run`

Il normale path resta:

```text
bin/ext*
 -> current
 -> <concrete>/cmd/<pkg-command>
 -> rumiai-os
 -> dot pkg-launch.lib.sh
 -> launcher
 -> <concrete>/link/<pkg-command>
 -> <concrete>/root/<upstream>
```

Non diventa:

```text
command -> pkg run -> upstream
```

Un futuro `pkg run` resta un'interfaccia esplicita per selezioni/override amministrativi o per-invocation e dovrà raggiungere il command entry appropriato, delegando allo stesso runtime package.

Per questo `pkg-run.lib.sh` non viene usato come nome della libreria del normale launcher.

---

## 8. Supersession mirata

Sono superseded esclusivamente le precedenti affermazioni che fissavano:

```text
launcher in lib/sh/core.lib.sh
launcher caricato implicitamente dal bootstrap per ogni command
core.lib.sh come sede necessaria del runtime package launch
command source DBeaver che invoca launcher senza dot esplicito di pkg-launch.lib.sh
```

Restano validi:

```text
launcher come primitive comune del runtime package
m_COMMAND_BIN come autorità sul command entry corrente
cmd/<pkg-command> come luogo della logica command-specific
link/<pkg-command>, quando presente, confinato a root/ dello stesso concrete package
normale launch indipendente dal comando pkg
HOME=$m_HOME_DIR/<pkg> nel baseline non qualificato
env package seguito da env utente
final exec dell'upstream
pkg run separato dal normale runtime path
```

---

## 9. Implementazione e testing

Il baseline è implementato in:

```text
rumiai-os/lib/sh/pkg-launch.lib.sh
```

Il catalogo DBeaver carica esplicitamente la libreria per tutti gli stream correnti Linux, macOS e Windows x86_64.

I test permanenti appartengono a:

```text
rumiai-tests/tests/rumiai-os/pkg-launch/contract.test
rumiai-tests/tests/rumiai-os/pkg-integration/contract.test
```

e proteggono almeno:

```text
pkg-launch.lib.sh non executable e senza shebang
core/bootstrap non espongono implicitamente launcher
command entry che usa launcher carica esplicitamente pkg-launch.lib.sh
m_COMMAND_BIN come autorità sul command corrente
rifiuto di command entry fuori da $m_PKG_DIR/<concrete>/cmd/
confinamento del direct-link dentro root/
assenza di PATH lookup/scansione upstream
HOME=$m_HOME_DIR/<pkg>
ordine package env -> user env
assenza di set -a implicito
env invalido impedisce upstream execution
preservazione esatta degli argomenti
final exec e propagazione dello status upstream
status 2 per API invalida e 1 per failure operative pre-exec
```

Un development check isolato POSIX `sh` ha validato il direct-link baseline, HOME, env layering, non-export implicito, argv, final `exec`, env syntax failure e root confinement. Tale check non sostituisce la physical validation revision-specific.

La frase del piano 2026-09-09 che indicava il `launcher` come non ancora implementato è quindi superseded. DBeaver installato e avviato end-to-end resta comunque da validare fisicamente sui reference host dopo l'allineamento di prodotto, test e catalogo.

---

## 10. Invarianti fissati

```text
PKG-LAUNCH-01  launcher vive in lib/sh/pkg-launch.lib.sh, non in core.lib.sh/bootstrap
PKG-LAUNCH-02  pkg-launch.lib.sh è regular non-executable, senza shebang, POSIX sh
PKG-LAUNCH-03  i command entry che usano launcher caricano esplicitamente la libreria
PKG-LAUNCH-04  il nome canonico della primitive resta launcher
PKG-LAUNCH-05  pkg-run.lib.sh non identifica il normale runtime package; pkg run resta concetto separato
PKG-LAUNCH-06  API direct-link corrente = launcher <pkg> [command-arguments...]
PKG-LAUNCH-07  m_COMMAND_BIN identifica command e concrete package; il package logico non viene inferito dal concrete basename
PKG-LAUNCH-08  il direct-link deve risolvere a regular executable confinato nel root/ dello stesso concrete package
PKG-LAUNCH-09  il baseline standard isolation implementato ora fissa soltanto HOME=$m_HOME_DIR/<pkg>
PKG-LAUNCH-10  env layering = standard isolation -> package env -> user env -> exec, senza set -a
PKG-LAUNCH-11  normal launch non invoca pkg e non consulta pkg-catalog
PKG-LAUNCH-12  failure pre-exec = 2 API invalida oppure 1 failure operativa; dopo exec valgono direttamente semantica shell/kernel e status upstream
PKG-LAUNCH-13  command composti senza link restano fuori dal primo implementation slice finché richiesti da un package concreto
PKG-LAUNCH-14  la source DBeaver corrente carica esplicitamente pkg-launch.lib.sh e conserva invariati gli argomenti fissi già fissati
```