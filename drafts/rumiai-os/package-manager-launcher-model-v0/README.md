# RumiAI package manager — launcher / Execution View model v0

Data: 2026-08-30

Stato: **design decision — public command launch model v0 fissato**

Prerequisiti:

```text
drafts/rumiai-os/system-bootstrap-v0/README.md
drafts/rumiai-os/package-manager-integration-schema-v0/README.md
drafts/rumiai-os/package-manager-persistence-layout-v0/README.md
drafts/rumiai-os/package-manager-package-descriptor/README.md
```

Obiettivo:

> un public command sotto `bin/` usa sempre l'exact binding della active generation, incluse dependency private, State Instance ed Environment Specification, senza re-resolution al launch e senza aggiornare atomicamente ogni command target durante generation switch.

---

# 1. Command Stub

Un **Command Stub** è un elemento derivato dell'Execution View.

Non contiene:

```text
exact provider Package Instance
active generation
JAVA_HOME concreto
absolute package path
dependency selection
latest/fallback policy
```

V0 public profile è `default`.

Public command scope/name derivano dal pathname dello stub.

---

# 2. Stable stub

Esempio:

```text
RUMIAI_ROOT/bin/netbeans
```

non viene riscritto quando cambiano:

```text
NetBeans Package Instance
JDK provider/version
private dependency closure
State Instance compatible binding
environment exact references
```

Lo stub delega al Rumi Launcher, che legge `active` una sola volta.

---

# 3. Public Command Key

Chiave v0:

```text
profile
scope
public command name
```

Scope:

```text
cross-platform
native:<platform>-<architecture>
```

Esempi:

```text
default / cross-platform / tool
default / native:linux-arm64 / tool
```

Desired binding ID/provenance non fanno parte della public key.

---

# 4. Filesystem placement

Cross-platform:

```text
RUMIAI_ROOT/bin/<name>
```

Native:

```text
RUMIAI_ROOT/bin/@platforms/<platform>-<architecture>/<name>
```

Il pathname determina scope/name.

---

# 5. POSIX-shebang stub v0

Sulle reference platform dove l'execution environment supporta lo shebang Rumi, il Command Stub è un **piccolo file regolare generato**, non un symlink.

Forma concettuale canonica:

```sh
#!/usr/bin/env rumi
rumi_require launcher || exit $?
rumi_launch "$@"
```

Il nome/scope NON sono embedded nel body.

`rumi_launch` usa:

```text
RumiAI_COMMAND_BIN
```

esposto dal bootstrap per ricavare il pathname dello stub effettivamente invocato.

Il body può essere identico byte-per-byte per tutti i public command stub della stessa stub schema/version.

---

# 6. Perché non symlink

Il bootstrap corrente canonicalizza il command entry prima di esporre `RumiAI_COMMAND_BIN`.

Un symlink:

```text
bin/foo -> common-stub
```

può quindi perdere il pathname pubblico `bin/foo` durante canonicalization e diventare indistinguibile da altri alias.

Per v0 sulle reference POSIX-like:

```text
symlink stub = forbidden
```

come implementazione del public command.

La scelta evita di dipendere da `argv[0]`/symlink-preservation semantics variabili.

---

# 7. Perché non hardlink

Un hardlink potrebbe preservare il pathname invocato ma condivide lo stesso inode/content e aggiunge filesystem semantics non necessarie.

V0 preferisce:

```text
canonical generated regular-file copy
```

per semplicità, inspection e repair deterministici.

Hardlink non è richiesto dal modello.

---

# 8. Stub validation

Poiché `bin/` è derived view, lo stub non necessita identity persistita propria.

Reconciliation verifica almeno:

```text
expected pathname
regular file type
expected executable mode
canonical stub schema/body
non-symlink
```

Stub missing/corrupt viene rigenerato.

---

# 9. Stub identity derivation

Il launcher riceve `RumiAI_COMMAND_BIN` canonico.

Se è:

```text
RUMIAI_ROOT/bin/<name>
```

allora:

```text
profile = default
scope   = cross-platform
name    = <name>
```

Se è:

```text
RUMIAI_ROOT/bin/@platforms/<platform>-<architecture>/<name>
```

allora:

```text
profile = default
scope   = native:<platform>-<architecture>
name    = <name>
```

Altro placement non è public command stub v0.

---

# 10. Native scope validation

Una native stub viene normalmente scoperta dal PATH soltanto nel current native namespace.

Una invocazione esplicita di stub sotto altra native platform directory deve essere validata contro:

```text
RumiAI_EXECUTION_PLATFORM
```

Binding nativo incompatibile non viene lanciato accidentalmente.

---

# 11. Rumi Launcher abstraction

Input logico:

```text
RUMIAI_ROOT
RumiAI_COMMAND_BIN
profile derivato
scope derivato
public command name derivato
user argv tail
current host environment
```

Output:

```text
exec exact Launch Specification
```

Il launcher non acquisisce software e non esegue dependency resolution.

---

# 12. Launch algorithm v0

```text
1 validate RUMIAI_ROOT + RumiAI_COMMAND_BIN placement
2 derive profile/scope/name
3 read active generation exactly once
4 open immutable gN/resolved SCF
5 verify generation/profile consistency
6 lookup public binding by profile+scope+name
7 absent -> COMMAND_NOT_ACTIVE
8 verify exact root Package Instance launch health
9 load exact @package SCF as needed
10 use exact Resolved Dependency Graph from gN
11 bind exact State Instance
12 ensure package-local run/ routing
13 compose Execution Environment
14 materialize Launch Template recursively through exact slots
15 append/pass user argv according to contract
16 execute without shell reinterpretation
```

Nessun punto esegue:

```text
latest
provider preference
fallback
host PATH runtime discovery
new dependency selection
```

---

# 13. Active read-once rule

Dopo:

```text
active = g17
```

lo stesso launch non rilegge `active`.

Se active passa a g18 durante il launch:

```text
launch corrente usa interamente g17
launch successivo usa g18
```

Retention conserva g17 finché necessario secondo policy v0 conservativa.

---

# 14. New command activation

Prima dello switch active può esistere già:

```text
bin/foo
```

ma con old generation senza binding:

```text
COMMAND_NOT_ACTIVE
```

Dopo atomic switch lo stesso stub usa il new exact binding.

---

# 15. Target change

```text
g17 java -> Temurin A
g18 java -> Temurin B
```

Lo stub `java` non cambia.

L'unico semantic switch è `active`.

---

# 16. Command removal

Dopo una generation che rimuove `foo`, uno stale stub rimasto per crash/cleanup incompleto produce:

```text
COMMAND_NOT_ACTIVE
```

Non può rilanciare old binding.

---

# 17. Native specialization

PATH:

```text
bin/@platforms/<current-platform>-<architecture>
bin
<inherited PATH>
```

Native specialization viene trovata prima del cross-platform binding.

Direct pathname `RUMIAI_ROOT/bin/tool` seleziona intenzionalmente il cross-platform scope.

---

# 18. Windows / non-POSIX-native command surface

Il logical stub contract resta:

```text
preserve invoked public pathname identity
forward argv exactly
enter rumi launcher
non embed provider/generation
rebuildable
```

Se la reference Windows environment non esegue direttamente POSIX shebang script dal native command surface, serve un platform adapter/shim fisicamente validato.

La semantica launcher non cambia.

Non viene imposto un `.exe` shim prima della Physical Platform Validation.

---

# 19. Package Launch Template

Una command resource immutabile può dichiarare:

```text
executable reference
fixed argv references
command-specific environment overlay
```

Hosted command:

```text
example-app
    executable = dependency python / command python
    args = self file main-script
```

Exact provider arriva dal Resolved Dependency Graph.

Host PATH non è dependency fallback.

---

# 20. Recursive command materialization

Dependency command reference:

```text
root command
    ↓ exact dependency slot
provider command Launch Template
```

La closure è già aciclica.

Cycle al launch:

```text
BROKEN_RESOLUTION
```

non nuova resolution.

---

# 21. Environment build

Precedence:

```text
1 inherited/sanitized Host Base Environment
2 RumiAI Base Environment
3 active Resolved Integration Profile environment
4 root Package Environment Specification
5 command-specific overlay
6 explicit invocation overrides
```

PATH-list viene materializzata con separator platform-specific alla process boundary.

---

# 22. State routing before exec

Il launcher verifica/ricostruisce la package-local:

```text
pkg/<id>/run/
```

secondo exact State Instance binding.

`run/` reconstruction non cambia Package Instance identity.

---

# 23. One runtime view invariant

V0:

```text
one active run/ view per Package Instance
```

Multi-state parallelism resta futuro e richiederà architettura esplicita.

---

# 24. Public default profile

Root Execution View:

```text
RUMIAI_ROOT/bin/
RUMIAI_ROOT/bin/@platforms/...
```

rappresenta profile:

```text
default
```

Altri profile non vengono fusi automaticamente nel root `bin/` namespace.

---

# 25. Execution View reconciliation

Sotto manager lock:

```text
ensure candidate stubs exist
validate canonical stub implementation
atomic active switch
remove obsolete stubs opportunistically
```

Source of truth:

```text
active Resolution Snapshot
```

non `bin/` listing.

---

# 26. Recovery

```text
read active generation
compute required public command paths
create/repair missing/noncanonical stubs
remove or leave harmless stale stub per cleanup policy
```

Missing stub:

```text
EXECUTION_VIEW_INCOMPLETE
```

---

# 27. Error classes

```text
COMMAND_NOT_ACTIVE
COMMAND_STUB_ERROR
EXECUTION_VIEW_INCOMPLETE
LAUNCH_BINDING_ERROR
LAUNCH_ENVIRONMENT_ERROR
BROKEN_RESOLUTION
STATE_ROUTING_ERROR
PLATFORM_MISMATCH
```

---

# 28. Invarianti

```text
LM-01 command stub = derived Execution View
LM-02 stub non embed provider/generation/name/scope metadata
LM-03 public key = profile + scope + name
LM-04 profile/scope/name derivano dal stub pathname v0
LM-05 POSIX-like stub v0 = generated regular file with Rumi shebang
LM-06 POSIX-like symlink stub forbidden
LM-07 launcher legge active una sola volta
LM-08 launch usa exact immutable generation
LM-09 launch non esegue dependency resolution
LM-10 stale/new stub non può bypassare active generation
LM-11 native/cross same name restano scope distinti
LM-12 argv non passa attraverso shell reinterpretation
LM-13 host PATH non è dependency fallback
LM-14 run/ è verificata/ricostruita prima del launch
LM-15 root bin namespace = public default profile
LM-16 bin listing non è authoritative integration state
LM-17 Windows/non-POSIX-native surface può richiedere platform shim validato
```
