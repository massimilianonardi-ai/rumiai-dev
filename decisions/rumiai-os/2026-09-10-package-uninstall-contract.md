# Decisione — Lifecycle locale `pkg uninstall`

Date: 2026-09-10  
Status: **Accepted**

## Contesto

La CLI package corrente ha già fissato:

```text
pkg install <package> [<package> ...]
pkg uninstall <package> [<package> ...]
```

con operand nelle forme:

```text
<pkg>
<pkg>@<version>
<pkg>!<osarch>
<pkg>@<version>!<osarch>
```

`pkg uninstall` è già fissato come operazione local-only. Non consulta `pkg-catalog`, non interroga repository upstream e non interpreta l'assenza della versione come `latest` remoto.

Il layer di integrazione espone già:

```text
pkg_deintegrate <pkg> <version> [<osarch>]
pkg_default <pkg> <version-or-empty> [<osarch>]
```

con responsabilità distinte: `pkg_deintegrate` rimuove availability di una concrete version non-current, mentre `pkg_default` è l'unico layer corrente che modifica selector current e binding pubblici.

Questa decisione chiude la prima parte concreta della fase lifecycle corrente senza introdurre nuovi nomi pubblici per le operazioni ancora indicate soltanto dal label di piano `version/current`.

Il precedente draft `drafts/rumiai-os/package-manager-lifecycle-v0` resta materiale storico superseded e non viene riattivato: non vengono reintrodotti generations, profiles, inventory, recovery framework o transaction graph.

---

## 1. Responsabilità pubblica

`pkg uninstall` rimuove una concrete package version già materializzata localmente.

Il flusso baseline è:

```text
parse/prevalidate all operands
-> resolve each operand only against local package state
-> if selected concrete version is current: pkg_default ... '' ...
-> pkg_deintegrate selected concrete version
```

Non viene introdotta una seconda primitive di rimozione fisica: la rimozione della concrete version resta responsabilità di `pkg_deintegrate`.

La nuova orchestrazione pubblica può essere esposta internamente come:

```text
pkg_uninstall <package> [<package> ...]
```

in una libreria dedicata coerente con `pkg_install`, perché questa responsabilità — parsing CLI multi-operand, local resolution e coordinamento `pkg_default`/`pkg_deintegrate` — non è coperta dalle primitive di integrazione esistenti.

---

## 2. Nessun accesso remoto

Per l'intera invocazione `pkg uninstall` non deve:

```text
refreshare pkg-catalog
leggere package definition dal catalogo
interrogare repository upstream
risolvere latest upstream
scaricare artifact
estrarre artifact
```

La source of truth dell'operazione è esclusivamente il package store locale sotto:

```text
$m_PKG_DIR
```

insieme ai selector current e ai binding già materializzati dal package layer.

---

## 3. Selezione della classe generic/target-specific

Le classi restano quelle già fissate:

```text
generic
    concrete  <pkg>@<version>
    selector  <pkg>

target-specific
    concrete  <pkg>@<version>!<osarch>
    selector  <pkg>!<osarch>
```

Se l'operand contiene `!<osarch>`, l'operazione riguarda esclusivamente quella classe target-specific.

Non esiste fallback verso una concrete identity generic per un operand che contiene `!<osarch>`: la generic identity non appartiene a quel target e non deve essere rimossa per approssimazione.

Se l'operand non contiene `!<osarch>`, `pkg uninstall` risolve la classe localmente con la stessa precedenza semantica del normale runtime del target corrente:

```text
1  classe target-specific del corrente $m_OSARCH, se localmente presente
2  altrimenti classe generic, se localmente presente
3  altrimenti failure
```

Una classe è localmente presente quando esiste il relativo selector oppure almeno una concrete identity appartenente a quella classe.

Se la struttura osservata per la classe prioritaria è malformata, l'operazione fallisce e non ripiega silenziosamente sulla classe generic.

Questa regola non consulta il catalogo e non tenta di ricostruire quale stream remoto produsse una installazione storica.

---

## 4. Operand con versione esplicita

Per:

```text
<pkg>@<version>
<pkg>@<version>!<osarch>
```

la versione richiesta identifica esattamente la concrete version da rimuovere all'interno della classe risolta.

Non vengono applicati:

```text
SemVer
ordinamento release
range resolution
alias latest
fallback verso una versione differente
```

Se la concrete identity esatta non è disponibile localmente nella classe risolta, l'operazione fallisce.

---

## 5. Operand senza versione

L'assenza di `@<version>` ha semantica esclusivamente locale.

Dopo aver risolto la classe generic/target-specific:

```text
se esiste un current valido
    -> rimuove la concrete version selezionata da current

se current è assente e esiste esattamente una concrete version disponibile
    -> rimuove quella concrete version

se current è assente e non esistono concrete version
    -> failure

se current è assente e esistono più concrete version
    -> failure per ambiguità
```

Questa regola rende utile il caso normale immediatamente successivo a `pkg install`, che materializza availability ma non crea automaticamente current, senza introdurre una scelta arbitraria quando più versioni locali convivono.

L'ordine lessicografico o filesystem delle versioni non viene mai usato per scegliere implicitamente quale rimuovere.

---

## 6. Rimozione della concrete version current

Se la concrete version selezionata da `uninstall` è current, l'orchestrazione pubblica deve prima rimuovere il default della stessa classe tramite la primitive esistente:

```text
pkg_default <pkg> '' [<osarch>]
```

poi invocare:

```text
pkg_deintegrate <pkg> <version> [<osarch>]
```

Quindi l'uninstall della current:

```text
rimuove i binding pubblici appartenenti al current
rimuove il selector current
rimuove la concrete version selezionata
non seleziona automaticamente un'altra versione disponibile
```

Non viene introdotta una policy implicita "previous", "latest local" o equivalente.

Se `pkg_default` fallisce, la concrete version non viene deintegrata.

Se la successiva `pkg_deintegrate` fallisce dopo la rimozione riuscita del current, il baseline non promette rollback automatico del selector: resta valido il failure model corrente, che non garantisce atomicità rispetto a errori operativi/crash e non introduce per questo un transaction framework generale.

---

## 7. State

`pkg uninstall` non è `purge`.

La rimozione continua a usare `pkg_deintegrate`; pertanto non elimina automaticamente state del package sotto semantic roots quali:

```text
conf
data
home
cache
log
run
tmp
```

quando tali aree esistono.

Una futura operazione distruttiva di purge richiede un contratto separato e non viene introdotta da questa decisione.

---

## 8. Invocazione multi-package

Come `pkg install`, `pkg uninstall` pre-valida lessicalmente tutti gli operand prima di iniziare mutazioni.

Dopo la prevalidazione gli operand sono elaborati in ordine, uno alla volta.

Il baseline è:

```text
successo operand precedente -> resta acquisito
failure operand corrente    -> stop immediato
operand successivi           -> non eseguiti
nessun rollback globale
```

Non viene introdotta atomicità multi-package.

---

## 9. Exit status

Il contratto pubblico resta coerente con `pkg install` e con il package layer corrente:

```text
0  successo dell'intera invocazione
1  errore semantico/operativo durante local resolution, default removal o deintegration
2  invocazione o operand lessicalmente invalido
```

Un eventuale status `2` di una primitive interna dopo la prevalidazione non viene esposto come nuova classe semantica dell'operand già accettato: una failure del lower layer durante l'operazione viene trattata come failure operativa pubblica status `1`.

---

## 10. Portabilità e filesystem

L'implementazione resta POSIX.1-2024 / Issue 8 e usa esclusivamente il layout package già fissato.

Non vengono introdotti:

```text
uname/platform branch
SemVer parser
indice locale aggiuntivo
metadata di installazione duplicati
cache di versioni installate
generations
lock globale package
```

La local resolution osserva direttamente gli oggetti autorevoli già presenti sotto `$m_PKG_DIR`.

Un oggetto che occupa il pathname di un selector o di una concrete identity attesa con type/shape incompatibile è corruption/failure; non viene ignorato per cercare un fallback più conveniente.

---

## 11. Confine della fase `version/current`

Questa decisione non introduce automaticamente sottocomandi pubblici chiamati:

```text
pkg version
pkg versions
pkg current
pkg default
```

Il label operativo `lifecycle uninstall/version/current` non è autorità sufficiente per promuovere uno di questi nomi a CLI di prodotto.

Le primitive interne `pkg_default` e i selector current esistenti restano normative per la responsabilità già implementata. La scelta della futura CLI di osservazione/selezione locale richiede una decisione esplicita separata o una denominazione fissata dall'utente.

---

## 12. Test permanenti richiesti

Il test permanente di `pkg uninstall` deve proteggere almeno:

```text
subcommand pubblico presente e argomenti mancanti -> 2
quattro forme lessicali operand
prevalidazione di tutti gli operand prima di mutare
assenza di accesso a catalog/upstream
classe target-specific esplicita senza fallback generic
precedenza target-specific del $m_OSARCH quando osarch è omesso
nessun fallback generic se la classe target-specific prioritaria è malformata
versione esplicita esatta
versione omessa -> current quando presente
versione omessa -> singola availability quando current assente
versione omessa + più availability + nessun current -> failure
uninstall della current -> pkg_default remove -> pkg_deintegrate
nessuna selezione automatica di una versione residua
preservazione delle versioni non selezionate
preservazione dello state esterno al concrete package
stop-on-first-failure senza rollback globale
status 0/1/2
```

La nuova revisione prodotto/test richiede physical validation revision-specific proporzionata sui reference host ARM64 prima di essere dichiarata validata.

---

## 13. Invarianti

```text
PKG-UNINSTALL-01  pkg uninstall resta local-only e non consulta catalog/upstream
PKG-UNINSTALL-02  l'operand usa esclusivamente la grammatica package già fissata
PKG-UNINSTALL-03  !<osarch> seleziona esclusivamente la classe target-specific indicata, senza fallback generic
PKG-UNINSTALL-04  senza !<osarch> la classe current-target ha precedenza locale sulla generic
PKG-UNINSTALL-05  corruption della classe prioritaria produce failure e non fallback
PKG-UNINSTALL-06  versione esplicita identifica esattamente una concrete version locale
PKG-UNINSTALL-07  senza versione si usa current; se assente è ammessa solo una singola availability non ambigua
PKG-UNINSTALL-08  più availability senza current non vengono ordinate o selezionate implicitamente
PKG-UNINSTALL-09  uninstall della current usa pkg_default per rimuovere selector/binding prima di pkg_deintegrate
PKG-UNINSTALL-10  dopo rimozione della current non viene scelto automaticamente un nuovo default
PKG-UNINSTALL-11  uninstall non elimina state esterno alla concrete version
PKG-UNINSTALL-12  multi-package è sequenziale, stop-on-first-failure e senza rollback globale
PKG-UNINSTALL-13  tutti gli operand sono prevalidati prima della prima mutazione
PKG-UNINSTALL-14  status pubblico = 0 success, 1 semantic/operational failure, 2 invalid invocation/operand
PKG-UNINSTALL-15  non vengono reintrodotti SemVer, generations, inventory, resolver universale o transaction framework
PKG-UNINSTALL-16  nessun nuovo nome pubblico version/current viene inferito dal label del piano
```
