# Decisione — Sequenza di implementazione `pkg` e confine di refresh del catalogo

Date: 2026-09-09  
Status: **Accepted**

## Contesto

La pipeline corrente di `pkg` separa già:

```text
catalog lookup
repository-specific discovery/resolution
generic download
generic extract
RumiAI package integration
```

Sono inoltre già fissati:

- il repository concreto `massimilianonardi-ai/pkg-catalog`;
- la cache locale rigenerabile `$m_ROOT/cache/sys/pkg/pkg-catalog/`;
- il primo repository adapter GitHub e il relativo transport `http-fetch`;
- la CLI pubblica `pkg install <package> [<package> ...]` e `pkg uninstall <package> [<package> ...]`;
- `pkg uninstall` come operazione local-only;
- il principio local-first di RumiAI.

L'utente ha approvato il proseguimento della pipeline e ha indicato che le operazioni `pkg` che dipendono dal catalogo devono lavorare normalmente su un catalogo aggiornato, distinguendole dalle operazioni puramente locali come uninstall/deintegration.

Questa decisione fissa il planning e il confine semantico del refresh. Non implementa ancora il meccanismo concreto di clone/fetch/update della working copy.

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

Alla data corrente `rumiai-tests` possiede già test permanenti dedicati a:

```text
http-fetch
json.lib.sh
pkg-repository-github.lib.sh
```

Questi test restano la copertura canonica dei componenti esistenti e non devono essere duplicati soltanto perché prosegue l'implementazione di `pkg`.

I nuovi layer introdotti dalla sequenza seguente ricevono invece propri test permanenti indipendenti.

---

## 5. Sequenza di sviluppo fissata

La sequenza corrente è:

```text
1  confine refresh/snapshot pkg-catalog                         [fissato qui]
2  test permanenti HTTP/JSON/GitHub adapter                    [già presenti]
3  contratto + implementazione + test di pkg_download          [corrente]
4  contratto + implementazione + test di pkg_extract           [corrente]
5  completamento package definition DBeaver per integration    [successivo]
6  contratto + implementazione pkg_integrate/pkg_deintegrate   [successivo]
7  orchestrazione reale pkg install                            [successivo]
8  lifecycle uninstall/version/current                         [successivo]
9  dependency/facility/state avanzato quando richiesto         [successivo]
```

La sequenza non riattiva i meccanismi storici già esclusi dal baseline, inclusi resolver universale, generations, inventory obbligatorie o migration framework generale.

---

## 6. Physical validation

La presenza di test permanenti e development checks non sostituisce la physical validation revision-specific quando i nuovi backend vengono promossi nel flusso operativo.

La physical validation dei nuovi layer verrà pianificata in modo proporzionato dopo la loro implementazione, senza confonderla con il gate bootstrap attualmente ancora in attesa sui reference host ARM64.

---

## 7. Invarianti fissati

```text
PKG-PLAN-01  ogni operazione che consuma package definition/upstream passa prima dal refresh boundary di pkg-catalog
PKG-PLAN-02  uninstall e pkg_deintegrate restano local-only e non richiedono refresh del catalogo
PKG-PLAN-03  il launch di software già installato non acquisisce una dipendenza di rete solo per aggiornare pkg-catalog
PKG-PLAN-04  una singola operazione catalog-dependent usa un unico commit/snapshot Git del catalogo
PKG-PLAN-05  clone/fetch/offline/failure/locking/pinning restano contratti separati da chiudere prima dell'orchestrazione completa
PKG-PLAN-06  i test permanenti già esistenti per http-fetch, JSON e GitHub adapter non vengono duplicati
PKG-PLAN-07  i prossimi layer implementativi sono pkg_download e pkg_extract con test permanenti propri
PKG-PLAN-08  integration, orchestration e lifecycle successivo restano fuori da questa unità
```