# Decisione — `pkg_extract`: confine semantico dei macOS application bundle

Date: 2026-09-12  
Status: **Accepted**

## 1. Contesto

Il contratto corrente di `pkg_extract` è definito da:

```text
decisions/rumiai-os/2026-09-09-package-extract-contract.md
```

La structural useful-root discovery corrente scende ricorsivamente finché il livello osservato contiene esattamente una sola entry e tale entry è una real directory non-symlink.

Questa regola ha correttamente assorbito finora wrapper upstream variabili come:

```text
<release-name>/
<product>/<version>/
```

senza introdurre pathname/version-specific metadata nel catalogo.

Electron macOS ARM64 `v44.3.0` introduce il primo caso reale in cui una singola directory top-level non è un wrapper ma il payload software semanticamente indivisibile:

```text
Electron.app/
└── Contents/
    ├── Info.plist
    ├── MacOS/
    │   └── Electron
    ├── Frameworks/
    ├── Resources/
    └── ...
```

Il manifest upstream esatto della release `v44.3.0` è interamente radicato sotto `Electron.app/` e dichiara l'eseguibile:

```text
Electron.app/Contents/MacOS/Electron
```

Applicando senza eccezioni la regola corrente, `pkg_extract` scenderebbe prima dentro `Electron.app/` e poi dentro `Contents/`, consegnando una useful root con `MacOS/`, `Frameworks/`, `Resources/` e `Info.plist` direttamente alla root. Questo distruggerebbe la gerarchia del macOS application bundle invece di limitarsi a eliminare wrapper upstream.

Il documento originario aveva esplicitamente previsto che un package reale non rappresentabile correttamente dalla sola regola single-directory dovesse essere valutato quando fosse emerso. Electron macOS è quel primo caso concreto.

---

## 2. Autorità esterna verificata

La struttura non viene dedotta dal solo suffisso `.app`.

La documentazione Apple definisce il macOS application bundle con una directory bundle che contiene `Contents/`; dentro `Contents/` si trovano almeno la property list `Info.plist` e la directory `MacOS/` contenente il main executable.

Per il requisito concreto corrente sono quindi osservabili contemporaneamente:

```text
<name>.app/
<name>.app/Contents/
<name>.app/Contents/Info.plist
<name>.app/Contents/MacOS/
```

Electron `v44.3.0` rispetta questa shape e il proprio tooling upstream usa come executable Darwin:

```text
Electron.app/Contents/MacOS/Electron
```

---

## 3. Confine semantico durante la useful-root discovery

La useful-root discovery resta strutturale e repository-neutral.

Quando il livello corrente contiene esattamente una sola real directory non-symlink, prima di scendere in quella directory `pkg_extract` deve verificare se essa è un macOS application bundle riconoscibile dal contratto minimo seguente.

La candidate directory è un application-bundle boundary soltanto se tutte queste condizioni sono vere:

```text
basename termina esattamente con .app
candidate è una real directory non-symlink
candidate/Contents è una real directory non-symlink
candidate/Contents/Info.plist è un regular file non-symlink
candidate/Contents/MacOS è una real directory non-symlink
```

Se tutte le condizioni sono vere:

```text
non scendere nella candidate .app
il livello corrente è la useful root
```

Altrimenti continua la normale regola single-real-directory già fissata.

Quindi:

```text
archive/
└── Electron.app/
    └── Contents/...

-> useful root = archive/
-> staging finale conserva Electron.app/Contents/...
```

E anche:

```text
archive/
└── release-wrapper/
    └── Electron.app/
        └── Contents/...

-> release-wrapper viene eliminato
-> staging finale conserva Electron.app/Contents/...
```

La semantic boundary riguarda soltanto la decisione di discesa. Non introduce una seconda materialization mode e non cambia la normale operazione con cui eventuali wrapper esterni vengono sollevati nella destination finale.

---

## 4. Perché non viene introdotto metadata nel catalogo

Non vengono introdotti:

```text
useful_root
preserve_root
strip_components
root_depth
bundle_path
package-specific extraction hooks
```

La ragione è la stessa già fissata dal contratto originario: i wrapper upstream possono variare fra versioni e piattaforme e non devono diventare pathname version-specific nel catalogo.

Il macOS application bundle, invece, è riconoscibile dalla propria struttura semantica stabile e deve essere preservato come payload.

Electron non controlla quindi il comportamento di `pkg_extract` tramite metadata package-specific.

---

## 5. Nessuna generalizzazione ad altri bundle o package format

Questa decisione non introduce un framework generale di semantic-root recognizer.

In particolare non vengono anticipati comportamenti speciali per:

```text
.framework
.bundle
.plugin
.xpc
.appx
altri suffix o container
```

Se uno di questi diventerà il primo payload reale con lo stesso problema, verrà valutato sul requisito concreto.

Il solo caso aggiunto al baseline è il macOS application bundle `.app` con la shape minima verificata sopra.

---

## 6. Relazione con il contratto `pkg_extract` precedente

Questa decisione supersede esclusivamente l'interpretazione incondizionata di:

```text
PKG-EXTRACT-15
PKG-EXTRACT-16
```

del documento `2026-09-09-package-extract-contract.md`.

Restano invariati:

```text
API a tre argomenti
staging scelto dal caller
format esplicito
delega raw extraction a extract
assenza di package-specific useful-root pathname metadata
repository-neutrality
failure model
AppImage opaco
tutti gli altri invarianti PKG-EXTRACT-*
```

La regola corrente diventa:

```text
single real directory
    -> se è application-bundle boundary: stop prima della directory
    -> altrimenti: scendi
```

I wrapper strutturali continuano a essere eliminati; il payload `.app` riconosciuto non è classificato come wrapper.

---

## 7. Conseguenza corrente per Electron macOS ARM64

Dopo il riallineamento di `pkg_extract`, la package definition Electron macOS ARM64 usa il modello target-specific già esistente:

```text
electron/catalog-macos-arm64/
```

con primo anchor:

```text
n0001=v44.3.0
```

artifact:

```text
electron-v44.3.0-darwin-arm64.zip
```

format:

```text
zip
```

La variante macOS non dichiara `setuid_root`.

Il main executable osservato nel bundle resta:

```text
Electron.app/Contents/MacOS/Electron
```

ma non è più il target del normale command pubblico RumiAI.

Il contratto di launch corrente è fissato da:

```text
decisions/rumiai-os/2026-09-12-package-macos-application-launch.md
decisions/rumiai-os/2026-09-12-package-launch-explicit-command-line.md
```

Quindi la variante macOS materializza:

```text
cmd/electron
```

senza:

```text
link/electron
```

e il command usa il bundle package-local tramite il meccanismo applicativo nativo macOS (`/usr/bin/open -n -W`, con `--args` quando necessario) delegando il runtime comune a `launcher -c`.

La precedente descrizione di un direct-link verso `Electron.app/Contents/MacOS/Electron` è superseded esclusivamente per il normale launch macOS; l'eseguibile interno resta parte della shape del bundle da preservare e verificare.

---

## 8. Testing permanente richiesto

Il permanent test di `pkg_extract` deve continuare a proteggere tutti i casi correnti e aggiungere almeno:

```text
.app valido direttamente sotto raw root -> bundle preservato
wrapper esterno + .app valido -> wrapper esterno eliminato e bundle preservato
.app senza Contents/Info.plist -> non riconosciuto come boundary
.app con Contents symlink -> non riconosciuto come boundary
.app con Info.plist symlink/non-regular -> non riconosciuto come boundary
.app con Contents/MacOS symlink/non-directory -> non riconosciuto come boundary
normale deep-wrapper non-.app -> comportamento invariato
```

Il test deve essere puramente filesystem/strutturale e deve poter girare sugli host POSIX di riferimento senza richiedere macOS: verifica il contratto di `pkg_extract`, non il comportamento del sistema operativo Apple.

I test reali Electron macOS restano separati e devono verificare l'artifact upstream effettivo.

---

## 9. Physical validation Electron macOS

La physical validation macOS ARM64 della revisione corrente deve verificare almeno:

```text
install reale di Electron dal catalogo
artifact v44.3.0 Darwin ARM64 corretto
digest SHA-256 corretto
Electron.app preservato nella concrete package root
Electron.app/Contents/Info.plist presente e valido
Electron.app/Contents/MacOS/Electron executable presente
framework/helper e symlink interni essenziali preservati
firma del bundle verificabile con gli strumenti macOS appropriati
assenza di link/electron artificiale
normal launch del bundle package-local tramite command RumiAI
nuova istanza per invocazione (-n)
attesa sincrona del launch (-W)
propagazione argv tramite --args
HOME RumiAI ereditato dall'applicazione
workload Electron minimo con BrowserWindow fino a ready/page-load osservabile
cleanup deterministico dell'istanza creata
```

La verifica fisica può usare gli strumenti di sistema macOS per verificare che il bundle estratto rimanga una struttura valida e firmata, senza introdurre tali strumenti come dipendenza runtime di `pkg`.

La validazione Linux resta distinta:

```text
install reale
setuid_root chrome-sandbox
normal launch/workload Electron
direct-link executable invariato
```

La precedente evidence Linux `setuid_root` resta valida per ciò che ha già esercitato; il normal launch/workload è una proprietà ulteriore da validare.

---

## 10. Stato corrente

Alla revisione corrente del progetto:

```text
application-bundle extraction contract       fissato e implementato
launcher explicit-command contract           fissato e implementato
cmd/ senza link/ integration contract        fissato e implementato
permanent contract tests                     riallineati; physical validation della nuova revisione pending
pkg-catalog macos-arm64                      pubblicato con cmd/electron nativo e senza link/electron
Electron physical validation macOS           pending sulla nuova revisione
Electron normal-launch regression Linux      pending sulla nuova revisione
```

La pubblicazione macOS è quindi avvenuta soltanto dopo che il prodotto è stato reso capace di materializzare correttamente un command senza direct-link e di delegare una launch line esplicita al runtime package comune.

---

## 11. Invarianti correnti

```text
PKG-EXTRACT-15A  la single-real-directory discovery si arresta prima di una directory che soddisfa il macOS application-bundle boundary fissato
PKG-EXTRACT-16A  vengono eliminati solo wrapper strutturali esterni alla semantic boundary; un application bundle riconosciuto viene preservato integralmente come directory del payload
PKG-EXTRACT-22   il boundary .app richiede suffix .app + real Contents + regular non-symlink Contents/Info.plist + real Contents/MacOS
PKG-EXTRACT-23   nessun pathname/depth override package-specific viene introdotto per Electron o per i macOS application bundle
PKG-EXTRACT-24   il riconoscimento .app è repository-neutral e non richiede osarch o repository type
PKG-EXTRACT-25   nessun altro tipo di bundle/container viene generalizzato senza un caso reale
PKG-ELECTRON-MAC-01  Electron macOS ARM64 deve preservare Electron.app/Contents come hierarchy upstream
PKG-ELECTRON-MAC-02  il main executable osservato resta Electron.app/Contents/MacOS/Electron
PKG-ELECTRON-MAC-03  catalog-macos-arm64 usa il modello target-specific esistente e non dichiara setuid_root
PKG-ELECTRON-MAC-04  il normale command macOS usa il bundle package-local tramite il contratto native application launch corrente e non materializza link/electron
PKG-ELECTRON-MAC-05  la physical validation macOS include install reale e normal launch/workload controllato
PKG-ELECTRON-LINUX-10  la qualificazione Linux va completata con normal launch/workload oltre alla evidence install/setuid_root già acquisita
```
