# Analisi — Risoluzione fisica dell'entrypoint e di `RUMIAI_ROOT`

Date: 2026-08-27  
Status: **Completed analysis**

## 1. Obiettivo

Definire la soluzione più semplice e robusta, compatibile con la baseline **POSIX.1-2024 / The Open Group Base Specifications Issue 8**, per determinare:

- il pathname fisico/canonicalizzato dell'entrypoint `rumiai-os`;
- `RUMIAI_ROOT` come directory fisica/canonicalizzata che contiene l'entrypoint reale;
- il corretto comportamento per invocazione diretta, tramite `PATH` e tramite symbolic link;
- fallimento per link circolari, link dangling e root non accessibile.

Vincolo esplicito:

```sh
cd -- "$RUMIAI_ROOT"
```

deve poter riuscire dopo il bootstrap.

---

## 2. Primitive POSIX rilevanti

### `command -v`

Quando `$0` non contiene `/`, l'invocazione è command-name based e deve essere risolta attraverso `PATH`.

POSIX Issue 8 definisce `command -v` come meccanismo per determinare come una command name verrà risolta. Per una utility eseguibile trovata tramite `PATH`, l'output è un pathname utilizzabile per identificarla.

Uso scelto:

```sh
command -v -- "$0"
```

`--` è usato perché `command` segue le Utility Syntax Guidelines e l'argomento command name è un operando.

### `realpath`

POSIX.1-2024 / Issue 8 standardizza la utility `realpath`.

Questa è la semplificazione decisiva rispetto al codice storico: non è necessario costruire in shell un resolver ricorsivo di symbolic link o interpretare l'output di `ls -l`.

Per un pathname esistente, `realpath` produce il pathname assoluto canonicalizzato risultante dalla pathname resolution fisica, eliminando symbolic link, componenti `.` e `..` e slash ridondanti.

Uso scelto:

```sh
realpath -- "$RUMIAI_ENTRY"
```

Non viene usato `realpath -e` nel bootstrap corrente. Issue 8 definisce `-e`, ma la utility `realpath` presente nel macOS corrente documenta una CLI più piccola e non espone `-e`/`-E` nel proprio synopsis. Il requisito RumiAI è comunque più stretto: l'entrypoint deve già esistere. Per tale dominio, la canonicalizzazione normale è sufficiente; un controllo successivo `[ -f "$RUMIAI_ENTRY" ]` rende esplicita l'esistenza richiesta.

Questa scelta evita di dipendere da un'opzione Issue 8 non ancora uniformemente esposta dagli host di riferimento senza rinunciare alla semantica necessaria.

### pathname resolution e symbolic-link loops

La pathname resolution POSIX deve fallire quando viene rilevato un loop di symbolic link. RumiAI non deve implementare un proprio contatore di link se delega la risoluzione alla facility standard del sistema.

Un loop è quindi un errore del bootstrap.

### `cd`

Dopo aver derivato `RUMIAI_ROOT`, il bootstrap verifica realmente l'invariante richiesto:

```sh
(cd -- "$RUMIAI_ROOT")
```

La subshell impedisce che il bootstrap alteri la current working directory del processo principale.

Il successo costituisce prova runtime che la root risolta è una directory esistente e attraversabile nel contesto corrente.

---

## 3. Algoritmo candidato consolidato

### Passo 1 — interpretare `$0`

Se `$0` contiene `/`, è già un pathname di invocazione:

```sh
case $0 in
  */*) RUMIAI_ENTRY=$0 ;;
  *)   ... ;;
esac
```

Se non contiene `/`, risolverlo attraverso `PATH`:

```sh
RUMIAI_ENTRY=$(command -v -- "$0")
```

La cattura reale usa il protocollo sentinel descritto più avanti per non perdere newline terminali appartenenti al pathname.

### Passo 2 — canonicalizzare una sola volta

Il pathname ottenuto viene passato direttamente a:

```sh
realpath -- "$RUMIAI_ENTRY"
```

Non è necessario trasformare prima un pathname relativo in assoluto tramite `pwd -P`: `realpath` svolge già questa funzione e produce il pathname fisico assoluto finale.

Questa rimozione riduce il numero di primitive e gli stati intermedi del bootstrap.

### Passo 3 — verificare l'entrypoint finale

Il risultato deve essere un regular file esistente:

```sh
[ -f "$RUMIAI_ENTRY" ]
```

`test`/`[` non riceve `--`: questa utility è una delle eccezioni POSIX che non segue Guideline 10 per tale sintassi.

### Passo 4 — derivare `RUMIAI_ROOT`

Dato che `RUMIAI_ENTRY` è ormai un pathname assoluto canonicalizzato di un regular file:

```sh
RUMIAI_ROOT=${RUMIAI_ENTRY%/*}
[ -n "$RUMIAI_ROOT" ] || RUMIAI_ROOT=/
```

L'unico caso in cui la rimozione del componente finale produce stringa vuota è un entrypoint direttamente sotto `/`; viene quindi normalizzato a `/`.

### Passo 5 — verificare l'invariante della root

```sh
(cd -- "$RUMIAI_ROOT")
```

Se fallisce, il bootstrap fallisce.

### Passo 6 — esportare lo stato fondamentale

Solo dopo tutti i controlli:

```sh
export RUMIAI_ENTRY RUMIAI_ROOT
```

---

## 4. `dirname` vs parameter expansion

Sono state confrontate entrambe le strategie richieste.

### `dirname`

`dirname` è una utility POSIX valida e definisce una trasformazione lessicale generale su pathname. Tuttavia il suo contratto deve coprire casi molto più ampi del dominio di questo bootstrap, e alcuni risultati sui pathname limite non sono intuitivi se letti come semplice "rimuovi il basename".

Inoltre richiede:

- un processo/utility esterna;
- output testuale;
- command substitution per riportare il risultato nella shell;
- gestione dei newline terminali se si vuole conservare integralmente il pathname.

### `${RUMIAI_ENTRY%/*}`

Dopo `realpath`, il dominio è già ristretto e noto:

- pathname assoluto;
- canonicalizzato;
- entrypoint regular file;
- nessun slash finale dell'entrypoint.

In questo dominio la parameter expansion:

```sh
${RUMIAI_ENTRY%/*}
```

ha esattamente l'operazione necessaria e non introduce processi o serializzazione testuale.

### Decisione

Per il bootstrap viene scelta **parameter expansion**, non `dirname`.

Analogamente, qualora servisse il nome del file finale, il pattern preferito nello stesso dominio è:

```sh
${RUMIAI_ENTRY##*/}
```

`dirname` e `basename` restano utility perfettamente legittime quando il problema richiede la loro semantica generale; non vengono vietate globalmente.

---

## 5. Audit del codice storico `massimilianonardi/m`

### `cmd/lib/realpaths.lib.sh`

Il resolver storico contiene buone intuizioni:

- `cd -P` per ottenere directory fisiche;
- `${0%/*}` e `${THIS_PATH##*/}`;
- tentativo di non dipendere da GNU `readlink -f`.

Ma la risoluzione del link è ottenuta attraverso:

```sh
ls -ld -- "$0"
```

seguito dal parsing del testo ` -> `.

Questo approccio non è più giustificato con Issue 8:

- interpreta output pensato per rappresentazione umana;
- gestisce direttamente solo il link osservato in `$0`;
- richiede logica aggiuntiva per catene, target relativi, componenti intermedi e loop;
- duplica una funzione ora standardizzata da `realpath`.

### `var/#_os/m/bin/m.lib`

Il pattern:

```sh
THIS_DIR_REAL="$(cd -P -- "${0%/*}"; pwd -P)"
THIS_NAME="${0##*/}"
```

conferma il valore delle parameter expansion per separare componente directory/nome, ma non risolve da solo:

- `$0` senza slash per invocazione da `PATH`;
- symbolic link finali;
- catene e loop.

### `var/#_os/m/bin/m-filesystem.lib`

Il codice storico usa anche `dirname` per operazioni filesystem generali e contiene un riferimento commentato a `realpath --relative-to`, opzione GNU-specifica.

Questo conferma che nel progetto storico esistevano esigenze più ampie di manipolazione path, ma tali esigenze non devono essere trascinate nel bootstrap minimo.

### Conclusione dell'audit

Si conserva dal codice storico:

- preferenza per primitive semplici;
- parameter expansion quando il dominio lo consente;
- distinzione fra path logico e fisico.

Non si conserva:

- parsing di `ls -l`;
- resolver di symlink fatto a mano;
- opzioni GNU-specifiche;
- dipendenza da `$0` come se contenesse sempre `/`.

---

## 6. Preservazione dei pathname e command substitution

La command substitution POSIX rimuove i newline finali. Un pathname Unix può contenere newline, compreso un newline come ultimo carattere di un componente.

Il PoC usa un piccolo protocollo sentinel:

```sh
capture_line()
{
  "$@"
  status=$?
  printf -- 'x'
  return "$status"
}
```

Il chiamante rimuove poi:

1. il sentinel `x`;
2. esattamente il newline di terminazione prodotto dalla utility.

In questo modo il PoC non perde automaticamente newline che appartengono al pathname.

Questo meccanismo rimane piccolo e locale al bootstrap; non viene generalizzato prematuramente in una libreria di serializzazione.

---

## 7. Evidenza PoC

PoC aggiornato:

```text
rumiai-dev-PoCs/pocs/003-entrypoint-symlink-resolution/
```

Sessione candidata di consolidamento:

```text
sessions/2026-08-27-linux-local-002/
```

Matrice locale:

```text
dash
bash --posix
busybox sh
```

Casi:

```text
relative
absolute
root-cd
PATH
relative symlink
absolute symlink
symlink chain
symlink in intermediate component
spaces / " -> " text
leading-dash path component
symlink loop -> failure
dangling symlink -> failure
trailing-newline pathname
trailing-newline root cd
```

Risultato locale verificato:

```text
14 pass / 0 fail per shell
42 pass / 0 fail complessivi
```

---

## 8. Limite di certificazione corrente

La strategia è conforme al contratto Issue 8 ed è verificata localmente su più shell indipendenti, ma la sessione corrente non è un'esecuzione runtime sul macOS di riferimento.

La documentazione corrente di macOS mostra una utility `realpath` capace di canonicalizzazione fisica, ma con opzioni CLI non ancora allineate integralmente a Issue 8 (`-e`/`-E` non sono documentate). Per questo il bootstrap non dipende da tali opzioni.

Prima di dichiarare certificazione host completa resta opportuno eseguire lo stesso PoC su:

- macOS di riferimento;
- Ubuntu LTS di riferimento.

Questo non impedisce di consolidare l'algoritmo come design RumiAI: eventuali divergenze runtime verranno trattate secondo la regola di baseline/compatibilità già stabilita.

---

## 9. Conclusione

La soluzione raccomandata è deliberatamente piccola:

```text
$0
 ├─ contiene /  ───────────────┐
 └─ non contiene / -> command -v
                               │
                               ▼
                         realpath
                               │
                               ▼
                    existing regular file
                               │
                               ▼
             ${RUMIAI_ENTRY%/*} (+ / edge case)
                               │
                               ▼
                  cd -- "$RUMIAI_ROOT"
                               │
                               ▼
                  export fundamental state
```

Non serve una portability abstraction aggiuntiva per la risoluzione dei symlink finché **POSIX.1-2024 Issue 8 `realpath`** soddisfa il requisito reale.
