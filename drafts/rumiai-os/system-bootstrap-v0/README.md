# RumiAI system layer — bootstrap contract v0

Data: 2026-08-30

Stato: **architectural contract — v0**

Questo documento definisce il contratto del bootstrap del RumiAI system layer.

Il bootstrap reale esistente in `rumiai-os` fornisce il nucleo iniziale:

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
kernel-backed manager lock
file/directory sync semantic APIs
same-parent atomic directory publish
```

Non esiste nel contratto v0 un nuovo command/interpreter dedicato al bootstrap. Nessun nome di command viene inferito da abbreviazioni usate in conversazione.

Gli script shell direttamente eseguibili seguono la regola canonica di `RULES.md`:

```sh
#!/bin/sh
```

Le semantiche delle API dati e delle primitive platform già registrate sono state fisicamente validate sulle reference installation riportate in `PHYSICAL-VALIDATION-2026-08-30.md`. Le successive correzioni e le nuove transaction primitives restano distinte dall'evidenza storica delle revisioni effettivamente esercitate.

---

# 1. System tool model

Un tool shell del system layer è codice POSIX `sh` che usa le API bootstrap RumiAI già inizializzate dal relativo entrypoint/dispatch contract.

Non viene introdotto implicitamente un interprete diverso da `/bin/sh`.

Se in futuro emergerà la necessità di un diverso meccanismo di bootstrap/dispatch, nome, invocazione e semantica dovranno essere definiti esplicitamente prima dell'implementazione.

---

# 2. Current execution semantics

Il front controller `rumiai-os`:

```text
1 scopre/canonicalizza sé stesso
2 determina RumiAI_ROOT
3 inizializza il system environment
4 carica le bootstrap libraries richieste
5 canonicalizza/valida un eventuale command-script
6 espone RumiAI_COMMAND_BIN
7 rimuove command-script dagli argv
8 source il command-script nello stesso POSIX sh
9 restituisce lo status del command
```

Il command script sourced non deve dipendere da `$0` per conoscere il proprio pathname.

Path canonico del command:

```text
RumiAI_COMMAND_BIN
```

---

# 3. Bootstrap independence

Il bootstrap precede `pkg` nella catena del system layer.

Quindi non può dipendere da:

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
bootstrap/platform adapter RumiAI
bootstrap libraries contenute nel system layer
```

---

# 4. POSIX code rule

I system tool shell, incluso `pkg`, sono POSIX `sh`.

Non assumono:

```text
bash arrays
associative arrays
[[ ... ]]
process substitution
bash-specific parameter expansion
non-POSIX shell syntax
```

Quando una semantica richiesta non è portabile in POSIX `sh`, viene fornita dal bootstrap/platform adapter RumiAI invece di essere implementata con branch host-specific sparsi nei tool.

---

# 5. Shell naming convention

Il namespace canonico di funzioni e variabili RumiAI è:

```text
RumiAI_*
```

Questo vale sia per API esposte ai system tool sia per helper interni namespaced.

Interfacce unnamespaced già specificate separatamente, per esempio gli entrypoint `log` e `i18n`, restano eccezioni esplicite e non costituiscono una seconda naming convention generale.

Abbreviazioni conversazionali non hanno autorità di naming e non possono diventare command, namespace o componenti senza decisione esplicita.

---

# 6. Semantic root environment

Il bootstrap espone almeno:

```text
RumiAI_ROOT
RumiAI_BIN_DIR
RumiAI_LIB_DIR
RumiAI_CONF_DIR
RumiAI_LANG_DIR
RumiAI_COMMAND_BIN
```

Il bootstrap/package-manager model può aggiungere root semantiche soltanto quando vengono fissate dal layout RumiAI.

I pathname persistiti dai package metadata restano relocatable; absolute pathname vengono materializzati soltanto runtime.

---

# 7. Native platform identity

Il bootstrap/platform adapter espone:

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

---

# 8. PATH baseline

Dopo native platform discovery:

```text
RUMIAI_ROOT/bin/@platforms/<current-platform>-<architecture>
RUMIAI_ROOT/bin
<inherited PATH>
```

La native specialization precede la cross-platform view.

---

# 9. Default filesystem creation policy

Per operazioni system-layer che creano contenuto privato:

```text
umask 0077
```

salvo contratto specifico fisicamente validato.

---

# 10. System Configuration Field API

API v0:

```text
RumiAI_conf_get <file> <field-name>
RumiAI_conf_has <file> <field-name>
RumiAI_conf_namespace <file> <prefix>
RumiAI_conf_validate <file>
RumiAI_conf_set <file> <field-name> <field-value>
RumiAI_conf_remove <file> <field-name>
```

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

Una mutation autorevole deve rispettare il transaction/atomic-write contract.

---

# 11. System Tabular Data API

API v0:

```text
RumiAI_table_validate
RumiAI_table_header
RumiAI_table_rows
RumiAI_table_column
RumiAI_table_select
```

Contratto:

```text
header validato
exact field count per row
single-pass streaming possibile
nessun quoting/escaping implicito
```

Gli inventory integrity usano questa classe di primitive, non lookup SCF ripetuti per ogni record.

---

# 12. No automatic shell-variable materialization

SCF field-name non viene trasformato automaticamente in shell variable.

Non si usa `eval` e non si trasforma genericamente `.` in `_` per generare variabili.

I file restano dati, non codice.

---

# 13. Path/filesystem primitives

Implementato:

```text
RumiAI_path_canonicalize_existing
RumiAI_fs_type
RumiAI_fs_mode
RumiAI_fs_readlink
```

Da implementare/validare separatamente quando richiesto:

```text
RumiAI_fs_walk
```

Resta fissata la distinzione:

```text
validate existence
→ canonicalize existing path
→ validate required type
```

---

# 14. Digest and Unicode primitives

Digest implementato:

```text
RumiAI_digest_file sha256 <file>
RumiAI_digest_text sha256 <exact-text>
```

La specifica corrente di Integrity Method 1 contiene ancora requisiti di NFC/case-fold e aveva derivato da essi le primitive:

```text
RumiAI_unicode_nfc
RumiAI_unicode_casefold
```

Queste primitive **non sono implementate** e la loro necessità è ora oggetto di rivalutazione esplicita prima di aggiungere complessità al bootstrap. Non costituiscono un prerequisito del transaction gate corrente.

Finché la rivalutazione non è conclusa, la specifica Integrity Method 1 non viene silenziosamente reinterpretata: l'eventuale semplificazione del relativo modello sarà una decisione separata.

---

# 15. Transaction primitives

Implementato e già fisicamente validato nelle revisioni storiche registrate:

```text
RumiAI_atomic_replace
```

Implementato nella revisione corrente, in attesa di Physical Platform Validation:

```text
RumiAI_lock_acquire
RumiAI_lock_release
RumiAI_file_sync
RumiAI_directory_sync
RumiAI_atomic_publish
```

Physical implementation v0:

```text
lock
    kernel-backed file lock su fd 9
    Linux: flock
    macOS: lockf

file_sync / directory_sync
    host-wide sync barrier

atomic_publish
    same-parent directory rename sotto manager lock
```

Il lock pathname è non autorevole: la sua esistenza non rappresenta ownership.

Il dettaglio completo è definito in `system-transaction-primitives-v0/README.md`.

`pkg` non implementa direttamente alternative host-specific per queste responsabilità.

---

# 16. Library loading

Quando una libreria obbligatoria deve essere sourced e tutte le failure di load appartengono alla stessa classe di errore, non si duplicano precheck di esistenza/leggibilità che anticipano la stessa operazione.

Il pattern v0 è una singola source operation controllata:

```sh
if ! command -- . "$LIB"
then
  <single diagnostic/error path>
fi
```

`command` è intenzionale: `.` è un POSIX special built-in e una sua failure diretta per file non trovato/non leggibile può terminare una shell non interattiva prima che il caller possa gestire lo status. Invocandolo tramite `command`, il bootstrap conserva l'effetto di source nello stesso environment ma può gestire la failure nel proprio branch.

Il primo `--` appartiene alla utility `command`, che lo usa come delimitatore prima dell'operando `.`. La dot utility riceve invece direttamente il pathname della libreria e non viene passata un'ulteriore `--`:

```sh
command -- . "$LIB"
```

non:

```sh
command -- . -- "$LIB"
```

Quindi:

```text
one semantic operation
one failure branch
no duplicate existence/readability precheck
-- applicato a command, non inventato per dot
```

---

# 17. Bootstrap libraries

Organizzazione corrente:

```text
lib/data.lib
    SCF + TSV

lib/platform.lib
    platform identity
    PATH specialization support
    pathname/filesystem primitives
    SHA-256
    atomic replace
    manager lock acquire/release
    file/directory sync
    atomic directory publish
```

Moduli ulteriori vengono introdotti solo quando emerge una necessità concreta.

---

# 18. Logging/output discipline

Le API bootstrap che restituiscono dati via stdout non devono mischiare diagnostics sullo stesso stream.

```text
stdout = result data
stderr/logger = diagnostic
exit status = semantic result
```

---

# 19. Current implementation mapping

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
kernel-backed mutation lock
host-wide sync semantic APIs
same-parent atomic directory publish
i18n
logger
CLI/command source dispatch
RumiAI_COMMAND_BIN
single controlled source operation for required libraries
```

Le evidenze di Physical Platform Validation restano associate alle revisioni precise riportate nel documento di validation. Le nuove transaction primitives non sono considerate fisicamente validate finché il gate corrente non viene eseguito sulle reference installation.

Follow-up già identificati:

```text
SCF bootstrap preferences instead of legacy single-value preference files
filesystem walk
rivalutazione della reale necessità di Unicode NFC/default case-fold nel modello Integrity Method 1
Physical Platform Validation delle transaction primitives correnti
```

Non esiste un follow-up implicito relativo a un nuovo command/interpreter o a un nuovo shebang: un simile concetto richiederebbe una decisione architetturale esplicita.

---

# 20. `pkg` relationship

```text
host validated facilities
        ↓
RumiAI bootstrap/platform layer
        ↓
RumiAI_* SCF / TSV / platform primitive API
        ↓
pkg (POSIX sh)
        ↓
Package Instance / resolver / generations / launcher
```

`pkg` non reimplementa il bootstrap contract.

---

# 21. Development consistency gate

Ogni modifica a questo sottosistema è soggetta a `CONSISTENCY-GATE.md`.

Prima di analizzare o modificare il bootstrap devono essere recuperati almeno:

```text
RULES.md
CONSISTENCY-GATE.md
questa specifica
HEAD remoti correnti
test permanenti pertinenti
```

Conversational shorthand, memoria e convenienza locale non possono introdurre nuove decisioni.

---

# 22. Invarianti

```text
RB-01 shell system tools follow POSIX sh and canonical #!/bin/sh rule
RB-02 no dedicated bootstrap command/interpreter is implied by v0
RB-03 bootstrap precedes pkg and cannot depend on pkg
RB-04 command script dispatch currently sources into the same POSIX sh
RB-05 RumiAI_COMMAND_BIN identifies the command source
RB-06 system shell tools do not depend on bash/Python/Node/jq
RB-07 non-portable semantics live behind bootstrap/platform adapter
RB-08 bootstrap exposes SCF query/validation
RB-09 bootstrap exposes TSV validation/streaming
RB-10 data is never source/eval/materialized automatically into shell variables
RB-11 bootstrap exposes native platform/architecture identity
RB-12 runtime PATH uses native @platforms before cross-platform bin
RB-13 digest/transaction semantics have uniform RumiAI APIs
RB-14 stdout of data-returning queries contains result data only
RB-15 bootstrap remains minimal
RB-16 Physical Platform Validation decides concrete adapter implementation support
RB-17 namespaced RumiAI shell functions/variables use exact RumiAI_* namespace
RB-18 conversational shorthand has no product naming authority
RB-19 required library load uses `command -- . "$LIB"`, with one controlled source operation and no duplicate prechecks
RB-20 established invariants are checked through CONSISTENCY-GATE.md before work and before completion
RB-21 manager lock ownership is kernel-backed; lock pathname existence is non-authoritative
RB-22 transaction sync v0 uses host-wide sync without introducing a new helper/runtime
RB-23 atomic publish is same-parent and requires the manager lock
RB-24 Unicode normalization/case-fold complexity is not added before explicit necessity reassessment
```