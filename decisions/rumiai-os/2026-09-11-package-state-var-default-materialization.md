# Decisione — Materializzazione package state, `var/` e factory `default/`

Date: 2026-09-11  
Status: **Accepted**

## Contesto

Il baseline package corrente ha già fissato:

```text
state non qualificato sotto $m_ROOT/<area>/<pkg>/
aree conf,data,home,cache,log,run,tmp
var/ come routing view package-local
root/<path> -> var/<area>/<path> per pathname upstream state-bearing
State Instance operative rinviate a una funzione successiva
uninstall != purge
```

La physical validation immediatamente precedente ha chiuso package `env` e resolved binding consumption. Il checkpoint corrente identifica quindi state/`var` come prossimo gap di integrazione da chiudere.

Restavano aperti, per il baseline non qualificato, la serializzazione dei mapping, la validazione degli overlap, l'inizializzazione dello state, la conservazione dei contenuti upstream sostituiti, il layout operativo di `default/` e il rollback proporzionato.

L'utente ha approvato esplicitamente il 2026-09-11 la soluzione definita in questo documento e ha autorizzato la relativa fase di implementazione in `rumiai-os`.

Questa decisione non introduce un nuovo nome di fase, non introduce State Instance operative e non modifica la distinzione già fissata fra routing via environment e routing via `var/`.

---

## 1. Scope

Questa unità chiude esclusivamente il baseline dello state package **non qualificato** per package che necessitano di routing statico tramite `var/`.

La destinazione fisica resta:

```text
$m_ROOT/<area>/<pkg>/
```

con `<area>` appartenente esattamente a:

```text
conf
data
home
cache
log
run
tmp
```

Restano fuori scope:

```text
State Instance nominate operative
state switching runtime o persistente
state compatibility policy fra versioni
migration
purge
factory-reset CLI
backup/retention
transaction/recovery engine generale
```

---

## 2. Serializzazione del mapping nel range

Una range definition che necessita di normalizzare pathname upstream state-bearing usa la directory opzionale:

```text
var/
```

Nel **catalogo/range**, `var/` è metadata dichiarativo e non è il routing view materializzato del concrete package.

Può contenere esclusivamente file con nome:

```text
conf
data
home
cache
log
run
tmp
```

Ogni file presente associa all'area omonima uno o più pathname root-relative, uno per riga.

Esempio:

```text
var/conf
    etc/tool/config
    settings/user.ini

var/data
    workspace
```

La directory `var/` non viene materializzata quando nessun mapping è necessario.

---

## 3. Formato dei file `var/<area>` nel range

Ogni `var/<area>` del range è:

```text
regular file
non symbolic link
readable
non executable
non vuoto
```

La serializzazione è line-oriented:

```text
<root-relative-path><LF>
[<root-relative-path><LF> ...]
```

Regole:

```text
una pathname per riga
LF finale obbligatorio
nessuna riga vuota
nessun commento
nessun quoting
nessun escaping
nessun prefisso/suffisso semantico aggiuntivo
```

Il contenuto della riga è il pathname upstream letterale nel dominio rappresentabile da questa serializzazione.

Poiché LF è il separatore record, un pathname contenente LF non è rappresentabile e non appartiene a questo formato.

Tab, spazi, leading `-` e altri caratteri validi nel pathname upstream non acquisiscono semantica speciale e vengono trattati come dati.

---

## 4. Validazione della pathname dichiarata

Una pathname dichiarata deve essere:

```text
relativa a root/
non vuota
senza slash iniziale
senza slash finale
senza componenti vuote
senza componenti . o ..
```

Quindi sono invalidi, per esempio:

```text
/etc/tool
etc/tool/
etc//tool
./etc
etc/../tool
```

I componenti appartengono al namespace upstream/external-data e non vengono forzati nella naming convention dei nomi RumiAI-controlled.

`pkg_integrate` non deve lowercase, rinominare, trim o normalizzare semanticamente tali componenti.

---

## 5. Oggetto upstream dichiarabile

Prima di ogni mutazione installata, ogni pathname dichiarata deve già esistere nella useful root consegnata da `pkg_extract`.

Il final object può essere esclusivamente:

```text
regular file
physical directory
```

Il final object non può essere un symbolic link o uno special file.

Ogni componente ancestor fra `root/` e il final object deve essere una physical directory e non un symbolic link.

Questa regola evita di normalizzare attraverso alias o traversal non fisicamente appartenenti al pathname upstream dichiarato.

---

## 6. Duplicati e overlap

L'insieme dei mapping è globale all'intera range definition, non separato per area.

Sono invalidi:

```text
lo stesso pathname dichiarato più di una volta
lo stesso pathname dichiarato in aree differenti
un pathname ancestor di un altro mapping
un pathname descendant di un altro mapping
```

Esempio invalido:

```text
conf: etc
data: etc/tool/workspace
```

Non viene definita una precedenza fra mapping sovrapposti: l'intera package definition è rifiutata prima della pubblicazione della concrete version.

---

## 7. Interazione con direct-link command

Nel baseline direct-link corrente, un executable dichiarato da:

```text
link/<pkg-command>
```

non può risolvere dentro un pathname dichiarato state-bearing.

Dopo la normalizzazione, un target di questo tipo risolverebbe attraverso `root/ -> var/` fuori dal concrete `root/`, mentre il launcher direct-link richiede che il target executable risolva nel `root/` della stessa concrete version.

La collisione viene quindi rifiutata durante la validazione, prima di mutazioni installate.

La verifica considera la destinazione fisicamente risolta del direct-link, così anche un alias symlink upstream verso un subtree state-bearing non aggira il controllo.

---

## 8. Namespace `sys`

La decisione Accepted sul namespace state del sistema base riserva:

```text
$m_ROOT/<area>/sys/
```

ai componenti base RumiAI.

Di conseguenza una package integration che dichiara mapping `var/` non può usare `sys` come `<pkg>`, perché produrrebbe state package nel namespace riservato del sistema base.

Questa decisione non introduce qui una nuova grammatica generale dei package name al di fuori del dominio state materializzato.

---

## 9. Prevalidazione dello state esistente

Per ogni area usata, la semantic root deve essere esattamente quella già fornita dal bootstrap:

```text
m_CONF_DIR  = $m_ROOT/conf
m_DATA_DIR  = $m_ROOT/data
m_HOME_DIR  = $m_ROOT/home
m_CACHE_DIR = $m_ROOT/cache
m_LOG_DIR   = $m_ROOT/log
m_RUN_DIR   = $m_ROOT/run
m_TMP_DIR   = $m_ROOT/tmp
```

La root usata deve esistere come physical directory e non come symbolic link.

Se esiste già:

```text
$m_ROOT/<area>/<pkg>/
```

deve essere una physical directory.

Per la pathname specifica già esistente:

```text
$m_ROOT/<area>/<pkg>/<path>
```

valgono inoltre:

```text
nessun ancestor state può essere symbolic link
il final object non può essere symbolic link
il final object deve avere la stessa classe file/directory dell'oggetto factory upstream
```

Un oggetto state preesistente incompatibile è corruption/failure e non viene sostituito, riparato o reinterpretato automaticamente.

---

## 10. `default/` derivato dai mapping

Per ogni pathname normalizzato, il concrete package conserva obbligatoriamente l'oggetto upstream originario sotto:

```text
<concrete>/default/<area>/<root-relative-path>
```

Esempio:

```text
root/etc/tool/config
    -> normalizzato come state conf

default/conf/etc/tool/config
    = oggetto factory originario della versione concreta
```

L'oggetto viene trasferito dal useful root al subtree `default/` prima di sostituire la pathname sotto `root/` con il symlink di routing.

Quindi, per questa unità:

```text
ogni mapping var ha un counterpart factory sotto default/
default/ è materializzato solo quando esiste almeno un mapping var
```

Il range non acquisisce in questa unità una top-level entry dichiarativa `default/` separata. Un eventuale factory state non derivato da un pathname upstream normalizzato richiede un contratto successivo.

---

## 11. Inizializzazione e riuso dello state

Dopo aver conservato il factory object in `default/`:

```text
se $m_ROOT/<area>/<pkg>/<path> non esiste
    -> viene inizializzato copiando il factory object

se $m_ROOT/<area>/<pkg>/<path> esiste già ed è valido
    -> viene lasciato invariato come state corrente
    -> non viene sovrascritto
    -> non viene merged col nuovo factory object
```

In particolare, installare una nuova concrete version può produrre:

```text
<new-concrete>/default/<area>/<path> = factory state della nuova versione
$m_ROOT/<area>/<pkg>/<path>          = state utente/runtime preesistente invariato
```

Questo è coerente con il baseline corrente, che usa soltanto lo state non qualificato e ha rinviato State Instance, compatibility policy e migration.

Nessuna nuova policy generale di ownership/mode viene introdotta qui; l'inizializzazione conserva il contenuto/tree necessario senza promuovere questa unità a framework di metadata filesystem.

---

## 12. Materializzazione di `var/<area>`

Nel concrete package, per ogni area effettivamente usata viene creato:

```text
<concrete>/var/<area>
```

come symbolic link relativo verso:

```text
$m_ROOT/<area>/<pkg>/
```

Poiché `<concrete>` vive direttamente sotto `$m_ROOT/pkg/`, il target testuale baseline è:

```text
../../../<area>/<pkg>
```

Esempio:

```text
pkg/example@1/var/conf -> ../../../conf/example
```

`var/` resta routing view e non contiene backing state.

Non viene creato `$m_ROOT/var/`.

---

## 13. Normalizzazione di `root/<path>`

Dopo factory preservation e state initialization/reuse, la pathname originale sotto `root/` viene sostituita da un symbolic link relativo verso:

```text
<concrete>/var/<area>/<root-relative-path>
```

Il target testuale contiene il numero di `../` necessario in base alla profondità del pathname.

Esempi:

```text
root/workspace
    -> ../var/data/workspace

root/etc/tool/config
    -> ../../../var/conf/etc/tool/config
```

La catena finale resta:

```text
root/<path>
    -> var/<area>/<path>
        -> $m_ROOT/<area>/<pkg>/<path>
```

Tutti i symlink materializzati dal package manager per questo routing sono relativi e restano relocatable insieme a `$m_ROOT`.

---

## 14. Ordine nel lifecycle di integrazione

La validazione di `var/`, mapping, source object e state preesistente avviene prima della mutazione della concrete package installata.

La materializzazione dello state avviene dopo che root e gli altri oggetti concrete già risolti sono stati preparati e **prima** della pubblicazione dei provider marker della concrete version.

Quindi una concrete version non diventa provider disponibile prima che il proprio routing state/default sia materializzato con successo.

La presenza di `var/` non modifica dependency resolution né provider ranking.

---

## 15. Rollback degli errori sincroni

Il baseline non introduce generations, journal, locking globale o crash/power-loss recovery.

Per failure rilevate sincronicamente durante la singola `pkg_integrate`, vale però ownership proporzionata delle mutazioni effettuate dalla stessa operazione:

```text
state preesistente
    -> non appartiene al rollback e non viene modificato/rimosso

state object creato dalla stessa integrazione
    -> appartiene al rollback e viene rimosso se la integrazione fallisce

factory object spostato in default/
    -> viene ripristinato nel root staging quando la concrete integration deve essere ritirata

directory state parent create dalla stessa integrazione
    -> vengono rimosse quando tornano vuote
```

Un errore di rollback/filesystem resta failure operativa; questa decisione non promette recovery da crash, power loss o mutazioni concorrenti.

---

## 16. Deintegration e uninstall

`pkg_deintegrate` continua a rimuovere la concrete package version e quindi anche i suoi:

```text
default/
var/
root/
```

ma non elimina automaticamente backing state sotto:

```text
$m_ROOT/<area>/<pkg>/
```

`pkg uninstall` continua quindi a essere distinto da un futuro `purge`.

La rimozione di una concrete version non ripristina factory defaults, non effettua merge e non cancella state esterno al concrete package.

---

## 17. DBeaver resta invariato

La package definition DBeaver corrente ha già fissato che il suo state necessario viene indirizzato tramite launch arguments/environment e che il range corrente non richiede un mapping `root/ -> var/`.

Questa unità non modifica DBeaver e non aggiunge artificialmente `var/` o `default/` alla sua definizione.

Il primo test permanente del nuovo contratto usa quindi un fixture sintetico che possiede realmente pathname upstream state-bearing.

---

## 18. Testing richiesto

I test permanenti devono proteggere almeno:

```text
var/ assente -> nessun var/default artificiale
sette soli nomi area ammessi
file metadata regular/readable/non-executable/non-symlink
file area non vuoto e LF finale obbligatorio
pathname relative e componenti . .. / vuote rifiutate
pathname external-data con spazi/leading - preservate
source final solo regular file o physical directory
source ancestor symlink rifiutato
special file rifiutato
duplicati e overlap ancestor/descendant globali rifiutati
direct-link executable dentro mapped state rifiutato
sys rifiutato come package state namespace
var/<area> relativo verso semantic root
root/<path> relativo verso var/<area>/<path>
catena root -> var -> state effettiva
factory object conservato sotto default/<area>/<path>
primo install inizializza state dal factory object
versione successiva preserva state esistente e conserva il nuovo factory object separatamente
state incompatibile preesistente rifiutato senza modifica
assenza di $m_ROOT/var
pkg_deintegrate/uninstall preservano state esterno
rollback rimuove state creato dall'integrazione fallita e ripristina useful root
regressione package esistente invariata
```

La modifica prodotto e la relativa suite richiedono physical validation revision-specific sui reference host correnti prima di essere dichiarate fisicamente validate.

---

## 19. Invarianti fissati

```text
PKG-STATE-MAT-01  range/var è il metadata dichiarativo opzionale dei mapping root-relative -> state area
PKG-STATE-MAT-02  dentro range/var sono ammessi esclusivamente conf,data,home,cache,log,run,tmp
PKG-STATE-MAT-03  ogni var/<area> di range è un regular readable non-executable non-symlink file non vuoto, line-oriented e con LF finale
PKG-STATE-MAT-04  le righe var/<area> sono pathname upstream letterali relative, senza empty component, . o ..; LF non è rappresentabile
PKG-STATE-MAT-05  i pathname upstream non acquisiscono la naming convention dei nomi RumiAI-controlled
PKG-STATE-MAT-06  il source final dichiarato è regular file o physical directory e tutti gli ancestor dichiarati sono physical directory
PKG-STATE-MAT-07  duplicati e overlap ancestor/descendant fra mapping sono vietati globalmente
PKG-STATE-MAT-08  un direct-link executable non può risolvere dentro un pathname state-bearing normalizzato
PKG-STATE-MAT-09  sys resta riservato al system-base state e non può essere usato come package state namespace da una integration con var/
PKG-STATE-MAT-10  state preesistente deve avere parent fisici e type file/directory compatibile; non viene riparato o sovrascritto
PKG-STATE-MAT-11  ogni pathname normalizzato conserva il factory object sotto <concrete>/default/<area>/<path>
PKG-STATE-MAT-12  default/ è derivato dai mapping var in questa unità; range/default separato non viene introdotto
PKG-STATE-MAT-13  state assente viene inizializzato dal factory object; state valido già esistente viene preservato senza overwrite o merge
PKG-STATE-MAT-14  concrete var/<area> è un symlink relativo verso ../../../<area>/<pkg>
PKG-STATE-MAT-15  concrete root/<path> diventa un symlink relativo verso var/<area>/<path>
PKG-STATE-MAT-16  non viene creato alcun $m_ROOT/var
PKG-STATE-MAT-17  state/default routing è materializzato prima della pubblicazione provider della concrete version
PKG-STATE-MAT-18  rollback sincrono rimuove solo state creato dalla stessa integrazione e non modifica state preesistente
PKG-STATE-MAT-19  deintegration/uninstall rimuovono il concrete package ma preservano backing state esterno
PKG-STATE-MAT-20  State Instance operative, migration, purge, reset CLI e transaction/recovery framework generale restano fuori scope
PKG-STATE-MAT-21  DBeaver corrente resta senza var/default perché il suo state è già indirizzato dal launch contract fissato
```
