# Decisione — Package manager: `root/`, `cmd/` e binding diretto

Date: 2026-09-05  
Status: **Accepted**

## Contesto

La decisione Accepted `2026-09-05-package-manager-current-and-run-model.md` ha fissato:

- `$m_ROOT/pkg/` come dominio locale dei package gestiti;
- la coesistenza di più versioni concrete dello stesso package;
- `current` come selector persistente relativo della versione predefinita;
- `pkg run` come punto di mediazione quando il launch richiede gestione;
- `bin/ext/` e `bin/ext-<osarch>/` come binding pubblici di comandi third-party;
- la possibilità di usare un symbolic link diretto quando il launch non richiede mediazione;
- la distinzione `package != command`.

Restavano aperti il modo concreto con cui una versione del package espone i propri command e la forma semantica del binding diretto verso il package selezionato.

Questa decisione chiude tali punti mantenendo separati il tree upstream e le strutture package-local RumiAI. La successiva decisione Accepted `2026-09-05-package-state-var-default.md` precisa inoltre che `pkg install` puo normalizzare pathname upstream mutabili sotto `root/` sostituendoli con symbolic link relativi verso la package-local state view `var/`.

Non modifica il runtime/bootstrap corrente e non autorizza modifiche a `rumiai-os`.

---

## 1. Separazione fra tree upstream e strutture RumiAI

Ogni versione concreta di un package usa, per le responsabilità qui fissate, questa struttura concettuale minima:

```text
<package-version>/
├── root/
└── cmd/
```

`root/` e il tree di esecuzione del software upstream appartenente a quella versione concreta del package.

`cmd/` appartiene invece al packaging RumiAI e costituisce l'interfaccia package-local dei command esposti.

Le due responsabilità non devono essere mischiate.

In particolare, RumiAI non deve usare pathname interni a `root/` come `cmd`, `bin`, `lib`, `tools`, `current`, `pkg` o altri nomi per attribuire automaticamente semantica di package-manager: i pathname sotto `root/` sono definiti dal software upstream.

Di conseguenza un eventuale:

```text
root/cmd/
```

appartiene al namespace upstream e non ha relazione con:

```text
<package-version>/cmd/
```

che e invece controllato da RumiAI.

La separazione non implica che `root/` sia una copia fisicamente intatta del payload upstream. Per i pathname che il packaging dichiara mutabili/state-bearing, `pkg install` puo sostituire l'entry upstream con un symbolic link relativo verso `var/<area>/<root-relative-path>` secondo `2026-09-05-package-state-var-default.md`.

Questa normalizzazione non introduce un nuovo namespace RumiAI dentro `root/`: conserva il pathname upstream e ne cambia soltanto la rappresentazione fisica per separare software e stato mutabile.

La vecchia regola universale di root immutabile con admission/rejection, inventory e wrapper `root/run-default/run` non viene ripristinata automaticamente.

---

## 2. Namespace package-local `cmd/`

Per ogni command esposto da una versione concreta del package:

```text
<pkg-command>
```

il pathname RumiAI corrispondente è esattamente:

```text
<package-version>/cmd/<pkg-command>
```

`<pkg-command>` è quindi un nome di command, non un pathname arbitrario dentro il tree upstream.

`pkg` non deve accettare un pathname upstream come sostituto di `<pkg-command>` e non deve dedurre command cercando executable dentro `root/`.

I command disponibili sono quelli esposti esplicitamente sotto `cmd/`.

---

## 3. `cmd/<pkg-command>` come symbolic link relativo

Ogni:

```text
<package-version>/cmd/<pkg-command>
```

è un symbolic link relativo che deve risolvere verso l'executable reale appartenente al package e contenuto nel tree di esecuzione:

```text
<package-version>/root/
```

Esempio:

```text
<package-version>/
├── root/
│   ├── bin/
│   │   └── mycommand
│   └── tools/
│       └── mytool
└── cmd/
    ├── mycommand -> ../root/bin/mycommand
    └── mytool    -> ../root/tools/mytool
```

Il package manager conosce quindi:

```text
cmd/mycommand
cmd/mytool
```

ma non deve conoscere né inferire il layout upstream che porta agli executable reali.

Il target del link può attraversare ulteriori symlink del tree di esecuzione, inclusi i link di normalizzazione state quando semanticamente applicabile, purché il command esposto appartenga al package.

---

## 4. Risoluzione di `<pkg-command>` da parte di `pkg run`

Quando `pkg run` deve eseguire uno specifico `<pkg-command>`:

1. seleziona la versione concreta appropriata tramite `current` o un eventuale override per-invocation già ammesso dal modello corrente;
2. costruisce esattamente il pathname package-local:

```text
<selected-package-version>/cmd/<pkg-command>
```

3. usa tale binding per raggiungere l'executable del package;
4. applica l'eventuale mediazione richiesta dal launch;
5. inoltra gli argomenti destinati al programma secondo la sintassi CLI che verrà fissata separatamente.

Non sono ammessi come comportamento normale:

- scansione di `root/bin`, `root/tools`, `root/libexec` o directory equivalenti;
- ricerca ricorsiva di executable;
- inferenza del command dal basename di file upstream non esposti in `cmd/`;
- uso diretto di un pathname upstream fornito dall'utente al posto di `<pkg-command>`.

Il full syntax contract di `pkg run`, inclusi option names e delimitazione finale degli argomenti del programma, resta separato da questa decisione.

---

## 5. Binding pubblico diretto

Quando un command third-party non richiede mediazione di `pkg run`, resta valido il binding diretto già ammesso dalla decisione precedente.

Questa decisione ne fissa la catena semantica:

```text
bin/ext*/<pkg-command>
    -> current
        -> <selected-package-version>/cmd/<pkg-command>
            -> <selected-package-version>/root/<upstream-executable>
```

Il binding pubblico diretto:

1. è un symbolic link relativo;
2. deve risolvere attraverso il selector `current` del package;
3. deve terminare sull'interfaccia package-local `cmd/<pkg-command>`;
4. non deve puntare direttamente a un pathname sotto `root/`;
5. non deve pinningare una versione concreta bypassando `current`.

La forma testuale esatta del target relativo non viene fissata qui perché il pathname concreto delle versioni e del selector `current` resta ancora aperto.

---

## 6. Collocazione del binding pubblico

La collocazione continua a seguire il runtime già Accepted:

```text
bin/ext/<pkg-command>
```

quando il binding è valido platform-independently, oppure:

```text
bin/ext-<osarch>/<pkg-command>
```

quando il binding è specifico del target.

`bin/ext-osarch` resta il symlink relativo alla directory `ext-<osarch>` attiva e non introduce una terza classe di binding.

La scelta fra `bin/ext/` e `bin/ext-<osarch>/` dipende dalla validità del binding rispetto al target e non dalla posizione interna dell'executable upstream sotto `root/`.

---

## 7. Criterio per usare il binding diretto

Il binding diretto è appropriato soltanto quando il launch reale si riduce sostanzialmente all'esecuzione del command esposto con gli argomenti dell'utente e non richiede mediazione RumiAI a runtime.

Esempi di condizioni che rendono necessaria la mediazione e quindi escludono il binding diretto includono:

- environment package-specific da applicare al launch;
- HOME o altre location da impostare tramite environment;
- dependency da selezionare o collegare per il launch;
- working directory speciale;
- argomenti fissi di launch;
- altra preparazione/adattamento dinamico richiesto dal packaging.

La presenza di state non esclude da sola il binding diretto. Se i pathname mutabili sono stati completamente normalizzati da `pkg install` tramite la catena statica:

```text
root/<path> -> var/<area>/<path> -> state selezionato
```

e il processo non richiede altre modifiche runtime, il command puo ancora essere eseguito tramite binding diretto.

Lo state selezionato puo essere il normale `$m_ROOT/<area>/<pkg>/` oppure, quando attivata, una State Instance nominata `$m_ROOT/<area>/<pkg>-<state-instance>/`.

Questa distinzione non introduce classi o nomi di prodotto per package "semplici" o "complessi": descrive esclusivamente due forme di binding già previste dal modello corrente.

---

## 8. Esempio concettuale

Per un package che espone direttamente `ls`:

```text
<package-version>/
├── root/
│   └── .../ls
└── cmd/
    └── ls -> ../root/.../ls
```

il binding pubblico segue concettualmente:

```text
bin/ext-<osarch>/ls
    -> <package-current-selector>/cmd/ls
        -> ../root/.../ls
```

oppure usa `bin/ext/ls` se quel binding è realmente platform-independent.

Cambiare `current` cambia quindi anche la versione raggiunta dal normale comando pubblico `ls`, senza modificare il binding in `bin/ext*`.

Poiché questa esecuzione non passa da `pkg run`, eventuali override per-invocation che richiedono mediazione non si applicano al binding diretto.

---

## 9. Relazione con il vecchio `cmd/` superseded

La directory package-local:

```text
<package-version>/cmd/
```

non riapre il precedente modello RumiAI command-entry basato su multicall + directory shadow `cmd/`, che resta superseded.

I due concetti hanno scope e responsabilità differenti:

```text
vecchio command-entry cmd/
    superseded

package-local <package-version>/cmd/
    interfaccia RumiAI dei command di una specifica versione di package third-party
```

---

## 10. Questioni ancora aperte

Questa decisione non fissa:

1. pathname esatto delle versioni concrete sotto `$m_ROOT/pkg/`;
2. pathname esatto e grammatica del selector `current`;
3. regola finale per selector target-qualified vs condivisi quando il package è realmente target-independent;
4. formato di eventuali metadata/descriptor oltre alle strutture package-local gia fissate (`root/`, `cmd/`, `env`, `var/`, `default/`);
5. grammatica delle State Instance nominate, selezione/compatibilita dello state e relativa collision policy;
6. formato dei metadata con cui `pkg install` conosce i pathname mutabili e la loro state area;
7. sintassi completa di `pkg run`, option names e override environment variables;
8. formato/interprete dei wrapper usati quando è necessaria mediazione;
9. policy per eventuali collisioni tra command pubblici con lo stesso nome provenienti da package differenti;
10. acquisition/download/build e sintassi completa di `pkg install`;
11. eventuale dependency resolver generale;
12. eventuale sandbox/isolation model.

---

## 11. Implementazione e test

Alla data di questa decisione non esiste ancora un comando `pkg` stabile in `rumiai-os` né un gruppo permanente di test `pkg` in `rumiai-tests`.

Questa unità di lavoro consolida esclusivamente il design in `rumiai-dev`.

L'implementazione in `rumiai-os` richiede una successiva autorizzazione esplicita. Quando `root/`, `cmd/`, `current`, i binding diretti e la normalizzazione state diventeranno comportamento osservabile del prodotto, dovranno essere protetti da test permanenti proporzionati in `rumiai-tests`.

---

## 12. Invarianti fissati

```text
PKG-LAYOUT-01  una versione concreta separa tree upstream e strutture package-local RumiAI
PKG-LAYOUT-02  root/ e il tree di esecuzione upstream e puo contenere symlink di normalizzazione dei pathname mutabili fissati da pkg install
PKG-LAYOUT-03  pathname sotto root/ non acquisiscono automaticamente semantica pkg dal proprio nome
PKG-CMD-01     <pkg-command> corrisponde esattamente a cmd/<pkg-command>
PKG-CMD-02     cmd/<pkg-command> è un symbolic link relativo
PKG-CMD-03     cmd/<pkg-command> risolve verso un executable appartenente al package sotto root/
PKG-CMD-04     pkg non scopre command scandendo root/
PKG-CMD-05     un pathname upstream non sostituisce <pkg-command>
PKG-DIRECT-01  il binding pubblico diretto è un symbolic link relativo
PKG-DIRECT-02  il binding pubblico diretto risolve attraverso current
PKG-DIRECT-03  il binding pubblico diretto termina su cmd/<pkg-command>, non direttamente su root/
PKG-DIRECT-04  il binding pubblico diretto non pinna una versione concreta
PKG-DIRECT-05  bin/ext vs bin/ext-<osarch> segue la validità del binding rispetto al target
PKG-DIRECT-06  il binding diretto non applica override per-invocation che richiedono pkg run
PKG-DIRECT-07  il solo routing statico root -> var -> state selezionato non obbliga a usare pkg run
PKG-CMD-06     il package-local cmd/ non riapre il vecchio command-entry cmd/ shadow model
```
