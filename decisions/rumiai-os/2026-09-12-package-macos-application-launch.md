# Decisione — Launch nativo dei macOS application bundle nei package RumiAI

Date: 2026-09-12  
Status: **Accepted**

## Contesto

Il runtime package corrente distingue:

```text
cmd/<pkg-command>    command entry RumiAI package-local
launcher             primitive comune del runtime package
link/<pkg-command>   quando presente, binding relativo verso root/ dello stesso package concreto
root/                 payload upstream
```

Il baseline direct-link di `launcher` termina con `exec` di un regular executable confinato in `root/`.

Electron macOS rende concreto un caso diverso: l'artefatto upstream è `Electron.app`, il cui main executable vive sotto `Contents/MacOS/`, ma il bundle è l'unità applicativa nativa riconosciuta da macOS. L'utente ha chiesto di preferire, quando corretto, il meccanismo applicativo nativo di macOS invece dell'esecuzione diretta del Mach-O interno.

La documentazione Apple su Launch Services stabilisce che l'apertura di un'application bundle lancia l'app se non è già attiva oppure la attiva/riapre se è già in esecuzione. Il comando macOS `open` espone inoltre le opzioni `-n` per una nuova istanza, `-W` per attendere la chiusura e `--args` per passare i restanti argomenti direttamente all'`argv` dell'applicazione.

Electron è anche un runtime invocabile da CLI; quindi il solo `open Electron.app` sarebbe semanticamente troppo debole. La forma RumiAI deve sfruttare Launch Services senza perdere la semantica per-invocation necessaria al runtime.

---

## 1. Bundle e Mach-O interno non sono equivalenti

Su macOS:

```text
Electron.app
```

è l'application bundle nativo, mentre:

```text
Electron.app/Contents/MacOS/Electron
```

è il main executable Mach-O interno.

L'esecuzione diretta del Mach-O ha semantica Unix processuale: `exec`, segnali ed exit status appartengono direttamente al processo Electron.

Il launch del bundle passa invece attraverso il modello applicativo macOS/Launch Services e consente al sistema operativo di trattare l'intera `.app` come unità applicativa.

Per una GUI macOS distribuita realmente come `.app`, il command pubblico normale deve preferire il bundle nativo salvo un requisito concreto che richieda invece il Mach-O interno.

---

## 2. Target Electron macOS

Per Electron macOS il target concettuale del command pubblico `electron` è:

```text
<concrete>/root/Electron.app
```

non:

```text
<concrete>/root/Electron.app/Contents/MacOS/Electron
```

Il Mach-O interno resta un oggetto tecnico verificabile e può essere usato da test specifici quando serve osservare proprietà processuali dirette, ma non costituisce il normale entrypoint GUI del package RumiAI su macOS.

---

## 3. Forma di launch scelta

Il command entry macOS usa il comando di sistema:

```text
/usr/bin/open
```

sul pathname package-local del bundle.

Per preservare la semantica per-invocation di Electron, la forma normale è:

```text
/usr/bin/open -n -W <concrete>/root/Electron.app
```

Quando l'utente passa uno o più argomenti al command `electron`, la forma diventa:

```text
/usr/bin/open -n -W <concrete>/root/Electron.app --args <argomenti-utente...>
```

Proprietà intenzionali:

```text
-n       ogni invocazione RumiAI richiede una nuova istanza Electron
-W       il command resta sincrono fino alla chiusura dell'istanza aperta
--args   gli argomenti successivi vengono passati all'argv dell'applicazione
```

`--args` non viene emesso quando non esistono argomenti utente.

Non viene usato:

```text
open -a Electron
open -b <bundle-id>
```

perché la risoluzione per nome o bundle identifier dipenderebbe dal database globale delle applicazioni e potrebbe selezionare una copia di Electron diversa da quella del concrete package RumiAI.

L'autorità resta sempre il pathname di `Electron.app` derivato dal concrete package corrente.

---

## 4. Relazione con `launcher`

Il generic direct-link launcher non acquisisce automaticamente semantica macOS e non viene trasformato in un launcher GUI.

Electron usa invece la modalità explicit-command fissata da:

```text
decisions/rumiai-os/2026-09-12-package-launch-explicit-command-line.md
```

quindi il command entry macOS delega la preparazione runtime comune a una forma equivalente a:

```text
launcher -c "electron" "/usr/bin/open" -n -W "$electron_bundle"
```

oppure, con argomenti utente:

```text
launcher -c "electron" "/usr/bin/open" -n -W "$electron_bundle" --args "$@"
```

Il `launcher` continua a possedere:

```text
validazione del command entry/concrete/root
HOME=$m_HOME_DIR/electron
package env
user env
final exec
```

La conoscenza di `Electron.app`, `/usr/bin/open`, `-n`, `-W` e `--args` appartiene esclusivamente al command-specific packaging macOS.

---

## 5. Nessun `link/electron` su macOS

La variante macOS non deve materializzare:

```text
link/electron
```

verso il Mach-O interno.

Motivi:

```text
- il normale target applicativo è una directory bundle, non un regular executable;
- link/ resta un puro binding verso executable nel root/ quando il direct-link è realmente usato;
- un link al Mach-O rappresenterebbe una semantica diversa da quella scelta per il command pubblico;
- non viene creato alcun wrapper artificiale dentro root/.
```

La variante Linux continua invece a usare il proprio direct-link executable come già fissato.

---

## 6. Semantica processuale osservabile

Con `-n -W`, il command macOS conserva due proprietà importanti rispetto al launch diretto:

```text
nuova istanza per invocazione
attesa sincrona fino alla chiusura dell'app aperta
```

Non deve però essere promesso che il modello sia identico a `exec` del Mach-O.

In particolare:

```text
- il processo finale eseguito dal package launcher è /usr/bin/open;
- Launch Services crea/gestisce il processo applicativo Electron;
- l'exit status di open descrive il proprio risultato e non viene assunto come exit status nativo del processo Electron;
- segnali diretti al processo open non sono assunti equivalenti a segnali diretti all'istanza Electron;
- eventuali proprietà processuali che RumiAI richiederà in futuro devono essere validate esplicitamente e non inferite.
```

Questa differenza è accettata perché il normale command macOS rappresenta un'application bundle nativo.

---

## 7. Sicurezza e garanzie macOS

Il launch del bundle tramite `open` usa il percorso applicativo nativo del sistema e lascia a macOS le normali policy applicabili al launch di application bundle.

Questo non sostituisce le responsabilità RumiAI:

```text
integrità/provenienza artefatto        package download/integrity
preservazione della bundle hierarchy   pkg_extract/pkg_integrate
confinement del concrete payload       package integration
runtime HOME/env                       launcher
policy di launch dell'application      macOS/Launch Services
```

`open` non viene trattato come sostituto dei controlli RumiAI sull'artefatto.

---

## 8. Portabilità

La specializzazione è host-specific perché risponde a una struttura upstream e a un modello applicativo host-specific reali.

Non modifica il contratto generale POSIX di RumiAI OS e non introduce `open` nei package Linux.

Il modello Electron diventa:

```text
Linux
  cmd/electron
    -> launcher direct-link
    -> root/electron

macOS
  cmd/electron
    -> launcher explicit-command
    -> /usr/bin/open -n -W root/Electron.app [--args ...]
```

La differenza è intenzionale e deriva dal formato upstream e dal sistema host.

---

## 9. Testing permanente richiesto

La variante macOS deve proteggere almeno:

```text
Electron.app preservato sotto root/
cmd/electron presente e executable
assenza di link/electron
bundle pathname derivato dal concrete package corrente
nessuna ricerca globale per nome/bundle id
uso di /usr/bin/open
uso di -n
uso di -W
assenza di --args con zero argomenti
presenza di --args con uno o più argomenti
preservazione esatta di argv dopo --args
HOME/env layering ancora gestito da launcher
failure se /usr/bin/open o il bundle non sono utilizzabili
```

Il live test macOS deve verificare il launch reale di un workload Electron minimo e il cleanup dell'istanza creata.

Il test non deve equiparare arbitrariamente lo status di `open` allo status interno dell'app Electron.

---

## 10. Physical validation

Per la revisione che implementa questo contratto resta necessaria physical validation su:

```text
Darwin/arm64
  install reale Electron
  bundle integrity/shape
  normal launch tramite command RumiAI
  workload Electron minimo
  argv rilevante
  chiusura/cleanup

Linux/aarch64
  regressione install/setuid_root
  normal launch/workload Linux
  nessuna regressione direct-link
```

Le evidence precedenti restano valide soltanto per le revisioni e proprietà che hanno realmente esercitato.

---

## 11. Supersession mirata

Questa decisione supersede le sole affermazioni incompatibili presenti in `2026-09-12-package-extract-macos-application-bundle-boundary.md` che, prima della valutazione del launch nativo, indicavano come comportamento corrente:

```text
link target Electron macOS = Electron.app/Contents/MacOS/Electron
link/electron obbligatorio nella variante macOS
normal launch macOS tramite direct-link al main executable
```

Restano integralmente valide la preservazione di `Electron.app` come semantic boundary di extraction, la shape del bundle osservata e tutti gli altri invarianti di quel documento.

---

## 12. Invarianti fissati

```text
PKG-MACOS-APP-LAUNCH-01  un vero macOS .app usato come GUI è trattato come application bundle, non come semplice pathname del Mach-O interno
PKG-MACOS-APP-LAUNCH-02  Electron macOS normale lancia il bundle package-local Electron.app
PKG-MACOS-APP-LAUNCH-03  la forma Electron usa /usr/bin/open -n -W sul pathname package-local
PKG-MACOS-APP-LAUNCH-04  --args viene aggiunto soltanto quando esistono argomenti utente e preserva il loro argv
PKG-MACOS-APP-LAUNCH-05  non si usa risoluzione globale open -a/open -b per Electron
PKG-MACOS-APP-LAUNCH-06  il generic direct-link launcher non acquisisce implicitamente semantica Launch Services
PKG-MACOS-APP-LAUNCH-07  Electron macOS usa launcher -c per preservare il runtime package comune
PKG-MACOS-APP-LAUNCH-08  la variante macOS non materializza link/electron e non crea wrapper artificiali
PKG-MACOS-APP-LAUNCH-09  -n preserva una nuova istanza per invocazione e -W preserva l'attesa sincrona
PKG-MACOS-APP-LAUNCH-10  status e segnali non vengono assunti equivalenti al direct exec del processo Electron
PKG-MACOS-APP-LAUNCH-11  il launch nativo non sostituisce controlli di integrità/confinement RumiAI
PKG-MACOS-APP-LAUNCH-12  la specializzazione macOS non modifica la semantica Linux
PKG-MACOS-APP-LAUNCH-13  Electron deve essere validato fisicamente su Darwin/arm64 e Linux/aarch64 per la revisione implementata
```
