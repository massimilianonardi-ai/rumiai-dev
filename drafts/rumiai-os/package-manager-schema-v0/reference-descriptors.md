# `@package` schema v0 — reference descriptors

Data: 2026-08-30

Stato: **architectural schema stress test — no PoC**

Questi esempi verificano che lo schema v0 possa rappresentare casi differenti senza introdurre nuove primitive.

Non sono manifest di release reali e non pretendono di descrivere esattamente i layout upstream dei prodotti citati. I tree sono **normalizzati RumiAI di riferimento** e gli integrity digest sono abbreviati.

---

# 1. JDK provider — Temurin 21 / Linux ARM64

Obiettivi stressati:

```text
native Package Instance
multiple Package Interface resources
multiple command resources
multiple provided capabilities
no State Instance
no Execution Requirement
```

```toml
schema = 1

[identity]
name = "temurin"
version = "21.0.8+9"
revision = 1
platform = "linux"
architecture = "arm64"
display-name = "Eclipse Temurin 21"

[release]
release-order = 108

[integrity]
method = 1
algorithm = "sha256"

[integrity.root]
files = 2
directories = 2
links = 0
manifest-digest = "root-manifest-digest-placeholder"
records = [
  "D\t0500\t.",
  "D\t0500\t./bin",
  "java-digest\tF\t0500\t./bin/java",
  "javac-digest\tF\t0500\t./bin/javac",
]

[integrity.run-default]
files = 0
directories = 1
links = 0
manifest-digest = "defaults-manifest-digest-placeholder"
records = [
  "D\t0500\t.",
]

[[interface.directories]]
id = "home"
path = "."

[[interface.directories]]
id = "bin"
path = "bin"

[[interface.files]]
id = "java-exe"
path = "bin/java"

[[interface.files]]
id = "javac-exe"
path = "bin/javac"

[[interface.commands]]
id = "java"
executable = { source = "self", resource-type = "file", resource = "java-exe" }
args = []

[[interface.commands]]
id = "javac"
executable = { source = "self", resource-type = "file", resource = "javac-exe" }
args = []

[[interface.provides]]
capability = "java-runtime"
version = "21"

[[interface.provides.resources]]
key = "command"
resource-type = "command"
resource = "java"

[[interface.provides.resources]]
key = "home"
resource-type = "directory"
resource = "home"

[[interface.provides.resources]]
key = "bin"
resource-type = "directory"
resource = "bin"

[[interface.provides]]
capability = "java-development-kit"
version = "21"

[[interface.provides.resources]]
key = "java"
resource-type = "command"
resource = "java"

[[interface.provides.resources]]
key = "javac"
resource-type = "command"
resource = "javac"

[[interface.provides.resources]]
key = "home"
resource-type = "directory"
resource = "home"

[[interface.provides.resources]]
key = "bin"
resource-type = "directory"
resource = "bin"
```

Esito:

```text
PASS — nessuna nuova primitive richiesta
```

---

# 2. NetBeans consumer — JVM-any

Obiettivi stressati:

```text
cross-platform Package Instance
private native JDK dependency
State Instance
writable-island routing
JAVA_HOME override
PATH private prepend
public command che usa self executable
```

Il layout normalizzato di riferimento assume:

```text
root/etc      -> ../run/etc
root/userdir  -> ../run/userdir
root/cache    -> ../run/cache
root/log      -> ../run/log
```

```toml
schema = 1

[identity]
name = "netbeans"
version = "26"
revision = 1
platform = "jvm"
architecture = "any"
display-name = "NetBeans 26"

[release]
release-order = 26

[integrity]
method = 1
algorithm = "sha256"

[integrity.root]
files = 1
directories = 2
links = 4
manifest-digest = "root-manifest-digest-placeholder"
records = [
  "D\t0500\t.",
  "D\t0500\t./bin",
  "launcher-digest\tF\t0500\t./bin/netbeans",
  "etc-target-digest\tL\t./etc\t../run/etc",
  "userdir-target-digest\tL\t./userdir\t../run/userdir",
  "cache-target-digest\tL\t./cache\t../run/cache",
  "log-target-digest\tL\t./log\t../run/log",
]

[integrity.run-default]
files = 1
directories = 5
links = 0
manifest-digest = "defaults-manifest-digest-placeholder"
records = [
  "D\t0500\t.",
  "D\t0500\t./cache",
  "D\t0500\t./etc",
  "D\t0500\t./log",
  "D\t0500\t./userdir",
  "config-digest\tF\t0400\t./etc/netbeans.conf",
]

[state]
compatibility-version = 1
scope = "shared"

[[state.mappings]]
path = "etc"
area = "conf"

[[state.mappings]]
path = "userdir"
area = "home"

[[state.mappings]]
path = "cache"
area = "cache"

[[state.mappings]]
path = "log"
area = "log"

[[interface.files]]
id = "launcher"
path = "bin/netbeans"

[[interface.commands]]
id = "netbeans"
executable = { source = "self", resource-type = "file", resource = "launcher" }
args = []

[[requirements]]
slot = "jdk"
target = "capability"
capability = "java-development-kit"
constraint = ">=17 <22"

[[environment]]
name = "JAVA_HOME"
operation = "set"
type = "path"
value = { source = "dependency", slot = "jdk", resource-type = "directory", resource = "home" }

[[environment]]
name = "PATH"
operation = "prepend"
type = "path-list"
value = { source = "dependency", slot = "jdk", resource-type = "directory", resource = "bin" }
```

Resolution possibile su Linux ARM64:

```text
netbeans@26@r1@jvm-any
└── slot jdk
    └── temurin@21.0.8+9@r1@linux-arm64
```

Il default Java pubblico del sistema non viene modificato.

Esito:

```text
PASS — private runtime isolation rappresentata senza wrapper shell o absolute path
```

---

# 3. Python runtime provider — Python 3.12

Obiettivi stressati:

```text
capability version scheme major.minor
native runtime provider
command + home + bin resources
```

```toml
schema = 1

[identity]
name = "python"
version = "3.12.11"
revision = 1
platform = "linux"
architecture = "arm64"
display-name = "Python 3.12"

[release]
release-order = 31211

[integrity]
method = 1
algorithm = "sha256"

[integrity.root]
files = 1
directories = 2
links = 0
manifest-digest = "root-manifest-digest-placeholder"
records = [
  "D\t0500\t.",
  "D\t0500\t./bin",
  "python-digest\tF\t0500\t./bin/python3",
]

[integrity.run-default]
files = 0
directories = 1
links = 0
manifest-digest = "defaults-manifest-digest-placeholder"
records = [
  "D\t0500\t.",
]

[[interface.directories]]
id = "home"
path = "."

[[interface.directories]]
id = "bin"
path = "bin"

[[interface.files]]
id = "python-exe"
path = "bin/python3"

[[interface.commands]]
id = "python"
executable = { source = "self", resource-type = "file", resource = "python-exe" }
args = []

[[interface.provides]]
capability = "python-runtime"
version = "3.12"

[[interface.provides.resources]]
key = "command"
resource-type = "command"
resource = "python"

[[interface.provides.resources]]
key = "home"
resource-type = "directory"
resource = "home"

[[interface.provides.resources]]
key = "bin"
resource-type = "directory"
resource = "bin"
```

Esito:

```text
PASS
```

---

# 4. Python application consumer — hosted command

Obiettivi stressati:

```text
command executable fornito da dependency
fixed argv resource
private Python runtime
State Instance separata
```

```toml
schema = 1

[identity]
name = "example-python-app"
version = "1.0"
revision = 1
platform = "python"
architecture = "any"
display-name = "Example Python App"

[release]
release-order = 1

[integrity]
method = 1
algorithm = "sha256"

[integrity.root]
files = 1
directories = 2
links = 2
manifest-digest = "root-manifest-digest-placeholder"
records = [
  "D\t0500\t.",
  "D\t0500\t./app",
  "app-digest\tF\t0400\t./app/main.py",
  "config-target-digest\tL\t./config\t../run/config",
  "data-target-digest\tL\t./data\t../run/data",
]

[integrity.run-default]
files = 1
directories = 3
links = 0
manifest-digest = "defaults-manifest-digest-placeholder"
records = [
  "D\t0500\t.",
  "D\t0500\t./config",
  "D\t0500\t./data",
  "settings-digest\tF\t0400\t./config/settings.toml",
]

[state]
compatibility-version = 1
scope = "shared"

[[state.mappings]]
path = "config"
area = "conf"

[[state.mappings]]
path = "data"
area = "data"

[[interface.files]]
id = "main-script"
path = "app/main.py"

[[interface.commands]]
id = "example-app"
executable = { source = "dependency", slot = "python", resource-type = "command", resource = "python" }
args = [
  { source = "self", resource-type = "file", resource = "main-script" },
]

[[requirements]]
slot = "python"
target = "capability"
capability = "python-runtime"
constraint = "=3.12"

[[environment]]
name = "PATH"
operation = "prepend"
type = "path-list"
value = { source = "dependency", slot = "python", resource-type = "directory", resource = "bin" }
```

Esito:

```text
PASS — hosted command/argv espresso senza shell
```

---

# 5. Pulsar — Electron/self-contained

Obiettivi stressati:

```text
self-contained native application
nessuna Java dependency
state routing
single direct command
```

```toml
schema = 1

[identity]
name = "pulsar"
version = "1.130.0"
revision = 1
platform = "linux"
architecture = "arm64"
display-name = "Pulsar"

[release]
release-order = 113000

[integrity]
method = 1
algorithm = "sha256"

[integrity.root]
files = 1
directories = 2
links = 3
manifest-digest = "root-manifest-digest-placeholder"
records = [
  "D\t0500\t.",
  "D\t0500\t./bin",
  "pulsar-digest\tF\t0500\t./bin/pulsar",
  "config-target-digest\tL\t./config\t../run/config",
  "cache-target-digest\tL\t./cache\t../run/cache",
  "log-target-digest\tL\t./log\t../run/log",
]

[integrity.run-default]
files = 0
directories = 4
links = 0
manifest-digest = "defaults-manifest-digest-placeholder"
records = [
  "D\t0500\t.",
  "D\t0500\t./cache",
  "D\t0500\t./config",
  "D\t0500\t./log",
]

[state]
compatibility-version = 1
scope = "shared"

[[state.mappings]]
path = "config"
area = "conf"

[[state.mappings]]
path = "cache"
area = "cache"

[[state.mappings]]
path = "log"
area = "log"

[[interface.files]]
id = "pulsar-exe"
path = "bin/pulsar"

[[interface.commands]]
id = "pulsar"
executable = { source = "self", resource-type = "file", resource = "pulsar-exe" }
args = []
```

Esito:

```text
PASS — nessun requirement artificiale
```

---

# 6. Cross-case result

I cinque descriptor esercitano:

```text
native and cross-platform identity
provider and consumer roles
capability constraints
private runtime resolution
direct command
hosted command
fixed argv
state/no-state packages
writable-island mappings
persistent + disposable state areas
environment set
PATH prepend
multiple capabilities from one provider
self-contained Electron app
```

Non è emersa la necessità di aggiungere nel v0:

```text
shell script metadata
env/ physical directory
absolute pathname
virtual package
optional dependency
OR constraint
runtime re-resolution
provider fallback at launch
```

---

# 7. Osservazione emersa: execution-domain vocabulary

Gli esempi usano:

```text
jvm-any
python-any
```

come execution domain cross-platform.

Questo conferma la necessità già emersa di distinguere concettualmente:

```text
native platform target
execution domain target
```

ma non richiede una nuova primitive nello schema: entrambi continuano a essere rappresentati dai campi canonici:

```text
platform
architecture
```

La lista normativa dei platform/domain token deve essere fissata separatamente.

---

# 8. Schema stress conclusion

Esito complessivo:

```text
PASS
```

Lo schema `@package` v0 è sufficiente per i reference case scelti senza introdurre nuovi concetti fondamentali.

Il prossimo nodo è lo **schema Desired/Resolved Integration State v0**.