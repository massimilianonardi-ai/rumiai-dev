# Decisione — Physical validation ARM64 della correzione JSON

Date: 2026-09-10  
Status: **Validated**

## Scope

Questa evidence registra la validation completa del gruppo `rumiai-os` dopo la correzione prestazionale di `lib/sh/json.lib.sh` che evita di materializzare le stringhe JSON non selezionate pur continuando a validarne struttura, escape e contenuto sintattico.

La correzione non modifica la superficie pubblica JSON, la serializzazione typed, gli endpoint GitHub, la paginazione `per_page=100` o la semantica del repository adapter.

La validation è revision-specific e non viene estesa implicitamente a revisioni successive.

Coppia validata:

```text
rumiai-os@46718998627825055991ebb648b6edbc9cc52950
rumiai-tests@8c5d1820527089c186bcb21e254d9d5650178bf8
selection: rumiai-os
```

Il catalogo DBeaver corrente durante il gate resta:

```text
pkg-catalog@514cb620075188ec9ad9090f6bd008fcec85913f
```

Il gruppo `rumiai-os` usa fixture/local repository per i test package correnti; questa validation non costituisce quindi evidence del percorso DBeaver GitHub/upstream live.

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
20260910T144704+0200-63201
validation ref: validation/20260910T144704+0200-63201
validation evidence commit: 6fea2d87304717b4aa4b4b488fab7513eb99c1bb
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

I test JSON hanno entrambi prodotto `PASS`:

```text
rumiai-os/json/object-read.test
rumiai-os/json/structure.test
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
20260910T145216+0200-62127
validation ref: validation/20260910T145216+0200-62127
validation evidence commit: 1c600c87141020585ba8c606c1637997c677d811
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

Anche su macOS ARM64 i due test JSON hanno prodotto `PASS`.

---

## Conclusione

Per la coppia revision-specific sopra indicata il gruppo completo `rumiai-os` è fisicamente validato sui due reference host ARM64 correnti.

La correzione del parser JSON non mostra regressioni osservate nei test permanenti del prodotto e la regressione aggiunta a `rumiai-os/json/structure.test` passa su entrambi gli host.

La validation non chiude il gate live DBeaver. Restano distinti e ancora da verificare sul prodotto corrente:

```text
GitHub release discovery reale nel flusso pkg install dbeaver
download/digest reale dell'artifact DBeaver
extract reale del DMG DBeaver su macOS
materializzazione live DBeaver
selezione esplicita del default
launch reale DBeaver
```

La precedente evidence `2026-09-10-rumiai-os-arm64-physical-validation.md` resta immutata e valida esclusivamente per la propria coppia revision-specific.

---

## Invarianti di evidence

```text
JSON-VAL-01  coppia validata = rumiai-os@4671899 + rumiai-tests@8c5d182
JSON-VAL-02  Ubuntu ARM64 = PASS 65, FAIL 0, SKIP 2, ERROR 0
JSON-VAL-03  i due SKIP Ubuntu derivano esclusivamente dall'assenza di Zsh
JSON-VAL-04  macOS ARM64 = PASS 67, FAIL 0, SKIP 0, ERROR 0
JSON-VAL-05  rumiai-os/json/object-read.test e structure.test PASS su entrambi i reference host
JSON-VAL-06  le evidence remote restano sui rispettivi validation/<run-id>
JSON-VAL-07  il gate completo non viene promosso a evidence di network/upstream DBeaver live
JSON-VAL-08  evidence revision-specific: revisioni successive richiedono nuova valutazione proporzionata
```
