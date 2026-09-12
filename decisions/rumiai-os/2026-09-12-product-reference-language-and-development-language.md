# Decisione — Lingua di riferimento del prodotto e lingua della documentazione di sviluppo

Date: 2026-09-12  
Status: **Accepted**

## 1. Scopo

Questa decisione separa due esigenze differenti:

```text
lingua di riferimento del prodotto distribuito

lingua di lavoro della documentazione interna di sviluppo
```

Le due lingue non devono essere confuse né costringere il progetto a mantenere tutta la documentazione interna in inglese nella fase corrente.

## 2. Lingua di riferimento del prodotto

La lingua di riferimento del prodotto distribuito è:

```text
English
```

Ogni contenuto testuale incluso nel prodotto e destinato a essere consumato da utenti, sviluppatori o tooling come rappresentazione testuale del prodotto deve avere una versione inglese **corretta e completa**.

Rientrano in questo principio, quando presenti nel prodotto:

```text
messaggi runtime
help e usage text
documentazione/manuale distribuito
error text destinato alla presentazione
informazioni descrittive pubbliche incluse nel prodotto
altri contenuti testuali localizzabili distribuiti come parte del prodotto
```

La completezza inglese non è opzionale e non dipende dalla presenza di altre traduzioni.

## 3. Inglese come baseline semantico delle localizzazioni

Per i contenuti localizzati del prodotto, l'inglese costituisce la rappresentazione di riferimento.

Il modello è:

```text
English
  -> baseline completa e corretta

altre lingue
  -> localizzazioni della stessa semantica
```

Una localizzazione non deve introdurre un contratto o un significato differente dalla corrispondente rappresentazione inglese.

Le altre lingue possono essere incomplete quando il relativo sottosistema prevede un fallback corretto verso l'inglese; tale incompletezza non deve però compromettere la completezza del prodotto in inglese.

## 4. Relazione con `lang`

Il contratto corrente del runtime già usa:

```text
m_LANGUAGE_FALLBACK=en_US
m_LANG_FALLBACK_DIR=$m_LANG_DIR/en_US
```

ed effettua fallback dal catalogo selezionato a `en_US`.

Questa decisione attribuisce a tale catalogo anche il ruolo di baseline completa dei messaggi di prodotto correnti.

Per ogni message identity canonica distribuita dal prodotto deve quindi esistere un testo inglese non vuoto nel catalogo `en_US`.

Le altre lingue possono fornire la traduzione della stessa identity; se manca una traduzione, il resolver può usare il fallback inglese secondo il contratto corrente.

## 5. Documentazione normativa distribuita nel prodotto

Se verrà adottata l'idea di distribuire nel prodotto una documentazione normativa consultabile localmente, la versione inglese dovrà essere la rappresentazione completa di riferimento della documentazione pubblicata.

Eventuali traduzioni dovranno rappresentare la stessa semantica e non costituire fonti normative indipendenti.

Questo punto non attiva ancora il modello del manuale runtime né ne decide tool, layout, formato o processo di pubblicazione.

## 6. `rumiai-dev`: lingua di lavoro corrente

La documentazione di sviluppo in `rumiai-dev` continua a essere mantenuta principalmente in:

```text
Italiano
```

Questo vale in particolare per:

```text
regole di sviluppo
decisioni
specifiche
analisi
handoff
note progettuali
memoria e documentazione di lavoro
```

nella fase corrente del progetto.

La scelta riflette il fatto che la collaborazione attiva è attualmente centrata sull'autore del progetto e non esiste ancora una necessità concreta di imporre l'inglese come lingua di lavoro interna.

## 7. Quando riesaminare la lingua di `rumiai-dev`

La lingua di lavoro di `rumiai-dev` dovrà essere riesaminata quando inizieranno partecipazioni attive esterne al progetto tali da rendere utile o necessario un linguaggio condiviso più internazionale.

Il riesame non avviene automaticamente per pubblicazione open source, visibilità del repository o presenza occasionale di lettori esterni.

Serve una necessità concreta legata alla collaborazione attiva.

## 8. Separazione fra sviluppo e prodotto

La presenza di documentazione italiana in `rumiai-dev` non autorizza a distribuire nel prodotto contenuti inglesi mancanti, incompleti o di qualità inferiore.

Viceversa, il requisito di inglese completo nel prodotto non impone di tradurre in inglese tutto il materiale interno di sviluppo.

La separazione desiderata è:

```text
rumiai-dev
  -> italiano come lingua di lavoro corrente

prodotto distribuito
  -> inglese completo come riferimento
  -> eventuali altre localizzazioni
```

## 9. Identificatori e codice

Questa decisione riguarda contenuti linguistici destinati alla lettura e alla localizzazione.

Non modifica automaticamente:

```text
nomi di command
API
namespace
message-id
domain
pathname
environment variables
identificatori di codice
```

che continuano a seguire le rispettive regole e decisioni di naming.

## 10. Controlli

La completezza strutturale della baseline inglese deve essere verificata meccanicamente quando il costo è ragionevole.

Per i cataloghi messaggi, almeno la seguente proprietà è verificabile automaticamente:

> ogni message identity distribuita in qualunque catalogo di prodotto deve possedere una corrispondente entry inglese non vuota.

La correttezza linguistica e semantica del testo inglese richiede invece revisione del contenuto e non può essere garantita soltanto da un test meccanico.

Per futura documentazione distribuita, i controlli dovranno analogamente distinguere completezza strutturale da qualità/correttezza semantica.

## 11. Invarianti

```text
LANGUAGE-POLICY-01  English è la lingua di riferimento del prodotto distribuito
LANGUAGE-POLICY-02  i contenuti testuali distribuiti devono essere corretti e completi in inglese
LANGUAGE-POLICY-03  le altre lingue sono localizzazioni della stessa semantica e non fonti indipendenti
LANGUAGE-POLICY-04  localizzazioni non inglesi possono essere parziali solo quando esiste un fallback corretto verso l'inglese
LANGUAGE-POLICY-05  en_US è la baseline completa dei cataloghi messaggi correnti
LANGUAGE-POLICY-06  rumiai-dev resta principalmente in italiano nella fase corrente
LANGUAGE-POLICY-07  la lingua di rumiai-dev verrà riesaminata quando emergerà collaborazione esterna attiva
LANGUAGE-POLICY-08  la lingua dei contenuti non modifica automaticamente naming e identificatori tecnici
```

## 12. Stato corrente

I cataloghi `en_US` e `it_IT` correnti di `rumiai-os` presentano attualmente la stessa struttura di message identity.

Questa decisione non richiede una modifica immediata al resolver `lang` né al meccanismo `lang-set`.

La futura documentazione normativa distribuita resta oggetto di analisi separata e non viene attivata da questa decisione.