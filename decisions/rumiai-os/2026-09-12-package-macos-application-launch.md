# Decisione — Launch nativo dei macOS application bundle nei package RumiAI

Date: 2026-09-12  
Status: **Superseded**

Questa decisione è stata superseded dalla successiva verifica del ruolo reale del package `electron` e dalla decisione:

```text
decisions/rumiai-os/2026-09-12-electron-macos-runtime-command.md
```

La valutazione precedente aveva trattato `Electron.app` come se il command pubblico RumiAI rappresentasse una applicazione macOS finale da aprire tramite LaunchServices.

La correzione corrente distingue invece:

```text
package electron
  runtime/framework CLI
  -> direct execution di Electron.app/Contents/MacOS/Electron

futura applicazione GUI macOS confezionata come .app
  applicazione finale
  -> native application launch da valutare nel relativo package/command
```

Non sono più correnti per Electron macOS:

```text
/usr/bin/open -n -W Electron.app
--args per inoltrare argv
assenza di link/electron
Electron come consumer della modalità launcher -c
```

Restano valide, perché fissate anche da decisioni indipendenti:

```text
Electron.app come semantic boundary da preservare durante extraction
validazione di Info.plist e bundle signature
nessuna ricerca globale per nome/bundle identifier quando serve un concrete package specifico
launcher -c come capacità generica per vere launch line composte
necessità di physical validation Electron su macOS ARM64 e Linux ARM64
```

Il contenuto storico completo di questa decisione resta disponibile nella storia Git precedente alla correzione forward-only.
