# RumiAI package manager — Package Instance internal layout v0

Data: 2026-08-30

Stato: **design decision — struttura fisica Package Instance fissata**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-v0/README.md
drafts/rumiai-os/package-manager-local-layout/README.md
drafts/rumiai-os/package-manager-state-model/README.md
drafts/rumiai-os/package-manager-platform-vocabulary-v0/README.md
drafts/rumiai-os/package-manager-serialization-v0/README.md
```

---

# 1. Wrapper fisica

```text
pkg/<package-instance-id>/
├── root/
├── run-default/
├── @package
└── run/
```

Core immutabile:

```text
root/
run-default/
@package
```

`run/` è derivata, ricostruibile e non partecipa a identity/integrity.

Package pathname:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

Platform/architecture v0 descrivono soltanto vincoli del contenuto:

```text
platform     any | linux | macos | windows
architecture any | arm64 | x86_64
```

Runtime/interpreti/SDK come Java/JDK/JRE/Python sono requirements, non platform token.

---

# 2. `root/`

`root/` è l'execution tree normalizzato e immutabile.

Non deve coincidere byte-per-byte con il vendor tree.

Prima dell'admission il producer può normalizzare writable paths; dopo admission:

```text
root/ non cambia durante install/integrate/execute
```

Se non è possibile produrre una root fissa e sicura:

```text
REJECTED
```

---

# 3. Writable islands

Preferenza forte per redirection a livello directory:

```text
root/log   -> ../run/log
root/conf  -> ../run/conf
root/cache -> ../run/cache
```

Questo evita che atomic replace/unlink di singoli file distrugga file-level symlink.

File-level redirection è ammessa solo se fisicamente validata come sicura.

I symlink `root -> run` fanno parte dell'integrity di `root/`; si verifica il target testuale senza dereferenziare lo state mutabile.

---

# 4. `run/`

Ogni Package Instance ha una sola runtime view attiva.

Esempio:

```text
root/log -> ../run/log
run/log  -> ../../../log/<state-id>/log
```

`run/` viene creata prima del sealing della wrapper.

Dopo commit non si sostituisce normalmente la directory `run/`; si ricostruisce il suo contenuto.

---

# 5. `run-default/`

Contiene factory defaults immutabili delle writable islands nei pathname attesi dal software.

Serve per:

```text
first State Instance initialization
factory reset
controlled default recovery
```

Factory reset copia/materializza default verso state mutabile; non rende mai `run-default/` writable.

---

# 6. `@package`

Descriptor dichiarativo immutabile, restricted TOML 1.0.

Contiene:

```text
schema
identity
release
integrity
state
interface
requirements
environment
```

Identity minima:

```text
name
version
revision
platform
architecture
display-name
```

I primi cinque campi canonici devono concordare con il pathname.

`display-name` è human-readable e non entra nel pathname.

Nessun `source`, `eval` o codice eseguibile.

---

# 7. Integrity

Si verificano separatamente:

```text
root/
run-default/
```

Metadata:

```text
integrity method/version
digest algorithm
file count
directory count
link count
manifest digest
canonical line inventory
```

Il v0 serializza `records` in `@package` come una singola multiline literal string TOML line-oriented.

Semantic record:

```text
D<TAB><mode><TAB><relative-path>
<digest><TAB>F<TAB><mode><TAB><relative-path>
<digest-target><TAB>L<TAB><relative-path><TAB><relative-target>
```

Regole:

```text
regular file: digest bytes + canonical mode
directory: canonical mode, no content digest
symlink: digest target text, no dereference
LF canonical line endings
LF finale obbligatorio
canonical record order
UID/GID/ACL/symlink mode excluded
```

Manifest digest = digest del canonical `records` block decodificato.

`run/` e target mutabili sono esclusi.

---

# 8. Mode normalizzati

Unix-like core immutable:

```text
regular non-executable  0400
regular executable      0500
directory immutable     0500
@package                0400
```

Write bit sotto `root/` o `run-default/` è incompatibile con v0.

Vietati nel core v0:

```text
POSIX ACL aggiuntive
setuid
setgid
sticky bit
```

---

# 9. Environment Owner

Nessun requisito `root:root`, utente `rumiai` o gruppo speciale.

Ogni RumiAI environment ha un solo Environment Owner.

UID/GID numerici:

```text
non identity
non integrity
non persisted RumiAI identity
```

Group sharing non supportato nel v0.

---

# 10. Permission layout Unix-like

Default:

```text
RUMIAI_ROOT/  0700
pkg/          0700
bin/          0700
conf/         0700
data/         0700
home/         0700
cache/        0700
log/          0700
run/          0700
tmp/          0700
```

Wrapper sealed:

```text
pkg/<id>/      0500
├── root/      0500
├── run-default/ 0500
├── @package   0400
└── run/       0700
```

Default process `umask`:

```text
0077
```

---

# 11. Immutability boundary

Permission proteggono dalle modifiche accidentali ma non creano security boundary contro l'Environment Owner, che possiede gli inode.

Contratto:

```text
immutability by contract
+
filesystem accidental-write protection
+
integrity verification
```

Non richiede:

```text
root ownership
privileged helper
read-only mount
immutable filesystem flag
```

---

# 12. Relocatability

Persisted reference relative/logical only.

Esempio:

```text
root/log -> ../run/log
run/log  -> ../../../log/<state-id>/log
```

Nessun absolute RUMIAI_ROOT nel descriptor.

Filesystem/mount semantics sono Physical Platform Validation input.

---

# 13. Materialization transaction

```text
candidate software
        ↓
pre-admission normalization
        ↓
build root + run-default + @package + empty run in staging
        ↓
normalize modes/ownership semantics
        ↓
verify identity/integrity/writable mappings
        ↓
atomic commit pkg/<package-id>
        ↓
seal wrapper
```

Staging non è un immediate child ordinario di `pkg/`.

---

# 14. Recovery

```text
@package missing/corrupt
    pathname still recovers minimal identity

root/run-default mismatch
    Package Instance corrupt

run missing/corrupt contents
    core may remain healthy; rebuild run contents
```

`pkg/` anti-ghost inventory classifica ogni immediate child.

---

# 15. Uninstall

Dopo reference/integration checks:

```text
unseal with Environment Owner permissions
remove pkg/<id>/
```

Nessun vendor uninstaller.

Uninstall non implica State Instance purge.

---

# 16. Invarianti

```text
PI-01 immutable core = root + run-default + @package
PI-02 run is derived and excluded from identity/integrity
PI-03 one active run view per Package Instance
PI-04 root remains immutable during normal execution
PI-05 unsafe/non-separable mutable tree => package rejected
PI-06 writable islands prefer directory-level relative symlink routing
PI-07 run-default contains immutable factory writable view
PI-08 @package = restricted TOML declarative descriptor
PI-09 package platform/architecture describes own content only
PI-10 Java/JDK/JRE/Python requirements do not alter package platform identity
PI-11 root/run-default integrity uses canonical line inventory + modes
PI-12 UID/GID are not portable identity/integrity
PI-13 no ACL/setuid/setgid/sticky in core v0
PI-14 single Environment Owner
PI-15 wrapper non-writable; run precreated and content-rebuilt
PI-16 staging not ordinary pkg child
PI-17 uninstall removes unique wrapper but not external state implicitly
```
