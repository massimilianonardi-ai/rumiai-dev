# Decisione — Multicall commands, `cmd/` e bootstrap status

Date: 2026-08-28
Status: **Superseded**

Superseded by:

```text
decisions/rumiai-os/2026-08-28-command-interpreter-shebang.md
```

## Valore storico

Questa decisione documenta una proposta precedentemente accettata durante l'esplorazione del bootstrap command model. Non rappresenta più l'architettura corrente.

Il modello esplorato era:

```text
bin/<command> -> ../rumiai-os
cmd/<command>
```

con `bin/` come namespace pubblico nel `PATH` e `cmd/` come directory privata delle implementazioni.

Il lavoro successivo ha mostrato che questo modello richiedeva progressivamente:

- preservare `RumiAI_INVOKED_AS` e il pathname pre-realpath;
- distinguere symlink interni ed esterni;
- stabilire regole per alias esterni rinominati;
- risolvere collisioni di basename in directory diverse;
- trasformare `cmd/` in uno shadow tree dei pathname pubblici;
- introdurre dispatch e mapping aggiuntivi nel front controller.

Questa complessità è diventata la motivazione principale per abbandonare il multicall.

## Stato precedente della proposta

La directory privata proposta era:

```text
$RumiAI_ROOT/cmd
```

con:

```text
RumiAI_COMMAND_DIR=$RumiAI_ROOT/cmd
```

I comandi pubblici erano symlink:

```text
bin/log -> ../rumiai-os
bin/foo -> ../rumiai-os
```

Le forme:

```text
log ...
rumiai-os log ...
```

avrebbero dovuto convergere sullo stesso bootstrap e su `RumiAI_COMMAND`.

## Alias esterni esplorati

Era stata esplorata una policy in cui un alias esterno con basename `<name>` veniva accettato quando esisteva:

```text
$RumiAI_BIN_DIR/<name>
```

che canonicalizzava allo stesso `RumiAI_BOOTSTRAP_BIN`.

Questo permetteva, per esempio:

```text
/usr/local/bin/log -> /opt/rumiai/rumiai-os
```

ma non un alias rinominato `my-log` senza ulteriore mapping. Questo limite ha contribuito alla revisione del modello.

## Bootstrap preferences e status

Durante questa esplorazione sono rimaste valide e sono state conservate nelle decisioni successive le parti indipendenti dal multicall:

```text
conf/bootstrap/language
conf/bootstrap/text-encoding
```

con fallback di lingua e UTF-8 già definiti.

È stata inoltre accettata la rinumerazione pre-stability degli errori condivisi della phase 0:

```text
1  PATH resolution failure
2  realpath/canonicalization failure
3  invalid bootstrap binary
4  invalid/inaccessible RumiAI root
```

La regola append-only dei codici di errore resta valida; i codici `7..9` che erano specifici del dispatcher multicall non devono essere considerati assegnazioni canoniche del nuovo modello.

## Nuovo modello

Il modello corrente usa command file direttamente interpretabili da RumiAI:

```text
#!/usr/bin/env rumiai-os
```

Il command file contiene la propria implementazione POSIX shell e viene sourced da `rumiai-os` dopo il bootstrap. Non è più necessario `cmd/` né un symlink multicall interno.
