# Decisione — Physical validation ARM64 del default DBeaver

Date: 2026-09-10  
Status: **Validated**

## Scope

Questa evidence registra la validazione separata del livello default DBeaver successiva al gate live di `pkg install dbeaver`.

Coppia esercitata:

```text
rumiai-os@79cb5964428ca68c06c2f4eac98ac7350ae9561f
rumiai-tests@bf770b1de4a1fad4fddd65e551bae696b8ef9748
selection: external/dbeaver/default-live.test
pkg-catalog@514cb620075188ec9ad9090f6bd008fcec85913f
```

Il test permanente è:

```text
rumiai-tests/tests/external/dbeaver/default-live.test
```

Il test usa una root RumiAI isolata ed è indipendente. Esegue realmente:

```text
pkg install dbeaver
verifica availability senza default implicito
pkg_default dbeaver <version> <osarch>
verifica selector target-specific
verifica binding pubblico target-specific
verifica risoluzione del binding attraverso current verso cmd/dbeaver
verifica assenza di selector e binding generic impropri
```

Non esegue il normal launch DBeaver.

La revisione `rumiai-tests@bf770b1` contiene nella propria `rumiai-validate.conf`:

```text
rumiai-os-commit  79cb5964428ca68c06c2f4eac98ac7350ae9561f
selection         external/dbeaver/default-live.test
```

Entrambi i commit evidence hanno come parent esattamente:

```text
rumiai-tests@bf770b1de4a1fad4fddd65e551bae696b8ef9748
```

---

## Ubuntu ARM64

Sessione:

```text
run-id:              20260910T175938+0200-104234
validation ref:      validation/20260910T175938+0200-104234
evidence commit:     d6f565dd05aae99246491e15bd259ac1b9c8434f
rumiai-tests parent: bf770b1de4a1fad4fddd65e551bae696b8ef9748
```

Host:

```text
OS:           Linux
OS version:   Ubuntu 26.04.1 LTS
architecture: aarch64
kernel:       Linux 7.0.0-31-generic
```

Risultato:

```text
PASS   external/dbeaver/default-live.test
PASS   1
FAIL   0
SKIP   0
ERROR  0
TOTAL  1
runner exit status: 0
```

Timing persistito dal runner:

```text
external/dbeaver/default-live.test   16.23 s
```

Output persistito dal test:

```text
default=dbeaver@26.2.0!linux-arm64
selector-target=dbeaver@26.2.0!linux-arm64
binding-target=../../pkg/dbeaver!linux-arm64/cmd/dbeaver
```

---

## macOS ARM64

Sessione:

```text
run-id:              20260910T180009+0200-9653
validation ref:      validation/20260910T180009+0200-9653
evidence commit:     2c429f11a39121eb37338880b15293e279cced07
rumiai-tests parent: bf770b1de4a1fad4fddd65e551bae696b8ef9748
```

Host:

```text
OS:           Darwin
OS version:   26.6.2
architecture: arm64
kernel:       Darwin 25.6.0
```

Risultato:

```text
PASS   external/dbeaver/default-live.test
PASS   1
FAIL   0
SKIP   0
ERROR  0
TOTAL  1
runner exit status: 0
```

Timing persistito dal runner:

```text
external/dbeaver/default-live.test   25.63 s
```

Output persistito dal test:

```text
default=dbeaver@26.2.0!macos-arm64
selector-target=dbeaver@26.2.0!macos-arm64
binding-target=../../pkg/dbeaver!macos-arm64/cmd/dbeaver
```

---

## Conclusione

Il physical gate del livello default DBeaver è chiuso sulla coppia:

```text
rumiai-os@79cb5964428ca68c06c2f4eac98ac7350ae9561f
rumiai-tests@bf770b1de4a1fad4fddd65e551bae696b8ef9748
```

sui due reference host ARM64 correnti.

La prova conferma fisicamente che:

```text
pkg install produce availability senza default implicito
pkg_default seleziona la concrete version già disponibile
il selector target-specific punta alla concrete identity corretta
il binding pubblico target-specific passa attraverso current e risolve a cmd/dbeaver
non vengono creati selector o binding generic impropri
```

Questa evidence non valida ancora il normal launch del DBeaver installato. Il launch resta il sottogate successivo e deve essere eseguito soltanto dove le precondizioni GUI richieste dall'upstream sono disponibili.

---

## Invarianti di evidence

```text
DBEAVER-DEFAULT-LIVE-01  coppia validata = rumiai-os@79cb596 + rumiai-tests@bf770b1
DBEAVER-DEFAULT-LIVE-02  pkg-catalog osservato = 514cb620075188ec9ad9090f6bd008fcec85913f
DBEAVER-DEFAULT-LIVE-03  Ubuntu ARM64 default-live = PASS, dbeaver@26.2.0!linux-arm64
DBEAVER-DEFAULT-LIVE-04  macOS ARM64 default-live = PASS, dbeaver@26.2.0!macos-arm64
DBEAVER-DEFAULT-LIVE-05  timing Ubuntu ARM64 = 16.23 s
DBEAVER-DEFAULT-LIVE-06  timing macOS ARM64 = 25.63 s
DBEAVER-DEFAULT-LIVE-07  pkg install resta availability-only
DBEAVER-DEFAULT-LIVE-08  pkg_default crea il selector e il binding target-specific previsti
DBEAVER-DEFAULT-LIVE-09  non vengono creati selector o binding generic per DBeaver target-specific
DBEAVER-DEFAULT-LIVE-10  normal launch resta fuori scope e non è ancora validato da questa evidence
DBEAVER-DEFAULT-LIVE-11  evidence revision-specific: revisioni prodotto/test successive richiedono nuova valutazione proporzionata
```
