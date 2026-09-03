# Decisione — Layout e naming delle librerie runtime

Date: 2026-09-03  
Status: **Accepted**

## Contesto

RumiAI può contenere librerie interne destinate a runtime differenti. Una libreria shell non deve poter essere confusa con una libreria JavaScript o con un altro formato caricabile da un runtime diverso.

La root semantica delle librerie è già:

```text
m_LIB_DIR=$m_ROOT/lib
```

Questa decisione fissa il layout, il naming e il confine di responsabilità senza introdurre nuove environment variables di comodo.

## 1. Unica environment variable delle librerie

Per le librerie RumiAI si usa soltanto:

```text
m_LIB_DIR
```

Non vengono introdotte environment variables derivate come:

```text
m_LIB_SH_DIR
m_LIB_JS_DIR
```

né equivalenti create soltanto per abbreviare sottopercorsi.

I consumer derivano il sottalbero necessario da `m_LIB_DIR`.

## 2. Layout runtime-qualified

Ogni libreria interna appartiene al sottalbero del runtime che la può caricare:

```text
lib/<runtime>/
```

Le forme canoniche iniziali sono:

```text
lib/sh/<nome-libreria>.lib.sh
lib/js/<nome-libreria>.lib.js
```

Esempi:

```text
lib/sh/osarch.lib.sh
lib/js/example.lib.js
```

Il runtime compare intenzionalmente due volte:

1. nel sottodirectory, per separare fisicamente i namespace di caricamento;
2. nel suffisso finale del file, per rendere esplicito il formato/runtime anche quando il file viene osservato o spostato fuori dal proprio sottalbero.

La componente `.lib` identifica semanticamente il ruolo di libreria.

## 3. Regola di caricamento

Un consumer deve caricare soltanto librerie appartenenti al proprio sottalbero runtime.

Esempio shell:

```text
$m_LIB_DIR/sh/<nome-libreria>.lib.sh
```

Una shell POSIX non deve effettuare source di file trovati genericamente sotto `m_LIB_DIR` né di file appartenenti a `lib/js/` o ad altri sottalberi runtime.

## 4. Librerie shell

Le librerie sotto:

```text
lib/sh/
```

sono file sourced, non eseguibili.

Pertanto:

- non hanno bit executable;
- non contengono shebang;
- usano naming `<nome-libreria>.lib.sh`;
- devono rispettare il contratto shell/POSIX applicabile al prodotto.

Un file che deve essere direttamente eseguibile appartiene al modello dei comandi/eseguibili e non al modello delle librerie.

## 5. Comandi pubblici invariati

Questa decisione non modifica la regola dei comandi pubblici RumiAI: il nome pubblico di un eseguibile continua a descriverne la funzione e non incorpora l'estensione del linguaggio/interprete.

Quindi un comando shell resta, per esempio:

```text
osarch-update
```

non:

```text
osarch-update.sh
```

## 6. Decomposizione `osarch`

È fissata anche la separazione di responsabilità per il sottosistema OS/architecture:

```text
lib/sh/osarch.lib.sh
```

si occupa della detection e normalizzazione riutilizzabile di sistema operativo, architettura e identificatore `osarch`.

```text
bin/sys/osarch-update
```

carica `osarch.lib.sh` e mantiene la responsabilità specifica di:

- creare le directory `sys-<osarch>/` e `ext-<osarch>/` quando mancanti;
- aggiornare i symlink relativi `sys-osarch` e `ext-osarch`;
- gestire gli errori propri dell'aggiornamento del layout attivo.

La detection non deve essere duplicata dentro `osarch-update` dopo il riallineamento completo.

La libreria `osarch.lib.sh` è intenzionalmente riutilizzabile da altri contesti che necessitano dell'identità della piattaforma, incluso un futuro consumer come `pkg`, senza duplicare la detection.

## 7. Stato di implementazione

Durante questa unità di lavoro l'utente ha pubblicato:

```text
massimilianonardi-ai/rumiai-os@7134b47f3ce92391ec1a1be0826a017e919311e1
```

Questa revisione materializza già:

```text
lib/sh/osarch.lib.sh
```

e il caricamento della libreria da `bin/sys/osarch-update`.

La revisione non viene modificata in questa unità di lavoro.

Il riallineamento è ancora parziale: `osarch-update` conserva al momento la propria detection duplicata e `osarch.lib.sh` deve ancora essere adeguata integralmente alle regole della libreria shell fissate qui, incluse assenza di shebang e terminologia/namespace correnti.

Il prossimo intervento esplicitamente richiesto dall'utente dovrà quindi completare la separazione già iniziata, preservando le modifiche pubblicate dall'utente e senza reintrodurre una seconda detection dentro `osarch-update`.
