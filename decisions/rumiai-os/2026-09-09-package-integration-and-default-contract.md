# Decisione — Integrazione di disponibilità e selezione default dei package

Date: 2026-09-09  
Status: **Accepted**

## Contesto

La pipeline package corrente separa già catalog lookup, repository resolution, download, extract e integrazione RumiAI. `pkg_extract` consegna a `pkg_integrate` una useful root già normalizzata e non pubblica autonomamente in `$m_ROOT/pkg`.

Le decisioni correnti distinguono inoltre:

```text
concrete package identity
selector current
public command binding
facility/provider availability
resolved dependency binding
```

Una dependency verso una facility viene risolta verso una concrete package identity e non verso il selector `current` del provider. Di conseguenza una concrete version può essere disponibile e utilizzabile come provider senza essere il default del proprio package.

Le correzioni esplicite dell'utente del 2026-09-09 fissano questa distinzione come parte del contratto operativo di integrazione e introducono la funzione `pkg_default`.

Questa decisione completa il contratto del passo 8 della sequenza package. Non introduce ancora l'orchestrazione pubblica `pkg install`/`pkg uninstall` né riapre dependency resolution, generations, inventory o migration framework.

---

## 1. Due livelli semantici distinti

Il primo livello è la **disponibilità** di una concrete version.

Una concrete version disponibile:

```text
esiste sotto $m_ROOT/pkg/<concrete-identity>/
possiede root/ e gli altri oggetti package-local applicabili
può offrire facility ed essere referenziata direttamente da resolved binding quando tali layer sono implementati
non deve essere current
non deve possedere binding pubblici in bin/ext*
```

Il secondo livello è la **selezione come default**.

Una concrete version default:

```text
è già disponibile
è selezionata dal relativo selector current
espone i propri command pubblici attraverso bin/ext o bin/ext-<osarch>
```

Quindi:

```text
default => available
available != default
```

Più concrete version dello stesso package possono essere simultaneamente disponibili. Per ogni selector generic o target-specific può esistere al massimo un default.

---

## 2. API iniziali

Il layer resta:

```text
lib/sh/pkg-integration.lib.sh
```

ed espone:

```text
pkg_integrate <pkg> <version> <range-dir> <useful-root> [<osarch>]
pkg_deintegrate <pkg> <version> [<osarch>]
pkg_default <pkg> <version-or-empty> [<osarch>]
```

Per tutte e tre le funzioni l'eventuale `<osarch>` qualifica la concrete identity/selector perché la package definition proviene da `catalog-<osarch>`; non rappresenta semplicemente il target richiesto dalla CLI.

Per `pkg_default`:

```text
version non vuota
    -> seleziona quella concrete version già disponibile come nuovo default

version vuota
    -> rimuove il default corrente della stessa classe generic/target-specific
```

Esempi interni:

```text
pkg_default dbeaver 26.2.0 linux-arm64
pkg_default dbeaver '' linux-arm64
pkg_default generic-tool 1.4
pkg_default generic-tool ''
```

La stringa vuota è esclusivamente il segnale API interno di assenza del default richiesto; non è una versione upstream e non introduce sintassi CLI.

Il nome `pkg_default` riguarda la selezione della concrete version default e non modifica la semantica della directory package-local opzionale `default/`, che resta uno strumento distinto di state/default materialization.

---

## 3. `pkg_integrate`: integrazione di disponibilità

`pkg_integrate` riceve:

```text
pkg
versione upstream concreta
range-dir già selezionata nello snapshot catalogo dell'operazione
useful-root già normalizzata da pkg_extract
osarch opzionale di qualificazione dell'identità
```

Non:

```text
interroga repository upstream
risolve latest
ridiscopre wrapper artifact
sceglie $m_ROOT/pkg come destination di extract
crea o modifica current
crea binding pubblici bin/ext*
```

La concrete identity è:

```text
<pkg>@<version>
<pkg>@<version>!<osarch>
```

secondo la classe della package definition selezionata.

La concrete identity finale non deve già esistere. Il baseline non introduce overwrite implicito, repair o reinstall in-place.

La useful root è staging consumabile: dopo la validazione `pkg_integrate` può spostarla e usarla direttamente come:

```text
<concrete>/root/
```

Dopo successo il caller non deve dipendere dal pathname staging originario.

---

## 4. Baseline `cmd/` e `link/`

Per il primo contratto implementato, richiesto dalla package definition DBeaver, `pkg_integrate` supporta la materializzazione direct-link:

```text
<concrete>/cmd/<pkg-command>
<concrete>/link/<pkg-command> -> ../root/<declared-target>
```

Il source `cmd/<pkg-command>` del catalogo:

```text
è un file regolare di dati non eseguibile
viene copiato byte-per-byte
non viene source, eval o templated
la copia installata viene resa eseguibile
```

Il valore `link/<pkg-command>` del catalogo è un pathname relativo alla useful root. Deve essere non vuoto, non assoluto, non contenere componenti `.` o `..`, non uscire da `root/` neppure attraverso symlink e deve risolvere a un file esistente dentro la useful root.

Nel caso direct-link gli insiemi dei nomi presenti in `cmd/` e `link/` coincidono esattamente.

I campi di range già consumati da layer precedenti, inclusi `archive_regex`, `digest_regex`, `digest_type` e `format`, vengono ignorati dall'integrazione.

Strutture di integrazione future la cui serializzazione/comportamento non è ancora implementata non vengono interpretate implicitamente: producono `unsupported` finché il relativo contratto operativo non viene chiuso.

---

## 5. `pkg_default`: selezione e rimozione del default

`pkg_default` opera esclusivamente sul livello default e non modifica l'integrazione di disponibilità della concrete version.

Per impostare un nuovo default la concrete version richiesta deve essere già disponibile e appartenere alla stessa classe del selector:

```text
generic -> selector <pkg>
target-specific -> selector <pkg>!<osarch>
```

Non viene introdotto alcun comparatore universale delle versioni né resolution di facility dentro `pkg_default`.

Il cambio default avviene nell'ordine semantico fissato:

```text
1  validare completamente vecchio stato, nuovo candidato e collisioni
2  rimuovere i binding pubblici dei command del vecchio default, se esiste
3  rimuovere il vecchio selector current, se esiste
4  creare il nuovo selector current relativo verso la concrete identity richiesta
5  creare i binding pubblici dei command del nuovo default attraverso current
```

Il punto 4 precede sempre il punto 5: non si crea intenzionalmente un binding pubblico dangling contando sul fatto che la creazione di un symlink verso un target assente possa riuscire.

Binding pubblici:

```text
package generic:
    bin/ext/<pkg-command>
        -> ../../pkg/<pkg>/cmd/<pkg-command>

package target-specific:
    bin/ext-<osarch>/<pkg-command>
        -> ../../pkg/<pkg>!<osarch>/cmd/<pkg-command>
```

`bin/ext-osarch` resta la view/alias runtime del target corrente e non è la sede fisica dei binding target-specific persistenti.

Un oggetto pubblico estraneo non viene sovrascritto o rimosso. Un binding già appartenente al vecchio default è invece rimosso durante la transizione.

Il command-set del nuovo default può differire da quello precedente. Non esiste un requisito di uguaglianza fra i due insiemi.

Per rimuovere il default, `pkg_default`:

```text
rimuove i binding pubblici del default corrente
rimuove il selector current
lascia intatta la concrete version
lascia intatta la sua disponibilità
non modifica provider index o resolved dependency binding
```

La rimozione di un default già assente è idempotente.

---

## 6. `pkg_deintegrate`: rimozione della disponibilità

`pkg_deintegrate` opera su una concrete version esatta e resta local-only.

Non consulta:

```text
pkg-catalog
repository upstream
latest
artifact
```

Una concrete version selezionata come `current` non può essere deintegrata. Il caller deve prima spostare o rimuovere il default tramite `pkg_default`.

Nel baseline corrente, prima dell'implementazione operativa di facility/dependency/state avanzato, la deintegration rimuove la concrete package materializzata e non rimuove state sotto le semantic roots utente/runtime.

Quando verranno implementati provider index, dependency materialization o altri meccanismi di disponibilità, la coppia `pkg_deintegrate`/`pkg_integrate` dovrà essere estesa con particolare cura rispetto ai consumer ancora legati a provider concreti. Tale requisito non autorizza a introdurre adesso un resolver universale, transaction graph, generation o dependency framework non richiesto dal caso corrente.

Cambiare default tramite `pkg_default` non equivale a deintegrate/reintegrate la disponibilità e non deve invalidare resolved binding che puntano direttamente a concrete version ancora disponibili.

---

## 7. Failure model e status

Il baseline non promette atomicità rispetto a crash, power loss o processi concorrenti e non introduce per questo generations, journal o locking generale.

Prima delle mutazioni vengono validate, per quanto determinabile, struttura e collisioni. Gli errori rilevati non autorizzano overwrite o repair di oggetti estranei.

Status iniziali:

```text
0  successo
1  errore semantico/operativo o filesystem
2  chiamata API invalida oppure feature di integrazione non ancora supportata
```

La diagnostica dettagliata può essere emessa tramite `log` senza introdurre una tassonomia estesa di exit status.

---

## 8. Relazione con dependency/facility

La selezione default è indipendente dalla resolution delle dependency.

Esempio concettuale:

```text
temurin@17...  available provider java/17
temurin@21...  available provider java/21, current/default
temurin@25...  available provider java/25
```

Un consumer può possedere `binding/java` verso `temurin@17...` o `temurin@25...` anche mentre il default del package Temurin è la versione 21. Spostare `current` non riscrive tali binding.

La futura deintegration di una concrete version che funge da provider deve invece verificare le dependency applicabili prima di ritirarne la disponibilità.

---

## 9. Implementazione, test e physical validation

Il passo di prodotto implementa questo contratto in:

```text
rumiai-os/lib/sh/pkg-integration.lib.sh
```

I test permanenti appartengono a:

```text
rumiai-tests/tests/rumiai-os/pkg-integration/
```

Devono proteggere almeno:

```text
identity generic e target-specific
materializzazione root/cmd/link
command source copiato esattamente e reso eseguibile
link relativo confinato in root
assenza di current e binding pubblici dopo il solo pkg_integrate
pkg_default set/remove
ordine strutturale current prima dei binding pubblici
binding fisici sotto bin/ext o bin/ext-<osarch>
nessuna scrittura fisica in bin/ext-osarch
cambio default con command-set differente
collisioni con oggetti pubblici estranei
pkg_deintegrate rifiutato sulla current
pkg_deintegrate ammesso su concrete version non-current
rimozione default senza perdita della disponibilità
DBeaver Linux/macOS/Windows direct-link mapping
assenza di template/eval
assenza di env/default/var quando non dichiarati
```

La physical validation ARM64 chiusa in precedenza resta evidence esclusivamente delle revisioni allora validate e non copre questa nuova implementazione. Le nuove revisioni prodotto/test richiedono una successiva validation revision-specific proporzionata.

---

## 10. Invarianti fissati

```text
PKG-INT-01  availability e default sono livelli distinti; default implica availability ma availability non implica default
PKG-INT-02  pkg_integrate materializza la disponibilità di una concrete version e non modifica current o bin/ext*
PKG-INT-03  pkg_default gestisce esclusivamente selector current e binding pubblici del default
PKG-INT-04  pkg_default con versione vuota rimuove il default senza rimuovere la concrete version
PKG-INT-05  il cambio default rimuove prima i vecchi binding, poi sostituisce current, poi crea i nuovi binding
PKG-INT-06  i binding pubblici risolvono sempre attraverso current e terminano su cmd/<pkg-command>
PKG-INT-07  i binding target-specific persistenti appartengono a bin/ext-<osarch>, non a bin/ext-osarch
PKG-INT-08  command-set differenti fra default successivi sono ammessi
PKG-INT-09  pkg_deintegrate opera soltanto su concrete version non-current
PKG-INT-10  pkg_default non modifica provider availability o resolved dependency binding
PKG-INT-11  pkg_deintegrate resta local-only
PKG-INT-12  pkg_integrate riceve la useful root già normalizzata e non ridiscopre wrapper artifact
PKG-INT-13  il catalog cmd source non viene source/eval/template; la copia installata è eseguibile
PKG-INT-14  link/<pkg-command> è relativo e confinato nel root della stessa concrete version
PKG-INT-15  nessun universal resolver, generation, mandatory inventory o migration framework viene reintrodotto dal baseline di integrazione
PKG-INT-16  la futura deintegration di provider concreti deve preservare la coerenza delle dependency prima di ritirarne la disponibilità
```
