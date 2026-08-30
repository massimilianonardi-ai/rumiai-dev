# RumiAI package manager — Local package and command layout

Data: 2026-08-30

Stato: **design draft — proposta successiva a Package Admission v0 e Integration Profile / Execution Environment**

Questo documento riguarda esclusivamente il lato locale del confine già fissato:

```text
payload eseguibile già disponibile
        ↓
Package Instance locale
        ↓
integrazione / utilizzo / rimozione
```

Discovery remota, `rumiai-store`, download e build restano fuori scope.

---

# 1. Decisione: un solo `pkg/`

Tutte le Package Instance locali convivono sotto una sola directory fisica:

```text
RUMIAI_ROOT/pkg/
```

Non esistono directory `pkg` separate per piattaforma.

La piattaforma appartiene all'identità della Package Instance stessa.

Esempio:

```text
pkg/
├── java@21.0.8+9~r1~linux-arm64/
├── java@21.0.8+9~r1~macos-arm64/
├── java@8u462~r1~linux-x86_64/
├── pulsar@1.130.0~r1~jvm-any/
└── tool-script@3.2~r2~posix-any/
```

La coesistenza nello stesso `pkg/` è intenzionale e permette allo stesso environment fisico, per esempio su disco rimovibile, di contenere Package Instance adatte a host differenti.

---

# 2. Decisione: `bin/` fisica con namespace platform-specific

`RUMIAI_ROOT/bin/` rimane una directory fisica.

Contiene direttamente gli entrypoint che non sono legati a una singola piattaforma nativa supportata:

```text
bin/
├── pulsar
├── tool-script
└── ...
```

Quando viene integrato almeno un comando platform-dependent per una piattaforma, viene creata la relativa sottodirectory:

```text
bin/
├── linux-arm64/
│   ├── java
│   └── ffmpeg
├── macos-arm64/
│   ├── java
│   └── ffmpeg
├── pulsar
└── tool-script
```

Le directory platform-specific vengono create **on demand**, non durante il bootstrap soltanto per rappresentare piattaforme teoricamente supportate.

---

# 3. Bootstrap PATH

Il bootstrap determina il `current-platform` dell'host corrente.

Poi espone almeno:

```text
RUMIAI_ROOT/bin/<current-platform>
RUMIAI_ROOT/bin
```

nel `PATH` RumiAI.

Ordine candidato:

```text
RUMIAI_ROOT/bin/<current-platform>
RUMIAI_ROOT/bin
<inherited PATH>
```

Motivazione: se in futuro viene ammessa esplicitamente una specializzazione nativa dello stesso command name, quella della piattaforma corrente può prevalere sulla variante cross-platform.

Tuttavia la precedence del `PATH` NON deve essere usata come normale meccanismo di risoluzione dei conflitti. Due binding che producono lo stesso command name nello stesso scope devono essere considerati conflittuali salvo decisione/override esplicito del modello di integrazione.

La precedence precisa resta candidata finché il modello di binding non viene promosso a specifica.

---

# 4. Generalizzazione futura ad altre directory

Il pattern di `bin/` può essere applicato in futuro ad altre aree soltanto quando un caso reale dimostra che lo stato condiviso tra piattaforme è incompatibile.

Esempio possibile:

```text
home/
├── linux-arm64/
├── macos-arm64/
└── <shared content se realmente condivisibile>
```

Non viene introdotto ora un albero platform-specific generale.

Principio:

> specializzare per piattaforma solo la directory o la categoria di stato che dimostra di averne bisogno.

Questo evita sia la duplicazione preventiva dell'intero albero RumiAI sia l'assunzione opposta che ogni stato sia realmente cross-platform.

---

# 5. Identità filesystem della Package Instance

Il pathname della directory package DEVE contenere una rappresentazione completa e deterministicamente parseable dell'identità minima della Package Instance.

Obiettivo:

> anche se il descrittore interno viene perso o corrotto, una scansione di `pkg/` deve poter ricostruire almeno quali Package Instance fisiche sono presenti.

Il pathname non deve essere l'unica fonte di metadata operativi, ma deve impedire la nascita di package fisicamente presenti e semanticamente invisibili (“package fantasma”).

---

# 6. Naming convention candidata

La forma candidata è:

```text
<name>@<version>~r<revision>~<platform>-<architecture>
```

Esempi:

```text
java@21.0.8+9~r1~linux-arm64
java@8u462~r1~linux-x86_64
pulsar@1.130.0~r1~jvm-any
my-tool@2.0-beta-3~r2~linux-x86_64
```

Significato:

```text
name          identità logica RumiAI del package
version       versione/release del software upstream
revision      revisione del packaging RumiAI
platform      execution platform/domain
architecture  architecture nativa oppure `any` quando non applicabile
```

`revision` è sempre esplicita; non esiste un default implicito nel pathname.

---

# 7. Perché non `name-version.revision-platform-architecture`

La forma storicamente intuitiva:

```text
name-version.revision-platform-architecture
```

non è deterministicamente parseable senza ulteriori vincoli, perché sia `name` sia `version` possono contenere `-` e le versioni upstream non possiedono una grammatica universale.

Esempio ambiguo:

```text
my-great-tool-2.0-beta-3.1-linux-x86_64
```

Non è possibile stabilire dal pathname soltanto dove termina il nome e dove inizia la versione.

La forma proposta usa invece separatori strutturali riservati:

```text
@    separa name da version
~r   introduce revision
~    introduce execution target
```

---

# 8. Grammatiche e encoding

## 8.1 Package name

Il `name` deve essere un identificatore RumiAI normalizzato con grammatica ristretta e portabile tra filesystem.

Grammatica candidata:

```text
[a-z0-9][a-z0-9._-]*
```

`@` e `~` non sono ammessi nel name.

La policy su case folding viene fissata separatamente; per evitare collisioni su filesystem case-insensitive il candidato v0 è lowercase canonico.

## 8.2 Revision

La revision è un intero positivo in base 10:

```text
r1
r2
r17
```

## 8.3 Platform e architecture

`platform` e `architecture` usano token canonici controllati dal progetto, per esempio:

```text
linux-arm64
linux-x86_64
macos-arm64
jvm-any
posix-any
```

L'elenco concreto viene specificato separatamente.

## 8.4 Version

La versione upstream NON viene reinterpretata semanticamente dal filesystem layout.

Deve però essere trasformata in un **filesystem-safe reversible token**.

I caratteri strutturali o non portabili devono essere escaped con una codifica canonica reversibile.

La codifica precisa non viene ancora fissata; deve soddisfare almeno:

- round-trip esatto alla stringa upstream;
- compatibilità con filesystem Linux, macOS e Windows;
- nessuna ambiguità con `@` e `~` strutturali;
- rappresentazione ASCII stabile;
- una sola rappresentazione canonica per la stessa stringa di versione.

La forma leggibile viene conservata quando i caratteri sono già ammessi.

---

# 9. Path identity e descriptor identity

La Package Instance mantiene normalmente anche un descrittore interno autorevole per metadata più ricchi:

```text
name
version
revision
platform
architecture
content digest
Package Interface
Execution Requirements
state requirements
altri metadata
```

Il pathname e il descrittore contengono quindi **ridondanza intenzionale** per i campi di identità minima.

Regola:

```text
pathname identity == descriptor identity
```

quando il descrittore è presente e valido.

Una divergenza è un errore di integrità, non una precedence decision.

---

# 10. Recovery quando il descriptor manca

Il pathname non può realisticamente ricostruire dependency graph, Package Interface, entrypoint, state schema e tutti gli altri metadata.

Può e deve ricostruire invece l'identità minima e la presenza fisica.

Una scansione di `pkg/` deve classificare ogni child directory.

Stati candidati:

```text
HEALTHY
    pathname parseable + descriptor presente + identity coerente

RECOVERABLE
    pathname parseable + descriptor mancante/corrotto

IDENTITY_MISMATCH
    pathname parseable + descriptor presente ma identity differente

UNKNOWN
    pathname non conforme alla naming convention
```

Una Package Instance `RECOVERABLE`:

- è visibile nell'inventario;
- non può diventare invisibile o “fantasma”;
- può essere rimossa in modo controllato;
- può essere sottoposta a repair/recovery;
- NON deve essere usata automaticamente per soddisfare nuove dipendenze o produrre nuovi binding finché i metadata operativi non sono stati ripristinati/verificati.

Una directory `UNKNOWN` sotto `pkg/` deve essere segnalata esplicitamente; non deve essere ignorata silenziosamente.

---

# 11. Principio anti-ghost

Invariante candidata:

> Ogni directory immediatamente contenuta in `pkg/` deve essere classificabile dal package manager come Package Instance valida, recuperabile, inconsistente oppure sconosciuta. Nessun contenuto sotto `pkg/` può essere semplicemente ignorato perché manca un indice o un descrittore.

Questo rende `pkg/` stesso una fonte di verità fisica ricostruibile.

Un eventuale indice/cache centrale può accelerare le operazioni, ma deve essere sempre rigenerabile tramite scansione del filesystem.

---

# 12. Relazione con `bin/`

Gli entrypoint in `bin/` e `bin/<platform>/` sono integrazione derivata e non fanno parte dell'identità fisica della Package Instance.

Quindi:

```text
pkg/
    fonte fisica delle Package Instance locali

bin/
    Materialized View dei command binding
```

La perdita o corruzione di `bin/` deve essere riparabile ricostruendo la view a partire dallo stato di integrazione e dalle Package Instance valide.

Un link rimasto in `bin/` verso una Package Instance assente è un errore di integrazione rilevabile, non prova che il package sia installato.

---

# 13. Caso cross-platform con dependency native

Una Package Instance cross-platform può produrre un command binding direttamente sotto `bin/`, anche se durante l'esecuzione richiede una dependency nativa della piattaforma corrente.

Esempio:

```text
pkg/pulsar@1.130.0~r1~jvm-any/

bin/pulsar
```

`bin/pulsar` non deve necessariamente essere un symlink diretto al JAR. Può materializzare una Launch Specification capace di costruire l'Execution Environment e selezionare, sulla piattaforma corrente, una Package Instance che soddisfi `java-runtime`.

Quindi la presenza del comando cross-platform e la disponibilità di tutte le sue dependency native sull'host corrente sono concetti distinti.

Se la dependency non è disponibile per il current-platform, l'esecuzione deve fallire in modo esplicito come dependency unavailable; non deve cercare una Java casuale dell'host.

---

# 14. Invarianti candidate

```text
LL-01 tutte le Package Instance locali vivono nello stesso `pkg/`

LL-02 la piattaforma appartiene all'identità della Package Instance, non alla directory parent `pkg`

LL-03 `bin/` è fisica e contiene i command binding cross-platform

LL-04 `bin/<platform>/` viene creata on demand per command binding platform-dependent

LL-05 bootstrap espone sia `bin/<current-platform>` sia `bin`

LL-06 collisioni command non vengono risolte casualmente dal PATH order

LL-07 il pathname package contiene l'identità minima in forma deterministicamente parseable

LL-08 il descriptor ripete intenzionalmente l'identità minima e deve essere coerente col pathname

LL-09 descriptor mancante non rende invisibile la Package Instance

LL-10 ogni child di `pkg/` deve essere classificato durante una ricostruzione inventario

LL-11 eventuali indici di package sono cache rigenerabili, non fonte fisica esclusiva di verità

LL-12 `bin/` è una view ricostruibile e non la fonte di verità sull'installazione

LL-13 lo stesso pattern di specializzazione per piattaforma può essere esteso ad altre directory solo quando un requisito reale lo richiede
```

---

# 15. Questioni aperte successive

- encoding canonico esatto della stringa `version` nel pathname;
- lista canonica `platform` / `architecture`;
- nome e formato del descriptor interno;
- policy di repair per Package Instance `RECOVERABLE`;
- ordine definitivo di `bin/<platform>` e `bin` nel PATH;
- modello esatto dei command conflict / override;
- come persistere Desired/Resolved Integration Profile;
- forma concreta della Launch Specification;
- condizioni nelle quali altre aree (`home`, cache, state) diventano platform-specialized.
