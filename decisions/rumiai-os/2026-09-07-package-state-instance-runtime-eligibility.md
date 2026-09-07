# Decisione — Eligibilita runtime delle State Instance rispetto a `var/`

Date: 2026-09-07  
Status: **Accepted**

## Contesto

Il modello corrente dei package ha gia fissato:

- lo state normale sotto `$m_ROOT/<area>/<pkg>/`;
- la forma riservata delle State Instance nominate sotto `$m_ROOT/<area>/<pkg>@!<state-instance>/`;
- `var/` come routing view package-local necessaria quando lo upstream raggiunge parte dello state tramite pathname del proprio installation tree;
- l'environment standard di isolamento costruito dal `launcher` usando direttamente le root semantiche;
- `<package-version>/env` e l'env persistente utente come frammenti shell sourced dal `launcher`;
- la prima baseline operativa limitata allo state non qualificato;
- la gestione operativa delle State Instance come funzione successiva e opzionale.

La decisione `2026-09-06-package-self-contained-launch-and-default-state.md` distingueva gia fra:

1. state completamente controllabile tramite environment, potenzialmente selezionabile a runtime;
2. state che usa anche `root/ -> var/ -> state`, non selezionabile correttamente per singola invocazione.

La presente decisione rende questo confine strutturale e normativo.

Non introduce classi, nomi di prodotto, metadata o nuove primitive. Fissa soltanto quando una State Instance puo essere attivata a runtime e quando, invece, una futura selezione deve essere persistente a livello package.

Questa unita di lavoro modifica soltanto `rumiai-dev`. Non autorizza modifiche a `rumiai-os` o `rumiai-tests`.

---

## 1. Principio fondamentale

La presenza di routing state tramite package-local `var/` e incompatibile con l'attivazione runtime di una State Instance.

Regola:

```text
package che usa var/ per lo state
    -> State Instance runtime vietata
```

Motivo:

```text
root/<path>
    -> var/<area>/<path>
        -> state selezionato persistentemente
```

costituisce routing statico materializzato nel filesystem.

Cambiare soltanto le environment variables del processo verso una State Instance differente produrrebbe due identita di state contemporanee:

```text
environment -> State Instance A
var/        -> State Instance B
```

Il modello RumiAI non ammette questa possibile divergenza.

La regola non dipende dal fatto che, per uno specifico launch, il programma usi effettivamente o meno ogni pathname raggiungibile tramite `var/`: se il package usa `var/` come parte del proprio contratto state, la State Instance non e selezionabile per-invocation.

---

## 2. Significato di "package che usa `var/`"

La condizione e semantica.

Un package usa `var/` quando la versione concreta materializzata contiene almeno un routing state necessario del tipo:

```text
<package-version>/var/<area>
```

utilizzato direttamente o tramite un pathname upstream normalizzato:

```text
root/<path> -> var/<area>/<path>
```

La mera esistenza accidentale di una directory `var/` vuota non deve creare una diversa semantica. Una `var/` vuota e non necessaria non deve essere materializzata soltanto per uniformare il layout.

`var/` continua ad avere esattamente la responsabilita gia fissata: routing package-local dello state non completamente indirizzabile tramite environment.

---

## 3. Package con `var/`: State Instance solo tramite selezione persistente package-level

Quando un package usa `var/`, una futura State Instance alternativa puo essere selezionata soltanto come stato persistente del package.

La selezione:

- e gestita da `pkg`;
- non e un override per singola invocazione;
- non viene scelta autonomamente dal `launcher`;
- deve avvenire con il package non in esecuzione;
- deve mantenere coerenti tutte le rappresentazioni dello state usate dal package, inclusi i routing `var/` e l'environment costruito dal launcher;
- resta valida per i launch successivi finche non viene effettuata una nuova selezione persistente.

Il normale launch non deve poter ricevere una State Instance runtime che contraddica la selezione persistente materializzata dal package.

La forma fisica resta:

```text
$m_ROOT/<area>/<pkg>@!<state-instance>/
```

quando una State Instance nominata e selezionata.

L'esatto meccanismo futuro con cui `pkg` rappresentera una selezione package-level, aggiornera coerentemente i routing `var/`, impedira cambi mentre il package e in esecuzione e garantira atomicita/recovery resta aperto.

Questa funzione non e richiesta dalla prima implementazione, che puo continuare a usare soltanto lo state non qualificato.

---

## 4. Package senza `var/` ma con state

Se un package non usa `var/` e possiede state gestito da RumiAI, tutto lo state rilevante all'esecuzione deve essere indirizzabile completamente tramite environment.

Regola:

```text
package senza var/
    + state gestito
    -> state interamente controllabile via environment
    -> State Instance attivabile a runtime
```

In questo caso non esiste routing package-local statico concorrente da mantenere sincronizzato.

Una futura selezione runtime puo quindi essere realizzata dal `launcher` scegliendo le destinazioni environment appropriate per la singola esecuzione.

Per lo state normale:

```text
$m_<AREA>_DIR/<pkg>
```

Per una State Instance nominata:

```text
$m_<AREA>_DIR/<pkg>@!<state-instance>
```

secondo il mapping environment standard che verra fissato separatamente.

L'attivazione runtime non richiede modifiche a:

```text
current
root/
cmd/
link/
var/
```

poiche `var/` non appartiene a questo caso.

La sintassi CLI, il modo con cui il caller comunica al launcher la State Instance e gli eventuali override di `pkg run` restano separati e non vengono fissati qui.

---

## 5. Env utente della State Instance runtime

Quando in futuro una State Instance viene attivata a runtime per un package senza `var/`, il layering dell'environment resta invariato ma l'env persistente utente appartiene alla State Instance selezionata.

Quindi il layer utente e:

```text
$m_CONF_DIR/<pkg>/env
```

per lo state normale, oppure:

```text
$m_CONF_DIR/<pkg>@!<state-instance>/env
```

per la State Instance runtime selezionata.

Il package env version-specific resta invece:

```text
<package-version>/env
```

indipendente dalla State Instance.

La sequenza resta:

```text
isolation environment per lo state selezionato
    -> source <package-version>/env
    -> source env utente dello state selezionato
    -> eventuali override caller
    -> exec
```

---

## 6. Package senza `var/` e senza state

Un package che non usa `var/` e non possiede state gestito da RumiAI e un normale tool stateless dal punto di vista del package manager.

Per tale package una State Instance non ha semantica da applicare.

Regola:

```text
package senza var/
    + nessuno state gestito
    -> State Instance non applicabile
```

La presenza di `<package-version>/env` per dependency, toolchain o compatibilita non costituisce da sola state del package e non rende necessaria una State Instance.

Non viene introdotta una State Instance vuota o artificiale soltanto per uniformare il modello.

---

## 7. Nessuna terza categoria supportata dal baseline

Nel modello package corrente, un package con state gestito che non puo indirizzare completamente tale state tramite environment deve usare `var/` per i pathname upstream dichiarabili che richiedono routing.

Di conseguenza il baseline supportato converge alle sole proprieta strutturali seguenti:

```text
var/ presente e usato
    -> state almeno in parte pathname-routed
    -> nessuna State Instance runtime

var/ assente + state presente
    -> state completamente environment-routed
    -> State Instance runtime possibile

var/ assente + state assente
    -> State Instance non applicabile
```

Software che produce state non controllabile ne tramite environment ne tramite i pathname dichiarabili/normalizzabili con `var/` resta un caso difficile fuori dal baseline e richiede una strategia mirata quando emergera.

---

## 8. Relazione con il launcher

Il `launcher` non deve inferire liberamente se una State Instance runtime sia sicura.

Quando la funzione verra implementata, il contratto del package deve rendere determinabile se il launch corrente appartiene al caso senza `var/` e con state completamente controllabile tramite environment.

Questa decisione non fissa ancora il metadata o il meccanismo con cui tale proprieta viene materializzata da `pkg install`.

Resta vietato introdurre un secondo routing runtime che tenti di scavalcare `var/`.

Per un package con `var/`, il launcher usa sempre la selezione state persistente del package.

Per un package senza `var/` e con state, il launcher puo usare la State Instance scelta per la singola esecuzione quando l'interfaccia corrispondente verra definita.

---

## 9. Relazione con `pkg run`

`pkg run` resta fuori dal normale launch path e, quando usato, deve delegare allo stesso `cmd/<command>` e allo stesso `launcher`.

Una futura option di `pkg run` per selezionare una State Instance per-invocation e semanticamente valida soltanto per package senza `var/` il cui state sia completamente controllabile tramite environment.

Per package che usano `var/`, `pkg run` non deve offrire un override State Instance per la singola invocazione.

L'eventuale cambio di State Instance per tali package appartiene a una distinta operazione persistente package-level eseguita con il package non in esecuzione.

La sintassi di entrambe le funzioni resta aperta.

---

## 10. Supersession e chiarimenti

Questa decisione completa e prevale sulle parti meno restrittive delle decisioni precedenti relative all'eligibilita runtime delle State Instance.

### `2026-09-06-package-self-contained-launch-and-default-state.md`

Sono sostituiti/precisati gli invarianti:

```text
PKG-STATE-FUTURE-01
PKG-STATE-FUTURE-02
PKG-STATE-FUTURE-03
```

Il precedente "una futura selezione runtime e possibile solo quando..." diventa una regola strutturale completa:

```text
var/ usato -> runtime State Instance vietata
no var/ + state -> state completamente via env -> runtime State Instance ammessa
no var/ + no state -> State Instance non applicabile
```

Resta valida la decisione che una selezione alternativa per package con `var/` sia package-level, persistente e avvenga con package non in esecuzione.

### `2026-09-05-package-state-var-default.md`

Le sezioni che mostrano `var/<area>` puntare a una State Instance nominata restano valide esclusivamente per una State Instance selezionata persistentemente a livello package.

Non devono essere interpretate come supporto a uno switch runtime/per-invocation di `var/`.

La forma `<pkg>@!<state-instance>` e il separatore `@!` restano invariati.

### `2026-09-06-package-env-shell-source.md`

Il contratto sourced degli `env` resta invariato.

Quando una State Instance runtime e supportata, l'env utente sourced deve appartenere allo state selezionato, come fissato nella sezione 5 della presente decisione.

---

## 11. Implementazione e test

Alla data di questa decisione la gestione delle State Instance non e ancora implementata nel prodotto e `rumiai-tests` non contiene test permanenti `pkg`/State Instance.

Questa decisione consolida soltanto il design.

Quando la funzione verra implementata, i test permanenti dovranno proteggere almeno:

```text
package con var/ -> override State Instance runtime rifiutato/non disponibile
package con var/ -> eventuale selezione alternativa soltanto persistente package-level
package senza var/ + state -> State Instance runtime applicata tramite environment
package senza var/ + state -> env utente sourced dalla State Instance selezionata
package senza var/ + no state -> nessuna State Instance artificiale
assenza di divergenza fra environment e var/
pkg run non bypassa queste regole
```

I dettagli operativi verranno testati insieme alla loro futura implementazione.

---

## 12. Invarianti fissati

```text
PKG-SI-RUNTIME-01  un package che usa var/ per lo state non puo attivare una State Instance a runtime o per-invocation
PKG-SI-RUNTIME-02  per un package con var/, una futura State Instance alternativa e selezione persistente package-level gestita da pkg con package non in esecuzione
PKG-SI-RUNTIME-03  una selezione persistente di un package con var/ deve mantenere coerenti routing var/ ed environment; il meccanismo atomico resta da fissare
PKG-SI-RUNTIME-04  un package senza var/ che possiede state gestito deve avere tutto lo state rilevante controllabile tramite environment
PKG-SI-RUNTIME-05  un package senza var/ con state gestito e strutturalmente idoneo all'attivazione runtime di State Instance
PKG-SI-RUNTIME-06  una State Instance runtime seleziona direttamente le destinazioni $m_<AREA>_DIR/<pkg>@!<state-instance> dell'environment
PKG-SI-RUNTIME-07  per una State Instance runtime l'env utente e $m_CONF_DIR/<pkg>@!<state-instance>/env
PKG-SI-RUNTIME-08  un package senza var/ e senza state gestito non usa State Instance
PKG-SI-RUNTIME-09  la presenza del solo package env version-specific non costituisce state e non rende applicabile una State Instance
PKG-SI-RUNTIME-10  non esiste nel baseline un override runtime State Instance che conviva con routing state via var/
PKG-SI-RUNTIME-11  pkg run puo offrire in futuro una selezione State Instance per-invocation solo ai package senza var/ con state completamente environment-routed
PKG-SI-RUNTIME-12  software con state non controllabile ne via environment ne via var/ resta fuori dal baseline e richiede strategia mirata
```
