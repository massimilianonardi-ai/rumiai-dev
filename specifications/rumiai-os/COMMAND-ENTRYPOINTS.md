# RumiAI OS — Command Entrypoints

Status: **Normative specification**  
Date: 2026-08-28  
Updated: 2026-09-09

## 1. Scope

RumiAI distingue due forme di entrypoint direttamente eseguibili:

```text
bootstrap-integrated command
    usa il runtime RumiAI e le facility inizializzate dal bootstrap

standalone shell utility
    è intenzionalmente autonoma dal bootstrap RumiAI
```

La classificazione dipende dal contratto runtime del comando, non dalla directory fisica, dal fatto che il file sia di proprietà RumiAI o dal linguaggio usato per implementarlo.

RumiAI continua inoltre a supportare le due forme top-level del runtime:

```text
rumiai-os
    enter the interactive RumiAI shell

rumiai-os file [args...]
    interpret/source the explicitly supplied file
```

Il vecchio multicall + `cmd/` shadow model resta superseded.

## 2. Bootstrap-integrated command

Un comando direttamente eseguibile MUST usare:

```text
#!/usr/bin/env rumiai-os
```

quando:

- usa attualmente environment variables, funzioni, librerie, logger, resolver lingua, root/path semantici, configurazione o altre facility inizializzate dal bootstrap RumiAI; oppure
- il suo ruolo rende ragionevolmente prevedibile che una dipendenza di questo tipo diventi parte del contratto del comando durante la sua evoluzione normale.

Non si deve scegliere `#!/bin/sh` soltanto perché la prima implementazione non usa ancora una facility bootstrap se l'integrazione con il runtime RumiAI è già una conseguenza ragionevolmente prevedibile del ruolo del comando.

Il profilo host deve supportare `/usr/bin/env`, executable shebang scripts, PATH-based interpreter resolution e forwarding del command pathname a `rumiai-os`.

La convenzione `#!` resta un'estensione esplicita del profilo host rispetto al contratto POSIX astratto.

## 3. Standalone shell utility

Una utility shell direttamente eseguibile MAY usare esattamente:

```text
#!/bin/sh
```

soltanto quando tutte le condizioni seguenti sono soddisfatte:

1. l'implementazione è POSIX `sh`;
2. il comando non dipende attualmente dal bootstrap RumiAI;
3. una dipendenza dal bootstrap non è ragionevolmente prevedibile nel normale ruolo del comando;
4. l'uso standalone costituisce una scelta intenzionale del contratto, non una scorciatoia implementativa;
5. l'utente ha autorizzato preventivamente questa scelta;
6. una decisione o specifica autorevole documenta la motivazione, le dipendenze esterne e il contratto osservabile.

Una standalone shell utility non può richiedere, come parte del proprio funzionamento, `m_*`, `log`, `lang`, librerie sourced dal bootstrap, `m_COMMAND_BIN` o altre facility fornite dal runtime RumiAI.

Le dipendenze esterne non garantite dalla baseline POSIX devono essere dichiarate esplicitamente come capability/dependency del comando.

Se in seguito emerge una dipendenza dal bootstrap, la classificazione e lo shebang MUST essere riesaminati. La migrazione normale è verso:

```text
#!/usr/bin/env rumiai-os
```

salvo una nuova decisione esplicita che stabilisca diversamente.

`bin/sys/read-key` è la prima utility autorizzata secondo questo modello standalone e usa `#!/bin/sh` per decisione del 2026-09-09.

## 4. Explicit source operand

Un file invocato tramite:

```text
rumiai-os file [args...]
```

nomina già l'interprete e quindi:

- non deve necessariamente contenere uno shebang;
- non deve necessariamente avere executable bit;
- deve risolvere a un regular file leggibile.

Questa forma riguarda i file interpretati dal runtime RumiAI. Una standalone shell utility non acquisisce implicitamente semantica bootstrap soltanto perché può essere letta come testo o invocata da un altro script.

## 5. Active runtime and portable exposure

Per l'esecuzione diretta dei bootstrap-integrated command, `/usr/bin/env` seleziona `rumiai-os` dal `PATH` corrente.

Dentro un ambiente RumiAI attivato/portable, il runtime canonico è esposto come:

```text
bin/sys/rumiai-os -> ../../rumiai-os
```

`bin/sys` partecipa al RumiAI `PATH` prima del path host ereditato. I command con shebang `#!/usr/bin/env rumiai-os` possono quindi risolvere il runtime attivo senza installazione host-global obbligatoria e senza preferire accidentalmente un'altra installazione host.

Questo symlink non è multicall routing.

Le standalone shell utility non dipendono da questo meccanismo per scegliere il proprio interprete, perché usano il pathname assoluto `/bin/sh` approvato dal relativo contratto.

## 6. Command/source identity

Per i file interpretati dal runtime RumiAI, il runtime canonicalizza il source pathname fornito e lo espone come environment variable:

```text
m_COMMAND_BIN
```

`m_COMMAND_BIN` è il pathname assoluto fisico/canonico del file sorgente interpretato.

L'identità operativa resta il pathname, non il solo basename. Alias/symlink esterni possono quindi rinominare un command file senza introdurre un registry globale dei basename.

Una standalone shell utility non riceve né richiede `m_COMMAND_BIN` dal bootstrap.

## 7. Positional arguments

Prima di eseguire il source di un bootstrap-integrated command body, `rumiai-os` rimuove il source-file operand dai propri positional parameters.

Il body osserva `$@` come gli argomenti originariamente forniti dopo il source pathname.

Una standalone shell utility riceve invece direttamente dal normale exec del sistema i propri positional parameters secondo il contratto del relativo interprete.

## 8. Execution model

Il bootstrap-integrated command body corrente è POSIX shell sourced in-process dopo che il bootstrap ha inizializzato l'ambiente RumiAI, `lang` e logger.

Esempio:

```sh
#!/usr/bin/env rumiai-os
log "$@"
```

Poiché il file è sourced nel runtime inizializzato, può chiamare direttamente le funzioni RumiAI già presenti nel processo.

Una standalone shell utility usa invece un processo `/bin/sh` indipendente e non deve assumere ambient state prodotto dal bootstrap RumiAI.

Un command body può delegare a un altro runtime approvato quando il relativo capability/profile contract lo consente.

## 9. Root semantics

Per i bootstrap-integrated command la root RumiAI deriva dal runtime fisico attivo, non dalla posizione del command file.

Una standalone shell utility non deve dipendere dalla root RumiAI salvo che una futura modifica ne cambi esplicitamente la classificazione.

## 10. Symbolic links and aliases

Un bootstrap-integrated command file può essere raggiunto tramite symbolic link con basename differente. Il runtime canonicalizza il source operand prima dell'esecuzione, quindi il nome esterno dell'alias non definisce l'identità dell'implementazione.

Le standalone shell utility seguono la normale semantica dell'exec host e non acquisiscono per implicazione il command-identity model del bootstrap.

## 11. No-argument shell behavior

Quando `rumiai-os` non riceve operandi, avvia:

```text
$SHELL if set and non-empty
sh otherwise
```

La precedente Bash-preferred / `conf/shell/default` selection policy è superseded.

La RumiAI shell deve ereditare l'ambiente RumiAI ed esporre le funzioni previste dal contratto interattivo corrente.

## 12. Superseded environment names

I riferimenti storici a:

```text
RumiAI_ROOT
RumiAI_BOOTSTRAP_BIN
RumiAI_COMMAND_BIN
```

sono superseded dal namespace corrente, incluso:

```text
m_ROOT
m_BOOTSTRAP_BIN
m_COMMAND_BIN
```

## 13. Failure handling

Il fallimento della risoluzione o validazione di un source file MUST impedirne il sourcing da parte del runtime RumiAI.

Dopo l'attivazione del logger, i failure dei bootstrap-integrated command SHOULD usare il normale logger quando il contratto del sottosistema lo prevede.

Una standalone shell utility non può dipendere dal logger bootstrap; se produce dati su stdout, le diagnostiche devono restare separate su stderr secondo il proprio contratto.

La consolidazione generale degli external numeric status resta un contratto separato salvo quando una specifica di comando fissa stati precisi.

## 14. Security boundary

Sourcing un RumiAI command esegue trusted code con privilegi e ambiente del processo runtime corrente. Questo meccanismo non è una sandbox.

L'uso di `/bin/sh` per una standalone shell utility non crea una sandbox né una boundary di sicurezza aggiuntiva; definisce soltanto indipendenza dal bootstrap e scelta dell'interprete.
