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

La separazione di responsabilità del sottosistema OS/architecture è:

```text
lib/sh/osarch.lib.sh
```

che esegue detection e normalizzazione riutilizzabile di sistema operativo, architettura e identificatore `osarch`, esponendo:

```text
m_OSARCH_OS
m_OSARCH_ARCH
m_OSARCH
```

come environment variables readonly dopo il caricamento.

I valori host riconosciuti vengono normalizzati; i valori non riconosciuti restano disponibili come dati rilevati e non vengono rifiutati dalla libreria.

```text
bin/sys/osarch-update
```

carica `osarch.lib.sh` e mantiene la responsabilità specifica di:

- verificare che il valore rilevato appartenga al vocabolario supportato dall'updater prima di usarlo come pathname RumiAI;
- creare le directory `sys-<osarch>/` e `ext-<osarch>/` quando mancanti;
- aggiornare i symlink relativi `sys-osarch` e `ext-osarch`;
- gestire gli errori propri dell'aggiornamento del layout attivo.

La detection non deve essere duplicata dentro `osarch-update`.

La libreria `osarch.lib.sh` è intenzionalmente riutilizzabile da altri contesti che necessitano dell'identità della piattaforma, incluso un futuro consumer come `pkg`, senza duplicare la detection.

Gli errori specifici correnti del sottosistema usano il dominio catalogo:

```text
system
```

con i message-id:

```text
osarch-detection-failure
osarch-update-failure
```

presenti in tutti i cataloghi lingua correnti.

## 7. Quoting applicabile

Il codice `sh` del sottosistema segue la regola generale di quoting difensivo definita in `RULES.md` con le eccezioni esplicitamente fissate:

- i pattern/match dei rami `case` non sono soggetti al quoting difensivo;
- gli argomenti delle invocazioni `fatal` e `log` non sono soggetti alla regola stilistica del quoting difensivo;
- un'espansione variabile resta comunque quotata quando ciò è necessario per preservarla come singolo argomento e non modificarne il valore tramite word splitting o pathname expansion.

## 8. Stato di implementazione

La separazione corrente, la policy del vocabolario dell'updater e i messaggi di catalogo sono implementati in:

```text
massimilianonardi-ai/rumiai-os@9b5ae94c76b13877d65d8f0dfacf6c7b1d1f7dfa
```

A partire da questa revisione:

- `lib/sh/osarch.lib.sh` non contiene shebang e non è executable;
- il codice attivo della libreria è responsabile della detection/normalizzazione `osarch` e lascia intatti i valori non riconosciuti;
- `bin/sys/osarch-update` non invoca `uname` e consuma `m_OSARCH_OS`, `m_OSARCH_ARCH` e `m_OSARCH` prodotti dalla libreria;
- l'updater valida `linux|macos|windows` e `arm64|x86_64` prima di costruire pathname RumiAI;
- l'updater preserva il preflight dei due active-link pathname prima delle modifiche;
- `system/osarch-detection-failure` e `system/osarch-update-failure` esistono sia in `en_US` sia in `it_IT`.

La copertura permanente è riallineata in:

```text
massimilianonardi-ai/rumiai-tests@326dc93086af2f5c25716d1d92c08a86317afa7f
```

Il gruppo `tests/rumiai-os/osarch/` verifica separatamente la libreria di detection e il comportamento dell'updater. `update.test` include fixture deterministiche che verificano sia che `osarch-update` consumi il risultato della libreria senza ripetere la detection dell'host, sia che OS e architetture fuori vocabolario vengano rifiutati prima di creare directory o modificare i symlink attivi.
