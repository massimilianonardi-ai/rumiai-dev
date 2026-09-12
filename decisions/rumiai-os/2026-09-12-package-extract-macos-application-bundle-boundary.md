# Decisione — `pkg_extract`: confine semantico dei macOS application bundle

Date: 2026-09-12  
Status: **Accepted**

## 1. Contesto

Il contratto corrente di `pkg_extract` è definito da:

```text
decisions/rumiai-os/2026-09-09-package-extract-contract.md
```

La structural useful-root discovery scende ricorsivamente finché il livello osservato contiene esattamente una sola entry e tale entry è una real directory non-symlink.

Questa regola assorbe wrapper upstream come:

```text
<release-name>/
<product>/<version>/
```

Electron macOS ARM64 `v44.3.0` introduce il primo caso reale in cui una singola directory top-level non è un wrapper ma il payload semanticamente indivisibile:

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

Applicando senza eccezioni la regola single-directory, `pkg_extract` entrerebbe in `Electron.app/` e poi in `Contents/`, distruggendo la gerarchia del macOS application bundle.

Il contratto originario aveva previsto che un package reale non rappresentabile correttamente dalla sola regola single-directory dovesse essere valutato quando fosse emerso. Electron macOS è quel primo caso concreto.

---

## 2. Boundary strutturale

La struttura non viene dedotta dal solo suffisso `.app`.

La candidate directory è un application-bundle boundary soltanto se tutte queste condizioni sono vere:

```text
basename termina esattamente con .app
candidate è una real directory non-symlink
candidate/Contents è una real directory non-symlink
candidate/Contents/Info.plist è un regular file non-symlink
candidate/Contents/MacOS è una real directory non-symlink
```

Quando il livello corrente contiene esattamente una sola real directory non-symlink, `pkg_extract` verifica prima questo contratto.

Se tutte le condizioni sono vere:

```text
non scendere nella candidate .app
il livello corrente è la useful root
```

Altrimenti continua la normale regola single-real-directory.

Quindi:

```text
archive/
└── Electron.app/
    └── Contents/...

-> useful root = archive/
-> staging finale conserva Electron.app/Contents/...
```

E:

```text
archive/
└── release-wrapper/
    └── Electron.app/
        └── Contents/...

-> release-wrapper viene eliminato
-> staging finale conserva Electron.app/Contents/...
```

La semantic boundary riguarda soltanto la decisione di discesa. Non introduce una seconda materialization mode.

---

## 3. Nessun metadata package-specific

Non vengono introdotti:

```text
useful_root
preserve_root
strip_components
root_depth
bundle_path
package-specific extraction hooks
```

Il macOS application bundle è riconoscibile dalla propria struttura semantica e deve essere preservato come payload.

Electron non controlla quindi `pkg_extract` tramite metadata package-specific.

---

## 4. Nessuna generalizzazione preventiva

Questa decisione non introduce un framework generale di semantic-root recognizer.

Non vengono anticipati comportamenti speciali per:

```text
.framework
.bundle
.plugin
.xpc
.appx
altri suffix o container
```

Se uno di questi diventerà un payload reale con lo stesso problema, verrà valutato sul requisito concreto.

---

## 5. Relazione con il contratto precedente

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

---

## 6. Conseguenza per Electron macOS ARM64

La package definition Electron macOS ARM64 usa il modello target-specific già esistente:

```text
electron/catalog-macos-arm64/
n0001=v44.3.0
```

con artifact:

```text
electron-v44.3.0-darwin-arm64.zip
```

e format:

```text
zip
```

La variante macOS non dichiara `setuid_root`.

Il bundle preservato è:

```text
root/Electron.app/
```

Il package `electron` espone il runtime Electron, quindi il normale command macOS segue il contratto diretto fissato da:

```text
decisions/rumiai-os/2026-09-12-electron-macos-runtime-command.md
```

ossia:

```text
link/electron -> ../root/Electron.app/Contents/MacOS/Electron
cmd/electron -> launcher "electron" "$@"
```

Il normale command runtime non usa `/usr/bin/open` o LaunchServices.

Una futura app finale RumiAI confezionata come `.app` valuterà separatamente il proprio native application launch.

---

## 7. Testing permanente

Il permanent test di `pkg_extract` protegge almeno:

```text
.app valido direttamente sotto raw root -> bundle preservato
wrapper esterno + .app valido -> wrapper esterno eliminato e bundle preservato
.app senza Contents/Info.plist -> non riconosciuto come boundary
.app con Contents symlink -> non riconosciuto come boundary
.app con Info.plist symlink/non-regular -> non riconosciuto come boundary
.app con Contents/MacOS symlink/non-directory -> non riconosciuto come boundary
normale deep-wrapper non-.app -> comportamento invariato
```

Il test resta puramente filesystem/strutturale e gira sugli host POSIX di riferimento senza richiedere macOS.

I test reali Electron macOS restano separati.

---

## 8. Physical validation dell'archive macOS

La physical validation dell'archive ufficiale `v44.3.0` è registrata in:

```text
decisions/rumiai-os/2026-09-12-electron-macos-prebuilt-signature-and-archive-validation.md
```

Evidence:

```text
validation/20260912T222918+0200-77771
rumiai-tests 9271e8b9c1dfbf4e33234d9d94c282649a39bcb6
rumiai-os    96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
Darwin/arm64
PASS
```

Il gate ha verificato sullo stesso ZIP ufficiale:

```text
SHA-256 osservato
RumiAI extract vs /usr/bin/ditto -x -k
path tree equivalente
14 symlink in entrambi
framework symlink targets equivalenti
Contents/Resources presente
main executable presente/executable
runtime --version = v44.3.0
```

L'archive upstream osservato non contiene `Electron.app/Contents/_CodeSignature/CodeResources`; di conseguenza la strict `codesign` verification fallisce allo stesso modo sia dopo RumiAI extract sia dopo `ditto`.

Questo non è un failure di `pkg_extract`.

Il contratto corrente sulla firma è:

```text
materiale firma presente upstream
    -> RumiAI deve preservarlo e la verifica applicabile deve riuscire

materiale firma assente upstream
    -> registrare il limite upstream
    -> non risignare/riparare in pkg install
```

Digest e integrità dell'artifact restano obbligatori.

---

## 9. Physical validation runtime Electron macOS

Dopo il gate archive/extraction, il normal launch macOS deve verificare almeno:

```text
install reale di Electron dal catalogo
Electron.app preservato nella concrete package root
Info.plist valido
main executable Electron.app/Contents/MacOS/Electron presente/executable
link/electron relativo al main executable interno
cmd/electron direct-link
public command RumiAI
process.execPath package-local
HOME RumiAI del package
argv diretto preservato
BrowserWindow nascosta
loadFile HTML locale
marker deterministico
exit/cleanup
```

Se `Contents/_CodeSignature/CodeResources` è presente nel bundle installato, il launch gate richiede anche `codesign --verify --deep --strict` PASS; se è assente, registra lo stato senza attribuirlo a RumiAI, coerentemente con la evidence archive corrente.

La validazione Linux resta distinta:

```text
install reale
setuid_root chrome-sandbox
normal launch/workload Electron
direct-link executable
sandbox Chromium non disabilitato
```

---

## 10. Stato corrente

Alla revisione corrente del progetto:

```text
application-bundle extraction contract       fissato e implementato
launcher direct-link                          baseline corrente
launcher explicit-command (-c)                non implementato; deferito
cmd senza link                                non implementato; deferito
Electron macOS direct runtime definition      pubblicata
pkg_extract permanent validation ARM64        PASS Linux + macOS sulla revisione 96d399d0...
Electron macOS archive extraction gate        PASS sulla revisione 96d399d0...
Electron macOS normal launch                   da riconfermare dopo la correzione del criterio firma
Electron Linux install/setuid + launch         PASS sulla revisione 96d399d0... con suite external/electron Linux
```

---

## 11. Invarianti correnti

```text
PKG-EXTRACT-15A  la single-real-directory discovery si arresta prima di una directory che soddisfa il macOS application-bundle boundary fissato
PKG-EXTRACT-16A  vengono eliminati solo wrapper strutturali esterni alla semantic boundary; un application bundle riconosciuto viene preservato integralmente come directory del payload
PKG-EXTRACT-22   il boundary .app richiede suffix .app + real Contents + regular non-symlink Contents/Info.plist + real Contents/MacOS
PKG-EXTRACT-23   nessun pathname/depth override package-specific viene introdotto per Electron o per i macOS application bundle
PKG-EXTRACT-24   il riconoscimento .app è repository-neutral e non richiede osarch o repository type
PKG-EXTRACT-25   nessun altro tipo di bundle/container viene generalizzato senza un caso reale
PKG-ELECTRON-MAC-01  Electron macOS ARM64 preserva Electron.app/Contents come hierarchy upstream
PKG-ELECTRON-MAC-02  il main executable è Electron.app/Contents/MacOS/Electron
PKG-ELECTRON-MAC-03  catalog-macos-arm64 usa il modello target-specific esistente e non dichiara setuid_root
PKG-ELECTRON-MAC-04  il runtime command macOS usa direct-link al main executable interno e non LaunchServices
PKG-ELECTRON-MAC-05  la physical validation macOS separa archive/extraction state e normal runtime launch
PKG-ELECTRON-MAC-06  pkg install non inventa né ripara una firma mancante upstream
PKG-ELECTRON-LINUX-10  la qualificazione Linux comprende install/setuid_root e normal launch/workload
``` 
