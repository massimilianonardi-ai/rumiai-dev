# RumiAI package manager — Local package and command layout

Data: 2026-08-30

Stato: **design draft — decisioni di layout locale fissate, dettagli successivi ancora da definire**

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
├── java@21.0.8+9@r1@linux-arm64/
├── java@21.0.8+9@r1@macos-arm64/
├── java@8u462@r1@linux-x86_64/
├── pulsar@1.130.0@r1@jvm-any/
└── tool-script@3.2@r2@posix-any/
```

La coesistenza nello stesso `pkg/` è intenzionale e permette allo stesso environment fisico, per esempio su disco rimovibile, di contenere Package Instance adatte a host differenti.

---

# 2. Decisione: `bin/` fisica con namespace riservato `@platforms`

`RUMIAI_ROOT/bin/` rimane una directory fisica.

Contiene direttamente gli entrypoint che non sono legati a una singola piattaforma nativa supportata:

```text
bin/
├── pulsar
├── tool-script
└── ...
```

I command binding platform-dependent vivono invece sotto un unico namespace riservato:

```text
bin/@platforms/<platform>-<architecture>/
```

Esempio:

```text
bin/
├── @platforms/
│   ├── linux-arm64/
│   │   ├── pulsar
│   │   └── ffmpeg
│   └── macos-arm64/
│       ├── pulsar
│       └── ffmpeg
├── pulsar
└── tool-script
```

La directory relativa a una piattaforma viene creata **on demand**, alla prima integrazione di un command binding platform-dependent per quella piattaforma.

`@platforms` è una parola riservata del layout `bin/`.

Conseguenza:

```text
RUMIAI_ROOT/bin/@platforms
```

NON può essere contemporaneamente un command binding cross-platform.

Questa è una collisione strutturale deliberatamente ridotta a un solo nome noto a priori. Il prefisso `@` rende inoltre il namespace chiaramente infrastrutturale e riduce la possibilità di collisione con un comando legittimo senza renderlo nascosto come accadrebbe con `.platforms`.

Non vengono riservati direttamente sotto `bin/` tutti i nomi delle piattaforme possibili.

---

# 3. Bootstrap PATH

Il bootstrap determina il `current-platform` dell'host corrente, inclusa l'architettura canonica.

Poi espone nel `PATH` RumiAI, in questo ordine:

```text
RUMIAI_ROOT/bin/@platforms/<current-platform>
RUMIAI_ROOT/bin
<inherited PATH>
```

La directory platform-specific HA precedenza sulla directory cross-platform.

Questa precedence è intenzionale e supporta il caso in cui un software possieda:

```text
una variante cross-platform
+
una variante ottimizzata/specializzata per una specifica piattaforma
```

Esempio:

```text
bin/pulsar
    variante JVM/cross-platform

bin/@platforms/linux-arm64/pulsar
    variante Linux ARM64 specifica
```

Su `linux-arm64`:

```text
pulsar
→ bin/@platforms/linux-arm64/pulsar
```

mentre su una piattaforma priva di specializzazione nativa può restare disponibile:

```text
bin/pulsar
```

La precedence del `PATH` non sostituisce comunque il modello esplicito di integrazione. Un binding platform-specific e uno cross-platform con lo stesso nome possono convivere soltanto quando questa relazione di specializzazione è ammessa dal profilo di integrazione; collisioni non dichiarate tra package differenti restano errori.

Il bootstrap può aggiungere `bin/@platforms/<current-platform>` al `PATH` anche quando la directory non esiste ancora: la prima integrazione nativa potrà crearla senza modificare nuovamente il `PATH`.

---

# 4. Generalizzazione futura ad altre directory

Il pattern:

```text
<directory>/@platforms/<platform>-<architecture>/
```

può essere applicato in futuro ad altre aree soltanto quando un caso reale dimostra che lo stato condiviso tra piattaforme è incompatibile.

Esempio possibile:

```text
home/
├── @platforms/
│   ├── linux-arm64/
│   └── macos-arm64/
└── <shared content se realmente condivisibile>
```

Non viene introdotto ora un albero platform-specific generale.

Principio:

> specializzare per piattaforma solo la directory o la categoria di stato che dimostra di averne bisogno.

Questo evita sia la duplicazione preventiva dell'intero albero RumiAI sia l'assunzione opposta che ogni stato sia realmente cross-platform.

`@platforms` viene preferito a `.platforms` perché resta visibile nelle normali operazioni filesystem e non introduce il comportamento speciale dei dotfile; viene preferito a `arc` perché descrive direttamente il concetto e non è ambiguo con architecture/archive. La prevenzione dei conflitti deriva dalla riserva esplicita del namespace.

---

# 5. Identità filesystem della Package Instance

Il pathname della directory package DEVE contenere una rappresentazione completa e deterministicamente parseable dell'identità minima della Package Instance.

Obiettivo:

> anche se il descrittore interno viene perso o corrotto, una scansione di `pkg/` deve poter ricostruire almeno quali Package Instance fisiche sono presenti.

Il pathname non deve essere l'unica fonte di metadata operativi, ma deve impedire la nascita di package fisicamente presenti e semanticamente invisibili (“package fantasma”).

---

# 6. Naming convention fissata

La forma è:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

Esempi:

```text
java@21.0.8+9@r1@linux-arm64
java@8u462@r1@linux-x86_64
pulsar@1.130.0@r1@jvm-any
my-tool@2.0-beta-3@r2@linux-x86_64
```

Significato:

```text
name          identità logica RumiAI del package
version-token rappresentazione canonica e reversibile della versione upstream
revision      revisione del packaging RumiAI
platform      execution platform/domain
architecture  architecture nativa oppure `any` quando non applicabile
```

`revision` è sempre esplicita; non esiste un default implicito nel pathname.

---

# 7. Separatore strutturale

La forma intuitiva:

```text
<name>@<version>!<revision>^<platform>-<architecture>
```

separa chiaramente i campi, ma `!` e `^` sono problematici come caratteri strutturali cross-platform:

- `!` possiede semantica di history expansion in shell interattive come Bash e può avere semantica particolare anche in ambienti Windows;
- `^` è il carattere di escape di `cmd.exe`;
- entrambi aumentano la necessità di quoting/escaping proprio nel nome canonico della Package Instance.

La convenzione fissata usa invece `@` come unico separatore strutturale principale:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

Il parser non deve cercare di interpretare `-` o `.` dentro nome/versione.

`@` è riservato e non può comparire letteralmente nel `name`, nel `version-token`, nella revision, nella platform o nell'architecture.

---

# 8. Grammatiche e encoding

## 8.1 Package name

Il `name` deve essere un identificatore RumiAI normalizzato con grammatica ristretta e portabile tra filesystem.

Grammatica candidata:

```text
[a-z0-9][a-z0-9._-]*
```

`@` non è ammesso nel name.

Per evitare collisioni su filesystem case-insensitive, il nome canonico è lowercase.

## 8.2 Revision

La revision è un intero positivo in base 10 ed è introdotta dal marker `r`:

```text
@r1@
@r2@
@r17@
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

## 8.4 Version token

La versione upstream è l'unico componente dell'identità minima che RumiAI non controlla sintatticamente.

Per questo il pathname NON contiene necessariamente la stringa upstream grezza: contiene un **version-token canonico, filesystem-safe e reversibile**.

Obiettivi:

- round-trip esatto alla stringa upstream;
- parsing non ambiguo del pathname;
- compatibilità con filesystem Linux, macOS e Windows;
- assenza di `@` nel token;
- una sola rappresentazione canonica per la stessa versione;
- resistenza alle collisioni su filesystem case-insensitive;
- conservazione della leggibilità per le versioni comuni.

### Forma letterale

Una versione può essere mantenuta letteralmente quando soddisfa una grammatica safe definita da RumiAI.

Candidato iniziale:

```text
[a-z0-9][a-z0-9._+-]*
```

Esempi:

```text
21.0.8+9
8u462
1.130.0
2.0-beta-3
```

sono direttamente rappresentabili.

### Forma encoded

Una versione che contiene:

- lettere maiuscole;
- `@`;
- caratteri non portabili tra filesystem;
- caratteri shell-problematici;
- oppure qualunque sequenza riservata dalla codifica;

viene convertita in una forma encoded canonica e reversibile.

Candidato:

```text
b32-<base32-lowercase-utf8-senza-padding>
```

La forma Base32 lowercase usa soltanto caratteri filesystem-safe e non dipende dal case per distinguere due token.

Il prefisso `b32-` è riservato: una versione upstream letterale che inizi con `b32-` deve essere encoded per evitare ambiguità.

La scelta Base32 resta candidata finché non viene confrontata con casi reali di versioni upstream; il requisito normativo è la reversibilità e la canonicalità, non l'algoritmo specifico.

---

# 9. Parsing deterministico

Con la grammatica fissata:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

il parsing procede sui separatori `@`, tutti riservati ai campi strutturali.

Dopo lo split si ottengono esattamente quattro componenti:

```text
1. name
2. version-token
3. r<revision>
4. <platform>-<architecture>
```

`platform` e `architecture` appartengono a vocabolari controllati, quindi il loro split finale è deterministico rispetto ai token canonici ammessi.

Il `version-token` viene poi decodificato se usa la forma encoded.

Il parsing non dipende dal descriptor interno.

---

# 10. Path identity e descriptor identity

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

# 11. Recovery quando il descriptor manca

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

# 12. Principio anti-ghost

Invariante:

> Ogni directory immediatamente contenuta in `pkg/` deve essere classificabile dal package manager come Package Instance valida, recuperabile, inconsistente oppure sconosciuta. Nessun contenuto sotto `pkg/` può essere semplicemente ignorato perché manca un indice o un descrittore.

Questo rende `pkg/` stesso una fonte di verità fisica ricostruibile.

Un eventuale indice/cache centrale può accelerare le operazioni, ma deve essere sempre rigenerabile tramite scansione del filesystem.

---

# 13. Relazione con `bin/`

Gli entrypoint in:

```text
bin/
bin/@platforms/<platform>-<architecture>/
```

sono integrazione derivata e non fanno parte dell'identità fisica della Package Instance.

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

# 14. Caso cross-platform con specializzazione nativa

Una Package Instance cross-platform può produrre un command binding direttamente sotto `bin/`.

Una Package Instance nativa/specializzata può produrre lo stesso command name sotto:

```text
bin/@platforms/<platform>-<architecture>/
```

Esempio:

```text
bin/pulsar
    launcher JVM/cross-platform

bin/@platforms/linux-arm64/pulsar
    variante nativa Linux ARM64
```

Sul current-platform `linux-arm64`, il secondo precede il primo tramite il PATH stabilito dal bootstrap.

Questa relazione non viene dedotta soltanto dalla coincidenza del nome: deve essere coerente con lo stato di integrazione risolto.

---

# 15. Caso cross-platform con dependency native

Una Package Instance cross-platform può produrre un command binding direttamente sotto `bin/`, anche se durante l'esecuzione richiede una dependency nativa della piattaforma corrente.

Esempio:

```text
pkg/pulsar@1.130.0@r1@jvm-any/

bin/pulsar
```

`bin/pulsar` non deve necessariamente essere un symlink diretto al JAR. Può materializzare una Launch Specification capace di costruire l'Execution Environment e selezionare, sulla piattaforma corrente, una Package Instance che soddisfi `java-runtime`.

Quindi la presenza del comando cross-platform e la disponibilità di tutte le sue dependency native sull'host corrente sono concetti distinti.

Se la dependency non è disponibile per il current-platform, l'esecuzione deve fallire in modo esplicito come dependency unavailable; non deve cercare una Java casuale dell'host.

---

# 16. Invarianti fissate/candidate

```text
LL-01 tutte le Package Instance locali vivono nello stesso `pkg/`

LL-02 la piattaforma appartiene all'identità della Package Instance, non alla directory parent `pkg`

LL-03 `bin/` è fisica e contiene i command binding cross-platform

LL-04 `bin/@platforms/<platform>-<architecture>/` contiene i command binding platform-dependent ed è creata on demand

LL-05 `@platforms` è namespace riservato sotto `bin/`

LL-06 bootstrap espone prima `bin/@platforms/<current-platform>` e poi `bin`

LL-07 una specializzazione platform-specific può prevalere sulla variante cross-platform dello stesso command name quando il profilo di integrazione lo prevede

LL-08 collisioni non dichiarate tra command binding restano errori e non vengono risolte casualmente dal PATH order

LL-09 il pathname package contiene l'identità minima in forma deterministicamente parseable

LL-10 il `version-token` è canonico, reversibile e filesystem-safe

LL-11 il descriptor ripete intenzionalmente l'identità minima e deve essere coerente col pathname

LL-12 descriptor mancante non rende invisibile la Package Instance

LL-13 ogni child di `pkg/` deve essere classificato durante una ricostruzione inventario

LL-14 eventuali indici di package sono cache rigenerabili, non fonte fisica esclusiva di verità

LL-15 `bin/` è una view ricostruibile e non la fonte di verità sull'installazione

LL-16 lo stesso pattern `@platforms/<platform>-<architecture>` può essere esteso ad altre directory solo quando un requisito reale lo richiede
```

---

# 17. Questioni aperte successive

- conferma dell'encoding Base32 oppure scelta di un encoding canonico alternativo per le versioni non literal-safe;
- lista canonica `platform` / `architecture`;
- nome e formato del descriptor interno;
- policy di repair per Package Instance `RECOVERABLE`;
- modello esatto dei command conflict / override oltre alla specializzazione native-over-cross-platform;
- come persistere Desired/Resolved Integration Profile;
- forma concreta della Launch Specification;
- condizioni nelle quali altre aree (`home`, cache, state) diventano platform-specialized.
