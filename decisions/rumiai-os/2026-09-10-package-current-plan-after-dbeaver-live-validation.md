# Decisione — Piano package corrente dopo la validation live DBeaver

Date: 2026-09-10  
Status: **Accepted**

## Scopo e supersession

Questo documento è il checkpoint operativo corrente della sequenza package e supersede, esclusivamente per stato di avanzamento e physical-validation status, il checkpoint:

```text
decisions/rumiai-os/2026-09-10-package-current-plan-after-arm64-validation.md
```

I contratti architetturali e tecnici restano nei rispettivi documenti autorevoli.

## Stato acquisito

Sono completati e consolidati:

```text
1   refresh/snapshot pkg-catalog
2   HTTP/JSON/GitHub adapter e test permanenti
3   pkg_download
4   digest/extract
5   pkg_extract structural useful-root normalization
6   pkg-analyze consumo del useful-root normalizzato
7   definizione DBeaver Linux/macOS/Windows x86_64
8   pkg_integrate/pkg_deintegrate/pkg_default
9   orchestrazione reale pkg install
9a  package launcher direct-link in lib/sh/pkg-launch.lib.sh
```

La revisione prodotto precedente:

```text
rumiai-os@a2531626b68e81c9df4e76a007e7f963b3f26343
```

è fisicamente validata sul gruppo completo `rumiai-os` sui due reference host ARM64 con:

```text
rumiai-tests@9198a69f62a5f77c390cc015f193bbfb117fdc47
```

ed il gate live DBeaver è inoltre fisicamente PASS su entrambi i reference host con:

```text
rumiai-tests@80ea0e67d75d0b9e75a9f96575628c2b507edb02
selection: external/dbeaver
pkg-catalog@514cb620075188ec9ad9090f6bd008fcec85913f
```

Evidence live:

```text
decisions/rumiai-os/2026-09-10-dbeaver-live-install-arm64-physical-validation.md
```

Quindi il physical gate di `pkg install dbeaver` per `rumiai-os@a253162` è chiuso.

## Performance JSON macOS

Il gate live ha reso evidente una differenza prestazionale non funzionale:

```text
Linux/aarch64 live DBeaver   circa 17 s
Darwin/arm64 live DBeaver    circa 242 s
```

Il PoC 007 ha isolato sul reference macOS il costo nel parser JSON della revisione `a253162`:

```text
payload GitHub reale         2,355,841 byte
HTTP fetch                   1.408512 s
awk lineare                  0.06 s real
json parser corrente         100.02 s real / 99.67 s user
```

La seconda fase del PoC ha verificato fisicamente sullo stesso reference host il candidato windowed:

```text
semantic-smoke               PASS
payload GitHub reale         2,355,841 byte
HTTP fetch                   1.386539 s
awk lineare                  0.05 s real
json parser windowed         5.23 s real / 5.19 s user
record emessi                100
miglioramento                circa 19.1x
```

Decisione di promozione:

```text
decisions/rumiai-os/2026-09-10-json-windowed-source-cursor.md
```

Il candidato fisicamente provato è stato promosso senza modifiche ulteriori in:

```text
rumiai-os@79cb5964428ca68c06c2f4eac98ac7350ae9561f
lib/sh/json.lib.sh blob 6b028e01bba06bd24f7af8fe26bff0d1a9bb29fe
```

Sono stati aggiunti test permanenti sui boundary della finestra in `rumiai-os/json/structure.test`, senza soglie temporali. La nuova revisione prodotto è **pending physical validation** e non eredita automaticamente i PASS di `a253162`.

## Runner timing

La durata per-test è stata aggiunta al runner secondo:

```text
decisions/rumiai-tests/2026-09-10-runner-per-test-timing.md
```

La revisione:

```text
rumiai-tests@be92befb9342a164231c012df4e5245ec189a206
selection: runner
```

è fisicamente PASS sui due reference host ARM64. Evidence:

```text
decisions/rumiai-tests/2026-09-10-runner-per-test-timing-arm64-physical-validation.md
```

Il runner ora mostra la durata per-test e persiste `timings`; `results`, log ed exit semantics restano invariati.

## Gate corrente

La configurazione corrente di validation è:

```text
rumiai-os-commit  79cb5964428ca68c06c2f4eac98ac7350ae9561f
selection         rumiai-os
```

La suite corrente include i boundary test JSON introdotti dopo il PoC. Il gate completo deve essere eseguito sui due reference host ARM64 prima di promuovere la nuova revisione a baseline fisicamente validata.

## Sequenza operativa corrente

```text
A  gate completo rumiai-os per revisione DMG a253162                  [completato]
B  gate live pkg install dbeaver Ubuntu ARM64                         [completato]
C  gate live pkg install dbeaver macOS ARM64                          [completato]
D  localizzazione performance macOS JSON                              [completato]
E  PoC correzione algoritmica JSON su macOS                           [completato]
F  promozione minima JSON + boundary test permanenti                  [completato]
G  validation revision-specific rumiai-os@79cb596                     [corrente]
H  riesecuzione live DBeaver sulla nuova revisione JSON               [successivo]
I  validazione separata default + launch dove GUI disponibile         [successivo]
J  ripresa lifecycle uninstall/version/current                        [successivo]
K  dependency/facility/state avanzato soltanto quando richiesto       [successivo]
```

L'ottimizzazione JSON viene completata prima di proseguire con default/launch e lifecycle, così il percorso live non conserva un costo noto patologico sul reference macOS.

## Invarianti correnti

```text
PKG-NOW-01  pkg install produce availability e non seleziona il default
PKG-NOW-02  pkg_default resta l'unico layer corrente per current e binding pubblici
PKG-NOW-03  launcher vive in lib/sh/pkg-launch.lib.sh ed è caricato esplicitamente dai command entry che lo usano
PKG-NOW-04  normal launch non passa da pkg e non consulta pkg-catalog
PKG-NOW-05  dmg preferisce hdiutil+ditto quando entrambe disponibili; 7zz/7z/7za sono fallback di capability
PKG-NOW-06  un errore operativo del backend dmg selezionato non provoca retry
PKG-NOW-07  rumiai-os@a253162 resta la precedente revisione fisicamente validata sui due reference host ARM64
PKG-NOW-08  pkg install dbeaver su a253162 resta live PASS sui due reference host ARM64
PKG-NOW-09  il PASS live precedente non comprende default né launch GUI
PKG-NOW-10  la performance patologica macOS è stata localizzata nel parser JSON e il candidato windowed ha ridotto 100.02 s a 5.23 s nel PoC
PKG-NOW-11  rumiai-os@79cb596 contiene il candidato esatto del PoC ed è pending physical validation
PKG-NOW-12  la nuova revisione non eredita i PASS di a253162; richiede gate completo e successivo live DBeaver propri
PKG-NOW-13  il timing per-test del runner è fisicamente validato sui due reference host ARM64
PKG-NOW-14  lifecycle uninstall/version/current riprende dopo chiusura dell'ottimizzazione JSON e dei gate package correnti
```
