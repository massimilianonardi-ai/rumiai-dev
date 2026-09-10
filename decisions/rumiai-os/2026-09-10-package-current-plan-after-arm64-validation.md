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

Dopo il problema prestazionale emerso nel percorso GitHub live, `lib/sh/json.lib.sh` è stato corretto per non materializzare le stringhe JSON non selezionate pur continuando a validarle. La coppia corrente:

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

Evidence corrente:

```text
decisions/rumiai-os/2026-09-10-json-parser-correction-arm64-physical-validation.md
```

Le evidence precedenti restano immutabili e non vengono retroattivamente attribuite alla revisione corrente.

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

Sul reference macOS ARM64 la precedente esecuzione live non è arrivata a un risultato pubblicabile: l'indagine successiva ha isolato un costo patologico del parser JSON sulle pagine GitHub reali, poi corretto e fisicamente validato come indicato sopra.

Resta inoltre un confine separato prima di ripetere utilmente il gate live macOS: il contratto `extract` corrente associa `dmg` al primo backend disponibile fra `7zz`, `7z`, `7za`, mentre sul reference Mac osservato tali comandi non sono disponibili. Cambiare il backend `dmg` sarebbe una modifica del contratto accettato e non può essere introdotto come semplice workaround.

Il gate live continua a dover usare una root RumiAI isolata, non modificare il checkout operativo, non selezionare implicitamente il default e ripulire il payload temporaneo al termine.

Il launch GUI reale e la selezione esplicita del default restano gate successivi e distinti dal solo install live.

---

## Prossima sequenza operativa

```text
A  test permanente external/dbeaver/install-live.test                         [completato]
B  correzione + physical validation ARM64 del parser JSON                     [completato]
C  PoC mirato del backend DMG nativo sul reference macOS                      [successivo]
D  se il PoC giustifica un cambio di contratto, consolidare decisione         [successivo]
E  solo dopo approvazione, riallineare extract e i test permanenti            [successivo]
F  rieseguire il gate live DBeaver su Ubuntu ARM64 e macOS ARM64              [successivo]
G  se entrambi PASS, chiudere il physical gate di pkg install DBeaver         [successivo]
H  validare separatamente default + launch dove la precondizione GUI esiste   [successivo]
I  riprendere il passo 10 lifecycle uninstall/version/current                  [successivo]
```

Il PoC del punto C deve rispondere soltanto alla necessità concreta emersa per il DMG DBeaver corrente e non deve promuovere automaticamente una semantica universale per immagini multi-volume o altri casi non richiesti.

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
PKG-CURRENT-05  la precedente coppia b724bd1/897e830 resta evidence revision-specific e non copre revisioni successive
PKG-CURRENT-06  il gate completo fixture/local-repository non viene promosso a prova del percorso GitHub/upstream live
PKG-CURRENT-07  il gate live DBeaver usa una root RumiAI isolata e lascia intatto il checkout target
PKG-CURRENT-08  i test live DBeaver restano fuori dal gruppo rumiai-os per non appesantire le normali validation
PKG-CURRENT-09  lifecycle uninstall/version/current resta il prossimo sviluppo dopo la chiusura dei gate package correnti
PKG-CURRENT-10  la coppia corrente 4671899/8c5d182 è fisicamente validata sul gruppo rumiai-os dei due reference host ARM64
PKG-CURRENT-11  il mapping dmg -> 7zz/7z/7za resta vigente finché una decisione esplicita non lo modifica
PKG-CURRENT-12  l'assenza del backend DMG sul reference Mac è un confine da risolvere, non un motivo per trasformare il gate in SKIP
```
