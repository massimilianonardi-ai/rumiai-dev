# Decisione — Electron macOS prebuilt: stato firma upstream e validazione fisica dell'archive

Date: 2026-09-12  
Status: **Accepted**

## 1. Contesto

La qualificazione Electron macOS ARM64 usa il prebuilt ufficiale Electron:

```text
v44.3.0
electron-v44.3.0-darwin-arm64.zip
```

Il package RumiAI `electron` espone il runtime Electron. Il bundle `Electron.app` deve essere preservato integralmente sotto `root/`, mentre il command runtime usa il main executable interno tramite il direct-link già fissato.

Durante la prima physical validation macOS il controllo:

```text
codesign --verify --deep --strict
```

sul bundle installato ha fallito. Prima di attribuire il failure a `pkg_extract`, è stato introdotto un gate diagnostico revision-specific che confronta lo stesso ZIP ufficiale estratto con il backend RumiAI e con `/usr/bin/ditto -x -k`.

## 2. Evidence fisica

Evidence pubblicata:

```text
validation/20260912T222918+0200-77771
```

Revisioni esercitate:

```text
rumiai-tests  9271e8b9c1dfbf4e33234d9d94c282649a39bcb6
rumiai-os     96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
platform      Darwin/arm64
selection     external/electron/macos-archive-extraction-live.test
runner        0
result        PASS
```

L'archive ufficiale osservato ha SHA-256:

```text
49b91ef265c603c8888500f807484b63816069c30f87ba2b403e7c87f0f45035
```

La central directory dello ZIP non contiene:

```text
Electron.app/Contents/_CodeSignature/CodeResources
```

e non contiene altre entry `_CodeSignature/CodeResources` per il bundle esterno.

Questa assenza è quindi proprietà dell'archive upstream osservato, non conseguenza dell'estrazione RumiAI.

## 3. Confronto RumiAI vs `ditto`

Lo stesso archive è stato estratto indipendentemente con:

```text
RumiAI extract zip
/usr/bin/ditto -x -k
```

Il confronto fisico ha verificato:

```text
path tree del bundle                  uguale
numero symlink                        14 in entrambi
framework symlink targets             uguali
Contents/Resources                    presente in entrambi
Electron runtime executable           presente/executable in entrambi
runtime --version                     v44.3.0 in entrambi
```

I principali symlink framework osservati coincidono, inclusi:

```text
Versions/Current -> A
Resources -> Versions/Current/Resources
Electron Framework -> Versions/Current/Electron Framework
```

Questa evidence chiude il dubbio che il backend ZIP corrente di RumiAI stia alterando la struttura o i symlink necessari del bundle Electron macOS `v44.3.0`.

## 4. Stato code-signature del prebuilt

Il controllo strict `codesign` fallisce sia sul tree estratto da RumiAI sia su quello estratto da `ditto`, con la stessa causa sostanziale: il bundle dichiara risorse firmate ma il relativo `CodeResources` non è presente nell'archive distribuito.

Per il prebuilt runtime Electron `v44.3.0` il requisito corretto non è quindi:

```text
codesign strict del bundle deve sempre PASS
```

perché tale proprietà non è fornita dall'artefatto upstream che RumiAI sta impacchettando.

Il contratto corrente diventa:

```text
1. verificare SHA-256 dell'artifact tramite la normale pipeline pkg;
2. preservare integralmente la shape del bundle e i symlink upstream;
3. osservare lo stato di firma del payload upstream;
4. se l'archive upstream contiene il materiale di firma necessario, l'estrazione/integration non deve romperlo e la verifica deve PASS;
5. se il materiale necessario è già assente upstream, la mancata verifica strict non è attribuita a RumiAI e viene registrata come limite dell'artefatto upstream;
6. RumiAI non deve inventare, riparare o risignare il prebuilt Electron durante `pkg install`.
```

Questo non riduce il requisito di integrità dell'archive: digest e pipeline di repository restano obbligatori.

## 5. Distinzione dal signing di una app finale RumiAI

Il runtime Electron prebuilt non è una app finale RumiAI distribuita all'utente.

Quando RumiAI produrrà una propria applicazione macOS `.app`, la relativa distribuzione dovrà valutare esplicitamente le normali garanzie macOS applicabili, incluse code signing e notarization quando richieste dal modello di distribuzione scelto.

La mancata firma strict del prebuilt runtime corrente non viene generalizzata alle future app RumiAI.

## 6. Conseguenze per i live test

`macos-archive-extraction-live.test` conserva il ruolo diagnostico/physical di confronto dell'archive upstream con un extractor macOS indipendente.

`macos-launch-live.test` non deve fallire soltanto perché il prebuilt corrente è privo di `Contents/_CodeSignature/CodeResources` già upstream.

Regola del launch test:

```text
CodeResources presente nel bundle installato
    -> codesign --verify --deep --strict deve PASS

CodeResources assente
    -> registrare signature-state=upstream-material-absent
    -> proseguire con le altre proprietà runtime
```

La validazione runtime resta obbligata a verificare:

```text
Electron.app preservato
Info.plist valido
main executable interno
link/electron corretto
public command RumiAI
process.execPath package-local
HOME package RumiAI
argv
BrowserWindow
loadFile
marker deterministico
exit/cleanup
```

## 7. Invarianti

```text
ELECTRON-MAC-SIGN-01  il prebuilt runtime v44.3.0 osservato non contiene il CodeResources esterno necessario alla strict bundle verification
ELECTRON-MAC-SIGN-02  il backend ZIP RumiAI e ditto producono per v44.3.0 tree e symlink equivalenti
ELECTRON-MAC-SIGN-03  la mancata strict verification già riprodotta con ditto non viene attribuita a pkg_extract
ELECTRON-MAC-SIGN-04  pkg install non risigna e non ripara il prebuilt Electron
ELECTRON-MAC-SIGN-05  digest SHA-256 e integrità dell'artifact restano obbligatori
ELECTRON-MAC-SIGN-06  se un futuro artifact upstream contiene il materiale di firma, RumiAI deve preservarlo e la verifica applicabile deve riuscire
ELECTRON-MAC-SIGN-07  una futura app finale RumiAI .app valuta separatamente signing/notarization
ELECTRON-MAC-SIGN-08  la qualificazione runtime macOS continua con il normal launch workload dopo questo gate PASS
ELECTRON-MAC-SIGN-09  evidence e conclusioni restano revision-specific
ELECTRON-MAC-SIGN-10  Git resta forward-only
```
