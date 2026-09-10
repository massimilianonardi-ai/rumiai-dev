# Decisione — Physical validation ARM64 live di `pkg install dbeaver`

Date: 2026-09-10  
Status: **Validated**

## Scope

Questa evidence registra il gate live end-to-end di:

```text
pkg install dbeaver
```

sui due reference host ARM64 correnti.

Coppia esercitata:

```text
rumiai-os@a2531626b68e81c9df4e76a007e7f963b3f26343
rumiai-tests@80ea0e67d75d0b9e75a9f96575628c2b507edb02
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

---

## Ubuntu ARM64

Sessione:

```text
run-id:              20260910T155724+0200-89580
validation ref:      validation/20260910T155724+0200-89580
evidence commit:     b34398ce4d6b1c18dc50d71647be088e2d85f122
rumiai-tests parent: 80ea0e67d75d0b9e75a9f96575628c2b507edb02
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

Tempo sessione osservato dal runner:

```text
start  2026-09-10T15:57:24+0200
end    2026-09-10T15:57:41+0200
circa 17 s complessivi
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
run-id:              20260910T155800+0200-93499
validation ref:      validation/20260910T155800+0200-93499
evidence commit:     2c887728567b5aa6b3e4ac943450da25e1173fdd
rumiai-tests parent: 80ea0e67d75d0b9e75a9f96575628c2b507edb02
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

Tempo sessione osservato dal runner:

```text
start  2026-09-10T15:58:00+0200
end    2026-09-10T16:02:02+0200
circa 242 s complessivi
```

Output persistito dal test:

```text
installed=dbeaver@26.2.0!macos-arm64
catalog-head=514cb620075188ec9ad9090f6bd008fcec85913f
upstream-target=DBeaver.app/Contents/MacOS/dbeaver
```

Sul reference macOS questo gate esercita realmente il backend DMG native-first `hdiutil` + `ditto` introdotto in `rumiai-os@a253162`.

---

## Separazione fra correttezza e performance

Il gate funzionale è **PASS** su entrambi i reference host e chiude il confine live di `pkg install dbeaver` per la coppia revision-specific indicata.

La durata macOS di circa 242 secondi è però anomala rispetto ai circa 17 secondi Linux. L'indagine prestazionale successiva è separata dalla validità funzionale di questa evidence.

Il PoC:

```text
rumiai-dev-PoCs/pocs/007-macos-dbeaver-install-performance/
```

ha già localizzato il costo sul reference macOS nel parser JSON corrente. Sullo stesso payload reale GitHub da 2,355,841 byte sono stati osservati:

```text
HTTP fetch                 1.408512 s
awk lineare                0.06 s real
json parser corrente       100.02 s real
                           99.67 s user
record corretti emessi     100
```

Quindi il collo di bottiglia osservato non viene attribuito al backend DMG senza evidence: il costo dominante già isolato è nel percorso algoritmico del parser JSON su `/usr/bin/awk` macOS.

L'ottimizzazione del parser è un workstream successivo. Una futura modifica di `lib/sh/json.lib.sh` produrrà una nuova revisione di `rumiai-os` e richiederà nuova validation proporzionata; questa evidence non viene estesa retroattivamente.

---

## Gate esclusi

Questa validation non verifica:

```text
pkg_default dbeaver
binding pubblico del default
launch GUI reale di DBeaver
lifecycle uninstall/version/current
```

Default e launch restano gate separati. Il lifecycle resta sviluppo successivo secondo il piano package corrente.

---

## Invarianti di evidence

```text
DBEAVER-LIVE-01  coppia validata = rumiai-os@a253162 + rumiai-tests@80ea0e6
DBEAVER-LIVE-02  pkg-catalog osservato = 514cb620075188ec9ad9090f6bd008fcec85913f
DBEAVER-LIVE-03  Ubuntu ARM64 install-live = PASS, dbeaver@26.2.0!linux-arm64
DBEAVER-LIVE-04  macOS ARM64 install-live = PASS, dbeaver@26.2.0!macos-arm64
DBEAVER-LIVE-05  macOS esercita realmente il backend dmg hdiutil+ditto della revisione a253162
DBEAVER-LIVE-06  pkg install produce availability e non seleziona il default
DBEAVER-LIVE-07  checkout operativo non modificato e GUI non lanciata
DBEAVER-LIVE-08  performance anomala macOS è un problema separato dal PASS funzionale
DBEAVER-LIVE-09  una futura revisione JSON non eredita questa evidence revision-specific
DBEAVER-LIVE-10  default+launch e lifecycle restano fuori dallo scope di questa validation
```
