# Decisione — Text encoding interno e transcoding al boundary

Date: 2026-08-28  
Status: **Accepted**  
Updated: 2026-08-31

## Decisione

RumiAI separa in modo esplicito:

```text
lingua di interazione
encoding di interazione
rappresentazione testuale interna
```

Le tre dimensioni non devono essere fuse in un unico identificatore locale/codeset.

## Lingua di interazione

Variabile canonica:

```text
RumiAI_LANGUAGE
```

Forma:

```text
language_TERRITORY
```

Esempio:

```text
RumiAI_LANGUAGE=it_IT
```

Il codeset non fa parte della variabile.

## Encoding di interazione

Variabile canonica:

```text
RumiAI_TEXT_ENCODING
```

La bootstrap primitive esplicita è:

```text
$RumiAI_CONF_DIR/bootstrap/i18n/text-encoding
```

Prima implementazione e fallback garantito:

```text
RumiAI_TEXT_ENCODING=UTF-8
```

La variabile è configurabile e rappresenta l'encoding testuale del boundary di interazione. Future implementazioni possono supportare ulteriori encoding senza cambiare il modello interno.

Il file bootstrap contiene un valore semplice letto come dato; la validazione dell'encoding richiesto appartiene alla selector i18n. Non viene introdotto un formato di configurazione separato per questo valore bootstrap.

## Rappresentazione interna

Il testo controllato internamente da RumiAI usa UTF-8 come rappresentazione canonica.

Il control plane interno usa inglese + UTF-8.

Payload utente e dati esterni possono contenere qualunque lingua; quando vengono rappresentati come testo interno vengono convertiti/normalizzati a UTF-8.

Questa regola non implica che contenuto utente o dati esterni debbano essere semanticamente in inglese.

## Cataloghi i18n

I cataloghi sono sempre UTF-8.

Layout:

```text
lang/en_US/
lang/it_IT/
```

Non vengono creati cataloghi duplicati per encoding diversi e il codeset non compare nel pathname del catalogo.

Forme rifiutate:

```text
lang/it_IT.UTF-8/
lang/it_IT/UTF-8/
```

## Boundary

La conversione di encoding avviene soltanto al confine con un'interfaccia o sorgente/destinazione esterna che richieda un encoding diverso:

```text
external/user encoding
        ↓ transcoding
internal UTF-8
        ↓ processing
internal UTF-8
        ↓ transcoding
external/user encoding
```

Con UTF-8 su entrambi i lati non viene eseguita alcuna transcodifica.

## Estensibilità

Supportare in futuro Shift-JIS, EUC-KR, Big5, GB18030, ISO-8859-* o altri encoding significa aggiungere capability/adapter di transcoding al boundary, non duplicare cataloghi o modificare il control plane interno.

## Failure policy

L'assenza di supporto per un encoding di interazione richiesto non dovrebbe rendere il bootstrap fatal quando il boundary può continuare a funzionare in UTF-8.

Il fallback preferito è UTF-8 e la condizione viene diagnosticata tramite logger appena il logger è disponibile.
