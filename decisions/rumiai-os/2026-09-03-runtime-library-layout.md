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

## 7. Stato di implementazione

La separazione e il quoting corrente del sottosistema sono implementati in:

```text
massimilianonardi-ai/rumiai-os@2ca7081edee262220953f002d41e9682d4e304c5
```

A partire da questa revisione:

- `lib/sh/osarch.lib.sh` non contiene shebang, non è executable e contiene soltanto la responsabilità di detection/normalizzazione `osarch`;
- i residui attivi `RumiAI_OSARCH_*` sono stati rimossi dalla libreria;
- `bin/sys/osarch-update` non invoca più `uname` e consuma `m_OSARCH_OS`, `m_OSARCH_ARCH` e `m_OSARCH` prodotti dalla libreria;
- l'updater preserva il preflight dei due active-link pathname prima delle modifiche;
- il codice modificato segue la disciplina corrente delle doppie virgolette shell.

La copertura permanente è riallineata in:

```text
massimilianonardi-ai/rumiai-tests@c713d5b7f27c8af20df2ca4d859497005199ba1e
```

Il gruppo `tests/rumiai-os/osarch/` verifica separatamente la libreria di detection e il comportamento dell'updater, inclusa una fixture deterministica che dimostra che `osarch-update` consuma il risultato della libreria invece di ripetere la detection dell'host.
