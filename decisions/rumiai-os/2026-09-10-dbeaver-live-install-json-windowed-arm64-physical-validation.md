# Decisione — Physical validation ARM64 live di `pkg install dbeaver` sulla revisione JSON windowed

Date: 2026-09-10  
Status: **Validated**

## Scope

Questa evidence registra la riesecuzione live end-to-end di:

```text
pkg install dbeaver
```

sui due reference host ARM64 correnti dopo la promozione del cursore JSON windowed.

Coppia esercitata:

```text
rumiai-os@79cb5964428ca68c06c2f4eac98ac7350ae9561f
rumiai-tests@15e0f0c1470fdc89e6aa82a8e5d1577de69b698e
selection: external/dbeaver
pkg-catalog@514cb620075188ec9ad9090f6bd008fcec85913f
```

Il test permanente è:

```text
rumiai-tests/tests/external/dbeaver/install-live.test
```

Il test usa una root RumiAI isolata, non modifica il checkout operativo, non seleziona implicitamente il default e non lancia la GUI DBeaver.

Il percorso esercitato realmente comprende:

```text
clone/fetch pkg-catalog GitHub
GitHub release discovery
risoluzione release e artifact DBeaver
download artifact reale
verifica size e SHA-256
extract host-specific reale
pkg_integrate del payload reale
verifica command entry e direct-link
verifica assenza di default implicito
```

La revisione `rumiai-tests@15e0f0c` contiene nella propria `rumiai-validate.conf`:

```text
rumiai-os-commit  79cb5964428ca68c06c2f4eac98ac7350ae9561f
selection         external/dbeaver
```

Entrambi i commit evidence hanno come parent esattamente `rumiai-tests@15e0f0c1470fdc89e6aa82a8e5d1577de69b698e`.

---

## Ubuntu ARM64

Sessione:

```text
run-id:              20260910T174239+0200-102697
validation ref:      validation/20260910T174239+0200-102697
evidence commit:     fc18b297e333ef686062a115bac130be99a2b9f9
rumiai-tests parent: 15e0f0c1470fdc89e6aa82a8e5d1577de69b698e
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
PASS   external/dbeaver/install-live.test
PASS   1
FAIL   0
SKIP   0
ERROR  0
TOTAL  1
runner exit status: 0
```

Timing persistito dal runner:

```text
external/dbeaver/install-live.test   17.03 s
```

Output persistito dal test:

```text
installed=dbeaver@26.2.0!linux-arm64
catalog-head=514cb620075188ec9ad9090f6bd008fcec85913f
upstream-target=dbeaver
```

---

## macOS ARM64

Sessione:

```text
run-id:              20260910T174312+0200-8202
validation ref:      validation/20260910T174312+0200-8202
evidence commit:     2f149824e0f93e053b9837b4273e1c12408e2677
rumiai-tests parent: 15e0f0c1470fdc89e6aa82a8e5d1577de69b698e
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
PASS   external/dbeaver/install-live.test
PASS   1
FAIL   0
SKIP   0
ERROR  0
TOTAL  1
runner exit status: 0
```

Timing persistito dal runner:

```text
external/dbeaver/install-live.test   26.69 s
```

Output persistito dal test:

```text
installed=dbeaver@26.2.0!macos-arm64
catalog-head=514cb620075188ec9ad9090f6bd008fcec85913f
upstream-target=DBeaver.app/Contents/MacOS/dbeaver
```

Sul reference macOS questo percorso esercita realmente sia il parser JSON windowed della revisione `79cb596` sul payload GitHub reale sia il backend DMG native-first `hdiutil` + `ditto`.

---

## Confronto prestazionale con la revisione precedente

La precedente evidence live revision-specific su:

```text
rumiai-os@a2531626b68e81c9df4e76a007e7f963b3f26343
```

aveva osservato:

```text
Ubuntu ARM64   circa 17 s
macOS ARM64    circa 242 s
```

La nuova revisione osserva:

```text
Ubuntu ARM64   17.03 s
macOS ARM64    26.69 s
```

Linux resta sostanzialmente invariato nel percorso end-to-end osservato.

Su macOS la durata scende da circa 242 secondi a 26.69 secondi, cioè circa 9.1 volte più veloce end-to-end e circa l'89% di tempo in meno rispetto alla precedente run live. Questa misura riguarda l'intero test e non viene reinterpretata come benchmark isolato del solo parser JSON.

Il risultato è coerente con il PoC 007, che aveva localizzato nel parser JSON precedente il costo dominante e aveva già misurato separatamente il candidato windowed sul payload GitHub reale.

---

## Conclusione

Il physical gate live di `pkg install dbeaver` è chiuso anche per la revisione:

```text
rumiai-os@79cb5964428ca68c06c2f4eac98ac7350ae9561f
```

sui due reference host ARM64 correnti.

Non sono state osservate regressioni funzionali nel percorso live. La regressione prestazionale patologica precedentemente osservata su macOS non è più presente nella stessa forma: la durata end-to-end passa da circa 242 s a 26.69 s, mentre Linux resta circa 17 s.

Questa evidence non verifica ancora:

```text
pkg_default dbeaver
binding pubblico del default
launch reale DBeaver installato
lifecycle uninstall/version/current
Windows/MSYS2
```

Default e launch restano il gate successivo separato. Il lifecycle riprende soltanto dopo tale gate secondo il piano package corrente.

---

## Invarianti di evidence

```text
DBEAVER-WINDOW-LIVE-01  coppia validata = rumiai-os@79cb596 + rumiai-tests@15e0f0c
DBEAVER-WINDOW-LIVE-02  pkg-catalog osservato = 514cb620075188ec9ad9090f6bd008fcec85913f
DBEAVER-WINDOW-LIVE-03  Ubuntu ARM64 install-live = PASS, dbeaver@26.2.0!linux-arm64
DBEAVER-WINDOW-LIVE-04  macOS ARM64 install-live = PASS, dbeaver@26.2.0!macos-arm64
DBEAVER-WINDOW-LIVE-05  timing live Ubuntu ARM64 = 17.03 s
DBEAVER-WINDOW-LIVE-06  timing live macOS ARM64 = 26.69 s
DBEAVER-WINDOW-LIVE-07  Linux resta sostanzialmente invariato rispetto alla precedente evidence live
DBEAVER-WINDOW-LIVE-08  il costo patologico macOS osservato a circa 242 s non permane sulla revisione windowed
DBEAVER-WINDOW-LIVE-09  pkg install continua a produrre availability senza selezionare il default
DBEAVER-WINDOW-LIVE-10  checkout operativo non modificato e GUI non lanciata
DBEAVER-WINDOW-LIVE-11  default+launch e lifecycle restano fuori dallo scope di questa validation
DBEAVER-WINDOW-LIVE-12  evidence revision-specific: revisioni prodotto successive richiedono nuova valutazione proporzionata
```
