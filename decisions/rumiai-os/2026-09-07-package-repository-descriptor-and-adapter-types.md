# Decisione — Serializzazione del repository descriptor e policy dei repository type

Date: 2026-09-07  
Status: **Accepted**

## Contesto

Il package-definition catalog di RumiAI usa, per ogni stream disponibile, un solo repository upstream corrente. Le decisioni precedenti avevano già fissato il ruolo semantico del repository descriptor e le API comuni degli adapter, lasciandone aperta la serializzazione fisica.

È ora fissato che il repository descriptor è **dato dichiarativo del catalogo**, non codice. La package-definition catalog non deve poter introdurre logica shell arbitraria soltanto perché descrive un repository upstream.

Questa decisione chiude la serializzazione minima di `<stream>/repository/` e la policy iniziale dei repository type. Non chiude ancora la serializzazione completa della package definition di range.

Questa unità modifica soltanto `rumiai-dev`. Non modifica `pkg-catalog`, `rumiai-os` o `rumiai-tests`.

---

## 1. `repository/` è una directory

Ogni stream disponibile contiene esattamente una directory:

```text
repository/
```

Esempio strutturale:

```text
<pkg>/catalog/
├── repository/
├── n0001=<version-minimum>/
└── ...
```

oppure:

```text
<pkg>/catalog-<osarch>/
├── repository/
├── n0001=<version-minimum>/
└── ...
```

`repository/` descrive esclusivamente il repository upstream corrente dello stream.

Non è:

```text
un file env
un manifest shell
una libreria
un eseguibile
un repository storico
una package definition di range
```

---

## 2. File scalari dichiarativi

I campi del repository descriptor sono file scalari direttamente contenuti in:

```text
repository/
```

Ogni campo è rappresentato da:

```text
repository/<field>
```

Il nome del file identifica il campo; il contenuto identifica il valore.

Il formato generico di un campo scalare è:

```text
<value>\n
```

con le seguenti regole:

```text
file regolare non eseguibile
un solo valore non vuoto
una sola riga terminata da LF
nessun CR
nessun NUL
nessuna seconda riga
nessuna interpretazione shell
```

Il valore viene preservato come dato. Eventuali restrizioni ulteriori appartengono al contratto del singolo campo definito dall'adapter pertinente.

Un campo opzionale non presente è rappresentato dall'assenza del relativo file, non da un file vuoto.

La baseline mantiene `repository/` piatta: i campi sono file scalari direttamente sotto la directory. Sottodirectory o strutture più complesse richiedono una necessità concreta e una decisione successiva.

---

## 3. `repository/type` è l'unico campo comune obbligatorio

Ogni `repository/` contiene obbligatoriamente:

```text
repository/type
```

Il file contiene il repository type concreto, per esempio:

```text
github
```

oppure:

```text
sourceforge
```

oppure:

```text
maven
```

Il repository type è un identificatore RumiAI lowercase e usa lettere ASCII minuscole, cifre e, quando necessario, hyphen `-`; inizia e termina con una lettera o cifra.

Il valore di `repository/type` seleziona l'adapter canonico:

```text
type = <type>
    -> lib/sh/pkg-repository-<type>.lib.sh
```

Questa corrispondenza non introduce una nuova API: l'adapter selezionato continua a esporre esclusivamente le API repository già fissate:

```text
pkg_repository_list_versions
pkg_repository_resolve_version
pkg_repository_resolve_artifact
```

---

## 4. Gli altri campi appartengono al repository type

Non viene introdotto un campo universale come:

```text
repo_path
```

per comprimere in una composite string coordinate che ecosistemi differenti rappresentano diversamente.

Dopo aver letto `repository/type`, è l'adapter selezionato a definire e validare i propri campi repository-specific.

Quindi:

```text
core pkg
    conosce il campo comune type

repository adapter
    conosce i campi specifici del proprio type
```

Ogni adapter deve distinguere almeno:

```text
campi obbligatori
campi opzionali
campi sconosciuti
valori non validi
```

Un campo obbligatorio mancante è errore.

Un campo presente ma non previsto dal contratto dell'adapter è errore, così che typo e descriptor incompatibili non vengano ignorati silenziosamente.

La serializzazione concreta dei campi di `github`, `sourceforge`, `maven` e dei futuri type viene fissata insieme al rispettivo adapter, senza modificare il formato generico dei file scalari.

---

## 5. Il repository descriptor non viene mai eseguito

Nessun file sotto `repository/` viene:

```text
source
eval
eseguito
interpretato come shell
interpretato come assegnazione env
usato per command substitution
```

Forme come:

```sh
. repository
source repository
eval "$(cat repository/...)"
```

non appartengono al modello.

Analogamente non si definisce il formato come un file `key=value` da interrogare con una serie di `grep` indipendenti.

La directory di file scalari elimina la necessità di un parser env/config generale: ogni valore viene letto come dato dal relativo file e validato dal consumer che ne possiede il contratto.

Questo preserva il confine fra:

```text
pkg-catalog
    dati/versioni concrete delle package definition

rumiai-os
    codice fidato degli adapter e del package manager
```

I file che altri contratti package hanno già definito esplicitamente come shell code, come `env` o i command entry quando applicabile, mantengono il loro contratto separato e non rendono eseguibile `repository/`.

---

## 6. Repository type standard e type product-specific

La baseline riconosce repository type per ecosistemi con un contratto comune reale, inizialmente inclusi:

```text
github
sourceforge
maven
```

Non viene implementato né riservato come type corrente:

```text
custom
```

e non appartiene al baseline la libreria:

```text
lib/sh/pkg-repository-custom.lib.sh
```

Quando un prodotto usa un sistema upstream che non aderisce a un repository type comune già supportato, si introduce un **repository type dedicato a quel prodotto** e il relativo adapter:

```text
repository/type
    -> <product-specific-type>

lib/sh/pkg-repository-<product-specific-type>.lib.sh
```

Un adapter product-specific può essere deliberatamente monoproduct. Non deve essere forzato dentro una pseudo-astrazione generica se non condivide realmente protocollo, discovery, naming o resolution con altri prodotti.

L'esatto nome del type product-specific viene deciso quando il prodotto concreto viene aggiunto e non viene anticipato da questa decisione.

Se in futuro l'esperienza con più prodotti mostra un contratto realmente comune e stabile, potrà essere introdotto un repository type condiviso mediante decisione esplicita. Solo in quel momento potrà essere valutato anche un concetto `custom` o un nome più appropriato; oggi `custom` non è un repository type RumiAI corrente.

---

## 7. `archive_regex`, `digest_regex` e `digest_type` sono range-level

I dati semanticamente indicati come:

```text
archive_regex
digest_regex
digest_type
```

non appartengono a `repository/`.

Appartengono alla package definition del range:

```text
nNNNN=<version-minimum>/
```

perché selezione/naming dell'artifact e modalità di integrity discovery possono cambiare fra intervalli di release anche quando il repository upstream corrente rimane lo stesso.

Quindi la separazione è:

```text
repository/
    dove e tramite quale repository type interrogare l'upstream corrente

nNNNN=<version-minimum>/
    come selezionare/materializzare/verificare le release di quel range
```

Questa decisione fissa la **collocazione semantica** di `archive_regex`, `digest_regex` e `digest_type`, ma non ne fissa ancora:

```text
pathname fisico definitivo nella range definition
obbligatorietà
sintassi regex concreta
insieme dei digest type accettati
relazioni fra i tre campi
```

Tali aspetti appartengono al prossimo contratto di serializzazione della range definition.

---

## 8. Relazione con `pkg_repository_resolve_artifact`

`pkg_repository_resolve_artifact` continua a ricevere semanticamente due classi di informazioni distinte:

```text
repository corrente dello stream
package definition del range selezionato
```

Il repository descriptor fornisce coordinate e contesto dell'upstream corrente.

La range definition fornisce le regole che possono cambiare fra versioni, incluse artifact selection e integrity/provenance.

Il fatto che un adapter sia product-specific non sposta artifact regex, digest policy o materialization dentro `repository/`.

---

## 9. Relazione con il catalogo concreto

Il repository concreto delle package definition resta:

```text
massimilianonardi-ai/pkg-catalog
```

Alla data di questa decisione è ancora vuoto e non possiede commit/HEAD.

Questa decisione non lo inizializza: prima del primo package concreto resta ancora da chiudere la serializzazione della range definition e il primo adapter necessario.

Quando verrà materializzato un package, `repository/` dovrà rispettare il contratto qui fissato.

---

## 10. Supersession e correzioni

Questa decisione supersede le precedenti formulazioni che lasciavano completamente aperta la serializzazione di `<stream>/repository` oppure lo rappresentavano come possibile file singolo.

D'ora in poi la forma fisica corrente è:

```text
<stream>/repository/
```

con file scalari dichiarativi.

Sono inoltre superseded le formulazioni della pipeline che includevano `custom` fra i repository type baseline o mostravano:

```text
lib/sh/pkg-repository-custom.lib.sh
```

come adapter canonico corrente.

Restano invariati:

```text
un solo repository upstream corrente per stream
repository corrente distinto dalla range definition
adapter caricati in contesto shell isolato
le tre API repository correnti
nessun repository storico fallback
range resolution posizionale
nessun comparatore universale delle versioni upstream
```

---

## 11. Implementazione e testing futuro

Alla data di questa decisione non esiste ancora implementazione prodotto del catalogo/repository adapter e non esistono test permanenti `pkg` corrispondenti.

Quando implementato, i test dovranno proteggere almeno:

```text
repository è directory e non file
repository/type obbligatorio
campi repository come regular file scalari non eseguibili
un solo valore non vuoto terminato da LF
assenza di source/eval del descriptor
selezione adapter da repository/type
campi obbligatori mancanti -> errore
campi sconosciuti -> errore
type standard supportati secondo adapter presenti
assenza di custom nel baseline
supporto a type product-specific quando concretamente introdotti
archive/digest selection non collocata nel repository descriptor
```

Questa decisione è documentale e non richiede physical validation separata.

---

## 12. Invarianti fissati

```text
PKG-REPOSITORY-DESC-01  ogni stream disponibile contiene la directory repository/
PKG-REPOSITORY-DESC-02  repository/ è dato dichiarativo e non codice eseguibile
PKG-REPOSITORY-DESC-03  i campi sono regular file scalari non eseguibili direttamente sotto repository/
PKG-REPOSITORY-DESC-04  ogni campo contiene un solo valore non vuoto su una riga terminata LF; niente CR, NUL o righe aggiuntive
PKG-REPOSITORY-DESC-05  repository/type è l'unico campo comune obbligatorio
PKG-REPOSITORY-DESC-06  repository/type seleziona lib/sh/pkg-repository-<type>.lib.sh
PKG-REPOSITORY-DESC-07  il core pkg non impone repo_path o altre composite coordinate universali
PKG-REPOSITORY-DESC-08  ogni adapter definisce e valida i propri campi obbligatori/opzionali; campi sconosciuti sono errore
PKG-REPOSITORY-DESC-09  repository/ non viene source, eval o interpretato come env/shell
PKG-REPOSITORY-DESC-10  i repository type comuni iniziali includono github, sourceforge e maven
PKG-REPOSITORY-DESC-11  custom non è un repository type corrente e pkg-repository-custom.lib.sh non appartiene al baseline
PKG-REPOSITORY-DESC-12  un upstream non standard usa un type e adapter product-specific dedicato quando necessario
PKG-REPOSITORY-DESC-13  un type condiviso ulteriore nasce solo da un contratto comune concreto già osservato
PKG-REPOSITORY-DESC-14  archive_regex, digest_regex e digest_type appartengono semanticamente alla range definition e non a repository/
PKG-REPOSITORY-DESC-15  la serializzazione fisica completa della range definition resta il prossimo contratto
```
