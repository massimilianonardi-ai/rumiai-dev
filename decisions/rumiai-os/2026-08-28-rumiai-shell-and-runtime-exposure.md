# Decisione — RumiAI shell e esposizione del runtime

Date: 2026-08-28  
Status: **Partially superseded 2026-09-02 / shell startup superseded 2026-09-05**

La motivazione originaria per esporre il runtime dentro l'ambiente portable resta valida, ma i dettagli di layout, namespace, shell selection e startup shell di questa decisione sono stati sostituiti.

Decisioni correnti:

```text
decisions/rumiai-os/2026-09-02-bootstrap-runtime-standards.md
decisions/rumiai-os/2026-09-05-interactive-shell-startup.md
```

Contratto corrente di esposizione runtime:

```text
bin/sys/rumiai-os -> ../../rumiai-os
```

Il symlink espone il runtime canonico per `#!/usr/bin/env rumiai-os` e non implementa multicall.

La policy corrente di selezione shell è:

```text
$SHELL se valorizzata
sh altrimenti
```

La precedente selezione automatica Bash-preferred e `conf/shell/default` è superseded.

Il contratto corrente di startup, forwarding degli argomenti, `m_SHELL_EXT`, adapter Bash/Zsh/POSIX, login/non-login e protezione dagli alias è definito da `2026-09-05-interactive-shell-startup.md`.

Il contenuto storico completo resta disponibile in Git history e costituisce rationale storico, non il contratto corrente per i punti sostituiti.
