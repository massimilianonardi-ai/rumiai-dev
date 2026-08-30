# `@package` schema v0 — reference descriptor stress cases

Data: 2026-08-30

Stato: **architectural schema stress test — SCF dot notation + tabular integrity**

Gli esempi mostrano soltanto le sezioni rilevanti; identity/release/integrity metadata seguono lo schema v0.

---

# 1. Temurin 21 provider

```text
interface.directories.count	2
interface.directories.1.id	home
interface.directories.1.path	.
interface.directories.2.id	bin
interface.directories.2.path	bin

interface.files.count	2
interface.files.1.id	java-exe
interface.files.1.path	bin/java
interface.files.2.id	javac-exe
interface.files.2.path	bin/javac

interface.commands.count	2
interface.commands.1.id	java
interface.commands.1.executable.source	self
interface.commands.1.executable.resource_type	file
interface.commands.1.executable.resource	java-exe
interface.commands.1.args.count	0
interface.commands.2.id	javac
interface.commands.2.executable.source	self
interface.commands.2.executable.resource_type	file
interface.commands.2.executable.resource	javac-exe
interface.commands.2.args.count	0

interface.provides.count	2
interface.provides.1.capability	java-runtime
interface.provides.1.contract	1
interface.provides.1.version	21
interface.provides.1.resources.count	3
interface.provides.1.resources.1.key	command
interface.provides.1.resources.1.resource_type	command
interface.provides.1.resources.1.resource	java
interface.provides.1.resources.2.key	home
interface.provides.1.resources.2.resource_type	directory
interface.provides.1.resources.2.resource	home
interface.provides.1.resources.3.key	bin
interface.provides.1.resources.3.resource_type	directory
interface.provides.1.resources.3.resource	bin

interface.provides.2.capability	java-development-kit
interface.provides.2.contract	1
interface.provides.2.version	21
interface.provides.2.resources.count	4
interface.provides.2.resources.1.key	java
interface.provides.2.resources.1.resource_type	command
interface.provides.2.resources.1.resource	java
interface.provides.2.resources.2.key	javac
interface.provides.2.resources.2.resource_type	command
interface.provides.2.resources.2.resource	javac
interface.provides.2.resources.3.key	home
interface.provides.2.resources.3.resource_type	directory
interface.provides.2.resources.3.resource	home
interface.provides.2.resources.4.key	bin
interface.provides.2.resources.4.resource_type	directory
interface.provides.2.resources.4.resource	bin
```

Provider identity native, per esempio:

```text
temurin@21.0.8+9@r1@linux-arm64
```

PASS.

---

# 2. NetBeans consumer `any-any`

Writable islands:

```text
root/etc      -> ../run/etc
root/userdir  -> ../run/userdir
root/cache    -> ../run/cache
root/log      -> ../run/log
```

Descriptor sections:

```text
state.present	true
state.compatibility_version	1
state.scope	shared
state.mappings.count	4
state.mappings.1.path	etc
state.mappings.1.area	conf
state.mappings.2.path	userdir
state.mappings.2.area	home
state.mappings.3.path	cache
state.mappings.3.area	cache
state.mappings.4.path	log
state.mappings.4.area	log

interface.files.count	1
interface.files.1.id	launcher
interface.files.1.path	bin/netbeans
interface.directories.count	0
interface.commands.count	1
interface.commands.1.id	netbeans
interface.commands.1.executable.source	self
interface.commands.1.executable.resource_type	file
interface.commands.1.executable.resource	launcher
interface.commands.1.args.count	0
interface.provides.count	0

requirements.count	1
requirements.1.slot	jdk
requirements.1.target	capability
requirements.1.capability	java-development-kit
requirements.1.contract	1
requirements.1.constraint	>=17 <22

environment.count	2
environment.1.name	JAVA_HOME
environment.1.operation	set
environment.1.type	path
environment.1.value.source	dependency
environment.1.value.slot	jdk
environment.1.value.resource_type	directory
environment.1.value.resource	home
environment.2.name	PATH
environment.2.operation	prepend
environment.2.type	path-list
environment.2.value.source	dependency
environment.2.value.slot	jdk
environment.2.value.resource_type	directory
environment.2.value.resource	bin
```

Possible resolution:

```text
netbeans@26@r1@any-any
└── jdk -> temurin@21.0.8+9@r1@linux-arm64
```

PASS.

---

# 3. Python runtime provider

```text
interface.directories.count	2
interface.directories.1.id	home
interface.directories.1.path	.
interface.directories.2.id	bin
interface.directories.2.path	bin
interface.files.count	1
interface.files.1.id	python-exe
interface.files.1.path	bin/python3
interface.commands.count	1
interface.commands.1.id	python
interface.commands.1.executable.source	self
interface.commands.1.executable.resource_type	file
interface.commands.1.executable.resource	python-exe
interface.commands.1.args.count	0
interface.provides.count	1
interface.provides.1.capability	python-runtime
interface.provides.1.contract	1
interface.provides.1.version	3.12
interface.provides.1.resources.count	3
interface.provides.1.resources.1.key	command
interface.provides.1.resources.1.resource_type	command
interface.provides.1.resources.1.resource	python
interface.provides.1.resources.2.key	home
interface.provides.1.resources.2.resource_type	directory
interface.provides.1.resources.2.resource	home
interface.provides.1.resources.3.key	bin
interface.provides.1.resources.3.resource_type	directory
interface.provides.1.resources.3.resource	bin
```

Provider native, per esempio `cpython@...@linux-arm64`.

PASS.

---

# 4. Python hosted application `any-any`

```text
interface.files.count	1
interface.files.1.id	main-script
interface.files.1.path	app/main.py
interface.directories.count	0
interface.commands.count	1
interface.commands.1.id	example-app
interface.commands.1.executable.source	dependency
interface.commands.1.executable.slot	python
interface.commands.1.executable.resource_type	command
interface.commands.1.executable.resource	python
interface.commands.1.args.count	1
interface.commands.1.args.1.source	self
interface.commands.1.args.1.resource_type	file
interface.commands.1.args.1.resource	main-script
interface.provides.count	0
requirements.count	1
requirements.1.slot	python
requirements.1.target	capability
requirements.1.capability	python-runtime
requirements.1.contract	1
requirements.1.constraint	=3.12
```

PASS.

---

# 5. Pulsar Electron/self-contained

```text
interface.files.count	1
interface.files.1.id	pulsar-exe
interface.files.1.path	bin/pulsar
interface.directories.count	0
interface.commands.count	1
interface.commands.1.id	pulsar
interface.commands.1.executable.source	self
interface.commands.1.executable.resource_type	file
interface.commands.1.executable.resource	pulsar-exe
interface.commands.1.args.count	0
interface.provides.count	0
requirements.count	0
```

Nessun requirement Java artificiale.

PASS.

---

# 6. Integrity metadata + tabular data

`@package` metadata:

```text
integrity.method	1
integrity.algorithm	sha256
integrity.root.inventory	@integrity-root.tsv
integrity.root.files	2
integrity.root.directories	2
integrity.root.links	1
integrity.root.manifest_digest	...
integrity.run_default.inventory	@integrity-run-default.tsv
integrity.run_default.files	0
integrity.run_default.directories	1
integrity.run_default.links	0
integrity.run_default.manifest_digest	...
```

`@integrity-root.tsv`:

```text
type	mode	digest	target	path
D	0500	-	-	.
F	0400	<digest>	-	./app.jar
D	0500	-	-	./bin
F	0500	<digest>	-	./bin/foo
L	-	<digest-target>	../run/log	./log
```

Le data row sono ordinate per canonical pathname; il type non raggruppa le row.

PASS.

---

# 7. Dot notation stress result

Il modello rappresenta senza mini-language aggiuntive:

```text
namespace
nested object
array scalare
array di object
nested array
structured reference
arbitrary logical ID nei value
```

Nessuna scalar/namespace collision necessaria.

PASS.

---

# 8. Conclusion

Il modello copre senza nuove primitive:

```text
native runtime provider
any-any Java/Python consumer
private runtime resolution
state routing
environment isolation
hosted/direct commands
capability contracts
self-contained app
external streaming tabular integrity inventory
```

Result:

```text
PASS
```
