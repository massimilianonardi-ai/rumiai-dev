# `@package` schema v0 — reference descriptor stress cases

Data: 2026-08-30

Stato: **architectural schema stress test — capability references aligned to contract v1 and platform/content separation**

Questi frammenti verificano le sezioni semantiche che differiscono fra i casi. Identity/release/integrity seguono lo schema v0 già fissato; gli integrity inventory completi non vengono ripetuti qui.

Non sono manifest upstream normativi: rappresentano packaging RumiAI normalizzati di riferimento.

Principio platform fissato:

> `platform`/`architecture` descrivono soltanto i vincoli propri del contenuto della Package Instance. Runtime/interpreti/SDK richiesti sono Execution Requirements.

---

# 1. Temurin 21 provider

Temurin è un provider native per la piattaforma/architettura concreta, per esempio `linux-arm64`.

```toml
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
contract = 1
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
contract = 1
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

Stress result:

```text
native provider
multiple commands
multiple capability contracts
PASS
```

---

# 2. NetBeans consumer

Identity di riferimento quando il contenuto normalizzato non ha vincoli nativi propri:

```text
netbeans@26@r1@any-any
```

Normalized writable islands:

```text
root/etc      -> ../run/etc
root/userdir  -> ../run/userdir
root/cache    -> ../run/cache
root/log      -> ../run/log
```

```toml
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
contract = 1
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

Possible resolution on Linux ARM64:

```text
netbeans@26@r1@any-any
└── jdk
    └── temurin@21.0.8+9@r1@linux-arm64
        satisfies java-development-kit contract 1 version 21
```

Possible resolution on macOS ARM64:

```text
netbeans@26@r1@any-any
└── jdk
    └── temurin@21.0.8+9@r1@macos-arm64
```

Stress result:

```text
portable-content consumer
private native runtime provider
state routing
JAVA_HOME/PATH isolation
PASS
```

---

# 3. Python 3.12 provider

Il runtime Python concreto è normalmente una Package Instance native, per esempio `linux-arm64`.

```toml
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
contract = 1
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

Stress result:

```text
major.minor capability version scheme
native provider of a runtime capability
PASS
```

---

# 4. Python hosted application

Identity di riferimento se script/resource propri sono OS/CPU-independent:

```text
example-app@...@any-any
```

```toml
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
contract = 1
constraint = "=3.12"

[[environment]]
name = "PATH"
operation = "prepend"
type = "path-list"
value = { source = "dependency", slot = "python", resource-type = "directory", resource = "bin" }
```

Stress result:

```text
any-any package content
hosted command
fixed argv
private native interpreter provider
PASS
```

Se la Package Instance contiene una native extension obbligatoria, l'identity deve invece riflettere il relativo native platform/architecture.

---

# 5. Pulsar Electron/self-contained

Pulsar non viene considerato Java-dependent. La sua identity platform/architecture dipende dal contenuto concreto dell'artifact normalizzato.

```toml
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

No `requirements` section per Java.

Stress result:

```text
self-contained Electron app
no artificial Java dependency
platform determined by own artifact content
PASS
```

---

# 6. Cross-case conclusion

Covered:

```text
native runtime provider
any-any consumer content
capability contract identity
capability compatibility constraint
private runtime resolution
direct command
hosted command
argv composition
state/no-state
writable islands
environment set/prepend
multiple capabilities
self-contained app
orthogonality of platform identity and Execution Requirements
```

Not required:

```text
jvm/python execution-domain platform
shell metadata
env/ physical directory
absolute path
virtual package
optional dependency
OR constraint
runtime re-resolution
provider fallback at launch
```

Result:

```text
PASS
```

No new primitive is required by these reference cases.