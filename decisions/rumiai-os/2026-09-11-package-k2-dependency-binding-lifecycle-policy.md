# Decisione — K2 dependency resolution, binding lifecycle e provider reference policy

Date: 2026-09-11  
Status: **Accepted**

## Contesto e autorità

Questa decisione completa il confine K2 lasciato aperto da:

```text
decisions/rumiai-os/2026-09-07-package-facility-dependency-and-provider-index.md
decisions/rumiai-os/2026-09-11-package-facility-dependency-serialization-and-resolution-policy.md
decisions/rumiai-os/2026-09-11-package-current-plan-after-k1-physical-validation.md
```

L'utente ha approvato esplicitamente questa policy il 2026-09-11 e ha autorizzato la prosecuzione autonoma della fase K2, inclusa l'implementazione in `rumiai-os`, nei limiti delle regole correnti.

Restano invariate tutte le decisioni già Accepted su:

```text
facility
dependency
compatibility
provider index
target eligibility
resolved binding
massima compatibility compatibile
ambiguity failure
normal launch senza resolution
```

Questa decisione chiude in particolare i punti ancora aperti relativi a:

```text
provider removal quando esistono binding referenzianti
atomicità delle mutazioni dependency/binding
recovery scope di K2
ordine fra dependency resolution e provider admission
```

---

## 1. Preflight completo delle dependency prima della mutazione

Per un concrete package che contiene `dependency`, `pkg` deve completare prima di qualsiasi mutazione del package installato:

```text
validazione dell'intera package definition
validazione dell'intero file dependency
resolution di tutte le dependency
costruzione dell'intero insieme dei resolved binding
```

Solo quando tutte le dependency sono state risolte con successo può iniziare la materializzazione del concrete package.

Se anche una sola dependency è:

```text
malformata
insoddisfatta
priva di provider target-eligible
ambigua alla compatibility selezionata
```

l'integrazione fallisce e non deve pubblicare una concrete package version parzialmente materializzata.

La resolution dell'intero set è quindi una fase di preflight e non viene intercalata con la creazione progressiva dei singoli binding.

---

## 2. Materializzazione e provider admission

Dopo la resolution completa, il concrete package può essere materializzato con gli oggetti applicabili:

```text
root/
cmd/
link/
facility
dependency
binding/
```

Il file package-local `dependency` viene materializzato senza traduzione, usando la serializzazione già fissata.

Per ogni dependency esiste esattamente un:

```text
binding/<facility>
```

contenente la concrete identity del provider selezionato seguita da LF.

Se il concrete package offre anche facility proprie, i relativi provider marker vengono pubblicati soltanto dopo che la materializzazione del package, incluse dependency e binding, è completata con successo.

Un package non deve quindi diventare provider disponibile mentre i propri binding sono ancora incompleti.

---

## 3. Nessuna self-provision durante la stessa integrazione

Le facility dichiarate dal concrete package che si sta integrando non partecipano alla resolution delle dependency dello stesso package.

La resolution considera i provider già disponibili nel provider index prima dell'integrazione del nuovo package.

Non viene introdotto un fallback che consulti il file `facility` del package in corso di installazione come provider aggiuntivo.

Questo mantiene un unico meccanismo di provider discovery:

```text
provider index degli installed provider
```

---

## 4. Operandi multipli restano sequenziali

La semantica corrente di operazioni multi-operando resta invariata.

Per esempio:

```text
pkg install a b c
```

esegue i package in ordine di operando.

Se `a` viene installato con successo, può diventare provider disponibile quando viene successivamente elaborato `b`.

Non vengono introdotti in K2:

```text
riordinamento automatico degli operandi
grafo topologico di installazione
installazione automatica delle dependency
rollback globale degli operandi già completati
```

La stessa disciplina sequenziale resta applicabile a `pkg uninstall` secondo il contratto già esistente.

---

## 5. Provider referenziato non rimovibile

Un concrete package provider non può essere rimosso mentre almeno un installed consumer possiede un resolved binding che contiene esattamente la concrete identity del provider.

Quindi, se un consumer contiene:

```text
binding/<facility>
```

con contenuto:

```text
<provider-concrete-identity>\n
```

la rimozione di quel provider fallisce con status operativo `1`.

Questa regola vale anche quando esiste un altro provider compatibile che potrebbe soddisfare la stessa dependency.

La rimozione non effettua re-resolution automatica e non modifica implicitamente i binding dei consumer.

---

## 6. Reference check prima di qualsiasi mutazione di uninstall

La verifica che il concrete provider non sia referenziato deve avvenire prima di qualunque mutazione osservabile richiesta dall'uninstall.

In particolare, se il provider è anche la versione `current`, il reference check precede:

```text
rimozione del selector current
rimozione dei public command binding
rimozione dei provider marker
rimozione del concrete package
```

Se il provider è referenziato, tutti questi oggetti devono restare invariati.

---

## 7. Nessun reverse reference index

K2 non introduce un indice inverso dei consumer o delle reference.

Il dato autorevole resta package-local:

```text
<consumer>/binding/<facility>
```

Durante un'operazione esplicita di removal, `pkg` può scandire i concrete package installati e i loro binding per verificare se la concrete identity da rimuovere è ancora referenziata.

Non vengono introdotti namespace come:

```text
data/sys/pkg/consumers/
data/sys/pkg/references/
```

La scansione avviene soltanto durante operazioni amministrative esplicite e non durante il normale launch.

---

## 8. Atomicità K2 per singola concrete package operation

K2 richiede atomicità logica a livello della singola integrazione di concrete package:

```text
tutte le dependency risolte e tutti i binding materializzati
```

oppure:

```text
integrazione fallita senza package installato parzialmente valido
```

La garanzia si appoggia al lifecycle e al rollback della singola `pkg_integrate` e non introduce un transaction engine generale.

Le operazioni multi-operando continuano a non costituire una transazione globale: un operando già completato non viene rollbackato a causa del fallimento di un operando successivo.

---

## 9. Recovery da crash fuori da K2

K2 deve gestire gli errori rilevati durante le operazioni tramite preflight e rollback proporzionati.

Non introduce invece una garanzia generale contro crash arbitrari, power loss o process termination in qualunque punto della mutazione.

Restano fuori da K2:

```text
journal
write-ahead log
generations
transaction directory globale
recovery daemon
commit marker generale
```

Se emergerà un requisito concreto di crash consistency, verrà affrontato come proprietà generale del package lifecycle con una decisione separata.

---

## 10. Nessun nuovo comando pubblico di re-resolution

Il modello continua ad ammettere semanticamente una futura re-resolution esplicita dei binding, ma K2 non introduce ancora un nuovo comando pubblico per effettuarla.

Non vengono quindi fissati o creati in questa fase nomi come:

```text
pkg resolve
pkg rebind
pkg repair
```

Un provider referenziato resta non rimovibile fino a quando il consumer viene rimosso oppure un futuro meccanismo esplicito, separatamente specificato, modifica il binding.

---

## 11. Compatibility comparison senza overflow

L'implementazione del confronto della compatibility deve rispettare la semantica numerica già fissata senza dipendere dalla capacità numerica dell'integer shell.

I componenti decimali possono quindi essere confrontati come stringhe canoniche mediante:

```text
lunghezza del componente
poi ordine lessicografico delle cifre a parità di lunghezza
```

Il confronto tuple resta componente-per-componente e considera i componenti mancanti semanticamente uguali a `0`.

Non viene usato un comparatore universale delle versioni upstream.

---

## 12. Exit status

K2 non introduce nuovi exit status pubblici.

Restano:

```text
0  successo
1  operazione valida ma impossibile/fallita o package definition semanticamente invalida
2  uso/API non valido o feature non supportata
```

Sono quindi status `1`, fra gli altri:

```text
dependency malformata
provider assente
constraint insoddisfatto
provider ambiguo
provider ancora referenziato
```

Gli status dei permanent test restano invece quelli definiti da `TESTING.md`.

---

## 13. Confine implementativo K2

K2 può ora implementare:

```text
validazione/materializzazione dependency
compatibility comparison e constraint matching
provider discovery dal provider index
selezione della massima compatibility compatibile
ambiguity failure
resolved binding package-local
reference scan dei binding durante provider removal
preflight uninstall prima di current/public-binding mutation
rollback per-package proporzionato
```

K2 non introduce:

```text
nuovo comando pubblico
reverse reference index
automatic dependency installation
automatic operand reorder
automatic re-resolution on uninstall
self-provision durante la stessa integrazione
global transaction engine
crash-recovery engine
State Instance avanzato
```

---

## 14. Invarianti

```text
PKG-K2-01  tutte le dependency vengono validate e risolte prima di qualsiasi mutazione della concrete integration
PKG-K2-02  failure di una dependency impedisce la pubblicazione di un consumer parzialmente installato
PKG-K2-03  dependency materializzata mantiene la serializzazione catalogo invariata
PKG-K2-04  ogni dependency risolta produce esattamente binding/<facility> con provider concrete identity + LF
PKG-K2-05  provider admission del nuovo package avviene soltanto dopo materializzazione completa dei suoi binding
PKG-K2-06  il package in integrazione non può soddisfare una propria dependency tramite facility non ancora pubblicate
PKG-K2-07  install/uninstall multi-operando restano sequenziali e non transazionali globalmente
PKG-K2-08  K2 non riordina operandi e non installa automaticamente dependency
PKG-K2-09  provider referenziato da un installed binding non è rimovibile
PKG-K2-10  provider removal non effettua re-resolution automatica
PKG-K2-11  reference check precede ogni mutazione di current, public binding, provider index e concrete package
PKG-K2-12  nessun reverse reference index viene introdotto; binding package-local resta autorevole
PKG-K2-13  atomicità richiesta = singola concrete package operation, non intera command line
PKG-K2-14  crash/power-loss recovery generale resta fuori da K2
PKG-K2-15  nessun nuovo comando pubblico di re-resolution viene introdotto in K2
PKG-K2-16  compatibility comparison non dipende dall'ampiezza degli integer shell
PKG-K2-17  malformed/unsatisfied/ambiguous/referenced operational cases ritornano status 1
PKG-K2-18  normale launch continua a non effettuare resolution
PKG-K2-19  dependency requirement continua a essere distinto dal resolved binding
PKG-K2-20  Git resta forward-only
```
