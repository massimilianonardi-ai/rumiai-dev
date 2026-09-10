# Decisione — CLI locale `pkg versions` e `pkg default`

Date: 2026-09-10  
Status: **Accepted**

## Contesto

Il lifecycle package corrente ha già fissato e fisicamente validato:

```text
pkg install
pkg uninstall
availability != default
selector current generic/target-specific
pkg_default come unica primitive che modifica selector current e binding pubblici
```

Il checkpoint corrente lasciava aperto il confine di pianificazione `version/current` senza promuovere automaticamente alcun nome a CLI pubblica.

L'utente ha approvato esplicitamente la seguente chiusura minima del confine J3:

```text
pkg versions
pkg default
```

Non vengono introdotti alias o sottocomandi ulteriori come `pkg version`, `pkg current`, `pkg use` o equivalenti.

---

## 1. Responsabilità pubbliche

`pkg versions` osserva le concrete version disponibili localmente per una singola classe package.

`pkg default` osserva oppure modifica il default persistente della classe selezionata.

Le due responsabilità restano distinte:

```text
pkg versions = availability locale
pkg default  = default persistente
current      = selector interno/concezionale che realizza il default
```

`current` non diventa un sottocomando pubblico.

---

## 2. Forme CLI

### `pkg versions`

Forme ammesse:

```text
pkg versions <pkg>
pkg versions <pkg>!<osarch>
```

La versione non è ammessa nell'operand di `versions`.

### `pkg default`

Query:

```text
pkg default <pkg>
pkg default <pkg>!<osarch>
```

Set:

```text
pkg default <pkg>@<version>
pkg default <pkg>@<version>!<osarch>
```

Rimozione:

```text
pkg default -u <pkg>
pkg default -u <pkg>!<osarch>
```

`-u` non può essere combinato con `@<version>`.

Poiché `pkg default` accetta un'opzione, segue le POSIX Utility Syntax Guidelines e riconosce `--` come terminatore delle option. Sono quindi valide anche forme come:

```text
pkg default -- <pkg>
pkg default -u -- <pkg>
```

L'operand package non può iniziare con `-` secondo la grammatica corrente, quindi `--` non cambia la grammatica dell'identity.

Ogni invocazione `versions` o `default` accetta esattamente un operand package dopo l'eventuale option parsing. Argomenti mancanti, extra, option sconosciute o combinazioni non ammesse producono status `2`.

---

## 3. Grammatica package

Restano normative le componenti già fissate:

```text
<pkg>
<version>
<osarch>
```

con le forme concrete/selector già Accepted:

```text
<pkg>@<version>
<pkg>
<pkg>@<version>!<osarch>
<pkg>!<osarch>
```

La stringa upstream `current` resta una versione valida e non è riservata dalla nuova CLI.

---

## 4. Selezione della classe locale

Entrambi i sottocomandi sono local-only e riusano la stessa precedenza consolidata da `pkg uninstall`.

Se l'operand contiene `!<osarch>`:

```text
si osserva/opera esclusivamente quella classe target-specific
nessun fallback generic
```

Se l'operand omette `!<osarch>`:

```text
1  classe target-specific del corrente $m_OSARCH, se localmente presente
2  altrimenti classe generic, se localmente presente
3  altrimenti nessuna classe locale
```

Una classe è presente quando esiste il selector oppure almeno una concrete identity della classe.

Se la classe prioritaria presenta struttura corrotta o selector non valido, l'operazione fallisce con status `1` e non ripiega sulla generic.

La selezione locale non consulta catalogo, repository upstream o metadata remoti.

---

## 5. `pkg versions`

`pkg versions` emette su stdout una concrete identity completa per riga, appartenente esclusivamente alla classe selezionata.

Esempio target-specific:

```text
dbeaver@26.1.5!macos-arm64
dbeaver@26.2.0!macos-arm64
```

Esempio generic:

```text
tool@1
tool@2
```

L'output non contiene:

```text
marker current/default
header
colonne aggiuntive
sentinel
versioni upstream remote
```

L'ordine di presentazione è lessicografico bytewise nella locale `C` della concrete identity completa. Tale ordine è soltanto una proprietà deterministica di output e **non** introduce ordinamento semantico delle versioni, SemVer o policy latest.

Se nessuna classe locale applicabile esiste, oppure la classe selezionata non contiene concrete version valide, stdout resta vuoto e lo status è `1`.

---

## 6. `pkg default` query

Per:

```text
pkg default <pkg>[!<osarch>]
```

la CLI legge il selector current della classe selezionata.

Se esiste un default valido, stdout contiene esattamente la concrete identity completa seguita da newline, per esempio:

```text
dbeaver@26.2.0!macos-arm64
```

Se la classe esiste ma non possiede default, oppure nessuna classe locale applicabile esiste:

```text
stdout vuoto
status 1
```

Un selector malformato/dangling o una classe strutturalmente corrotta produce status `1`.

La query non modifica filesystem o binding.

---

## 7. `pkg default` set

Per:

```text
pkg default <pkg>@<version>[!<osarch>]
```

la concrete version richiesta deve essere già disponibile nella classe locale selezionata.

Non vengono applicati:

```text
install implicito
catalog refresh
latest
SemVer
fallback verso altra versione
fallback generic dopo selezione di una classe target-specific
```

La mutazione delega esclusivamente alla primitive esistente:

```text
pkg_default <pkg> <version> [<osarch>]
```

che resta unica proprietaria di selector current e binding pubblici.

Se la versione richiesta non è disponibile nella classe selezionata, status `1` e nessuna selezione alternativa.

Un set sullo stesso default già attivo conserva l'idempotenza della primitive esistente.

Il successo non produce output su stdout.

---

## 8. `pkg default -u`

Per:

```text
pkg default -u <pkg>[!<osarch>]
```

la CLI rimuove il default della classe selezionata delegando a:

```text
pkg_default <pkg> '' [<osarch>]
```

La concrete version resta disponibile.

Se una classe locale valida è presente ma non possiede default, l'operazione è idempotente e restituisce `0`.

Se non esiste alcuna classe locale applicabile, la rimozione è ugualmente un no-op idempotente con status `0` e stdout vuoto.

Se invece esiste una struttura rilevante ma corrotta, la corruption non viene mascherata come assenza: status `1`.

Il successo non produce output su stdout.

---

## 9. Confine local-only

Per entrambe le CLI sono vietati:

```text
refresh/lettura di pkg-catalog
GitHub/repository adapter
resolution latest upstream
download/extract
SemVer o ordinamento release
indice locale aggiuntivo
metadata duplicati
```

La source of truth è esclusivamente il package store locale e i selector già materializzati sotto `$m_PKG_DIR`.

---

## 10. Exit status

Il contratto pubblico resta coerente con `pkg install` e `pkg uninstall`:

```text
0  successo
1  stato locale non soddisfacibile/corrotto oppure failure operativa
2  invocazione, option o operand lessicalmente invalido
```

Le query che non trovano il dato richiesto (`versions` senza classe/versioni, `default` senza default) usano status `1` e stdout vuoto; non viene introdotto un sentinel testuale.

---

## 11. Implementazione interna minima

La scansione/risoluzione locale oggi implementata privatamente dentro `pkg-uninstall.lib.sh` acquista con questa decisione più consumer reali.

Il refactoring minimo autorizzato è estrarre in una libreria interna dedicata:

```text
lib/sh/pkg-local.lib.sh
```

soltanto le responsabilità comuni di:

```text
parsing della package identity locale
scansione/validazione di una classe generic o target-specific
selezione della classe locale secondo la precedenza fissata
```

La libreria non diventa un nuovo concetto architetturale pubblico e non introduce un secondo package store.

`pkg-uninstall.lib.sh` deve riusare tali primitive invece di conservarne copie.

Le nuove orchestration library possono essere:

```text
lib/sh/pkg-versions.lib.sh
lib/sh/pkg-default.lib.sh
```

`pkg-default.lib.sh` deve delegare le mutazioni alla primitive `pkg_default` esistente e non replicarne l'implementazione.

Tutte le librerie sotto `lib/sh/` restano `100644`, senza shebang.

---

## 12. Test permanenti

La suite deve proteggere separatamente almeno:

### versions

```text
query generic
target-specific esplicito
precedenza target corrente quando target omesso
nessun fallback dopo corruption target
nessun marker default
concrete identity complete
ordine deterministico C senza SemVer
nessun accesso catalog/upstream
versione nell'operand rifiutata
status 0/1/2
```

### default

```text
query default generic/target-specific
query senza default -> 1 + stdout vuoto
set exact version disponibile
set version assente -> 1 senza fallback
rimozione -u
rimozione default assente idempotente
assenza totale della classe con -u -> 0
selector e binding modificati soltanto tramite semantica pkg_default
precedenza target corrente quando target omesso
nessun fallback dopo corruption target
-- come option terminator
invocazioni/opzioni invalide -> 2
nessun accesso catalog/upstream
```

Il refactoring comune deve continuare a far passare integralmente `pkg uninstall`.

Ogni nuova revisione prodotto/test richiede physical validation revision-specific proporzionata sui reference host ARM64 prima di essere dichiarata validata.

---

## 13. Invarianti

```text
PKG-LOCAL-01  pkg versions e pkg default sono local-only
PKG-LOCAL-02  pkg versions osserva availability e stampa concrete identity complete
PKG-LOCAL-03  pkg default osserva/modifica il default persistente; current resta selector interno/concezionale
PKG-LOCAL-04  pkg_default resta l'unica primitive che muta selector current e binding pubblici
PKG-LOCAL-05  target esplicito non fa fallback generic
PKG-LOCAL-06  target omesso usa precedenza current-$m_OSARCH -> generic
PKG-LOCAL-07  corruption della classe prioritaria produce failure senza fallback
PKG-LOCAL-08  nessun SemVer/latest/catalogo entra nelle operazioni locali
PKG-LOCAL-09  versions produce output C-lexicographic soltanto per determinismo, non per selezione semantica
PKG-LOCAL-10  default query senza default = stdout vuoto + status 1
PKG-LOCAL-11  default set richiede concrete version già disponibile nella classe selezionata
PKG-LOCAL-12  default -u è idempotente anche quando non esiste alcuna classe locale applicabile
PKG-LOCAL-13  nessun sottocomando pkg current/version/use viene introdotto
PKG-LOCAL-14  la scansione locale comune viene estratta senza duplicare package-store semantics
PKG-LOCAL-15  librerie shell nuove restano 100644 senza shebang
PKG-LOCAL-16  semantic change richiede physical validation revision-specific
PKG-LOCAL-17  Git resta forward-only
```
