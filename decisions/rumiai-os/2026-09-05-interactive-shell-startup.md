# Decisione — Startup della shell interattiva RumiAI

Date: 2026-09-05  
Status: **Accepted**  
Updated: 2026-09-06

## Contesto

Questa decisione consolida il comportamento della funzione `shell` e degli adapter di startup shell sviluppato e ottimizzato nel prodotto fino a:

```text
massimilianonardi-ai/rumiai-os@7b645edf1b5d84c512488b3b69d9f1cd8483061f
```

Questa revisione è considerata la baseline sostanzialmente definitiva del sottosistema. Sono ammesse successive correzioni o semplificazioni che non ne cambino il contratto; una modifica semantica richiede una nuova decisione esplicita.

La successiva decisione Accepted `2026-09-06-system-base-state-namespace.md` ha fissato `$m_ROOT/<area>/sys/<component>/` come namespace state/configurazione dei componenti del sistema base. Di conseguenza i riferimenti canonici alla configurazione del componente `shell` usano ora `$m_ROOT/conf/sys/shell/`. Il prodotto `rumiai-os@7b645edf...` precede questo riallineamento fisico e resta pending realignment per il solo pathname fino alla modifica che l'utente effettuera autonomamente.

Restano invariati POSIX.1-2024 come contratto generale, la selezione `$SHELL` con fallback `sh`, la relocatability e le regole generali definite in `RULES.md`.

## 1. Scopo di `shell`

La funzione:

```text
shell [args...]
```

permette all'utente di avviare la propria shell di sistema inoltrandole argomenti senza dover conoscere o ripetere il nome dell'eseguibile corrente.

La shell target è:

```text
$SHELL se impostata e non vuota
sh altrimenti
```

Gli argomenti ricevuti da `shell` vengono inoltrati alla shell target senza reinterpretazione applicativa da parte di RumiAI.

Opzioni native che modificano modalità o startup della shell mantengono il proprio significato nativo. RumiAI non deve reinterpretarle per simulare una diversa modalità della shell.

## 2. Ambito della startup RumiAI

L'integrazione di startup RumiAI ha come caso principale la shell **interattiva non-login** usata come ambiente di lavoro dell'utente.

Per le shell supportate, nel normale percorso interattivo non-login RumiAI rende disponibili:

```text
environment variables RumiAI
funzioni RumiAI destinate all'ambiente interattivo
prompt RumiAI
m_SHELL_EXT
```

Le shell login seguono il proprio percorso di startup nativo. RumiAI non emula i profile login e non garantisce né forza il caricamento del core o di `m_SHELL_EXT` attraverso quel percorso. Questa scelta evita di sostituire o reinterpretare la semantica login della shell e riduce il rischio di effetti collaterali non evidenti, inclusi quelli di sicurezza.

Le shell non-interattive non caricano `m_SHELL_EXT` tramite il percorso RumiAI.

Le opzioni native che disabilitano i normali startup file, per esempio le rispettive forme `--norc`, `-f` o equivalenti quando previste dalla shell, non vengono contrastate da RumiAI. In tali percorsi il caricamento dell'ambiente interattivo RumiAI non è garantito.

## 3. Shell con adapter specifico

La baseline corrente contiene adapter specifici per:

```text
bash
zsh
sh
dash
ash
```

`sh`, `dash` e `ash` condividono l'adapter POSIX basato su `ENV`.

Le altre shell vengono eseguite direttamente con gli argomenti ricevuti e non hanno una garanzia RumiAI di caricamento del core o di `m_SHELL_EXT`.

In particolare non viene introdotta logica specifica per:

```text
ksh
mksh
```

La loro eventuale presenza sull'host non giustifica complessità aggiuntiva nel bootstrap corrente.

## 4. `m_SHELL_EXT`

`m_SHELL_EXT` è il punto uniforme con cui l'utente può inizializzare il proprio ambiente di lavoro RumiAI indipendentemente dalla shell supportata.

Il file indicato viene sourced, quando è un file leggibile, dopo il caricamento del core e dopo l'impostazione del prompt RumiAI nel percorso interattivo gestito dall'adapter.

`m_SHELL_EXT` non è un sostituto dei normali startup file della shell. Gli startup file nativi dell'utente vengono rispettati secondo il relativo adapter e possono continuare a configurare normalmente la shell.

## 5. Adapter POSIX `sh` / `dash` / `ash`

Prima dell'`exec`, RumiAI salva il valore ereditato di `ENV` in `m_SHELL_ENV` e imposta temporaneamente `ENV` al proprio adapter.

RumiAI **non interpreta** il contenuto di `ENV` e non ne reimplementa parameter expansion, command substitution o altra semantica. Il valore salvato è trattato come pathname letterale; viene sourced soltanto se non vuoto e leggibile.

Dopo lo startup utente, tutti gli alias esistenti vengono intenzionalmente eliminati prima di leggere il core:

```sh
\unalias -a

. "$m_LIB_DIR/sh/core.lib.sh"
```

Questa scelta protegge il parsing del core da alias che potrebbero alterare sia nomi di funzioni sia command word contenute nelle function definition. Gli alias eliminati non vengono serializzati o ricostruiti. Gli alias specifici dell'ambiente RumiAI possono essere definiti in `m_SHELL_EXT`, che viene caricato successivamente.

Le function definition provenienti dall'`ENV` utente restano disponibili salvo i nomi successivamente ridefiniti dal core RumiAI.

## 6. Adapter Bash

L'adapter Bash carica prima la normale `~/.bashrc` dell'utente, quando leggibile.

Per evitare che alias definiti dall'utente interferiscano con il parsing di `core.lib.sh`, l'adapter preserva lo stato di `expand_aliases`, lo disabilita soltanto durante il source del core e poi ripristina lo stato precedente.

La logica Bash-specific resta confinata all'adapter Bash.

Una Bash login segue la propria semantica login; RumiAI non simula manualmente i profile login e non garantisce il proprio rcfile nel percorso login.

## 7. Adapter Zsh e `ZDOTDIR`

L'adapter Zsh usa `ZDOTDIR` come meccanismo nativo di instradamento temporaneo verso i proxy RumiAI.

Lo stato originario di `ZDOTDIR` viene preservato distinguendo esattamente:

```text
variabile unset
variabile impostata a stringa vuota
variabile impostata a un valore non vuoto
```

La presenza o assenza di `m_SHELL_ZDOTDIR` rappresenta rispettivamente lo stato set/unset senza introdurre una seconda variabile di stato.

Il proxy `.zshenv`:

1. ripristina lo stato `ZDOTDIR` dell'utente;
2. carica la `.zshenv` utente appropriata;
3. ricattura un eventuale nuovo stato di `ZDOTDIR` impostato dall'utente;
4. mantiene il proxy RumiAI soltanto se la shell è interattiva;
5. nelle shell non-interattive ripristina lo stato utente e termina il bridge RumiAI.

Per una shell interattiva login, il normale routing Zsh raggiunge il proxy `.zprofile`. Questo carica la `.zprofile` utente, elimina le variabili ponte e consegna il resto dello startup login alla normale semantica Zsh. RumiAI non mantiene proxy `.zlogin` o `.zlogout`.

Per una shell interattiva non-login, il normale routing Zsh raggiunge il proxy `.zshrc`. Questo ripristina e carica la `.zshrc` utente, elimina le variabili ponte, carica il core RumiAI, imposta il prompt e carica `m_SHELL_EXT`.

Un eventuale cambiamento di `ZDOTDIR` effettuato dallo startup utente non viene normalizzato o sovrascritto al termine del proxy.

## 8. Protezione dagli alias e eccezioni shell-specific

Il contratto generale resta POSIX e il codice generico deve continuare a rispettare `POSIX-PLAT-003` in `specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md`.

Sono però approvate, ai sensi dell'eccezione prevista da `RULES.md`, le seguenti dipendenze shell-specific **solo nei rispettivi adapter**:

```text
Bash:
  builtin/shopt per leggere, disabilitare e ripristinare expand_aliases

Zsh:
  [[ -o aliases ]]
  builtin/unsetopt/setopt per leggere, disabilitare e ripristinare ALIASES
```

Ragione tecnica: Bash e Zsh permettono di sospendere temporaneamente l'espansione degli alias mantenendo intatte le definizioni dell'utente. Usare `unalias -a` in questi adapter distruggerebbe inutilmente stato utente che le shell possono invece preservare nativamente.

Queste eccezioni non autorizzano l'uso di sintassi Bash/Zsh nel codice POSIX generale, in particolare nel file bootstrap root `rumiai-os`, in `lib/sh/`, in `conf/sys/shell/sh/` o in altri componenti del core POSIX.

Non istituiscono una nuova regola generale di portabilità.

## 9. Relazione con gli startup file utente

Gli startup file nativi dell'utente mantengono la propria responsabilità. RumiAI usa i meccanismi nativi della shell per inserire il proprio caricamento dove possibile senza emulare l'intera sequenza di startup.

RumiAI non tenta di vincere contro una scelta esplicita dello startup utente che modifica o disabilita il normale hook della shell. In particolare non reinterpreta `ENV`, non emula profile login e non forza il caricamento quando la shell stessa è stata invocata con un'opzione di bypass dello startup.

## 10. Stato di implementazione e test

La baseline implementativa osservata per il comportamento di questa decisione è:

```text
massimilianonardi-ai/rumiai-os@7b645edf1b5d84c512488b3b69d9f1cd8483061f
```

Questa revisione usa ancora fisicamente il precedente pathname `conf/shell/`. Il pathname canonico corrente è `conf/sys/shell/` secondo `2026-09-06-system-base-state-namespace.md`; il prodotto è quindi pending realignment esclusivamente per questa collocazione fisica. L'utente ha richiesto esplicitamente che tale modifica non venga effettuata in questa unità di lavoro.

Questa decisione **non costituisce validazione fisica** della revisione prodotto sopra indicata. Le evidenze fisiche precedenti restano valide soltanto per le revisioni e i contratti effettivamente esercitati all'epoca.

La suite permanente è stata successivamente riallineata al contratto shell corrente nel repository:

```text
massimilianonardi-ai/rumiai-tests@475937a39029c228efbcdd9e9d73300b14b4c5af
```

Questa annotazione documentale non dichiara una nuova sessione di validazione fisica. Dopo il riallineamento del pathname prodotto a `conf/sys/shell/`, i test pertinenti dovranno essere rieseguiti e, se contengono assunzioni fisiche sul precedente pathname, adeguati alla nuova collocazione.

I comportamenti protetti dalla suite shell includono, in modo proporzionato:

```text
selezione $SHELL con fallback sh
inoltro esatto degli argomenti di shell
startup interattivo non-login di bash, zsh, sh, dash e ash
assenza di m_SHELL_EXT nelle shell non-interattive
assenza di garanzia RumiAI nel percorso login
rispetto delle opzioni native di bypass dello startup
ENV salvato e trattato letteralmente, senza reinterpretazione RumiAI
rimozione degli alias nell'adapter sh/dash/ash
preservazione dello stato alias durante il caricamento core in Bash e Zsh
preservazione esatta di ZDOTDIR unset / empty / value
modifiche a ZDOTDIR effettuate dagli startup file utente
fallback diretto per shell senza adapter
```

## 11. Propagazione

Questa decisione chiude l'open item relativo al caricamento cross-shell delle funzioni RumiAI presente nei documenti bootstrap precedenti.

Per il layout state/configurazione dei componenti del sistema base, l'autorità corrente è:

```text
decisions/rumiai-os/2026-09-06-system-base-state-namespace.md
```

I documenti attivi devono riferirsi a questa decisione per il namespace `sys/`; gli handoff e le evidenze storiche non vengono riscritti e restano riferiti alle revisioni e ai pathname che documentavano.

Questa unità di lavoro documentale non modifica `rumiai-os` né `rumiai-tests`.
