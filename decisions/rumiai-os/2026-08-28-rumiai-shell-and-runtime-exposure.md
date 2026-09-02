# Decisione — RumiAI shell e esposizione del runtime

Date: 2026-08-28  
Status: **Partially superseded 2026-09-02**

La motivazione originaria per esporre il runtime dentro l'ambiente portable resta valida, ma i dettagli di layout, namespace e shell selection di questa decisione sono stati sostituiti.

Decisione corrente:

```text
decisions/rumiai-os/2026-09-02-bootstrap-runtime-standards.md
```

Contratto corrente:

```text
bin/sys/rumiai-os -> ../../rumiai-os
```

Il symlink espone il runtime canonico per `#!/usr/bin/env rumiai-os` e non implementa multicall.

La policy shell corrente è:

```text
$SHELL se valorizzata
sh altrimenti
```

La precedente selezione automatica Bash-preferred e `conf/shell/default` è superseded.

Il contenuto storico completo resta disponibile in Git history e costituisce rationale storico, non il contratto corrente per i punti sostituiti.
