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

La correzione esplicita dell'utente del 2026-09-09 fissa inoltre che `pkg_extract` deve consegnare direttamente la useful root normalizzata, eliminando i wrapper upstream variabili prima di `pkg_integrate`.

Di conseguenza il precedente stato del piano che marcava `pkg_extract` come completamente concluso è superseded: l'attuale implementazione raw-staging esiste, ma il contratto, l'implementazione e i test devono essere riallineati dopo aver ricavato dai package reali la normalization information necessaria.

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

## 4. Stato dei test già esistenti

Alla data corrente `rumiai-tests` possiede test permanenti dedicati a:

```text
http-fetch
json.lib.sh
pkg-repository-github.lib.sh
digest
extract
pkg_download
pkg_extract
pkg_analyze
```

I test di `digest`, `extract`, download e repository adapter restano validi per i rispettivi contratti.

I test correnti di `pkg_extract` e la parte artifact dei test di `pkg_analyze` proteggono ancora il precedente comportamento raw-staging e sono **pending realignment** rispetto alla useful-root normalization appena fissata.

Il riallineamento non deve duplicare i test della utility generale `extract`.

---

## 5. Sequenza di sviluppo fissata

La sequenza corrente diventa:

```text
1  confine refresh/snapshot pkg-catalog                                  [fissato]
2  test permanenti HTTP/JSON/GitHub adapter                             [completato]
3  contratto + implementazione + test di pkg_download                   [completato]
4  utility di sistema digest/extract e relativi test                    [completato]
5  pkg_analyze + analisi package reale per useful-root/materialization  [in corso]
6  completamento package definition DBeaver, inclusa normalization info [successivo]
7  riallineamento contratto fisico + implementazione + test pkg_extract [successivo]
8  contratto + implementazione pkg_integrate/pkg_deintegrate            [successivo]
9  orchestrazione reale pkg install                                     [successivo]
10 lifecycle uninstall/version/current                                  [successivo]
11 dependency/facility/state avanzato quando richiesto                  [successivo]
```

La normalizzazione della useful root deve essere chiusa prima di `pkg_integrate`, perché integration deve ricevere un payload già normalizzato e non deve conoscere wrapper upstream release/platform-specific.

La sequenza non riattiva i meccanismi storici già esclusi dal baseline, inclusi resolver universale, generations, inventory obbligatorie o migration framework generale.

---

## 6. Physical validation

La presenza di test permanenti e development checks non sostituisce la physical validation revision-specific quando i nuovi backend o i nuovi confini semantici vengono promossi nel flusso operativo.

La physical validation dei nuovi layer verrà pianificata in modo proporzionato dopo la loro implementazione, senza confonderla con il gate bootstrap attualmente ancora in attesa sui reference host ARM64.

La correzione documentale della useful-root normalization non costituisce physical validation dell'implementazione corrente di `pkg_extract`.

---

## 7. Invarianti fissati

```text
PKG-PLAN-01  ogni operazione che consuma package definition/upstream passa prima dal refresh boundary di pkg-catalog
PKG-PLAN-02  uninstall e pkg_deintegrate restano local-only e non richiedono refresh del catalogo
PKG-PLAN-03  il launch di software già installato non acquisisce una dipendenza di rete solo per aggiornare pkg-catalog
PKG-PLAN-04  una singola operazione catalog-dependent usa un unico commit/snapshot Git del catalogo
PKG-PLAN-05  clone/fetch/offline/failure/locking/pinning restano contratti separati da chiudere prima dell'orchestrazione completa
PKG-PLAN-06  i test permanenti dei layer indipendenti non vengono duplicati nei layer successivi
PKG-PLAN-07  digest, extract e pkg_download sono completati secondo i rispettivi contratti correnti
PKG-PLAN-08  pkg_extract non è più considerato completato finché non implementa e testa la useful-root normalization
PKG-PLAN-09  pkg_analyze/package reali forniscono evidence per fissare la normalization information della package definition
PKG-PLAN-10  pkg_integrate viene implementato soltanto dopo che pkg_extract consegna direttamente il payload normalizzato
```
