# Decisione — Serializzazione facility/dependency e policy di compatibility resolution

Date: 2026-09-11  
Status: **Accepted**

## Contesto e autorità

Questa decisione chiude i punti lasciati esplicitamente aperti da:

```text
decisions/rumiai-os/2026-09-07-package-facility-dependency-and-provider-index.md
```

relativi a:

```text
sintassi testuale esatta di <package-version>/facility
sintassi testuale esatta di <package-version>/dependency
grammatica e confronto della compatibility numerica multi-componente
policy deterministica fra provider compatibili equivalenti
```

Le decisioni preesistenti su facility, dependency, provider index, resolved binding, target eligibility e normale launch restano invariate.

L'utente ha approvato esplicitamente questa proposta il 2026-09-11 e ha autorizzato la prosecuzione autonoma della fase nei limiti delle regole correnti.

---

## 1. Nome della facility

Una facility usa la grammatica canonica:

```text
[a-z][a-z0-9-]*
```

Sono quindi esempi validi:

```text
java
python
example-api
openssl-api
```

Non sono validi, fra gli altri:

```text
Java
foo_bar
foo.bar
foo/bar
```

La facility è un'identità RumiAI controllata e viene usata anche come singolo pathname component nel provider index e in `binding/<facility>`.

---

## 2. Compatibility

La compatibility è una tupla numerica decimale distinta dalla versione upstream.

Grammatica concettuale:

```text
<number>[.<number>...]
```

Ogni componente è:

```text
0
```

oppure:

```text
[1-9][0-9]*
```

Sono validi, per esempio:

```text
0
1
17
21
3.11
3.14
2.7.15
1.0.1
```

Non sono validi:

```text
01
3.011
3.
.11
3..11
v21
21-ea
21+1
```

Per garantire una sola rappresentazione canonica dello stesso valore numerico, una compatibility con più componenti non può terminare con componente `0`.

Quindi:

```text
21
3.11
3.11.2
1.0.1
```

sono forme canoniche, mentre:

```text
21.0
3.11.0
1.0.0
```

non lo sono.

---

## 3. Confronto delle compatibility

Il confronto avviene numericamente, componente per componente da sinistra.

I componenti mancanti sono semanticamente considerati `0` durante il confronto.

Esempi:

```text
3.11 < 3.12
3.11 < 3.11.1
3.11.2 > 3.11.1
21 < 22
```

La proibizione degli zeri finali impedisce di avere più serializzazioni canoniche dello stesso valore, per esempio `21`, `21.0` e `21.0.0`.

Queste regole valgono esclusivamente per la compatibility delle facility. Non introducono un comparatore universale delle versioni upstream.

---

## 4. Serializzazione canonica di `facility`

Il file opzionale:

```text
<package-version>/facility
```

usa una dichiarazione per riga con forma esatta:

```text
<facility> <compatibility>
```

Esempio:

```text
example-api 3
java 21
python 3.11
```

Il file è:

```text
regular file
non executable
non shell code
terminato da LF
```

La serializzazione canonica richiede inoltre:

```text
nessuna riga vuota
nessun commento
nessun quoting
nessun escaping
nessuno spazio iniziale o finale
esattamente un ASCII SPACE fra facility e compatibility
facility univoche nel file
righe ordinate bytewise con LC_ALL=C per facility
```

La declaration package-local resta autorevole; il provider index resta derivato.

---

## 5. Serializzazione canonica di `dependency`

Il file opzionale:

```text
<package-version>/dependency
```

usa una dependency per riga con forma:

```text
<facility> <comparator><compatibility> [<comparator><compatibility> ...]
```

Esempi:

```text
example-api =3
java >=17 <22
python >=3.11 <3.14
```

Ogni comparator e compatibility costituiscono un singolo token. La forma:

```text
java >= 17 < 22
```

non è canonica.

Restano ammessi esclusivamente i comparator già fissati:

```text
=
>
>=
<
<=
```

Più comparator della stessa riga sono congiunti per intersezione.

Il file segue inoltre le stesse regole strutturali di `facility`:

```text
regular file
non executable
non shell code
terminato da LF
nessuna riga vuota
nessun commento
nessun quoting
nessun escaping
nessuno spazio iniziale o finale
esattamente un ASCII SPACE fra i token
una sola dependency per facility
righe ordinate bytewise con LC_ALL=C per facility
```

Restano esclusi:

```text
OR
!=
wildcard
caret
tilde
constraint sulla versione upstream
provider concreto
selector current
```

La dependency resta quindi un requisito astratto e non duplica il resolved binding.

---

## 6. Serializzazione catalogo e package materializzato

Le package definition del catalogo usano la stessa identica serializzazione per gli eventuali file:

```text
facility
dependency
```

`pkg` valida la serializzazione e, quando la relativa fase implementativa è supportata, la materializza senza tradurla in un secondo formato.

Non viene introdotto un secondo schema, template, shell assignment o mini-linguaggio.

---

## 7. Selezione della compatibility

Dopo il filtro già fissato per:

```text
facility esatta
constraint soddisfatti
target eligibility
```

la resolution seleziona la **massima compatibility numericamente compatibile**.

Esempio:

```text
dependency: java >=17 <22
compatibility disponibili: 17, 18, 21, 22
```

La compatibility selezionata è:

```text
21
```

Questa regola ordina la compatibility della facility e non costituisce ranking delle versioni upstream o dei provider.

---

## 8. Provider equivalenti alla compatibility selezionata

Dopo aver scelto la massima compatibility compatibile, vengono considerati i provider concreti eleggibili che offrono esattamente quella compatibility.

Se il provider concreto eleggibile è uno solo, viene selezionato.

Se esistono più provider concreti eleggibili alla stessa compatibility selezionata, la resolution fallisce per ambiguità.

Non vengono usati come tie-break impliciti:

```text
ordine lessicografico del package
ordine di installazione
selector current/default del provider
ordine del filesystem
prima entry incontrata
release upstream più recente
preferenza implicita target-specific rispetto a generic
preferenza implicita generic rispetto a target-specific
```

Un eventuale futuro meccanismo esplicito di scelta fra provider equivalenti verrà introdotto soltanto davanti a un caso d'uso concreto e richiederà una decisione separata.

---

## 9. Confine implementativo K1

La prima tranche implementativa viene mantenuta intenzionalmente più piccola del modello completo.

K1 implementa esclusivamente il lato provider `facility`:

```text
validazione della serializzazione facility nel range catalogo
materializzazione invariata di <package-version>/facility
creazione dei provider marker derivati durante pkg_integrate
rimozione dei provider marker durante pkg_deintegrate
rimozione della directory <compatibility>/ quando perde l'ultimo marker
```

K1 non abilita ancora package definition contenenti `dependency` e non materializza `binding/`.

Una range definition con `dependency` continua quindi a non essere ammessa dal prodotto fino a K2. Questo impedisce di installare con successo un consumer con requirement materializzato ma senza resolved binding.

K1 non modifica il normale launch e non introduce alcun nuovo comando pubblico.

---

## 10. Confine K2 ancora separato

K2 potrà implementare:

```text
validazione/materializzazione dependency
compatibility matching e confronto
provider discovery attraverso provider index
scelta della massima compatibility compatibile
fallimento su provider equivalenti multipli
materializzazione binding/<facility>
```

Prima di completare il lifecycle K2 dovrà essere fissata, quando concretamente necessaria, la semantica di rimozione di un provider già referenziato da binding esistenti e l'eventuale atomicità/recovery delle sostituzioni.

Questa decisione non anticipa tale punto ancora aperto.

Lo State Instance avanzato resta fuori da K1/K2 salvo un successivo caso d'uso concreto.

---

## 11. Invarianti

```text
PKG-FAC-SER-01  facility name = [a-z][a-z0-9-]*
PKG-FAC-SER-02  compatibility = uno o più componenti numerici decimali separati da punto
PKG-FAC-SER-03  ogni componente compatibility è 0 oppure [1-9][0-9]*
PKG-FAC-SER-04  compatibility multi-componente non termina con componente 0
PKG-FAC-SER-05  confronto compatibility numerico componente-per-componente; componenti mancanti valgono 0
PKG-FAC-SER-06  queste regole non introducono confronto universale delle versioni upstream
PKG-FAC-SER-07  facility line = <facility><SPACE><compatibility><LF>
PKG-FAC-SER-08  dependency line = <facility><SPACE><op><compatibility>[<SPACE><op><compatibility>...]<LF>
PKG-FAC-SER-09  facility/dependency non hanno righe vuote, commenti, quoting, escaping o whitespace non canonico
PKG-FAC-SER-10  facility/dependency sono ordinate bytewise C per facility e non duplicano facility
PKG-FAC-SER-11  catalogo e package materializzato usano la stessa serializzazione
PKG-FAC-SER-12  resolution sceglie la massima compatibility numericamente compatibile dopo facility/constraint/target filtering
PKG-FAC-SER-13  un solo provider alla compatibility scelta -> provider selezionato
PKG-FAC-SER-14  più provider eleggibili alla compatibility scelta -> ambiguity/failure
PKG-FAC-SER-15  nessun current/default/install-order/filesystem-order/upstream-release-order o ranking implicito risolve l'ambiguità
PKG-FAC-SER-16  K1 implementa solo facility provider declaration + provider index lifecycle
PKG-FAC-SER-17  K1 non accetta ancora dependency nel prodotto e non materializza binding
PKG-FAC-SER-18  K2 resta separato e non anticipa ancora provider-removal/reference e transaction semantics
PKG-FAC-SER-19  normale launch resta privo di resolution
PKG-FAC-SER-20  State Instance avanzato resta fuori da questa tranche
```
