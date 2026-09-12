# Analisi esplorativa — `m` come substrato general purpose e RumiAI OS come specializzazione

Date: 2026-09-12  
Status: **EXPLORATORY / NON-NORMATIVE**

## 1. Scopo e limite di autorità

Questa nota esplora una possibile separazione architetturale futura:

```text
m
  substrato OS general purpose
  meccanismi e contratti riusabili

        ↑ dipendenza unidirezionale

RumiAI OS
  specializzazione costruita sopra m
  composizione, policy e capacità specifiche RumiAI/AI
```

`m` è qui il nome proposto dall'utente per un eventuale nuovo ruolo futuro del substrato e richiama intenzionalmente la filosofia del progetto storico omonimo. Questa nota **non** reintroduce automaticamente `massimilianonardi/m` come fonte normativa e non stabilisce che il repository storico/currente debba diventare il repository del nuovo substrato.

Secondo `RULES.md`, `massimilianonardi/m` resta allo stato corrente materiale storico/di riferimento e non fonte normativa per RumiAI finché una decisione esplicita non stabilisce diversamente.

Questa analisi non:

- rinomina `rumiai-os`;
- modifica la classificazione dei repository;
- sposta codice;
- modifica contratti pubblici;
- introduce un nuovo namespace;
- introduce `bin/sys/ai`;
- modifica il package manager;
- stabilisce quali componenti debbano essere package obbligatori, opzionali o esterni;
- autorizza una migrazione fisica;
- modifica test o physical evidence.

Ogni eventuale adozione richiederebbe una decisione separata e il riallineamento esplicito di regole, specifiche, architettura, test e implementation ownership interessati.

## 2. Preflight e fonti correnti considerate

La riflessione è stata condotta contro gli HEAD remoti correnti osservati durante il preflight:

```text
rumiai-dev    658a97635ff3e277cf702544baa3d46561c6d0af
rumiai-os     bd31613f6e2de2ef8096d730916634ee40c4b967
rumiai-tests  4d04b9d6b27f5d99887ea2b18818ab2e00c3267a
m             6f1678dfd2fc7fc203a1beff637130f442c36e9c
```

Sono state considerate in particolare le fonti autorevoli correnti relative a:

```text
RULES.md
CONSISTENCY-GATE.md
architecture/rumiai-os/PHASE-0.md
architecture/rumiai-os/PHASE-1.md
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
handoff/2026-08-29-rumiai-os-bootstrap-permanent-tests-handoff.md
decisions/rumiai-os/2026-09-03-runtime-library-layout.md
decisions/rumiai-os/2026-09-05-package-manager-current-and-run-model.md
decisions/rumiai-os/2026-09-06-package-command-entry-link-and-launcher.md
decisions/rumiai-os/2026-09-08-top-level-semantic-roots-and-lang-placement.md
decisions/rumiai-os/2026-09-08-package-stream-repository-independence.md
decisions/rumiai-os/2026-09-12-package-launch-explicit-command-line.md
decisions/rumiai-os/2026-09-12-package-selection-and-electron-cross-platform-validation.md
```

Il repository `m` è stato considerato esclusivamente come materiale di contesto e lineage, coerentemente con il suo ruolo corrente non normativo.

## 3. Invarianti correnti che questa riflessione non può reinterpretare

La separazione ipotizzata deve partire dagli invarianti correnti, non aggirarli.

Fra quelli materialmente rilevanti:

1. RumiAI OS sviluppa contro POSIX e mantiene relocatability, deterministic resolution e fail-fast come proprietà del runtime.
2. Il namespace `m_*` è attualmente il namespace canonico delle environment variables RumiAI-owned; non stabilisce da solo un namespace generale per componenti, comandi, funzioni o repository.
3. I bootstrap-integrated command correnti dipendono dal runtime `rumiai-os` e usano `#!/usr/bin/env rumiai-os` secondo il contratto attuale.
4. La classificazione di un command dipende dal suo contratto runtime, non dalla sola directory fisica o ownership.
5. Il package manager corrente è già pensato come meccanismo di composizione dell'ambiente software, non come semplice archive installer.
6. Le package definitions, i catalog stream, il repository model, `cmd/`, `link/`, `launcher`, environment layering e gli altri contratti package già fissati non possono essere sostituiti implicitamente da una seconda architettura di estensioni.
7. I package reali possono essere selezionati anche perché utili concretamente a RumiAI, senza che questo crei nuove categorie o primitive nel package manager.
8. La Git history resta forward-only e le physical evidence restano valide soltanto per le revisioni realmente esercitate.

Di conseguenza, una futura separazione `m` / RumiAI OS sarebbe un cambiamento del confine di prodotto e ownership, non una semplice riorganizzazione cosmetica di directory.

## 4. Ipotesi concettuale

L'ipotesi sembra concettualmente ragionevole se il confine viene definito in termini di **meccanismo contro policy/specializzazione**, non semplicemente in termini di "non-AI contro AI".

Una formulazione possibile è:

```text
m
  fornisce meccanismi generali per costruire e comporre un ambiente OS relocatable
  non conosce RumiAI
  non conosce modelli AI, orchestrazione AI o policy di prodotto RumiAI
  espone contratti pubblici stabili consumabili da livelli superiori

RumiAI OS
  consuma i contratti pubblici di m
  sceglie e compone package e capability necessari al prodotto RumiAI
  aggiunge policy, default e semantiche specifiche RumiAI/AI
  non richiede che m conosca il consumer che lo usa
```

Questa direzione avrebbe un vantaggio reale soltanto se la dipendenza restasse unidirezionale:

```text
RumiAI OS -> m
m -/-> RumiAI OS
```

Se `m` dovesse conoscere package, nomi, cataloghi, command o assunzioni proprie di RumiAI, la separazione diventerebbe soprattutto fisica e perderebbe gran parte del valore architetturale atteso.

## 5. Perché la separazione può essere utile

Il beneficio principale non sarebbe il riuso nominale del codice, ma la possibilità di sviluppare il substrato come sistema autonomo con proprietà verificabili indipendentemente dal prodotto AI.

Potenziali vantaggi:

- debug e hardening del livello basso senza dipendere dall'evoluzione AI;
- test più netti dei contratti di bootstrap, portability, path, shell, logging, package composition e primitive di sistema;
- riduzione dell'accoppiamento fra infrastruttura OS e semantica RumiAI;
- possibilità di usare lo stesso substrato per altri sistemi di livello superiore senza trascinare dipendenze AI;
- maggiore chiarezza su ciò che costituisce API/contratto pubblico del substrato e ciò che resta implementation detail;
- evoluzione indipendente del substrato, purché la compatibilità verso i consumer sia gestita esplicitamente;
- RumiAI OS più vicino a una composizione/specializzazione del substrato invece che a un contenitore indistinto di meccanismi generici e capacità AI.

La separazione sarebbe però utile solo se riducesse realmente le responsabilità miste. Due repository con API indefinite, duplicazione o continui cambi coordinati produrrebbero il problema opposto.

## 6. Criterio di appartenenza: non basta essere "generico"

Un possibile test per ogni componente è:

> Il componente conserva un contratto completo e sensato se RumiAI e l'AI non esistono affatto?

Se sì, è un candidato per il substrato.

Un secondo test è:

> Un altro sistema di livello superiore potrebbe consumarlo senza conoscere nomi, package, policy, default o semantiche di RumiAI?

Se no, il confine probabilmente perde isolamento.

Un terzo test distingue meccanismo e policy:

```text
meccanismo
  come risolvere una root
  come costruire PATH
  come rilevare os/arch
  come scaricare/verificare/estrarre un artifact
  come risolvere/materializzare/integrate/launch un package

policy/specializzazione
  quali package installare
  quali package sono necessari a RumiAI
  quali capacità AI compongono il prodotto
  quali default e configurazioni RumiAI usare
  quali command hanno semantica specificamente RumiAI
```

La riusabilità da sola non dovrebbe essere sufficiente a spostare una responsabilità verso il basso: il substrato deve possedere un contratto autonomo, non diventare un deposito di tutto ciò che potrebbe essere riusato.

## 7. Candidati naturali al substrato, da verificare uno per uno

Senza fissarne ancora l'ownership futura, il codice corrente mostra già responsabilità largamente indipendenti dall'AI, per esempio:

```text
root discovery e canonicalizzazione
semantic roots e path model
POSIX/runtime portability
shell/environment bootstrap
logging e lingua come infrastruttura generale
OS/architecture detection
primitive come digest, extract e HTTP fetch
utility terminali realmente generiche
package resolution/materialization/integration/launch come meccanismo
```

Al contrario, resterebbero naturalmente al livello superiore le responsabilità che esprimono intenzione di prodotto RumiAI, per esempio:

```text
selezione del software necessario a RumiAI
AI runtimes e modelli scelti dal prodotto
orchestrazione e componenti cognitivi
command con semantica RumiAI/AI
configurazioni e default di prodotto
package definitions o repository mantenuti specificamente come composizione RumiAI
```

Questa lista è deliberatamente indicativa. Prima di qualunque migrazione ogni file/responsabilità dovrebbe essere classificato sulla base del contratto reale e delle dipendenze, non del nome o della directory corrente.

## 8. Il package manager come possibile boundary di composizione

Il package manager corrente è particolarmente importante perché l'handoff già lo descrive come **software environment composition substrate**.

Se l'ipotesi `m` venisse adottata, appare concettualmente forte separare:

```text
m
  package mechanism
  resolution
  provider/repository adapters generici
  artifact acquisition/verification
  extraction/materialization
  integration
  dependency/facility mechanism
  launcher/runtime preparation generica
  receipts/state/transaction semantics quando previste dal contratto

RumiAI OS
  package set scelto dal prodotto
  package definitions RumiAI-specifiche
  AI software scelto/supportato
  policy/default di composizione
  eventuali command specificamente RumiAI
```

Questa è soltanto un'ipotesi di ownership: il package manager corrente è normativamente un sottosistema di RumiAI OS e il suo trasferimento a un eventuale `m` richiederebbe una decisione esplicita e una migrazione dei contratti.

Un aspetto importante è che **package non significa necessariamente componente esterno o opzionale**.

Una capacità RumiAI potrebbe essere:

- implementata come package first-party;
- installata per default;
- obbligatoria per una determinata composizione RumiAI;
- distribuita insieme al prodotto;

senza per questo appartenere al substrato `m`.

Questa distinzione permetterebbe di usare il package model come unico meccanismo di composizione anche per capacità first-party, evitando una seconda architettura parallela riservata alle "estensioni AI".

## 9. Valutazione esplorativa di `bin/sys/ai`

L'ipotesi di introdurre, per esempio:

```text
bin/sys/ai/
```

non appare al momento il candidato più forte come confine fra substrato e RumiAI.

Motivi:

1. trasformerebbe una separazione di ownership/layering in una gerarchia fisica di command;
2. la specifica corrente stabilisce che il contratto runtime del command non deriva dalla directory fisica;
3. il package model possiede già `cmd/` e `launcher` per esporre command provenienti da package senza introdurre una seconda palette gerarchica;
4. una directory `ai/` rischierebbe di diventare un contenitore semantico troppo ampio e di confondere "system utility", "AI capability" e "package command";
5. il problema principale è definire chi possiede il meccanismo e quale contratto consuma il livello superiore, non dove annidare fisicamente il command.

Questo non dimostra che nessun command AI possa mai essere system-level. Significa soltanto che `bin/sys/ai` non sembra necessario come **meccanismo generale di separazione**.

## 10. Modelli fisici possibili

### 10.1 Repository indipendente per il substrato + composizione RumiAI

Possibile forma futura:

```text
repository m
  sorgente e test del substrato
  release/versione identificabile
  contratti pubblici del substrato

repository rumiai-os
  dipendenza esplicita da una versione/revisione compatibile di m
  composizione RumiAI
  package/default/policy specifici
  minimo glue realmente product-specific

build/release
  assembla un ambiente RumiAI a partire da m + specializzazione RumiAI
```

È il modello che massimizzerebbe l'indipendenza desiderata, ma richiede prima confini e compatibility contract sufficientemente chiari.

### 10.2 Separazione logica iniziale nello stesso repository

Prima di dividere fisicamente i repository si potrebbe rendere esplicito il boundary nel design e nelle dipendenze, verificando che il livello generico non richiami il livello RumiAI-specifico.

Vantaggio:

- minore costo di coordinamento mentre il boundary è ancora in esplorazione.

Svantaggio:

- non realizza pienamente l'indipendenza di lifecycle e release desiderata.

Può essere utile come fase di prova del confine, non necessariamente come assetto finale.

### 10.3 Vendoring, subtree o submodule

Sono possibili strumenti tecnici per collegare sorgenti separati, ma non risolvono il problema architetturale.

Possono anzi mantenere forte accoppiamento fra repository e rendere meno chiaro quale release/contratto sia realmente consumato. Sarebbero quindi strumenti da valutare soltanto dopo aver definito il modello di dipendenza, non la base su cui definirlo.

### 10.4 Copia del codice generico dentro RumiAI OS

È il modello meno coerente con l'obiettivo dichiarato perché produrrebbe due fonti di verità e renderebbe difficile sviluppare, correggere e validare il substrato indipendentemente.

## 11. Nodo aperto fondamentale: identità del runtime/bootstrap

La separazione non può essere completa finché i command generici dipendono semanticamente da un runtime chiamato `rumiai-os`.

Il contratto corrente è, per i bootstrap-integrated command:

```text
#!/usr/bin/env rumiai-os
```

ed è parte della specifica attiva.

Se in futuro esistesse un substrato `m` realmente autonomo, bisognerebbe decidere esplicitamente almeno:

- quale componente possiede il bootstrap generale;
- quale sia l'identità dell'interprete/runtime generico;
- come RumiAI OS attivi o specializzi tale runtime;
- quali environment variables appartengano al contratto del substrato e quali al consumer;
- se e come preservare compatibilità con i command correnti;
- come evitare che il substrato dipenda nominalmente o semanticamente da RumiAI.

Questa nota **non propone un nuovo shebang o un nuovo executable name**. Farlo ora introdurrebbe una primitive pubblica prima di avere deciso il confine.

Anche il fatto che le environment variables correnti usino il namespace `m_*` non risolve automaticamente questa domanda: `RULES.md` specifica che tale convenzione riguarda le environment variables RumiAI-owned e non definisce da sola un namespace generale di prodotto.

## 12. Compatibilità e versionamento fra livelli

L'indipendenza di sviluppo richiede un contratto di compatibilità osservabile.

In termini concettuali:

```text
m cambia internamente
  -> nessun impatto sul consumer finché il contratto pubblico resta compatibile

m cambia un contratto pubblico
  -> RumiAI OS deve dichiarare/validare la compatibilità con la nuova revisione

RumiAI OS evolve capacità AI
  -> m non deve cambiare salvo che emerga un nuovo requisito veramente general purpose
```

Una futura realizzazione dovrebbe quindi rendere identificabile la revisione/release di `m` contro cui una revisione RumiAI OS è stata testata. Questa nota non definisce ancora formato, manifest, range o schema di versionamento.

## 13. Rischi della separazione

La separazione ha anche costi reali.

### 13.1 Generalizzazione prematura

Estrarre troppo presto un'API può cristallizzare contratti ancora in evoluzione e rendere ogni refactor più costoso.

### 13.2 Due-platform problem

Se quasi ogni modifica richiede commit coordinati in `m` e `rumiai-os`, il boundary sarebbe troppo permeabile oppure troppo fine.

### 13.3 Duplicazione di primitive

Un nuovo substrato non deve creare una seconda implementazione di package, path, launcher, logging o altre responsabilità già coperte. La migrazione dovrebbe trasferire ownership, non clonare meccanismi.

### 13.4 Leakage di policy RumiAI

Se il livello basso deve conoscere nomi AI, default RumiAI, package RumiAI o casi speciali di prodotto, l'astrazione perde generalità.

### 13.5 Overhead di release e compatibility

Repository indipendenti richiedono identificazione delle versioni compatibili, test del boundary e disciplina di rilascio aggiuntiva.

### 13.6 Migrazione documentale e di evidence

Le decisioni e physical evidence correnti sono revision-specific e descrivono RumiAI OS. Non possono essere retroattivamente reinterpretate come validation di un nuovo substrato estratto.

## 14. Approccio esplorativo prudente

Prima di una separazione fisica, la sequenza più prudente sembra essere:

```text
E0  inventario delle responsabilità correnti di rumiai-os

E1  classificazione di ogni responsabilità:
    general-purpose mechanism
    RumiAI policy/specialization
    boundary/uncertain

E2  mappa delle dipendenze reali fra i due insiemi
    con ricerca dei leakage dal generico verso RumiAI

E3  definizione dei candidate public contracts del substrato
    senza ancora rinominare executable, namespace o repository

E4  verifica che i candidate contracts siano testabili autonomamente
    e utili senza alcuna conoscenza RumiAI

E5  confronto dei modelli fisici di composizione/versionamento

E6  solo se il boundary regge, decisione esplicita di adozione
    e piano di migrazione forward-only
```

Questo ordine evita di usare la separazione fisica come mezzo per scoprire il boundary: prima si dimostra che il boundary esiste, poi lo si materializza.

## 15. Direzione che appare più promettente in questa fase

Senza trasformarla in decisione, la combinazione che appare più coerente con i contratti correnti è:

```text
m
  substrato autonomo e general purpose
  meccanismi OS/runtime/package riusabili
  nessuna conoscenza di RumiAI o AI

RumiAI OS
  specializzazione/composizione sopra m
  AI e RumiAI soprattutto attraverso package e configurazione/policy
  system glue specifico ridotto al minimo

package model
  unico meccanismo generale di composizione
  capace di ospitare sia software esterno sia componenti first-party
  senza introdurre una seconda gerarchia "AI extensions"
```

In questa lettura `bin/sys/ai` non sarebbe il centro della soluzione. La domanda più importante diventerebbe invece:

> qual è il più piccolo contratto pubblico di `m` sufficiente perché RumiAI OS possa essere costruito sopra di esso senza che `m` sappia nulla di RumiAI?

Questa domanda può guidare la prossima fase esplorativa senza ancora impegnare il progetto in una nuova topologia fisica.

## 16. Non-decisioni registrate

Questa analisi lascia deliberatamente aperti:

```text
repository concreto che ospiterebbe il futuro m
nome definitivo del substrato
nome/identità del bootstrap generico
layout fisico finale fra m e rumiai-os
modalità di pin/versionamento fra i repository
quali command restano system-level
quali componenti RumiAI diventano package
quali package sono obbligatori, default o opzionali
ownership futura del package manager
ownership dei package definitions/cataloghi
formato di una eventuale distribution/profile definition
strategia di build/release assemblata
piano di migrazione del codice esistente
```

Nessuno di questi punti deve essere inferito come già approvato dalla presente nota.
