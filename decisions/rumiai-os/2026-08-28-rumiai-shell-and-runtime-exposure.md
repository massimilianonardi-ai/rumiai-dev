# Decisione — RumiAI shell e esposizione del runtime

Date: 2026-08-28
Status: **Accepted design direction**

## Obiettivo

Risolvere il requisito pre-bootstrap del command model:

```text
#!/usr/bin/env rumiai-os
```

senza richiedere che una installazione RumiAI modifichi obbligatoriamente l'ambiente host.

## Due modalità complementari

RumiAI supporta concettualmente due modalità.

### Portable / activated environment

L'utente avvia direttamente il runtime tramite un pathname noto, per esempio:

```text
/path/to/rumiai-os
```

Quando `rumiai-os` viene invocato senza argomenti, dopo il bootstrap apre la shell interattiva predefinita dell'ambiente RumiAI.

La shell RumiAI eredita l'environment inizializzato da RumiAI e dispone del namespace dei comandi RumiAI nel proprio `PATH`.

Il runtime viene esposto dentro l'ambiente RumiAI tramite un singolo entrypoint interno:

```text
$RumiAI_BIN_DIR/rumiai-os -> ../rumiai-os
```

Poiché phase 1 prepende `RumiAI_BIN_DIR` al `PATH`, dentro la RumiAI shell:

```text
command -v rumiai-os
```

può risolvere il runtime senza aggiungere `RumiAI_ROOT` al `PATH`.

Questo symlink non implementa il vecchio multicall: espone soltanto il runtime con il proprio nome canonico e non codifica identità o routing dei comandi.

### Host-integrated environment

Opzionalmente RumiAI può fornire una utility/script per creare o rimuovere un symlink host verso il runtime fisico.

La destinazione host NON è fissata a `/bin`.

Motivazione:

- `/bin` è area di sistema e non è una destinazione portabile per software locale;
- macOS protegge `/bin` tramite System Integrity Protection;
- `/usr/local/bin` è il default naturale per software installato localmente su host Unix-like compatibili.

Default iniziale proposto:

```text
/usr/local/bin/rumiai-os -> <RumiAI_BOOTSTRAP_BIN>
```

La directory host deve restare configurabile/overrideable.

L'utility di integrazione host dovrà:

- non sovrascrivere silenziosamente un pathname esistente non appartenente alla stessa installazione;
- rimuovere un link solo dopo aver verificato che esso punti al runtime atteso;
- riportare chiaramente errori di permesso;
- non richiedere l'integrazione host per usare RumiAI in portable mode.

## RumiAI shell

Invocazione senza argomenti:

```text
rumiai-os
```

significa inizialmente:

```text
bootstrap RumiAI
    ↓
initialize environment/i18n/logger
    ↓
launch interactive RumiAI shell
```

La shell preferita iniziale è:

```text
bash
```

con fallback:

```text
sh
```

se Bash non è disponibile o non è selezionabile.

La configurazione della shell appartiene a `RumiAI_CONF_DIR`, non ai bootstrap preference files `conf/bootstrap/*`.

Una code proposal iniziale usa concettualmente:

```text
conf/shell/default
conf/shell/bashrc
conf/shell/shrc
```

I nomi esatti restano soggetti a review della code proposal prima di diventare specifica normativa.

## Prompt

La shell RumiAI deve poter avere un prompt chiaramente riconoscibile e personalizzabile.

Il prompt non necessita di un protocollo separato: può essere parte della configurazione/rc file della shell selezionata.

Esempio concettuale:

```text
[RumiAI] user@host:path $
```

Per Bash, una RumiAI-specific rc file consente prompt, alias e altre preferenze senza caricare automaticamente i normali startup file host.

Per il fallback POSIX `sh`, la variabile `ENV` può puntare a una RumiAI-specific rc file assoluta per la shell interattiva.

## Relazione con il command interpreter

Dentro la RumiAI shell:

```text
RumiAI_BIN_DIR è nel PATH
bin/rumiai-os espone il runtime
```

quindi un command file:

```text
#!/usr/bin/env rumiai-os
```

può essere eseguito senza ulteriore installazione host.

In host-integrated mode, `/usr/local/bin/rumiai-os` rende lo stesso interprete risolvibile anche dalle normali shell host, purché `/usr/local/bin` appartenga al `PATH` host.

## Riferimento storico `msh`

Il precedente ambiente `m` usava già lo stesso principio generale:

- costruzione di un PATH dell'ambiente;
- apertura di Bash quando invocato senza argomenti;
- prompt riconoscibile;
- ambiente isolato dai normali startup file Bash.

Quel codice è materiale storico di riferimento, non implementazione da copiare. In particolare RumiAI non eredita la scansione indiscriminata delle sottodirectory nel PATH né la vecchia risoluzione manuale dei symlink.

## Product boundary

Questa decisione riguarda design e bozze in `rumiai-dev`.

Non autorizza ancora modifiche al repository prodotto `rumiai-os`.
