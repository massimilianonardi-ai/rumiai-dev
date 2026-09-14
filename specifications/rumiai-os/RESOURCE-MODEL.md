# Specifica — Resource model

Date: 2026-09-14  
Status: **Current**

## 1. Scopo

Questa specifica definisce il modello corrente delle risorse distribuite di RumiAI OS dopo il freeze `2.0.0`.

Il modello distingue:

- risorse globali appartenenti al layer tecnico `sys`;
- risorse globali appartenenti al layer branded `ai`;
- risorse appartenenti a package gestiti;
- state mutabile.

La specifica non introduce un resolver universale delle risorse, URI di risorsa, registry, daemon o resource manager.

---

## 2. Definizione di risorsa

Una resource payload è contenuto distribuito con un owner, necessario o utilizzabile a runtime, che non costituisce state applicativo mutabile e non è un entrypoint.

Esempi possibili includono cataloghi di lingua, immagini, icone, template, schema o altri asset statici quando un caso concreto li richiede.

La classificazione come resource è semantica. Non autorizza automaticamente nuove classi di risorsa o nuove API.

I selector co-locati alle risorse, come `lang/current`, sono metadata di selezione mutabili. La loro mutabilità non riclassifica i payload selezionati come state.

---

## 3. Root globale `res`

La semantic root globale delle risorse di sistema è:

```text
$m_ROOT/res/
```

Il bootstrap espone:

```text
m_RES_DIR=$m_ROOT/res
```

Le risorse globali sono ownership-qualified:

```text
res/
├── sys/
└── ai/
```

`sys` identifica risorse del substrate tecnico `m`.

`ai` identifica risorse del layer branded RumiAI.

L'esistenza di `res/ai` non crea una dipendenza semantica di `m` da RumiAI. Il substrate può conoscere la forma generale del resource model senza conoscere o richiedere contenuti branded specifici.

Nuovi owner globali non sono definiti da questa specifica.

---

## 4. Classi di risorsa

Una classe di risorsa è collocata sotto il relativo owner:

```text
res/<owner>/<resource-class>/
```

Questa specifica fissa inizialmente una sola classe concreta:

```text
lang
```

Non vengono introdotti namespace generici ulteriori per anticipare classi future.

La presenza di `res` non autorizza automaticamente directory quali `icons`, `themes`, `templates`, `models` o equivalenti: ciascuna classe viene materializzata quando esiste un requisito concreto.

---

## 5. Language resources globali

Il layout corrente è:

```text
res/
├── sys/
│   └── lang/
│       ├── en_US/
│       ├── it_IT/
│       └── current -> <locale>
└── ai/
    └── lang/
        ├── en_US/
        ├── it_IT/
        └── current -> <locale>
```

Ogni directory `res/<owner>/lang/<locale>/` dichiara che quell'owner supporta il locale nella propria classe `lang`.

Un catalogo di lingua supportato può essere vuoto. Non è necessario inventare messaggi soltanto per materializzare una lingua supportata.

`current` deve essere un symbolic link relativo il cui target è il nome leaf del locale selezionato nello stesso `lang/`.

Tutti i language tree globali materializzati sotto:

```text
res/*/lang/
```

partecipano alla selezione globale e devono avere lo stesso locale selezionato.

La selezione iniziale distribuita è:

```text
en_US
```

---

## 6. Interfaccia tecnica `lang`

L'interfaccia shell esistente `lang` resta una facility tecnica di `m`.

Il bootstrap mantiene:

```text
m_LANG_DIR=$m_RES_DIR/sys/lang
m_LANG_CURRENT_DIR=$m_LANG_DIR/current
m_LANGUAGE_FALLBACK=en_US
m_LANG_FALLBACK_DIR=$m_LANG_DIR/$m_LANGUAGE_FALLBACK
```

`m_LANG_DIR` viene mantenuta come interfaccia semantica già esistente per la facility tecnica `lang`; il suo nuovo valore non introduce una regola generale di environment alias per ogni sottodirectory di `res`.

La funzione tecnica:

```text
lang <domain> <message-id>
```

risolve esclusivamente il catalogo `sys`.

Non cerca in `res/ai/lang`, non effettua merge tra owner e non introduce fallback cross-owner.

Un futuro consumer branded potrà leggere risorse `ai` soltanto quando esisterà un requisito concreto e un contratto appropriato. Questa specifica non anticipa tale API.

---

## 7. Selezione globale con `lang-set`

Il comando pubblico resta:

```text
bin/sys/lang-set
```

ed è implementato dal layer tecnico `m`.

### 7.1 Query

Con zero argomenti:

```text
lang-set
```

restituisce esclusivamente il nome del locale selezionato dal selector tecnico:

```text
res/sys/lang/current
```

seguito da newline.

Esempio:

```text
it_IT
```

La query non elenca i cataloghi e non restituisce conteggi.

Se il selector `sys` non è un symbolic link relativo valido verso un locale disponibile nel proprio tree, la query fallisce. Non presenta il fallback come se fosse la selezione corrente.

### 7.2 Selezione

Con un argomento:

```text
lang-set <locale>
```

il comando:

1. individua i language tree globali materializzati nella forma `res/*/lang/`;
2. verifica prima di ogni mutazione che `<locale>` esista in tutti i tree partecipanti;
3. verifica che ogni `current` partecipante sia un selector valido;
4. prepara i nuovi selector relativi;
5. aggiorna tutti i selector partecipanti;
6. aggiorna il selector `sys` per ultimo, come commit logico della selezione osservabile da `lang-set` senza argomenti;
7. in caso di errore ordinario durante l'aggiornamento tenta il ripristino dei selector precedenti.

Se la lingua richiesta manca anche in un solo owner globale partecipante, l'operazione fallisce senza modificare alcun selector.

`lang-set` non deve contenere una dipendenza semantica esplicita dal nome `ai`: opera sulla forma generale dei language tree globali sotto `m_RES_DIR`.

L'aggiornamento di più symlink non è una transazione filesystem crash-atomica. Il contratto richiede coerenza dopo successo e rollback per gli errori ordinari gestiti; non introduce journal, generation directory, lock framework o transaction manager.

---

## 8. Package resources

Le risorse di un package appartengono al package e restano nel relativo tree/versione gestita.

Non vengono copiate o proiettate automaticamente sotto:

```text
$m_RES_DIR
```

Questo vale anche per i cataloghi di lingua del package.

`lang-set` non visita, modifica o sincronizza selector o configurazioni interne dei package.

L'integrazione di un package può configurare il software upstream affinché segua la lingua globale di sistema oppure usi un override proprio, se il software lo supporta. La traduzione tra il locale RumiAI e l'eventuale schema locale dell'upstream appartiene alla specifica integrazione del package.

Questa regola non introduce una sintassi generica `lang=` né una nuova primitive di package configuration.

---

## 9. Separazione da state

`res/` non è una state area.

Le state area e il resolver `state-path` conservano le semantiche correnti.

I payload sotto `res/` sono distribuiti come parte del prodotto; i selector `current` sono metadata di selezione co-locati alle risorse per il contratto specifico che li definisce.

Il resource model non riapre il modello di state e non introduce un secondo resolver di state.

---

## 10. Nessun resolver universale

Non vengono introdotti:

```text
resource-path
res-path
resource://
registry di risorse
resource daemon
resource manager
```

Un consumer usa la semantic root o il contratto specifico già pertinente alla propria responsabilità.

Una nuova primitive di risoluzione richiederà un requisito concreto che non sia già coperto dalle interfacce esistenti.

---

## 11. Invarianti

```text
RES-01  la semantic root globale delle risorse è $m_ROOT/res ed è esposta come m_RES_DIR
RES-02  le risorse globali sono ownership-qualified; gli owner correnti sono sys e ai
RES-03  sys appartiene al substrate tecnico m; ai appartiene al layer branded RumiAI
RES-04  resource payload e state mutabile restano concetti distinti
RES-05  un selector current co-locato non trasforma il resource tree in state
RES-06  la prima classe di risorsa globale fissata è lang
RES-07  m_LANG_DIR resta l'interfaccia tecnica lang e vale $m_RES_DIR/sys/lang
RES-08  la facility tecnica lang risolve soltanto risorse sys e non dipende da ai
RES-09  res/*/lang/current seleziona lo stesso locale in tutti i language tree globali materializzati
RES-10  lang-set senza argomenti restituisce soltanto il locale selezionato da res/sys/lang/current
RES-11  lang-set valida tutti i language tree globali prima di mutare e aggiorna sys per ultimo
RES-12  lang-set non visita né modifica le risorse o configurazioni dei package
RES-13  le risorse dei package restano package-local e sono private al package salvo contratti futuri espliciti
RES-14  nessun resolver universale, URI, registry, daemon o resource manager è introdotto
RES-15  la selezione multi-owner è semanticamente unica ma non è promessa come transazione filesystem crash-atomica
RES-16  en_US è la selezione globale distribuita iniziale e resta il fallback tecnico
```
