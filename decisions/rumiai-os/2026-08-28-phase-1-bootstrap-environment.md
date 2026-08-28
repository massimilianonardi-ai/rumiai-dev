# Decisione — Phase 1 bootstrap environment

Date: 2026-08-28
Status: **Accepted**

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

Primitive accettate:

```text
$RumiAI_CONF_DIR/bootstrap/language
$RumiAI_CONF_DIR/bootstrap/text-encoding
```

Entrambi i file contengono dati e non vengono sourced come codice shell.

`language` fornisce la preferenza esplicita per la lingua di interazione.

`text-encoding` fornisce la preferenza esplicita per la codifica testuale del boundary di interazione.

## Linguaggio di interazione

Variabile canonica:

```text
RumiAI_LANGUAGE
```

Forma lingua/territorio:

```text
language_TERRITORY
```

Esempi:

```text
en_US
it_IT
```

La componente territorio maiuscola è un'eccezione semantica documentata alla convenzione filesystem lowercase quando l'identificatore viene usato come pathname component.

Il codeset NON fa parte di `RumiAI_LANGUAGE`.

## Selezione e fallback della lingua

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

## Codifica testuale di interazione

Variabile canonica:

```text
RumiAI_TEXT_ENCODING
```

La preferenza bootstrap esplicita viene letta da:

```text
$RumiAI_CONF_DIR/bootstrap/text-encoding
```

Valore inizialmente implementato e fallback garantito:

```text
UTF-8
```

La variabile è configurabile perché appartiene al boundary di interazione con l'utente e future implementazioni potranno aggiungere altri encoding.

Questo non modifica la rappresentazione interna di RumiAI.

## Invariante interno

Il sistema RumiAI usa internamente UTF-8 per il testo controllato da RumiAI.

Il control plane interno usa inglese + UTF-8 come rappresentazione canonica.

Payload utente e dati esterni possono contenere qualunque lingua; quando vengono rappresentati come testo interno sono normalizzati a UTF-8.

## Cataloghi

I cataloghi linguistici sono SEMPRE UTF-8.

Layout canonico:

```text
lang/en_US/
lang/it_IT/
```

Non vengono usati layout quali:

```text
lang/it_IT.UTF-8/
lang/it_IT/UTF-8/
```

Lo stesso catalogo non deve essere duplicato per encoding diversi.

## Transcoding al boundary

La codifica configurata riguarda il boundary di interazione:

```text
external encoding
    ↓ transcoding
internal UTF-8
    ↓ processing / catalog rendering
internal UTF-8
    ↓ transcoding
external encoding
```

Con `RumiAI_TEXT_ENCODING=UTF-8` non serve alcuna transcodifica.

Encoding aggiuntivi potranno essere implementati in futuro mediante adapter/transcoder senza modificare cataloghi o rappresentazione interna.

Quando un encoding esterno richiesto non è disponibile, il sistema dovrebbe evitare errori bloccanti se il boundary può continuare in UTF-8; il degrado può essere diagnosticato dopo l'attivazione del logger.
