# Decisione — `launcher` explicit command line e `cmd/` senza `link/`

Date: 2026-09-12  
Status: **Superseded / deferred**

Questa decisione aveva chiuso una firma concreta:

```text
launcher -c <pkg> <absolute-command> [command-arguments...]
```

e la materializzazione di `cmd/` senza `link/` perché Electron macOS era stato interpretato come primo consumer reale tramite `/usr/bin/open`.

La successiva verifica upstream ha corretto quel presupposto: il package RumiAI `electron` espone il runtime CLI e su Darwin deve eseguire direttamente:

```text
Electron.app/Contents/MacOS/Electron
```

tramite il normale direct-link package.

La decisione autorevole corrente è:

```text
decisions/rumiai-os/2026-09-12-electron-macos-runtime-command.md
```

Di conseguenza non esiste più un consumer concreto corrente che giustifichi la firma `launcher -c` o l'implementazione product-level di `cmd/` senza `link/`.

Torna corrente quanto già fissato in:

```text
decisions/rumiai-os/2026-09-07-package-command-specific-launch.md
decisions/rumiai-os/2026-09-10-package-launch-library.md
```

ossia:

```text
- una launch line composta resta un caso architetturalmente previsto;
- la logica command-specific appartiene a cmd/<pkg-command>;
- non si deve creare un link artificiale quando un futuro command richiederà davvero una launch line composta;
- la firma concreta del launcher e la relativa materializzazione restano però da fissare soltanto al primo package reale che le richiederà.
```

La precedente implementazione è stata corretta forward-only in `rumiai-os`; la storia Git non viene riscritta.

Sono quindi superseded come contratto corrente gli invarianti `PKG-LAUNCH-15..22` e `PKG-CMD-LINK-01..06` introdotti da questo documento nella loro forma concreta. Non viene superseded il principio preesistente secondo cui una futura launch line composta potrà richiedere un command entry senza direct-link artificiale.

Il contenuto storico completo resta disponibile nella storia Git precedente a questa correzione.
