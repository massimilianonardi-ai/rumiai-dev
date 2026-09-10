# Decisione — Physical validation ARM64 della revisione DMG di RumiAI OS

Date: 2026-09-10  
Status: **Validated**

## Scope

Questa evidence registra la validation completa del gruppo `rumiai-os` dopo l'introduzione del backend `dmg` native-first in `bin/sys/extract`.

La revisione prodotto validata preferisce il backend composto `hdiutil` + `ditto` quando entrambe le capability sono disponibili e usa `7zz`, `7z`, `7za` come fallback esclusivamente per indisponibilità iniziale della capability. Un errore operativo del backend selezionato non provoca retry.

La validation è revision-specific e non viene estesa implicitamente a revisioni successive.

Coppia validata:

```text
rumiai-os@a2531626b68e81c9df4e76a007e7f963b3f26343
rumiai-tests@9198a69f62a5f77c390cc015f193bbfb117fdc47
selection: rumiai-os
```

Il catalogo DBeaver corrente resta:

```text
pkg-catalog@514cb620075188ec9ad9090f6bd008fcec85913f
```

Il gruppo `rumiai-os` usa backend fake deterministici per il dispatch di `extract` e fixture/local repository per i test package. Questa validation verifica la revisione prodotto sui reference host e la semantica permanente del dispatch, ma **non** costituisce evidence dell'esecuzione reale `hdiutil` + `ditto` sul DMG DBeaver nel percorso `pkg install` live. Tale confine resta al gate `external/dbeaver/install-live.test`.

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
20260910T154533+0200-80748
validation ref: validation/20260910T154533+0200-80748
validation evidence commit: a402b3c51a38e1bd2ac9a7bdadc4709e20169151
```

Risultato:

```text
PASS   65
FAIL   0
SKIP   2
ERROR  0
TOTAL  67
runner exit status: 0
```

I due `SKIP` sono esclusivamente:

```text
rumiai-os/shell/zsh-alias-preservation.test
rumiai-os/shell/zsh-zdotdir-preservation.test
```

perché Zsh non è disponibile sull'host.

`rumiai-os/extract/dispatch.test` ha prodotto `PASS`.

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
20260910T154553+0200-82955
validation ref: validation/20260910T154553+0200-82955
validation evidence commit: cb62d6b64a18f5bedd64b6a52c76a7690da447b6
```

Risultato:

```text
PASS   67
FAIL   0
SKIP   0
ERROR  0
TOTAL  67
runner exit status: 0
```

`rumiai-os/extract/dispatch.test` ha prodotto `PASS` anche su macOS ARM64.

---

## Run precedenti con difetto dell'harness

Prima della coppia sopra validata sono state pubblicate due sessioni con un unico `FAIL` in `rumiai-os/extract/dispatch.test`:

```text
validation/20260910T153953+0200-72553  Linux/aarch64
validation/20260910T154030+0200-72870  Darwin/arm64
```

I log immutabili mostrano che il fake backend `tar` del test tentava di eseguire `cat` dopo che il test aveva intenzionalmente ristretto `PATH` al runtime e ai backend fake. `cat` non era quindi disponibile e il test terminava prima di raggiungere i casi DMG.

La correzione successiva in:

```text
rumiai-tests@9198a69f62a5f77c390cc015f193bbfb117fdc47
```

ha reso i fake backend autosufficienti aggiungendo un `cat` fake implementato con builtin POSIX, senza modificare `rumiai-os`, le aspettative del test o il contratto DMG. Le due sessioni precedenti restano evidence immutabile del difetto dell'harness e non vengono reinterpretate come failure del prodotto.

---

## Conclusione

Per la coppia revision-specific sopra indicata il gruppo completo `rumiai-os` è fisicamente validato sui due reference host ARM64 correnti.

La revisione `rumiai-os@a253162` non mostra regressioni osservate nella suite permanente completa. La semantica DMG native-first è protetta deterministicamente dal test di dispatch su entrambi gli host.

Questa validation non chiude ancora il gate live DBeaver. Il passo successivo resta:

```text
external/dbeaver/install-live.test
```

su Ubuntu ARM64 e macOS ARM64, con la stessa revisione `rumiai-os@a253162`. Quel gate deve esercitare realmente:

```text
pkg-catalog GitHub
GitHub release discovery
download e digest DBeaver
extract host-specific reale
pkg_integrate del payload DBeaver
```

Sul reference macOS tale percorso è anche il gate revision-specific dell'uso reale `hdiutil` + `ditto` sul DMG DBeaver.

Default selection e launch GUI restano gate separati e successivi.

---

## Invarianti di evidence

```text
DMG-VAL-01  coppia validata = rumiai-os@a253162 + rumiai-tests@9198a69
DMG-VAL-02  Ubuntu ARM64 = PASS 65, FAIL 0, SKIP 2, ERROR 0
DMG-VAL-03  i due SKIP Ubuntu derivano esclusivamente dall'assenza di Zsh
DMG-VAL-04  macOS ARM64 = PASS 67, FAIL 0, SKIP 0, ERROR 0
DMG-VAL-05  rumiai-os/extract/dispatch.test PASS su entrambi i reference host
DMG-VAL-06  le evidence remote restano sui rispettivi validation/<run-id>
DMG-VAL-07  i FAIL delle due run precedenti appartenevano all'harness del test e restano immutabili
DMG-VAL-08  il gate completo rumiai-os non viene promosso a evidence del percorso GitHub/upstream DBeaver live
DMG-VAL-09  l'esecuzione reale hdiutil+ditto nel prodotto resta da provare nel gate live DBeaver macOS
DMG-VAL-10  evidence revision-specific: revisioni prodotto successive richiedono nuova valutazione proporzionata
```
