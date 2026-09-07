# Decisione — Resolution del range per versioni upstream esplicite

Date: 2026-09-07  
Updated: 2026-09-07  
Status: **Superseded**

Questa decisione è stata superseded integralmente da:

```text
2026-09-07-package-current-upstream-and-positional-range-resolution.md
```

La versione precedente aveva ammesso:

```text
repository type/coordinate differenti fra range dello stesso stream
consultazione di adapter candidate differenti prima della selezione definitiva del range
membership determinata interrogando più repository context
```

Questi punti non appartengono più al design corrente.

Il modello corrente fissa invece:

```text
un solo repository upstream corrente per stream
<stream>/repository come descriptor del repository corrente
pkg_repository_list_versions contro quel repository corrente
successione delle versioni installabili oldest -> latest
range determinato dalla posizione della versione rispetto agli anchor nNNNN=<version-minimum>
nessun repository storico automatico
nessuna lista statica delle versioni per range
nessuna primitive package-specific match nel baseline
```

Restano storicamente valide soltanto le motivazioni che avevano portato a rifiutare un comparatore universale delle versioni upstream. Le regole operative correnti sono esclusivamente quelle della decisione superseding e delle decisioni catalog/pipeline aggiornate.

Git conserva la versione precedente di questo documento come storia del design; non deve essere usata come autorità corrente.
