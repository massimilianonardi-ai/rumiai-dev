# Decisione — Orchestrazione `pkg install` e snapshot operativo di `pkg-catalog`

Date: 2026-09-09  
Status: **Accepted**

## Contesto

La pipeline package corrente ha già separato e implementato i layer:

```text
repository adapter
pkg_download
pkg_extract
pkg_integrate / pkg_deintegrate / pkg_default
```

ed ha fissato che:

```text
pkg_integrate
    materializza la disponibilità di una concrete version
    non modifica current
    non crea binding pubblici

pkg_default
    è l'unico layer corrente che seleziona/rimuove il default
    gestisce current e bin/ext*
```

Il passo successivo del piano è l'orchestrazione reale:

```text
pkg install <package> [<package> ...]
```

Prima di tale orchestrazione restavano da chiudere clone/fetch/offline/failure/locking/pinning della working copy Git del catalogo, perché ogni operazione catalog-dependent deve usare un solo snapshot coerente.

L'utente ha autorizzato esplicitamente questa fase di implementazione con l'istruzione di procedere in autonomia. La dipendenza runtime da Git necessaria al confine catalogo già fissato viene quindi documentata qui come eccezione specifica al baseline POSIX, non come rilassamento generale delle regole RumiAI.

---

## 1. File e responsabilità

Il comando pubblico è:

```text
bin/sys/pkg
```

Il comando resta sottile e delega l'orchestrazione install a:

```text
lib/sh/pkg-install.lib.sh
```

La libreria espone:

```text
pkg_install <package> [<package> ...]
```

Non viene introdotto in questa fase un comando pubblico separato di gestione del catalogo. Il refresh/snapshot è una responsabilità interna dell'operazione `install`, perché è l'unico consumer corrente che la richiede.

`pkg uninstall` resta il passo lifecycle successivo e non acquisisce accidentalmente semantica in questa decisione.

---

## 2. CLI implementata in questa fase

La forma pubblica implementata è:

```text
pkg install <package> [<package> ...]
```

Ogni operand conserva esattamente la grammatica già fissata:

```text
<pkg>
<pkg>@<version>
<pkg>!<osarch>
<pkg>@<version>!<osarch>
```

Semantica:

```text
<pkg>
    latest upstream, target corrente

<pkg>@<version>
    versione upstream esatta, target corrente

<pkg>!<osarch>
    latest upstream, target esplicito

<pkg>@<version>!<osarch>
    versione upstream esatta, target esplicito
```

Exit status del comando per questa superficie:

```text
0  install completato per tutti gli operand
1  failure operativa/semantica durante l'installazione
2  invocazione, subcommand o operand lessicalmente invalido
```

Subcommand non ancora implementati, incluso `uninstall`, producono status `2` e non acquisiscono un comportamento parziale implicito.

---

## 3. Prevalidazione e multi-package invocation

Prima di consultare o modificare la cache del catalogo, `pkg_install` valida lessicalmente tutti gli operand ricevuti.

Se un operand è lessicalmente invalido:

```text
nessun refresh catalogo
nessun download
nessuna integrazione
status 2
```

Dopo la creazione dello snapshot, gli operand vengono processati sequenzialmente nell'ordine ricevuto.

Il baseline corrente usa:

```text
stop on first failure
nessuna transazione globale multi-package
nessun rollback delle concrete version integrate con successo prima del failure
```

Questo non introduce generations, journal o inventory obbligatoria.

Una concrete identity già presente non viene sovrascritta, riparata o reinstallata implicitamente: la collision policy di `pkg_integrate` resta autorevole.

---

## 4. `install` produce disponibilità, non default

Il termine della pipeline di un singolo operand è:

```text
pkg_integrate
```

`pkg install` **non** chiama automaticamente:

```text
pkg_default
```

Quindi una installazione riuscita rende disponibile la concrete version ma non modifica:

```text
current
bin/ext/
bin/ext-<osarch>/
```

La selezione o rimozione del default resta una responsabilità esplicita e separata di `pkg_default`.

---

## 5. Target e selezione dello stream

Per ogni operand:

```text
target esplicito
    -> usa l'<osarch> dell'operand

target omesso
    -> usa m_OSARCH del runtime corrente
```

Il vocabulary corrente accettato è:

```text
linux-arm64
linux-x86_64
macos-arm64
macos-x86_64
windows-arm64
windows-x86_64
```

Per target `T` la selezione resta:

```text
se <pkg>/catalog-T/ esiste
    -> usa esclusivamente catalog-T
altrimenti se <pkg>/catalog/ esiste
    -> usa catalog
altrimenti
    -> failure
```

Non esiste merge o fallback per-versione.

La qualificazione della concrete identity deriva dallo stream realmente selezionato:

```text
catalog
    -> <pkg>@<version>

catalog-<osarch>
    -> <pkg>@<version>!<osarch>
```

Specificare un target nella CLI non forza quindi `!<osarch>` quando il package usa il fallback generic `catalog`.

---

## 6. Validazione strutturale dello stream e dei range

Lo stream selezionato deve contenere esclusivamente:

```text
repository/
nNNNN=<version-minimum>/
...
```

`repository/` deve essere una real directory.

I range devono essere real directory con ordinali:

```text
n0001
n0002
...
```

contigui e ordinati. `<version-minimum>` usa la grammatica upstream già fissata:

```text
[A-Za-z0-9][A-Za-z0-9._+~-]*
```

Un oggetto stream sconosciuto, un symlink al posto delle directory strutturali o una sequenza di ordinali non contigua rende lo stream invalido.

`repository/type` continua a essere uno scalar dichiarativo. Seleziona esclusivamente una libreria RumiAI fidata già installata:

```text
lib/sh/pkg-repository-<type>.lib.sh
```

La libreria deve essere regular, readable, non executable e non symlink.

Il descriptor del catalogo non viene source o eval.

---

## 7. Isolamento dei repository adapter

Ogni invocazione di una API repository viene eseguita in un subshell che carica soltanto l'adapter selezionato.

Le API restano:

```text
pkg_repository_list_versions <repository-dir>
pkg_repository_resolve_version <repository-dir> [<version>]
pkg_repository_resolve_artifact <repository-dir> <range-dir> <version>
```

Adapter differenti non vengono sourced simultaneamente nello stesso contesto persistente.

---

## 8. Resolution di versione e range

Per semplicità e validazione forte, il primo orchestratore può chiamare `pkg_repository_list_versions` anche per `latest`.

Questo non modifica il contratto precedente, che consentiva l'ottimizzazione di evitare tale enumerazione ma non la rendeva obbligatoria.

La successione deve essere:

```text
non vuota
oldest -> latest secondo l'adapter
una versione per riga
versioni conformi alla grammatica upstream
nessun duplicato
```

Per versione esplicita:

```text
pkg_repository_resolve_version <repository-dir> <version>
```

deve restituire esattamente la versione richiesta.

Per versione omessa:

```text
pkg_repository_resolve_version <repository-dir>
```

deve restituire esattamente l'ultima versione della successione corrente.

La scelta del range usa esclusivamente le posizioni della versione richiesta e degli anchor nella successione.

Ogni anchor deve comparire esattamente una volta e le sue posizioni devono essere strettamente crescenti nello stesso ordine degli ordinali `nNNNN`.

Il core non usa SemVer, confronto lessicografico, numerico, date o pattern package-specific per ordinare le versioni.

---

## 9. Pipeline di un singolo operand

Dopo la resolution:

```text
pkg_repository_resolve_artifact
    -> descriptor repository-neutral

pkg_download
    -> artifact locale verificato

read range/format

pkg_extract
    -> useful root normalizzata

pkg_integrate
    -> concrete version disponibile
```

Ogni layer conserva il proprio contratto e non assorbe responsabilità dei layer adiacenti.

---

## 10. Working area dell'operazione

L'orchestrazione usa una working area transiente sotto:

```text
$m_TMP_DIR/sys/pkg/install-$$/
```

con `umask 077` e cleanup tramite trap.

Lo snapshot del catalogo e gli staging per i singoli operand appartengono a questa working area.

Quando `pkg_integrate` riesce, la useful root viene consumata nel package store secondo il contratto del layer di integrazione; il restante materiale transiente viene eliminato al termine dell'invocazione.

---

## 11. Cache Git canonica del catalogo

La working copy persistente resta:

```text
$m_CACHE_DIR/sys/pkg/pkg-catalog/
```

Remote canonico:

```text
https://github.com/massimilianonardi-ai/pkg-catalog.git
```

Branch canonica corrente:

```text
main
```

Il remote e la branch sono dati del prodotto per il catalogo canonico corrente e non vengono ottenuti da package definition.

---

## 12. Eccezione runtime Git

`pkg install` richiede il comando host:

```text
git
```

Questa è un'eccezione implementation-specific documentata al baseline POSIX.

Ragione tecnica concreta:

```text
- la fonte autorevole delle package definition è già fissata come repository Git;
- il commit Git è già fissato come identità dello snapshot;
- il requisito operativo include clone/fetch, verifica ancestry fast-forward e materializzazione di uno snapshot esatto;
- usare Git direttamente implementa tali semantiche senza inventare un secondo protocollo, formato di history o sistema di snapshot RumiAI.
```

L'autorizzazione alla presente fase di implementazione è stata data esplicitamente dall'utente con l'istruzione di procedere in autonomia.

Questa eccezione è limitata al boundary Git del catalogo e non autorizza dipendenze non-POSIX arbitrarie in altri componenti.

---

## 13. Lock della working copy

Il lock canonico è una directory:

```text
$m_RUN_DIR/sys/pkg/pkg-catalog.lock/
```

La creazione atomica tramite `mkdir` acquisisce il lock.

La directory contiene soltanto:

```text
pid
```

come scalar con il PID del processo proprietario.

Se il lock esiste:

```text
PID vivo
    -> failure

PID non più vivo e shape esattamente riconosciuta
    -> stale lock reclamabile

shape malformata, symlink o oggetti sconosciuti
    -> failure senza cleanup distruttivo
```

Un possibile riuso host del PID può produrre un conservativo failure, non una rimozione aggressiva del lock.

Il lock protegge esclusivamente refresh e creazione snapshot della cache `pkg-catalog`. Non è un lock globale del package store e non introduce una transazione multi-package.

---

## 14. Clone iniziale

Se la cache non esiste:

1. viene creato un clone temporaneo sibling della destination;
2. il clone usa esclusivamente remote canonico e branch `main`;
3. il clone viene validato;
4. solo dopo viene spostato nella destination canonica.

Failure del clone senza cache valida produce failure dell'operazione.

Non viene lasciata intenzionalmente una cache parziale come sorgente successiva.

---

## 15. Validazione della cache esistente

Una cache utilizzabile deve essere:

```text
real directory, non symlink
working tree Git con .git real directory
origin esattamente uguale al remote canonico
branch corrente esattamente main
working tree clean, inclusi untracked files
HEAD Git valido
```

Una cache dirty, con origin differente, branch differente o struttura non riconosciuta è errore.

La cache è rigenerabile per classificazione, ma il baseline non cancella automaticamente un oggetto invalido o estraneo per tentare una riparazione implicita.

---

## 16. Refresh fast-forward-only

Per una cache valida esistente:

```text
fetch origin main
```

Se il fetch riesce:

1. il vecchio HEAD locale deve essere ancestor del nuovo remote head;
2. l'aggiornamento avviene esclusivamente fast-forward;
3. il nuovo HEAD locale deve coincidere esattamente con il remote head ottenuto.

Non vengono eseguiti:

```text
reset distruttivo
rebase
merge commit
force update
accettazione automatica di history remota riscritta
```

Una divergenza dopo fetch riuscito è failure semantica e non autorizza fallback alla cache precedente.

---

## 17. Offline/fetch failure

Se una cache preesistente è valida ma il **fetch stesso** fallisce per indisponibilità della rete/remoto:

```text
warn
-> usa il HEAD cached già validato
```

Questa è la policy local-first corrente.

Il fallback è ammesso solo sul failure del tentativo di fetch. Non maschera:

```text
cache invalida
dirty working tree
origin errato
branch errata
divergenza/history rewrite osservata dopo fetch riuscito
snapshot failure
```

Se non esiste ancora una cache valida, offline/fetch failure non può produrre un catalogo e l'installazione fallisce.

---

## 18. Pinning dello snapshot per operazione

Mentre il lock è detenuto viene scelto un singolo HEAD Git e il suo tree viene materializzato nella working area dell'operazione tramite snapshot Git del commit esatto.

Lo snapshot operativo:

```text
contiene soltanto il tree tracked del commit
non contiene .git
è separato dalla working copy cache aggiornabile
viene usato da tutti gli operand della stessa invocazione
```

Dopo la materializzazione dello snapshot il lock può essere rilasciato.

Aggiornamenti successivi della cache non possono quindi cambiare le package definition osservate da una installazione già in corso.

Il commit Git emesso internamente dal boundary identifica lo snapshot usato dall'operazione; non viene introdotta una seconda numerazione RumiAI.

---

## 19. Hardening Git iniziale

Le invocazioni Git del boundary impostano esplicitamente almeno:

```text
http.sslVerify=true
core.hooksPath=/dev/null
core.fsmonitor=false
```

Quindi:

```text
la verifica TLS non può essere disabilitata accidentalmente da http.sslVerify=false dell'utente
hook della working copy non vengono eseguiti come parte del normale boundary
automazioni fsmonitor esterne non diventano requisito del catalogo
```

La configurazione host pertinente a CA, proxy e credenziali può restare disponibile a Git; non viene introdotto un trust store RumiAI separato.

Il baseline corrente non introduce firma obbligatoria dei commit/tags. Il primo clone accetta la history servita dal remote HTTPS canonico; i refresh successivi accettano soltanto discendenti fast-forward del HEAD già accettato.

---

## 20. Testing

I test permanenti del nuovo layer devono proteggere almeno:

```text
CLI pkg install e status per invocazioni invalide
prevalidazione di tutti gli operand prima del refresh
quattro forme operand
uso del target corrente o esplicito
precedenza catalog-<osarch> e fallback completo catalog
qualificazione concrete identity derivata dallo stream selezionato
ordinali range contigui
resolution posizionale senza comparatore versioni
coerenza exact/latest con list_versions
adapter isolato
pipeline resolve -> download -> extract -> integrate
install non modifica default/current/bin/ext*
stop on first failure senza rollback delle installazioni precedenti
clone iniziale del catalogo
validazione origin/branch/clean HEAD
refresh fast-forward
rifiuto divergenza
fallback al cached HEAD soltanto su fetch failure
lock e stale-lock conservativo
snapshot singolo per invocazione multi-package
assenza di .git nello snapshot operativo
```

I test permanenti usano fixture/local repositories quando verificano il protocollo Git, senza dipendere dalla disponibilità della rete pubblica.

La physical validation della revisione prodotto resta revision-specific e distinta dai development checks.

---

## 21. Limiti intenzionali della fase

Questa decisione non implementa né riapre:

```text
pkg uninstall
pkg version/current come CLI pubblica
selezione automatica default dopo install
facility/dependency resolution
provider index
State Instance avanzate
generations
inventory obbligatoria
migration framework
transazione/rollback globale multi-package
launcher
```

Il `launcher` già fissato architetturalmente resta ancora da implementare; quindi l'installazione/materializzazione di DBeaver non equivale ancora a validazione del launch end-to-end.

---

## 22. Invarianti fissati

```text
PKG-INSTALL-01  comando pubblico = bin/sys/pkg; l'orchestrazione install appartiene a lib/sh/pkg-install.lib.sh
PKG-INSTALL-02  API interna corrente = pkg_install <package> [<package> ...]
PKG-INSTALL-03  tutti gli operand vengono validati lessicalmente prima del refresh catalogo
PKG-INSTALL-04  multi-package procede nell'ordine ricevuto, stop al primo failure, senza rollback globale
PKG-INSTALL-05  pkg install termina con pkg_integrate e non chiama automaticamente pkg_default
PKG-INSTALL-06  install riuscito produce disponibilità della concrete version, non selezione default
PKG-INSTALL-07  target omesso usa m_OSARCH; target esplicito usa l'operand; entrambi devono appartenere al vocabulary canonico
PKG-INSTALL-08  stream target-specific ha precedenza completa sul generic; nessun merge/fallback per-versione
PKG-INSTALL-09  concrete identity generic/target-specific deriva dallo stream realmente selezionato
PKG-INSTALL-10  range nNNNN sono contigui e la membership viene risolta solo per posizione nella successione upstream
PKG-INSTALL-11  il primo orchestratore può enumerare list_versions anche per latest e ne verifica la coerenza col resolved latest
PKG-INSTALL-12  ogni chiamata repository API carica soltanto l'adapter selezionato in un subshell isolato
PKG-INSTALL-13  pipeline singola = resolve artifact -> pkg_download -> pkg_extract -> pkg_integrate
PKG-INSTALL-14  working area = $m_TMP_DIR/sys/pkg/install-$$ e viene ripulita salvo gli effetti persistenti già trasferiti ai layer di destinazione
PKG-CATALOG-SNAPSHOT-01  cache canonica = $m_CACHE_DIR/sys/pkg/pkg-catalog
PKG-CATALOG-SNAPSHOT-02  remote canonico = https://github.com/massimilianonardi-ai/pkg-catalog.git e branch corrente = main
PKG-CATALOG-SNAPSHOT-03  Git è una dipendenza runtime implementation-specific autorizzata esclusivamente per questo boundary e documentata come eccezione POSIX
PKG-CATALOG-SNAPSHOT-04  lock = $m_RUN_DIR/sys/pkg/pkg-catalog.lock come directory atomica con scalar pid
PKG-CATALOG-SNAPSHOT-05  cache invalida o estranea non viene cancellata/riparata implicitamente
PKG-CATALOG-SNAPSHOT-06  refresh riuscito accetta soltanto avanzamento fast-forward dal HEAD cached
PKG-CATALOG-SNAPSHOT-07  fetch failure può usare una cache preesistente ancora valida; failure semantici successivi a fetch riuscito non vengono mascherati
PKG-CATALOG-SNAPSHOT-08  ogni invocazione pkg install usa un solo tree snapshot del commit Git scelto
PKG-CATALOG-SNAPSHOT-09  snapshot operativo non contiene .git e resta immutabile rispetto a refresh successivi della cache
PKG-CATALOG-SNAPSHOT-10  il lock protegge cache refresh/snapshot, non introduce una transazione globale sul package store
PKG-CATALOG-SNAPSHOT-11  il boundary forza TLS verification e disabilita hook/fsmonitor locali per le proprie invocazioni Git
PKG-CATALOG-SNAPSHOT-12  nessuna firma Git obbligatoria o sistema di provenance aggiuntivo viene introdotto in questo baseline
```
