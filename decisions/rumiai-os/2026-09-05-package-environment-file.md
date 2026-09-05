# Decisione — Package manager: file `env` per environment package-local

Date: 2026-09-05  
Status: **Superseded**

Questa decisione e stata superseded da:

```text
decisions/rumiai-os/2026-09-06-package-environment-layering.md
```

La decisione successiva mantiene il nome `env`, il modello dichiarativo minimo `set`/`unset`, la relocatability, la separazione da working directory/argv e il divieto di trattare `env` come shell code, ma corregge il modello distinguendo:

```text
environment standard di isolamento
    responsabilita runtime di pkg run

<package-version>/env
    configurazione version-specific gestita da pkg install
    per compatibilita e interazione con altri package/runtime/toolchain

<package-version>/var/conf/env
    configurazione persistente dello state selezionato
    per personalizzazioni e override utente
```

Per il contratto corrente fare riferimento esclusivamente alla decisione Accepted del 2026-09-06.
