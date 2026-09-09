# Decisione — Boundary runtime state del proxy Zsh

Date: 2026-09-09  
Status: **Accepted finding; product realignment pending explicit authorization**

## Contesto

La coppia candidata corrente per il gate cross-platform è:

```text
rumiai-os@52454b4d679bd6b49596ecdf5c8f4535e20bb5c7
rumiai-tests@17f307165810e328ef2e44b2ca447a09575623f2
selection=rumiai-os
```

Ubuntu 26.04.1 ARM64 ha già prodotto PASS fisico della coppia in:

```text
validation/20260909T201747+0200-21089
```

Il successivo tentativo di avviare la stessa validation su macOS ARM64 non ha avviato il runner perché il launcher ha correttamente rilevato il target `rumiai-os` dirty:

```text
?? conf/sys/shell/zsh/.zsh_history
?? conf/sys/shell/zsh/.zsh_sessions/
```

Non è stata quindi creata una nuova sessione di validation per questo tentativo e non deve essere registrato come validation FAIL o PASS.

I pathname non appartengono a una modifica utente del prodotto: sono runtime state Zsh materializzato nel sottotree di configurazione versionata durante una precedente esecuzione interattiva Zsh sul reference host macOS.

## 1. Causa

Il prodotto corrente instrada temporaneamente lo startup Zsh impostando prima dell'`exec`:

```text
ZDOTDIR=$m_CONF_DIR/sys/shell/zsh
```

perché i proxy RumiAI `.zshenv`, `.zprofile` e `.zshrc` sono versionati in:

```text
$m_CONF_DIR/sys/shell/zsh/
```

Zsh usa però `ZDOTDIR` non soltanto per individuare i local startup file: fra i local startup file esegue anche i global startup file della propria installazione. Un global startup file può quindi osservare il valore proxy di `ZDOTDIR` e derivarne runtime state.

Il comportamento fisicamente osservato su macOS è precisamente questo: il global startup dell'host ha derivato da `ZDOTDIR` almeno history e session state e li ha materializzati nel directory proxy RumiAI.

Il problema non è specifico della nomenclatura `.zsh_history` o `.zsh_sessions`: il boundary errato è usare un directory di configurazione base versionata come `ZDOTDIR` runtime osservabile da codice Zsh/host esterno a RumiAI.

## 2. Relazione con il contratto shell corrente

Resta valido il contratto di `2026-09-05-interactive-shell-startup.md`:

```text
- usare i meccanismi nativi Zsh;
- preservare esattamente lo stato ZDOTDIR utente;
- caricare gli startup file utente secondo la semantica Zsh;
- non emulare o sostituire genericamente la startup sequence dell'host;
- confinare le eccezioni Zsh nell'adapter Zsh.
```

La physical observation corrente dimostra però che l'implementazione del proxy non può usare come runtime `ZDOTDIR` un pathname sotto la configurazione versionata del prodotto.

La correzione deve preservare il contratto sopra e cambiare soltanto il boundary fisico fra:

```text
configurazione adapter versionata
runtime state osservabile tramite ZDOTDIR
```

## 3. Boundary state

`conf/sys/shell/zsh/` resta configurazione base versionata e deve contenere esclusivamente gli adapter/proxy appartenenti al prodotto.

Runtime state creato da Zsh, global startup file o terminal integration non deve essere scritto in quel sottotree durante l'uso normale.

La decisione `2026-09-06-system-base-state-namespace.md` fornisce già il namespace per state del componente base `shell`:

```text
$m_ROOT/<area>/sys/shell/
```

ed esplicitamente consente l'area `home` quando il componente base necessita compatibility state persistente:

```text
$m_HOME_DIR/sys/shell/
```

Non serve quindi introdurre una nuova semantic root, un nuovo namespace o un meccanismo host-specific per risolvere il boundary.

La direzione candidata per il riallineamento è mantenere i proxy canonici/versionati sotto `conf/sys/shell/zsh/` e usare un runtime proxy `ZDOTDIR` mutabile sotto il namespace state del componente shell, con `$m_HOME_DIR/sys/shell/zsh/` come candidato naturale quando history/session/compatibility state devono restare persistenti.

La scelta concreta di materializzazione dei proxy runtime e la conseguente policy di history/session state non vengono promosse a contratto prodotto da questo finding: devono essere consolidate e autorizzate prima della modifica di `rumiai-os`.

## 4. Cosa non fare

Non sono correzioni accettabili:

```text
aggiungere .zsh_history o .zsh_sessions a un .gitignore sotto conf/
far cancellare automaticamente tali pathname al validator
considerare il checkout dirty come falso positivo
aggiungere cleanup host-specific al runner
ignorare il problema perché compare soltanto su macOS
```

La cleanliness check del validator ha rilevato correttamente una mutazione del target e deve continuare a fermare la validation quando il target non è clean.

## 5. Test permanente richiesto dal riallineamento

Quando il prodotto verrà riallineato, la suite shell deve proteggere in modo deterministico almeno la proprietà:

```text
l'avvio della shell Zsh RumiAI non materializza runtime state nel sottotree versionato conf/sys/shell/zsh/
```

Il test deve restare indipendente e deve pulire soltanto le proprie fixture/state; non deve affidarsi al validator per rimuovere mutazioni dal target.

I test correnti di startup/ZDOTDIR restano evidence del contratto precedente, ma non proteggono ancora esplicitamente questo boundary.

## 6. Stato del gate

Il gate cross-platform della coppia:

```text
rumiai-os@52454b4d679bd6b49596ecdf5c8f4535e20bb5c7
rumiai-tests@17f307165810e328ef2e44b2ca447a09575623f2
selection=rumiai-os
```

resta aperto:

```text
Ubuntu ARM64  PASS
macOS ARM64   non eseguito sulla coppia corrente: precondition cleanliness failure
```

Prima di rilanciare macOS devono essere soddisfatte entrambe le condizioni:

1. il prodotto deve essere riallineato affinché lo startup Zsh non scriva runtime state sotto la configurazione versionata;
2. i due pathname già materializzati nel checkout locale macOS devono essere rimossi soltanto dopo averne riconosciuto la natura di runtime residue, così il target torna clean.

Una successiva modifica prodotto genera una nuova revisione `rumiai-os`; di conseguenza il gate dovrà usare e registrare la nuova coppia revision-specific secondo `TESTING.md`.

## 7. Invarianti

```text
ZSH-STATE-01  conf/sys/shell/zsh resta configurazione base versionata e non è runtime state storage
ZSH-STATE-02  il runtime ZDOTDIR proxy non deve permettere a Zsh/global startup di materializzare state sotto conf/sys/shell/zsh
ZSH-STATE-03  la soluzione deve riusare le semantic root e il namespace sys già fissati; nessuna nuova root/namespace è introdotta
ZSH-STATE-04  il validator non deve ignorare o cancellare automaticamente mutazioni del target per far passare il gate
ZSH-STATE-05  il tentativo macOS interrotto dalla cleanliness precondition non è una sessione di validation
ZSH-STATE-06  il riallineamento prodotto richiede consenso esplicito separato secondo RULES.md
ZSH-STATE-07  dopo il riallineamento serve un guard permanente che verifichi l'assenza di runtime state nel conf Zsh versionato
```