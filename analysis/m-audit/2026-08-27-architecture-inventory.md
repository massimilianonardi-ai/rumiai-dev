# Audit di `massimilianonardi/m` — Inventario architetturale preliminare

Data: 2026-08-27

Repository sorgente: `https://github.com/massimilianonardi/m`

Snapshot di riferimento:

```text
e4faae1c1d9b27cc5503b987ba5e7bf2874c906c
```

## Stato del documento

Questo documento è il primo inventario dell'audit. Non è una specifica di `rumiai-os` e non autorizza la migrazione automatica di codice.

Le classificazioni `KEEP`, `REIMPLEMENT`, `REDESIGN` e `DROP` qui presenti sono **preliminari** e riguardano soprattutto concetti e responsabilità architetturali. La classificazione definitiva richiederà l'analisi dettagliata e, dove necessario, test riproducibili in `rumiai-dev-PoCs`.

Il repository `m` viene trattato come materiale storico e sperimentale: l'obiettivo è distinguere la visione e le idee valide dalla forma concreta assunta dalle implementazioni nel tempo.

---

# 1. Quadro generale

L'audit ha già evidenziato almeno tre filoni distinti e parzialmente sovrapposti:

1. il sistema storico `var/#_os`, che contiene una vera architettura di portable OS, package manager, root semantica, profili, target e bootstrap;
2. una generazione più recente di librerie POSIX e package manager sotto `cmd/lib` e `cmd/pkg`;
3. PoC e script operativi più recenti, ad esempio `ai/podman-ai.sh`, che sperimentano container e stack AI ma non costituiscono una base architetturale stabile.

È quindi sbagliato trattare `m` come se contenesse un'unica implementazione corrente. L'audit deve ricostruire l'evoluzione dei concetti e confrontare le generazioni.

---

# 2. Sottosistemi prioritari individuati

## 2.1 `var/#_os` — precedente diretto della vision `rumiai-os`

Directory principali individuate:

```text
var/#_os/
├── .mk/
├── boot/
├── fsx/
├── install/
├── m/
└── retu/
```

Questa area è attualmente il materiale di riferimento più importante per `rumiai-os`.

Contiene già concetti che coincidono con la vision corrente:

- inizializzazione di un ambiente portabile;
- filesystem/root indipendente dall'host;
- package separati dal sistema;
- stato utente e stato di lavoro separati;
- piattaforme differenti;
- supporto storico a Cygwin/Windows come substrato;
- profili e target di build/run/install;
- bootstrap molto piccolo che inoltra l'esecuzione al sistema installato.

### Candidato concettuale

**KEEP / REDESIGN**.

La visione è direttamente rilevante. L'implementazione deve invece essere verificata rispetto alle regole attuali: POSIX come contratto, relocatability rigorosa, separazione degli adapter host-specific e assenza di assunzioni implicite sull'host.

---

# 3. Root semantica e filesystem portabile

Il file storico:

```text
var/#_os/m/bin/m-sys.lib
```

definisce già una root logica e una serie di path semantici derivati:

```text
ROOT_DIR
├── src
├── pkg
├── sys
│   ├── cmd
│   ├── env
│   ├── app
│   ├── lib
│   ├── dep
│   └── deprev
├── usr
└── wrk
```

Inoltre definisce directory per utente e per singolo workload/componente:

```text
conf
data
home
log
pid
tmp
```

Questa è una delle idee più forti trovate finora.

Il sistema storico distingue già:

- package installati;
- artefatti di integrazione del sistema;
- stato utente;
- configurazione;
- dati persistenti;
- home;
- log;
- PID;
- dati temporanei.

### Valutazione preliminare

**KEEP come concetto. REDESIGN dell'API e dell'implementazione.**

Per `rumiai-os` la topologia non va copiata meccanicamente, ma il principio di una root unica dalla quale derivano path semantici centralizzati è perfettamente coerente con le regole correnti.

Va invece ridotto il ruolo della rilevazione dell'OS: POSIX è il contratto generale; l'identità dell'host deve essere interrogata soltanto dove una capability o un adapter richiedono realmente comportamento specifico.

---

# 4. Entrypoint minimale

Il vecchio entrypoint:

```text
var/#_os/install/m
```

è composto essenzialmente da:

```sh
#!/bin/sh

"${0%/*}/pkg/m/bin/shell" "$@"
```

Il concetto è molto vicino alla decisione attuale per la root di `rumiai-os`: un front controller minuscolo che individua il sistema relativo alla propria posizione e delega immediatamente.

### Valutazione preliminare

**KEEP come principio.**

Il nuovo `rumiai-os` non deve necessariamente mantenere gli stessi path o lo stesso dispatcher, ma dovrebbe conservare questa semplicità.

---

# 5. Bootstrap/installazione storica

`var/#_os/install/install` costruisce una root contenente almeno:

```text
src/
pkg/
wrk/
```

ed è già in buona parte root-relative.

Sono presenti modalità differenti per sviluppo e copia/installazione.

Tuttavia il calcolo di alcune directory sorgenti dipende da pattern specifici del layout storico del repository. Questo è incompatibile con il nuovo requisito di relocatability rigorosa se riutilizzato senza modifiche.

Nella stessa area sono presenti bootstrap Windows/Cygwin storici:

```text
cygwin-installer.cmd
install-windows.cmd
m.cmd
```

Questi file sono preziosi per capire come il progetto abbia già affrontato Windows come substrato POSIX, ma non devono determinare l'architettura generale di `rumiai-os`.

### Valutazione preliminare

- bootstrap POSIX e concetto di root: **KEEP / REIMPLEMENT**;
- assunzioni sul layout sorgente: **DROP / REIMPLEMENT**;
- bootstrap Windows: **reference adapter**, non core architecture.

---

# 6. Profili e target `.mk`

`var/#_os/.mk` contiene configurazioni distinte per:

- progetto/multi-progetto;
- profilo;
- target di installazione;
- target di run.

`mk.conf` mostra inoltre una composizione del sistema per progetti, con esempi storici come:

```text
m
init
pkg
mk
netstore
shell
terminal
cygwin-windows-x86_64
```

Questa è una chiara anticipazione del concetto attuale di sistema dichiarativo composto da componenti e materializzato verso target differenti.

### Valutazione preliminare

**KEEP come concetto, REDESIGN completo del modello dichiarativo.**

Va approfondito separatamente il sottosistema `mk` per capire se contiene astrazioni ancora utili per:

- profiles;
- target;
- dependency graph;
- build/deploy graph;
- materializzazione di environment differenti.

---

# 7. Package manager — due generazioni distinte

## 7.1 Generazione storica: `var/#_os/m/bin/pkg`

È la generazione architetturalmente più interessante finora.

Il front controller è modulare e carica funzioni separate da:

```text
var/#_os/m/bin/include/pkg/
├── install
├── integrate
├── parse
├── profile
├── query
└── search
```

Responsabilità già separate:

- parsing dell'identità del package;
- ricerca e matching;
- installazione;
- integrazione nel sistema;
- gestione profilo/stato;
- query package installati e dipendenze.

### Modello package

Il package viene modellato concettualmente come:

```text
name / platform / version
```

con supporto embrionale per:

- package `all`;
- package platform-specific;
- versione esatta;
- range di versione;
- `latest`;
- dipendenze;
- reverse dependencies.

### Catalogo/store

Il catalogo storico separa due aspetti:

```text
pkg/<nome>/pkg/...
pkg/<nome>/ver/<platform>/<version>/...
```

Il template mostra una distinzione interessante fra:

1. **package skeleton**, contenente integrazione e default;
2. **version/platform metadata**, contenente almeno sorgente/link e riferimento al package skeleton.

Un package skeleton può contenere:

```text
def/
├── conf
├── data
└── home

sys/
├── app
├── command
├── depend
├── env
├── lib
├── path
├── postdownload
├── postinstall
└── srv
```

Questo modello merita un audit dedicato: separare il payload binario del vendor dalle regole di integrazione e dai default del package è un'idea potenzialmente molto utile per `rumiai-os`.

### Problemi già visibili

Il resolver non è ancora un vero dependency solver:

- il confronto versioni è implementato manualmente ed è orientato a versioni numeriche semplici;
- esistono numerosi TODO sulla gestione dipendenze;
- update è sostanzialmente uninstall + install;
- non è ancora evidente una gestione completa di cicli, conflitti, alternative, pin, lock e rollback;
- alcune aree mostrano codice vecchio e nuovo sovrapposto nello stesso file.

### Valutazione preliminare

**REDESIGN**, preservando numerosi concetti.

Non copiare il resolver attuale. Recuperare invece il modello mentale e verificarlo contro i requisiti di `rumiai-os`.

---

## 7.2 Generazione recente: `cmd/pkg`

La versione più recente presenta un'interfaccia più piccola:

```text
pkg install
pkg uninstall
pkg run
```

ed introduce una buona astrazione dei repository/provider:

```text
custom
github
maven
sourceforge
codeberg
```

con un'interfaccia comune basata su operazioni come:

```text
versions
latest_version
download_url
```

### Punto positivo

Il provider abstraction è un candidato forte da preservare concettualmente.

### Problema strutturale immediato

Il front controller `cmd/pkg/pkg` incorpora direttamente una root `/m` e path del repository sorgente, ad esempio per package, bin, app, lib, home e configurazione.

Questo viola direttamente le regole attuali di relocatability.

### Ulteriore coupling

`pkg-install` include direttamente responsabilità molto differenti:

- download/unpack;
- postinstall;
- certificati;
- PostgreSQL;
- servizi systemd;
- utenti/gruppi;
- desktop/menu/icon Linux;
- symlink e launcher.

Il package manager generale non dovrebbe incorporare direttamente queste politiche host-specific.

### Valutazione preliminare

- provider abstraction: **KEEP / REDESIGN**;
- front controller e path: **REIMPLEMENT**;
- installer monolitico/host-specific: **REDESIGN**.

---

# 8. Package integration come fase autonoma

Il package manager storico distingue esplicitamente `install` da `integrate`.

`integrate` gestisce aspetti come:

- PATH;
- environment;
- command alias/link;
- application alias/link;
- librerie;
- profilo/default;
- hook post-download/post-install.

Il principio è valido: **acquisire un artefatto** e **integrarlo nell'ambiente operativo** sono due responsabilità differenti.

Questa distinzione potrebbe diventare ancora più importante in `rumiai-os`, perché lo stesso package potrebbe essere materializzato in target differenti:

```text
hosted POSIX
container
image
full OS
```

### Problemi di implementazione già verificati

Nel file storico `include/pkg/integrate` sono presenti costrutti non compatibili con il contratto POSIX corrente, tra cui:

```sh
IFS=$'\n'
```

ed uso di opzioni GNU-specifiche di `diff` per ricostruire environment durante la deintegration.

Sono inoltre presenti molte elaborazioni basate su shell word splitting e parsing testuale fragile.

### Valutazione preliminare

**KEEP la fase architetturale. REIMPLEMENT l'implementazione.**

---

# 9. Profili e separazione stato/package

`include/pkg/profile` separa già il package installato dai dati runtime/default:

```text
def/conf
def/data
def/home
```

che vengono materializzati in directory di work separate.

Il codice stesso contiene un TODO sulla compatibilità dello stato fra versioni differenti: è un problema reale che dovrà essere formalizzato in `rumiai-os`.

### Valutazione preliminare

**KEEP / REDESIGN**.

Da approfondire:

- ownership dei dati;
- migrazioni fra versioni;
- reset;
- uninstall senza perdita dati;
- versionamento dello schema di configurazione;
- profili multipli;
- snapshot/rollback.

---

# 10. POSIX compatibility / utility layer

La generazione recente sotto `cmd/lib` contiene almeno:

```text
arg.lib.sh
array.lib.sh
enc.lib.sh
env.lib.sh
log.lib.sh
map.lib.sh
menu.lib.sh
realpaths.lib.sh
term.lib.sh
waituser.lib.sh
```

Questa non è una raccolta casuale di helper: contiene tentativi espliciti di fornire in shell POSIX primitive che normalmente vengono ottenute con Bash, GNU o strutture non disponibili direttamente nello standard.

## 10.1 `array.lib.sh`

Implementa un'API di array sopra namespace di variabili shell, con operazioni:

```text
size
get
put
add
ins
rem
set
unset
```

Utilizza però intensivamente `eval`.

### Valutazione preliminare

**KEEP il requisito; REIMPLEMENT/VERIFY l'implementazione.**

Prima di un eventuale riuso devono essere testati almeno:

- valori contenenti spazi;
- newline;
- wildcard;
- quote;
- backslash;
- stringhe vuote;
- nomi variabile non validi;
- injection tramite valori o nomi;
- comportamento sulle principali shell POSIX target;
- performance su array grandi.

## 10.2 `env.lib.sh`

Implementa un vero meccanismo di passaggio/import/export dello stato shell fra funzioni/comandi e non va trattato semplicemente come utility.

Anche qui `eval` è centrale e richiede un audit specifico di correttezza e sicurezza.

## 10.3 `realpaths.lib.sh`

Tenta di ricostruire path reali e symlink senza dipendere da `readlink -f` GNU.

Il requisito è direttamente coerente con `rumiai-os`, ma la semantica esatta va definita e testata prima di scegliere l'implementazione.

In particolare vanno verificati:

- catene di symlink;
- symlink relativi;
- invocazione attraverso PATH;
- file nella directory corrente senza `/` in `$0`;
- link circolari;
- directory o file con spazi/newline;
- link inesistenti;
- comportamento delle opzioni utilizzate sulle diverse implementazioni POSIX.

### Decisione metodologica

Non assumere che una reimplementazione storica sia automaticamente corretta solo perché evita Bash/GNU.

Ogni primitiva deve avere:

1. contratto esplicito;
2. test di conformità;
3. test edge-case;
4. test cross-shell/cross-host.

---

# 11. POSIX: violazioni e incompatibilità già evidenti

L'audit non è ancora completo, ma sono già presenti esempi concreti di dipendenze non compatibili con le regole correnti.

## Esempi verificati

### Shell syntax non POSIX

```sh
IFS=$'\n'
```

presente nel package integration storico.

### GNU/tool-specific options o behavior

Esempi presenti nella generazione recente del package manager o nei PoC:

```text
grep -P
sort --version-sort
sed -i
diff --old-line-format / --new-line-format / --unchanged-line-format
echo -e
```

Alcuni altri costrutti incontrati, come l'uso di `--` su determinate utility/builtin o particolari opzioni di utility standard, devono essere verificati puntualmente contro la specifica POSIX invece di essere classificati a memoria.

### Dipendenza esplicita da Bash

Lo storico `var/#_os/m/bin/shell`, pur essendo uno script `/bin/sh`, lancia `bash -i` come shell interattiva predefinita sui sistemi non Windows.

Questo non è conforme alla nuova regola se Bash diventa requirement implicito. In `rumiai-os` un'eventuale Bash deve essere software opzionale o eccezione deliberata, non substrato nascosto del core.

---

# 12. Hardcoded paths e host coupling

Esempi verificati:

## `cmd/pkg/pkg`

```text
/m/src/git/m/cmd/pkg/conf
/m/pkg
/m/bin
/m/app
/m/lib
/m/home
/m/conf
```

## `ai/podman-ai.sh`

```text
/m/src/git/m/...
/m/data/podman
```

## `cmd/inst/install`

Integra direttamente il sistema attraverso path e meccanismi Linux-specifici, fra cui:

```text
/etc/environment.d
/etc/sudoers.d
/etc/profile.d
/bin
```

oltre ad assumere `sudo`.

### Valutazione preliminare

Tutti questi elementi sono **REIMPLEMENT/REDESIGN** nel modello `rumiai-os`.

La root portabile deve essere derivata; l'host integration deve essere un adapter o una capability esplicita.

---

# 13. Podman / AI PoC

`ai/podman-ai.sh` è molto utile come cronologia di una sessione sperimentale: costruisce network, volumi, pod e container per Ollama, Open-WebUI, Core-AI, terminal gateway e Python.

Non è invece una base adatta a un deployment engine stabile perché:

- assume un host Debian/Ubuntu (`apt`);
- modifica configurazioni globali Podman;
- contiene path locali;
- esegue reset/rimozioni globali e distruttive di immagini, volumi, container e pod;
- incorpora nello stesso script provisioning, configurazione, sorgente applicativo e test manuali.

### Valutazione preliminare

**KEEP come evidenza/PoC; REDESIGN completamente per un futuro target Podman.**

Materiale di questo tipo appartiene concettualmente a `rumiai-dev-PoCs` finché non emerge un backend Podman stabile.

---

# 14. Separazione idea / implementazione: prima classificazione

| Elemento | Concetto | Implementazione attuale | Classificazione preliminare |
|---|---|---|---|
| Root semantica | forte | mescolata con platform detection | KEEP / REDESIGN |
| Entrypoint minimale | forte | semplice e relocatable | KEEP |
| `pkg/sys/usr/wrk` separation | forte | da rivedere nei dettagli | KEEP / REDESIGN |
| Work dirs `conf/data/home/log/pid/tmp` | forte | naming/layout da validare | KEEP / REDESIGN |
| Package `name/platform/version` | utile | resolver incompleto | KEEP / REDESIGN |
| Version range | necessario | comparator troppo limitato | REDESIGN |
| Dependency graph | necessario | incompleto/TODO | REDESIGN |
| Package skeleton + vendor binary | molto interessante | va formalizzato | KEEP / REDESIGN |
| `install` vs `integrate` | forte | integration fragile/non-POSIX | KEEP / REIMPLEMENT |
| Repository/provider adapters | forte | API da formalizzare | KEEP / REDESIGN |
| Package metadata come shell eseguibile | flessibile | aumenta coupling e rischio | REDESIGN |
| Postinstall shell hooks | talvolta necessari | trust model assente | REDESIGN |
| POSIX array abstraction | requisito utile | `eval`-heavy | VERIFY / REIMPLEMENT |
| Environment/state abstraction | interessante | `eval`-heavy | VERIFY / REDESIGN |
| Portable realpath | necessario | edge case da testare | VERIFY / REIMPLEMENT |
| `.mk` profile/target concepts | forte | da audit dedicato | KEEP / REDESIGN |
| OS detection globale | storicamente utile | troppo pervasiva per il nuovo contratto | REDESIGN |
| Windows bootstrap | utile come riferimento | non deve influenzare il core | REFERENCE ADAPTER |
| `cmd/inst` Linux integration | utile come intento | host-specific | REIMPLEMENT AS ADAPTER |
| `podman-ai.sh` | ottimo PoC storico | monolitico e distruttivo | KEEP AS PoC / REDESIGN |
| path `/m/...` | nessun valore architetturale | viola relocatability | DROP |

---

# 15. Gap importanti da verificare nell'audit del package manager

L'analisi successiva deve stabilire con precisione se e come il sistema gestisce:

1. dependency cycles;
2. version conflicts;
3. multiple compatible versions;
4. virtual packages / providers / alternatives;
5. optional dependencies;
6. package pinning;
7. lock file / reproducibility;
8. checksum e firma degli artefatti;
9. repository trust;
10. offline cache;
11. atomic installation;
12. transaction/rollback;
13. recovery dopo interruzione;
14. concurrency e locking;
15. idempotency;
16. upgrade dello stato utente/configurazione;
17. downgrade;
18. package provenance;
19. license metadata;
20. host capability requirements;
21. separation fra package metadata e codice eseguibile;
22. sandboxing dei lifecycle hooks;
23. target-specific integration;
24. container/image materialization;
25. uninstall senza perdita di user data.

---

# 16. Sicurezza: aree prioritarie

Senza ancora formulare un audit di sicurezza completo, sono già emerse aree che richiedono attenzione:

- uso esteso di `eval` nelle librerie shell;
- sourcing di file di configurazione/package;
- hook package eseguibili;
- download di binari da repository/vendor;
- esempi recenti con verifica TLS disabilitata;
- operazioni `sudo` e modifiche host-global;
- installazione di servizi e utenti;
- assenza ancora da verificare di checksum/firme/manifest immutabili;
- operazioni distruttive globali negli script PoC.

Queste aree devono essere separate fra:

```text
trusted system code
trusted package manifest
untrusted remote metadata
untrusted payload
privileged host operation
```

Il nuovo package manager non dovrebbe trattarle come equivalenti.

---

# 17. Implicazioni preliminari per `rumiai-os`

Senza ancora definire la struttura definitiva del repository, l'audit suggerisce che `rumiai-os` avrà probabilmente bisogno di responsabilità distinte per:

```text
bootstrap/root discovery
semantic filesystem
POSIX primitives
package catalog/repository providers
package resolver
package acquisition
package materialization
package integration
profiles/state
platform/host adapters
target adapters
deployment
```

Non è ancora deciso che queste responsabilità corrispondano una-a-una a directory o processi.

L'architettura va definita solo dopo il completamento dei deep dive.

---

# 18. Ordine dei prossimi deep dive

Priorità proposta sulla base dell'inventario:

## A. Package manager storico

Analizzare integralmente:

```text
var/#_os/m/bin/pkg
var/#_os/m/bin/include/pkg/*
var/#_os/m/def/data/pkg/*
```

Output atteso:

- modello dati;
- resolver;
- lifecycle;
- dependency graph;
- integration model;
- trust/security model;
- problemi concreti;
- concetti da recuperare.

## B. POSIX primitive layer

Confrontare:

```text
var/#_os/m/bin/m-*.lib
cmd/lib/*.lib.sh
```

Output atteso:

- inventario delle primitive;
- duplicazioni/evoluzioni;
- conformità POSIX;
- casi di test;
- API candidate.

## C. `mk` / target / profile

Ricostruire il modello storico di composizione e materializzazione.

## D. Bootstrap / environment

Confrontare:

```text
var/#_os/install
cmd/inst
```

per separare root bootstrap, host adapter e system integration.

## E. Podman/deployment

Usare i PoC esistenti per estrarre requisiti del futuro target adapter, senza migrare script monolitici.

---

# 19. Prima conclusione dell'audit

Il repository `m` non è semplicemente una raccolta di vecchi script da ripulire.

Contiene già diversi embrioni della vision attuale di `rumiai-os`, in particolare:

- portable root;
- semantic filesystem;
- package store;
- package manager modulare;
- package integration;
- profili;
- target;
- primitive POSIX;
- compatibility substrate;
- container experimentation.

Il problema principale non sembra quindi essere inventare tutti i concetti da zero, ma **separare e formalizzare quelli validi, rimuovere le assunzioni storiche e costruire una nuova implementazione verificabile rispetto alle regole correnti**.

La direzione di audit rimane pertanto:

```text
understand → isolate concepts → test assumptions → classify → specify → PoC → implement in rumiai-os
```
