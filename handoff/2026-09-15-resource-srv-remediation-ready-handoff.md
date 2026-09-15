# Handoff — resource / `srv` remediation pronta per physical validation

Date: 2026-09-15  
Status: ready for physical validation

## Authority

Questo handoff è non normativo.

La coppia corrente è fissata da:

```text
decisions/rumiai-tests/2026-09-15-advance-validation-pair-after-resource-srv-remediation.md
```

Restano autoritativi anche:

```text
RULES.md
CONSISTENCY-GATE.md
TESTING.md
specifications/rumiai-os/RESOURCE-MODEL.md
decisions/rumiai-os/2026-09-14-srv-portable-service-lifecycle.md
```

## Coppia da validare

```text
rumiai-os    a5442e527f6bc7a70022f09330ba27770c0b5fb7
rumiai-tests df36a9d359901fa16daa1c7b763a3d8ec85ca2a2
selection    rumiai-os
```

Il prodotto non è cambiato durante la remediation.

## Remediation completata

Il confronto netto tra:

```text
rumiai-tests@16f3926a224dd32d7d226a39234c779fa4ce1353
rumiai-tests@df36a9d359901fa16daa1c7b763a3d8ec85ca2a2
```

contiene soltanto i permanent test interessati dalla remediation.

Sono stati riallineati:

```text
bootstrap/branded-path-prepend.test
bootstrap/system-profile-selector.test
command/* interessati dalla fixture inline
osarch/update.test
shell/* interessati dalla fixture inline
state-path/contract.test
pkg/setuid.test
pkg-repository-nodejs/artifact.test
srv/lifecycle.test
```

Le fixture interessate usano ora:

```text
res
```

in luogo del superseded top-level:

```text
lang
```

Le copie inline della fixture completa puntano alla sorgente immutabile:

```text
rumiai-tests@216e4ffdd9ae31e625fd2c47e27573bdae9c4538:lib/rumiai-os-fixture.lib
```

## Correzioni specifiche

### Resource model

I permanent test interessati richiedono/copano il tree:

```text
$m_ROOT/res
```

Il consistency scan sul branch corrente non trova più nei test le forme superseded analizzate:

```text
source_root/lang
root/lang
fixture_dir in bin lib lang state
```

### `pkg/setuid`

I cataloghi tecnici attesi sono ora:

```text
$root/res/sys/lang/en_US/...
$root/res/sys/lang/it_IT/...
```

### Node.js artifact descriptor

L'aspettativa iniziale del digest in `pkg-repository-nodejs/artifact.test` è stata corretta a 64 cifre esadecimali, coerentemente con SHA-256 e con il resto dello stesso test.

### `srv` su macOS

Il precedente fallimento aggiuntivo macOS era dovuto al confronto tra un pathname di fixture non canonicalizzato basato su `/tmp` e il pathname realmente canonicalizzato dal prodotto, che su macOS può essere rappresentato sotto `/private/tmp`.

Il test continua a proteggere `SRV-05`: legge il metadata `command`, canonicalizza l'expected target tramite `realpath` e richiede uguaglianza esatta tra i due pathname canonicali. La diagnostica espone expected e observed in caso di mismatch.

Nessun workaround host-specific è stato introdotto in `rumiai-os`.

## File mode e struttura

Il tree corrente di `rumiai-tests` conserva `100755` per i `.test` coinvolti dalla remediation.

`rumiai-validate.conf` resta:

```text
rumiai-os-commit<TAB>a5442e527f6bc7a70022f09330ba27770c0b5fb7
selection<TAB>rumiai-os
```

Non è stata introdotta una nuova chiave di configurazione per la revisione della suite.

## Storia Git forward-only

Durante il lavoro sono stati accidentalmente creati e immediatamente rimossi alcuni file temporanei vuoti mediante coppie di commit successive.

La storia non è stata riscritta e non deve esserlo. Tali coppie hanno effetto netto nullo sul tree corrente; nessun `tmp-do-not-create*` resta nel repository.

La revisione da validare è quindi esattamente:

```text
rumiai-tests@df36a9d359901fa16daa1c7b763a3d8ec85ca2a2
```

## Evidence precedente

Restano immutabili come failure evidence della vecchia suite:

```text
Ubuntu 26.04 ARM64
validation/20260915T145047+0200-376171

macOS ARM64
validation/20260915T145126+0200-42022
```

Non vengono reinterpretate come evidence della nuova coppia.

## Verifiche già completate

Sono stati verificati sul repository corrente:

```text
HEAD remoti prima e dopo la remediation
net diff della suite rispetto alla revisione fallita
contenuti dei cambi critici
assenza dei pattern superseded sopra elencati
file mode dei permanent test
configurazione revision-specific del prodotto e selection
assenza di modifiche a rumiai-os
```

L'ambiente di lavoro usato per l'analisi non consente di materializzare il checkout Git completo per eseguire onestamente la full suite o un `sh -n` locale su tutti i file. Non viene quindi dichiarata evidence di esecuzione che non sia stata realmente prodotta.

## Prossimo gate

Eseguire sui reference host:

```text
./rumiai-validate
```

almeno su:

```text
Ubuntu 26.04 ARM64
macOS ARM64
```

Il launcher deve self-update a:

```text
rumiai-tests@df36a9d359901fa16daa1c7b763a3d8ec85ca2a2
```

e mantenere:

```text
rumiai-os@a5442e527f6bc7a70022f09330ba27770c0b5fb7
selection=rumiai-os
```

Solo dopo PASS della full-suite si procede al gate separato:

```text
external/nodejs/install-live.test
```

## Vincoli di continuazione

```text
- non ripristinare il top-level lang
- non allentare SRV-05
- non reinterpretare le vecchie sessioni come PASS
- non avanzare al gate live Node.js prima della full-suite positiva
- non riscrivere la storia Git
```
