# RumiAI package manager — State model

Data: 2026-08-30

Stato: **design draft — concetti fissati fino alle runtime mappings**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-v0/README.md
drafts/rumiai-os/package-manager-package-instance-layout/README.md
```

---

# 1. Principio centrale

```text
Package Instance
    !=
State Instance
```

La Package Instance contiene software e default immutabili.

La **State Instance** contiene lo stato mutabile associabile alle versioni compatibili dello stesso package.

Cambiare software version non deve creare, rinominare o cancellare automaticamente lo stato.

---

# 2. Identità della State Instance

Naming fissato:

```text
<pkg-name>[@<platform>-<architecture>]@s<state-compatibility-version>
```

Il segmento:

```text
@<platform>-<architecture>
```

è presente **solo quando lo stato dipende dalla piattaforma e/o dall'architettura**.

Esempi:

```text
pulsar@s3
netbeans@linux-any@s2
foo@linux-arm64@s4
bar@any-arm64@s1
```

Semantica:

```text
pkg-name
    package logico a cui appartiene lo stato

platform / architecture
    execution target dello stato quando necessario

state-compatibility-version
    versione del contratto/schema di compatibilità dello stato
```

La `state-compatibility-version` NON è la software version.

Nel v0 è un intero positivo controllato dal packaging RumiAI:

```text
s1
s2
s3
...
```

---

# 3. Una sola State Instance per identity

Nel v0 non introduciamo state profile nominati come:

```text
default
work
test
```

Esiste una sola State Instance per la combinazione:

```text
pkg-name
+ eventuale platform/architecture
+ state-compatibility-version
```

Questo è coerente con la decisione già fissata che una Package Instance possiede una sola `run/` attiva.

Se in futuro emergerà un requisito reale per più State Instance parallele dello stesso package/schema, l'identità potrà essere estesa allora.

---

# 4. Compatibilità indipendente dalla software version

Esempio:

```text
Pulsar 1.0 supports s3
Pulsar 1.1 supports s3
```

entrambi possono usare:

```text
pulsar@s3
```

senza copiare o rinominare lo stato.

Se invece:

```text
Pulsar 2.0 supports s4
```

il passaggio da:

```text
pulsar@s3
```

a:

```text
pulsar@s4
```

è una **state migration**, non un semplice upgrade della Package Instance.

---

# 5. Qualificazione per piattaforma

Lo stato resta cross-platform quando può essere riutilizzato in sicurezza da Package Instance compatibili su host differenti.

Esempio:

```text
pulsar@s3
```

può essere condiviso da:

```text
pulsar / jvm-any
```

su Linux e macOS se il suo contenuto è realmente indipendente dalla piattaforma.

Quando lo stato dipende dall'OS e/o dalla CPU, l'identità viene qualificata:

```text
foo@linux-any@s2
foo@any-arm64@s2
foo@linux-arm64@s2
```

Token `platform` e `architecture` usano lo stesso vocabolario canonico controllato dal progetto.

Regola conservativa:

> se una parte autorevole della State Instance richiede specializzazione di piattaforma/architettura e non può essere separata in sicurezza, l'intera State Instance viene qualificata.

---

# 6. State areas

Una State Instance è distribuita semanticamente in sette aree RumiAI:

```text
conf
data
home
cache
log
run
tmp
```

Non tutte devono esistere per ogni package.

Fisicamente, il modello candidato è:

```text
conf/<state-id>/
data/<state-id>/
home/<state-id>/
cache/<state-id>/
log/<state-id>/
run/<state-id>/
tmp/<state-id>/
```

Dove `<state-id>` segue la convenzione fissata.

---

# 7. Tre classi semantiche

## 7.1 Persistent authoritative

```text
conf
data
home
```

Queste aree contengono stato che non deve essere eliminato implicitamente.

### `conf`

Configurazione persistente che determina il comportamento dell'applicazione.

### `data`

Dati autorevoli prodotti/gestiti dall'applicazione. Se eliminarli causa una perdita non rigenerabile, appartengono a `data`.

### `home`

Compatibility bucket persistente e conservativo per software che richiede una HOME privata o mescola stato eterogeneo non classificabile meglio.

`home` non è la destinazione preferita: quando possibile, contenuti chiaramente classificabili vanno in `conf`, `data` o `cache`.

Se un contenuto resta in `home`, viene trattato come autorevole per evitare perdita accidentale di dati.

---

## 7.2 Persistent non-authoritative

```text
cache
log
```

Persistono tra le esecuzioni ma non sono necessari per ricostruire lo stato funzionale autorevole.

### `cache`

Contenuti rigenerabili: indici, cache compilate, download cache, thumbnail, ecc.

Può essere eliminata per cleanup/factory reset senza perdita di stato autorevole.

### `log`

Diagnostica e storia operativa non autorevole.

È separata da `cache` perché richiede policy proprie di retention/rotation/purge.

---

## 7.3 Transient runtime state

```text
run
tmp
```

### `run`

Stato di coordinamento valido solo per una runtime attiva:

```text
PID
socket
lock
runtime status
endpoint metadata
```

Stale runtime state può essere ripulito durante activation/recovery.

### `tmp`

Scratch temporaneo senza identità operativa persistente:

```text
temporary downloads
intermediate files
scratch/extraction
```

Distinzione:

```text
run = coordination
tmp = scratch
```

---

# 8. Runtime mappings e writable islands

La Package Instance contiene:

```text
root/
run-default/
@package
run/
```

Le writable islands sotto `root/` puntano in modo relativo alla `run/` package-local.

Esempio:

```text
root/etc       -> ../run/etc
root/workspace -> ../run/workspace
root/logs      -> ../run/logs
root/temp      -> ../run/temp
```

`@package` classifica semanticamente ciascuna writable island:

```text
etc       -> conf
workspace -> data
logs      -> log
temp      -> tmp
```

La `run/` package-local materializza poi i link relativi verso le aree della State Instance attiva:

```text
pkg/<package-id>/run/etc
    -> RUMIAI_ROOT/conf/<state-id>/...

pkg/<package-id>/run/workspace
    -> RUMIAI_ROOT/data/<state-id>/...
```

Il nome/path atteso dal software e la classificazione RumiAI sono quindi concetti distinti.

---

# 9. Una writable island appartiene a una sola state area

Regola fissata:

> ogni writable island dichiarata da `@package` appartiene esattamente a una fra `conf`, `data`, `home`, `cache`, `log`, `run`, `tmp`.

Se una directory upstream mescola contenuti con lifecycle differenti e non può essere separata durante la normalizzazione pre-admission, viene assegnata alla categoria più conservativa compatibile, tipicamente `home` o `data`.

Se neppure questo consente una root fissa e sicura, il package non è ammissibile allo store per quella piattaforma.

---

# 10. `run-default/`

`run-default/` conserva gli analoghi fisici iniziali delle writable islands distribuiti dal vendor o prodotti durante la normalizzazione.

Non deve necessariamente essere organizzato per state area.

Esempio:

```text
run-default/
├── etc/
│   └── settings.ini
└── workspace/
    └── initial.db
```

mentre `@package` dichiara:

```text
etc       -> conf
workspace -> data
```

Questo preserva la view attesa dal software senza imporre nomi RumiAI nel tree normalizzato.

---

# 11. Inizializzazione e factory reset

Una nuova State Instance viene inizializzata materializzando nelle corrette state areas il contenuto pertinente di `run-default/`.

Factory reset è un'operazione esplicita sullo stato, non una reinstallazione del package.

Semantica di default:

```text
conf
    replace from defaults

data
    replace from defaults / empty se non esistono default

home
    replace from defaults / empty se non esistono default

cache
    clear

log
    clear secondo policy

run
    clear

tmp
    clear
```

`run-default/` resta sempre immutabile e non viene mai usato direttamente come destinazione writable.

---

# 12. Upgrade e migration

Upgrade senza migration:

```text
Package A1 supports s3
Package A2 supports s3
State Instance = package@s3

A1 -> A2
```

lo stato resta lo stesso.

Upgrade incompatibile:

```text
current state = package@s3
new Package Instance supports only s4

→ migration required
```

La migration deve essere operazione separata e può creare:

```text
package@s4
```

preservando `package@s3` fino al commit/cleanup secondo la futura policy transazionale.

---

# 13. Rollback

Rollback semplice è possibile quando entrambe le Package Instance comprendono la stessa State Instance:

```text
A1 supports s3
A2 supports s3
state = package@s3

A1 -> A2 -> A1
```

Se lo stato è stato migrato a `s4` e A1 non comprende `s4`, serve snapshot/reverse migration o conservazione della precedente State Instance.

---

# 14. Backup e cleanup derivati dalla tassonomia

Default backup:

```text
include:
    conf
    data
    home

exclude:
    cache
    log
    run
    tmp
```

I log possono essere inclusi tramite policy esplicita.

Cleanup sicuro può eliminare:

```text
cache
run
tmp
```

senza perdere stato autorevole.

`log` segue una policy separata di retention.

---

# 15. Deintegrate, uninstall, purge-state

```text
deintegrate
    rimuove binding/runtime view
    NON elimina Package Instance
    NON elimina State Instance

uninstall
    rimuove Package Instance non più necessaria
    NON elimina automaticamente State Instance

purge-state
    elimina esplicitamente la State Instance e le sue aree
```

Una State Instance può quindi sopravvivere alla rimozione temporanea del software.

---

# 16. Invarianti

```text
SM-01 Package Instance != State Instance
SM-02 State Instance identity non contiene la software version
SM-03 State Instance ID = <pkg-name>[@<platform>-<architecture>]@s<state-compatibility-version>
SM-04 il qualifier platform/architecture esiste solo quando necessario
SM-05 state-compatibility-version != software version
SM-06 nel v0 esiste una sola State Instance per identity, senza profile nominati
SM-07 state areas = conf, data, home, cache, log, run, tmp
SM-08 conf/data/home sono persistent authoritative
SM-09 cache/log sono persistent non-authoritative
SM-10 run/tmp sono transient
SM-11 home è compatibility bucket conservativo, non destinazione preferita
SM-12 ogni writable island appartiene esattamente a una state area
SM-13 path software e state area RumiAI sono distinti e collegati dai runtime mappings
SM-14 run-default/ contiene default immutabili nelle forme/path attese dal software
SM-15 upgrade compatibile riusa la stessa State Instance
SM-16 cambio di state-compatibility-version richiede migration esplicita
SM-17 deintegrate != uninstall != purge-state
SM-18 State Instance può sopravvivere alla rimozione della Package Instance
```

---

# 17. Prossimo punto

Prima della Package Interface resta da fissare il **runtime mapping descriptor** in `@package`:

```text
writable island path
state area target
default source sotto run-default/
eventuali regole di inizializzazione
```

Dopo questo possiamo tornare al modello della Package Interface e delle Execution Requirements.
