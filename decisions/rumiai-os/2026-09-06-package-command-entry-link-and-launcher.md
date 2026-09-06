# Decisione — Package command entry, `link/` e launcher

Date: 2026-09-06  
Status: **Accepted**

## Contesto

La decisione `2026-09-06-package-self-contained-launch-and-default-state.md` ha fissato il principio secondo cui `pkg install` rende ogni package il piu autosufficiente possibile e il normale launch di un package gia installato dipende dal sistema base RumiAI, non dal comando `pkg`.

Sono gia fissati:

- `$m_ROOT/pkg/` come dominio dei package gestiti;
- `current` come selector persistente della versione predefinita;
- `root/` come tree di esecuzione upstream normalizzato da `pkg install`;
- `cmd/<pkg-command>` come interfaccia package-local del command;
- `launcher` come funzione comune del sistema base in `lib/sh/core.lib.sh`;
- `m_COMMAND_BIN` come pathname canonico del command file interpretato;
- `var/` come routing view necessaria per i pathname upstream mutabili/state-bearing;
- l'environment standard costruito dal launcher usando direttamente le root semantiche;
- `<package-version>/env` come configurazione version-specific di compatibilita/interazione;
- `$m_CONF_DIR/<pkg>/env` come personalizzazione/override persistente dell'utente nel baseline state non qualificato;
- il normale state sotto `$m_ROOT/<area>/<pkg>/`;
- la gestione operativa delle State Instance nominate come funzione futura, non appartenente alla prima baseline.

Restavano da fissare il layout fisico completo di `cmd/`, il binding verso l'executable upstream, la firma minima del launcher e la relazione esatta fra command pubblico, `current`, command entry ed executable upstream.

Questa decisione chiude tali punti introducendo `link/` con una responsabilita unica e separata.

Questa unita di lavoro modifica soltanto `rumiai-dev`. Non autorizza modifiche a `rumiai-os` o `rumiai-tests`.

---

## 1. Layout package-local corrente

Per le responsabilita fissate dal baseline corrente, una versione concreta di package usa il seguente layout concettuale:

```text
<package-version>/
├── root/
├── cmd/
├── link/
├── env
├── default/
└── var/
```

La presenza concreta resta proporzionata alle necessita:

- `root/` esiste per il payload/tree upstream della versione;
- `cmd/` e `link/` contengono una entry per ogni command esposto;
- `env` e opzionale;
- `default/` e opzionale;
- sotto `var/` esistono soltanto le state area necessarie al package.

Semantica:

```text
root/     tree di esecuzione upstream, con eventuali symlink di normalizzazione state
cmd/      command entry RumiAI dei command esposti
link/     binding package-local command -> executable upstream
env       environment aggiuntivo version-specific gestito da pkg install
default/  factory/default state opzionale
var/      routing view package-local dello state per pathname upstream mutabili
```

`cmd/`, `link/`, `env`, `default/` e `var/` appartengono al packaging RumiAI e sono esterni al namespace upstream.

Un eventuale pathname `root/cmd`, `root/link`, `root/var` o con altro basename coincidente resta un pathname upstream e non acquisisce semantica package-manager dal proprio nome.

---

## 2. Relazione uno-a-uno fra `cmd/` e `link/`

Per ogni command esposto con nome:

```text
<pkg-command>
```

`pkg install` materializza esattamente entrambe le entry:

```text
<package-version>/cmd/<pkg-command>
<package-version>/link/<pkg-command>
```

I due namespace hanno lo stesso insieme di nomi per i command esposti.

La relazione e uno-a-uno:

```text
cmd/<pkg-command>
    command entry RumiAI

link/<pkg-command>
    binding verso l'executable upstream dello stesso command
```

Il runtime non cerca executable sotto `root/`, non inferisce command da basename upstream e non usa un pathname upstream fornito dall'utente come sostituto di `<pkg-command>`.

La conoscenza del mapping:

```text
<pkg-command> -> <upstream-executable>
```

viene materializzata da `pkg install` attraverso `link/<pkg-command>`.

---

## 3. `link/` e il suo ruolo

`link/` e un namespace package-local RumiAI con una sola responsabilita:

> collegare il nome RumiAI del command esposto all'executable upstream reale della stessa versione concreta.

Ogni:

```text
<package-version>/link/<pkg-command>
```

E un **symbolic link relativo** verso l'executable corrispondente sotto:

```text
<package-version>/root/
```

Esempio:

```text
<package-version>/
├── root/
│   ├── bin/
│   │   └── java
│   └── tools/
│       └── javadoc
└── link/
    ├── java    -> ../root/bin/java
    └── javadoc -> ../root/tools/javadoc
```

Il target testuale deve essere relativo per preservare relocatability.

Il target puo attraversare ulteriori symbolic link appartenenti al tree `root/`, ma l'executable esposto appartiene alla stessa versione concreta del package e al suo tree di esecuzione.

`link/`:

- non e pubblico;
- non viene aggiunto al `PATH`;
- non seleziona la versione;
- non costruisce environment;
- non contiene state;
- non sostituisce `var/`;
- non contiene la configurazione `env`;
- non codifica State Instance;
- non e un secondo `cmd/`;
- non viene scandito per discovery: il pathname e costruito esattamente dal nome del command corrente.

Nel baseline corrente `link/<pkg-command>` e un symlink, non un wrapper e non un file di configurazione.

Argomenti fissi, working directory speciali o altre future adattazioni di launch non devono essere codificati implicitamente nel ruolo di `link/`; se emergeranno requisiti concreti saranno specificati separatamente senza cambiare la semantica di `link/`.

---

## 4. `cmd/<pkg-command>` e il suo ruolo

Ogni:

```text
<package-version>/cmd/<pkg-command>
```

E il command entry package-local RumiAI del command esposto.

Nel baseline corrente e un **regular executable command file** con il command entrypoint canonico:

```text
#!/usr/bin/env rumiai-os
```

Il file non contiene il mapping all'executable upstream: tale mapping appartiene esclusivamente a `link/<pkg-command>`.

Il command file contiene soltanto la delega al launcher comune e l'identita del package materializzata da `pkg install`.

Forma canonica:

```sh
#!/usr/bin/env rumiai-os
launcher "<pkg>" "$@"
```

`<pkg>` viene sostituito da `pkg install` con il nome canonico reale del package.

Il nome del command non viene duplicato nel contenuto del file: il launcher lo deriva dal basename canonico di `m_COMMAND_BIN`.

Questa scelta evita di dipendere dalla grammatica fisica futura del pathname `<package-version>` per ricavare l'identita package.

---

## 5. Firma minima di `launcher`

La firma pubblica necessaria ai command entry package-local e:

```text
launcher <pkg> [command-arguments...]
```

Il primo argomento e l'identita canonica del package.

Gli argomenti successivi sono esattamente gli argomenti ricevuti dal command pubblico e devono essere inoltrati all'executable upstream senza reinterpretazione da parte del command entry.

`launcher` usa:

```text
m_COMMAND_BIN
```

come sorgente autorevole del pathname canonico del command file corrente.

Da `m_COMMAND_BIN` deriva:

```text
<pkg-command>      basename di m_COMMAND_BIN
<cmd-dir>          directory contenente m_COMMAND_BIN
<package-version>  parent di <cmd-dir>
```

La struttura attesa e quindi:

```text
<package-version>/cmd/<pkg-command>
```

Il launcher non ricava `<pkg>` dal nome fisico della directory `<package-version>`: usa l'identita passata dal command entry.

Questo mantiene aperta e indipendente la futura grammatica dei pathname delle versioni concrete sotto `$m_ROOT/pkg/`.

---

## 6. Target esatto del launcher

Dopo aver determinato `<package-version>` e `<pkg-command>`, il launcher costruisce esattamente:

```text
<package-version>/link/<pkg-command>
```

come target di esecuzione.

Non sono previsti nel normale launch:

- scansione di `root/`;
- ricerca ricorsiva di executable;
- PATH lookup per trovare l'executable upstream del package;
- metadata lookup runtime per ricostruire il mapping command -> executable;
- chiamata a `pkg` per risolvere l'executable.

Il mapping e gia stato materializzato da `pkg install` in `link/`.

Dopo la preparazione dell'environment il launcher sostituisce il processo di launch con l'executable raggiunto da `link/<pkg-command>` e inoltra gli argomenti originali.

Semantica finale:

```text
exec <package-version>/link/<pkg-command> [command-arguments...]
```

L'uso di `exec` e parte del contratto: il launcher non deve restare come processo padre artificiale dopo il launch normale.

Gli exit status e i signal del programma devono quindi propagarsi secondo la normale semantica del processo eseguito, salvo errori precedenti del launcher.

La classificazione e i codici esatti degli errori propri del launcher saranno fissati insieme all'implementazione e ai relativi test permanenti.

---

## 7. Environment costruito dal launcher

Prima dell'`exec`, `launcher` applica il layering gia fissato dalla decisione `2026-09-06-package-self-contained-launch-and-default-state.md`:

```text
environment host ereditato/sanitizzato secondo il launch contract
        ↓
environment standard di isolamento costruito da launcher
        ↓
<package-version>/env
        ↓
$m_CONF_DIR/<pkg>/env
        ↓
eventuali override espliciti gia forniti dal caller
        ↓
exec link/<pkg-command>
```

Nel baseline corrente lo state e soltanto quello non qualificato:

```text
$m_ROOT/<area>/<pkg>/
```

Le variabili di isolamento usano direttamente le root semantiche garantite dal bootstrap, non `var/<area>`.

Esempio gia fissato:

```text
HOME=$m_HOME_DIR/<pkg>
```

`var/` continua parallelamente a servire il routing dei pathname upstream mutabili e non viene usato dal launcher come sorgente dell'identita dello state.

I file `env` restano dichiarativi e non diventano shell code o file da `source`.

La grammatica fisica completa dei file `env` e l'elenco finale delle variabili standard di isolamento restano decisioni separate; questa decisione non li ridefinisce.

---

## 8. Catena completa del normale launch

Per un command gestito da `pkg`, la catena canonica e:

```text
bin/ext*/<pkg-command>
    -> <package-current-selector>/cmd/<pkg-command>
        -> rumiai-os
            -> core.lib.sh:launcher
                -> <package-version>/link/<pkg-command>
                    -> <package-version>/root/<upstream-executable>
```

Il binding sotto `bin/ext*` e un symbolic link relativo.

Il selector `current` resta un symbolic link relativo e seleziona soltanto la versione persistente predefinita.

Il command entry sotto `cmd/` costruisce il launch tramite il sistema base.

Il binding sotto `link/` seleziona soltanto l'executable upstream corrispondente.

`root/` contiene il tree upstream e puo includere i symlink di normalizzazione state gia fissati:

```text
root/<path>
    -> var/<area>/<path>
        -> $m_ROOT/<area>/<pkg>/<path>
```

Le due forme di routing sono quindi indipendenti e complementari:

```text
command routing:
bin/ext* -> current -> cmd -> launcher -> link -> root executable

state routing upstream:
root mutable path -> var -> semantic state root
```

---

## 9. Nessun direct bypass per i package gestiti

La precedente distinzione fra:

```text
direct binding che raggiunge direttamente l'upstream executable
wrapper che passa da pkg run
```

non appartiene piu al baseline corrente dei package gestiti.

Per un command esposto da un package gestito, il normale binding pubblico termina sempre su:

```text
cmd/<pkg-command>
```

e quindi usa il launcher comune.

Non sono binding pubblici normali ammessi:

```text
bin/ext*/<pkg-command> -> link/<pkg-command>
bin/ext*/<pkg-command> -> root/<upstream-executable>
```

Questo rende uniforme l'applicazione dell'environment standard e degli eventuali `env` senza reintrodurre `pkg run` nel percorso normale.

La presenza o assenza di state, `env` o pathname normalizzati non cambia il command path pubblico del package gestito.

---

## 10. `pkg run`

`pkg run` resta fuori dal normale command path.

Quando verra usato per una funzione esplicita supportata, deve:

1. scegliere la versione/command richiesti senza modificare `current` salvo operazione esplicita separata;
2. raggiungere il corrispondente `cmd/<pkg-command>`;
3. delegare allo stesso command entry e allo stesso `launcher` del percorso normale.

`pkg run` non deve:

- eseguire direttamente `link/<pkg-command>`;
- eseguire direttamente un pathname sotto `root/`;
- duplicare il layering dell'environment;
- creare un secondo motore di launch.

La sintassi concreta di `pkg run` resta separata.

---

## 11. Responsabilita di `pkg install`

Per ogni command esposto, `pkg install` e responsabile di materializzare coerentemente:

```text
cmd/<pkg-command>
link/<pkg-command>
binding pubblico sotto bin/ext* quando previsto
```

Inoltre resta responsabile delle responsabilita gia fissate:

```text
installazione della versione concreta
normalizzazione dei pathname upstream mutabili
costruzione dei routing root/ -> var/
installazione di <package-version>/env
inizializzazione dello state di default quando necessaria
materializzazione install-time delle interazioni/dependency che possono essere risolte senza lavoro runtime del package manager
```

Una versione non deve essere considerata correttamente materializzata per un command esposto se manca una delle due entry corrispondenti:

```text
cmd/<pkg-command>
link/<pkg-command>
```

La validazione esatta e gli errori di installazione verranno fissati insieme al contratto operativo di `pkg install`.

---

## 12. Separazione delle responsabilita

Il modello corrente fissa questa separazione:

```text
bin/ext*   esposizione pubblica del command third-party
current    selezione persistente della versione
cmd/       command entry RumiAI e ingresso nel launcher comune
launcher   preparazione runtime comune e exec
link/      mapping package-local command -> executable upstream
root/      tree di esecuzione upstream
var/       routing package-local dello state raggiunto tramite pathname upstream
env        configurazione environment version-specific
conf/.../env  personalizzazione environment persistente dell'utente
pkg        installazione, gestione e selezioni esplicite; non engine del normale launch
```

Nessuna delle responsabilita sopra deve essere duplicata in un altro layer senza una nuova decisione esplicita.

---

## 13. Supersession

Questa decisione completa e prevale sulle parti incompatibili delle decisioni precedenti.

### `2026-09-05-package-root-cmd-and-direct-binding.md`

La decisione e superseded per il modello corrente di command exposure e launch.

In particolare sono sostituiti:

- `cmd/<pkg-command>` come symlink all'upstream executable;
- il direct binding che da `cmd/` termina direttamente su `root/`;
- la distinzione direct binding vs wrapper verso `pkg run`;
- la catena `bin/ext* -> current -> cmd -> root executable`.

Restano riaffermati qui i principi ancora validi: separazione da `root/`, mapping esplicito dei command, nessuna scansione di `root/`, binding pubblico attraverso `current`, `package != command`.

### `2026-09-05-package-manager-current-and-run-model.md`

Sono superseded, per i package gestiti, le parti che descrivono:

- wrapper pubblico verso `pkg run` come forma normale di launch mediato;
- direct upstream binding come normale alternativa quando non serve mediazione;
- `pkg run` come engine che costruisce il normale launch.

Restano validi `pkg`, `pkg install`, dominio `$m_ROOT/pkg/`, coesistenza versioni, `current`, distinzione package/command e le altre parti non incompatibili gia riaffermate dalle decisioni successive.

### `2026-09-06-package-self-contained-launch-and-default-state.md`

Questa decisione chiude i punti che quel documento lasciava aperti riguardo a:

- introduzione e ruolo di `link/`;
- contenuto canonico di `cmd/<pkg-command>`;
- firma minima di `launcher`;
- modo con cui il launcher determina l'executable upstream;
- forma completa della catena di launch.

Restano integralmente valide le decisioni di quel documento su autosufficienza, root semantiche, environment diretto, `var/`, state di default e State Instance future.

---

## 14. Implementazione e test

Alla data di questa decisione `rumiai-os` non implementa ancora il package layout/launcher qui fissato e `rumiai-tests` non contiene test permanenti `pkg`.

Questa decisione non autorizza modifiche al prodotto.

Quando il modello verra implementato, i test permanenti dovranno proteggere almeno:

```text
cmd/<command> regular executable command file
shebang #!/usr/bin/env rumiai-os
forma launcher "<pkg>" "$@"
relazione uno-a-uno cmd/<command> <-> link/<command>
link/<command> come symlink relativo verso root/
binding bin/ext* relativo attraverso current verso cmd/
uso di m_COMMAND_BIN per derivare command e package-version
assenza di lookup runtime in root/
assenza di pkg dal normale launch path
layering environment prima dell'exec
exec finale attraverso link/<command>
root/<path> -> var/<area>/<path> invariato per state upstream
relocatability dell'intera catena
```

I test su State Instance alternative restano rinviati alla futura funzione corrispondente.

---

## 15. Invarianti fissati

```text
PKG-LAYOUT-CMD-01  ogni versione concreta separa root/, cmd/, link/, env, default/ e var/ secondo le rispettive responsabilita
PKG-LINK-01        per ogni command esposto esiste link/<pkg-command>
PKG-LINK-02        link/<pkg-command> e un symbolic link relativo verso l'executable upstream della stessa versione sotto root/
PKG-LINK-03        link/ non e pubblico, non e nel PATH e non costruisce environment o state
PKG-LINK-04        link/ codifica esclusivamente il mapping <pkg-command> -> upstream executable
PKG-LINK-05        link/ non codifica fixed argv, cwd, env o State Instance
PKG-CMD-ENTRY-01   per ogni command esposto esiste cmd/<pkg-command>
PKG-CMD-ENTRY-02   cmd/<pkg-command> e un regular executable command file con shebang #!/usr/bin/env rumiai-os
PKG-CMD-ENTRY-03   la forma canonica del body e launcher "<pkg>" "$@"
PKG-CMD-ENTRY-04   pkg install materializza nel command entry l'identita canonica <pkg>
PKG-CMD-ENTRY-05   il nome command non e duplicato nel body; launcher lo deriva da m_COMMAND_BIN
PKG-LAUNCHER-01    la firma minima e launcher <pkg> [command-arguments...]
PKG-LAUNCHER-02    launcher usa m_COMMAND_BIN per derivare <package-version> e <pkg-command>
PKG-LAUNCHER-03    launcher non deriva <pkg> dalla grammatica del pathname <package-version>
PKG-LAUNCHER-04    launcher costruisce esattamente <package-version>/link/<pkg-command> come target upstream
PKG-LAUNCHER-05    launcher non scansiona root/, non usa PATH per trovare l'upstream executable e non interroga pkg per il mapping command
PKG-LAUNCHER-06    launcher applica il layering environment fissato e poi usa exec sul target link/<pkg-command>
PKG-BINDING-01     il normale binding pubblico di un package gestito e un symlink relativo bin/ext*/<command> -> current -> cmd/<command>
PKG-BINDING-02     un binding pubblico normale non bypassa cmd/ verso link/ o root/
PKG-BINDING-03     tutti i command pubblici dei package gestiti usano il launcher comune nel baseline corrente
PKG-CMD-LINK-01    cmd/ e link/ espongono lo stesso insieme di <pkg-command> con relazione uno-a-uno
PKG-INSTALL-CMD-01 pkg install materializza cmd/, link/ e il binding pubblico coerentemente per ogni command esposto
PKG-RUNTIME-01     pkg non appartiene al normale launch path di un package gia installato
PKG-RUNTIME-02     pkg run, quando usato, delega allo stesso cmd/<command>/launcher e non esegue direttamente link/ o root/
PKG-STATE-ROUTING-01 il nuovo command routing non modifica root/<path> -> var/<area>/<path> -> state per pathname upstream mutabili
```
