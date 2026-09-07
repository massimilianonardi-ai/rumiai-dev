# Decisione — Baseline operativa di `pkg install` per candidate locale stateless

Date: 2026-09-07  
Status: **Accepted**

## Contesto

Il modello package corrente ha già fissato:

- `$m_ROOT/pkg/<pkg>@<version>!<osarch>/` come pathname di una versione concreta;
- `$m_ROOT/pkg/<pkg>!<osarch>` come selector persistente `current` relativo;
- `cmd/<pkg-command>` come command entry package-local RumiAI;
- `link/<pkg-command>`, quando presente, come symlink relativo esclusivamente verso `root/` della stessa versione concreta;
- `<package-version>/env` come frammento shell POSIX opzionale gestito/materializzato da `pkg install`;
- `root/ -> var/ -> state` come normalizzazione install-time per software stateful;
- facility/dependency/provider index/resolved binding come modello corrente delle dependency;
- `pkg install` come operazione distinta da acquisition, download e build.

Restano però aperti:

- il formato package-source generale;
- la serializzazione esatta di `facility` e `dependency`;
- il confronto compatibility multi-componente;
- la policy fra provider equivalenti;
- le State Instance operative;
- la transaction/recovery generale multi-oggetto del package manager;
- la firma finale del `launcher` nei diversi command shape.

La prima implementazione prodotto di `pkg install` deve quindi essere utile senza inventare implicitamente queste parti ancora aperte.

Questa decisione autorizza e delimita la prima implementazione operativa di `pkg install` in `rumiai-os` e i relativi test permanenti in `rumiai-tests`.

---

## 1. Scopo del primo incremento

La prima implementazione supporta esclusivamente la **materializzazione locale di un candidate stateless già prodotto**.

Non appartengono a questo incremento:

```text
download
repository/remoti
build/toolchain
facility/dependency resolution
provider index
binding/<facility>
state mapping root/ -> var/
default state
State Instance
remove/update/select/run
transaction/recovery generale concorrente
```

Queste responsabilità restano nel modello complessivo di `pkg` ma vengono implementate soltanto dopo la chiusura dei rispettivi contratti ancora aperti.

Il termine `candidate` descrive qui soltanto l'input locale dell'operazione e non introduce una nuova identità persistente di package.

---

## 2. CLI iniziale

La forma iniziale è esattamente:

```text
pkg install <pkg> <version> <candidate-directory>
```

Il sottocomando `install` non espone option nella prima implementazione; i tre valori successivi sono quindi sempre operandi e non viene introdotto `--` finché non esiste una option grammar da terminare.

`<candidate-directory>` è pathname esterno fornito dal caller e viene trattato come pathname opaco, senza rinomina o normalizzazione lessicale.

`<pkg>` è un identificatore RumiAI-controlled conforme alla naming convention generica corrente.

`<version>` usa esattamente la grammatica già fissata:

```text
[A-Za-z0-9][A-Za-z0-9._+~-]*
```

`<osarch>` non è un quarto operando: la prima implementazione installa per il target nativo corrente rilevato dal vocabulary RumiAI già fissato (`linux|macos|windows` + `arm64|x86_64`).

---

## 3. Candidate locale stateless

Il candidate iniziale contiene esclusivamente la subset necessaria fra:

```text
<candidate>/
├── root/
├── cmd/
├── link/
└── env
```

Regole:

```text
root/  obbligatorio; directory reale contenente il tree upstream già prodotto
cmd/   obbligatorio; directory reale con almeno un command entry
link/  opzionale; directory reale contenente soltanto symlink command -> root/
env    opzionale; regular file package-local POSIX shell fragment
```

Non sono ammessi altri immediate child nel candidate della baseline iniziale.

In particolare un candidate che richiede:

```text
var/
default/
facility
dependency
binding/
```

non è installabile da questo incremento e deve essere rifiutato anziché essere installato parzialmente o con semantica inventata.

Il candidate non viene copiato come identity persistente e il suo basename non ha significato package-manager.

---

## 4. `cmd/`

Ogni immediate child di `cmd/`:

- ha un nome `<pkg-command>` conforme alla naming convention RumiAI dei command;
- è un regular file reale, non un symlink;
- è leggibile ed executable;
- usa il command entrypoint canonico:

```text
#!/usr/bin/env rumiai-os
```

Il file viene preservato come command entry della versione concreta.

`pkg install` non interpreta né riscrive la launch line del command entry. Questa scelta evita di anticipare la firma finale di `launcher`, che resta separatamente aperta dopo la decisione command-specific del 2026-09-07.

La logica command-specific, quando necessaria, resta quindi nel `cmd/<pkg-command>` fornito dal packaging, in accordo con il modello corrente.

---

## 5. `link/`

`link/` è opzionale.

Ogni immediate child di `link/`:

- è un symbolic link;
- usa un nome che esiste anche in `cmd/`;
- risolve a un regular executable file sotto `root/` dello stesso candidate;
- non può risolvere fuori da `root/`.

Poiché candidate e package materializzato mantengono la stessa relazione fra `link/` e `root/`, il target testuale relativo del symlink viene preservato.

Un command entry può non avere `link/<pkg-command>` quando implementa una launch line esplicita che non richiede tale binding, come già fissato dalla decisione command-specific corrente.

---

## 6. Materializzazione della versione concreta

Per il target nativo corrente viene costruita l'identità:

```text
<pkg>@<version>!<osarch>
```

La versione concreta finale è:

```text
$m_ROOT/pkg/<pkg>@<version>!<osarch>/
```

Il target finale deve essere assente. `pkg install` non sovrascrive né modifica inplace una versione concreta già presente.

L'implementazione costruisce prima un tree staging sotto lo stesso parent `$m_ROOT/pkg/`, valida il tree completo e pubblica la directory finale con rename/move nello stesso parent.

Il nome dello staging è un pathname interno temporaneo e nascosto; non è identity e deve essere rimosso dopo failure pre-publish.

Questa baseline usa il publish di directory come unità per evitare che una versione concreta diventi visibile come partial copy. Non pretende di chiudere la futura transaction/recovery generale del package manager.

---

## 7. `current` durante install

`pkg install` non è anche un comando generico di version selection.

Regola:

```text
selector <pkg>!<osarch> assente
    -> la prima installazione riuscita crea current verso la nuova versione

selector <pkg>!<osarch> già presente e valido
    -> la nuova versione viene installata ma current resta invariato
```

Questa regola rende possibile la coesistenza di più versioni senza introdurre implicitamente una policy di upgrade/switch.

Cambiare `current` dopo la prima installazione appartiene a una futura operazione esplicita separata.

Se il pathname del selector esiste come oggetto non-symlink, oppure il symlink esistente è invalido/non risolve a una versione concreta coerente dello stesso package/osarch, `pkg install` fallisce prima di pubblicare una nuova versione.

Il selector creato durante la prima installazione è un symlink relativo con target testuale uguale al basename della versione concreta.

---

## 8. Binding pubblici nella prima installazione

Per la prima versione selezionata, ogni command sotto `cmd/` viene esposto sotto:

```text
$m_ROOT/bin/ext-<osarch>/<pkg-command>
```

come symbolic link relativo che risolve semanticamente a:

```text
$m_ROOT/pkg/<pkg>!<osarch>/cmd/<pkg-command>
```

La forma target-specific viene usata perché la versione concreta è sempre qualificata da `<osarch>`.

`pkg install` non invoca automaticamente `osarch-update` e non modifica `bin/ext-osarch`; la decisione del 2026-09-03 mantiene `osarch-update` come comando esplicito. L'installazione può creare la directory fisica `bin/ext-<osarch>/` se assente.

Prima della prima pubblicazione, qualunque collisione con un pathname pubblico già esistente per uno dei command è errore. `pkg install` non sovrascrive binding preesistenti.

Il selector viene creato soltanto dopo che package concreto e binding pubblici della prima installazione sono stati materializzati; la sua creazione rende risolvibile la catena pubblica completa.

Per versioni successive, poiché `current` non cambia, `pkg install` non modifica i binding pubblici esistenti.

---

## 9. Failure boundary della baseline

La prima implementazione garantisce almeno:

```text
validation failure prima del publish
    -> nessuna nuova versione concreta visibile

failure durante staging
    -> staging ripulito

prima installazione: failure prima della creazione di current
    -> i binding pubblici creati dalla stessa invocazione vengono rimossi
    -> la nuova versione concreta pubblicata dalla stessa invocazione viene rimossa
    -> current resta assente
```

Queste garanzie sono deliberate ma non vengono promosse a transaction API generale.

La baseline non dichiara supporto a mutazioni `pkg` concorrenti; il mutation lock generale resta da chiudere separatamente prima di introdurre lifecycle concorrente più ampio.

---

## 10. Relazione con state e dependency future

Questa prima implementazione non modifica le decisioni Accepted sul modello completo.

Quando verranno aggiunti package stateful, `pkg install` dovrà continuare a essere responsabile della normalizzazione:

```text
root/<path> -> var/<area>/<path> -> state
```

secondo le decisioni correnti.

Quando verranno aggiunte facility/dependency, l'installazione dovrà materializzare i file package-local e il provider index/binding secondo la decisione del 2026-09-07, dopo aver fissato la serializzazione e la policy mancanti.

La baseline stateless non crea placeholder `var/`, `default/`, `facility`, `dependency` o `binding/` per uniformità cosmetica.

---

## 11. Implementazione e test

La prima implementazione prodotto deve introdurre:

```text
bin/sys/pkg
```

come command RumiAI platform-independent.

I test permanenti iniziali devono proteggere almeno:

```text
validazione pkg/version/candidate
materializzazione del concrete pathname corretto
preservazione root/cmd/link/env
rifiuto di link cross-package/outside root
rifiuto di top-level candidate non supportati
selector relativo creato soltanto alla prima installazione
seconda versione installata senza cambiare current
binding pubblici target-specific relativi creati alla prima installazione
assenza di overwrite di concrete package o binding pubblici esistenti
cleanup della prima installazione se la pubblicazione dei binding/current fallisce
```

La validazione fisica su macOS/Linux resta distinta dalla semplice esecuzione in fixture e deve riferirsi agli SHA effettivamente esercitati.

---

## 12. Invarianti fissati

```text
PKG-INSTALL-01  la prima implementazione di pkg install usa pkg install <pkg> <version> <candidate-directory>
PKG-INSTALL-02  la prima implementazione acquisisce soltanto candidate locali già prodotti; download/build/remoti sono fuori scope
PKG-INSTALL-03  il candidate iniziale è stateless e contiene soltanto root/, cmd/, link/ opzionale ed env opzionale
PKG-INSTALL-04  root/ e cmd/ sono obbligatori; cmd/ contiene almeno un command entry canonico executable
PKG-INSTALL-05  pkg install preserva cmd/ senza interpretarne o riscriverne la launch line
PKG-INSTALL-06  link/ è opzionale; ogni link è relativo/relocatable semanticamente confinato al root/ dello stesso package e ha un cmd omonimo
PKG-INSTALL-07  var/default/facility/dependency/binding non vengono ignorati o inventati: il candidate che li richiede è rifiutato nella baseline
PKG-INSTALL-08  la versione concreta viene staged e pubblicata come unità sotto pkg/<pkg>@<version>!<osarch>
PKG-INSTALL-09  una versione concreta preesistente non viene sovrascritta
PKG-INSTALL-10  install crea current solo quando il selector non esiste; installazioni successive non cambiano current
PKG-INSTALL-11  il selector creato è relativo e punta al basename concreto
PKG-INSTALL-12  la prima installazione crea binding pubblici relativi sotto bin/ext-<osarch>/ verso current/cmd
PKG-INSTALL-13  pkg install non invoca automaticamente osarch-update e non modifica bin/ext-osarch
PKG-INSTALL-14  una collisione con un binding pubblico preesistente è errore e non viene sovrascritta
PKG-INSTALL-15  il selector current è il commit point osservabile della prima installazione integrata; prima di esso una failure ripulisce gli oggetti creati dalla stessa invocazione
PKG-INSTALL-16  la baseline non introduce mutation lock, resolver facility incompleto, State Instance o transaction framework generale
PKG-INSTALL-17  la limitazione stateless è un incremento implementativo e non supersede le responsabilità state/dependency già fissate per il modello completo
```