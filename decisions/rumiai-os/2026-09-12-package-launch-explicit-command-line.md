# Decisione — `launcher` explicit command line e `cmd/` senza `link/`

Date: 2026-09-12  
Status: **Accepted**

## Contesto

Il runtime package corrente ha già fissato:

```text
cmd/<pkg-command>    command entry RumiAI package-local
launcher             preparazione runtime comune del package
link/<pkg-command>   quando presente, puro binding relativo verso un executable nel root/ dello stesso concrete package
root/                 payload upstream
```

Il baseline implementato di `launcher` supporta il caso direct-link:

```text
launcher <pkg> [command-arguments...]
```

che deriva il command corrente da `m_COMMAND_BIN`, risolve:

```text
<concrete>/link/<pkg-command>
```

verifica che il target sia un regular executable confinato in `<concrete>/root/`, applica `HOME` e gli `env`, quindi termina con `exec` del target.

La decisione `2026-09-07-package-command-specific-launch.md` ha però già fissato che una launch line composta può appartenere direttamente a `cmd/<pkg-command>` e che in quel caso non è richiesto un `link/<pkg-command>` artificiale. `2026-09-10-package-launch-library.md` aveva lasciato volutamente fuori dal primo implementation slice la firma concreta per questo secondo caso fino all'emergere di un package reale.

Electron macOS è ora quel caso reale: il command deve usare il meccanismo nativo macOS per aprire il bundle package-local `Electron.app`, quindi non deve rappresentare tale launch tramite un symlink `link/electron` verso il Mach-O interno né tramite wrapper artificiali nel payload.

Questa decisione chiude esclusivamente il contratto necessario per la launch line composta e riallinea l'integrazione `cmd/`/`link/` con la decisione già accettata del 7 settembre.

---

## 1. Nessuna nuova primitive

La responsabilità è già del `launcher`; non vengono introdotte primitive parallele come:

```text
launch
launcher_exec
pkg_run
run_command
```

La primitive canonica resta una sola:

```text
launcher
```

Il nuovo caso è una modalità esplicita della stessa API.

---

## 2. API direct-link invariata

La forma esistente resta esattamente:

```text
launcher <pkg> [command-arguments...]
```

Il primo argomento è il package logico secondo la grammatica canonica.

Il comportamento resta:

```text
m_COMMAND_BIN
  -> concrete package corrente
  -> link/<pkg-command>
  -> regular executable confinato in root/
  -> HOME/env layering
  -> exec target [command-arguments...]
```

Nessuna semantica o compatibilità del direct-link viene modificata.

In particolare un argomento utente `-c` passato dopo `<pkg>` resta un normale argomento dell'upstream; la nuova modalità non crea ambiguità con argv del command perché viene riconosciuta soltanto nella prima posizione dell'API `launcher`.

---

## 3. Nuova forma explicit-command

La nuova forma è:

```text
launcher -c <pkg> <absolute-command> [command-arguments...]
```

`-c` significa che il command entry fornisce esplicitamente l'executable finale della launch line invece di usare `link/<pkg-command>`.

Requisiti:

```text
<pkg>              package name canonico
<absolute-command> pathname assoluto
                    esistente
                    canonicalizzabile
                    regular file
                    executable
```

Il launcher non effettua PATH lookup per `<absolute-command>`.

Il pathname può risolvere fuori dal `root/` del package concreto. Questa è una proprietà necessaria della modalità composta: il command può essere, per esempio, una utility nativa dell'host o in futuro un executable di una dependency già risolta attraverso il modello package/dependency.

La scelta dell'executable appartiene al `cmd/<pkg-command>`; il launcher non cerca né seleziona autonomamente utility host o dependency.

---

## 4. Runtime comune invariato

Anche in modalità `-c`, `launcher` continua obbligatoriamente a:

```text
validare m_COMMAND_BIN
verificare che il command entry appartenga direttamente a $m_PKG_DIR/<concrete>/cmd/
validare il concrete package e il relativo root/
impostare HOME=$m_HOME_DIR/<pkg>
applicare <concrete>/env
applicare $m_CONF_DIR/<pkg>/env
terminare con exec
```

La sola differenza è la provenienza del target finale:

```text
direct-link       target da <concrete>/link/<pkg-command>
explicit-command  target da <absolute-command> fornito dal command entry
```

Non viene duplicata nel command entry la preparazione runtime comune.

---

## 5. Final execution

Dopo environment layering:

```text
direct-link:
  exec <resolved-link-target> [command-arguments...]

explicit-command:
  exec <resolved-absolute-command> [command-arguments...]
```

Il `launcher` continua quindi a essere sostituito dal processo finale che esso avvia.

Se tale processo finale è a sua volta un launcher del sistema operativo, per esempio `/usr/bin/open` su macOS, le proprietà processuali successive dipendono dal contratto di quel tool e non vengono reinterpretate dal generic package launcher.

---

## 6. Error model

Restano le classi correnti:

```text
2  invocazione API invalida
1  failure operativa/runtime rilevata prima dell'exec
```

In modalità `-c` sono API invalid almeno:

```text
-c senza <pkg>
-c senza <absolute-command>
<pkg> invalido
<absolute-command> non assoluto
```

Sono failure operative almeno:

```text
command path assoluto non risolvibile
resolved command non regular
resolved command non executable
runtime/layout/env failure comune
```

Dopo `exec` vale la semantica del processo finale, come nel baseline corrente.

---

## 7. Contratto corrente `cmd/` / `link/`

La product integration deve essere riallineata alla decisione già fissata del 7 settembre.

Regole correnti:

```text
cmd/ assente
  -> nessun command esposto dal concrete package

cmd/ presente
  -> deve contenere almeno un command source valido

link/ assente
  -> ammesso; i command possono usare launch line composta

link/ presente
  -> richiede cmd/
  -> deve contenere almeno un binding
  -> ogni link/<name> richiede cmd/<name>

per ogni cmd/<name>
  -> link/<name> può esistere oppure no
```

Quando `link/<name>` esiste, conserva integralmente il contratto corrente:

```text
file descriptor catalog valido
relative target
confinamento nel root/ dello stesso concrete package
regular target
materializzazione come symlink relativo ../root/<target>
```

Quando `link/<name>` non esiste, `pkg_integrate` materializza soltanto `cmd/<name>` e non crea un binding artificiale.

Una directory `link/` vuota non rappresenta alcun contratto utile e resta invalida.

---

## 8. Materializzazione

`pkg_integrate` deve materializzare separatamente i due insiemi:

```text
range/cmd/*
  -> <concrete>/cmd/*, executable

range/link/*, quando presenti
  -> <concrete>/link/*, symbolic link relativi verso ../root/<target>
```

Non deve più assumere che ogni `cmd/*` possieda necessariamente un descriptor omonimo sotto `link/`.

L'assenza completa di `link/` non deve creare un `<concrete>/link/` vuoto soltanto per uniformità cosmetica.

---

## 9. Electron macOS come primo consumer

Per Electron macOS ARM64:

```text
cmd/electron   launch line command-specific
link/electron  assente
```

Il command entry deriva il pathname del bundle dal concrete package identificato da `m_COMMAND_BIN` e delega la preparazione runtime comune a:

```text
launcher -c electron /usr/bin/open ...
```

La forma esatta delle opzioni `open` è fissata nella decisione:

```text
decisions/rumiai-os/2026-09-12-package-macos-application-launch.md
```

Questa implementazione chiude il primo caso concreto di `PKG-CMD-LAUNCH-06` e `PKG-LAUNCH-13` senza cambiare la semantica Linux di Electron.

---

## 10. Testing richiesto

I permanent test devono proteggere almeno:

```text
launcher direct-link invariato
launcher -c richiede package + absolute command
launcher -c rifiuta command relativo
launcher -c applica lo stesso HOME/env layering
a launcher -c viene preservato argv esattamente
launcher -c termina tramite exec e propaga lo status del processo esplicito
launcher -c non richiede link/<pkg-command>
cmd/ senza link/ è una definition valida
link/ senza cmd/ è invalido
link/ presente può coprire un sottoinsieme di cmd/
ogni link richiede il cmd omonimo
link target esistente conserva confinement/root validation
materializzazione cmd-only non crea link artificiale
```

I test Electron macOS verificano separatamente il contratto specifico di `/usr/bin/open` e del bundle.

---

## 11. Supersession mirata

Questa decisione implementa e rende operativa la regola già fissata da `2026-09-07-package-command-specific-launch.md` secondo cui `link/<pkg-command>` non è obbligatorio per una launch line composta.

Sono quindi superseded, ovunque ancora descritti come comportamento corrente:

```text
obbligo product-level cmd/link uno-a-uno
obbligo di link/ per ogni command source
materializzazione che legge sempre link/<command> per ogni cmd/<command>
```

Resta valido tutto il contratto direct-link per i command che possiedono il binding.

---

## 12. Invarianti fissati

```text
PKG-LAUNCH-15  launcher resta l'unica primitive comune per direct-link ed explicit command line
PKG-LAUNCH-16  API composta = launcher -c <pkg> <absolute-command> [command-arguments...]
PKG-LAUNCH-17  -c è riconosciuto solo come primo argomento dell'API; gli argv dopo <pkg> del direct-link restano opachi
PKG-LAUNCH-18  explicit command richiede pathname assoluto e non usa PATH lookup
PKG-LAUNCH-19  explicit command viene canonicalizzato e deve risolvere a regular executable
PKG-LAUNCH-20  explicit command può risolvere fuori dal package root perché la scelta appartiene alla launch line command-specific
PKG-LAUNCH-21  HOME/env layering e validazione del command entry/concrete/root sono identici nelle due modalità
PKG-LAUNCH-22  entrambe le modalità terminano con exec del target finale scelto
PKG-CMD-LINK-01  cmd/ può esistere senza link/
PKG-CMD-LINK-02  link/ non può esistere senza cmd/
PKG-CMD-LINK-03  ogni link/<name> richiede cmd/<name>, ma ogni cmd/<name> non richiede link/<name>
PKG-CMD-LINK-04  link/ presente deve essere non vuoto e conserva il contratto relativo/confinato al root
PKG-CMD-LINK-05  materializzazione cmd-only non crea wrapper o link artificiali
PKG-CMD-LINK-06  Electron macOS è il primo consumer concreto della launch line composta senza link
```
