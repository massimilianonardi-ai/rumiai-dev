# Decisione — Attivazione del resource model e migrazione `lang` sotto `res`

Date: 2026-09-14  
Status: **Accepted**

## 1. Decisione

Viene attivata come contratto corrente:

```text
specifications/rumiai-os/RESOURCE-MODEL.md
```

La static-resource architecture, esplicitamente rinviata dal Model 2.0 a dopo `2.0.0`, viene ora fissata per la prima baseline concreta.

La nuova semantic root è:

```text
$m_ROOT/res
```

con:

```text
m_RES_DIR=$m_ROOT/res
```

Le risorse globali sono ownership-qualified:

```text
res/sys/
res/ai/
```

La prima classe concreta migrata è `lang`.

---

## 2. Migrazione di `lang`

Il precedente layout:

```text
$m_ROOT/lang/<locale>/<domain>/<message-id>
$m_ROOT/lang/current
```

viene sostituito da:

```text
$m_ROOT/res/sys/lang/<locale>/<domain>/<message-id>
$m_ROOT/res/sys/lang/current
$m_ROOT/res/ai/lang/<locale>/...
$m_ROOT/res/ai/lang/current
```

L'interfaccia tecnica esistente resta:

```text
m_LANG_DIR=$m_RES_DIR/sys/lang
```

La funzione `lang` di `m` continua a risolvere soltanto i cataloghi tecnici `sys`.

Non viene introdotto un resolver cross-owner.

---

## 3. Selezione della lingua

La lingua globale è rappresentata dai symbolic link relativi:

```text
res/sys/lang/current
res/ai/lang/current
```

I language tree globali materializzati sotto `res/*/lang` partecipano alla stessa selezione.

`lang-set <locale>` valida prima tutti i partecipanti e cambia tutti i selector nello stesso operation contract. `sys` viene aggiornato per ultimo come commit logico osservabile dalla query.

`lang-set` senza argomenti restituisce soltanto il locale selezionato da `res/sys/lang/current`.

La selezione iniziale distribuita è `en_US`.

Non viene promessa crash-atomicity multi-symlink; gli errori ordinari gestiti richiedono rollback verso la selezione precedente.

---

## 4. Ownership dei package

Le risorse dei package, inclusi i cataloghi di lingua, restano nel tree/versione del package.

Non vengono proiettate nel resource tree globale e non vengono modificate da `lang-set`.

La specifica integrazione del package decide se e come configurare il software upstream per seguire la lingua globale oppure un override package-specifico. Non viene introdotta una sintassi universale di configurazione lingua per i package.

---

## 5. Dipendenza `m` / RumiAI

Il nuovo layout non modifica l'invariante per cui `m` non dipende semanticamente da RumiAI.

In particolare:

- `m_RES_DIR` identifica la root generale delle risorse globali;
- `m_LANG_DIR` identifica il language tree tecnico `sys`;
- `lang-set` opera sulla forma generale `res/*/lang` e non contiene una dipendenza esplicita dal nome `ai`;
- `lang` non cerca cataloghi branded.

---

## 6. Supersession mirata

Questa decisione supersede, per il contratto corrente post-2.0, le seguenti clausole di:

```text
decisions/rumiai-os/2026-09-08-top-level-semantic-roots-and-lang-placement.md
```

come segue:

- `SEMROOT-01`: `lang` non è più una semantic root top-level; `res` entra nell'insieme delle semantic root top-level;
- `SEMROOT-08`: `m_LANG_DIR` non vale più `$m_ROOT/lang`, ma `$m_RES_DIR/sys/lang`;
- `SEMROOT-10`: il selector tecnico non è più `$m_ROOT/lang/current`, ma `$m_RES_DIR/sys/lang/current`, affiancato dal selector globale degli altri language tree materializzati;
- `SEMROOT-11`: il precedente divieto di introdurre una root generica `share/resources` soltanto per contenere `lang` è superato dalla decisione post-2.0 di adottare `res` come semantic root generale delle risorse, non come semplice wrapper di `lang`.

Restano invariati gli altri principi della decisione, inclusi:

- una top-level semantic root ha la propria environment variable;
- una root variable non obbliga il bootstrap a materializzare la directory;
- non vengono creati environment alias per ogni sottodirectory;
- le state area mantengono le proprie semantiche;
- non esiste una semantic root globale `var`.

`m_LANG_DIR` è mantenuta perché è un'interfaccia semantica preesistente della facility `lang`, non perché ogni resource class debba ottenere una environment variable dedicata.

---

## 7. Rapporto con Model 2.0

`MODEL-2.0-MIGRATION.md` aveva fissato:

```text
MODEL2-28  static-resource redesign is deferred until after 2.0.0
```

Questa decisione chiude quel rinvio nel periodo post-2.0 senza modificare il checkpoint storico `2.0.0` né la relativa evidenza.

Non vengono riscritte decisioni storiche o validation precedenti.

---

## 8. Documentazione corrente

`specifications/rumiai-os/LANG-BOOTSTRAP.md` viene riallineata nello stesso work unit al nuovo resource model.

Le descrizioni precedenti incompatibili del path `$m_ROOT/lang` e del vecchio output tabellare di `lang-set` devono essere lette come superseded da questa decisione e dalle specifiche correnti.

---

## 9. Implementazione e test

L'attivazione richiede, nello stesso work unit logico:

1. introduzione di `m_RES_DIR` nel bootstrap;
2. migrazione dei cataloghi tecnici correnti da `lang/` a `res/sys/lang/`;
3. materializzazione dei language tree `sys` e `ai` per i locale supportati correnti;
4. selector `current` relativi inizializzati a `en_US` per entrambi;
5. riallineamento di `lang-set` alla selezione globale multi-owner;
6. aggiornamento dei test permanenti pertinenti in `rumiai-tests`;
7. development run proporzionata;
8. eventuale validation run solo su revisioni committed e clean, secondo `TESTING.md`.

L'esistenza di questa decisione non costituisce evidenza di implementazione o validation.

---

## 10. Invarianti della decisione

```text
RES-ACT-01  RESOURCE-MODEL.md è il contratto corrente delle risorse globali
RES-ACT-02  res è una semantic root top-level ed è esposta come m_RES_DIR
RES-ACT-03  lang migra da $m_ROOT/lang a $m_RES_DIR/sys/lang per il layer tecnico
RES-ACT-04  sys e ai mantengono selector lang/current distinti ma semanticamente sincronizzati
RES-ACT-05  lang-set query legge la selezione sys e restituisce soltanto il locale
RES-ACT-06  lang-set set valida e aggiorna tutti i language tree globali materializzati
RES-ACT-07  m non acquisisce dipendenza semantica da ai
RES-ACT-08  le risorse dei package restano package-local e fuori dal controllo di lang-set
RES-ACT-09  nessun resolver universale delle risorse viene introdotto
RES-ACT-10  il resource model non modifica il modello di state
RES-ACT-11  le clausole SEMROOT-01, SEMROOT-08, SEMROOT-10 e SEMROOT-11 sono superseded nella misura definita qui
RES-ACT-12  Git resta forward-only e la validation resta revision-specific
```
