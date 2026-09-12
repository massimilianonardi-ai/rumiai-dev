# Analisi esplorativa — due livelli di contratto del substrato general purpose

Date: 2026-09-12  
Status: **EXPLORATORY / NON-NORMATIVE**

## 1. Contesto

Questa nota estende l'analisi esplorativa:

```text
analysis/rumiai-os/2026-09-12-m-substrate-and-rumiai-os-specialization.md
```

La premessa resta che l'attuale `rumiai-os`, non contenendo ancora responsabilità funzionali AI-specifiche, sia sostanzialmente candidato a diventare il futuro substrato general purpose sul quale costruire RumiAI.

L'obiettivo ulteriore qui esplorato è separare due esigenze differenti:

```text
stabilità estrema per i consumer di alto livello

contro

libertà di evoluzione per sviluppo, tooling e uso avanzato del substrato
```

Il nome possibile `m` resta soltanto un working name del futuro substrato. Il termine "SDK di m" usato nella conversazione è qui trattato esclusivamente come abbreviazione esplorativa per una possibile **superficie di sviluppo**: non introduce un nome di prodotto, package, directory, namespace o componente canonico.

## 2. Preflight e stato corrente

La riflessione è stata riesaminata contro gli HEAD remoti correnti:

```text
rumiai-dev    ba62278290cd59e0689f1e30c0d48c6db7434b62
rumiai-os     bd31613f6e2de2ef8096d730916634ee40c4b967
rumiai-tests  4d04b9d6b27f5d99887ea2b18818ab2e00c3267a
pkg-catalog   69dcdab2b8cd5dd0c0b0f9d8e0fe9651939fbcaa
```

Sono stati riesaminati in particolare:

```text
RULES.md
CONSISTENCY-GATE.md
analysis/rumiai-os/2026-09-12-m-substrate-and-rumiai-os-specialization.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
decisions/rumiai-os/2026-09-03-runtime-library-layout.md
tests/rumiai-os/command/direct-shebang-execution.test
```

La ricerca nella documentazione autorevole corrente non ha individuato un concetto già fissato denominato `SDK`, `internal API` o equivalente da riutilizzare come terminologia canonica.

## 3. Invarianti applicabili

Restano validi almeno i seguenti vincoli:

```text
- i contratti normativi correnti di rumiai-os non cambiano con questa analisi;
- RumiAI dovrebbe dipendere soltanto da una superficie minima e stabile del substrato;
- la classificazione runtime dei command correnti resta quella fissata da COMMAND-ENTRYPOINTS.md;
- le librerie interne correnti restano organizzate secondo il layout runtime-qualified già Accepted;
- nessun nuovo namespace, directory, API, command o package viene introdotto qui;
- il termine SDK non viene promosso automaticamente a concetto canonico;
- Git resta forward-only e le evidence correnti restano revision-specific.
```

## 4. Modello: due livelli di contratto

La proposta esplorativa è che il futuro substrato esponga **due livelli distinti di contratto**.

```text
                    RUMIAI
                      │
                      │ usa normalmente solo questo
                      ▼
        ┌───────────────────────────┐
        │ CONTRATTO STABILE MINIMO │
        └───────────────────────────┘
                      │
            implementato tramite
                      ▼
        ┌───────────────────────────┐
        │ SUPERFICIE DI SVILUPPO    │
        │ più ampia e più dinamica  │
        └───────────────────────────┘
                      │
                      ▼
        implementation detail privati
        senza contratto di consumo
```

I primi due livelli sono entrambi contratti, ma con garanzie differenti.

Gli implementation detail sottostanti non costituiscono invece un terzo livello di contratto: possono cambiare liberamente e non sono destinati a essere consumati direttamente.

## 5. Livello 1 — contratto stabile minimo

Questo livello costituisce la vera boundary fra substrato e RumiAI.

Dovrebbe essere:

```text
piccolo
esplicito
documentato
fortemente testato
compatibile nel tempo per quanto ragionevolmente possibile
indipendente dalla struttura interna del substrato
```

RumiAI dovrebbe poter essere sviluppato e rilasciato conoscendo idealmente soltanto questa superficie.

Le candidate surface già emerse nell'analisi principale restano:

```text
shell contract
service/daemon contract futuro
pochi command pubblici stabili
```

con esempi plausibili, ma ancora non definitivamente classificati, quali:

```text
lang
log
pkg
```

La dimensione del contratto stabile dovrebbe essere trattata come un budget: ogni nuova dipendenza permanente aggiunta da RumiAI aumenta il costo di compatibilità futura del substrato.

## 6. Proprietà desiderate del contratto stabile

Una volta che una primitive o un comportamento viene promosso nel contratto stabile, il substrato assume un costo di compatibilità intenzionale.

In linea esplorativa, una modifica dovrebbe seguire un modello simile a:

```text
cambiamento interno compatibile
  -> libero, nessun impatto sul consumer

estensione compatibile del contratto stabile
  -> possibile dopo verifica del requisito reale

cambiamento breaking del contratto stabile
  -> decisione esplicita
  -> migrazione del consumer
  -> riallineamento documentazione e test
  -> nuova validazione appropriata
```

Questo livello dovrebbe quindi privilegiare semantica osservabile e invarianti, non dettagli fisici o implementativi evitabili.

## 7. Livello 2 — superficie di sviluppo flessibile

Il secondo livello sarebbe una superficie più ampia utilizzabile per:

```text
sviluppo del substrato
sviluppo di tooling avanzato
prototipazione
integrazioni sperimentali
consumer tecnici che accettano maggiore coupling
strumenti di diagnostica o amministrazione
```

Questa superficie può esporre più primitive rispetto al contratto stabile, incluse eventualmente librerie, helper, command o informazioni operative già utili internamente.

La differenza fondamentale non è che tali primitive possano essere scorrette o non testate.

Dovrebbero comunque essere:

```text
corrette per la revisione a cui appartengono
documentabili
verificabili
testate in modo proporzionato
```

ma **non promettono la stessa stabilità inter-release** del contratto minimo.

Una modifica interna del substrato può quindi comportare una modifica di questa superficie quando ciò migliora architettura, robustezza, semplicità o manutenibilità.

## 8. Perché non chiamarla semplicemente `internals`

Esiste una distinzione semantica utile.

Se una primitive è esplicitamente documentata e proposta agli sviluppatori come qualcosa che possono utilizzare, essa possiede comunque un contratto, anche se debole e revisionabile.

Quindi conviene distinguere:

```text
superficie di sviluppo
  -> uso intenzionale consentito
  -> comportamento definito nella revisione corrente
  -> compatibilità futura non garantita allo stesso livello

implementation detail privato
  -> non destinato al consumo
  -> nessuna garanzia di forma o persistenza
```

Il termine colloquiale "internals" può descrivere l'area complessiva non stabile, ma non dovrebbe confondere una API di sviluppo intenzionalmente usabile con dettagli puramente privati.

## 9. Regola fondamentale per RumiAI

Perché il modello funzioni, il consumer principale deve rispettare una disciplina molto forte:

> **il runtime/prodotto RumiAI non deve dipendere dalla superficie di sviluppo quando esiste o deve esistere un contratto stabile appropriato.**

Altrimenti si creerebbe questa situazione:

```text
contratto stabile piccolo sulla carta

ma

RumiAI -> primitive dinamiche della superficie di sviluppo
```

che renderebbe la separazione soltanto nominale.

L'uso della superficie di sviluppo può invece essere ragionevole per:

```text
tooling di sviluppo RumiAI
test e diagnostica
PoC
strumenti non distribuiti come parte del runtime RumiAI
```

quando il coupling alla revisione corrente è esplicito e accettato.

## 10. Promotion path

Uno dei vantaggi maggiori del modello è consentire alle API di maturare prima di diventare permanenti.

Una possibile traiettoria concettuale è:

```text
implementation detail
       │
       │ emerge un uso reale ripetibile
       ▼
superficie di sviluppo
       │
       │ il contratto matura e più consumer ne dipendono
       │ la semantica si dimostra stabile
       ▼
contratto stabile minimo
```

Questo permette di evitare due estremi:

```text
A. rendere stabile troppo presto ogni helper utile
B. tenere tutto privato fino a costringere i consumer a duplicare logica
```

La promozione verso il contratto stabile deve essere intenzionale e motivata da un requisito concreto, non automatica con il passare del tempo.

## 11. Possibile demotion o rimozione

La superficie di sviluppo può evolvere più rapidamente.

Una primitive può quindi essere:

```text
rinominata
sostituita
accorpata
separata
rimossa
```

quando il design lo richiede, purché la documentazione della revisione corrente sia coerente e i consumer che accettano tale superficie comprendano il minor livello di compatibilità.

La rimozione di una primitive dal contratto stabile sarebbe invece un evento architetturale molto più costoso e richiederebbe una migrazione esplicita.

## 12. Testing differenziato

I due livelli suggeriscono anche due tipi diversi di garanzia.

### Contratto stabile

I test dovrebbero proteggere soprattutto:

```text
semantica osservabile
compatibilità del consumer RumiAI
invarianti pubblici
failure contract rilevanti
portabilità richiesta
```

La regressione è normalmente un difetto del substrato oppure un cambiamento di contratto che deve essere deliberato.

### Superficie di sviluppo

I test dovrebbero proteggere:

```text
correttezza della revisione corrente
coerenza fra primitive
assenza di regressioni accidentali non motivate
```

ma non trasformare automaticamente ogni forma osservata in una garanzia di compatibilità permanente.

Il fatto che una primitive possieda test non implica che appartenga al contratto stabile.

## 13. Documentazione differenziata

Per evitare ambiguità, ogni futura API o primitive esposta intenzionalmente dovrebbe rendere chiaro il proprio livello di garanzia.

Concettualmente dovrebbero poter essere distinti almeno:

```text
stable consumer contract

development surface

private implementation detail
```

Questa nota non stabilisce ancora:

```text
naming formale dei livelli
annotazioni nei file
layout della documentazione
manifest/API registry
versioning scheme
compatibility marker
```

Tali meccanismi devono essere introdotti soltanto se risultano necessari.

## 14. Relazione con il layout corrente

Il modello non deve essere dedotto direttamente dalle directory correnti.

Per esempio:

```text
lib/sh/*.lib.sh
```

identifica oggi librerie interne per runtime shell, ma la collocazione fisica non determina automaticamente se una funzione futura appartenga alla superficie di sviluppo o al contratto stabile.

Analogamente:

```text
bin/sys/*
```

non implica che tutti i command siano automaticamente parte della API stabile del consumer RumiAI.

Il livello di contratto è una proprietà semantica, non una conseguenza automatica del pathname.

## 15. Relazione con `pkg`

Il modello è particolarmente utile anche per `pkg`.

RumiAI potrebbe dipendere soltanto dal piccolo contratto pubblico del command/package manager, mentre lo sviluppo del package subsystem può usare una superficie molto più ricca composta da resolver, adapter, primitive di materializzazione, helper e strumenti di diagnostica.

Questo permetterebbe a `pkg` di evolvere internamente senza trasformare ogni sua primitive in API permanente per RumiAI o per altri consumer del substrato.

Le package definition concrete continuano a seguire i contratti di catalogo già fissati; questa analisi non modifica schema o ruolo di `pkg-catalog`.

## 16. Beneficio architetturale atteso

Il modello combina due proprietà che spesso entrano in conflitto:

```text
ROBUSTEZZA
  pochi contratti stabili
  piccoli boundary
  test di compatibilità forti
  minore coupling del consumer

FLESSIBILITÀ
  ampia superficie per sviluppo
  refactoring ancora possibile
  sperimentazione senza API freeze prematuro
  primitive che possono maturare prima di essere stabilizzate
```

In altre parole, il substrato può essere conservativo verso l'esterno e aggressivamente migliorabile all'interno.

## 17. Rischi principali

### 17.1 Dipendenza nascosta di RumiAI dalla superficie dinamica

È il rischio principale. Se RumiAI usa direttamente primitive non stabili, la promessa di indipendenza fra i due prodotti viene meno.

### 17.2 Stable surface creep

La comodità può spingere a promuovere troppe primitive nel contratto stabile. Il risultato sarebbe una API vasta e costosa da mantenere.

### 17.3 SDK surface creep

Anche la superficie di sviluppo può diventare un dumping ground. Una primitive dovrebbe esservi esposta perché ha reale utilità per sviluppatori o tooling, non soltanto perché esiste internamente.

### 17.4 Falsa stabilità prodotta dai test

Un test permanente di correttezza non deve essere interpretato automaticamente come promessa di compatibilità eterna della forma osservata.

### 17.5 Ecosystem expectations

Se la superficie dinamica venisse usata da consumer esterni, occorrerà comunicare chiaramente il livello di stabilità per evitare che uso diffuso venga scambiato per garanzia implicita.

## 18. Criterio di classificazione esplorativo

Per ogni primitive futura si potrebbe chiedere:

```text
1. RumiAI deve dipenderne in produzione?
   sì -> candidata al contratto stabile

2. è utile intenzionalmente a sviluppatori/tooling ma RumiAI può farne a meno?
   sì -> candidata alla superficie di sviluppo

3. serve soltanto all'implementazione corrente?
   sì -> implementation detail privato
```

Una risposta positiva alla prima domanda non basta da sola a promuovere immediatamente la primitive: occorre prima verificare che il contratto sia sufficientemente piccolo, general purpose e maturo.

## 19. Conseguenza sulla futura compatibilità

Il modello suggerisce due significati diversi di compatibilità:

```text
compatibilità del contratto stabile
  -> proprietà di prodotto intenzionalmente preservata

compatibilità della superficie di sviluppo
  -> best effort o revision-scoped secondo la futura policy
```

Questo può permettere al substrato di avere release molto robuste per i consumer pur continuando ad evolvere rapidamente nella propria architettura interna.

La policy concreta di versionamento, deprecation e compatibilità non viene fissata qui.

## 20. Direzione esplorativa risultante

La forma risultante appare coerente con il boundary precedentemente discusso:

```text
GENERAL-PURPOSE SUBSTRATE

  stable minimal contract
      shell / service / pochi command
      usato da RumiAI
      compatibilità forte

  development surface
      più ampia
      usata per sviluppo e tooling
      evoluzione più rapida

  private implementation
      nessun contratto di consumo

                │
                │ stable minimal contract only
                ▼

RUMIAI
  shell personalizzata
  servizi/daemon AI
  core/capability AI
  desktop/GUI
```

Il vantaggio centrale è rendere possibile che il substrato sia contemporaneamente:

```text
stabile per chi lo usa

ma

flessibile per chi lo sviluppa
```

## 21. Non-decisioni registrate

Restano deliberatamente aperti:

```text
nome definitivo dei due livelli
uso canonico o meno del termine SDK
forma fisica della superficie di sviluppo
quali primitive correnti appartengano a ciascun livello
se esista un versioning distinto della development surface
policy concreta di backward compatibility
policy di deprecation
meccanismo di promotion da development a stable
eventuali marker o metadata di classificazione
layout documentale delle API
strumenti di enforcement del boundary
```

Nessuno di questi punti deve essere inferito come approvato dalla presente analisi.
