# Decisione — Physical validation ARM64 di `pkg-launch`

Date: 2026-09-10  
Status: **Validated**

## Scope

Questa evidence riguarda esclusivamente il contratto e l'implementazione del package launcher introdotti da:

```text
decisions/rumiai-os/2026-09-10-package-launch-library.md
rumiai-os/lib/sh/pkg-launch.lib.sh
rumiai-tests/tests/rumiai-os/pkg-launch/contract.test
```

La validation è revision-specific e non viene estesa implicitamente ad altre revisioni o ad altri layer package non selezionati.

Coppia validata:

```text
rumiai-os@b724bd1f3a4ea6fe0b968c5ea38e7db835fee179
rumiai-tests@463dec024053fa809b090d00b3965acd6127c92c
selection: rumiai-os/pkg-launch
```

Il catalogo DBeaver allineato al nuovo caricamento esplicito del launcher era:

```text
pkg-catalog@514cb620075188ec9ad9090f6bd008fcec85913f
```

Il catalogo non è consumato dal test permanente `pkg-launch/contract.test`; la revisione è registrata soltanto per identificare lo stato coerente del sottosistema al momento del gate.

---

## Ubuntu ARM64

Host osservato:

```text
OS: Ubuntu 26.04.1 LTS
architecture: aarch64
kernel: Linux 7.0.0-31-generic
```

Sessione:

```text
20260910T115759+0200-49756
validation ref: validation/20260910T115759+0200-49756
validation evidence commit: b37caa2d4c573db0c767617a0ae22cffc11cdba6
```

Risultato:

```text
PASS   rumiai-os/pkg-launch/contract.test
PASS   1
FAIL   0
SKIP   0
ERROR  0
TOTAL  1
runner exit status: 0
```

---

## macOS ARM64

Host osservato:

```text
OS: Darwin 26.6.2
architecture: arm64
kernel: Darwin 25.6.0
```

Sessione:

```text
20260910T115823+0200-49448
validation ref: validation/20260910T115823+0200-49448
validation evidence commit: 182879c7a9498a421c8fd4de49a9f398037b07cc
```

Risultato:

```text
PASS   rumiai-os/pkg-launch/contract.test
PASS   1
FAIL   0
SKIP   0
ERROR  0
TOTAL  1
runner exit status: 0
```

---

## Conclusione

Il baseline direct-link di `launcher` è fisicamente validato sui reference host ARM64 Ubuntu e macOS per la coppia revision-specific sopra indicata.

La validation conferma il contratto osservabile protetto dal test permanente, incluso:

```text
pkg-launch.lib.sh separato dal bootstrap/core
m_COMMAND_BIN come autorità sul command corrente
confinamento del direct-link nel root della stessa concrete version
HOME=$m_HOME_DIR/<pkg>
package env -> user env
assenza di export implicito tramite set -a
preservazione argv
final exec e propagazione dello status upstream
rifiuto di env sintatticamente invalido
rifiuto di command/link fuori dal package store/root previsto
```

Questa evidence **non** costituisce ancora physical validation di:

```text
pkg_integrate/pkg_deintegrate/pkg_default
orchestrazione reale pkg install
refresh GitHub reale del catalogo come percorso live end-to-end
installazione reale DBeaver da upstream
selezione DBeaver come default
launch reale DBeaver installato
Windows/MSYS2
```

Tali scope richiedono gate successivi proporzionati.

---

## Invarianti di evidence

```text
PKG-LAUNCH-VAL-01  la coppia validata è rumiai-os@b724bd1 + rumiai-tests@463dec0
PKG-LAUNCH-VAL-02  Ubuntu ARM64 e macOS ARM64 hanno entrambi PASS 1/1 senza FAIL/SKIP/ERROR
PKG-LAUNCH-VAL-03  le evidence remote restano sui rispettivi validation/<run-id>
PKG-LAUNCH-VAL-04  questa evidence non viene riattribuita a revisioni successive
PKG-LAUNCH-VAL-05  la validation del launcher non equivale a DBeaver end-to-end né a validation degli altri layer package
```
