# Decisione — Baseline operativa di `pkg install` per candidate locale stateless

Date: 2026-09-07  
Status: **Superseded**

Questa decisione descriveva il primo incremento in cui la CLI pubblica era:

```text
pkg install <pkg> <version> <candidate-directory>
```

e `bin/sys/pkg` incorporava direttamente validazione, materializzazione e integrazione di un candidate locale.

Il modello è stato superseded dalla correzione architetturale fissata in:

```text
decisions/rumiai-os/2026-09-07-package-install-repository-pipeline-and-cli.md
```

Il modello corrente fissa invece:

```text
pkg install <pkg> [<pkg> ...]
pkg uninstall <pkg> [<pkg> ...]
```

con responsabilità fisicamente/API separate:

```text
repository-specific discovery/resolution
    -> una libreria per repository type con API comune

generic download
    -> lib/sh/pkg-download.lib.sh

generic extract
    -> lib/sh/pkg-extract.lib.sh

RumiAI package materialization/integration
    -> lib/sh/pkg-integration.lib.sh
```

L'implementazione prodotto:

```text
rumiai-os@b0d1e1244709e1766c679898ac46785711aca1ca
```

implementa questa baseline superseded e non deve essere considerata il contratto corrente di `pkg install`.

Restano validi soltanto gli invarianti provenienti dalle altre decisioni Accepted correnti e non dipendenti dalla CLI local-candidate, inclusi il concrete pathname, il selector relativo, `cmd/`, `link/`, `env`, state e facility/dependency semantics.
