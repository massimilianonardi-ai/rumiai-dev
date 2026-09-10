# Decisione — Piano package corrente dopo l'osservazione del normal launch DBeaver

Date: 2026-09-10  
Status: **Accepted**

## Scopo e supersession

Questo documento è il checkpoint operativo corrente della sequenza package e supersede, esclusivamente per stato di avanzamento e physical-validation status, il checkpoint:

```text
decisions/rumiai-os/2026-09-10-package-current-plan-after-dbeaver-live-validation.md
```

I contratti architetturali e tecnici restano nei rispettivi documenti autorevoli.

## Stato acquisito precedente

Restano acquisiti senza riapertura:

```text
rumiai-os@79cb5964428ca68c06c2f4eac98ac7350ae9561f
```

- full `rumiai-os` gate PASS sui due reference host ARM64;
- `pkg install dbeaver` live PASS sui due reference host ARM64;
- `pkg_default dbeaver` live PASS sui due reference host ARM64;
- `pkg install` produce availability e non seleziona il default;
- `pkg_default` resta il layer che materializza current e binding pubblico;
- il normal launch passa dal binding pubblico e non deve passare da `pkg` o consultare `pkg-catalog`.

Le evidence revision-specific precedenti restano nei documenti già pubblicati.

## Prima esecuzione del normal launch

La prima versione del test permanente era:

```text
rumiai-tests@f0a9b0c34d70859d0ba2b26c1e9407c30fbda5cf
tests/external/dbeaver/launch-live.test
selection: external/dbeaver/launch-live.test
```

Il test esercitava realmente:

```text
pkg install dbeaver
-> pkg_default dbeaver
-> bin/ext-osarch/dbeaver
-> binding target-specific
-> current selector
-> concrete cmd/dbeaver
-> rumiai-os
-> pkg-launch.lib.sh
-> launcher
-> concrete link/dbeaver
-> executable DBeaver nel root installato
```

Il criterio finale iniziale considerava sufficiente osservare contemporaneamente:

```text
processo DBeaver ancora vivo
configuration directory creata
.workspace/.metadata creata
```

Tale criterio si è rivelato insufficiente a dimostrare che la finestra GUI fosse effettivamente comparsa.

### Ubuntu ARM64

Sessione:

```text
validation/20260910T190400+0200-106058
validation commit ea7d78340c9a14792f7985008d66e0eb6f29a7be
rumiai-tests parent f0a9b0c34d70859d0ba2b26c1e9407c30fbda5cf
rumiai-os 79cb5964428ca68c06c2f4eac98ac7350ae9561f
result PASS
timing 19.39 s
```

L'utente ha osservato fisicamente che la finestra DBeaver si è realmente avviata.

La combinazione tra percorso reale esercitato dalla sessione e osservazione fisica dell'utente costituisce evidence positiva del normal launch DBeaver sul reference Ubuntu ARM64 per la revisione prodotto indicata.

### macOS ARM64

Sessione:

```text
validation/20260910T190532+0200-11203
validation commit 87b08f1f895828bf07093a057b3332a0bf3c13e5
rumiai-tests parent f0a9b0c34d70859d0ba2b26c1e9407c30fbda5cf
rumiai-os 79cb5964428ca68c06c2f4eac98ac7350ae9561f
recorded result PASS
timing 36.30 s
```

L'utente ha osservato fisicamente che la finestra DBeaver **non** si è avviata.

Il `PASS` registrato dalla sessione è quindi un **falso positivo del criterio del test** e non costituisce evidence di normal launch GUI riuscito su macOS.

La sessione conserva comunque evidence utile e più limitata: il percorso ha raggiunto l'eseguibile, il processo è rimasto vivo abbastanza da soddisfare il probe iniziale e DBeaver ha creato le aree di configuration/workspace attese. Queste proprietà dimostrano inizializzazione, non presentazione GUI.

La sessione storica non viene riscritta né eliminata; viene reinterpretata correttamente da questo checkpoint secondo l'osservazione fisica successiva.

## Correzione del test permanente

Il falso positivo è stato corretto esclusivamente nella suite, senza modificare `rumiai-os` o `pkg-catalog`:

```text
rumiai-tests@61769281ef40a5efc1c37ccf7334ced4d49dc391
commit: Require operator confirmation for DBeaver GUI launch
```

Il test continua a richiedere prima:

```text
processo DBeaver vivo
configuration creata
.workspace/.metadata creata
```

ma tali condizioni sono ora soltanto una precondizione per la verifica finale.

Per dichiarare `PASS` il test richiede inoltre conferma interattiva esplicita che la finestra DBeaver sia visibile. Il prompt è scritto e letto tramite `/dev/tty`:

```text
DBeaver window visible? Press Enter to confirm and close it, or type n then Enter if it did not appear:
```

Semantica:

```text
Enter / y / yes  -> GUI osservata, il test può completare PASS
n / no           -> GUI non osservata, FAIL
TTY non disponibile -> SKIP prima del setup costoso
```

Dopo la conferma positiva il test verifica ancora che il processo sia vivo e termina soltanto il PID avviato dal test.

Il test resta `100755`, indipendente, in root RumiAI isolata e continua a esercitare il normal command path reale.

## Gate corrente

Il punto I è ora:

```text
default DBeaver Ubuntu ARM64    completato
default DBeaver macOS ARM64     completato
normal launch Ubuntu ARM64      completato con osservazione fisica della GUI
normal launch macOS ARM64       NON completato
```

La prossima validazione proporzionata riguarda quindi soltanto il reference macOS ARM64 con:

```text
rumiai-os@79cb5964428ca68c06c2f4eac98ac7350ae9561f
rumiai-tests@61769281ef40a5efc1c37ccf7334ced4d49dc391
selection: external/dbeaver/launch-live.test
```

Non è giustificata una nuova modifica prodotto prima di osservare il risultato corretto del test macOS.

Se la finestra compare e l'operatore la conferma, il gate I può essere chiuso e la sequenza passa al lifecycle `uninstall/version/current`.

Se la finestra non compare, l'operatore deve rispondere `n`; il test produrrà `FAIL` e renderà disponibili stdout/stderr del processo per localizzare la divergenza prima di qualsiasi modifica a prodotto, catalogo o contratto.

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
I  validazione separata default + launch                              [corrente: resta solo launch macOS ARM64]
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
PKG-NOW-11  rumiai-os@79cb596 è fisicamente validata sul gruppo completo rumiai-os dei due reference host ARM64
PKG-NOW-12  pkg install dbeaver su rumiai-os@79cb596 è live PASS sui due reference host ARM64
PKG-NOW-18  pkg_default dbeaver su rumiai-os@79cb596 è live PASS sui due reference host ARM64
PKG-NOW-20  il primo launch test f0a9b0c aveva un criterio insufficiente: processo vivo + state creato non dimostrano GUI visibile
PKG-NOW-21  la sessione Linux ea7d783, insieme all'osservazione fisica dell'utente, valida il normal launch Ubuntu ARM64
PKG-NOW-22  il PASS macOS 87b08f1 è un falso positivo e non valida il normal launch GUI macOS
PKG-NOW-23  la sessione macOS 87b08f1 conserva soltanto evidence di inizializzazione e state creation
PKG-NOW-24  il test corretto 6176928 richiede conferma esplicita della GUI; una risposta negativa produce FAIL
PKG-NOW-25  un'esecuzione senza TTY non può produrre PASS per questo gate GUI e viene classificata SKIP
PKG-NOW-26  il solo sottogate rimanente del punto I è il normal launch DBeaver sul reference macOS ARM64
PKG-NOW-27  nessuna modifica a rumiai-os o pkg-catalog è giustificata dal falso positivo del test
PKG-NOW-28  lifecycle uninstall/version/current riprende soltanto dopo la chiusura del normal launch macOS
```
