# Decisione — Piano package corrente dopo la physical validation del normal launch DBeaver

Date: 2026-09-10  
Status: **Accepted**

## Scopo e supersession

Questo documento è il checkpoint operativo corrente della sequenza package e supersede, esclusivamente per stato di avanzamento e physical-validation status, il checkpoint:

```text
decisions/rumiai-os/2026-09-10-package-current-plan-after-dbeaver-launch-observation.md
```

I contratti architetturali e tecnici restano nei rispettivi documenti autorevoli.

---

## Baseline prodotto corrente

La baseline prodotto resta:

```text
rumiai-os@79cb5964428ca68c06c2f4eac98ac7350ae9561f
pkg-catalog@514cb620075188ec9ad9090f6bd008fcec85913f
```

Sono fisicamente acquisiti sui reference host ARM64 Ubuntu e macOS:

```text
full rumiai-os validation
pkg install dbeaver live end-to-end
pkg_default dbeaver live
normal launch dbeaver con GUI realmente osservata
```

Le rispettive evidence revision-specific restano nei documenti dedicati.

Il normal launch finale è consolidato da:

```text
decisions/rumiai-os/2026-09-10-dbeaver-normal-launch-arm64-physical-validation.md
```

---

## Chiusura del gate I

Il punto I è completato:

```text
default DBeaver Ubuntu ARM64    PASS
default DBeaver macOS ARM64     PASS
normal launch Ubuntu ARM64      PASS con osservazione fisica GUI
normal launch macOS ARM64       PASS con osservazione fisica GUI e gui-visible=confirmed
```

Per macOS la sessione conclusiva è:

```text
validation/20260910T195700+0200-13062
validation evidence commit 8b65dad89f8415dfe6a5ed8ac0c059573eeafcfb
rumiai-tests parent cd2980b076abe0ad6889862c3f4483ff8cac08a6
rumiai-os 79cb5964428ca68c06c2f4eac98ac7350ae9561f
result PASS
timing 45.58 s
runner-exit-status 0
```

Il log registra esplicitamente:

```text
launched=dbeaver@26.2.0!macos-arm64
public-command=bin/ext-osarch/dbeaver
configuration=created
workspace=created
gui-visible=confirmed
```

Le precedenti sessioni macOS con falso positivo e SKIP restano evidence storiche immutabili e non vengono usate come prova finale del launch.

---

## Fase corrente: lifecycle

La sequenza passa ora al punto:

```text
J  lifecycle uninstall/version/current
```

La fase non autorizza implicitamente modifiche al prodotto; prima dell'implementazione devono essere consolidati i contratti ancora aperti.

### Già fissato

La CLI pubblica già Accepted comprende:

```text
pkg install <package> [<package> ...]
pkg uninstall <package> [<package> ...]
```

Gli operand di `pkg uninstall` usano la stessa grammatica lessicale già fissata per install:

```text
<pkg>
<pkg>@<version>
<pkg>!<osarch>
<pkg>@<version>!<osarch>
```

`pkg uninstall` è local-only:

```text
- non effettua refresh del catalogo;
- non interroga upstream;
- una versione omessa non significa latest upstream.
```

Esistono già le primitive interne:

```text
pkg_deintegrate <pkg> <version> [<osarch>]
pkg_default <pkg> <version-or-empty> [<osarch>]
```

con responsabilità già fissate:

```text
pkg_deintegrate
    rimuove availability di una concrete version non-current
    rifiuta la concrete version current/default

pkg_default
    seleziona/rimuove current
    gestisce i binding pubblici corrispondenti
```

Il current selector fisico è già fissato:

```text
generic        pkg/<pkg> -> <pkg>@<version>
target-specific pkg/<pkg>!<osarch> -> <pkg>@<version>!<osarch>
```

ed è sempre un symlink relativo.

### Non ancora fissato

Il label di piano:

```text
lifecycle uninstall/version/current
```

non costituisce da solo definizione di nuovi sottocomandi pubblici.

Nelle decisioni Accepted correnti non risulta ancora fissata una CLI pubblica denominata:

```text
pkg version ...
pkg current ...
```

né sono ancora fissate completamente le rispettive semantiche osservabili.

Restano quindi da consolidare prima dell'implementazione almeno:

```text
1  semantica di pkg uninstall quando <version> è omessa e più versioni locali esistono;
2  comportamento di uninstall quando la versione indicata è current;
3  eventuale relazione fra uninstall e rimozione esplicita del current/default;
4  operazione pubblica per osservare le versioni installate/localmente disponibili;
5  operazione pubblica per osservare e/o cambiare il current, inclusa la distinzione read vs mutation;
6  output canonico delle operazioni di osservazione;
7  exit status e comportamento multi-package delle nuove operazioni;
8  ruolo del target implicito/esplicito per le operazioni local-only;
9  eventuale interazione con package generic e target-specific coesistenti nella stessa root.
```

Questi punti non devono essere risolti per inferenza dai nomi `version/current` del piano.

---

## Stato implementativo

Il command entry corrente:

```text
rumiai-os/bin/sys/pkg
```

espone oggi soltanto:

```text
pkg install
```

Le primitive di integrazione/deintegrazione/default sono già implementate nella libreria package integration e protette da test permanenti.

I test permanenti `tests/rumiai-os/pkg/` proteggono attualmente:

```text
catalog-snapshot.test
install.test
```

Non esistono ancora test permanenti lifecycle pubblici per `uninstall/version/current`.

La prossima unità corretta è quindi:

```text
consolidamento contratto lifecycle
-> test permanenti proporzionati
-> implementazione autorizzata nel command entry/layer necessario
-> validation revision-specific
```

---

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
I  validazione separata default + normal launch                       [completato]
J  lifecycle uninstall/version/current                                [corrente: contratto da consolidare]
K  dependency/facility/state avanzato soltanto quando richiesto       [successivo]
```

---

## Invarianti correnti

```text
PKG-NOW-01  pkg install produce availability e non seleziona il default
PKG-NOW-02  pkg_default resta l'unico layer corrente per current e binding pubblici
PKG-NOW-03  launcher vive in lib/sh/pkg-launch.lib.sh ed è caricato esplicitamente dai command entry che lo usano
PKG-NOW-04  normal launch non passa da pkg e non consulta pkg-catalog
PKG-NOW-05  dmg preferisce hdiutil+ditto quando entrambe disponibili; 7zz/7z/7za sono fallback di capability
PKG-NOW-06  un errore operativo del backend dmg selezionato non provoca retry
PKG-NOW-11  rumiai-os@79cb596 è fisicamente validata sul gruppo completo rumiai-os dei due reference host ARM64
PKG-NOW-12  pkg install dbeaver su rumiai-os@79cb596 è live PASS sui due reference host ARM64
PKG-NOW-18  pkg_default dbeaver su rumiai-os@79cb596 è live PASS sui due reference host ARM64
PKG-NOW-31  normal launch dbeaver su rumiai-os@79cb596 è fisicamente validato sui due reference host ARM64 con GUI osservata
PKG-NOW-32  la validation finale macOS usa rumiai-tests@cd2980b e sessione 8b65dad con gui-visible=confirmed
PKG-NOW-33  il gate I default+launch è chiuso
PKG-NOW-34  la fase corrente è il lifecycle J
PKG-NOW-35  pkg uninstall è già CLI canonica local-only con la grammatica operand fissata
PKG-NOW-36  pkg_deintegrate e pkg_default sono primitive esistenti da riusare per le responsabilità già coperte
PKG-NOW-37  i nomi version/current nel label del piano non definiscono automaticamente nuovi sottocomandi pubblici
PKG-NOW-38  CLI, output e semantiche ancora aperte del lifecycle devono essere consolidate prima della modifica prodotto
PKG-NOW-39  nessuna operazione local-only lifecycle deve acquisire refresh/catalog/upstream senza una nuova responsabilità esplicita
PKG-NOW-40  Git resta forward-only e ogni futura implementazione richiede validation revision-specific proporzionata
```
