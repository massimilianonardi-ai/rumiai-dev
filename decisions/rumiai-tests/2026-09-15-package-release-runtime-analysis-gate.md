# Decisione — Gate di runtime analysis per i package in rilascio

Date: 2026-09-15  
Status: **Accepted / Active — physical evidence pending**

## 1. Correzione applicata

La physical validation di download/install/launch non e' sufficiente, da sola, a considerare verificata una nuova package definition.

Per esplicita correzione dell'utente, prima del rilascio una nuova package definition deve essere sottoposta a `pkg-analyze` per osservare il comportamento reale del payload normalizzato durante il runtime.

Il precedente gate Node.js Content-Length resta evidence valida della remediation del resolver/download/install sulla revisione esercitata, ma non viene reinterpretato come release gate completo della package definition Node.js: non includeva `pkg-analyze`.

Questa decisione e' forward-only e non modifica le evidence storiche.

## 2. Scope corrente

Il work unit corrente riguarda esclusivamente:

```text
chrome
chromium
jq
micromamba
nodejs
pulsar
```

Sono esplicitamente fuori scope, anche se presenti nel catalogo corrente:

```text
keycloak
maven
netbeans
```

oltre a qualsiasi altro package non elencato sopra. I package fuori scope hanno remediation o verifiche proprie da affrontare in una fase successiva e non devono essere trascinati in questo gate.

## 3. Revisioni di partenza

Preflight del work unit:

```text
rumiai-dev    b34ed0d9ff33bdd776fd0956ea61b4f119abdc17
rumiai-os     0751add1a59f90d4a0fc19b36db9d4dbda0167ad
rumiai-tests  c98d96aa6708f2d5d1216a5dfb14fc866c020b8b
pkg-catalog   af4332445d8f6ad678ff7ec2a14e482358a43182
```

Le package subtree correnti da osservare sono:

```text
chrome      e604224104d352473b1d4cd61a7d18ee467c9ca3
chromium    2e4df5df3588db656763b014453d8b1f5d63dff9
jq          4119740a4a92c4da21c772c3613a6144abd35611
micromamba  384bbf72d1998ef39832be5d0ba8eef29728c3c6
nodejs      5166a81b561ea1b30b31ddd829c6c4e1eadc14ac
pulsar      d3832f9a6ea99e28eb7e56744a1cfa03abae5be5
```

Un avanzamento del solo HEAD di `pkg-catalog` per package estranei non invalida automaticamente una evidence: deve essere registrata anche la tree identity del package realmente esercitato.

## 4. Autorita' package-specifiche

Restano autorevoli, senza riapertura:

```text
chrome    decisions/rumiai-os/2026-09-15-google-chrome-package-integration.md
chromium  decisions/rumiai-os/2026-09-15-chromium-package-catalog.md
          decisions/rumiai-os/2026-09-15-chromium-runtime-support.md
jq        decisions/rumiai-os/2026-09-15-jq-package-integration.md
nodejs    decisions/rumiai-os/2026-09-14-nodejs-package-integration.md
          piu' la successiva remediation Content-Length gia' consolidata
```

Per `micromamba` e `pulsar` non e' stata trovata nel preflight una decisione package-specifica corrente in `rumiai-dev`. Le definition gia' presenti in `pkg-catalog` sono quindi materiale candidato da verificare, non una nuova autorita' architetturale implicita. Il gate puo' produrre evidence e individuare correzioni; una modifica semantica della definition deve essere consolidata prima di modificare catalogo o prodotto.

## 5. Analisi obbligatoria con `pkg-analyze`

Per ogni target fisicamente esercitato:

1. il package viene installato realmente in una root RumiAI isolata;
2. viene individuata la concrete package version e la sua `root/` normalizzata;
3. `pkg-analyze <extracted-directory>` viene eseguito su quella root;
4. il candidate che corrisponde al command upstream materialmente esportato viene sottoposto a dynamic probe quando il contratto corrente di `pkg-analyze` lo rende direttamente eseguibile;
5. per package GUI il programma deve essere realmente avviato e chiuso dall'operatore; una mera `--version` non sostituisce il dynamic probe;
6. il report `pkg-analyze` deve essere conservato nella normale evidence di validation.

Per Node.js il probe `pkg-analyze` protegge il candidate direttamente osservabile del payload (`node`). `npm` e `npx`, quando materializzati upstream attraverso symlink/script non classificati come candidate dal contratto corrente di `pkg-analyze`, restano obbligatoriamente esercitati attraverso i command RumiAI reali e non vengono dichiarati analizzati da `pkg-analyze` per analogia.

## 6. Package-root immutability

Il contratto corrente di `pkg-analyze` confronta pathname e tipo e dichiara esplicitamente di non rilevare ogni modifica in-place.

Di conseguenza il release gate usa due evidence complementari:

```text
pkg-analyze package-root path delta
inventario before/after della root usato dal test di release
```

L'inventario del test deve confrontare almeno:

```text
pathname + tipo
mode
contenuto SHA-256 dei regular file
symlink target
```

La root e' considerata runtime-immutable soltanto se l'inventario before/after coincide e il `package-root path delta` di `pkg-analyze` non mostra aggiunte/rimozioni inattese.

Questa verifica supplementare non cambia il baseline di `pkg-analyze` e non introduce una nuova primitive di prodotto: e' infrastruttura di validation proporzionata al requisito di rilascio.

## 7. State e HOME

Il dynamic probe deve inoltre produrre evidence per:

```text
redirected-environment path delta
original-HOME path delta
```

`original-HOME path delta` deve essere vuoto per un release positivo.

Lo state creato nelle directory environment redirette non viene automaticamente considerato errore: deve essere esaminato per verificare che il launcher/package contract corrente lo collochi nello state RumiAI appropriato. Se l'osservazione richiede una correzione di package definition, il package resta pending fino alla remediation e a una nuova evidence positiva.

## 8. Launch attraverso RumiAI

Il probe diretto del payload non sostituisce il test del command integrato.

Per ogni command pubblico dichiarato dalla package definition deve essere esercitato il relativo concrete command RumiAI. Quando esiste una forma non interattiva autorevole (`--version` o equivalente) viene usata anche quella per una verifica deterministica minima.

Per i package GUI:

```text
chrome
chromium
pulsar
```

la release richiede inoltre un launch grafico reale con conferma operatore e terminazione pulita, secondo il precedente gia' usato dalla suite per applicazioni GUI.

## 9. Target e host applicabili

Il gate e' target-aware. Un PASS su una osarch non diventa evidence per un'altra osarch che usa artifact, pathname o runtime differenti.

Target dichiarati correnti:

```text
chrome      linux-x86_64
chromium    linux-x86_64, macos-arm64, macos-x86_64, windows-arm64, windows-x86_64
jq          linux-arm64, linux-x86_64, macos-arm64, macos-x86_64, windows-arm64, windows-x86_64
micromamba  linux-arm64, linux-x86_64, macos-arm64, macos-x86_64, windows-arm64, windows-x86_64
nodejs      linux-arm64, linux-x86_64, macos-arm64, macos-x86_64, windows-arm64, windows-x86_64
pulsar      linux-arm64, linux-x86_64, macos-arm64, macos-x86_64, windows-x86_64
```

Gli host stabili correnti restano macOS e Ubuntu 26.04 ARM64. Ubuntu x64 e ambienti Windows POSIX-compatible sono host periodici quando pertinenti.

Per questo work unit:

- una evidence viene richiesta su ogni host stabile per cui il package dichiara il target corrispondente;
- `chrome`, non avendo un target esercitabile sui due host stabili ARM64 correnti, richiede almeno Ubuntu x64 prima di qualunque stato di release;
- target Windows dichiarati non vengono descritti come fisicamente validati finche' non esiste una evidence Windows POSIX-compatible;
- la presenza di stream non esercitati resta una limitazione esplicita della release evidence, non viene colmata per analogia.

## 10. Esito di release

Per ogni package/target il gate deve distinguere:

```text
PENDING     manca una prova richiesta
VALIDATED   tutte le prove richieste sul target hanno PASS e l'evidence e' stata verificata
BLOCKED     l'analisi ha rivelato una correzione necessaria prima del release
```

Il package senza qualificatore di target non viene dichiarato completamente rilasciato finche' restano target dichiarati materialmente non verificati; le evidence positive gia' ottenute restano comunque valide per le esatte revisioni e target esercitati.

## 11. Invarianti

```text
PKG-RELEASE-01  questo gate riguarda solo chrome, chromium, jq, micromamba, nodejs e pulsar
PKG-RELEASE-02  ogni package/target fisicamente validato deve essere sottoposto a pkg-analyze
PKG-RELEASE-03  pkg-analyze e launch del command RumiAI sono evidence distinte e entrambe necessarie
PKG-RELEASE-04  package-root path delta vuoto non basta da solo: la root viene confrontata anche per contenuto/mode/symlink target
PKG-RELEASE-05  original-HOME path delta deve essere vuoto
PKG-RELEASE-06  redirected state viene osservato e valutato contro il package/launcher contract, non ignorato
PKG-RELEASE-07  GUI package = avvio reale + chiusura/conferma operatore; --version da sola non e' release evidence
PKG-RELEASE-08  evidence e stato release sono revision-specific e target-specific
PKG-RELEASE-09  target non esercitati non vengono dichiarati validati per analogia
PKG-RELEASE-10  il vecchio gate Node.js Content-Length resta remediation evidence, non release evidence completa
PKG-RELEASE-11  micromamba e pulsar restano candidate definition finche' l'analisi non ne consolida il comportamento richiesto
PKG-RELEASE-12  nessuna modifica a rumiai-os o pkg-catalog e' autorizzata implicitamente da questo gate
PKG-RELEASE-13  Git resta forward-only e le evidence storiche restano immutabili
```