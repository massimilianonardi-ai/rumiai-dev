# Decisione — Physical validation ARM64 del normal launch DBeaver

Date: 2026-09-10  
Status: **Validated**

## Scope

Questa evidence riguarda esclusivamente il normal launch del DBeaver realmente installato e selezionato come default attraverso il package subsystem corrente.

La revisione prodotto validata è:

```text
rumiai-os@79cb5964428ca68c06c2f4eac98ac7350ae9561f
```

Il percorso osservato è:

```text
pkg install dbeaver
-> pkg_default dbeaver
-> bin/ext-osarch/dbeaver
-> bin/ext-<osarch>/dbeaver
-> pkg/<pkg>!<osarch> current selector
-> concrete cmd/dbeaver
-> rumiai-os command runtime
-> pkg-launch.lib.sh
-> concrete link/dbeaver
-> executable DBeaver sotto concrete root
```

Il normal launch non passa da `pkg` dopo la selezione del default e non consulta `pkg-catalog` durante l'esecuzione del command binding già materializzato.

Questa validation completa i gate separati già acquisiti per:

```text
pkg install dbeaver
pkg_default dbeaver
```

senza fonderne le semantiche.

---

## Ubuntu ARM64

Sessione:

```text
validation/20260910T190400+0200-106058
validation evidence commit ea7d78340c9a14792f7985008d66e0eb6f29a7be
rumiai-tests parent f0a9b0c34d70859d0ba2b26c1e9407c30fbda5cf
rumiai-os 79cb5964428ca68c06c2f4eac98ac7350ae9561f
```

Risultato persistito:

```text
PASS external/dbeaver/launch-live.test
timing 19.39 s
launched=dbeaver@26.2.0!linux-arm64
public-command=bin/ext-osarch/dbeaver
configuration=created
workspace=created
runner-exit-status=0
```

Il criterio automatico di quella revisione del test osservava processo vivo e creazione delle aree runtime attese, ma non conteneva ancora conferma interattiva della finestra.

Durante la stessa esecuzione l'utente ha osservato fisicamente l'effettiva apertura della finestra DBeaver sul reference Ubuntu ARM64.

La validation Ubuntu è quindi costituita congiuntamente da:

```text
evidence immutabile del percorso normal launch riuscito
+
osservazione fisica dell'effettiva GUI da parte dell'operatore
```

---

## macOS ARM64 — tentativi intermedi

La prima esecuzione macOS con la stessa revisione iniziale del test produsse un PASS automatico ma l'utente osservò che la finestra non era comparsa:

```text
validation/20260910T190532+0200-11203
validation evidence commit 87b08f1f895828bf07093a057b3332a0bf3c13e5
rumiai-tests parent f0a9b0c34d70859d0ba2b26c1e9407c30fbda5cf
recorded result PASS
timing 36.30 s
```

Quella sessione resta evidence di inizializzazione/processo/state creation, ma il PASS è un falso positivo rispetto alla proprietà più forte "GUI realmente visibile" e non viene usato per validare il normal launch macOS.

Il test fu quindi corretto in:

```text
rumiai-tests@61769281ef40a5efc1c37ccf7334ced4d49dc391
```

introducendo conferma esplicita dell'operatore via `/dev/tty`. Una prima esecuzione della correzione fece però SKIP perché il test assumeva erroneamente che fd 0 dovesse essere un TTY:

```text
validation/20260910T193122+0200-12657
validation evidence commit d2e08c2a7e994f5dac5385d69d67e3f7fb2f08bb
result SKIP
timing 0.36 s
```

Il runner usa stdin per la propria lista di esecuzione; il test fu quindi riallineato a usare direttamente il controlling terminal senza dipendere da fd 0.

Queste due sessioni intermedie restano immutabili e non vengono reinterpretate come validation positiva del normal launch macOS.

---

## macOS ARM64 — validation finale

La revisione corretta del test è:

```text
rumiai-tests@cd2980b076abe0ad6889862c3f4483ff8cac08a6
commit: Use controlling TTY for DBeaver launch confirmation
selection: external/dbeaver/launch-live.test
```

Sessione finale:

```text
validation/20260910T195700+0200-13062
validation evidence commit 8b65dad89f8415dfe6a5ed8ac0c059573eeafcfb
rumiai-tests parent cd2980b076abe0ad6889862c3f4483ff8cac08a6
rumiai-os 79cb5964428ca68c06c2f4eac98ac7350ae9561f
OS Darwin 26.6.2
architecture arm64
kernel Darwin 25.6.0
```

Risultato:

```text
PASS external/dbeaver/launch-live.test
timing 45.58 s
runner-exit-status=0
```

Il log immutabile registra:

```text
launched=dbeaver@26.2.0!macos-arm64
public-command=bin/ext-osarch/dbeaver
configuration=created
workspace=created
gui-visible=confirmed
```

L'utente ha inoltre osservato fisicamente l'apertura della finestra DBeaver prima di confermare il prompt del test.

Questa sessione costituisce quindi evidence positiva forte del normal launch DBeaver sul reference macOS ARM64 per la revisione prodotto indicata.

---

## Conclusione

Il normal launch DBeaver per:

```text
rumiai-os@79cb5964428ca68c06c2f4eac98ac7350ae9561f
pkg-catalog@514cb620075188ec9ad9090f6bd008fcec85913f
```

è fisicamente validato sui reference host Ubuntu ARM64 e macOS ARM64.

Sono quindi chiusi separatamente sullo stesso baseline prodotto:

```text
pkg install dbeaver       PASS Ubuntu ARM64 + macOS ARM64
pkg_default dbeaver       PASS Ubuntu ARM64 + macOS ARM64
normal launch dbeaver     PASS Ubuntu ARM64 + macOS ARM64 con GUI realmente osservata
```

Questa evidence non valida revisioni future e non costituisce validation di Windows/MSYS2 né delle future operazioni lifecycle.

---

## Invarianti di evidence

```text
DBEAVER-LAUNCH-VAL-01  il prodotto validato è rumiai-os@79cb596
DBEAVER-LAUNCH-VAL-02  il normal launch Ubuntu è supportato da sessione ea7d783 + osservazione fisica dell'utente
DBEAVER-LAUNCH-VAL-03  il PASS macOS 87b08f1 resta falso positivo per la proprietà GUI e non viene usato come validation finale
DBEAVER-LAUNCH-VAL-04  la sessione macOS d2e08c2 resta SKIP dovuto alla precondizione fd0 della revisione test 6176928
DBEAVER-LAUNCH-VAL-05  la validation macOS finale usa rumiai-tests@cd2980b e sessione 8b65dad
DBEAVER-LAUNCH-VAL-06  il log finale macOS registra gui-visible=confirmed e l'utente ha osservato fisicamente la GUI
DBEAVER-LAUNCH-VAL-07  normal launch resta distinto da availability e default selection
DBEAVER-LAUNCH-VAL-08  le evidence storiche non vengono riscritte
DBEAVER-LAUNCH-VAL-09  Windows/MSYS2 e lifecycle restano fuori dallo scope
```
