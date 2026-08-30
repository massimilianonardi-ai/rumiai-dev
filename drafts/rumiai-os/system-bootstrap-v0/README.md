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
```

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

# 6. Public bootstrap namespace

API pubblica system-layer:

```text
rumi_*
```

State/variable bootstrap già esposto può mantenere namespace:

```text
RumiAI_*
```

I dettagli interni non costituiscono API salvo esplicita dichiarazione.

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

`any` non è host identity; è token di Package Instance portability.

Platform detection è Physical Platform Validation concern e non viene duplicata in `pkg`.

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

API semantica minima:

```text
rumi_conf_get <file> <field-name>
rumi_conf_has <file> <field-name>
rumi_conf_namespace <file> <prefix>
rumi_conf_validate <file> [schema]
```

Mutation helper possono includere:

```text
rumi_conf_set
rumi_conf_remove
```

ma una mutation autorevole deve rispettare il transaction/atomic-write contract; nessuna API implica inplace byte editing del file attivo.

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

---

# 12. System Tabular Data API

Il bootstrap fornisce primitive comuni per dataset TSV con header.

API semantica minima:

```text
rumi_table_validate <file> <schema>
rumi_table_header <file>
rumi_table_rows <file>
```

Primitive opzionali/ottimizzate:

```text
rumi_table_filter <file> <column> <value>
rumi_table_each <file> <callback>
```

Il contratto importante è:

```text
header validato
exact field count per row
single-pass streaming possibile
nessun quoting/escaping implicito
```

Gli inventory integrity usano questa API/classe di primitive, non `rumi_conf_get` ripetuto.

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

Contratto minimo candidato:

```text
rumi_path_canonicalize_existing
rumi_fs_type
rumi_fs_mode
rumi_fs_readlink
rumi_fs_walk
```

Le primitive devono preservare la distinzione:

```text
validate existence
→ canonicalize existing path
→ validate required type
```

come già fissato nel bootstrap RumiAI.

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

Il bootstrap/platform adapter espone una semantica uniforme:

```text
rumi_digest_file <algorithm> <file>
rumi_digest_text <algorithm> <exact-text>
```

ed eventualmente streaming digest quando richiesto dagli inventory.

Algorithm availability è fisicamente validata.

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
rumi_unicode_nfc
rumi_unicode_casefold
```

oppure una primitive equivalente che produca le stesse canonical/collision key.

La semantica è normativa; l'implementazione è platform-specific.

---

# 17. Transaction primitives

Il persistence model di `pkg` richiede primitive uniformi per:

```text
exclusive lock
file flush/durability
directory durability quando necessaria
atomic rename
atomic replace
```

Contratto semantico candidato:

```text
rumi_lock_acquire
rumi_lock_release
rumi_file_sync
rumi_directory_sync
rumi_atomic_rename
rumi_atomic_replace
```

I tool non implementano direttamente `flock` vs `fcntl` vs platform-specific alternatives.

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

Il consumer (`pkg`) vede sempre lo stesso contratto semantico.

---

# 19. Bootstrap libraries

Il bootstrap può organizzare le API in librerie sourced, coerentemente con il modello già esistente (`i18n.lib`, `log.lib`, `shell.lib`).

Separazione logica candidata:

```text
config
    SCF parsing/query

table
    STD parsing/streaming

path/fs
    pathname + filesystem abstraction

digest
    hashing

unicode
    NFC/case-fold

transaction
    lock/sync/atomic operations
```

Il layout fisico/nome dei `.lib` non è fissato da questo documento.

---

# 20. Core vs lazy modules

Il bootstrap deve rimanere piccolo.

Sono core le primitive necessarie a inizializzare/dispatchare qualsiasi system command.

Primitive costose/specialistiche possono essere caricate on-demand tramite una futura API `rumi_require` o equivalente.

Non si forza il caricamento Unicode/digest/transaction per un semplice command che non li usa.

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

# 22. Current implementation mapping

Il bootstrap attuale `rumiai-os` già implementa il nucleo di:

```text
POSIX sh bootstrap
root discovery
existing-path canonicalization
semantic directories
PATH prepend
bootstrap config read minimale
i18n
logger
CLI/command source dispatch
RumiAI_COMMAND_BIN
```

Da riallineare/estendere rispetto al contratto v0:

```text
logical command name `rumi`
SCF bootstrap configuration invece di single-value config ad hoc
SCF API
STD API
native platform/architecture export
native @platforms PATH precedence
filesystem/digest/unicode/transaction adapters
```

Questi sono implementation follow-up, non nuove primitive architetturali.

---

# 23. `pkg` relationship

```text
host validated facilities
        ↓
rumi bootstrap
        ↓
SCF / STD / platform primitive API
        ↓
pkg (POSIX sh)
        ↓
Package Instance / resolver / generations / launcher
```

`pkg` non reimplementa il bootstrap contract.

---

# 24. Invarianti

```text
RB-01 system tool = POSIX sh + Rumi shebang/bootstrap
RB-02 logical shebang command = rumi
RB-03 bootstrap precede pkg and cannot depend on pkg
RB-04 command script viene sourced nello stesso POSIX sh
RB-05 RumiAI_COMMAND_BIN identifica il command source
RB-06 system tools non dipendono da bash/Python/Node/jq
RB-07 non-portable semantics vivono nel bootstrap/platform adapter
RB-08 bootstrap espone SCF query/validation
RB-09 bootstrap espone STD validation/streaming
RB-10 data non viene source/eval/materializzata automaticamente in shell variables
RB-11 bootstrap espone native platform/architecture identity
RB-12 runtime PATH usa native @platforms before cross-platform bin
RB-13 digest/Unicode/transaction semantics hanno API uniformi
RB-14 stdout delle query contiene solo result data
RB-15 bootstrap resta minimal; specialized modules possono essere lazy
RB-16 Physical Platform Validation decide implementazione concreta delle adapter primitive
```
