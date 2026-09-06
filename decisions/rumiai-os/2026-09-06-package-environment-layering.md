# Decisione — Package manager: layering dell'environment e override utente

Date: 2026-09-06  
Status: **Superseded**

Questa decisione descrive il precedente modello in cui i file `env` erano configurazione dichiarativa non-shell con una futura grammatica RumiAI propria.

Il modello corrente e stato sostituito da:

```text
decisions/rumiai-os/2026-09-06-package-env-shell-source.md
```

L'autorita corrente mantiene il layering e le responsabilita gia emerse, ma fissa i file:

```text
<package-version>/env
$m_CONF_DIR/<pkg>/env
```

come frammenti shell POSIX opzionali caricati dal `launcher` tramite il dot command `.`.

Restano validi, perche riaffermati dalla decisione corrente:

- environment standard di isolamento separato e costruito dal launcher;
- `<package-version>/env` version-specific e gestito da `pkg install`;
- `$m_CONF_DIR/<pkg>/env` come personalizzazione/override persistente utente;
- ordine package env prima dell'env utente;
- nessuna state area `var/env`;
- relocatability;
- separazione di `var/` come routing dei pathname upstream mutabili.

Sono superseded:

- formato dichiarativo non-shell;
- grammatica RumiAI `set`/`unset`;
- parser/interprete dedicato per `env`;
- divieto di shell code;
- divieto di caricamento tramite `.`;
- i relativi punti aperti su quoting, escaping, prepend/append e altre primitive di un mini-linguaggio.

Il contenuto storico completo resta disponibile nella cronologia Git e non e fonte normativa per la semantica corrente di `env`.
