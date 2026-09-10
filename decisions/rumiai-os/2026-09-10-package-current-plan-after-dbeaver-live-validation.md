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

La revisione prodotto corrente:

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

Il gate live ha anche reso evidente una differenza prestazionale non funzionale:

```text
Linux/aarch64 live DBeaver   circa 17 s
Darwin/arm64 live DBeaver    circa 242 s
```

Il PoC 007 ha isolato sul reference macOS il costo nel parser JSON corrente:

```text
payload GitHub reale         2,355,841 byte
HTTP fetch                   1.408512 s
awk lineare                  0.06 s real
json parser corrente         100.02 s real / 99.67 s user
```

Il problema è quindi trattato come ottimizzazione distinta del parser, non come riapertura del PASS funzionale live DBeaver.

La correzione candidata resta nel PoC finché non acquisisce evidence fisica. Una futura modifica a `lib/sh/json.lib.sh` genera una nuova revisione prodotto e richiede nuova validation revision-specific proporzionata.

## Runner timing

L'assenza di durata per singolo test ha reso meno immediata la diagnosi del gate live. L'utente ha approvato l'aggiunta della durata per-test al runner.

Contratto:

```text
decisions/rumiai-tests/2026-09-10-runner-per-test-timing.md
```

Il lavoro sul runner è separato dalla semantica package e dal parser JSON. Non modifica `results`, non modifica i log prodotti dai test e non modifica il contratto runner -> test.

## Sequenza operativa corrente

```text
A  gate completo rumiai-os per revisione DMG a253162                  [completato]
B  gate live pkg install dbeaver Ubuntu ARM64                         [completato]
C  gate live pkg install dbeaver macOS ARM64                          [completato]
D  localizzazione performance macOS JSON                              [completato]
E  PoC correzione algoritmica JSON su macOS                           [in corso]
F  se PoC positivo, promozione minima JSON + test permanenti          [successivo]
G  validation revision-specific della nuova revisione JSON            [successivo]
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
PKG-NOW-07  rumiai-os@a253162 è fisicamente validata sui due reference host ARM64
PKG-NOW-08  pkg install dbeaver su a253162 è live PASS sui due reference host ARM64
PKG-NOW-09  il PASS live non comprende default né launch GUI
PKG-NOW-10  la performance patologica macOS è localizzata nel parser JSON ed è separata dalla correttezza funzionale
PKG-NOW-11  una nuova revisione JSON richiederà evidence propria e non eredita i PASS di a253162
PKG-NOW-12  lifecycle uninstall/version/current riprende dopo chiusura dell'ottimizzazione JSON e dei gate package correnti
```
