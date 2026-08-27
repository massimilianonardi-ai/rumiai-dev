# Audit di `massimilianonardi/m` — Bootstrap e deployment

Data: 2026-08-27

Snapshot:

```text
e4faae1c1d9b27cc5503b987ba5e7bf2874c906c
```

## Scopo

Confrontare:

```text
var/#_os/install/*
cmd/inst/*
ai/podman-ai.sh
```

per separare correttamente nel futuro `rumiai-os`:

```text
bootstrap del sistema
root initialization
host integration
deployment environment
PoC provisioning
```

---

# 1. Due filosofie di installazione differenti

Nel repository convivono almeno due generazioni molto diverse.

## Storica: `var/#_os/install`

È orientata a creare un **filesystem portabile sotto una root scelta**.

Il POSIX installer ricava directory come:

```text
ROOT_DIR
SRC_DIR
PKG_DIR
WRK_DIR
DATA_DIR
```

ed installa/copia il sistema dentro tale root.

Questa filosofia è molto vicina alla vision corrente di `rumiai-os`.

## Recente: `cmd/inst`

È orientata a integrare `/m` nel sistema Linux host.

Scrive o rimuove elementi in:

```text
/etc/environment.d
/etc/sudoers.d
/etc/profile.d
/bin
```

ed assume `sudo` e altri comportamenti Linux-specifici.

Questa seconda filosofia non può diventare il bootstrap universale di `rumiai-os`.

---

# 2. Bootstrap vs host integration

L'audit suggerisce una separazione netta di responsabilità.

## Bootstrap

Deve fare soltanto ciò che serve per rendere vivo `rumiai-os` nella propria root.

Esempio concettuale:

```text
locate repository/runtime root
validate minimum POSIX requirements
initialize semantic filesystem
load core commands
enter RumiAI OS environment
```

## Host integration

È opzionale e dipende dal substrato.

Può includere, per esempio:

```text
system-wide PATH integration
login/profile integration
service manager integration
desktop launcher integration
privileged device access
```

Queste operazioni non appartengono al core bootstrap.

### Regola candidata

> `rumiai-os` deve essere utilizzabile senza modificare globalmente l'host. L'integrazione host-wide è una capability/deployment choice esplicita.

---

# 3. Root scelta dall'utente / root derivata

Lo storico `var/#_os/install/install` accetta una root o usa la directory corrente.

Questo è concettualmente più sano del recente `/m` hardcoded.

Tuttavia la nuova architettura deve distinguere due casi:

```text
repository root
runtime/system root
```

che inizialmente possono coincidere ma non devono essere confusi per definizione.

Questo sarà importante quando `rumiai-os` dovrà:

- avviarsi direttamente dal clone;
- materializzare un'altra root;
- costruire un container;
- costruire un'immagine;
- preparare un device.

---

# 4. Entry point

Lo storico:

```text
var/#_os/install/m
```

mostra il pattern corretto: entrypoint minuscolo, `/bin/sh`, delega immediata al sistema relativo alla propria posizione.

Il nuovo file root:

```text
rumiai-os
```

dovrebbe conservare questa proprietà.

Non deve diventare:

- installer Linux;
- installer Cygwin;
- Podman builder;
- flasher;
- package manager monolitico.

Deve essere il **front controller stabile** dal quale si raggiungono queste capability.

---

# 5. Windows/Cygwin storico

`var/#_os/install` contiene script Windows e Cygwin.

Il valore di questi file è storico e operativo: dimostrano che il progetto ha già usato un substrato Unix-like per offrire lo stesso ambiente sopra Windows.

La decisione corrente di `rumiai-os` è però più semplice:

```text
platform contract = POSIX
```

Quindi Windows non richiede una nuova architettura interna.

La documentazione può raccomandare Cygwin; eventuali helper di preparazione possono esistere come tooling separato, ma non devono contaminare il core POSIX.

---

# 6. `cmd/inst/install-online`: problemi concreti

Lo script recente contiene:

```text
/m/src/git/m
apt
sudo -s
git clone
```

quindi è specifico di una famiglia Linux e di un layout locale.

Nei commenti compare anche un esempio `wget --no-check-certificate`.

## Classificazione

**DROP come modello generale; eventualmente conservare come riferimento storico di host provisioning.**

Per `rumiai-os` un online bootstrap non dovrebbe:

- imporre `/m`;
- assumere APT;
- ottenere root privileges per tutta la procedura;
- suggerire la disabilitazione della verifica TLS;
- installare direttamente nell'host prima di avere un piano verificabile.

---

# 7. Privilege model

Gli installer recenti usano `sudo` direttamente.

Questo suggerisce un requisito che il nuovo sistema deve formalizzare:

```text
unprivileged core
        ↓
privileged operation request
        ↓
explicit host/deployment adapter
        ↓
smallest required privileged action
```

### Principio candidato

> Il core di `rumiai-os` deve funzionare senza privilegi elevati quando l'operazione richiesta non li necessita. L'elevazione deve essere puntuale, esplicita e confinata.

Questo riduce sia il rischio sia la dipendenza dall'host.

---

# 8. Idempotenza e ownership dell'host

`cmd/inst/install` e `uninstall` manipolano file globali con nomi fissi.

Il nuovo modello deve poter rispondere a domande che l'implementazione storica non formalizza abbastanza:

```text
chi ha creato questa modifica?
qual era il valore precedente?
è sicuro sovrascriverla?
più installazioni possono coesistere?
la rimozione ripristina esattamente lo stato precedente?
```

L'host integration deve quindi avere ownership/state tracking e non essere una semplice sequenza di `rm`, `ln`, `echo` e `sudo`.

---

# 9. Deployment Podman storico

`ai/podman-ai.sh` costruisce concretamente uno stack AI con Podman e contiene quindi molti requisiti reali:

- storage;
- network;
- volumi;
- pod;
- container;
- immagini;
- configurazione CA;
- Ollama;
- Open-WebUI;
- Core-AI;
- terminal gateway;
- Python environments.

## Valore

È utile come **testimony of requirements**: mostra quali operazioni un futuro backend Podman deve saper esprimere.

## Problemi

Lo script è un PoC imperativo e include:

- path `/m/...` hardcoded;
- host Debian/Ubuntu assumptions;
- `apt`;
- modifiche alla configurazione globale Podman;
- reset globali/distruttivi;
- provisioning e test mescolati;
- shell constructs/tool options da verificare rispetto a POSIX.

### Classificazione

```text
requirements/evidence: KEEP
script as product code: DROP/REIMPLEMENT
```

---

# 10. Deployment non deve essere un caso speciale nel core

La vision corrente richiede almeno:

```text
hosted POSIX root
Podman container/environment
OS image
device flashing
future bare-metal
```

Il core non dovrebbe contenere `if podman`, `if image`, `if device` distribuiti nel codice.

Serve una separazione concettuale:

```text
System Definition
       ↓
Resolved System Plan
       ↓
Materializer / Deployment Adapter
       ├── hosted-root
       ├── podman
       ├── image
       └── device
```

L'adapter traduce il piano nello specifico substrato.

---

# 11. Device flashing

Il repository `m` analizzato finora non ha ancora fornito evidenza sufficiente di un flasher generalizzato paragonabile alla vision attuale.

Questo requisito va quindi trattato come capability futura da progettare, non come qualcosa che possiamo assumere già risolto nel codice storico.

Il design dovrà distinguere almeno:

```text
build image
validate image
select target device
safety confirmation
write image
verify write
```

La selezione del device è un'operazione ad alto rischio e non dovrà mai essere implicita.

---

# 12. Un solo modello, più materializzazioni

Il principio architetturale più importante che emerge dal confronto è:

> Non dobbiamo avere un installer per il portable OS, uno script indipendente per Podman e un altro sistema completamente diverso per le immagini.

Dobbiamo puntare a:

```text
one resolved system model
        ↓
multiple materializers
```

La parte condivisa deve risolvere:

- componenti;
- package/versioni;
- configurazione;
- servizi;
- capability;
- filesystem intent;
- user/system state policy.

La parte specifica deve solo trasformare quel piano nel substrato richiesto.

---

# 13. Hosted environment come primo materializer

Per ordine di sviluppo il primo deployment adapter dovrebbe essere il più semplice:

```text
POSIX directory/root on current host
```

Questo consente di validare:

- root discovery;
- relocatability;
- package manager;
- state model;
- profile;
- system commands;

senza introdurre subito container/image/device complexity.

In seguito lo stesso piano potrà essere materializzato in Podman.

---

# 14. Bootstrapping chain candidata

Modello da approfondire:

```text
Host POSIX environment
        ↓
./rumiai-os
        ↓
minimal root discovery
        ↓
core system bootstrap
        ↓
semantic filesystem + command environment
        ↓
package/provisioning services
        ↓
RumiAI OS running
        ↓
deploy/materialize another environment if requested
```

Questo rende coerente la scelta di avere `rumiai-os` come unico entrypoint root anche quando l'obiettivo finale è un'altra macchina o un device.

---

# 15. Classificazione preliminare

| Elemento | Classificazione |
|---|---|
| root-relative historical install | KEEP / REIMPLEMENT |
| tiny historical `m` entrypoint | KEEP pattern |
| `/m` as mandatory root | DROP |
| Linux global host installer | REIMPLEMENT as optional adapter |
| `sudo` throughout installer | REDESIGN privilege model |
| Cygwin support | KEEP as documented/tested substrate, not core branch |
| online pipe-to-shell installer | REDESIGN |
| TLS verification bypass examples | DROP |
| Podman PoC requirements | KEEP |
| Podman PoC implementation | REIMPLEMENT |
| materialize arbitrary test root | KEEP strongly |
| one system model → multiple environments | TARGET ARCHITECTURAL DIRECTION |

---

# 16. Fase 1: stato dopo questo documento

Con questo deep dive la mappa architetturale iniziale di `m` copre ormai i quattro blocchi prioritari:

```text
portable OS/root
package manager
POSIX primitives
mk/profile/target
bootstrap/deployment/Podman
```

Il passaggio successivo non dovrebbe ancora essere scrivere `rumiai-os`.

Prima conviene trasformare l'audit in:

1. **requirements estratti da `m`**;
2. **decisioni architetturali candidate**;
3. **test PoC minimi** per le primitive fondazionali;
4. solo dopo, prima struttura stabile di `rumiai-os`.
