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

L'analisi DBeaver e la prima package definition utilizzabile dal layer di integrazione sono consolidate da:

```text
decisions/rumiai-os/2026-09-09-dbeaver-package-integration-definition.md
decisions/rumiai-os/2026-09-09-windows-posix-environment-baseline.md
```

Il contratto operativo corrente del layer di integrazione, inclusa la distinzione fra disponibilità e default e la funzione `pkg_default`, è consolidato da:

```text
decisions/rumiai-os/2026-09-09-package-integration-and-default-contract.md
```

Il contratto corrente dell'orchestrazione `pkg install` e del refresh/pinning Git del catalogo è consolidato da:

```text
decisions/rumiai-os/2026-09-09-package-install-orchestration-and-catalog-snapshot.md
```

Per DBeaver sono fissati in particolare:

```text
-configuration -> $m_CONF_DIR/dbeaver/configuration
-data          -> $m_HOME_DIR/dbeaver/.workspace
```

La range definition usa inoltre `format`, `cmd/<pkg-command>` e, per i command direct-link, `link/<pkg-command>` secondo la serializzazione minima fissata dalla decisione DBeaver.

Gli stream Linux, macOS e Windows x86_64 possiedono ora la definizione di launch necessaria all'integrazione. Per Windows la baseline corrente assume MSYS2 come ambiente POSIX-compatible di riferimento e mantiene i pathname RumiAI POSIX senza conversioni Win32 package-specific. La scelta MSYS2 resta da validare fisicamente prima di decidere se debba diventare un requisito esclusivo definitivo.

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
pkg_default
launch di un package già installato tramite pkg run, quando non richiede discovery remota
future operazioni di selezione locale di una versione già installata
```

In particolare il semplice avvio di software già installato non deve acquisire una dipendenza di rete soltanto perché il package è stato originariamente installato da `pkg`.

---

## 2. Snapshot coerente per operazione

Dopo la fase di refresh, una singola operazione che consuma il catalogo usa un unico snapshot Git del catalogo.

Il commit Git della working copy identifica tale snapshot.

Durante la stessa operazione non vengono mescolate package definition provenienti da commit differenti del catalogo, inclusa un'invocazione multi-package.

Il baseline operativo corrente implementa il pinning materializzando, mentre il lock della working copy è detenuto, il tree dell'HEAD scelto in una working area separata dell'operazione. Dopo la materializzazione il lock può essere rilasciato senza permettere a refresh successivi di modificare le package definition osservate dall'invocazione già in corso.

---

## 3. Baseline Git corrente del refresh

Il refresh non è modellato come una generica API `git pull`.

Il contratto corrente fissa invece esplicitamente:

```text
remote canonico
    https://github.com/massimilianonardi-ai/pkg-catalog.git

branch
    main

cache
    $m_ROOT/cache/sys/pkg/pkg-catalog/

lock
    $m_ROOT/run/sys/pkg/pkg-catalog.lock/
```

La prima operazione crea un clone temporaneo sibling e lo pubblica come cache soltanto dopo validazione.

Una cache esistente deve avere origin e branch attesi, working tree clean e HEAD valido. Il refresh usa fetch e accetta soltanto un avanzamento fast-forward del precedente HEAD; divergenze o history rewrite osservate dopo fetch riuscito sono failure.

Se il fetch stesso fallisce ma una cache preesistente resta valida, il baseline local-first usa il precedente HEAD cached. Una cache invalida non viene cancellata o ricostruita implicitamente.

Il lock è una directory atomica con scalar `pid`; un lock attivo blocca l'operazione, un lock stale viene reclamato soltanto quando la shape è esattamente quella attesa, mentre oggetti malformati non vengono rimossi aggressivamente.

Git è una dipendenza runtime implementation-specific documentata e autorizzata esclusivamente per questo boundary. Il relativo hardening forza TLS verification e disabilita hook e fsmonitor per le invocazioni del package manager.

Il contratto completo è in:

```text
decisions/rumiai-os/2026-09-09-package-install-orchestration-and-catalog-snapshot.md
```

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
pkg-integration
pkg install / catalog snapshot
```

I test di `digest`, `extract`, download e repository adapter restano validi per i rispettivi contratti.

I test correnti di `pkg_extract` proteggono la structural useful-root normalization, inclusi identity case, wrapper profondi, hidden entry, symlink e output nella destination scelta dal caller senza pubblicazione implicita in `$m_ROOT/pkg`.

I test correnti di `pkg-analyze` proteggono il consumo diretto della root normalizzata restituita da `pkg_extract` e l'assenza della precedente seconda discovery/interazione sulla useful root.

Il riallineamento non duplica i test della utility generale `extract`.

I test correnti di `pkg-integration` proteggono il baseline direct-link di DBeaver, la separazione fra disponibilità e default, `pkg_default`, la rimozione del default senza perdita della concrete version, il rifiuto di `pkg_deintegrate` sulla current, i binding fisici sotto `bin/ext`/`bin/ext-<osarch>`, il cambio default con command-set differente, le collisioni estranee, il confinamento di `link/` in `root/` e il vocabulary `<osarch>` corrente.

I test correnti di `pkg` proteggono il command entry, la prevalidazione prima del refresh, l'uso di un solo snapshot per invocazione multi-package, le quattro forme operand, precedenza target/fallback generic, concrete identity derivata dallo stream, range resolution posizionale su versioni opache, assenza di default implicito e stop-on-first-failure senza rollback globale. Un test separato usa repository Git locali per proteggere clone, refresh fast-forward, fallback offline, lock active/stale, snapshot privo di `.git` e parametri canonici del boundary.

---

## 6. Sequenza di sviluppo fissata

La sequenza corrente diventa:

```text
1  confine refresh/snapshot pkg-catalog                                      [fissato e implementato nel passo 9]
2  test permanenti HTTP/JSON/GitHub adapter                                 [completato]
3  contratto + implementazione + test di pkg_download                       [completato]
4  utility di sistema digest/extract e relativi test                        [completato]
5  riallineamento pkg_extract: structural useful-root normalization         [completato]
6  riallineamento pkg-analyze: consumo diretto del pkg_extract normalizzato [completato]
7  analisi DBeaver + package definition Linux/macOS/Windows per integration [completato]
8  contratto + implementazione pkg_integrate/pkg_deintegrate/pkg_default    [completato; physical validation pending]
9  orchestrazione reale pkg install                                         [completato; physical validation pending]
10 lifecycle uninstall/version/current                                      [successivo]
11 dependency/facility/state avanzato quando richiesto                      [successivo]
```

La normalizzazione della useful root è chiusa prima dell'integrazione: la forma artifact di `pkg-analyze` usa lo stesso output normalizzato che viene passato a `pkg_integrate`.

`pkg_integrate` materializza la disponibilità della concrete version senza selezionarla automaticamente come default. `pkg_default` gestisce separatamente il selector `current` e i binding pubblici, mentre `pkg_deintegrate` opera soltanto su concrete version non-current.

`pkg install` orchestra ora stream selection, repository adapter, version/range resolution, artifact resolution, `pkg_download`, `pkg_extract` e `pkg_integrate` su un unico snapshot catalogo per invocazione. L'installazione non chiama `pkg_default` e quindi non altera automaticamente la selezione persistente.

La package definition DBeaver non contiene pathname di wrapper interni dell'artifact. Per Linux, macOS e Windows x86_64 contiene soltanto le informazioni semantiche necessarie al layer di integrazione: formato, command source, target direct-link e state routing espresso nella launch line.

La definizione Windows usa `format=zip`, `link/dbeaver=dbeaver.exe` e lo stesso `cmd/dbeaver` degli altri target. Non viene introdotto un bridge pathname POSIX/native dentro RumiAI: il baseline Windows corrente assume MSYS2 come ambiente POSIX-compatible di riferimento. La validazione fisica Windows resta separata e potrà determinare se MSYS2 diventa requisito esclusivo oppure se altri ambienti soddisfano lo stesso contratto.

La sequenza non riattiva i meccanismi storici già esclusi dal baseline, inclusi resolver universale, generations, inventory obbligatorie o migration framework generale.

---

## 7. Physical validation

La presenza di test permanenti e development checks non sostituisce la physical validation revision-specific quando i nuovi backend o i nuovi confini semantici vengono promossi nel flusso operativo.

Il precedente gate ARM64 completo resta evidence immutabile esclusivamente per la coppia revision-specific allora validata:

```text
rumiai-os@130944920b5dab5f9d25bd3515667f5cdff36a48
rumiai-tests@68e12c37dae9789bc44d966578e76e9530d7db95
```

L'implementazione di `pkg_integrate`, `pkg_deintegrate`, `pkg_default` e della nuova orchestrazione `pkg install` è successiva a quella coppia e non è coperta da tale evidence. La revisione corrente richiede quindi una nuova physical validation proporzionata sui reference host prima di dichiarare fisicamente validati questi layer.

I development checks del nuovo boundary Git usano repository locali e non costituiscono validazione della connettività GitHub reale, dei backend host reference o del comportamento Windows/MSYS2.

La package definition DBeaver e il relativo launch model non sono ancora fisicamente validati come package installato end-to-end: download/extract/integration possono ora essere orchestrati dal comando `pkg install`, ma il `launcher` necessario al percorso reale di esecuzione non è ancora implementato nel prodotto corrente.

La physical validation Windows resta successiva e distinta dalla validation sui reference host ARM64 Ubuntu/macOS.

---

## 8. Invarianti fissati

```text
PKG-PLAN-01  ogni operazione che consuma package definition/upstream passa prima dal refresh boundary di pkg-catalog
PKG-PLAN-02  uninstall, pkg_deintegrate e pkg_default restano local-only e non richiedono refresh del catalogo
PKG-PLAN-03  il launch di software già installato non acquisisce una dipendenza di rete solo per aggiornare pkg-catalog
PKG-PLAN-04  una singola operazione catalog-dependent usa un unico commit/snapshot Git del catalogo
PKG-PLAN-05  clone/fetch/offline/failure/locking/pinning del baseline pkg install sono fissati da 2026-09-09-package-install-orchestration-and-catalog-snapshot.md
PKG-PLAN-06  i test permanenti dei layer indipendenti non vengono duplicati nei layer successivi
PKG-PLAN-07  digest, extract e pkg_download sono completati secondo i rispettivi contratti correnti
PKG-PLAN-08  pkg_extract consegna automaticamente la structural useful root normalizzata nella destination scelta dal caller
PKG-PLAN-09  pkg-analyze forma artifact usa pkg_extract e non ripete useful-root discovery
PKG-PLAN-10  wrapper pathname/version-specific non appartiene alla package definition e non costituisce da solo un nuovo range
PKG-PLAN-11  latest deve continuare a funzionare attraverso variazioni puramente strutturali dei wrapper dell'artifact
PKG-PLAN-12  pkg_integrate riceve il payload già normalizzato e non effettua discovery/correzione dei wrapper upstream
PKG-PLAN-13  pkg_extract non sceglie né deriva $m_ROOT/pkg; la pubblicazione nel package store appartiene a un layer successivo
PKG-PLAN-14  la package definition DBeaver necessaria al primo pkg_integrate è completata per Linux, macOS e Windows x86_64
PKG-PLAN-15  la baseline Windows corrente assume MSYS2 e non introduce conversioni pathname Win32 package-specific
PKG-PLAN-16  pkg_integrate/pkg_deintegrate/pkg_default e l'orchestrazione reale pkg install sono implementati; il passo di sviluppo successivo è lifecycle uninstall/version/current
PKG-PLAN-17  la physical validation è revision-specific; il precedente gate ARM64 non copre pkg-integration né la nuova orchestrazione pkg install
```
