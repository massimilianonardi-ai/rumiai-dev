# Decisione — Workspace `src` e domini `lang` generici

Date: 2026-09-02  
Status: **Accepted**

## Contesto

Questa decisione completa il riallineamento del layout corrente di `rumiai-os` dopo la baseline bootstrap/runtime fissata il 2026-09-02.

## 1. Workspace locale di sviluppo

La directory locale di sviluppo sotto la root di `rumiai-os` è:

```text
src/
```

La precedente directory:

```text
.dev/
```

è superseded.

Il semantic root esportato è:

```text
m_SRC_DIR=$m_ROOT/src
```

`src/` ospita esclusivamente materiale di sviluppo locale, inclusi i checkout indipendenti di `rumiai-tests` e `rumiai-dev-PoCs` quando presenti. Il suo contenuto operativo resta fuori dal prodotto runtime, ignorato da Git e non deve diventare una dipendenza necessaria all'esecuzione di RumiAI OS.

Layout locale canonico:

```text
src/
├── rumiai-tests/
└── rumiai-dev-PoCs/
```

I repository contenuti restano repository Git indipendenti e non submodule.

## 2. Comandi RumiAI platform-independent

I comandi RumiAI platform-independent appartengono a:

```text
bin/sys/
```

Di conseguenza il comando pubblico `log` è collocato in:

```text
bin/sys/log
```

Il runtime root resta esposto tramite il symlink relativo già fissato:

```text
bin/sys/rumiai-os -> ../../rumiai-os
```

## 3. Domini `lang`

I cataloghi correnti non devono organizzare i messaggi in base al componente che casualmente li emette quando il significato è riutilizzabile da più componenti.

I domini iniziali generici sono:

```text
filesystem
execution
security
```

I message-id descrivono la condizione semantica e restano statici, riutilizzabili e privi di valori dinamici. I dettagli dinamici continuano a essere trasportati come structured fields dal logger/event layer.

### `filesystem`

Message-id iniziali:

```text
path-invalid
path-non-existent
path-is-readonly
path-is-not-readable
path-is-not-writable
path-is-not-file
path-is-not-directory
execution-bit-not-set
file-is-not-executable
```

### `execution`

Message-id iniziali:

```text
command-not-found
command-failed
execution-failed
invalid-arguments
```

### `security`

Message-id iniziali:

```text
permission-denied
operation-not-permitted
command-requires-root-privileges
```

## 4. Cataloghi superseded

Il dominio catalogo storico:

```text
bootstrap
```

con messaggi specifici della vecchia configurazione lingua/encoding e del precedente bootstrap non fa parte del catalogo prodotto corrente.

Questa supersession riguarda i cataloghi correnti, non riscrive l'evidenza storica delle revisioni precedenti.

## 5. Lingue e encoding

Restano invariati:

```text
lang/<language_TERRITORY>/<domain>/<message-id>
UTF-8
fallback en_US
lang/current come symlink relativo quando una lingua è selezionata
```

Non viene introdotta interpolazione nei cataloghi.

## 6. Propagazione

La nuova directory `src/` supersede i riferimenti correnti a `.dev/` nelle regole, nella documentazione di sviluppo, nello script `setup-dev.sh` e nei test permanenti che verificano il layout di setup.

L'evidenza fisica storica che registrava `.dev/` resta valida per le revisioni allora esercitate e non deve essere riscritta come se avesse validato `src/`.
