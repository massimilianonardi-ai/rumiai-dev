# Decisione — Standard bootstrap/runtime dopo l'ottimizzazione

Date: 2026-09-02  
Status: **Accepted**
Updated: 2026-09-06

## Contesto

Il bootstrap corrente di `rumiai-os` è considerato la nuova baseline comportamentale dopo il ciclo di ottimizzazione concluso il 2026-09-02. Ulteriori modifiche possono essere leggere ottimizzazioni, ma non devono alterare il comportamento qui fissato senza una nuova decisione esplicita.

Baseline prodotto osservata durante questa decisione:

```text
massimilianonardi-ai/rumiai-os@77051580f489b9243b45145e9791f2cf4ace90ed
```

Questa decisione riallinea gli standard precedenti al comportamento consolidato e supersede le regole incompatibili relative a namespace delle environment variables, layout `bin/`, selezione lingua, naming `i18n`, shell selection ed esposizione interna del runtime.

Restano invariati POSIX come contratto di piattaforma, relocatability, root discovery dal bootstrap fisico, command entry tramite `#!/usr/bin/env rumiai-os`, separazione fra dati e codice e Git forward-only.

## 1. Namespace delle environment variables

Le environment variables proprie di RumiAI usano il namespace:

```text
m_*
```

Esempi correnti:

```text
m_ROOT
m_BOOTSTRAP_BIN
m_BIN_DIR
m_LANG_DIR
m_COMMAND_BIN
```

`m_*` è fissato **solo** come namespace delle environment variables RumiAI.

Questa decisione NON definisce un namespace generale per:

```text
funzioni shell
variabili locali/interne non esportate
comandi
file
API
componenti
```

Le environment variables standard dell'host, come `PATH` e `SHELL`, mantengono il proprio nome standard.

Le precedenti environment variables `RumiAI_*` sono superseded.

## 2. Layout degli eseguibili

`bin/` è il contenitore delle directory di eseguibili o binding che possono partecipare al `PATH`; `bin/` non viene aggiunta direttamente al `PATH`.

Layout canonico:

```text
bin/
├── sys/
├── sys-<osarch>/
├── sys-osarch -> sys-<osarch>
├── ext/
├── ext-<osarch>/
└── ext-osarch -> ext-<osarch>
```

Responsabilità:

```text
bin/sys/
    eseguibili/symlink propri di RumiAI, platform-independent

bin/sys-<osarch>/
    eseguibili/symlink propri di RumiAI specifici della piattaforma

bin/sys-osarch
    symlink relativo alla directory sys-<osarch> della piattaforma attiva

bin/ext/
    binding pubblici di comandi third-party validi platform-independently

bin/ext-<osarch>/
    binding pubblici di comandi third-party specifici della piattaforma

bin/ext-osarch
    symlink relativo alla directory ext-<osarch> della piattaforma attiva
```

Un binding sotto `bin/ext/` o `bin/ext-<osarch>/` può essere un executable/symlink diretto quando il software è direttamente lanciabile, oppure un wrapper/launcher RumiAI minimale quando l'esecuzione third-party richiede mediazione. Il carattere `ext` descrive il comando/software esposto, non necessariamente la proprietà del file fisico che realizza il binding.

Il modello concreto di binding diretto vs wrapper per i package è fissato dalla decisione `2026-09-05-package-manager-current-and-run-model.md`; questa precisazione non cambia né il layout né l'ordine del `PATH`.

Esempio di `<osarch>` già ammesso:

```text
macos-arm64
```

Il meccanismo che rileva la piattaforma corrente e aggiorna `sys-osarch` / `ext-osarch` è stato successivamente fissato dal comando esplicito `osarch-update` nella decisione `2026-09-03-lang-and-osarch-utilities.md`. Nessun automatismo viene introdotto nel bootstrap da questa decisione.

## 3. Ordine del PATH

La precedenza corrente è normativa:

```text
$m_BIN_SYS_OSARCH_DIR
$m_BIN_SYS_DIR
$m_BIN_EXT_OSARCH_DIR
$m_BIN_EXT_DIR
PATH ereditato dall'host
```

Forma concettuale:

```sh
PATH=$m_BIN_SYS_OSARCH_DIR:$m_BIN_SYS_DIR:$m_BIN_EXT_OSARCH_DIR:$m_BIN_EXT_DIR${PATH:+:$PATH}
```

Questo ordine non deve essere modificato incidentalmente.

## 4. `lang` sostituisce `i18n`

Il nome del sottosistema/API bootstrap è:

```text
lang
```

Il precedente nome pubblico/bootstrap `i18n` è superseded e non viene mantenuto come alias salvo futura esigenza esplicita.

Il modello canonico del messaggio resta:

```text
domain
message-id
structured fields
UTF-8
```

Il testo localizzato è presentation data e non identità canonica dell'evento.

## 5. Selezione della lingua

La lingua RumiAI non viene più scelta leggendo configurazione bootstrap e non viene dedotta da `LC_ALL`, `LC_MESSAGES` o `LANG` dell'host.

La selezione è rappresentata dal symlink:

```text
lang/current -> <language_TERRITORY>
```

Esempio:

```text
lang/current -> it_IT
```

Il symlink deve essere relativo per preservare relocatability.

Fallback garantito:

```text
lang/en_US
```

Il resolver prova quindi:

```text
lang/current/<domain>/<message-id>
lang/en_US/<domain>/<message-id>
<domain>.<message-id>
```

La utility che mostra le lingue disponibili e aggiorna `lang/current` è stata successivamente fissata come `lang-set` nella decisione `2026-09-03-lang-and-osarch-utilities.md`.

## 6. Encoding

L'encoding RumiAI corrente è fisso:

```text
UTF-8
```

Non esiste più una preferenza bootstrap `text-encoding` da leggere o normalizzare.

I cataloghi e il testo controllato da RumiAI restano UTF-8.

## 7. Shell interattiva

Quando `rumiai-os` viene invocato senza operandi, il criterio di scelta della shell è:

```text
$SHELL se valorizzata
sh altrimenti
```

RumiAI non sceglie automaticamente Bash e non mantiene una configurazione bootstrap separata per scegliere la shell.

Principio: se l'utente preferisce una shell, l'ambiente host avrà normalmente già valorizzato `SHELL`; l'utente può comunque invocare esplicitamente un'altra shell quando desiderato.

La RumiAI shell deve avere disponibili, nel percorso interattivo supportato:

```text
environment variables RumiAI
funzioni RumiAI necessarie all'ambiente interattivo
```

Le environment variables vengono naturalmente ereditate dai processi figli. Il meccanismo shell-appropriate per caricare le funzioni RumiAI e `m_SHELL_EXT`, preservare gli startup file nativi e proteggere il core dagli alias è stato successivamente fissato da:

```text
decisions/rumiai-os/2026-09-05-interactive-shell-startup.md
```

La decisione successiva stabilisce inoltre che l'integrazione RumiAI ha come caso principale la shell interattiva non-login; le login shell non vengono emulate o forzate attraverso startup RumiAI, e le eccezioni Bash/Zsh necessarie restano confinate ai rispettivi adapter.

Il namespace state/configurazione corrente per il componente base `shell` è:

```text
$m_ROOT/conf/sys/shell/
```

ed è implementato dal prodotto a partire da `rumiai-os@90a68a7c5e8c80e36bad12035c39b6d3e8d75b56`.

## 8. Command entrypoint

Resta confermato il command entrypoint canonico:

```text
#!/usr/bin/env rumiai-os
```

Il command file è la propria implementazione; il vecchio multicall e la directory shadow `cmd/` restano superseded.

Il pathname canonico del command file interpretato viene esposto come environment variable:

```text
m_COMMAND_BIN
```

## 9. Esposizione interna del runtime

Nell'ambiente portable/attivato viene mantenuto:

```text
bin/sys/rumiai-os -> ../../rumiai-os
```

Questo symlink:

- espone il runtime canonico dentro il `PATH` RumiAI;
- permette a `#!/usr/bin/env rumiai-os` di funzionare anche senza integrazione host;
- fa sì che l'ambiente RumiAI attivo preferisca il proprio runtime rispetto a eventuali altre installazioni presenti nel `PATH` host;
- NON implementa multicall e NON codifica routing o identità dei command file.

Il nome `rumiai-os` nelle directory RumiAI che precedono `bin/sys` nel `PATH` deve essere considerato riservato, così da non oscurare accidentalmente il runtime canonico.

## 10. Stato delle decisioni successive

I punti originariamente lasciati aperti da questa decisione hanno avuto la seguente evoluzione:

1. rilevamento `<osarch>` e aggiornamento di `bin/sys-osarch` / `bin/ext-osarch`: fissati da `2026-09-03-lang-and-osarch-utilities.md` tramite `osarch-update`;
2. invocazione di `osarch-update`: fissata come comando esplicito; un eventuale richiamo automatico durante installazione, attivazione o altro lifecycle resta aperto;
3. selezione della lingua esistente e aggiornamento di `lang/current`: fissati da `2026-09-03-lang-and-osarch-utilities.md` tramite `lang-set`;
4. caricamento delle funzioni RumiAI nella shell avviata, `m_SHELL_EXT`, semantica login/non-login, adapter e protezione alias: fissati da `2026-09-05-interactive-shell-startup.md`;
5. namespace state/configurazione dei componenti base sotto `$m_ROOT/<area>/sys/<component>/`: fissato da `2026-09-06-system-base-state-namespace.md` e implementato per `shell` in `rumiai-os@90a68a7c...`.

Questi punti non autorizzano a reintrodurre nel bootstrap logica host-specific non approvata, configurazione lingua precedente o Bash-preferred selection.

## 11. Propagazione e stato di implementazione/test

Questa decisione resta autorità comportamentale per i punti che ha fissato; le decisioni Accepted successive ne specificano gli aspetti evoluti senza riaprirne i contratti non modificati.

Per il sottosistema shell, il prodotto corrente allineato al namespace state canonico è:

```text
massimilianonardi-ai/rumiai-os@90a68a7c5e8c80e36bad12035c39b6d3e8d75b56
```

La suite permanente corrente che protegge il contratto shell e il pathname fisico dell'adapter POSIX è:

```text
massimilianonardi-ai/rumiai-tests@c39b1a2c0b6e96e8e43809a6e66d16918cf90a7d
```

I precedenti test shell legati a Bash-preferred selection, `conf/shell/default` e altri contratti superseded sono stati rimossi durante il riallineamento della suite e non costituiscono più autorità sul comportamento corrente.

Questo stato documentale e della suite **non dichiara validazione fisica** di `rumiai-os@90a68a7c...`. La precedente evidenza fisica rimane valida esclusivamente per le revisioni e i contratti che furono effettivamente validati; la revisione shell corrente dovrà essere esercitata in una validation run appropriata.
