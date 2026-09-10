# Decisione — Physical validation ARM64 completa di RumiAI OS

Date: 2026-09-10  
Status: **Validated**

## Scope

Questa evidence registra la validation completa del gruppo `rumiai-os` dopo l'introduzione dei layer package correnti, inclusi:

```text
pkg_integrate / pkg_deintegrate / pkg_default
pkg install / catalog snapshot
pkg-launch direct-link
```

La validation è revision-specific e non viene estesa implicitamente a revisioni successive.

Coppia validata:

```text
rumiai-os@b724bd1f3a4ea6fe0b968c5ea38e7db835fee179
rumiai-tests@897e830d58f10fdf4e66b907a7aa9daa900c722b
selection: rumiai-os
```

La configurazione di validation della suite fissava esattamente tale coppia.

Il catalogo DBeaver coerente con il package launcher al momento del gate era:

```text
pkg-catalog@514cb620075188ec9ad9090f6bd008fcec85913f
```

Il gruppo `rumiai-os` usa fixture/local repository per i test package correnti; questa revisione del catalogo viene quindi registrata come stato coerente del sottosistema ma non è stata consumata dal gate completo come sorgente remota live.

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
20260910T121147+0200-50138
validation ref: validation/20260910T121147+0200-50138
validation evidence commit: 8f543391cd87ce02674d4e511185ce95eabb0719
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

ed entrambi dichiarano come precondizione mancante la disponibilità di Zsh sull'host. Non rappresentano incompatibilità osservate del prodotto.

I nuovi test package hanno tutti prodotto `PASS`:

```text
rumiai-os/pkg-integration/contract.test
rumiai-os/pkg-launch/contract.test
rumiai-os/pkg/catalog-snapshot.test
rumiai-os/pkg/install.test
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
20260910T121207+0200-50124
validation ref: validation/20260910T121207+0200-50124
validation evidence commit: b04aa11e3f47943818bb162db1fa3fa9333aaecc
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

I nuovi test package hanno tutti prodotto `PASS` anche su macOS ARM64.

---

## Conclusione

Per la coppia revision-specific sopra indicata il gruppo completo `rumiai-os` è fisicamente validato sui due reference host ARM64 correnti.

Sono quindi fisicamente validati, nei limiti dei rispettivi test permanenti basati su fixture/local repository:

```text
pkg_integrate
pkg_deintegrate
pkg_default
pkg install orchestration
catalog snapshot/lock/fast-forward/offline contract
pkg-launch direct-link contract
assenza di regressioni osservate nel resto del gruppo rumiai-os
```

Il gate **non** dimostra ancora le proprietà che richiedono rete e artifact upstream reali:

```text
clone/fetch effettivo del pkg-catalog remoto GitHub come parte di pkg install
GitHub release discovery reale di DBeaver
download reale dell'artifact DBeaver
digest reale dell'artifact DBeaver
extract reale DBeaver sul reference host
materializzazione reale DBeaver da upstream
selezione DBeaver come default
launch reale DBeaver installato
Windows/MSYS2
```

Tali proprietà appartengono a un gate esterno/live separato e proporzionato.

---

## Invarianti di evidence

```text
RUMIAI-OS-VAL-01  coppia validata = rumiai-os@b724bd1 + rumiai-tests@897e830
RUMIAI-OS-VAL-02  Ubuntu ARM64 = PASS 65, FAIL 0, SKIP 2, ERROR 0
RUMIAI-OS-VAL-03  i due SKIP Ubuntu derivano esclusivamente dall'assenza di Zsh
RUMIAI-OS-VAL-04  macOS ARM64 = PASS 67, FAIL 0, SKIP 0, ERROR 0
RUMIAI-OS-VAL-05  le evidence remote restano sui rispettivi validation/<run-id>
RUMIAI-OS-VAL-06  il gate completo non viene promosso a evidence di network/upstream DBeaver live
RUMIAI-OS-VAL-07  evidence revision-specific: revisioni successive richiedono nuova valutazione proporzionata
```
