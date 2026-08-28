# Decisione — Phase 1 bootstrap environment

Date: 2026-08-28
Status: **Accepted, encoding/catalog naming still open**

## Decisione

Dopo la phase 0, RumiAI inizializza un ambiente bootstrap minimale prima di caricare i18n e logger.

Directory fondamentali accettate:

```text
RumiAI_BIN_DIR  = $RumiAI_ROOT/bin
RumiAI_LIB_DIR  = $RumiAI_ROOT/lib
RumiAI_CONF_DIR = $RumiAI_ROOT/conf
RumiAI_LANG_DIR = $RumiAI_ROOT/lang
```

Non viene introdotta per ora una directory generica `share/` o `resources/`.

## PATH

`RumiAI_BIN_DIR` viene anteposta al `PATH` ereditato, mantenendo il path dell'host/caller come fallback.

Solo directory di comandi eseguibili partecipano a questo PATH. Le librerie vengono caricate mediante pathname espliciti derivati da `RumiAI_LIB_DIR`.

## Bootstrap primitive

Quando un sottosistema avanzato non può essere inizializzato senza una piccola quantità di dati che in seguito esso stesso governerà, RumiAI può usare una primitive bootstrap minimale per spezzare la dipendenza ciclica.

Prima applicazione accettata:

```text
$RumiAI_CONF_DIR/bootstrap/language
```

Il file contiene dati e non viene sourced come codice shell.

## Linguaggio RumiAI

Variabile canonica:

```text
RumiAI_LANGUAGE
```

Forma corrente lingua/territorio:

```text
language_TERRITORY
```

Esempi:

```text
en_US
it_IT
```

La componente territorio maiuscola è un'eccezione semantica documentata alla convenzione filesystem lowercase quando l'identificatore viene usato come pathname component.

## Selezione e fallback

Ordine:

```text
1. conf/bootstrap/language
2. LC_ALL
3. LC_MESSAGES
4. LANG
5. en_US
```

Il modulo i18n governa normalizzazione della locale host e catalog lookup. Lingue richieste mancanti o non supportate devono normalmente fare fallback quando il catalogo inglese è disponibile.

`en_US` è il fallback garantito.

## Questione aperta: encoding

Non è ancora deciso se il codeset faccia parte dell'identificatore linguistico RumiAI e/o del nome della directory dei cataloghi.

Restano aperte, tra le altre, le forme:

```text
lang/it_IT/
lang/it_IT.UTF-8/
```

La scelta dipende dal fatto che RumiAI supporti più encoding dei cataloghi oppure imponga un singolo encoding interno per le risorse testuali controllate da RumiAI.
