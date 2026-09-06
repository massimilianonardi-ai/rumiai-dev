# Decisione — Package manager: `root/`, `cmd/` e binding diretto

Date: 2026-09-05  
Status: **Superseded**

Questa decisione descrive il precedente modello in cui `cmd/<pkg-command>` era un symbolic link relativo verso l'executable upstream e il package manager distingueva direct binding e launch mediato tramite `pkg run`.

Il modello corrente e stato sostituito dalle decisioni Accepted successive:

```text
decisions/rumiai-os/2026-09-06-package-self-contained-launch-and-default-state.md
decisions/rumiai-os/2026-09-06-package-command-entry-link-and-launcher.md
```

L'autorita corrente fissa in particolare:

```text
bin/ext*/<pkg-command>
    -> current
        -> <package-version>/cmd/<pkg-command>
            -> launcher
                -> <package-version>/link/<pkg-command>
                    -> <package-version>/root/<upstream-executable>
```

con:

- `cmd/<pkg-command>` come regular executable command file RumiAI;
- `link/<pkg-command>` come symbolic link relativo verso l'executable upstream sotto `root/`;
- `launcher` come primitive comune del sistema base;
- nessun bypass pubblico normale da `bin/ext*` direttamente verso `link/` o `root/`;
- `pkg run` fuori dal normale launch path;
- `root/<path> -> var/<area>/<path> -> state` invariato per la normalizzazione dei pathname upstream mutabili.

I principi ancora validi della decisione storica — separazione del namespace upstream `root/`, mapping esplicito dei command, nessuna scansione di `root/`, `package != command` e selezione attraverso `current` — sono riaffermati nelle decisioni correnti sopra indicate.

Il contenuto storico completo resta disponibile nella cronologia Git e non e fonte normativa per il layout corrente.
