# Piano corrente — dopo implementazione package `env` e binding consumption

Date: 2026-09-11  
Status: **Current checkpoint — physical validation pending**

## 1. Stato corrente

La precedente baseline K2 resta chiusa e fisicamente validata esclusivamente per la coppia revision-specific:

```text
rumiai-os@096645f9be29b5338379a13061aff71c60a848a2
rumiai-tests@0a337fff671b5f0e38fe89d2b054111627bf03b6
selection: rumiai-os/pkg
```

Le relative evidence Ubuntu ARM64 e macOS ARM64 restano immutabili e non validano revisioni successive.

Dopo K2 è stata approvata e implementata una nuova unità di lavoro descrittiva, senza introdurre un nuovo nome di fase:

```text
package env materialization
+
resolved binding consumption at normal launch
```

La decisione autoritativa è:

```text
decisions/rumiai-os/2026-09-11-package-env-materialization-and-binding-consumption.md
```

---

## 2. Revisioni implementate

Prodotto corrente:

```text
rumiai-os@6a7df568551032708b3d7f63056896e8be30365f
```

Commit:

```text
Materialize package env during integration
```

La modifica prodotto rispetto alla baseline K2 interessa esclusivamente:

```text
lib/sh/pkg-integration.lib.sh
```

Test permanenti correnti:

```text
rumiai-tests@90170bc07320d6ce49b7e647554e9a1b6bfb13a6
```

Commit:

```text
Add package env binding launch test
```

La modifica test rispetto alla baseline K2 interessa esclusivamente:

```text
rumiai-validate.conf
tests/rumiai-os/pkg/env.test
```

`rumiai-validate.conf` è pinning su:

```text
rumiai-os-commit  6a7df568551032708b3d7f63056896e8be30365f
selection         rumiai-os/pkg
```

---

## 3. Contratto implementato

`pkg_integrate` supporta ora il package-local opzionale:

```text
range/env
    -> <concrete>/env
```

Il source catalogo deve essere:

```text
regular
non-symlink
readable
non-executable
POSIX shell syntax valida
```

La sintassi viene verificata tramite:

```text
sh -n
```

come parte della validazione completa della definition prima di qualsiasi concrete mutation.

Un `env` invalido produce status `1`; una entry realmente sconosciuta continua a produrre status `2` secondo il contratto esistente.

Durante l'integrazione `env` non viene sourced, eseguito, eval, templated o riscritto. Viene copiato byte-per-byte in `<concrete>/env` e resta non-executable.

La materializzazione di `env` avviene prima della provider admission e l'eventuale rollback per-package comprende anche `<concrete>/env`.

Non sono stati modificati:

```text
pkg-launch.lib.sh
resolver dependency
provider selection policy
pkg CLI
pkg uninstall/default
state routing
State Instance
```

---

## 4. End-to-end dependency consumption

Il nuovo test permanente:

```text
tests/rumiai-os/pkg/env.test
```

protegge il percorso:

```text
provider facility
    -> consumer dependency
    -> install-time resolution
    -> binding/<facility>
    -> package env
    -> launcher
    -> upstream consumer/provider execution
```

Il test verifica in particolare che:

```text
binding/java contiene la concrete provider identity risolta
package env deriva il consumer concrete directory da m_COMMAND_BIN
package env legge binding/java
JAVA_HOME/PATH vengono derivati dal provider concreto
package env non viene eseguito durante pkg_integrate
package env viene sourced al normal launch
provider index può essere rimosso dal fixture prima del launch senza impedire l'esecuzione
```

L'ultimo punto protegge esplicitamente l'invariante:

```text
normal launch != dependency resolution
```

Il test verifica inoltre il rifiuto pre-mutation di package `env`:

```text
sintatticamente invalido
executable
symlink
```

---

## 5. Suite selezionata

La selection:

```text
rumiai-os/pkg
```

contiene ora otto test permanenti:

```text
catalog-snapshot.test
default.test
dependency.test
env.test
facility.test
install.test
uninstall.test
versions.test
```

Il nuovo `env.test` è executable `100755`.

La libreria prodotto modificata resta non-executable `100644`.

`rumiai-validate.conf` resta `100644`.

---

## 6. Check proporzionati già eseguiti

Prima della promozione a `main` sono stati eseguiti controlli locali proporzionati sulla nuova logica interna:

```text
sh syntax
dash syntax
bash --posix syntax
valid env accepted
env copied byte-for-byte
materialized env non-executable
invalid POSIX shell syntax rejected
executable env rejected
symlink env rejected
```

Il nuovo permanent test `env.test` è stato inoltre verificato sintatticamente con:

```text
sh -n
dash -n
bash --posix -n
```

Questi check non equivalgono a una development run o physical validation completa del repository.

Non era disponibile un reference host completo nell'ambiente di implementazione per eseguire `rumiai-validate` end-to-end.

---

## 7. Consistency gate finale dell'implementazione

Il diff prodotto è stato riletto e contiene esclusivamente la responsabilità approvata di validazione/materializzazione package `env` e relativi rollback.

Il diff test contiene esclusivamente il nuovo permanent test e l'aggiornamento del pin di validation.

I mode finali sono coerenti con il contratto:

```text
rumiai-os/lib/sh/pkg-integration.lib.sh  100644
tests/rumiai-os/pkg/env.test             100755
rumiai-validate.conf                     100644
```

La scansione dell'area interessata non ha rilevato semantiche correnti residue che continuino a classificare `env` come feature unsupported.

Non sono stati introdotti termini o primitive di prodotto non fissati, né un nome arbitrario per la fase successiva.

Git è rimasto forward-only; `main` di prodotto e test è stato aggiornato tramite fast-forward senza force.

---

## 8. Gate ancora aperto: physical validation

Questa unità **non è ancora chiusa**.

La coppia esatta da validare è:

```text
rumiai-os@6a7df568551032708b3d7f63056896e8be30365f
rumiai-tests@90170bc07320d6ce49b7e647554e9a1b6bfb13a6
selection: rumiai-os/pkg
expected selected tests: 8
```

La physical validation revision-specific deve essere eseguita almeno sui reference host correnti:

```text
Ubuntu ARM64
macOS ARM64
```

tramite:

```sh
./rumiai-validate
```

L'unità può essere considerata chiusa soltanto dopo esito positivo su entrambi gli host e pubblicazione delle relative evidence revision-specific secondo `TESTING.md`.

L'evidenza K2 precedente non deve essere reinterpretata come evidence di questa coppia.

---

## 9. Prossimo tema dopo il gate

Dopo la physical validation, il prossimo gap architetturale utile resta il baseline dello state package già previsto dalle decisioni Accepted:

```text
state non qualificato sotto $m_ROOT/<area>/<pkg>/
var/<area> come routing package-local
root/<path> -> var/<area>/<path> per pathname upstream state-bearing
```

Prima dell'implementazione devono però essere chiusi i punti ancora realmente aperti, in particolare:

```text
serializzazione del mapping <root-relative-path> -> <state-area>
validazione dei mapping e degli overlap
inizializzazione del contenuto state-bearing
relazione con default/ senza perdita dei contenuti upstream sostituiti
rollback/lifecycle proporzionato
```

Non è autorizzata implicitamente in questo checkpoint l'implementazione di:

```text
State Instance nominate
state migration
state compatibility framework
per-invocation state switching
transaction/recovery engine generale
```

Nessun nome di nuova fase viene fissato da questo checkpoint.

---

## 10. Invarianti di continuità

```text
PKG-ENV-CP-01  K2 evidence resta immutabile e revision-specific
PKG-ENV-CP-02  current product revision = 6a7df568551032708b3d7f63056896e8be30365f
PKG-ENV-CP-03  current permanent-test revision = 90170bc07320d6ce49b7e647554e9a1b6bfb13a6
PKG-ENV-CP-04  validation selection = rumiai-os/pkg con 8 test attesi
PKG-ENV-CP-05  physical validation Ubuntu ARM64 + macOS ARM64 è ancora pending
PKG-ENV-CP-06  package env materialization non modifica launcher o dependency resolver
PKG-ENV-CP-07  normal launch consuma resolved binding e non esegue resolution
PKG-ENV-CP-08  state/var resta il prossimo tema di pianificazione, non una implementazione già autorizzata da questo checkpoint
PKG-ENV-CP-09  State Instance e migration restano fuori scope
PKG-ENV-CP-10  nessun nuovo nome di fase è stato introdotto
PKG-ENV-CP-11  Git resta forward-only
```
