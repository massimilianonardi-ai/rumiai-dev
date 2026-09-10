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

La coppia:

```text
rumiai-os@b724bd1f3a4ea6fe0b968c5ea38e7db835fee179
rumiai-tests@897e830d58f10fdf4e66b907a7aa9daa900c722b
```

è stata validata sul gruppo completo `rumiai-os` sui reference host ARM64:

```text
Ubuntu ARM64  PASS 65 / FAIL 0 / SKIP 2 / ERROR 0
macOS ARM64   PASS 67 / FAIL 0 / SKIP 0 / ERROR 0
```

I due SKIP Ubuntu derivano esclusivamente dall'assenza di Zsh.

Evidence completa:

```text
decisions/rumiai-os/2026-09-10-rumiai-os-arm64-physical-validation.md
```

Il precedente gate mirato di `pkg-launch` resta evidence immutabile della propria coppia revision-specific e non viene riscritto.

---

## Confine ancora non validato fisicamente

I test permanenti correnti di `pkg install` usano fixture e repository Git locali. Resta quindi da validare il percorso live:

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

Questo gate deve usare una root RumiAI isolata, non modificare il checkout operativo, non selezionare implicitamente il default e ripulire il payload temporaneo al termine.

Il test live appartiene al gruppo esterno DBeaver, non al gruppo `rumiai-os`, per evitare che ogni normale validation del prodotto scarichi nuovamente un artifact di grandi dimensioni.

Il launch GUI reale e la selezione esplicita del default sono gate successivi e distinti dal solo install live.

---

## Prossima sequenza operativa

```text
A  aggiungere test permanente external/dbeaver/install-live.test
B  eseguire il test live su Ubuntu ARM64 e macOS ARM64
C  registrare catalog HEAD e concrete version realmente osservati
D  se entrambi PASS, considerare chiuso il physical gate di pkg install DBeaver
E  validare separatamente default + launch DBeaver dove la precondizione GUI è disponibile
F  riprendere il passo 10 lifecycle uninstall/version/current
```

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
PKG-CURRENT-05  la coppia b724bd1/897e830 è fisicamente validata sul gruppo rumiai-os dei due reference host ARM64
PKG-CURRENT-06  il gate completo fixture/local-repository non viene promosso a prova del percorso GitHub/upstream live
PKG-CURRENT-07  il gate live DBeaver usa una root RumiAI isolata e lascia intatto il checkout target
PKG-CURRENT-08  i test live DBeaver restano fuori dal gruppo rumiai-os per non appesantire le normali validation
PKG-CURRENT-09  lifecycle uninstall/version/current resta il prossimo sviluppo dopo la chiusura dei gate package correnti
```
