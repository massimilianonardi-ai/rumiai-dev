# RumiAI package manager — launcher / Execution View model v0

Data: 2026-08-30

Stato: **design decision — public command launch model v0 fissato**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-integration-schema-v0/README.md
drafts/rumiai-os/package-manager-persistence-layout-v0/README.md
drafts/rumiai-os/package-manager-package-descriptor/README.md
```

Obiettivo:

> fare in modo che un public command sotto `bin/` usi sempre l'exact binding della active generation, incluse dependency private, State Instance ed Environment Specification, senza re-resolution al launch e senza dover aggiornare atomicamente ogni command target durante generation switch.

---

# 1. Command Stub

Un **Command Stub** è un elemento derivato dell'Execution View.

Non contiene:

```text
exact provider Package Instance
JAVA_HOME concreto
absolute package path
dependency selection
latest/fallback policy
```

Contiene semanticamente soltanto abbastanza informazione per identificare:

```text
RumiAI environment root
profile
public command scope
public command name
```

poi delega al RumiAI Launcher.

---

# 2. Stable stub, dynamic active-generation lookup

Esempio:

```text
RUMIAI_ROOT/bin/netbeans
```

non viene riscritto quando:

```text
NetBeans 26 -> NetBeans 27
JDK 21.0.8 -> JDK 21.0.9
provider Temurin -> Microsoft OpenJDK
```

Lo stub continua a significare:

```text
profile=default
scope=cross-platform
name=netbeans
```

Il launcher legge:

```text
var/pkg/profiles/default/active
```

una sola volta e usa l'exact binding presente in quella generation.

---

# 3. Public Command Key

Il launch lookup non dipende dal Desired binding ID.

La chiave semantica v0 è:

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

Questo permette a binding ID/provenance di evolvere senza cambiare il pathname stub finché il public command contract resta lo stesso.

---

# 4. Stub filesystem placement

Cross-platform binding:

```text
RUMIAI_ROOT/bin/<name>
```

Native binding:

```text
RUMIAI_ROOT/bin/@platforms/<native-platform>-<architecture>/<name>
```

Il pathname stesso determina il command scope dell'Execution View.

La physical stub implementation deve comunque rendere tale scope disponibile al Launcher in modo affidabile; non si presume genericamente che `argv[0]` basti su ogni OS.

---

# 5. RumiAI Launcher abstraction

Il **RumiAI Launcher** è una runtime primitive del package manager/execution layer.

Input logico:

```text
RUMIAI_ROOT
profile
command scope
public command name
user argv tail
current host process environment
```

Output:

```text
exec exact Launch Specification
```

Il launcher non acquisisce software e non esegue dependency resolution.

---

# 6. Launch algorithm v0

```text
1. resolve/validate RUMIAI_ROOT
2. read active generation pointer exactly once
3. open immutable gN/resolved
4. verify generation/profile consistency
5. lookup public binding by profile + scope + name
6. if absent -> COMMAND_NOT_ACTIVE
7. verify exact root Package Instance still HEALTHY enough for launch
8. load immutable @package of exact root/dependency Package Instance as needed
9. use exact Resolved Dependency Graph from gN
10. bind exact State Instance from gN
11. ensure package-local run/ routing matches required State Instance
12. compose Execution Environment by fixed precedence
13. materialize exact command Launch Template recursively through exact dependency slots
14. append/pass user argv according to command contract
15. execute without shell reinterpretation
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

# 7. Active generation read-once rule

Un singolo launch appartiene interamente a una generation.

Dopo aver letto:

```text
active = g17
```

il launcher NON rilegge `active` durante la costruzione dello stesso Launch Specification.

Se nel frattempo il sistema passa a `g18`:

```text
launch corrente continua coerentemente con g17
nuovo launch usa g18
```

Questo evita mixed-generation environment/graph.

Retention v0 garantisce che g17 non venga automaticamente eliminata durante il launch.

---

# 8. New command activation

Candidate generation `g18` aggiunge:

```text
foo
```

Prima dello switch active, il package manager può materializzare:

```text
bin/foo
```

come Command Stub.

Con active ancora `g17`:

```text
foo stub exists
launcher lookup in g17
→ COMMAND_NOT_ACTIVE
```

Dopo atomic switch:

```text
active -> g18
```

lo stesso stub trova l'exact g18 binding.

Non può accidentalmente lanciare un candidate provider prima del commit.

---

# 9. Existing command target change

Se `java` esiste in g17 e g18 ma cambia exact provider:

```text
g17 java -> Temurin A
g18 java -> Temurin B
```

il filesystem stub:

```text
bin/@platforms/.../java
```

non cambia.

L'unico switch semantico è:

```text
active g17 -> g18
```

Quindi tutti i campi exact usati dal launcher cambiano insieme alla generation.

---

# 10. Command removal

Candidate g18 rimuove `foo`.

Dopo active switch:

```text
stale bin/foo stub
→ lookup g18
→ COMMAND_NOT_ACTIVE
```

Il package manager può eliminarlo come cleanup derivato.

Se crasha prima del cleanup, resta un harmless stale stub, non una stale binding eseguibile.

Recovery/rebuild può riconciliare gli stub con la active generation.

---

# 11. Native specialization

PATH order resta:

```text
bin/@platforms/<current-native-platform>
bin
<inherited PATH>
```

Quindi una native specialization viene trovata prima della cross-platform binding.

Ogni stub porta scope distinto:

```text
native:linux-arm64 / tool
cross-platform / tool
```

Il launcher lookup mantiene la distinzione anche se il public basename coincide.

Se l'utente invoca esplicitamente il cross-platform pathname:

```text
RUMIAI_ROOT/bin/tool
```

ottiene la cross-platform binding, non la specialization native.

---

# 12. Stub physical implementation è platform adapter

Il modello logico non impone che ogni stub sia un symlink.

Implementation candidate per reference platform possono includere:

```text
small generated launcher stub
hardlink/copy di un common launcher capace di identificare path/scope
symlink quando le OS semantics permettono di preservare robustamente l'identità richiesta
native .exe shim su Windows
```

Requisiti fisici:

```text
forward argv senza shell re-parsing
identify public name/scope affidabilmente
locate RUMIAI_ROOT relocatably
non embed exact provider/generation
rebuildable from active/retained resolved state
Physical Platform Validation
```

Il v0 non rende una particolare tecnica universale prima della validation.

---

# 13. No arbitrary shell requirement

Il descriptor `@package` non contiene shell code.

Anche se un reference platform iniziale implementasse materialmente lo stub con uno script deterministico generato da RumiAI, quella sarebbe una **Execution View implementation**, non package metadata eseguibile e non una semantica richiesta dal modello.

Il semantic command launch resta argv-based.

---

# 14. Package Launch Template

Una command resource immutabile può dichiarare:

```text
executable reference
fixed argv references
command-specific environment overlay
```

Esempio hosted:

```text
example-app
    executable = dependency python / command python
    args = self file main-script
```

Il launcher usa il Resolved Dependency Graph per trasformare `dependency python` nell'exact provider della generation letta.

Non cerca un `python` arbitrario nel PATH host.

---

# 15. Recursive command materialization

Se executable reference punta a dependency command resource:

```text
root command
    ↓ exact dependency slot
provider command Launch Template
```

il launcher compone deterministicamente le Launch Template.

La dependency closure è già aciclica per resolver invariant.

Un cycle trovato durante launch indica corruption/inconsistency:

```text
BROKEN_RESOLUTION
```

non nuova resolution.

---

# 16. Environment build

Precedence già fissata:

```text
1 inherited/sanitized Host Base Environment
2 RumiAI Base Environment
3 active Resolved Integration Profile environment
4 root Package Environment Specification
5 selected Command-specific overlay
6 explicit invocation overrides
```

Private dependency resource references sono exact tramite gN graph.

PATH è materializzato come path-list con separator platform-specific soltanto alla process boundary.

---

# 17. Host PATH is not dependency fallback

L'Host Base Environment può contenere:

```text
PATH
JAVA_HOME
PYTHONHOME
...
```

Package/profile operations possono modificarli secondo il model.

Ma un missing exact provider non viene risolto cercando:

```text
java
python
ffmpeg
```

nell'host PATH.

Risultato:

```text
BROKEN_RESOLUTION
```

---

# 18. State routing before exec

Se il resolved command binding usa:

```text
state = foo@sN
```

il launcher deve verificare che la package-local:

```text
pkg/<id>/run/
```

rappresenti la runtime routing view corretta.

Se il contenuto derivato manca/corrotto può essere ricostruito dal state mapping + exact State Instance binding.

`run/` reconstruction non cambia la Package Instance identity.

---

# 19. One runtime view invariant

Il v0 mantiene:

```text
one active run/ view per Package Instance
```

Poiché esiste una sola State Instance per package/state identity e i profile v0 non introducono named parallel State Instance, i normal launch dello stesso environment convergono sulla stessa routing view.

Un futuro multi-state parallelism richiederà una diversa runtime-view architecture e non viene anticipato.

---

# 20. Public default profile

La root Execution View:

```text
RUMIAI_ROOT/bin/
RUMIAI_ROOT/bin/@platforms/...
```

rappresenta il public profile:

```text
default
```

Altri Integration Profile possono essere persistiti/risolti ma non vengono automaticamente fusi nel root `bin/` namespace.

Una shell/execution context alternativa può usare un profile-specific view/launcher scope futuro o una invocazione esplicita del launcher.

Questo preserva il caso storico di ambienti/shell differenti senza avere più default public profile simultanei nello stesso namespace.

---

# 21. Execution View reconciliation

Sotto `manager.lock`, dopo/attorno a una candidate generation commit:

```text
ensure stubs required by candidate exist
validate stub implementation
atomic active switch
remove obsolete stubs opportunistically
```

Cleanup non fa parte dell'atomic truth switch.

Source of truth:

```text
active Resolution Snapshot
```

Non:

```text
current list of files in bin/
```

---

# 22. Recovery

Rebuild algorithm:

```text
read active generation
compute required cross/native public command keys
create/repair missing Command Stub
remove or leave harmless stale stub according to cleanup policy
```

Un missing stub è:

```text
EXECUTION_VIEW_INCOMPLETE
```

ma non modifica il resolved graph.

Un stale stub che non ha binding nell'active generation è semantically inactive.

---

# 23. Error classes

```text
COMMAND_NOT_ACTIVE
COMMAND_STUB_ERROR
EXECUTION_VIEW_INCOMPLETE
LAUNCH_BINDING_ERROR
LAUNCH_ENVIRONMENT_ERROR
BROKEN_RESOLUTION
STATE_ROUTING_ERROR
```

---

# 24. Invarianti

```text
LM-01 command stub è derived Execution View, non source of truth
LM-02 stub non embed exact provider/generation
LM-03 public command key = profile + scope + name
LM-04 launcher legge active una sola volta per launch
LM-05 launch usa exact immutable generation
LM-06 launch non esegue dependency resolution
LM-07 new stub prima del switch non può lanciare candidate binding
LM-08 stale stub dopo removal non può lanciare old binding
LM-09 target change di existing command avviene atomicamente via active pointer
LM-10 native/cross same name restano scope distinti
LM-11 direct cross pathname bypassa native PATH specialization intenzionalmente
LM-12 physical stub technique è platform-adapter concern
LM-13 argv non passa attraverso shell reinterpretation semantica
LM-14 host PATH non è dependency fallback
LM-15 run/ è verificata/ricostruita prima del process launch quando necessaria
LM-16 root bin namespace rappresenta public default profile
LM-17 bin listing non è authoritative integration state
```

---

# 25. Stress result

Il modello copre:

```text
same public command across package upgrade
provider change without stub rewrite
new command
removed command
native specialization
private Java/Python runtime
hosted command
state routing
environment isolation
crash leaving stale/new stubs
```

Nessuno di questi casi richiede re-resolution durante il launch.

---

# 26. Prossimo passo

A questo punto il core package-manager architecture v0 ha una catena completa:

```text
Package Instance
→ @package schema
→ Desired Profile
→ resolver
→ immutable Resolution Generation
→ active pointer
→ stable Command Stub
→ RumiAI Launcher
→ exact Execution Environment
→ process
```

Prima di un PoC restano soprattutto **specification details**, non nuovi oggetti architetturali:

```text
canonical integrity pathname escaping/method 1
physical stub implementation per reference platform
atomic rename/lock physical validation
exact filesystem bootstrap/migration of var/pkg
```

Questi possono essere chiusi con targeted physical validation senza riaprire il modello logico.