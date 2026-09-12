# Decisione — Stabilizzare l'attuale `rumiai-os` prima di valutare la migrazione di modello

Date: 2026-09-12  
Status: **Accepted**

## 1. Scopo

Questa decisione fissa la sequenza di sviluppo da seguire prima di un eventuale passaggio al modello del futuro substrato general purpose.

Le riflessioni sul futuro substrato restano soggette al gate definito da:

```text
decisions/rumiai-os/2026-09-12-substrate-exploration-activation-gate.md
```

La presente decisione non attiva quel modello.

## 2. Strategia corrente

Lo sviluppo deve continuare sull'attuale `rumiai-os`, usando:

```text
identità corrente
bootstrap/runtime corrente
shebang correnti
namespace correnti
filesystem layout corrente
package model corrente
shell model corrente
testing workflow corrente
```

fino al raggiungimento di una baseline sufficientemente stabile del prodotto corrente.

Durante questa fase non devono essere introdotte modifiche preparatorie al futuro modello soltanto per facilitarne una possibile adozione successiva.

In particolare non devono essere anticipati, per questa ragione:

```text
rename del bootstrap
cambio degli shebang `#!/usr/bin/env rumiai-os`
separazione fisica del futuro substrato
cambio di repository ownership
nuovi namespace o semantic root legati al futuro modello
riclassificazione delle API secondo il futuro modello
migrazione dei permanent test verso identità non ancora adottate
```

Ogni modifica corrente continua a essere valutata esclusivamente contro requisiti e contratti correnti.

## 3. Stabilità non significa completezza

La baseline da raggiungere può essere funzionalmente incompleta.

Il criterio non è:

> RumiAI OS deve avere già tutte le funzionalità future previste.

Il criterio è invece:

> ciò che esiste e viene incluso nella baseline deve essere sufficientemente definito, coerente, robusto e validato da poter costituire un punto di riferimento affidabile per valutare una successiva migrazione architetturale.

È quindi accettabile che interi sottosistemi futuri non esistano ancora al momento del checkpoint.

## 4. Proprietà della baseline stabile

Il checkpoint di stabilità dovrà essere dichiarato esplicitamente quando il perimetro scelto soddisferà, in modo proporzionato, almeno queste proprietà:

```text
contratti correnti sufficientemente definiti
implementazione coerente con le specifiche correnti
assenza di contraddizioni note non accettate nel perimetro incluso
permanent test allineati alle proprietà che devono restare vere
validation evidence revision-specific sulle proprietà che richiedono validazione fisica
portabilità verificata sui reference host per il perimetro applicabile
stato dei failure contract conosciuto per le interfacce consolidate
documentazione corrente coerente con l'implementazione
contenuti testuali di prodotto completi e corretti in inglese secondo la language policy
working tree e revisioni identificabili per il checkpoint
```

Questo elenco definisce la qualità desiderata del checkpoint, non un obbligo di completare ogni area di prodotto prima di raggiungerlo.

Eventuali limitazioni note possono essere accettate quando sono esplicite, documentate e non rendono ambiguo il contratto del perimetro stabile.

## 5. Perimetro del checkpoint

Il perimetro esatto del checkpoint non viene congelato da questa decisione.

Lo sviluppo corrente può continuare ad aggiungere o completare capability necessarie finché appare utile farlo prima della valutazione di migrazione.

Quando il sistema raggiunge un punto nel quale:

```text
le fondamenta correnti sono robuste
le principali primitive general purpose necessarie sono utilizzabili
i contratti principali non stanno più cambiando continuamente
la suite permanente protegge adeguatamente il comportamento consolidato
```

si potrà dichiarare una candidate baseline da sottoporre al checkpoint di stabilità.

Non è necessario aggiungere nuove feature soltanto per rendere il checkpoint più "completo" se esse non sono necessarie alla valutazione del modello futuro.

## 6. Valutazione successiva della migrazione

Soltanto dopo il checkpoint stabile si apre una fase separata di assessment del futuro modello.

La domanda non sarà:

> come implementiamo immediatamente il nuovo modello?

ma:

> partendo da una baseline corrente stabile e conosciuta, quali modifiche concrete sono necessarie per trasformarla nel modello futuro, e il costo/beneficio complessivo rende la migrazione plausibile?

L'assessment dovrà almeno identificare gli impatti reali su:

```text
identità e naming del substrato
repository e ownership
bootstrap/runtime identity
shebang dei bootstrap-integrated command
runtime exposure nel PATH
environment-variable ownership e namespace
filesystem layout e semantic root
shell boundary
service/daemon boundary
command boundary
package/catalog ownership
contratto stabile iniziale
superficie di sviluppo iniziale
documentazione distribuita
specifiche e decisioni
permanent test
validation evidence
compatibilità e percorso di migrazione
Git forward-only
```

Questi elementi sono oggetti di assessment, non modifiche già approvate.

## 7. Esempio: bootstrap e shebang

Il runtime corrente espone e protegge oggi il contratto:

```text
rumiai-os
#!/usr/bin/env rumiai-os
bin/sys/rumiai-os -> ../../rumiai-os
```

Una futura separazione del substrato potrebbe richiedere un rename coordinato di questi elementi.

Tale rename non deve essere eseguito durante la fase corrente come preparazione preventiva.

Dopo il checkpoint dovrà invece essere trattato come una migrazione esplicita e completa, comprendendo almeno:

```text
nuova identity scelta
bootstrap root
runtime exposure
shebang consumer
specifiche
documentazione
permanent test
physical validation
compatibilità/migrazione degli eventuali consumer
```

Il medesimo principio vale per gli altri contratti strutturali.

## 8. Decisione dopo l'assessment

L'assessment può produrre almeno tre risultati legittimi:

```text
A. il nuovo modello appare sufficientemente plausibile
   -> si prepara e approva una fase esplicita di migrazione

B. il modello è promettente ma alcune questioni importanti restano aperte
   -> si continua l'esplorazione senza modificare il modello operativo corrente

C. costi, rischi o benefici non giustificano la migrazione
   -> si continua con l'attuale modello o si rivede l'ipotesi futura
```

Nessun risultato è predeterminato dalle riflessioni fin qui svolte.

## 9. Perché questa sequenza è preferita

La sequenza evita di combinare contemporaneamente due fonti di instabilità:

```text
sviluppo e consolidamento delle primitive correnti
+
migrazione delle fondamenta architetturali
```

Portare prima il sistema corrente a una baseline stabile consente di:

```text
conoscere meglio cosa stiamo realmente migrando
misurare il costo reale del rename e dei boundary change
separare bug preesistenti da regressioni della migrazione
conservare test ed evidence come baseline comparativa
ridurre il rischio di cambiare architettura sulla base di requisiti ancora ipotetici
valutare il futuro modello su esperienza concreta accumulata nello sviluppo corrente
```

## 10. Relazione con la futura stratificazione dei contratti

La direzione progettuale:

```text
stable contract
development surface
private implementation detail
```

resta non attiva durante questa fase.

Non è necessario riclassificare ora tutte le primitive correnti secondo quel modello.

L'esperienza accumulata continuando a sviluppare `rumiai-os` servirà invece come evidenza concreta per capire, al momento dell'assessment:

```text
quali primitive sono realmente consumate stabilmente
quali risultano utili soltanto allo sviluppo
quali sono puri implementation detail
```

Questo riduce il rischio di classificare prematuramente API sulla base di ipotesi.

## 11. Testing e validation

Durante la fase corrente continuano a valere integralmente `TESTING.md` e le regole correnti di development run e validation run.

Una development run non costituisce evidenza formale del checkpoint.

Il checkpoint stabile dovrà riferirsi a revisioni committed e, per le proprietà che richiedono validazione fisica, a validation run revision-specific secondo il normale contratto di testing.

Non si introduce un nuovo runner, un nuovo tipo di sessione o un nuovo workflow di test per il solo scopo di questo checkpoint.

## 12. Rapporto con il gate del futuro substrato

Il checkpoint stabile non attiva automaticamente il futuro modello.

La sequenza fissata è:

```text
sviluppo dell'attuale rumiai-os
        |
        v
baseline corrente stabile, anche incompleta
        |
        v
assessment esplicito della migrazione
        |
        +--> non ancora plausibile -> continuare modello corrente/esplorazione
        |
        +--> plausibile -> proposta concreta di migrazione
                              |
                              v
                    approvazione esplicita dell'utente
                              |
                              v
                    eventuale activation/migration phase
```

Quindi il checkpoint è una condizione per iniziare seriamente l'assessment di migrazione, non una condizione sufficiente per superare il substrate activation gate.

## 13. Invarianti

```text
CURRENT-STABILITY-01  lo sviluppo continua sull'attuale rumiai-os fino a una baseline stabile anche se incompleta
CURRENT-STABILITY-02  durante questa fase restano attivi bootstrap, shebang, namespace, layout e contratti correnti
CURRENT-STABILITY-03  non si introducono modifiche preparatorie al futuro modello senza requisito corrente indipendente
CURRENT-STABILITY-04  stabilità del checkpoint riguarda il perimetro realizzato, non feature completeness
CURRENT-STABILITY-05  il checkpoint richiede coerenza fra specifiche, implementazione, permanent test ed evidence applicabile
CURRENT-STABILITY-06  dopo il checkpoint si esegue un assessment separato degli impatti della migrazione
CURRENT-STABILITY-07  rename bootstrap, cambio shebang e analoghe trasformazioni sono oggetti dell'assessment, non modifiche già approvate
CURRENT-STABILITY-08  l'assessment non predetermina l'adozione del futuro modello
CURRENT-STABILITY-09  il futuro modello viene attivato soltanto tramite approvazione esplicita secondo il substrate activation gate
CURRENT-STABILITY-10  Git resta forward-only
```

## 14. Stato corrente

Questa decisione modifica soltanto la sequenza strategica di sviluppo.

Non modifica direttamente:

```text
rumiai-os
rumiai-tests
pkg-catalog
```

Non richiede da sola una physical validation, perché non cambia comportamento runtime osservabile.
