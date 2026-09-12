# Decisione — Stratificazione dei contratti del futuro substrato general purpose

Date: 2026-09-12  
Status: **Accepted**

## Contesto

Le analisi esplorative del 2026-09-12 hanno separato concettualmente l'attuale runtime general purpose di `rumiai-os` dal futuro prodotto AI RumiAI.

La separazione fisica, il nome definitivo del substrato, il repository concreto, il nuovo bootstrap/runtime e la migrazione dell'implementazione restano questioni distinte e non vengono decise qui.

Questa decisione consolida invece il modello di esposizione che dovrà essere rispettato **se e quando il substrato general purpose verrà formalmente separato**: il substrato non deve offrire una sola superficie indistinta, ma distinguere chiaramente ciò che deve restare molto stabile per i consumer da ciò che è intenzionalmente più dinamico per sviluppo e tooling.

L'analisi di provenienza è:

```text
analysis/rumiai-os/2026-09-12-substrate-two-level-contract-model.md
```

Il termine colloquiale "SDK di m" usato durante l'esplorazione non viene qui promosso a nome canonico di prodotto, componente, package, directory, namespace o comando. Il nome definitivo della superficie di sviluppo resta aperto.

## 1. Tre classi di esposizione

Il futuro substrato deve distinguere semanticamente tre classi:

```text
1. contratto stabile minimo
2. superficie di sviluppo
3. implementation detail privati
```

Solo le prime due costituiscono contratti intenzionalmente consumabili.

Gli implementation detail privati non costituiscono un terzo livello di API.

La classificazione è semantica e non deriva automaticamente dalla directory fisica, dal linguaggio, dalla presenza nel `PATH`, dall'esistenza di test o dal fatto che una primitive sia tecnicamente raggiungibile.

## 2. Contratto stabile minimo

Il contratto stabile minimo è la boundary primaria fra il substrato e RumiAI.

Deve essere:

```text
piccolo
esplicito
documentato
fortemente testato
compatibile nel tempo per quanto ragionevolmente possibile
indipendente dagli implementation detail evitabili
```

La sua dimensione deve essere trattata come un budget di compatibilità: ogni nuova dipendenza permanente aumenta il costo futuro di evoluzione del substrato.

Il runtime/prodotto RumiAI deve dipendere in produzione soltanto da questa superficie, salvo una futura decisione esplicita che documenti un'eccezione concreta.

Le candidate aree già emerse restano, senza che questa decisione ne fissi ancora il contenuto esatto:

```text
shell contract
service/daemon contract
pochi command pubblici stabili
```

Esempi correnti quali `lang`, `log` e `pkg` restano candidati da classificare separatamente; questa decisione non li promuove automaticamente nel contratto stabile del futuro substrato.

## 3. Garanzie del contratto stabile

Un cambiamento interno del substrato che non modifica il comportamento osservabile del contratto stabile non deve richiedere modifiche al consumer RumiAI.

Un'estensione compatibile del contratto stabile richiede un requisito reale e una decisione coerente con il normale workflow del progetto.

Un cambiamento breaking del contratto stabile è un cambiamento architetturale e richiede almeno:

```text
decisione esplicita
migrazione dei consumer interessati
riallineamento della documentazione normativa
riallineamento dei permanent test pertinenti
validazione proporzionata alla modifica
```

La stabilità riguarda la semantica osservabile e gli invarianti pubblici, non dettagli fisici o implementativi che non siano stati deliberatamente inclusi nel contratto.

## 4. Superficie di sviluppo

Il substrato può esporre una superficie intenzionalmente più ampia destinata a:

```text
sviluppo del substrato
tooling avanzato
prototipazione
integrazioni sperimentali
diagnostica e amministrazione
consumer tecnici che accettano coupling alla revisione corrente
```

Questa superficie costituisce un contratto reale per la revisione a cui appartiene, ma con garanzie di compatibilità inferiori rispetto al contratto stabile.

Le primitive della superficie di sviluppo devono comunque essere, per la revisione corrente:

```text
corrette
documentabili
verificabili
testate in modo proporzionato
```

Non devono però essere congelate per il solo fatto di essere utilizzabili intenzionalmente.

Possono essere rinominate, sostituite, accorpate, separate o rimosse quando l'evoluzione del design lo richiede, purché la documentazione e i consumer che accettano tale coupling vengano riallineati in modo coerente.

## 5. Uso della superficie di sviluppo da parte di RumiAI

Il runtime/prodotto RumiAI non deve usare la superficie di sviluppo come scorciatoia per evitare di definire un contratto stabile necessario.

Questa regola impedisce la situazione:

```text
contratto stabile piccolo sulla carta

ma

RumiAI -> molte primitive dinamiche del substrato
```

che renderebbe soltanto nominale la separazione fra i due prodotti.

L'uso della superficie di sviluppo è invece ammesso, quando esplicito e revision-coupled, per attività quali:

```text
tooling di sviluppo RumiAI
PoC
test e diagnostica
strumenti non appartenenti al runtime/prodotto distribuito
```

La presenza di tali usi non promuove automaticamente la primitive nel contratto stabile.

## 6. Implementation detail privati

Una primitive che serve soltanto all'implementazione corrente e non è intenzionalmente offerta ai consumer resta privata.

Per gli implementation detail privati non esiste promessa di:

```text
nome
pathname
firma
formato
persistenza fra revisioni
compatibilità
```

Il fatto che un dettaglio sia tecnicamente osservabile, richiamabile o coperto da test interni non lo trasforma in API.

I consumer non devono dipendere intenzionalmente da questi dettagli.

## 7. Percorso di maturazione

La promozione di una primitive deve essere deliberata.

Il percorso concettuale consentito è:

```text
implementation detail
       |
       | emerge un uso reale e ripetibile
       v
superficie di sviluppo
       |
       | semantica matura
       | utilità general purpose dimostrata
       | necessità di compatibilità stabile
       v
contratto stabile minimo
```

La promozione non avviene automaticamente per anzianità, numero di chiamanti o presenza di test.

Questo modello deve evitare due estremi:

```text
stabilizzare prematuramente ogni helper utile

tenere tutto privato fino a costringere i consumer a duplicare logica
```

## 8. Testing differenziato

I permanent test del contratto stabile devono proteggere in particolare:

```text
semantica osservabile
invarianti pubblici
compatibilità del consumer RumiAI
failure contract rilevanti
portabilità richiesta
```

Una regressione non deliberata del contratto stabile è normalmente un difetto.

I test della superficie di sviluppo devono proteggere la correttezza della revisione corrente e prevenire regressioni accidentali, ma non devono trasformare automaticamente ogni forma osservata in una promessa di compatibilità permanente.

La semplice esistenza di un permanent test non determina la classe di stabilità di una primitive.

## 9. Documentazione differenziata

La documentazione deve rendere distinguibile il livello di garanzia di una interfaccia o primitive intenzionalmente esposta.

Almeno semanticamente devono poter essere riconosciuti:

```text
stable consumer contract
development surface
private implementation detail
```

Questa decisione non fissa ancora:

```text
naming finale delle classi nel prodotto
annotazioni nei sorgenti
layout fisico della documentazione
registry o manifest delle API
schema di versionamento
marker di compatibilità
```

Tali meccanismi richiedono casi concreti e decisioni separate.

## 10. Path e visibilità non implicano stabilità

Il livello di contratto non deve essere inferito dal filesystem.

In particolare, nel prodotto corrente:

```text
lib/<runtime>/*
```

identifica librerie interne del relativo runtime, ma non rende automaticamente ogni simbolo un contratto stabile.

Analogamente:

```text
bin/sys/*
```

non implica che ogni command disponibile sia una dipendenza stabile autorizzata per RumiAI.

Lo stesso principio dovrà valere nel futuro substrato qualunque sia il layout definitivo.

## 11. Relazione con `pkg`

Il modello si applica anche al sottosistema package.

RumiAI potrà dipendere da un piccolo contratto stabile del package manager, mentre resolver, adapter, primitive di materializzazione, helper e strumenti diagnostici potranno appartenere alla superficie di sviluppo o restare implementation detail.

Questa decisione non modifica lo schema corrente di `pkg-catalog`, non classifica ancora le singole primitive di `pkg` e non modifica il contratto corrente secondo cui `pkg` non gestisce il sistema base RumiAI.

## 12. Beneficio architetturale fissato

Il substrato deve poter essere contemporaneamente:

```text
conservativo verso i consumer stabili

ed

aggressivamente migliorabile al proprio interno
```

La robustezza deriva dal mantenimento di pochi contratti forti.

La flessibilità deriva dal fatto che una superficie di sviluppo più ampia può evolvere senza congelare prematuramente l'intera architettura.

L'obiettivo è quindi:

> stabilizzare poco, ma stabilizzarlo molto bene.

## 13. Invarianti fissati

```text
SUBSTRATE-CONTRACT-01  il futuro substrato distingue contratto stabile minimo, superficie di sviluppo e implementation detail privati
SUBSTRATE-CONTRACT-02  soltanto contratto stabile e superficie di sviluppo sono contratti intenzionalmente consumabili
SUBSTRATE-CONTRACT-03  RumiAI in produzione dipende normalmente soltanto dal contratto stabile minimo
SUBSTRATE-CONTRACT-04  la superficie di sviluppo può evolvere con frequenza maggiore e non promette la stessa compatibilità inter-release
SUBSTRATE-CONTRACT-05  gli implementation detail privati non costituiscono API e non offrono garanzie di persistenza
SUBSTRATE-CONTRACT-06  path, visibilità, linguaggio, presenza nel PATH e presenza di test non determinano automaticamente la classe di stabilità
SUBSTRATE-CONTRACT-07  la promozione private -> development -> stable è deliberata e guidata da requisiti reali, non automatica
SUBSTRATE-CONTRACT-08  un cambiamento breaking del contratto stabile richiede decisione e migrazione esplicite
SUBSTRATE-CONTRACT-09  i test della superficie di sviluppo garantiscono correttezza della revisione corrente senza creare automaticamente compatibilità permanente
SUBSTRATE-CONTRACT-10  il termine colloquiale "SDK di m" non è ancora nome canonico di alcun componente o superficie
SUBSTRATE-CONTRACT-11  il modello non decide nome, repository, bootstrap, layout o migrazione fisica del futuro substrato
```

## 14. Stato di implementazione

Questa decisione è architetturale e documentale.

Non modifica:

```text
rumiai-os
rumiai-tests
pkg-catalog
```

Non introduce ancora nuovi command, file runtime, directory, environment variables, API concrete o test permanenti.

Non richiede una physical validation separata finché non viene tradotta in un contratto runtime o in implementazione osservabile.
