# Decisione — Piano package corrente dopo la validation ARM64 completa

Date: 2026-09-10  
Status: **Accepted**

## Scopo e supersession

Questo documento è il checkpoint operativo corrente della sequenza package e supersede, esclusivamente per stato di avanzamento e physical-validation status, il piano del 2026-09-09:

```text
decisions/rumiai-os/2026-09-09-package-implementation-plan-and-catalog-refresh-boundary.md
```

Le decisioni architetturali e i contratti tecnici specifici restano nei rispettivi documenti autorevoli.

Sono inoltre superseded come descrizione dello stato corrente tutte le frasi nei documenti precedenti che indicano `launcher` come non ancora implementato o collocato in `core.lib.sh`. Il contratto corrente è:

```text
decisions/rumiai-os/2026-09-10-package-launch-library.md
```

---

## Stato corrente

La sequenza implementativa è:

```text
1  confine refresh/snapshot pkg-catalog                                      [completato]
2  test permanenti HTTP/JSON/GitHub adapter                                 [completato]
3  pkg_download                                                               [completato]
4  digest/extract                                                             [completato]
5  pkg_extract structural useful-root normalization                           [completato]
6  pkg-analyze consumo diretto del pkg_extract normalizzato                   [completato]
7  DBeaver package definition Linux/macOS/Windows x86_64                     [completato]
8  pkg_integrate/pkg_deintegrate/pkg_default                                  [completato]
9  orchestrazione reale pkg install                                           [completato]
9a package launcher direct-link in lib/sh/pkg-launch.lib.sh                  [completato]
10 lifecycle uninstall/version/current                                        [successivo dopo il gate live DBeaver]
11 dependency/facility/state avanzato quando richiesto                        [successivo]
```

`9a` non introduce una nuova fase concettuale del package manager: registra soltanto il completamento della primitive runtime necessaria a rendere eseguibili i command materializzati dal modello già fissato.

---

## Physical validation acquisita

La precedente coppia:

```text
rumiai-os@b724bd1f3a4ea6fe0b968c5ea38e7db835fee179
rumiai-tests@897e830d58f10fdf4e66b907a7aa9daa900c722b
```

resta evidence revision-specific della validation completa del gruppo `rumiai-os` precedente alla correzione prestazionale JSON:

```text
Ubuntu ARM64  PASS 65 / FAIL 0 / SKIP 2 / ERROR 0
macOS ARM64   PASS 67 / FAIL 0 / SKIP 0 / ERROR 0
```

Evidence:

```text
decisions/rumiai-os/2026-09-10-rumiai-os-arm64-physical-validation.md
```

Dopo il problema prestazionale emerso nel percorso GitHub live, `lib/sh/json.lib.sh` è stato corretto per non materializzare le stringhe JSON non selezionate pur continuando a validarle. La coppia:

```text
rumiai-os@46718998627825055991ebb648b6edbc9cc52950
rumiai-tests@8c5d1820527089c186bcb21e254d9d5650178bf8
```

è stata nuovamente validata sul gruppo completo `rumiai-os` sui due reference host ARM64:

```text
Ubuntu ARM64  PASS 65 / FAIL 0 / SKIP 2 / ERROR 0
macOS ARM64   PASS 67 / FAIL 0 / SKIP 0 / ERROR 0
```

I due `SKIP` Ubuntu derivano esclusivamente dall'assenza di Zsh.

Evidence:

```text
decisions/rumiai-os/2026-09-10-json-parser-correction-arm64-physical-validation.md
```

Le evidence precedenti restano immutabili e non vengono retroattivamente attribuite alle revisioni successive.

---

## DMG native-first: PoC e implementazione corrente

Il confine macOS emerso nel gate live DBeaver è stato investigato con:

```text
rumiai-dev-PoCs/pocs/006-macos-dmg-extraction/
rumiai-dev-PoCs@a48039e8e7f2b7333439f22eb6cd0ee5e7a1658d
```

Il PoC sul reference macOS ARM64 ha prodotto `PASS` usando il DMG reale DBeaver 26.2.0. Sullo stesso host sono stati osservati `hdiutil` e `ditto`, mentre `7zz`, `7z` e `7za` erano assenti. L'executable `DBeaver.app/Contents/MacOS/dbeaver` è rimasto executable e byte-identico dopo la copia dal volume montato alla destination.

La decisione canonica `2026-09-09-digest-and-extract-system-utilities.md` è stata quindi aggiornata esplicitamente. Il contratto corrente per `dmg` è:

```text
1  hdiutil + ditto, quando entrambe le capability sono disponibili
2  7zz
3  7z
4  7za
```

La selezione avviene per disponibilità della capability, non tramite nome della piattaforma. Un errore operativo del backend selezionato termina l'operazione e non provoca retry con il backend successivo.

Il prodotto è stato riallineato in:

```text
rumiai-os@a2531626b68e81c9df4e76a007e7f963b3f26343
```

ed il test permanente `rumiai-os/extract/dispatch.test` è stato riallineato per proteggere selezione native-first, fallback 7-Zip e assenza di retry dopo failure del backend nativo.

Questa revisione prodotto **non è ancora fisicamente validata** sui reference host. La precedente physical validation `4671899/8c5d182` non viene estesa a questa modifica.

---

## Confine ancora non validato fisicamente

I test permanenti correnti di `pkg install` nel gruppo `rumiai-os` usano fixture e repository Git locali. Resta quindi da chiudere il percorso live:

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

Il test permanente live esiste già in:

```text
rumiai-tests/tests/external/dbeaver/install-live.test
```

Una precedente esecuzione Linux ARM64 sulla coppia `rumiai-os@b724bd1` / `rumiai-tests@3f83153` ha prodotto `PASS`, installando realmente `dbeaver@26.2.0!linux-arm64` dal catalogo `514cb620075188ec9ad9090f6bd008fcec85913f`. Tale evidence resta valida per quella coppia ma non viene promossa a validation della revisione prodotto corrente.

Sul reference macOS ARM64 la precedente esecuzione live non è arrivata a un risultato pubblicabile: l'indagine successiva ha isolato prima il costo patologico del parser JSON e poi l'assenza del precedente backend 7-Zip per `dmg`. Entrambi i confini sono stati ora affrontati a livello di implementazione; la nuova revisione deve essere validata prima di ripetere il gate live.

Il gate live continua a dover usare una root RumiAI isolata, non modificare il checkout operativo, non selezionare implicitamente il default e ripulire il payload temporaneo al termine.

Il launch GUI reale e la selezione esplicita del default restano gate successivi e distinti dal solo install live.

---

## Prossima sequenza operativa

```text
A  test permanente external/dbeaver/install-live.test                         [completato]
B  correzione + physical validation ARM64 del parser JSON                     [completato]
C  PoC mirato del backend DMG nativo sul reference macOS                      [completato]
D  consolidamento esplicito del nuovo contratto DMG native-first              [completato]
E  riallineamento extract e test permanenti                                   [completato]
F  physical validation ARM64 della nuova revisione rumiai-os                  [successivo]
G  riesecuzione gate live DBeaver su Ubuntu ARM64 e macOS ARM64               [successivo]
H  se entrambi PASS, chiusura del physical gate di pkg install DBeaver        [successivo]
I  validazione separata default + launch dove la precondizione GUI esiste     [successivo]
J  ripresa passo 10 lifecycle uninstall/version/current                        [successivo]
```

Il contratto DMG corrente risponde soltanto alla capability concreta richiesta e non stabilisce semantica universale per immagini multi-volume, hardening archive o altri casi non richiesti.

Non vengono introdotti prima del bisogno concreto:

```text
resolver universale
generations
inventory obbligatoria
migration framework
rollback globale
facility/dependency/state avanzato
```

---

## Invarianti correnti

```text
PKG-CURRENT-01  pkg install produce availability e non seleziona il default
PKG-CURRENT-02  pkg_default resta l'unico layer corrente per current e binding pubblici
PKG-CURRENT-03  launcher vive in lib/sh/pkg-launch.lib.sh ed è caricato esplicitamente dai command entry che lo usano
PKG-CURRENT-04  normal launch non passa da pkg e non consulta pkg-catalog
PKG-CURRENT-05  le precedenti coppie fisicamente validate restano evidence revision-specific e non coprono revisioni successive
PKG-CURRENT-06  il gate completo fixture/local-repository non viene promosso a prova del percorso GitHub/upstream live
PKG-CURRENT-07  il gate live DBeaver usa una root RumiAI isolata e lascia intatto il checkout target
PKG-CURRENT-08  i test live DBeaver restano fuori dal gruppo rumiai-os per non appesantire le normali validation
PKG-CURRENT-09  lifecycle uninstall/version/current resta il prossimo sviluppo dopo la chiusura dei gate package correnti
PKG-CURRENT-10  la coppia 4671899/8c5d182 è fisicamente validata sul gruppo rumiai-os dei due reference host ARM64
PKG-CURRENT-11  dmg preferisce hdiutil+ditto quando entrambe disponibili e usa 7zz/7z/7za soltanto come fallback di capability
PKG-CURRENT-12  un errore operativo del backend dmg selezionato non provoca retry con un backend successivo
PKG-CURRENT-13  rumiai-os@a253162 è la revisione prodotto corrente del backend dmg ed è pending physical validation ARM64
```
