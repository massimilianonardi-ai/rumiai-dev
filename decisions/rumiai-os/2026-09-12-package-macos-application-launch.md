# Decisione — Launch nativo dei macOS application bundle nei package RumiAI

Date: 2026-09-12  
Status: **Accepted**

## Contesto

Il runtime package corrente ha già fissato:

```text
cmd/<pkg-command>    command entry RumiAI package-local
launcher             primitive comune del runtime package
link/<pkg-command>   quando presente, binding relativo verso root/ dello stesso package concreto
root/                 payload upstream
```

Il baseline `launcher` corrente termina il direct-link con:

```text
exec <resolved-link-target> [command-arguments...]
```

Questa semantica è appropriata per executable normali perché conserva direttamente processo, argv, segnali ed exit status dell'upstream.

La validazione Electron su macOS ha però reso concreto un caso diverso: l'artefatto upstream è un application bundle macOS (`Electron.app`), il cui executable reale vive sotto `Contents/MacOS/`, ma il bundle costituisce l'unità applicativa nativa riconosciuta da macOS.

L'utente ha richiesto di valutare se, per questo caso, il command RumiAI debba avviare il bundle attraverso i meccanismi nativi macOS invece di eseguire direttamente `Electron.app/Contents/MacOS/Electron`, così da riutilizzare il comportamento e le garanzie già fornite dal sistema operativo.

Questa decisione fissa il risultato della valutazione senza modificare il contratto generale dei command non-bundle.

---

## 1. Distinzione semantica fra executable interno e application bundle

Su macOS:

```text
Electron.app/Contents/MacOS/Electron
```

è l'executable Mach-O interno del bundle, mentre:

```text
Electron.app
```

è l'unità applicativa nativa gestita da LaunchServices/macOS.

L'esecuzione diretta dell'executable interno mantiene la normale semantica Unix di `exec`: il processo chiamante viene sostituito, argv viene consegnato direttamente all'executable, segnali ed exit status seguono il processo avviato.

Il launch del bundle tramite i meccanismi nativi macOS ha invece semantica applicativa: macOS risolve e apre il bundle come applicazione, gestisce l'attivazione e può riusare un'istanza già esistente secondo la semantica dell'applicazione. Il processo che effettua la richiesta di launch non coincide necessariamente con il processo applicativo risultante e non costituisce quindi un sostituto trasparente di `exec`.

Questa differenza è intenzionale e non deve essere nascosta.

---

## 2. Regola per i package che espongono una GUI macOS come `.app`

Quando un package RumiAI espone come command una vera applicazione GUI macOS distribuita come application bundle, il launch normale su macOS deve preferire il bundle come unità applicativa invece dell'esecuzione diretta del Mach-O sotto `Contents/MacOS/`.

Quindi, per Electron su macOS, il target concettuale del command `electron` è:

```text
<concrete>/root/Electron.app
```

non:

```text
<concrete>/root/Electron.app/Contents/MacOS/Electron
```

quando l'intento dell'invocazione è avviare Electron come applicazione GUI macOS.

La scelta sfrutta il modello applicativo nativo del sistema operativo e mantiene intatto il bundle come boundary semantico.

---

## 3. Il generic `launcher` non cambia semantica

Il generic direct-link baseline di `launcher` resta invariato:

```text
final exec del regular executable risolto da link/<pkg-command>
```

Non viene trasformato in un launcher GUI host-specific e non acquisisce implicitamente una dipendenza da `open`, LaunchServices o altre primitive macOS.

Motivazioni:

```text
- `exec` conserva una semantica forte e portabile per i command normali;
- il launch di un `.app` ha semantica diversa da `exec`;
- il comportamento host-specific deve restare confinato dietro logica command-specific quando realmente necessario;
- introdurre automaticamente `open` nel generic launcher cambierebbe processo, status, segnali e lifecycle anche per command che non lo richiedono.
```

Resta quindi valido che il command entry possiede la minima logica di launch specifica necessaria al proprio command.

---

## 4. Collocazione della logica macOS-specifica

La conoscenza che Electron su macOS deve essere aperto come application bundle appartiene alla definizione del command Electron per lo stream macOS.

La logica deve quindi essere espressa nel `cmd/electron` materializzato per il package macOS, riusando per quanto possibile la preparazione runtime comune già fornita da `pkg-launch.lib.sh` e senza duplicare indiscriminatamente environment isolation o altre responsabilità del launcher.

Se il generic `launcher` corrente non espone ancora una forma adatta a finalizzare una launch line composta senza `link/<pkg-command>`, questa necessità costituisce il primo caso concreto già previsto da `PKG-CMD-LAUNCH-06` e `PKG-LAUNCH-13` e deve essere risolta con la minima estensione coerente del contratto esistente, non tramite un wrapper artificiale dentro `root/`.

Non viene introdotto un `link/electron` verso il directory bundle: il contratto corrente di `link/` richiede un executable regular confinato in `root/`, mentre `Electron.app` è una directory bundle.

---

## 5. Uso del comando macOS `open`

Per il command entry macOS, la primitive di sistema iniziale da usare per richiedere il launch del bundle è il comando macOS `open`, che inoltra la richiesta al sistema applicativo nativo.

La forma deve puntare esplicitamente al pathname package-local del bundle e deve preservare gli argomenti applicativi solo attraverso l'interfaccia documentata da `open` per passarli all'applicazione.

Non deve essere usata la ricerca per nome applicazione (`open -a Electron`) perché introdurrebbe dipendenza dal database globale delle applicazioni installate e potrebbe selezionare un'altra copia di Electron fuori dal concrete package RumiAI.

L'autorità resta quindi il bundle sotto il `root/` del concrete package corrente.

---

## 6. Conseguenze osservabili del launch nativo

Il command Electron macOS non deve promettere proprietà che il launch applicativo nativo non possiede.

In particolare:

```text
- il processo `open` può terminare dopo aver consegnato con successo la richiesta di launch;
- il suo exit status descrive il successo/fallimento della richiesta di apertura, non il futuro exit status dell'applicazione Electron;
- il lifecycle dell'app GUI non coincide necessariamente con quello del command shell che l'ha avviata;
- segnali inviati successivamente al processo chiamante non sono automaticamente equivalenti a segnali diretti al processo Electron;
- macOS può attivare o riutilizzare un'istanza applicativa esistente secondo la semantica del bundle.
```

Queste proprietà non sono considerate regressioni: sono parte della semantica nativa scelta per una GUI application bundle.

Quando serve invece la semantica processuale diretta dell'executable Electron, per esempio per specifici test tecnici o usi CLI/upstream che dipendono da exit status e segnali, il test o il consumer può indirizzare esplicitamente l'executable interno come oggetto tecnico; ciò non cambia il normale command pubblico `electron` su macOS.

---

## 7. Sicurezza e garanzie macOS

Il launch del bundle tramite il sistema applicativo macOS è preferibile per una GUI perché mantiene il bundle come unità riconosciuta dal sistema e lascia a macOS le normali verifiche e policy applicabili al launch di applicazioni.

Questa decisione non assume però che `open` aggiunga magicamente garanzie di integrità che RumiAI non abbia già verificato durante download/installazione, né sostituisce i controlli package RumiAI.

Rimangono separati:

```text
integrità/provenienza dell'artefatto       responsabilità package/install
struttura e confinement del bundle         responsabilità integration/validation
policy e launch applicativo macOS           responsabilità del sistema operativo
runtime isolation RumiAI                    responsabilità package launcher/environment
```

---

## 8. Portabilità

Questa è una specializzazione host-specific motivata da una struttura upstream host-specific reale.

Non modifica il contratto generale POSIX di RumiAI OS e non introduce `open` come dipendenza dei package Linux o degli executable portabili.

Il modello cross-platform Electron diventa quindi semanticamente:

```text
Linux
  cmd/electron
    -> runtime package comune
    -> executable upstream Linux

macOS
  cmd/electron
    -> runtime package comune
    -> launch nativo di root/Electron.app
```

La differenza è giustificata dalla diversa forma upstream e dal modello applicativo del sistema host, non da una divergenza arbitraria della CLI RumiAI.

---

## 9. Testing richiesto

La decisione deve essere protetta da test permanenti proporzionati.

Su macOS Electron devono essere verificati almeno:

```text
- il package installato conserva Electron.app come bundle integro sotto root/;
- il command pubblico non dipende da una copia globale di Electron;
- il launch usa il pathname del bundle del concrete package corrente;
- il normale launch GUI apre correttamente Electron tramite il meccanismo nativo macOS;
- gli argomenti destinati all'applicazione sono preservati attraverso la forma documentata del launch;
- un bundle mancante/non valido produce failure del command;
- il test non interpreta il ritorno del launch request come exit status finale dell'applicazione.
```

Linux continua a proteggere la normale semantica executable/process del proprio artefatto.

La physical validation cross-platform Electron resta necessaria sui reference host Linux/aarch64 e Darwin/arm64 per la revisione esatta che implementerà questa decisione.

---

## 10. Invarianti fissati

```text
PKG-MACOS-APP-LAUNCH-01  un vero macOS .app usato come GUI è trattato come application bundle, non come semplice pathname del Mach-O interno
PKG-MACOS-APP-LAUNCH-02  Electron macOS normale deve lanciare il bundle package-local Electron.app
PKG-MACOS-APP-LAUNCH-03  il generic direct-link launcher conserva final exec e non acquisisce implicitamente semantica LaunchServices
PKG-MACOS-APP-LAUNCH-04  la specializzazione bundle appartiene al command-specific packaging macOS
PKG-MACOS-APP-LAUNCH-05  non si usa open -a o altra risoluzione globale per nome; l'autorità è il pathname del bundle nel concrete root corrente
PKG-MACOS-APP-LAUNCH-06  link/ non viene piegato a rappresentare directory .app e non viene creato un wrapper artificiale in root/
PKG-MACOS-APP-LAUNCH-07  il successo del launch request macOS non equivale all'exit status futuro dell'applicazione GUI
PKG-MACOS-APP-LAUNCH-08  il launch nativo non sostituisce controlli di integrità, confinement e installazione RumiAI
PKG-MACOS-APP-LAUNCH-09  la specializzazione macOS non modifica la semantica Linux né il contratto POSIX generale
PKG-MACOS-APP-LAUNCH-10  Electron deve essere validato fisicamente sia su Darwin/arm64 sia su Linux/aarch64 per la revisione che implementa il nuovo command macOS
```
