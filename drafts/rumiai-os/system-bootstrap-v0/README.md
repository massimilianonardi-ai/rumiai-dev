# RumiAI system layer — `rumi` bootstrap contract v0

Data: 2026-08-30

Stato: **architectural contract — v0**

Questo documento definisce il contratto del bootstrap `rumi` usato dai tool del RumiAI system layer.

Il bootstrap reale esistente in `rumiai-os` fornisce già il nucleo iniziale:

```text
POSIX /bin/sh
relocatable RumiAI_ROOT discovery
semantic root variables
library loading tramite `.`
i18n/log bootstrap
command-entry resolution
source del command script dopo shift degli argv
SCF/TSV system data APIs
native platform/architecture identity
native @platforms PATH precedence
filesystem type/mode/readlink primitives
SHA-256 primitives
same-directory atomic replace
```

Le semantiche delle API dati e delle primitive platform sopra elencate sono state fisicamente validate su macOS arm64 e Ubuntu 26.04 ARM64 alle revisioni registrate in `PHYSICAL-VALIDATION-2026-08-30.md`.

Dopo tali gate è stata corretta la spelling delle nuove API da un namespace lowercase erroneamente introdotto al namespace canonico `RumiAI_*`; la revisione corrente risultante sarà ri-validata insieme al prossimo gate fisico sostanziale, senza attribuire retroattivamente la nuova spelling alle evidenze precedenti.

Il v0 estende questo modello senza introdurre un runtime Python/Node/JSON.

---

# 1. System tool model

Un tool del system layer è:

```text
POSIX sh source
+
shebang Rumi
+
bootstrap API
```

Forma logica dello shebang:

```text
#!/usr/bin/env rumi
```

`rumi` è il command bootstrap/interpreter del system layer.

La reference installation deve rendere `rumi` discoverable per la semantica dello shebang; la tecnica fisica di installazione/discovery è oggetto di Physical Platform Validation.

---

# 2. Execution semantics

Quando il kernel/`env` invoca:

```text
rumi <command-script> [argv...]
```

il bootstrap:

```text
1 scopre/canonicalizza sé stesso
2 determina RumiAI_ROOT
3 inizializza il system environment
4 carica le bootstrap libraries richieste
5 canonicalizza/valida command-script
6 espone RumiAI_COMMAND_BIN
7 rimuove command-script dagli argv
8 source il command-script nello stesso POSIX sh
9 restituisce lo status del command
```

Il command script non viene lanciato da un secondo shell interpreter.

---

# 3. `$0` e command identity

Poiché il command script viene sourced, non deve dipendere da `$0` per conoscere il proprio pathname.

Path canonico del command:

```text
RumiAI_COMMAND_BIN
```

Gli argv utente restano:

```text
$1 ... $N
```

dopo lo shift del command-entry.

---

# 4. Bootstrap independence

`rumi` precede `pkg` nella catena di bootstrap.

Quindi `rumi` NON può dipendere da:

```text
pkg
Package Instance resolution
Python
Node.js
jq
JSON parser
runtime gestito da pkg
```

Può usare soltanto:

```text
POSIX sh
host facilities necessarie e fisicamente validate
bootstrap/platform adapter Rumi
bootstrap libraries contenute nel system layer
```

---

# 5. POSIX code rule

I system tool, incluso `pkg`, sono POSIX `sh`.

Non assumono:

```text
bash arrays
associative arrays
[[ ... ]]
process substitution
bash-specific parameter expansion
non-POSIX shell syntax
```

Quando una semantica richiesta non è portabile in POSIX sh, viene fornita dal bootstrap/platform adapter invece di essere implementata con branch host-specific sparsi nei tool.

---

# 6. Shell naming convention

Il namespace canonico di funzioni e variabili RumiAI è:

```text
RumiAI_*
```

Questo vale sia per API esposte ai system tool sia per helper interni namespaced.

Il namespace alternativo lowercase:

```text
rumi_*
```

è vietato.

Il nome pubblico lowercase:

```text
rumi
```

identifica il command/interpreter e non definisce un namespace di funzioni.

Interfacce unnamespaced già specificate separatamente, per esempio gli entrypoint `log` e `i18n`, restano eccezioni esplicite e non costituiscono una seconda naming convention generale.

Una modifica futura della convenzione richiede una decisione esplicita; non può essere introdotta localmente da una nuova API.

---

# 7. Semantic root environment

Il bootstrap espone almeno:

```text
RumiAI_ROOT
RumiAI_BIN_DIR
RumiAI_LIB_DIR
RumiAI_CONF_DIR
RumiAI_LANG_DIR
RumiAI_COMMAND_BIN
```

Il bootstrap/pkg model può aggiungere root semantiche quando vengono fissate dal layout RumiAI.

Tutti i pathname persistiti dai package metadata restano relocatable; gli absolute pathname vengono materializzati soltanto runtime.

---

# 8. Native platform identity

Il bootstrap/platform adapter espone l'host concreto:

```text
RumiAI_PLATFORM
    linux | macos | windows

RumiAI_ARCHITECTURE
    arm64 | x86_64

RumiAI_EXECUTION_PLATFORM
    <platform>-<architecture>
```

Query API:

```text
RumiAI_platform
RumiAI_architecture
RumiAI_execution_platform
```

`any` non è host identity; è token di Package Instance portability.

Platform detection è Physical Platform Validation concern e non viene duplicata in `pkg`.

La semantica v0 è stata fisicamente validata su macOS arm64 e Ubuntu 26.04 ARM64 prima della correzione puramente nominale dell'API.

---

# 9. PATH baseline

Dopo native platform discovery il system environment segue la precedence RumiAI:

```text
RUMIAI_ROOT/bin/@platforms/<current-platform>-<architecture>
RUMIAI_ROOT/bin
<inherited PATH>
```

La native specialization precede la cross-platform view.

Bootstrap commands necessari prima della platform discovery devono restare raggiungibili senza dipendere da questa view.

La semantica v0 è stata fisicamente validata su macOS arm64 e Ubuntu 26.04 ARM64.

---

# 10. Default filesystem creation policy

Per operazioni system-layer che creano contenuto privato:

```text
umask 0077
```

salvo contratto specifico fisicamente validato.

Il bootstrap può applicare questa policy prima di entrare nel command system-layer o tramite primitive di creazione dedicate.

---

# 11. System Configuration Field API

Il bootstrap fornisce un parser/access layer unico per SCF.

API v0:

```text
RumiAI_conf_get <file> <field-name>
RumiAI_conf_has <file> <field-name>
RumiAI_conf_namespace <file> <prefix>
RumiAI_conf_validate <file>
RumiAI_conf_set <file> <field-name> <field-value>
RumiAI_conf_remove <file> <field-name>
```

Una mutation autorevole deve rispettare il transaction/atomic-write contract; nessuna API implica inplace byte editing del file attivo.

Il parser garantisce:

```text
UTF-8/framing
one TAB per record
dot-notation grammar
duplicate rejection
scalar/namespace collision rejection
exact field-value preservation
no source/eval
```

La semantica è stata fisicamente validata su macOS arm64 e Ubuntu 26.04 ARM64 con la precedente spelling API; la spelling `RumiAI_*` corrente viene coperta dal prossimo gate sostanziale.

---

# 12. System Tabular Data API

Il bootstrap fornisce primitive comuni per dataset TSV con header.

API v0:

```text
RumiAI_table_validate
RumiAI_table_header
RumiAI_table_rows
RumiAI_table_column
RumiAI_table_select
```

Il contratto importante è:

```text
header validato
exact field count per row
single-pass streaming possibile
nessun quoting/escaping implicito
```

Gli inventory integrity usano questa API/classe di primitive, non `RumiAI_conf_get` ripetuto.

La semantica è stata fisicamente validata su macOS arm64 e Ubuntu 26.04 ARM64 con la precedente spelling API; la spelling `RumiAI_*` corrente viene coperta dal prossimo gate sostanziale.

---

# 13. No automatic shell-variable materialization

SCF field-name non viene trasformato automaticamente in shell variable.

Non si usa:

```text
dot -> underscore
+
eval
```

perché può creare collisioni e trasformare dati in codice.

Il tool accede ai dati tramite API bootstrap.

---

# 14. Path/filesystem primitives

Il bootstrap espone semantiche uniformi per ciò che non è sufficientemente portabile come command host ad hoc.

Implementato:

```text
RumiAI_path_canonicalize_existing
RumiAI_fs_type
RumiAI_fs_mode
RumiAI_fs_readlink
```

Da implementare/validare separatamente:

```text
RumiAI_fs_walk
```

Le primitive preservano la distinzione:

```text
validate existence
→ canonicalize existing path
→ validate required type
```

come già fissato nel bootstrap RumiAI.

La semantica delle primitive già implementate è stata fisicamente validata su macOS arm64 e Ubuntu 26.04 ARM64 prima della correzione nominale delle nuove API.

---

# 15. Digest primitives

`pkg` non sceglie fra:

```text
sha256sum
shasum
openssl
certutil
...
```

Il bootstrap/platform adapter espone:

```text
RumiAI_digest_file sha256 <file>
RumiAI_digest_text sha256 <exact-text>
```

L'implementazione corrente isola inoltre gli host digest command dal PATH RumiAI.

La semantica v0 è stata fisicamente validata su macOS arm64 e Ubuntu 26.04 ARM64 prima della correzione nominale.

---

# 16. Unicode primitives

Integrity Method 1 richiede:

```text
Unicode NFC
Unicode default case-fold
```

POSIX sh non le fornisce portabilmente.

Il bootstrap/platform adapter deve quindi fornire semanticamente:

```text
RumiAI_unicode_nfc
RumiAI_unicode_casefold
```

oppure una primitive equivalente che produca le stesse canonical/collision key.

La semantica è normativa; l'implementazione è platform-specific.

Stato corrente: **non ancora implementato/validato**.

---

# 17. Transaction primitives

Il persistence model di `pkg` richiede primitive uniformi per:

```text
exclusive lock
file flush/durability
directory durability quando necessaria
atomic rename/publish
atomic replace
```

Implementato:

```text
RumiAI_atomic_replace
```

Il v0 corrente limita questa primitive a source/destination nella stessa directory, rendendo esplicita la precondizione necessaria per affidarsi alla rename atomica del filesystem.

Da implementare/validare separatamente:

```text
RumiAI_lock_acquire
RumiAI_lock_release
RumiAI_file_sync
RumiAI_directory_sync
RumiAI_atomic_publish
```

`pkg` non implementa direttamente `flock` vs `fcntl` vs platform-specific alternatives.

---

# 18. Platform adapters

Una primitive può essere implementata:

```text
in POSIX sh comune
tramite POSIX utility comune
tramite adapter specifico della reference platform
tramite piccolo bootstrap helper nativo quando inevitabile
```

Questa è una decisione di implementazione/Physical Platform Validation.

Il consumer (`pkg`) vede sempre lo stesso contratto semantico e lo stesso namespace `RumiAI_*`.

---

# 19. Bootstrap libraries

Il bootstrap organizza attualmente le nuove API comuni in:

```text
lib/data.lib
    SCF + TSV

lib/platform.lib
    platform identity
    PATH specialization support
    pathname/filesystem primitives
    SHA-256
    atomic replace
```

Restano candidati moduli separati quando emergono primitive che lo richiedono:

```text
unicode
transaction/durability
```

---

# 20. Core vs lazy modules

Il bootstrap deve rimanere piccolo.

Sono core le primitive necessarie a inizializzare/dispatchare qualsiasi system command.

Primitive costose/specialistiche possono essere caricate on-demand tramite una futura API:

```text
RumiAI_require
```

o equivalente esplicitamente specificata.

Non si forza il caricamento Unicode/durability per un semplice command che non li usa.

---

# 21. Logging/output discipline

Le API bootstrap che restituiscono dati via stdout non devono mischiare log/diagnostics sullo stesso stream.

Regola:

```text
stdout = result data
stderr/logger = diagnostic
exit status = success/failure/negative query secondo API
```

Questo è necessario perché POSIX command substitution e pipeline restino affidabili.

---

# 22. Library load failure pattern

Quando una libreria obbligatoria deve esistere, essere leggibile e poter essere sourced, e tutte queste failure appartengono alla stessa classe di errore, il bootstrap usa un singolo failure branch:

```sh
if [ ! -f "$LIB" ] || \
   [ ! -r "$LIB" ] || \
   ! . "$LIB"
then
  <single diagnostic/error path>
fi
```

Non si duplicano consecutivamente branch con lo stesso identico esito solo per separare precheck e source.

I precheck restano nello stesso conditional perché `.` è uno special builtin e il bootstrap non deve affidarsi a una failure non controllata.

---

# 23. Current implementation mapping

Il bootstrap corrente implementa:

```text
POSIX sh bootstrap
root discovery
existing-path canonicalization
semantic directories
SCF API
TSV API
native platform/architecture export
native @platforms PATH precedence
filesystem type/mode/readlink
SHA-256 file/text digest
same-directory atomic replace
i18n
logger
CLI/command source dispatch
RumiAI_COMMAND_BIN
```

Dopo i primi due physical gate sono state applicate due correzioni di coerenza:

```text
new API function prefix: rumi_* -> RumiAI_*
redundant same-error library load branches -> single branch
```

Le semantiche sottostanti erano già validate; la revisione corrente corretta viene ri-esercitata nel prossimo physical gate sostanziale invece di imporre una validation separata puramente nominale.

Restano implementation follow-up:

```text
logical command name `rumi`
SCF bootstrap preferences instead of legacy single-value preference files
filesystem walk
Unicode NFC/default case-fold adapter
exclusive process lock
file/directory durability sync
atomic generation publish protocol
logical shebang installation/discovery validation
```

---

# 24. `pkg` relationship

```text
host validated facilities
        ↓
rumi bootstrap
        ↓
RumiAI_* SCF / TSV / platform primitive API
        ↓
pkg (POSIX sh)
        ↓
Package Instance / resolver / generations / launcher
```

`pkg` non reimplementa il bootstrap contract.

---

# 25. Development consistency gate

Le modifiche a questo sottosistema sono soggette a:

```text
CONSISTENCY-GATE.md
```

in `rumiai-dev`.

In particolare, prima di dichiarare completata una modifica al bootstrap devono essere verificati almeno:

```text
naming convention corrente
riuso di primitive esistenti
assenza di spelling superseded nel prodotto
allineamento di test e documenti
file mode dei test/eseguibili
stato reale della Physical Platform Validation
```

La convenzione non può essere cambiata implicitamente da una nuova implementazione locale.

---

# 26. Invarianti

```text
RB-01 system tool = POSIX sh + Rumi shebang/bootstrap
RB-02 logical shebang command = rumi
RB-03 bootstrap precede pkg and cannot depend on pkg
RB-04 command script viene sourced nello stesso POSIX sh
RB-05 RumiAI_COMMAND_BIN identifica il command source
RB-06 system tools non dipendono da bash/Python/Node/jq
RB-07 non-portable semantics vivono nel bootstrap/platform adapter
RB-08 bootstrap espone SCF query/validation
RB-09 bootstrap espone TSV validation/streaming
RB-10 data non viene source/eval/materializzata automaticamente in shell variables
RB-11 bootstrap espone native platform/architecture identity
RB-12 runtime PATH usa native @platforms before cross-platform bin
RB-13 digest/Unicode/transaction semantics hanno API uniformi
RB-14 stdout delle query contiene solo result data
RB-15 bootstrap resta minimal; specialized modules possono essere lazy
RB-16 Physical Platform Validation decide implementazione concreta delle adapter primitive
RB-17 functions/variables namespaced use exact RumiAI_* prefix
RB-18 lowercase rumi_* function namespace is forbidden
RB-19 command name `rumi` is distinct from shell API namespace
RB-20 equivalent consecutive library-load failures share one failure branch
RB-21 established invariants are checked through CONSISTENCY-GATE.md before completion
```
