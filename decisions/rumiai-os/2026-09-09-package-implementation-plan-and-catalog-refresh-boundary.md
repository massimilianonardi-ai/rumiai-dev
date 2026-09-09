# Decisione — Sequenza di implementazione `pkg` e confine di refresh del catalogo

Date: 2026-09-09  
Updated: 2026-09-09  
Status: **Accepted**

## Contesto

La pipeline corrente di `pkg` separa già:

```text
catalog lookup
repository-specific discovery/resolution
generic download
generic raw extract
package materialization/useful-root normalization
RumiAI package integration
```

Sono inoltre già fissati:

- il repository concreto `massimilianonardi-ai/pkg-catalog`;
- la cache locale rigenerabile `$m_ROOT/cache/sys/pkg/pkg-catalog/`;
- il primo repository adapter GitHub e il relativo transport `http-fetch`;
- le utility di sistema general-purpose `digest` ed `extract`, che confinano i backend host non uniformi usati rispettivamente per digest ed estrazione;
- la CLI pubblica `pkg install <package> [<package> ...]` e `pkg uninstall <package> [<package> ...]`;
- `pkg uninstall` come operazione local-only;
- il principio local-first di RumiAI.

Le correzioni esplicite dell'utente del 2026-09-09 fissano inoltre che:

```text
pkg_extract
    deve consegnare direttamente la useful root normalizzata
    deve scoprire strutturalmente i wrapper da eliminare
    non deve ricevere pathname/version-specific di normalizzazione dal catalogo
    materializza nella destination ricevuta come terzo argomento
    non sceglie né deriva autonomamente $m_ROOT/pkg

pkg-analyze <format> <artifact>
    deve continuare a usare pkg_extract
    deve scegliere una propria destination temporanea da passare a pkg_extract
    deve quindi analizzare esattamente il tree normalizzato che arriverebbe a pkg_integrate
```

Il nome pubblico del comando diagnostico è `pkg-analyze`; la precedente spelling `pkg_analyze` è superseded e non viene mantenuta come alias.

Questo evita che wrapper interni come `<product>-<version>/` trasformino ogni release in un nuovo range e preserva la semantica di `latest` dell'ultimo range.

L'analisi DBeaver e la prima package definition utilizzabile dal futuro layer di integrazione sono ora consolidate da:

```text
decisions/rumiai-os/2026-09-09-dbeaver-package-integration-definition.md
massimilianonardi-ai/pkg-catalog@8727740aca09e98afa02e1b81859886c3061bc1e
```

Per DBeaver sono fissati in particolare:

```text
-configuration -> $m_CONF_DIR/dbeaver/configuration
-data          -> $m_HOME_DIR/dbeaver/.workspace
```

La range definition usa inoltre `format`, `cmd/<pkg-command>` e, per i command direct-link, `link/<pkg-command>` secondo la serializzazione minima fissata dalla decisione DBeaver. Gli stream Linux e macOS possiedono ora la definizione di launch necessaria all'integrazione; lo stream Windows x86_64 conserva `format=zip` ma non dichiara ancora `cmd/link`, in attesa della verifica del bridge pathname fra ambiente POSIX-compatible e processo Windows nativo.

---

## 1. Confine di refresh

Ogni operazione `pkg` che deve consultare package definition o interrogare un upstream attraverso una package definition deve iniziare da una fase di refresh/sincronizzazione della cache locale `pkg-catalog` prima della resolution.

Appartiene certamente a questa classe:

```text
pkg install
```

ed eventualmente vi apparterranno future operazioni che richiedano esplicitamente package definition correnti o discovery upstream.

Il refresh non viene invece introdotto come precondizione artificiale per operazioni che possono essere risolte interamente dallo stato locale già materializzato.

Restano quindi local-only e non richiedono refresh del catalogo, salvo futura decisione che introduca una responsabilità remota concreta:

```text
pkg uninstall
pkg_deintegrate
launch di un package già installato tramite pkg run, quando non richiede discovery remota
future operazioni di selezione locale di una versione già installata
```

In particolare il semplice avvio di software già installato non deve acquisire una dipendenza di rete soltanto perché il package è stato originariamente installato da `pkg`.

---

## 2. Snapshot coerente per operazione

Dopo la fase di refresh, una singola operazione che consuma il catalogo deve usare un unico snapshot Git del catalogo.

Il commit Git della working copy identifica naturalmente tale snapshot.

Durante la stessa operazione non devono essere mescolate package definition provenienti da commit differenti del catalogo, inclusa un'invocazione multi-package.

Il meccanismo concreto con cui lo snapshot viene pinning/isolato rispetto ad aggiornamenti concorrenti resta da fissare insieme al locking della working copy.

---

## 3. Refresh non equivale ancora a una specifica Git

Questa decisione non trasforma `git pull` o un altro comando Git in una API RumiAI.

Restano da chiudere prima dell'orchestrazione completa di `pkg install`:

```text
clone iniziale
fetch/update successivi
origine remota attesa e sua validazione
policy su fast-forward/divergenze
comportamento offline
failure policy quando il refresh non riesce ma una cache precedente è disponibile
locking della working copy
pinning dello snapshot durante una singola operazione
cleanup/rebuild di una cache invalida
```

Il requisito fissato qui è semantico: le operazioni catalog-dependent entrano attraverso il refresh boundary; le operazioni local-only no.

---

## 4. Range: cosa NON li deve creare

Un nuovo range serve quando cambia realmente il contratto della package definition.

Non deve essere creato un nuovo range soltanto perché cambia il pathname di un wrapper interno che `pkg_extract` elimina strutturalmente.

Esempi che non costituiscono da soli un nuovo range:

```text
foo-1.0/  -> foo-1.1/
foo/1.0/  -> foo/1.1/
release-2026-08/ -> release-2026-09/
```

se il payload utile risultante mantiene lo stesso contratto di artifact/materialization/integration.

Questo requisito è necessario affinché:

```text
nuova release
    -> ultimo range esistente
    -> pkg_extract normalizza il nuovo wrapper
    -> latest continua a funzionare
```

senza richiedere un aggiornamento del catalogo per ogni versione upstream.

---

## 5. Stato dei test già esistenti

Alla data corrente `rumiai-tests` possiede test permanenti dedicati a:

```text
http-fetch
json.lib.sh
pkg-repository-github.lib.sh
digest
extract
pkg_download
pkg_extract
pkg-analyze
```

I test di `digest`, `extract`, download e repository adapter restano validi per i rispettivi contratti.

I test correnti di `pkg_extract` proteggono ora la structural useful-root normalization, inclusi identity case, wrapper profondi, hidden entry, symlink e output nella destination scelta dal caller senza pubblicazione implicita in `$m_ROOT/pkg`.

I test correnti di `pkg-analyze` proteggono il consumo diretto della root normalizzata restituita da `pkg_extract` e l'assenza della precedente seconda discovery/interazione sulla useful root.

Il riallineamento non duplica i test della utility generale `extract`.

La definizione DBeaver corrente non introduce da sola un nuovo executable/runtime layer da testare in `rumiai-tests`: i test permanenti relativi a `format`, materializzazione `cmd/`, `link/`, state routing e argomenti fissi appartengono al successivo contratto/implementazione di `pkg_integrate`.

---

## 6. Sequenza di sviluppo fissata

La sequenza corrente diventa:

```text
1  confine refresh/snapshot pkg-catalog                                      [fissato]
2  test permanenti HTTP/JSON/GitHub adapter                                 [completato]
3  contratto + implementazione + test di pkg_download                       [completato]
4  utility di sistema digest/extract e relativi test                        [completato]
5  riallineamento pkg_extract: structural useful-root normalization         [completato]
6  riallineamento pkg-analyze: consumo diretto del pkg_extract normalizzato [completato]
7  analisi DBeaver + package definition Linux/macOS per integration         [completato]
8  contratto + implementazione pkg_integrate/pkg_deintegrate                [successivo]
9  orchestrazione reale pkg install                                         [successivo]
10 lifecycle uninstall/version/current                                      [successivo]
11 dependency/facility/state avanzato quando richiesto                      [successivo]
```

La normalizzazione della useful root è chiusa prima dell'integrazione: la forma artifact di `pkg-analyze` usa lo stesso output normalizzato che verrà passato a `pkg_integrate`.

La package definition DBeaver non contiene pathname di wrapper interni dell'artifact. Per Linux e macOS contiene invece soltanto le informazioni semantiche necessarie al layer successivo: formato, command source, target direct-link e state routing espresso nella launch line.

Lo stream Windows x86_64 resta intenzionalmente incompleto per il launch end-to-end: la selezione dell'artifact e `format=zip` sono definite, mentre `cmd/link` attendono la verifica del bridge pathname POSIX/native. Questa apertura non riporta il passo 7 allo stato successivo per i target Linux/macOS usati come primo caso di `pkg_integrate`.

La sequenza non riattiva i meccanismi storici già esclusi dal baseline, inclusi resolver universale, generations, inventory obbligatorie o migration framework generale.

---

## 7. Physical validation

La presenza di test permanenti e development checks non sostituisce la physical validation revision-specific quando i nuovi backend o i nuovi confini semantici vengono promossi nel flusso operativo.

La physical validation dei nuovi layer verrà pianificata in modo proporzionato dopo la loro implementazione, senza confonderla con il gate bootstrap attualmente ancora in attesa sui reference host ARM64.

L'implementazione corrente di `pkg_extract` e `pkg-analyze` ha superato development checks su fixture isolato, ma non viene considerata per questo fisicamente validata sui reference host.

La package definition DBeaver e il relativo launch model non sono ancora fisicamente validati come package installato: `pkg_integrate` e il `launcher` necessari al percorso reale non sono ancora implementati nel prodotto corrente.

---

## 8. Invarianti fissati

```text
PKG-PLAN-01  ogni operazione che consuma package definition/upstream passa prima dal refresh boundary di pkg-catalog
PKG-PLAN-02  uninstall e pkg_deintegrate restano local-only e non richiedono refresh del catalogo
PKG-PLAN-03  il launch di software già installato non acquisisce una dipendenza di rete solo per aggiornare pkg-catalog
PKG-PLAN-04  una singola operazione catalog-dependent usa un unico commit/snapshot Git del catalogo
PKG-PLAN-05  clone/fetch/offline/failure/locking/pinning restano contratti separati da chiudere prima dell'orchestrazione completa
PKG-PLAN-06  i test permanenti dei layer indipendenti non vengono duplicati nei layer successivi
PKG-PLAN-07  digest, extract e pkg_download sono completati secondo i rispettivi contratti correnti
PKG-PLAN-08  pkg_extract consegna automaticamente la structural useful root normalizzata nella destination scelta dal caller
PKG-PLAN-09  pkg-analyze forma artifact usa pkg_extract e non ripete useful-root discovery
PKG-PLAN-10  wrapper pathname/version-specific non appartiene alla package definition e non costituisce da solo un nuovo range
PKG-PLAN-11  latest deve continuare a funzionare attraverso variazioni puramente strutturali dei wrapper dell'artifact
PKG-PLAN-12  pkg_integrate riceve il payload già normalizzato e non effettua discovery/correzione dei wrapper upstream
PKG-PLAN-13  pkg_extract non sceglie né deriva $m_ROOT/pkg; la pubblicazione nel package store appartiene a un layer successivo
PKG-PLAN-14  la package definition DBeaver Linux/macOS necessaria al primo pkg_integrate è completata nel catalogo; lo stream Windows conserva cmd/link aperti fino alla verifica del bridge pathname POSIX/native
PKG-PLAN-15  il passo successivo della sequenza corrente è il contratto e l'implementazione di pkg_integrate/pkg_deintegrate
```
