# Decisione — Package catalog `jq`

Date: 2026-09-15  
Status: **Accepted**

## 1. Scopo

Questa decisione fissa la prima package definition RumiAI per `jq`, usando esclusivamente primitive package già consolidate più la modalità `format=executable` definita nella decisione `2026-09-15-package-single-executable-materialization.md`.

Non viene introdotto un repository adapter specifico per jq: le release ufficiali e i relativi asset sono pubblicati direttamente nel repository GitHub `jqlang/jq`, quindi l'adapter `github` corrente è sufficiente.

## 2. Package e repository

Package name:

```text
jq
```

Repository descriptor per ogni stream:

```text
repository/type        github
repository/owner       jqlang
repository/repository  jq
```

Il command pubblico dichiarato dal package è:

```text
jq
```

## 3. Target iniziali

La prima definizione usa i sei target correnti del package model:

```text
linux-arm64
linux-x86_64
macos-arm64
macos-x86_64
windows-arm64
windows-x86_64
```

Ogni target usa uno stream completo `catalog-<osarch>/`; non esiste merge o fallback per-versione verso un catalogo generic.

## 4. Anchor iniziale

L'anchor comune iniziale è:

```text
n0001=jq-1.8.2
```

`jq-1.8.2` è scelto come baseline comune perché la release ufficiale 1.8.2 include anche l'asset Windows ARM64, consentendo ai sei stream di partire dallo stesso anchor senza inventare compatibilità retroattiva per asset non verificati.

Le release successive restano nell'ultimo range finché il loro contratto di artifact/materialization/integration resta semanticamente equivalente.

## 5. Mapping degli asset

Il mapping iniziale è:

```text
linux-x86_64    jq-linux-amd64
linux-arm64     jq-linux-arm64
macos-x86_64    jq-macos-amd64
macos-arm64     jq-macos-arm64
windows-x86_64  jq-windows-amd64.exe
windows-arm64   jq-windows-arm64.exe
```

Ogni stream usa un `archive_regex` ancorato che seleziona esattamente il relativo asset:

```text
linux-x86_64    ^jq-linux-amd64$
linux-arm64     ^jq-linux-arm64$
macos-x86_64    ^jq-macos-amd64$
macos-arm64     ^jq-macos-arm64$
windows-x86_64  ^jq-windows-amd64\.exe$
windows-arm64   ^jq-windows-arm64\.exe$
```

## 6. Integrity e materializzazione

Ogni range dichiara:

```text
digest_type  sha256
format       executable
```

Non è necessario `digest_regex`: l'adapter GitHub usa il digest SHA-256 pubblicato nei metadata del release asset secondo il contratto corrente.

L'artifact jq viene quindi scaricato e verificato da `pkg_download`, materializzato come single executable da `pkg_extract`, e consegnato a `pkg_integrate` come useful root contenente direttamente l'asset.

Non vengono introdotti source build, post-install script, `chmod` catalog field o wrapper di materializzazione specifici per jq.

## 7. Command e link

Ogni range contiene un command body `cmd/jq` che usa il launcher package standard:

```sh
#!/usr/bin/env m

. "$m_LIB_DIR/sys/sh/pkg-launch.lib.sh"

launcher "jq" "$@"
```

Il relativo `link/jq` contiene il basename dell'asset dello stream, ad esempio:

```text
jq-linux-amd64
```

oppure:

```text
jq-windows-arm64.exe
```

Il catalog source command resta regular, readable e non executable; `pkg_integrate` materializza la copia command executable secondo il contratto esistente.

## 8. State, environment e dipendenze

La baseline jq non introduce:

```text
env
dependency
facility
var
setuid_root
```

perché il caso corrente non richiede tali primitive.

L'assenza di questi campi non costituisce una regola universale per future versioni: un nuovo range sarà necessario se una release futura modifica semanticamente i requisiti di integrazione.

## 9. Invarianti

```text
JQ-PKG-01  package name = jq
JQ-PKG-02  repository = github / jqlang / jq
JQ-PKG-03  baseline = sei stream target-specific correnti
JQ-PKG-04  anchor iniziale comune = jq-1.8.2
JQ-PKG-05  ogni stream seleziona esattamente l'asset ufficiale fissato per il relativo osarch
JQ-PKG-06  digest_type = sha256 e il digest proviene dai GitHub release asset metadata
JQ-PKG-07  format = executable
JQ-PKG-08  command pubblico dichiarato = jq tramite launcher standard
JQ-PKG-09  link/jq punta direttamente al basename dell'asset materializzato nella useful root
JQ-PKG-10  nessun adapter jq, build phase, post-install script o permission metadata viene introdotto
```
