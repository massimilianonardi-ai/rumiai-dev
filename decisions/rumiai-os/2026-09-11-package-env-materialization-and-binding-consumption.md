# Decisione — Materializzazione package `env` e consumo dei resolved binding al launch

Date: 2026-09-11  
Status: **Accepted**

## Contesto e autorità

K2 ha completato e validato fisicamente:

```text
facility
provider index
dependency
resolved binding
provider-reference protection
```

Il normale launch continua a non effettuare resolution. La decisione `2026-09-07-package-facility-dependency-and-provider-index.md` ha già fissato `<package-version>/env` come sede naturale per trasformare un `binding/<facility>` nella configurazione runtime richiesta dal consumer, mentre `2026-09-06-package-env-shell-source.md` ha fissato `env` come frammento POSIX shell version-specific sourced dal launcher.

Il prodotto corrente materializza già `root/`, `cmd/`, `link/`, `facility`, `dependency` e `binding/`, ma non materializza ancora il package-local `env` proveniente dalla range definition.

L'utente ha approvato esplicitamente il 2026-09-11 la chiusura di questo gap e ha autorizzato la prosecuzione autonoma dell'implementazione, inclusi `rumiai-os` e i test permanenti, entro questo scope.

Questa decisione non assegna un nuovo nome di fase al package manager e non riapre K2.

---

## 1. Scope

Questa unità completa esclusivamente il percorso:

```text
package range env
    -> pkg integration
    -> <concrete>/env
    -> launcher
    -> consume binding/<facility>
    -> upstream execution
```

Non introduce:

```text
nuovo comando pubblico
nuovo resolver
re-resolution automatica
auto-install delle dependency
reverse reference index
State Instance
var/ state routing
state migration
default/ lifecycle
nuova environment variable RumiAI
```

---

## 2. Package range `env`

Una range definition può contenere opzionalmente:

```text
env
```

come file package-local version-specific.

Il source catalogo deve essere:

```text
regular file
non symbolic link
readable
non executable
POSIX shell syntax valida
```

L'assenza del file resta valida e non materializza `<concrete>/env`.

`env` non ha shebang obbligatorio e non viene eseguito come programma autonomo. Il requisito `non executable` riguarda la forma canonica del source/materialized package file e non cambia la semantica già fissata secondo cui il launcher lo applica con il dot command POSIX `.`.

---

## 3. Validazione install-time

`pkg_integrate` valida il package `env` come parte della validazione completa della range definition e quindi prima di qualsiasi mutazione della concrete integration.

Se `env` è presente, la validazione deve verificare almeno:

```text
regular/readable/non-symlink/non-executable
sh -n riuscito
```

La validazione è esclusivamente sintattica e strutturale.

Durante l'integrazione il file non viene:

```text
sourced
eseguito
eval
interpretato semanticamente
templated
riscritto
```

Un `env` sintatticamente valido può comunque fallire quando viene sourced al launch per condizioni runtime; tale failure resta responsabilità del contratto del launcher già fissato.

---

## 4. Failure prima della mutazione

Un package `env` invalido è un errore semantico/operativo della package definition e produce status:

```text
1
```

La failure avviene durante il preflight della definition, prima di:

```text
creazione della concrete package directory
consumo/spostamento della useful root
materializzazione di cmd/link/facility/dependency/binding/env
provider admission
```

La useful root del caller resta quindi disponibile quando la failure è determinabile dal package `env` prima della mutazione.

Una entry di range realmente sconosciuta continua invece a rappresentare feature non supportata e mantiene status `2` secondo il contratto esistente.

---

## 5. Materializzazione

Dopo che definition e dependency set hanno superato il preflight, un `env` presente viene copiato byte-per-byte in:

```text
<concrete>/env
```

Il file materializzato resta:

```text
regular
non symbolic link
non executable
```

Non viene effettuata sostituzione di pathname, provider identity, facility name o altre informazioni.

In particolare il resolved provider continua a essere autoritativo in:

```text
<concrete>/binding/<facility>
```

mentre `env` contiene soltanto la logica package-specific necessaria a consumarlo.

---

## 6. Ordine rispetto a dependency e provider admission

La dependency resolution completa resta preflight e precede qualsiasi mutazione, come già fissato da K2.

Durante la materializzazione, `env` appartiene agli oggetti package-local che devono essere completati prima dell'ammissione del nuovo package nel provider index.

Il requisito fondamentale resta:

```text
provider marker publication
    only after complete concrete package materialization
```

Se la copia/materializzazione di `env` fallisce dopo l'inizio della concrete integration, il rollback per-package deve rimuovere anche l'eventuale `<concrete>/env` e ripristinare la useful root secondo il lifecycle corrente, senza pubblicare provider marker.

Questa estensione non introduce un transaction engine generale e non modifica i limiti già fissati rispetto a crash, power loss o operazioni concorrenti.

---

## 7. Consumo del resolved binding

Il normale launch continua a seguire il modello già Accepted:

```text
pkg operation
    -> resolve dependency
    -> materialize binding/<facility>

normal launch
    -> source <concrete>/env
    -> env reads binding/<facility> when the package requires it
    -> reconstruct provider path from concrete identity
    -> exec upstream
```

`env` può derivare il concrete package directory da `m_COMMAND_BIN` e leggere il binding package-local senza dipendere dalla current working directory.

Il provider pathname continua a essere ricostruibile come:

```text
$m_ROOT/pkg/<provider-concrete-identity>
```

Non vengono consultati durante il launch:

```text
provider index
compatibility constraints
catalog
pkg command
```

Se un binding richiesto non può essere letto o applicato correttamente, il package `env` fallisce e il launcher non esegue l'upstream, secondo il contratto esistente.

---

## 8. Nessuna modifica al launcher necessaria

Il launcher corrente già:

```text
valida sintatticamente <concrete>/env
source <concrete>/env
source $m_CONF_DIR/<pkg>/env dopo il package env
non usa set -a
esegue infine l'upstream con exec
```

Questa unità non modifica il contratto di `launcher` e non introduce una seconda primitive di launch.

L'implementazione richiesta appartiene al layer di integrazione che materializza il file già consumato dal launcher.

---

## 9. Test permanente

La proprietà deve essere protetta da un test permanente indipendente sotto il gruppo package manager.

Il test deve verificare almeno:

```text
range env opzionale
materializzazione byte-per-byte in <concrete>/env
source catalogo non reso executable
materialized env non executable
env invalido rifiutato con status 1 prima della mutazione
useful root non consumata su env preflight failure
unknown range entry continua a dare status 2
provider facility installata
dependency consumer risolta install-time
binding/<facility> contiene la concrete provider identity selezionata
package env legge il binding attraverso il concrete consumer
normal launch usa il provider risolto senza nuova resolution
upstream osserva l'environment derivato dal binding
```

Il test end-to-end non deve introdurre dipendenze fra test distinti: provider, consumer, launch e cleanup appartengono alla stessa unità autonoma.

---

## 10. Physical validation

La modifica è semantica e richiede physical validation revision-specific secondo `TESTING.md`.

La precedente evidenza K2 resta immutabile ed è valida esclusivamente per:

```text
rumiai-os@096645f9be29b5338379a13061aff71c60a848a2
rumiai-tests@0a337fff671b5f0e38fe89d2b054111627bf03b6
```

Le nuove revisioni prodotto/test dovranno essere validate sui reference host prima di considerare chiusa questa unità.

---

## 11. Invarianti

```text
PKG-ENV-INT-01  range env è opzionale e materializza <concrete>/env
PKG-ENV-INT-02  catalog env è regular, readable, non-symlink e non-executable
PKG-ENV-INT-03  catalog env deve superare sh -n durante il preflight di pkg_integrate
PKG-ENV-INT-04  install-time non source/exec/eval/template env
PKG-ENV-INT-05  env invalido produce status 1 prima di qualsiasi concrete mutation determinabile
PKG-ENV-INT-06  env materializzato è una copia byte-per-byte e resta non-executable
PKG-ENV-INT-07  env materialization deve completarsi prima della provider admission
PKG-ENV-INT-08  rollback della concrete integration comprende env quando applicabile
PKG-ENV-INT-09  resolved binding resta separato da env; env lo consuma senza duplicarne l'identità
PKG-ENV-INT-10  normal launch non effettua provider discovery o dependency resolution
PKG-ENV-INT-11  launcher contract e layering restano invariati
PKG-ENV-INT-12  nessun nuovo comando, resolver, state routing o State Instance viene introdotto
PKG-ENV-INT-13  exit status restano 0 successo, 1 failure semantico/operativa, 2 API invalida/feature realmente unsupported
PKG-ENV-INT-14  Git resta forward-only
```
