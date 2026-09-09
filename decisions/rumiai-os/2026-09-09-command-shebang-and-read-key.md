# Decisione — Shebang dei command entrypoint e utility `read-key`

Date: 2026-09-09  
Updated: 2026-09-09  
Status: **Accepted**

## Contesto

Le regole correnti contenevano due prescrizioni formulate in modo troppo assoluto:

- `RULES.md` indicava `#!/bin/sh` per gli script shell direttamente eseguibili;
- il contratto dei command entrypoint indicava `#!/usr/bin/env rumiai-os` per ogni command file RumiAI direttamente eseguibile.

Il nuovo caso concreto `read-key` ha reso necessario distinguere il linguaggio di implementazione dal runtime effettivamente richiesto dal comando.

`read-key` è una utility shell intenzionalmente autonoma dal bootstrap: legge un singolo tasto dal controlling terminal, usa esclusivamente primitive shell/POSIX più una capability `tput`/terminfo dichiarata, non usa `m_*`, `log`, `lang`, librerie sourced dal bootstrap, `m_COMMAND_BIN` o altre facility inizializzate da `rumiai-os`.

L'utente ha autorizzato esplicitamente sia l'introduzione di `read-key` in `rumiai-os` sia l'uso di `#!/bin/sh` per questa utility, oltre alla revisione generale della regola di scelta dello shebang.

L'utente ha successivamente fissato che `read-key` deve restare standalone e minimale anche nella gestione degli errori: i failure gestiti non producono messaggi diagnostici propri e vengono comunicati al consumer tramite exit status. La responsabilità di eventuali messaggi utente resta al consumer, che conosce il contesto della lettura e può usare `fatal`/`log` quando opera nel runtime RumiAI.

---

## 1. Principio generale

Lo shebang di un executable RumiAI implementato in shell è determinato dal **contratto runtime**, non semplicemente dal linguaggio del file o dalla directory in cui si trova.

La distinzione iniziale è:

```text
bootstrap-integrated command
standalone shell utility
```

Questi nomi descrivono il criterio di selezione dello shebang nel contratto di sviluppo; non introducono nuovi componenti runtime o namespace fisici.

---

## 2. Bootstrap-integrated command

Un comando direttamente eseguibile usa:

```text
#!/usr/bin/env rumiai-os
```

quando:

1. usa attualmente una o più facility inizializzate dal bootstrap RumiAI; oppure
2. il suo ruolo rende ragionevolmente prevedibile che una dipendenza di questo tipo diventi parte del contratto durante la normale evoluzione del comando.

Rientrano tra le facility bootstrap, a titolo non esaustivo:

```text
m_*
log
lang
funzioni/librerie sourced dal runtime
root/path semantici inizializzati dal bootstrap
configurazione/state esposti dal runtime
m_COMMAND_BIN
```

Non si sceglie `#!/bin/sh` soltanto perché una prima versione di un comando non usa ancora tali facility quando la futura integrazione è già ragionevolmente prevedibile.

Il body shell continua a rispettare il contratto POSIX `sh` salvo eccezioni esplicitamente approvate.

---

## 3. Standalone shell utility

Una utility direttamente eseguibile MAY usare esattamente:

```text
#!/bin/sh
```

soltanto se tutte le condizioni seguenti sono soddisfatte:

1. l'implementazione è POSIX `sh`;
2. non esiste una dipendenza attuale dal bootstrap RumiAI;
3. una dipendenza dal bootstrap non è ragionevolmente prevedibile nel normale ruolo della utility;
4. l'indipendenza dal bootstrap è parte intenzionale del contratto, non una scorciatoia implementativa;
5. l'utente autorizza preventivamente e in modo esplicito questa scelta;
6. una fonte autorevole documenta la motivazione, le dipendenze e il contratto osservabile.

Una standalone shell utility non deve richiedere per il proprio funzionamento le facility bootstrap elencate nella sezione precedente.

Una dipendenza esterna non garantita dalla baseline POSIX resta una capability/dependency esplicita e non viene trasformata in garanzia POSIX per il solo fatto che il comando è standalone.

---

## 4. Evoluzione futura

Se una utility inizialmente standalone acquisisce una dipendenza dal bootstrap, la classificazione e lo shebang devono essere riesaminati prima della modifica.

La migrazione normale è:

```text
#!/bin/sh
    ->
#!/usr/bin/env rumiai-os
```

salvo una nuova decisione esplicita che stabilisca un contratto differente.

La semplice possibilità astratta che qualunque programma possa un giorno cambiare non è sufficiente a vietare `#!/bin/sh`; la previsione deve derivare dal ruolo concreto della utility e dalla sua evoluzione ragionevolmente attesa.

---

## 5. Root bootstrap

Il root entrypoint:

```text
rumiai-os
```

resta un caso specifico già fissato e usa:

```text
#!/bin/sh
```

perché è il bootstrap che crea l'ambiente RumiAI e non può dipendere dall'ambiente che deve ancora inizializzare.

---

## 6. `read-key`

È approvato il comando:

```text
bin/sys/read-key
```

con:

```text
regular executable file
mode executable
#!/bin/sh
POSIX sh
zero operandi/argomenti
```

Il nome `read-key` sostituisce, nel prodotto RumiAI, i nomi storici/proposti `readc`, `readch`, `rch` e `read-char`; questi non diventano alias.

La motivazione del nome è semantica: l'utility legge un **tasto** e può restituire sia un carattere stampabile sia un nome logico per un tasto speciale.

---

## 7. Contratto sintetico di `read-key`

`read-key` legge esattamente un evento di tasto dal controlling terminal `/dev/tty`.

Per i caratteri stampabili UTF-8 restituisce il carattere originale. Per i tasti non convenientemente rappresentabili come carattere restituisce un nome logico stabile.

Mapping iniziale:

```text
NUL                         nul
Backspace                   backspace
Tab                         tab
Enter                       enter
Escape                      escape
Back Tab                    backtab
Up/Down/Left/Right          up/down/left/right
Home/End                    home/end
Insert/Delete               insert/delete
Page Up/Page Down           pageup/pagedown
F1 ... F20                  f1 ... f20
```

Lo spazio resta il carattere spazio e non viene convertito in `space`.

Le sequenze terminal-specific dei tasti speciali vengono ottenute dalla descrizione terminfo corrente tramite `tput`; non vengono hardcodate sequenze xterm/VT nel comando.

---

## 8. Dipendenze di `read-key`

Il comando usa il profilo POSIX shell e le utility:

```text
stty
dd
od
tr
```

Richiede inoltre esplicitamente:

```text
tput con supporto alle capability X/Open Curses / terminfo usate dal comando
```

Questa dipendenza non viene classificata come primitive dependency-free POSIX core.

Le capability iniziali consumate includono:

```text
smkx rmkx
kbs kent kcbt
kcuu1 kcud1 kcub1 kcuf1
khome kend
kich1 kdch1
kpp knp
kf1 ... kf20
```

---

## 9. Terminal state e side effect

`read-key`:

1. legge e salva lo stato TTY tramite `stty -g`;
2. usa input non canonico con echo disabilitato;
3. mantiene il normale signal processing della TTY invece di passare a un raw mode completo;
4. attiva `smkx` quando supportato;
5. ripristina `rmkx` e lo stato TTY salvato in cleanup.

L'I/O terminale passa esplicitamente attraverso `/dev/tty`; stdout resta il canale dati del comando.

---

## 10. Escape sequence e timeout

Il decoder usa un parser a prefissi sulla keymap ricavata da terminfo.

Dopo un byte che può iniziare una sequenza più lunga, i byte successivi vengono letti con un timeout inter-byte di un decimo di secondo tramite la semantica `MIN=0`, `TIME=1` di `stty`.

Il comando non legge un numero fisso di byte dopo `Escape` e quindi non consuma intenzionalmente caratteri successivi soltanto per riempire una lunghezza massima.

Una sequenza sconosciuta o incompleta produce failure invece di inventare un nome.

POSIX shell non fornisce un meccanismo portabile per reinserire nella TTY un byte già consumato durante il riconoscimento; questa limitazione fa parte del contratto operativo.

---

## 11. UTF-8

`read-key` preserva caratteri UTF-8 validi da uno a quattro byte.

La validazione rifiuta almeno:

```text
continuation byte invalido
sequenza incompleta
overlong encoding
UTF-16 surrogate code point
code point oltre U+10FFFF
byte iniziale UTF-8 non valido
```

Le variabili POSIX shell non possono rappresentare NUL; il byte NUL viene quindi normalizzato nel token `nul`.

---

## 12. Output ed exit status

Su successo stdout contiene esclusivamente il risultato seguito da newline.

`read-key` non emette messaggi diagnostici applicativi propri. Nei failure gestiti, stdout e stderr restano vuoti e il fallimento è comunicato esclusivamente dall'exit status. Le diagnostiche attese delle utility interne sono soppresse.

Questa scelta preserva l'indipendenza dal bootstrap e mantiene `read-key` come primitive bassa e circoscritta. La responsabilità della presentazione dell'errore appartiene al consumer che conosce il contesto della lettura; un consumer bootstrap-integrated può usare `fatal`/`log` senza trasformare `read-key` in una dipendenza dal runtime RumiAI.

Exit status:

```text
0  tasto letto e rappresentato correttamente
1  errore operativo, TTY/capability/utility necessaria non disponibile
2  invocazione invalida, sequenza/input non supportato o non valido
```

Il comando non accetta argomenti né operandi.

---

## 13. Signal handling

Il contratto iniziale mantiene i signal exit status espliciti già usati dall'implementazione:

```text
HUP   129
INT   130
QUIT  131
PIPE  141
TERM  143
TSTP  148
```

In particolare `TSTP` provoca cleanup e uscita 148 invece di lasciare il processo sospeso con la TTY in stato modificato.

---

## 14. Relazione con le decisioni precedenti

Questa decisione **raffina e limita** l'interpretazione universale di:

```text
decisions/rumiai-os/2026-08-28-command-interpreter-shebang.md
```

La prescrizione `#!/usr/bin/env rumiai-os` resta valida per i bootstrap-integrated command, ma non si applica alle standalone shell utility esplicitamente autorizzate secondo questa decisione.

La stessa precisazione si applica alla formulazione universale del command entrypoint presente nella decisione bootstrap/runtime del 2026-09-02. Tutti gli altri invarianti di quelle decisioni restano invariati.

Le fonti correnti da leggere per la regola sono:

```text
RULES.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
questa decisione
```

---

## 15. Invarianti fissati

```text
SHEBANG-01  la scelta dello shebang dipende dal contratto runtime, non dalla sola implementazione shell
SHEBANG-02  dipendenza bootstrap attuale o ragionevolmente prevedibile -> #!/usr/bin/env rumiai-os
SHEBANG-03  #!/bin/sh standalone richiede assenza di dipendenza bootstrap attuale/prevedibile, autorizzazione preventiva e documentazione
SHEBANG-04  una standalone utility non usa facility bootstrap come m_*, log, lang o m_COMMAND_BIN
SHEBANG-05  nuova dipendenza bootstrap -> riesame obbligatorio dello shebang
READ-KEY-01 comando canonico bin/sys/read-key, executable, #!/bin/sh
READ-KEY-02 zero argomenti; stdout solo risultato su successo; failure gestiti silenziosi su stdout/stderr
READ-KEY-03 printable UTF-8 invariato; tasti speciali normalizzati in nomi logici
READ-KEY-04 sequenze speciali derivate da terminfo/tput, non hardcodate per terminale
READ-KEY-05 tput/X/Open Curses/terminfo è capability esplicita
READ-KEY-06 terminal state salvato e ripristinato; input da /dev/tty
READ-KEY-07 escape parser prefix-based con timeout inter-byte e senza fixed-length over-read
READ-KEY-08 UTF-8 validato, NUL rappresentato come nul
READ-KEY-09 status 0 successo, 1 errore operativo/capability/TTY, 2 input/invocazione invalida
```

---

## 16. Testing e validazione

Devono essere mantenuti test permanenti almeno per:

```text
pathname/mode/shebang standalone
assenza di dipendenze bootstrap nel comando
assenza di diagnostiche applicative proprie nel comando
zero-argument CLI e failure invalido silenzioso
ASCII e spazio invariati
UTF-8 valido 2/3/4 byte
Escape/Enter/Tab
almeno una capability terminfo reale per freccia
ripristino dello stato TTY
assenza di smkx/rmkx su stdout
missing tput con status corretto e output di failure vuoto
UTF-8 invalido e sequenza terminale sconosciuta con status corretto e output di failure vuoto
```

La validazione locale PTY effettuata durante la progettazione e il riallineamento ha verificato questi comportamenti sulla revisione candidata, ma non costituisce una validation run certificata sui reference host per le revisioni committed. La physical validation revision-specific resta da registrare secondo `TESTING.md` quando appropriato.
