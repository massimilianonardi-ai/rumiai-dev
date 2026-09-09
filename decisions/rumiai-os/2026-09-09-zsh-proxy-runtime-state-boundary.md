# Decisione — Boundary runtime state del proxy Zsh

Date: 2026-09-09  
Status: **Accepted; implemented, physical validation pending**

## Contesto

La coppia precedente:

```text
rumiai-os@52454b4d679bd6b49596ecdf5c8f4535e20bb5c7
rumiai-tests@17f307165810e328ef2e44b2ca447a09575623f2
selection=rumiai-os
```

ha prodotto PASS fisico su Ubuntu 26.04.1 ARM64 in:

```text
validation/20260909T201747+0200-21089
```

Il successivo tentativo di avviare la stessa validation su macOS ARM64 non ha avviato il runner perché il launcher ha correttamente rilevato il target `rumiai-os` dirty:

```text
?? conf/sys/shell/zsh/.zsh_history
?? conf/sys/shell/zsh/.zsh_sessions/
```

Non è stata quindi creata una sessione di validation per quel tentativo e non deve essere registrato come validation FAIL o PASS.

I pathname osservati sono runtime state Zsh materializzato nel sottotree di configurazione versionata durante una precedente esecuzione interattiva Zsh sul reference host macOS.

## 1. Causa

L'implementazione precedente instradava temporaneamente lo startup Zsh impostando prima dell'`exec`:

```text
ZDOTDIR=$m_CONF_DIR/sys/shell/zsh
```

perché gli adapter RumiAI `.zshenv`, `.zprofile` e `.zshrc` sono versionati in:

```text
$m_CONF_DIR/sys/shell/zsh/
```

Zsh e i global startup file dell'host possono però osservare il valore di `ZDOTDIR` e derivarne runtime state. Su macOS questo ha materializzato almeno history e session state nel directory proxy RumiAI.

Il problema non è specifico dei nomi `.zsh_history` o `.zsh_sessions`: il boundary errato era usare un directory di configurazione base versionata come `ZDOTDIR` runtime osservabile da codice esterno a RumiAI.

## 2. Contratto shell preservato

Resta valido il contratto di `2026-09-05-interactive-shell-startup.md`:

```text
- usare i meccanismi nativi Zsh;
- preservare esattamente lo stato ZDOTDIR utente;
- caricare gli startup file utente secondo la semantica Zsh;
- non emulare o sostituire genericamente la startup sequence dell'host;
- confinare le eccezioni Zsh nell'adapter Zsh.
```

Il riallineamento modifica soltanto il boundary fisico fra:

```text
configurazione adapter versionata
runtime state osservabile tramite ZDOTDIR
```

Le semantiche unset / empty / value di `ZDOTDIR`, la ricattura delle modifiche effettuate dagli startup file utente e il comportamento login/non-login restano invariati.

## 3. Boundary state canonico

`conf/sys/shell/zsh/` resta configurazione base versionata e contiene gli adapter canonici:

```text
$m_CONF_DIR/sys/shell/zsh/.zshenv
$m_CONF_DIR/sys/shell/zsh/.zprofile
$m_CONF_DIR/sys/shell/zsh/.zshrc
```

Il runtime `ZDOTDIR` RumiAI per Zsh è invece:

```text
$m_HOME_DIR/sys/shell/zsh/
```

Questa scelta riusa direttamente la semantic root `home` e il namespace state del sistema base fissati da `2026-09-06-system-base-state-namespace.md`:

```text
$m_ROOT/<area>/sys/<component>/
```

Non viene introdotta nessuna nuova semantic root, namespace o eccezione macOS.

History, session state e altro compatibility state che Zsh o i global startup file derivano dal runtime `ZDOTDIR` possono quindi vivere sotto:

```text
$m_HOME_DIR/sys/shell/zsh/
```

senza contaminare la configurazione versionata.

## 4. Materializzazione dei redirector runtime

Prima dell'`exec` di Zsh, `shell()`:

1. crea se necessario `$m_HOME_DIR/sys/shell/zsh/`;
2. materializza come file regolari i tre redirector runtime:

```text
.zshenv
.zprofile
.zshrc
```

3. ogni redirector contiene esclusivamente il source del corrispondente adapter canonico, per esempio:

```sh
. "$m_CONF_DIR/sys/shell/zsh/.zshenv"
```

4. la scrittura avviene prima su un pathname temporaneo nello stesso directory e poi tramite `mv`, così il pathname finale non viene aggiornato attraverso una scrittura parziale;
5. i redirector runtime non sono symlink verso `conf/`, evitando un possibile write-through dal runtime state alla configurazione versionata;
6. `m_SHELL_ZDOTDIR_INIT` e quindi il `ZDOTDIR` iniziale passato a Zsh puntano al runtime directory sotto `home`.

I redirector runtime sono materiale derivato e non diventano una seconda fonte di configurazione: la sorgente autorevole resta sempre `conf/sys/shell/zsh/`.

## 5. Cosa non fare

Restano non accettabili:

```text
aggiungere .zsh_history o .zsh_sessions a un .gitignore sotto conf/
far cancellare automaticamente tali pathname al validator
considerare il checkout dirty come falso positivo
aggiungere cleanup host-specific al runner
ignorare il problema perché compare soltanto su macOS
usare symlink runtime che permettano write-through verso gli adapter versionati
```

La cleanliness check del validator ha rilevato correttamente una mutazione del target e deve continuare a fermare la validation quando il target non è clean.

## 6. Implementazione prodotto

Il riallineamento prodotto è implementato in:

```text
massimilianonardi-ai/rumiai-os@130944920b5dab5f9d25bd3515667f5cdff36a48
```

Il diff netto rispetto a `52454b4d...` modifica esclusivamente il ramo Zsh di:

```text
lib/sh/core.lib.sh
```

La configurazione canonica sotto `conf/sys/shell/zsh/` non viene modificata.

## 7. Test permanente

La suite aggiunge il test indipendente:

```text
tests/rumiai-os/shell/zsh-runtime-state-boundary.test
```

Il test usa una fixture isolata del target e un fake executable chiamato `zsh` che:

```text
osserva il ZDOTDIR ricevuto
materializza runtime state nel pathname ricevuto
```

Il guard verifica deterministicamente che:

```text
ZDOTDIR = $m_HOME_DIR/sys/shell/zsh
ZDOTDIR != $m_CONF_DIR/sys/shell/zsh
lo state creato finisca sotto home/sys/shell/zsh
nessuno state equivalente compaia sotto conf/sys/shell/zsh
i tre redirector runtime siano file regolari e non symlink
i redirector facciano source degli adapter canonici sotto conf
```

Gli attuali test Zsh restano responsabili della semantica reale di startup e della preservazione `ZDOTDIR` unset / empty / value.

La suite candidata corrente è:

```text
massimilianonardi-ai/rumiai-tests@18cdcf231a1353a9cc903581030a6dc6a094df4c
```

## 8. Stato del gate

Poiché il prodotto è cambiato, la precedente evidence Ubuntu resta valida soltanto per la precedente revisione.

La nuova coppia candidata è:

```text
rumiai-os@130944920b5dab5f9d25bd3515667f5cdff36a48
rumiai-tests@18cdcf231a1353a9cc903581030a6dc6a094df4c
selection=rumiai-os
```

Questa coppia deve essere validata nuovamente su:

```text
Ubuntu ARM64
macOS ARM64
```

con la stessa configurazione su entrambi gli host.

Sul checkout macOS i residui precedentemente osservati:

```text
conf/sys/shell/zsh/.zsh_history
conf/sys/shell/zsh/.zsh_sessions/
```

sono riconosciuti come runtime residue della vecchia implementazione. Devono essere rimossi manualmente una sola volta prima della nuova validation, senza introdurre cleanup automatico nel validator o nel prodotto.

## 9. Invarianti

```text
ZSH-STATE-01  conf/sys/shell/zsh resta configurazione base versionata e non è runtime state storage
ZSH-STATE-02  runtime ZDOTDIR RumiAI per Zsh = $m_HOME_DIR/sys/shell/zsh
ZSH-STATE-03  gli adapter canonici restano versionati sotto $m_CONF_DIR/sys/shell/zsh
ZSH-STATE-04  il runtime directory contiene redirector derivati che source gli adapter canonici
ZSH-STATE-05  i redirector runtime sono file regolari, non symlink verso conf
ZSH-STATE-06  la soluzione riusa semantic root home e namespace sys già fissati; nessuna nuova root/namespace è introdotta
ZSH-STATE-07  la semantica ZDOTDIR utente unset / empty / value resta invariata
ZSH-STATE-08  il validator non deve ignorare o cancellare automaticamente mutazioni del target
ZSH-STATE-09  il tentativo macOS interrotto dalla cleanliness precondition non è una sessione di validation
ZSH-STATE-10  il guard permanente zsh-runtime-state-boundary.test protegge il boundary conf/home
ZSH-STATE-11  la physical validation della nuova coppia resta pending fino ai run Ubuntu ARM64 e macOS ARM64
```
