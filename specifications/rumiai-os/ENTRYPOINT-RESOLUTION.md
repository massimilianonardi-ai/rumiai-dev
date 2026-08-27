# RumiAI OS — Entrypoint Resolution

Status: **Draft — Linux PoC passed, macOS runtime validation pending**  
Date: 2026-08-27

## 1. Scopo

Definire il modo più affidabile e robusto, compatibile con il profilo POSIX adottato, per determinare il pathname fisico reale dell'entrypoint `rumiai-os` e la root del sistema.

Questa specifica riguarda solo la risoluzione dell'entrypoint. Le altre variabili fondamentali dell'host verranno definite separatamente dopo aver stabilizzato questo primo passaggio.

## 2. Semantica della root

`RUMIAI_ROOT` è la directory fisica che contiene il **target finale reale** dell'entrypoint `rumiai-os`.

La posizione del symlink usato per invocare il comando non definisce la root.

Esempio:

```text
/usr/local/bin/rumiai-os -> /opt/rumiai/rumiai-os
```

produce:

```text
RUMIAI_ENTRY=/opt/rumiai/rumiai-os
RUMIAI_ROOT=/opt/rumiai
```

## 3. Primitive usate

La strategia candidata usa soltanto primitive appartenenti al profilo POSIX moderno verificato:

- parameter expansion della shell;
- `command -v`;
- `pwd -P`;
- `realpath`;
- `test` / `[ ... ]`;
- `printf`.

`realpath` è standardizzato da POSIX.1-2024 Issue 8 ed è disponibile sugli host di riferimento correnti Ubuntu LTS e macOS.

## 4. Algoritmo

### 4.1 Determinazione del pathname di invocazione

Se `$0` contiene `/`, esso viene trattato direttamente come pathname di invocazione.

Se `$0` non contiene `/`, l'invocazione è trattata come command lookup tramite `PATH` e viene risolta con:

```text
command -v -- "$0"
```

Il risultato può essere assoluto o relativo a seconda dell'implementazione e del contenuto di `PATH`; il passo successivo non assume che sia già assoluto.

### 4.2 Conversione ad assoluto

Se il pathname è relativo, viene prefissato con la physical current working directory ottenuta tramite:

```text
pwd -P
```

Il pathname passato alla fase di canonicalizzazione è quindi assoluto e non può essere ambiguamente interpretato come opzione della utility successiva.

### 4.3 Canonicalizzazione fisica

Il pathname assoluto viene passato a:

```text
realpath
```

La canonicalizzazione deve risolvere:

- symlink del file finale;
- symlink relativi;
- symlink assoluti;
- catene di symlink;
- symlink nei componenti intermedi;
- `.` e `..`;
- componenti ridondanti del pathname.

Il risultato deve identificare il file reale dell'entrypoint.

### 4.4 Verifica finale

Il pathname canonicalizzato deve riferirsi a un regular file.

Un fallimento nella ricerca tramite `PATH`, nella determinazione della CWD fisica, nella canonicalizzazione o nella verifica del file è un errore di bootstrap e deve terminare con diagnostica su stderr e status non-zero.

### 4.5 Derivazione della root

Poiché `realpath` produce un pathname assoluto canonicalizzato, la root viene derivata tramite POSIX parameter expansion dal pathname finale, evitando un'ulteriore utility esterna.

## 5. Preservazione dei pathname

I pathname POSIX possono contenere newline. La command substitution:

```text
$(...)
```

rimuove tutti i newline finali dall'output, quindi una cattura ingenua di `command -v`, `pwd` o `realpath` può alterare un pathname valido.

Il protocollo candidato deve preservare i newline appartenenti al dato. Il PoC 003 usa la seguente strategia:

1. eseguire la utility;
2. salvare il suo exit status;
3. emettere un sentinel non-newline dopo l'output;
4. effettuare la command substitution;
5. rimuovere il sentinel;
6. rimuovere esattamente un newline, quello prodotto dalla utility come terminatore di linea.

La shell non può rappresentare NUL in una variabile; tale limite rimane quello naturale del dominio dati della POSIX shell.

## 6. Delimitatore `--`

`command` segue le POSIX Utility Syntax Guidelines; la ricerca usa quindi:

```text
command -v -- "$0"
```

Per `realpath`, il PoC passa un pathname già assoluto e quindi non ambiguo rispetto alle opzioni.

L'uso esplicito di `--` con `realpath` verrà abilitato solo dopo validazione runtime sul `realpath` macOS di riferimento, perché il progetto non deve assumere opzioni non verificate soltanto per uniformità estetica.

## 7. Perché non usare il parsing di `ls -ld`

Il repository storico `massimilianonardi/m` contiene più implementazioni che estraggono il target di un symlink dal rendering di `ls -ld`.

L'intuizione architetturale è valida: `$0` può riferirsi a un symlink e il path reale deve essere determinato.

Il parsing di `ls`, tuttavia, non è la soluzione scelta per il nuovo bootstrap perché:

- interpreta il rendering di una utility invece di usare una primitive dedicata;
- un target relativo deve essere reinterpretato rispetto alla directory del link;
- una catena richiede iterazione manuale;
- symlink nei componenti intermedi richiedono ulteriore traversal;
- loop/error handling devono essere implementati manualmente;
- pathname con caratteri particolari aumentano la fragilità del parsing.

`realpath` delega questi problemi alla primitive di canonicalizzazione prevista per questo scopo.

## 8. Casi di test obbligatori

La soluzione non può essere accettata senza test almeno per:

```text
relative pathname
absolute pathname
PATH invocation
relative symlink target
absolute symlink target
symlink chain
symlink in intermediate directory
spaces in pathname
" -> " text in pathname
components beginning with '-'
embedded/trailing newline pathname
```

Devono inoltre essere verificati errori per pathname non risolvibili e condizioni anomale compatibili con il modo in cui l'entrypoint può essere effettivamente eseguito.

## 9. Evidenza corrente

PoC:

```text
rumiai-dev-PoCs/pocs/003-entrypoint-symlink-resolution
```

Sessione:

```text
sessions/2026-08-27-linux-local-001
```

Risultato locale:

```text
dash         10/10
bash --posix 10/10
busybox sh   10/10
```

## 10. Validazione mancante

Prima di promuovere questa specifica da Draft ad Accepted è richiesta almeno una sessione runtime sul macOS stabile di riferimento.

È inoltre opportuno eseguire una sessione sull'Ubuntu LTS di riferimento, anche se la disponibilità di `realpath` è già verificata documentalmente.

## 11. Trust e TOCTOU

La soluzione è necessariamente path-based. Una POSIX shell non dispone di un meccanismo portabile per ottenere il file descriptor del proprio script già aperto dall'interprete e derivarne successivamente il pathname.

Pertanto il bootstrap assume che l'albero contenente l'entrypoint non venga modificato contemporaneamente da un attore non trusted durante la fase di risoluzione.

Questo limite deve essere rivalutato solo se in futuro il bootstrap iniziale viene implementato con una tecnologia capace di offrire primitive più forti senza compromettere la portabilità desiderata.

## 12. Promozione nel prodotto

Questa specifica e il relativo PoC **non autorizzano** modifiche al repository `rumiai-os`.

La promozione richiede il consenso esplicito dell'utente previsto dalle regole di progetto.
