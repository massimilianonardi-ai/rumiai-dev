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

Il gate live precedente aveva reso evidente una differenza prestazionale non funzionale:

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

Sono stati aggiunti test permanenti sui boundary della finestra in `rumiai-os/json/structure.test`, senza soglie temporali.

La coppia:

```text
rumiai-os@79cb5964428ca68c06c2f4eac98ac7350ae9561f
rumiai-tests@886bd7bee855e613bbaa20af4006c3e8f9477a4d
selection: rumiai-os
```

è fisicamente validata sul gruppo completo `rumiai-os` sui due reference host ARM64:

```text
Ubuntu ARM64  PASS 65 / FAIL 0 / SKIP 2 / ERROR 0
macOS ARM64   PASS 67 / FAIL 0 / SKIP 0 / ERROR 0
```

Evidence:

```text
decisions/rumiai-os/2026-09-10-json-windowed-arm64-physical-validation.md
```

I timing permanenti osservati per i test JSON sono:

```text
                         Ubuntu ARM64   macOS ARM64
json/object-read.test       0.01 s        0.03 s
json/structure.test         0.03 s        0.42 s
```

Questi tempi appartengono alla suite permanente e non sostituiscono la misura del payload GitHub reale del PoC.

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

Il runner mostra la durata per-test e persiste `timings`; `results`, log ed exit semantics restano invariati.

## Live DBeaver sulla revisione JSON windowed

La riesecuzione live end-to-end è stata completata sulla stessa revisione prodotto:

```text
rumiai-os@79cb5964428ca68c06c2f4eac98ac7350ae9561f
rumiai-tests@15e0f0c1470fdc89e6aa82a8e5d1577de69b698e
selection: external/dbeaver
pkg-catalog@514cb620075188ec9ad9090f6bd008fcec85913f
```

Risultati:

```text
Ubuntu ARM64
  PASS  external/dbeaver/install-live.test
  timing 17.03 s
  installed dbeaver@26.2.0!linux-arm64

macOS ARM64
  PASS  external/dbeaver/install-live.test
  timing 26.69 s
  installed dbeaver@26.2.0!macos-arm64
```

Evidence:

```text
decisions/rumiai-os/2026-09-10-dbeaver-live-install-json-windowed-arm64-physical-validation.md
```

Il gate esercita realmente il percorso:

```text
pkg install dbeaver
  -> clone/fetch reale pkg-catalog da GitHub
  -> GitHub release discovery reale
  -> artifact descriptor reale
  -> download reale DBeaver
  -> digest reale
  -> extract reale host-specific
  -> pkg_integrate reale del payload DBeaver
```

Sul reference macOS il percorso usa realmente sia il parser JSON windowed sul payload GitHub sia il backend DMG native-first `hdiutil` + `ditto`.

La durata Linux resta sostanzialmente invariata rispetto alla precedente evidence live. La durata macOS scende da circa 242 s a 26.69 s: il comportamento patologico che aveva motivato il PoC 007 non permane nel nuovo percorso end-to-end.

Il gate live `pkg install dbeaver` è quindi chiuso anche per `rumiai-os@79cb596`.

## Gate corrente

Il gate corrente è ora la validazione separata di:

```text
pkg_default dbeaver
binding pubblico del default
normal launch del DBeaver installato
```

La distinzione semantica resta obbligatoria:

```text
pkg install  -> availability
pkg_default  -> current + binding pubblico
normal launch -> bin/ext* -> current -> cmd -> launcher -> link -> root
```

Il normal launch non deve passare da `pkg` e non deve consultare `pkg-catalog`.

La validazione del default deve essere automatizzabile e indipendente. La validazione del launch reale deve essere eseguita soltanto dove le precondizioni richieste dall'upstream sono disponibili; una GUI non disponibile è una precondizione di applicabilità del relativo test, non una ragione per reinterpretare il launch GUI come già validato.

Prima di introdurre un nuovo test DBeaver per questo gate va riusata la struttura già esistente sotto `tests/external/dbeaver/` e vanno mantenute l'indipendenza assoluta dei test e la root RumiAI isolata.

## Sequenza operativa corrente

```text
A  gate completo rumiai-os per revisione DMG a253162                  [completato]
B  gate live pkg install dbeaver Ubuntu ARM64                         [completato]
C  gate live pkg install dbeaver macOS ARM64                          [completato]
D  localizzazione performance macOS JSON                              [completato]
E  PoC correzione algoritmica JSON su macOS                           [completato]
F  promozione minima JSON + boundary test permanenti                  [completato]
G  validation revision-specific rumiai-os@79cb596                     [completato]
H  riesecuzione live DBeaver sulla nuova revisione JSON               [completato]
I  validazione separata default + launch dove applicabile             [corrente]
J  ripresa lifecycle uninstall/version/current                        [successivo]
K  dependency/facility/state avanzato soltanto quando richiesto       [successivo]
```

## Invarianti correnti

```text
PKG-NOW-01  pkg install produce availability e non seleziona il default
PKG-NOW-02  pkg_default resta l'unico layer corrente per current e binding pubblici
PKG-NOW-03  launcher vive in lib/sh/pkg-launch.lib.sh ed è caricato esplicitamente dai command entry che lo usano
PKG-NOW-04  normal launch non passa da pkg e non consulta pkg-catalog
PKG-NOW-05  dmg preferisce hdiutil+ditto quando entrambe disponibili; 7zz/7z/7za sono fallback di capability
PKG-NOW-06  un errore operativo del backend dmg selezionato non provoca retry
PKG-NOW-07  rumiai-os@a253162 resta una precedente revisione fisicamente validata sui due reference host ARM64
PKG-NOW-08  pkg install dbeaver su a253162 resta live PASS sui due reference host ARM64 come evidence storica revision-specific
PKG-NOW-09  nessun live install gate comprende implicitamente default o launch
PKG-NOW-10  la performance patologica macOS è stata localizzata nel parser JSON e il candidato windowed ha ridotto 100.02 s a 5.23 s nel PoC
PKG-NOW-11  rumiai-os@79cb596 è fisicamente validata sul gruppo completo rumiai-os dei due reference host ARM64 con rumiai-tests@886bd7b
PKG-NOW-12  pkg install dbeaver su rumiai-os@79cb596 è live PASS sui due reference host ARM64 con rumiai-tests@15e0f0c
PKG-NOW-13  timing live della revisione windowed = 17.03 s Ubuntu ARM64 e 26.69 s macOS ARM64
PKG-NOW-14  il timing per-test del runner è fisicamente validato sui due reference host ARM64
PKG-NOW-15  la suite permanente non usa soglie prestazionali; PoC e timing live restano evidence osservazionali separate
PKG-NOW-16  il gate corrente riguarda default e normal launch senza riaprire la semantica availability/default
PKG-NOW-17  lifecycle uninstall/version/current riprende dopo la chiusura del gate default+launch previsto dalla sequenza corrente
```
