# Piano corrente — dopo implementazione package state / `var`

Date: 2026-09-11  
Status: **Current checkpoint — implementation complete, physical validation pending**

## 1. Autorità della unità

La decisione Accepted che definisce questa unità è:

```text
decisions/rumiai-os/2026-09-11-package-state-var-default-materialization.md
```

La unità implementa esclusivamente il baseline non qualificato:

```text
range/var/<area> metadata dichiarativo
-> factory preservation sotto <concrete>/default/<area>/<path>
-> backing state sotto $m_ROOT/<area>/<pkg>/<path>
-> <concrete>/var/<area> relativo verso lo state
-> root/<path> relativo verso var/<area>/<path>
```

Non viene introdotto un nuovo nome di fase.

---

## 2. Revisione prodotto implementata

Prodotto:

```text
rumiai-os@3bbeefcaf6f25b4b2d22dcb9ff497f0b5b6810e6
```

Parent:

```text
6a7df568551032708b3d7f63056896e8be30365f
```

Commit:

```text
Materialize package state routing
```

Diff rispetto alla revisione precedente:

```text
lib/sh/pkg-integration.lib.sh  modified, +22 / -0
lib/sh/pkg-state.lib.sh        added
```

`pkg-state.lib.sh` è una libreria shell interna `100644`, senza shebang e non executable. Non espone nuovi comandi o API pubbliche; le primitive sono interne `_pkg_state_*` e il lifecycle resta posseduto da `pkg_integrate`.

`pkg-integration.lib.sh`:

```text
source pkg-state.lib.sh
accetta range/var come directory dichiarativa
prevalida il mapping prima delle mutazioni
materializza state/default/var dopo dependency/binding e prima del provider index
rollbacka lo state creato dalla stessa integrazione se una failure successiva impedisce la pubblicazione del provider
```

Dependency resolution, ranking provider, launcher, CLI pubblica e `pkg uninstall` non acquisiscono nuove responsabilità.

---

## 3. Comportamento implementato

Il prodotto implementa il contratto Accepted seguente:

```text
aree ammesse: conf,data,home,cache,log,run,tmp
nessun $m_ROOT/var
state normale: $m_ROOT/<area>/<pkg>/
range/var/<area>: una root-relative pathname per riga, LF finale obbligatorio
pathname assolute, trailing slash, //, . e .. rifiutate
duplicati e overlap ancestor/descendant globali rifiutati
mapped source limitato a regular file o physical directory
source symlink, ancestor symlink e special file rifiutati
state preesistente non-symlink e type-compatible
package sys rifiutato quando materializza package state
command direct-link dentro mapped state rifiutato
factory object conservato sotto default/<area>/<path>
state assente inizializzato dal factory object
state già valido preservato senza overwrite/merge
var/<area> relativo verso ../../../<area>/<pkg>
root/<path> relativo verso var/<area>/<path>
pkg_deintegrate/pkg uninstall non eliminano backing state esterno
```

Il range non acquisisce un top-level `default/` dichiarativo separato in questa unità.

---

## 4. Rollback sincrono

Il rollback proporzionato della singola integrazione distingue:

```text
state preesistente
    -> mai rimosso dal rollback

state object creato dalla stessa integrazione
    -> rimosso se la integrazione fallisce

parent state directory create dalla stessa integrazione
    -> rimosse quando tornano vuote

factory object spostato in default/
    -> ripristinato nel useful root prima di ritirare la concrete integration
```

Una copia state parzialmente fallita viene rimossa prima del rollback.

Il baseline continua a non promettere crash/power-loss recovery, locking generale, generations o transaction framework globale.

---

## 5. Test permanente

Suite:

```text
rumiai-tests@a10d9eb484590d71e2a8424da45cdac9fb722caa
```

Parent:

```text
90170bc07320d6ce49b7e647554e9a1b6bfb13a6
```

Commit:

```text
Add package state routing tests
```

Diff rispetto alla suite precedente:

```text
rumiai-validate.conf              pin prodotto aggiornato
 tests/rumiai-os/pkg/state.test   nuovo test permanente executable
```

Nessuno degli otto test package precedenti è stato modificato.

`state.test` protegge almeno:

```text
assenza di var/default artificiali quando non dichiarati
file e directory state-bearing
pathname con spazi e leading '-'
symlink relativi var e root
catena root -> var -> backing state
factory defaults version-specific
inizializzazione del primo state
preservazione dello state su versione successiva
preservazione dello state su pkg_deintegrate e pkg_uninstall
sette soli nomi area ammessi
shape e LF finale del metadata
path invalidi e record vuoti
duplicati e overlap globali
source/ancestor symlink e special file
direct-link dentro state mapped
namespace sys riservato
state preesistente type-incompatible
semantic root non canonica
rollback dopo failure della provider publication
```

Il file è `100755`. La nuova libreria prodotto è `100644`.

---

## 6. Check locali eseguiti

Prima della promozione del prodotto sono stati eseguiti check proporzionati sotto:

```text
sh
dash
bash --posix
```

sui nuovi/modified shell source e su harness isolati del comportamento `pkg_integrate`, comprendendo first install, update con state preservato, deintegration e rollback dopo failure successiva alla state materialization.

Il permanent test `state.test` è stato verificato sintatticamente con gli interpreti sopra e il blob pubblicato coincide con il contenuto preparato. La sua esecuzione completa revision-specific appartiene al gate di physical validation descritto sotto e non viene anticipata come evidence fisica da questo checkpoint.

---

## 7. Configurazione physical validation

`rumiai-validate.conf` della suite corrente pinna esattamente:

```text
rumiai-os-commit	3bbeefcaf6f25b4b2d22dcb9ff497f0b5b6810e6
selection	rumiai-os/pkg
```

La selection contiene ora esattamente 9 test:

```text
catalog-snapshot.test
default.test
dependency.test
env.test
facility.test
install.test
state.test
uninstall.test
versions.test
```

La coppia da validare è quindi:

```text
rumiai-os@3bbeefcaf6f25b4b2d22dcb9ff497f0b5b6810e6
rumiai-tests@a10d9eb484590d71e2a8424da45cdac9fb722caa
selection rumiai-os/pkg
9 selected tests
```

---

## 8. Physical validation ancora pending

Le evidence precedenti restano valide esclusivamente per le revisioni che esercitavano e non coprono questa implementazione.

La presente unità non deve essere dichiarata fisicamente validata finché la coppia esatta sopra non produce la validation prevista sui due reference host correnti:

```text
Ubuntu ARM64
macOS ARM64
```

con:

```text
9/9 PASS
runner-exit-status 0
```

Il prossimo passo operativo è quindi esclusivamente il gate fisico revision-specific.

---

## 9. Consistency gate finale

Il diff prodotto è limitato ai due file previsti e il diff test al nuovo test + pin.

La scansione del sottosistema non trova nel prodotto attivo:

```text
run-default
$m_ROOT/var
state-instance runtime/persistente operativo
top-level range/default supportato da pkg_integrate
```

DBeaver non è stato modificato e non riceve mapping `var/` artificiali.

Git è rimasto forward-only; `main` di prodotto e suite sono stati avanzati esclusivamente mediante fast-forward senza force update.

---

## 10. Confine successivo

Restano esplicitamente fuori da questa unità:

```text
State Instance nominate operative
state compatibility policy
migration
purge
factory reset CLI
backup/retention
state switch runtime o persistente
transaction/recovery engine generale
range/default dichiarativo indipendente dai mapping var
```

Nessuna di queste funzioni è autorizzata o implicitamente introdotta dal completamento dell'implementazione corrente.

---

## 11. Invarianti di continuità

```text
PKG-STATE-IMPL-01  authoritative decision = 2026-09-11-package-state-var-default-materialization.md
PKG-STATE-IMPL-02  product revision = 3bbeefcaf6f25b4b2d22dcb9ff497f0b5b6810e6
PKG-STATE-IMPL-03  permanent-test revision = a10d9eb484590d71e2a8424da45cdac9fb722caa
PKG-STATE-IMPL-04  selection = rumiai-os/pkg con 9 test
PKG-STATE-IMPL-05  physical validation è pending e non eredita evidence precedenti
PKG-STATE-IMPL-06  state baseline resta non qualificato sotto $m_ROOT/<area>/<pkg>
PKG-STATE-IMPL-07  var/ resta esclusivamente package-local e $m_ROOT/var è vietato
PKG-STATE-IMPL-08  uninstall/deintegrate preservano backing state esterno
PKG-STATE-IMPL-09  State Instance/migration/purge/recovery generale restano fuori scope
PKG-STATE-IMPL-10  nessun nuovo nome di fase è fissato
PKG-STATE-IMPL-11  Git resta forward-only
```
