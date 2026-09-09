# Decisione — `fatal` per i failure terminali con logging

Date: 2026-09-09  
Status: **Accepted**

## Contesto

Il runtime RumiAI espone già la primitive shell `fatal`, che combina due responsabilità intenzionalmente accoppiate:

1. emissione di un evento tramite `log` con severity `fatal`;
2. terminazione immediata con exit status configurabile.

Comporre manualmente `log ...` seguito da `exit` quando entrambe queste responsabilità sono richieste duplica una primitive esistente, può classificare come `error` un failure che in realtà termina il comando e favorisce wrapper privi di responsabilità aggiuntive.

## Decisione

Quando codice RumiAI opera in un runtime nel quale `fatal` è disponibile e un percorso di failure deve **sia** emettere un evento RumiAI **sia** terminare immediatamente il comando/processo corrente, deve essere usata la primitive esistente `fatal` invece di comporre `log ...` seguito da `exit`.

Forma canonica con status di default:

```sh
fatal execution execution-failed operation foo
```

Quando il contratto richiede uno status diverso da quello di default, lo status deve essere preservato tramite il primo argomento numerico di `fatal`:

```sh
fatal 2 execution invalid-arguments operation foo
```

La sostituzione non autorizza quindi a modificare incidentalmente gli exit status pubblici del comando.

## Severity e prosecuzione

`log error` resta appropriato per un errore registrato dopo il quale l'esecuzione corrente intenzionalmente prosegue oppure quando la terminazione non è responsabilità del punto che effettua il log.

Un percorso che registra l'evento e poi termina immediatamente non deve invece essere modellato come:

```sh
log error ...
exit ...
```

né come:

```sh
log fatal ...
exit ...
```

quando `fatal` è disponibile e semanticamente equivalente.

## Cleanup prima della terminazione

Se il failure richiede cleanup o altre operazioni necessarie prima della terminazione, tali operazioni possono precedere `fatal`.

Esempio:

```sh
command -p -- rm -f -- "$tmp" 2>/dev/null || :
fatal execution execution-failed operation foo
```

Il cleanup non giustifica la ricomposizione manuale di `log` + `exit` quando la terminazione finale resta esattamente responsabilità di `fatal`.

## Funzioni wrapper

Non deve essere introdotta o mantenuta una funzione la cui unica responsabilità sia fare da alias a `fatal`, oppure implementare esclusivamente la coppia `log ...` + `exit` che `fatal` sostituisce già.

Una funzione dedicata resta giustificata quando possiede una responsabilità reale aggiuntiva, per esempio cleanup, trasformazione o validazione non banale, gestione di stato o semantica riutilizzata da più call site.

## Ambito ed eccezioni

Questa regola si applica dove `fatal` è disponibile per contratto.

Non obbliga codice eseguito prima che il bootstrap abbia reso disponibile `fatal` ad usarlo.

Non obbliga una utility standalone `#!/bin/sh` ad acquisire una dipendenza dal bootstrap soltanto per la gestione diagnostica. Le utility standalone seguono il proprio contratto autorevole; `read-key` è il caso corrente esplicitamente approvato e comunica i failure gestiti tramite exit status senza diagnostiche proprie.

Un `exit` diretto non è vietato in assoluto: questa decisione disciplina specificamente il caso in cui **logging RumiAI e terminazione immediata sono entrambi intenzionali nello stesso failure path**.

## Conseguenze

Per il codice nuovo e per il codice modificato:

- i failure terminali con logging usano `fatal` quando disponibile;
- `log error` non viene usato come preludio immediato alla terminazione;
- `log fatal` + `exit` non viene ricomposto manualmente;
- gli exit status contrattuali vengono preservati usando, quando necessario, l'argomento numerico di `fatal`;
- non vengono creati helper che duplicano esclusivamente questa responsabilità.

Le revisioni storiche restano evidenza storica e non vengono riscritte.
