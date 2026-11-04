# Da `rumiai-os` a `m-os`: ricostruzione delle scelte progettuali

La decisione fondamentale è stata **separare il sistema tecnico indispensabile per far funzionare i package dagli strumenti che possono essere distribuiti e aggiornati come package**.

Non volevamo semplicemente dividere un repository in più repository. Volevamo interrompere le dipendenze circolari tra bootstrap, installazione dei software e strumenti di sviluppo.

## 1. La distinzione originaria: `m` e RumiAI

Il modello architetturale distingue due livelli:

- **`m`**: infrastruttura tecnica generale, che non deve dipendere dal prodotto RumiAI.
- **RumiAI**: livello applicativo superiore, che utilizza i servizi tecnici di `m`.

Da qui nasce `m-os`, repository autonomo del livello tecnico `m`. La rinomina del repository non ha cambiato i nomi pubblici `m`, `pkg` o `m_ROOT`.

Il criterio scelto per separare i componenti è stato il seguente:

**Rimane nel nucleo** ciò che serve prima che i package possano essere utilizzati, ciò che costituisce una funzione essenziale del runtime, oppure ciò che è talmente piccolo e strettamente integrato da non giustificare un ciclo di vita autonomo.

**Diventa un progetto/package indipendente** ciò che possiede funzionalità e interfacce coerenti, può essere aggiornato separatamente, ha dipendenze opzionali o pesanti, oppure può servire più prodotti senza dipendere dal repository originario.

L'indipendenza della distribuzione non modifica necessariamente l'appartenenza architetturale: per esempio, `mk` e `jsc` rimangono strumenti tecnici del livello `m`, anche se hanno repository e release autonomi.

## 2. Come abbiamo definito il nucleo minimale di `m-os`

Il criterio non era ridurre `m` al minor numero possibile di file. Era ottenere **il più piccolo sistema tecnico realmente autonomo**, in grado di inizializzarsi, gestire lo stato, installare software e avviarlo senza dipendere dai software che deve installare.

Abbiamo quindi mantenuto insieme `m` e `pkg`.

<box gap={1}>
  <box border radius="lg" padding={3} gap={2}>
    <box background="surface-secondary" radius="md" padding={3} align="center" gap={1}>
      **`m` — bootstrap POSIX**
      <text color="secondary" size="xs" textAlign="center">Ambiente, root, PATH, caricamento librerie fondamentali</text>
    </box>
    <row justify="center"><icon name="arrow-down" color="tertiary"/></row>
    <box background="surface-secondary" radius="md" padding={3} align="center" gap={1}>
      **`pkg` — package manager**
      <text size="xs" color="secondary" textAlign="center">Catalogo, dipendenze, provider, installazione, integrazione ed esecuzione</text>
    </box>
    <row justify="center"><icon name="arrow-down" color="tertiary"/></row>
    <grid columns={2} gap={2}>
      <grid-item>
        <box border radius="md" padding={3} align="center" gap={1}>
          **`mk`**
          <text size="xs" color="secondary" textAlign="center">Build e sviluppo</text>
        </box>
      </grid-item>
      <grid-item>
        <box border radius="md" padding={3} align="center" gap={1}>
          **Altri package**
          <text size="xs" color="secondary" textAlign="center">Compiler, editor, utility…</text>
        </box>
      </grid-item>
    </grid>
  </box>
  <caption>Schema concettuale delle dipendenze, non un nuovo layout di directory.</caption>
</box>

### Quali comandi abbiamo tenuto dentro

L'inventario iniziale ha identificato 15 comandi tecnici fondamentali, oltre al bootstrap `m`.

| Gruppo | Comandi | Motivazione |
|---|---|---|
| Package | `pkg` | Installare e utilizzare il resto del sistema |
| Ambiente e stato | `osarch`, `state-path`, `shell` | Inizializzazione e contesto operativo |
| Trasferimento e integrità | `http-fetch`, `digest`, `extract` | Acquisizione e verifica degli artifact |
| Diagnostica | `log` | Errori e osservabilità del runtime |
| Localizzazione e documentazione | `lang`, `lang-set`, `manual`, `pager` | Interfacce tecniche utilizzabili autonomamente |
| Sicurezza TLS | `tls-ca`, `tls-nss-sync` | Gestione della fiducia CA e integrazione NSS |
| Servizi | `srv` | Ciclo di vita dei servizi installati tramite `pkg` |

La scelta di includere `srv`, TLS e documentazione è significativa: non abbiamo definito un nucleo esclusivamente teorico, incapace di gestire normalmente i package reali.

La prima estrazione funzionante comprendeva anche **28 librerie shell, 44 manuali operativi**, risorse essenziali di localizzazione e gli strumenti per la gestione dello stato.

Il catalogo, invece, non è stato incorporato in `m-os`.

## 3. Perché `pkg-catalog` rimane separato

Questa separazione era già esistente e abbiamo deciso di conservarla.

**`pkg` è il motore, `pkg-catalog` contiene le definizioni.**

Il motore è responsabile dei processi generali: risoluzione delle versioni, dipendenze, download, verifica d'integrità, integrazione, default, provider e launcher.

Il catalogo descrive i singoli software, le versioni, le piattaforme supportate, i requisiti e i contratti delle facility.

Il vantaggio è che possiamo aggiornare la descrizione di un software senza dover modificare il runtime. E, soprattutto, il bootstrap `m` non deve interrogare GitHub, leggere il catalogo o risolvere provider semplicemente per avviarsi.

Le operazioni che richiedono il catalogo lo consultano quando servono.

Questo principio è diventato ancora più importante nella successiva progettazione dei package v2: **le definizioni devono essere prevalentemente dichiarative e la logica riutilizzabile deve risiedere nel runtime**.

## 4. Perché abbiamo separato `mk`

Questa è stata probabilmente la decisione architetturale più importante della migrazione.

Nel vecchio `rumiai-os`, `mk` era un comando tecnico di sistema, con l'implementazione JavaScript collegata al runtime generale.

Ma `mk` è un orchestratore del ciclo di sviluppo: gestisce progetti, goal, operazioni, dipendenze tra progetti, build e test. Non serve per inizializzare `m`, né per installare il primo package.

Inoltre richiede Node.js.

Se avessimo mantenuto `mk` come prerequisito di costruzione o installazione di `m`, avremmo rischiato questa dipendenza circolare:

```text id="vqy0p1"
m deve essere costruito usando mk
mk richiede Node.js
Node.js deve essere installato da pkg
pkg richiede m
```

Abbiamo scelto di eliminare il problema alla radice.

`mk` è rimasto uno strumento del livello tecnico `m`, ma è diventato **un package installabile con un ciclo di vita autonomo**, pubblicato dal repository `m-mk`.

Il contratto è netto: `mk` orchestra lo sviluppo dei progetti; `pkg` installa software e risolve dipendenze e provider. Nessuno dei due deve duplicare il lavoro dell'altro.

## 5. Come abbiamo deciso di costruire `mk`

Qui abbiamo fatto due esperimenti distinti, che è importante non confondere.

### Primo esperimento: come assemblare una distribuzione

Nel **PoC 072** abbiamo confrontato due modi di assemblare una piccola distribuzione composta da componenti indipendenti `m`, `pkg` e `lang`.

Un metodo utilizzava shell POSIX, Git e operazioni sul filesystem; l'altro utilizzava il vero motore `mk`, eseguito tramite Node.js dell'host.

Entrambi producevano, per quella fixture ridotta, un risultato equivalente. Ma il secondo metodo introduceva Node.js come prerequisito della procedura.

Il PoC dimostrava che le due strategie erano tecnicamente possibili, **non che fosse necessario utilizzare `mk` per costruire il nucleo**.

Abbiamo pertanto scelto un bootstrap autonomo POSIX, lasciando `mk` disponibile per orchestrare le build una volta che l'ambiente tecnico è operativo.

### Secondo esperimento: costruire il package `mk` stesso

Nel **PoC 073** abbiamo provato a collocare tutto il codice di `mk` nel proprio package, senza installarne le librerie dentro `m-os`.

Questa è la struttura effettivamente adottata:

```text id="ueal1j"
m-mk/
├── bin/
│   └── mk
├── lib/
│   └── mk.lib.js
├── res/
│   └── manual/
├── build.sh
└── tests/
```

Il comando `bin/mk` è un entrypoint Node.js che importa la libreria `lib/mk.lib.js` dallo stesso package. L'intero contenuto viene installato sotto la `root/` del package concreto.

La soluzione è semplice perché **il codice JavaScript di `mk` non richiede una compilazione**. La build della distribuzione consiste nella copia dei sorgenti e nella creazione di un archivio.

Nel repository corrente `m-mk`, il comando è:

```sh id="ee72ew"
sh build.sh /percorso/nuova-directory-output
```

La directory di output non deve già esistere. Il processo genera `mk-v0.1.0-all.tar.gz` con codice, entrypoint e manuali.

Successivamente si pubblica l'artifact versionato e `pkg-catalog` registra il package con la dipendenza:

```text id="8g4192"
nodejs =26
```

Dal punto di vista dell'utilizzatore, il risultato è:

```sh id="251j36"
./m pkg install mk@v0.1.0
./m mk --goals
```

Quindi **non serve Node.js per preparare il package `mk`; serve Node.js per eseguirlo**, ed è `pkg` a gestire quella dipendenza.

La versione `v0.1.0` di `m-mk` è stata realmente pubblicata e installata tramite il catalogo. Le prove con Node.js gestito, `--plan`, esecuzione delle operazioni e `--watch` hanno superato i test ospitati su Ubuntu e macOS.

Per costruire *un progetto con `mk`*, invece, il modello è diverso: il progetto descrive il proprio ciclo di sviluppo in `mk.json`; `mk` risolve i goal e coordina gli strumenti necessari senza diventare un compilatore universale.

## 6. Quali package abbiamo deciso di estrarre

Dopo il nucleo e `mk`, abbiamo confrontato i comandi del vecchio `rumiai-os` con quelli già presenti nel nuovo runtime autonomo.

L'inventario storico individuava **31 identità di comando** nel vecchio sistema. Sedici erano già nel nucleo autonomo, contando il bootstrap; `mk` era stato separato. Rimanevano 14 comandi da classificare.

Non abbiamo deciso di creare 14 repository. Abbiamo cercato **gruppi funzionali coerenti**, ciascuno con una ragione valida per avere una propria release.

| Componente o gruppo | Motivo della separazione | Decisione/stato |
|---|---|---|
| **`jsc`** | Compiler JavaScript/CSS, dipendenza Node.js, interfaccia e release autonome | Estratto e pubblicato |
| **`pkg-analyze`** | Strumento di analisi per sviluppatori, non necessario al normale funzionamento di `pkg` | Candidato da valutare |
| **Terminale**: `editor`, `read-key`, `readpass`, `readpassv`, `menu`, `vsed` | Funzioni interattive con contratti riutilizzabili, non indispensabili all'installazione dei package | Raggruppamento aperto |
| **`gitman`** | Gestione interattiva di Git; dipende da strumenti terminali e ha un ciclo d'uso proprio | Candidato, eventualmente dipendente dal gruppo terminale |
| **SSH/amministrazione**: `rssh`, `rsudo`, `rsudo-admin`, `ssh-askpass` | Ambito operativo specifico, dipendenze e requisiti di sicurezza propri | Raggruppamento da definire |
| **`testlab`** | Gestione di ambienti e scenari di sviluppo/test, non richiesta dal bootstrap | Candidato autonomo |

<text color="secondary" size="sm">Le motivazioni di raggruppamento sono la lettura architetturale dell'inventario nell'handoff; tranne `jsc`, non sono approvazioni definitive di specifici nuovi package o repository.</text>

### Perché `jsc` è già stato estratto

`jsc` era il secondo candidato più semplice da dimostrare.

Come `mk`, aveva un'implementazione JavaScript coerente, un comando pubblico identificabile e una dipendenza da Node.js che non doveva gravare sul nucleo.

Con il **PoC 074** abbiamo verificato che il suo motore CommonJS potesse vivere dentro la `root/` del package e continuare a compilare JavaScript e CSS usando il Node.js gestito da `pkg`.

Da questo esperimento è nato il repository `m-jsc`, con la release `v0.1.0`, la build POSIX e la registrazione nel catalogo.

`jsc` non è diventato una parte di `mk`: rimane un compiler utilizzabile autonomamente. `mk` può orchestrarlo come qualunque altro strumento.

### Le librerie e i componenti non ancora classificati

L'inventario segnalava anche componenti senza un comando autonomo:

`lib/sys/js/core`, `core-ext`, `ui`, `text-edit.lib.js`, `dynamic-loader.lib.js`, ulteriori librerie shell, componenti Web ed esportazione delle chat.

Per questi non abbiamo ancora deciso una corrispondenza definitiva fra libreria, package e repository.

La regola che avevamo scelto è evitare sia di lasciare tutto nel nucleo per comodità, sia di spezzare artificialmente ogni libreria in un package.

Una libreria necessaria al bootstrap può rimanere interna. Una capacità utilizzabile da più progetti, con interfaccia pubblica stabile e dipendenze proprie, è invece una buona candidata all'estrazione.

**Questo inventario è ancora uno dei lavori aperti**.

## 7. Perché manuali e localizzazioni devono accompagnare i package

Avevamo discusso anche se creare package separati per manuali, traduzioni e altre risorse.

La scelta esplicita è stata di **non separare i manuali e le localizzazioni dal software cui appartengono**.

Il motivo è la coerenza delle versioni.

Un package deve poter distribuire la documentazione esatta delle proprie interfacce, senza dipendere da una release separata che potrebbe non essere sincronizzata. Lo stesso vale per i cataloghi di localizzazione specifici del package.

Questo non impedisce di riutilizzare sorgenti comuni durante la preparazione degli artifact; significa semplicemente che ogni release deve contenere le proprie risorse.

Perciò sia `m-mk` sia `m-jsc` includono `res/manual/` nei rispettivi archivi.

## 8. Come `context` e pkg v2 completano il progetto

Una volta estratto il nucleo, è diventato evidente un problema ulteriore: **installare software autonomi non basta; occorre permettere loro di utilizzare correttamente comandi e librerie appartenenti ad altri package**.

È da qui che le discussioni successive su `context` e sullo schema v2 assumono importanza.

Nel progetto approvato per v2:

- `link/bin` rappresenta l'ingresso eseguibile uniforme, diretto oppure tramite wrapper `cmd`;
- `link/lib/sh` espone le librerie POSIX shell, ricercabili tramite `PATH` e il comando `.`;
- `link/lib/java` espone gli archivi JAR, selezionabili attraverso `CLASSPATH`;
- `pkg` crea e mantiene le proiezioni, mentre `context` seleziona quelle dei package installati;
- le librerie ordinarie non vengono trasformate in facility soltanto perché sono condivise.

Questa è la connessione con il tuo obiettivo attuale: portare le librerie del vecchio `rumiai-os` in package v2 riutilizzabili da altri package.

Resta però una distinzione progettuale non ancora risolta: selezionare esplicitamente una libreria già installata non equivale a far sì che un package consumatore possa dichiararla e ottenere automaticamente il proprio contesto completo.

Anche il modello generale di `context`, che avevamo progettato con selezioni per profilo, package, provider, stato e regole di ereditarietà, è ancora più ampio dell'implementazione oggi disponibile.

Il lavoro v2 rimane su branch separati: i test reali di coesistenza e alcune migrazioni v1→v2 sono riusciti, ma **la promozione nel ramo principale non risulta ancora completata**.

## 9. Cosa è stato completato e cosa manca

| Risultato | Stato ricostruito |
|---|---|
| Separazione concettuale `m` / RumiAI | Definita e canonica |
| Nucleo autonomo `m` con `pkg` | Implementato in `m-os` |
| Catalogo indipendente | Mantenuto in `pkg-catalog` |
| `mk` come package autonomo | Pubblicato e testato |
| `jsc` come package autonomo | Pubblicato e testato |
| Validazione completa di ogni funzione del nuovo `m` | Ancora parziale |
| Estrazione degli altri gruppi di strumenti | Da classificare e realizzare |
| Migrazione sistematica delle librerie shell | Da realizzare |
| `context` generalizzato | Progettato in parte, implementazione incompleta |
| pkg v2 | Sviluppato e parzialmente validato, non ancora promosso |
| Composizione finale del prodotto `rumiai-os` dai progetti autonomi | Ancora aperta |

È importante ricordare una tua correzione durante la verifica su Ubuntu: **due package installati e funzionanti non dimostrano che l'intero `m-os` sia corretto**.

Per questo abbiamo istituito un percorso autonomo di validazione che copre 15 aree, dalle funzioni di bootstrap fino a package, provider, dipendenze, servizi, TLS e casi di errore.

L'altra cautela fondamentale è che il vecchio `rumiai-os` è rimasto una sorgente di riferimento durante l'estrazione: la sua rimozione o modifica coordinata non deve essere considerata già avvenuta solo perché `m-os`, `m-mk` e `m-jsc` esistono.

## 10. La sintesi architetturale

Rileggendo tutto il percorso, la logica delle decisioni è questa:

**Non abbiamo cercato di ottenere un sistema composto dal massimo numero di package indipendenti. Abbiamo cercato di costruire una base tecnica autonoma, piccola ma operativamente completa, sopra la quale poter installare e comporre strumenti indipendenti.**

Questo spiega perché:

- `m` e `pkg` rimangono insieme;
- `pkg-catalog` conserva una responsabilità separata;
- `mk` e `jsc` sono stati estratti, pur continuando ad appartenere semanticamente al livello `m`;
- la build di `mk` non richiede né `mk` stesso né un Node.js preinstallato;
- i restanti strumenti devono essere separati per responsabilità coerenti, non semplicemente uno per comando;
- le librerie condivise devono poter essere distribuite dai package e selezionate mediante `context`;
- il livello superiore RumiAI può essere composto a partire da queste unità senza essere una dipendenza del nucleo.

La direzione è coerente. **Il principale lavoro architetturale rimasto non è più decidere se separare `mk`, ma completare la composizione tra package, librerie, provider e contesti mantenendo autonoma la base `m-os`.**

---

## Fonti principali della ricostruzione

Ho confrontato le chat archiviate pertinenti (`m-context`, `m-core` e `m-os`), gli handoff attivi, i PoC di estrazione, i repository `m-mk` e `m-jsc` e le specifiche correnti. L'archivio originario *m context* del 26 ottobre è stato individuato ma non era leggibile; non attribuisco a quella chat dettagli che non ho potuto verificare. Le altre conversazioni dedicate a netboot, rsudo e Keycloak sono responsabilità distinte, non decisioni sulla separazione del nucleo.

I riferimenti più utili sono:

<box gap={2}>
  <row align="center" gap={2}>
    <icon name="file-text" color="secondary"/>
    <Link url="https://github.com/massimilianonardi-ai/rumiai-dev/blob/main/handoff/rumiai-os-source-composition.md" title="Handoff della migrazione e dell'estrazione"/>
  </row>
  <row align="center" gap={2}>
    <icon name="file-text" color="secondary"/>
    <Link url="https://github.com/massimilianonardi-ai/rumiai-dev/blob/main/specifications/rumiai-os/CURRENT-MODEL.md" title="Modello architetturale corrente"/>
  </row>
  <row align="center" gap={2}>
    <icon name="file-text" color="secondary"/>
    <Link url="https://github.com/massimilianonardi-ai/rumiai-dev/blob/main/specifications/rumiai-os/MK.md" title="Contratto di mk"/>
  </row>
  <row align="center" gap={2}>
    <icon name="github" color="secondary"/>
    <Link url="https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/tree/rumiai-os-composition-comparison/pocs/072-rumiai-os-composition" title="PoC 072 — confronto POSIX e mk"/>
  </row>
  <row align="center" gap={2}>
    <icon name="github" color="secondary"/>
    <Link url="https://github.com/massimilianonardi-ai/m-mk" title="Repository m-mk e build.sh"/>
  </row>
  <row align="center" gap={2}>
    <icon name="github" color="secondary"/>
    <Link url="https://github.com/massimilianonardi-ai/m-jsc" title="Repository m-jsc"/>
  </row>
</box>

La parte che ritengo più utile da conservare è il **criterio di appartenenza al nucleo e di estrazione dei package**, perché permette di valutare coerentemente anche le librerie e gli strumenti che non abbiamo ancora migrato.