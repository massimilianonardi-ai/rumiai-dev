# RumiAI package manager — Integration Context draft

Data: 2026-08-29

Stato: **design draft — proposta successiva ai concetti Package Admission v0**

Prerequisito:

```text
drafts/rumiai-os/package-manager-v0/README.md
```

Questo documento parte da una proprietà già presente nel package manager storico di `m`:

```text
package presente in pkg
    !=
package integrato/attivo
```

L'antenato possedeva già `integrate` / `deintegrate` e supportava PATH, environment, command alias, app, librerie e profilo. Il nuovo modello cerca di mantenere quella capacità eliminando la dipendenza da mutazioni globali difficili da ricostruire.

---

# 1. Problema

Dopo l'admission abbiamo già:

```text
Package Instance immutabili
Execution Dependency risolte in Package Instance concrete
```

Resta da decidere come renderle utilizzabili.

Esempio storico Java:

```text
Java corrente/default disponibile come `java`
Java 8 disponibile contemporaneamente
comando esplicito `java8`
package legacy che deve usare Java 8
shell in cui `java` deve significare Java 8
```

La directory `pkg/` da sola non deve decidere quale versione sia attiva.

---

# 2. Integration Context

Un **Integration Context** è uno stato esplicito e risolto che descrive come un insieme di Package Instance viene reso utilizzabile in uno specifico contesto RumiAI.

Non è una Package Instance.

Non modifica il contenuto delle Package Instance.

Non è necessariamente globale.

Non è necessariamente permanente.

Concettualmente:

```text
Package Instance disponibili
        ↓
selezione / dependency resolution / override espliciti
        ↓
Integration Context risolto
        ↓
materializzazione della view di esecuzione
```

Un context contiene solo riferimenti a Package Instance concrete; i version range devono essere già risolti.

---

# 3. Binding

Il risultato fondamentale dell'integrazione è un insieme di **binding**.

Un binding associa un nome/ruolo visibile nel context a una risorsa proveniente da una Package Instance.

Categorie iniziali candidate:

```text
command binding
environment binding
application binding
library/search-path binding
```

Il v0 successivo dovrebbe partire da `command` ed `environment`; le altre categorie verranno introdotte soltanto quando necessarie.

Esempio:

```text
command `java`
    → java-runtime 21.0.8 / macos-arm64 / bin/java

JAVA_HOME
    → directory della stessa Package Instance
```

Il meccanismo fisico usato per applicare il binding — symlink, launcher, PATH, environment file o altro — è una decisione di materializzazione separata dal modello logico.

---

# 4. Package Integration Contribution

Una Package Instance può dichiarare quali elementi **può contribuire** a un Integration Context.

Esempio concettuale Java:

```text
exports command:
    java  -> bin/java
    javac -> bin/javac

exports environment contribution:
    JAVA_HOME -> <package-root>
```

Questa dichiarazione non significa che i binding siano automaticamente attivi in ogni context.

Distinguiamo quindi:

```text
EXPORT
    ciò che una Package Instance rende disponibile all'integrazione

BINDING
    ciò che uno specifico Integration Context decide di rendere visibile
```

Questo consente a più versioni della stessa Package Instance di esportare lo stesso nome senza conflitto finché non vengono selezionate nello stesso namespace del context.

---

# 5. Context default, named e package-specific

Non servono tre meccanismi differenti. Sono tutte istanze dello stesso concetto `Integration Context` con scope/lifecycle differenti.

## 5.1 Default context

È il context normalmente utilizzato da shell e command execution RumiAI quando non viene richiesto altro.

Esempio:

```text
default:
    java -> java-runtime 21
```

## 5.2 Named context

Un context può essere persistente e selezionabile esplicitamente.

Esempio:

```text
legacy-java8:
    java -> java-runtime 8
```

Una shell aperta nel context `legacy-java8` vede quindi:

```text
java -version
→ Java 8
```

senza modificare il default context.

## 5.3 Package execution context

Quando un package deve essere eseguito con dipendenze specifiche, RumiAI può costruire un context dedicato derivato dalle Execution Dependency già risolte.

Esempio:

```text
legacy-app
└── execution dependency: java-runtime 8

execution context legacy-app:
    java -> java-runtime 8
    JAVA_HOME -> java-runtime 8
```

Il default context può contemporaneamente continuare a usare Java 21.

---

# 6. Context derivation / override

Un Integration Context può opzionalmente derivare da un altro context.

La relazione serve a riutilizzare un ambiente generale sostituendo solo ciò che deve cambiare.

Esempio:

```text
default
    java -> Java 21
    python -> Python 3.13

legacy-java8 extends default
    override java -> Java 8
```

Il context risultante vede:

```text
java   -> Java 8
python -> Python 3.13
```

L'override deve essere esplicito. L'ordine casuale di installazione non deve determinare quale binding vince.

La necessità di inheritance multipla/composizione di più parent non viene assunta nel v0.

---

# 7. Alias espliciti

Il caso storico `java8` può essere rappresentato come binding addizionale senza cambiare il default `java`.

Esempio nel default context:

```text
java  -> Java 21 / bin/java
java8 -> Java 8  / bin/java
```

Quindi:

```text
java -version
→ 21

java8 -version
→ 8
```

Questo non richiede che Java 8 sia il runtime di default e non impedisce a un package-specific context di associare direttamente `java` a Java 8.

---

# 8. Conflict model

Se due Package Instance contribuiscono allo stesso namespace e il context tenta di attivarle entrambe senza regola esplicita, l'integrazione deve fallire come conflitto.

Esempio:

```text
foo-A exports command `tool`
foo-B exports command `tool`

context requests both as `tool`
→ CONFLICT
```

Non sono soluzioni accettabili:

```text
vince l'ultimo installato
vince quello trovato prima nel filesystem
vince quello processato per ultimo
```

Le soluzioni ammissibili sono esplicite, per esempio:

```text
selezione di una delle due
alias differente
override dichiarato in un derived context
```

Il conflitto riguarda il **binding nel context**, non necessariamente la coesistenza delle Package Instance nello store.

---

# 9. Integration context e dependency graph

Il dependency graph risolve **quali Package Instance servono**.

L'Integration Context decide **come quelle istanze diventano visibili durante l'esecuzione**.

Sono problemi correlati ma distinti.

Esempio:

```text
package A
└── requires java-runtime >=8 <9
        ↓ resolver
java-runtime 8.0.x / macos-arm64
        ↓ integration
execution context A:
    command java -> <java8>/bin/java
    JAVA_HOME    -> <java8>
```

Questa separazione permette allo stesso sistema di avere contemporaneamente:

```text
default context → Java 21
package A       → Java 8
package B       → Java 17
java8 alias      → Java 8
```

---

# 10. `integrate`

Nel nuovo modello, `integrate` non dovrebbe significare "esegui una serie di side effect irreversibili".

Concettualmente dovrebbe significare:

```text
modifica la definizione/desiderata selezione di un Integration Context
        ↓
resolve bindings
        ↓
validate conflicts
        ↓
materialize/rebuild la execution view del context
```

La Package Instance resta invariata.

Il context risultante deve essere conoscibile e riproducibile.

---

# 11. `deintegrate`

`deintegrate` non dovrebbe tentare di ricostruire al contrario ogni modifica fatta da `integrate` leggendo di nuovo i metadata del package.

Dovrebbe invece significare:

```text
rimuovi una selezione/binding dal desired state del context
        ↓
ricalcola context
        ↓
rebuild/materialize la nuova view
```

Questa differenza è importante rispetto all'antenato, dove la deintegration modificava file globali e cercava di sottrarre PATH/env/link precedentemente applicati.

Il nuovo modello rende `deintegrate` una trasformazione di stato dichiarato, non una procedura di undo euristica.

---

# 12. Materialized View

Un Integration Context è logico.

Per essere usato deve poter produrre una **Materialized View**.

Possibili elementi della view:

```text
bin namespace
environment
application namespace
library/search namespace
```

La forma fisica non è ancora decisa.

Per esempio, un command binding potrebbe essere materializzato mediante:

```text
symlink
launcher minimale
resolver command
```

Il modello non deve dipendere da una di queste implementazioni.

Una view dovrebbe poter essere rigenerata completamente dal context, rendendo superfluo affidarsi a mutazioni incrementali non registrate.

---

# 13. Context lifecycle

Un Integration Context può essere:

```text
persistent
    default o named context conservato dal sistema

ephemeral
    creato per una singola esecuzione/process tree
```

Questa distinzione riguarda il lifecycle, non il modello dei binding.

Un package execution context potrebbe quindi essere ephemeral senza lasciare stato globale dopo l'esecuzione.

---

# 14. Relazione con mutable application state

Integration Context e stato applicativo non sono la stessa cosa.

Il context può indicare dove si trovano configurazione/home/data di una specifica execution profile, ma tali dati non devono diventare parte della Package Instance né del binding stesso.

La relazione precisa fra:

```text
Package Instance
Integration Context
State/Profile
```

va progettata separatamente dopo aver fissato il modello base dell'integrazione.

---

# 15. Invarianti candidate

```text
IC-01 Package Instance nello store != package attivo

IC-02 Integration Context contiene solo riferimenti a Package Instance concrete

IC-03 version range non esistono nella Materialized View: sono già risolti

IC-04 package exports != context bindings

IC-05 stesso package/versioni diverse possono coesistere nello store

IC-06 conflitti di namespace sono errori salvo decisione esplicita

IC-07 install order non determina precedence

IC-08 context può essere persistent o ephemeral

IC-09 package-specific dependencies possono produrre context differenti dal default

IC-10 integrate modifica desired context state, non la Package Instance

IC-11 deintegrate ricostruisce la view dal nuovo desired state, non tenta undo euristici

IC-12 la Materialized View deve poter essere rigenerata dal context
```

---

# 16. Esempio completo Java

Store:

```text
pkg/
    java-runtime 8
    java-runtime 17
    java-runtime 21
    legacy-app
    modern-app
```

Default context:

```text
java  -> Java 21
java8 -> Java 8
```

Named context:

```text
legacy-shell extends default
    java -> Java 8
```

Package execution contexts:

```text
legacy-app
    java -> Java 8

modern-app
    java -> Java 17
```

Risultato:

```text
normal shell:       java → 21
normal shell:       java8 → 8
legacy-shell:       java → 8
legacy-app process: java → 8
modern-app process: java → 17
```

Tutte le Java restano Package Instance distinte e immutabili nello store.

---

# 17. Questioni ancora aperte

Questo draft non decide ancora:

- layout filesystem dei context;
- formato dei metadata `exports`;
- formato dei binding;
- come si materializza `bin`;
- come si applicano environment binding senza `eval`;
- precedence fra context parent/child oltre al singolo override;
- se il default context debba essere unico o esistano più root/user context;
- integrazione di shared libraries;
- applicazioni GUI;
- servizi;
- relazione precisa fra context e state/profile;
- atomicità del rebuild della Materialized View;
- persistenza/receipt del context;
- garbage collection delle Package Instance non più referenziate.

Il prossimo punto da discutere è se il modello `Integration Context → Binding → Materialized View` rappresenta correttamente tutti i casi storici che vogliamo preservare prima di fissare layout o metadata.
