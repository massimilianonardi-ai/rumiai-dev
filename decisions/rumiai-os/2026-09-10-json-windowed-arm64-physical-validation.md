# Decisione — Physical validation ARM64 del cursore JSON windowed

Date: 2026-09-10  
Status: **Validated**

## Scope

Questa evidence registra la validation completa del gruppo `rumiai-os` dopo la promozione nel prodotto del cursore source windowed del parser JSON definito in:

```text
decisions/rumiai-os/2026-09-10-json-windowed-source-cursor.md
```

La modifica mantiene invariata la superficie pubblica e la semantica di `lib/sh/json.lib.sh`; cambia soltanto il meccanismo interno di accesso alla stringa sorgente AWK usando una finestra da 4096 byte come dettaglio implementativo.

La validation è revision-specific e non viene estesa implicitamente a revisioni successive.

Coppia validata:

```text
rumiai-os@79cb5964428ca68c06c2f4eac98ac7350ae9561f
rumiai-tests@886bd7bee855e613bbaa20af4006c3e8f9477a4d
selection: rumiai-os
```

La configurazione `rumiai-validate.conf` della revisione test sopra indicata selezionava esattamente `rumiai-os@79cb5964428ca68c06c2f4eac98ac7350ae9561f`.

Il candidato promosso in `lib/sh/json.lib.sh` è lo stesso blob fisicamente misurato nel PoC 007:

```text
6b028e01bba06bd24f7af8fe26bff0d1a9bb29fe
```

I test permanenti includono i boundary crossing della finestra per stringhe lunghe, escape Unicode ignorati, literal e stringhe selezionate. Non esiste una soglia temporale nei test permanenti.

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
20260910T171635+0200-93578
validation ref: validation/20260910T171635+0200-93578
validation evidence commit: abc24b719e7f2c918917cb77c67c59bb7c21d3a8
validation evidence parent: 886bd7bee855e613bbaa20af4006c3e8f9477a4d
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

Timing JSON persistiti dal runner:

```text
rumiai-os/json/object-read.test   0.01 s
rumiai-os/json/structure.test     0.03 s
```

La sessione completa è stata registrata dalle `17:16:35+0200` alle `17:16:38+0200`.

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
20260910T171703+0200-96871
validation ref: validation/20260910T171703+0200-96871
validation evidence commit: 716493c3ba777737a61dd65142b50cd4d8ffef4c
validation evidence parent: 886bd7bee855e613bbaa20af4006c3e8f9477a4d
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

Timing JSON persistiti dal runner:

```text
rumiai-os/json/object-read.test   0.03 s
rumiai-os/json/structure.test     0.42 s
```

La sessione completa è stata registrata dalle `17:17:03+0200` alle `17:17:26+0200`.

---

## Relazione con il PoC prestazionale

Il PoC 007 sul reference macOS ARM64 aveva isolato il payload GitHub reale da 2,355,841 byte e misurato:

```text
parser precedente   100.02 s real
parser windowed       5.23 s real
record emessi          100
semantic-smoke        PASS
```

Questa physical validation completa non sostituisce né reinterpreta tale misura: i test permanenti verificano correttezza e boundary crossing, non riproducono il payload GitHub multi-megabyte né impongono una soglia temporale.

I timing della suite mostrano tuttavia che non emerge una regressione prestazionale anomala nei test JSON della revisione promossa sui due reference host.

La verifica end-to-end del parser windowed sul payload GitHub reale usato dal package manager resta affidata al successivo gate:

```text
external/dbeaver/install-live.test
```

sulla stessa revisione `rumiai-os@79cb596`.

---

## Conclusione

Per la coppia revision-specific sopra indicata il gruppo completo `rumiai-os` è fisicamente validato sui due reference host ARM64 correnti.

La revisione `rumiai-os@79cb596` non mostra regressioni osservate nella suite permanente completa. I boundary crossing introdotti per il cursore windowed sono esercitati dal test permanente `rumiai-os/json/structure.test`, che produce `PASS` su entrambi gli host.

Questa evidence chiude il gate completo della revisione JSON windowed, ma **non** estende automaticamente il precedente PASS live DBeaver di `rumiai-os@a253162` alla nuova revisione.

Il passo successivo è rieseguire:

```text
external/dbeaver/install-live.test
```

su Ubuntu ARM64 e macOS ARM64 contro `rumiai-os@79cb596`, usando il timing per-test del runner per osservare la nuova durata end-to-end.

Default selection e launch GUI restano gate separati e successivi.

---

## Invarianti di evidence

```text
JSON-WINDOW-VAL-01  coppia validata = rumiai-os@79cb596 + rumiai-tests@886bd7b
JSON-WINDOW-VAL-02  Ubuntu ARM64 = PASS 65, FAIL 0, SKIP 2, ERROR 0
JSON-WINDOW-VAL-03  i due SKIP Ubuntu derivano esclusivamente dall'assenza di Zsh
JSON-WINDOW-VAL-04  macOS ARM64 = PASS 67, FAIL 0, SKIP 0, ERROR 0
JSON-WINDOW-VAL-05  json/object-read.test e json/structure.test PASS su entrambi gli host
JSON-WINDOW-VAL-06  i timing per-test sono persistiti nelle evidence remote
JSON-WINDOW-VAL-07  la validation completa non sostituisce la misura prestazionale del payload GitHub del PoC 007
JSON-WINDOW-VAL-08  nessuna soglia temporale appartiene ai test permanenti
JSON-WINDOW-VAL-09  il precedente PASS live DBeaver di a253162 non viene esteso a 79cb596
JSON-WINDOW-VAL-10  il prossimo gate revision-specific è external/dbeaver/install-live.test su 79cb596
```
