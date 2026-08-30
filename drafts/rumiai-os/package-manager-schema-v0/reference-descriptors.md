# `@package` schema v0 — reference descriptor stress cases

Data: 2026-08-30

Stato: **architectural schema stress test — JSON v0**

Gli esempi mostrano soltanto le sezioni rilevanti; identity/release/integrity metadata seguono lo schema v0.

---

# 1. Temurin 21 provider

```json
{
  "interface": {
    "directories": [
      { "id": "home", "path": "." },
      { "id": "bin", "path": "bin" }
    ],
    "files": [
      { "id": "java-exe", "path": "bin/java" },
      { "id": "javac-exe", "path": "bin/javac" }
    ],
    "commands": [
      {
        "id": "java",
        "executable": { "source": "self", "resource-type": "file", "resource": "java-exe" },
        "args": []
      },
      {
        "id": "javac",
        "executable": { "source": "self", "resource-type": "file", "resource": "javac-exe" },
        "args": []
      }
    ],
    "provides": [
      {
        "capability": "java-runtime",
        "contract": 1,
        "version": "21",
        "resources": [
          { "key": "command", "resource-type": "command", "resource": "java" },
          { "key": "home", "resource-type": "directory", "resource": "home" },
          { "key": "bin", "resource-type": "directory", "resource": "bin" }
        ]
      },
      {
        "capability": "java-development-kit",
        "contract": 1,
        "version": "21",
        "resources": [
          { "key": "java", "resource-type": "command", "resource": "java" },
          { "key": "javac", "resource-type": "command", "resource": "javac" },
          { "key": "home", "resource-type": "directory", "resource": "home" },
          { "key": "bin", "resource-type": "directory", "resource": "bin" }
        ]
      }
    ]
  }
}
```

Provider identity resta native, per esempio:

```text
temurin@21.0.8+9@r1@linux-arm64
```

PASS.

---

# 2. NetBeans consumer `any-any`

Normalized writable islands:

```text
root/etc      -> ../run/etc
root/userdir  -> ../run/userdir
root/cache    -> ../run/cache
root/log      -> ../run/log
```

```json
{
  "state": {
    "compatibility-version": 1,
    "scope": "shared",
    "mappings": [
      { "path": "etc", "area": "conf" },
      { "path": "userdir", "area": "home" },
      { "path": "cache", "area": "cache" },
      { "path": "log", "area": "log" }
    ]
  },
  "interface": {
    "files": [
      { "id": "launcher", "path": "bin/netbeans" }
    ],
    "commands": [
      {
        "id": "netbeans",
        "executable": { "source": "self", "resource-type": "file", "resource": "launcher" },
        "args": []
      }
    ]
  },
  "requirements": [
    {
      "slot": "jdk",
      "target": "capability",
      "capability": "java-development-kit",
      "contract": 1,
      "constraint": ">=17 <22"
    }
  ],
  "environment": [
    {
      "name": "JAVA_HOME",
      "operation": "set",
      "type": "path",
      "value": { "source": "dependency", "slot": "jdk", "resource-type": "directory", "resource": "home" }
    },
    {
      "name": "PATH",
      "operation": "prepend",
      "type": "path-list",
      "value": { "source": "dependency", "slot": "jdk", "resource-type": "directory", "resource": "bin" }
    }
  ]
}
```

Possible resolution:

```text
netbeans@26@r1@any-any
└── jdk -> temurin@21.0.8+9@r1@linux-arm64
```

PASS.

---

# 3. Python runtime provider

```json
{
  "interface": {
    "directories": [
      { "id": "home", "path": "." },
      { "id": "bin", "path": "bin" }
    ],
    "files": [
      { "id": "python-exe", "path": "bin/python3" }
    ],
    "commands": [
      {
        "id": "python",
        "executable": { "source": "self", "resource-type": "file", "resource": "python-exe" },
        "args": []
      }
    ],
    "provides": [
      {
        "capability": "python-runtime",
        "contract": 1,
        "version": "3.12",
        "resources": [
          { "key": "command", "resource-type": "command", "resource": "python" },
          { "key": "home", "resource-type": "directory", "resource": "home" },
          { "key": "bin", "resource-type": "directory", "resource": "bin" }
        ]
      }
    ]
  }
}
```

Provider è native, per esempio `cpython@...@linux-arm64`.

PASS.

---

# 4. Python hosted application `any-any`

```json
{
  "interface": {
    "files": [
      { "id": "main-script", "path": "app/main.py" }
    ],
    "commands": [
      {
        "id": "example-app",
        "executable": { "source": "dependency", "slot": "python", "resource-type": "command", "resource": "python" },
        "args": [
          { "source": "self", "resource-type": "file", "resource": "main-script" }
        ]
      }
    ]
  },
  "requirements": [
    {
      "slot": "python",
      "target": "capability",
      "capability": "python-runtime",
      "contract": 1,
      "constraint": "=3.12"
    }
  ]
}
```

PASS.

---

# 5. Pulsar Electron/self-contained

```json
{
  "interface": {
    "files": [
      { "id": "pulsar-exe", "path": "bin/pulsar" }
    ],
    "commands": [
      {
        "id": "pulsar",
        "executable": { "source": "self", "resource-type": "file", "resource": "pulsar-exe" },
        "args": []
      }
    ]
  }
}
```

Nessun requirement artificiale Java.

PASS.

---

# 6. Integrity metadata + TSV

Descriptor:

```json
{
  "integrity": {
    "method": 1,
    "algorithm": "sha256",
    "root": {
      "inventory": "@integrity-root.tsv",
      "files": 2,
      "directories": 2,
      "links": 1,
      "manifest-digest": "..."
    },
    "run-default": {
      "inventory": "@integrity-run-default.tsv",
      "files": 0,
      "directories": 1,
      "links": 0,
      "manifest-digest": "..."
    }
  }
}
```

`@integrity-root.tsv`:

```text
D	0500	-	-	.
D	0500	-	-	./bin
F	0500	<digest>	-	./bin/foo
F	0400	<digest>	-	./app.jar
L	-	<digest-target>	../run/log	./log
```

PASS.

---

# 7. Conclusion

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
external streaming integrity inventory
```

Result:

```text
PASS
```
