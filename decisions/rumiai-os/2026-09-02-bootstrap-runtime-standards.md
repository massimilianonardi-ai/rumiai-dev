# Decisione — Standard bootstrap/runtime dopo l'ottimizzazione

Date: 2026-09-02  
Status: **Accepted**

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

`bin/` è il contenitore delle directory di eseguibili o symlink che possono partecipare al `PATH`; `bin/` non viene aggiunta direttamente al `PATH`.

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
    eseguibili/symlink third-party platform-independent

bin/ext-<osarch>/
    eseguibili/symlink third-party specifici della piattaforma

bin/ext-osarch
    symlink relativo alla directory ext-<osarch> della piattaforma attiva
```

Esempio di `<osarch>` già ammesso:

```text
macos-arm64
```

Il meccanismo che rileva la piattaforma corrente e aggiorna `sys-osarch` / `ext-osarch` resta da definire. Non è fissato se sarà manuale, richiamato durante installazione/attivazione o automatizzato. Nessun automatismo viene introdotto nel bootstrap finché questa decisione non viene presa.

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

Il meccanismo/script che mostra le lingue disponibili e aggiorna `lang/current` resta da definire.

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

La RumiAI shell deve avere disponibili:

```text
environment variables RumiAI
funzioni RumiAI necessarie all'ambiente interattivo
```

Le environment variables vengono naturalmente ereditate dai processi figli. Il meccanismo portabile e shell-appropriate con cui rendere disponibili anche le funzioni RumiAI nella nuova shell resta una domanda aperta e deve essere definito separatamente senza introdurre una dipendenza accidentale da Bash.

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

## 10. Decisioni esplicitamente aperte

Restano da definire separatamente:

1. utility/script per rilevare `<osarch>` e aggiornare `bin/sys-osarch` e `bin/ext-osarch`;
2. condizioni di invocazione di tale utility: manuale, installazione/attivazione o automatismo;
3. utility/script per scegliere una lingua esistente e aggiornare `lang/current`;
4. meccanismo con cui la shell avviata eredita/carica le funzioni RumiAI oltre alle environment variables.

Queste questioni aperte non autorizzano a reintrodurre nel bootstrap logica host-specific, configurazione lingua precedente o Bash-preferred selection.

## 11. Propagazione e stato di implementazione/test

Questa decisione aggiorna l'autorità documentale in `rumiai-dev`.

Non costituisce autorizzazione a modificare `rumiai-os` oltre alle modifiche prodotto già effettuate dall'utente, e non modifica in questa unità di lavoro `rumiai-tests`.

La suite permanente corrente contiene ancora test legati ai contratti superseded (`RumiAI_*`, configurazione lingua/encoding, `bin/` direttamente nel PATH, Bash-preferred shell). Tali test devono essere riallineati quando verranno affrontate le relative implementazioni; non devono essere usati per riaprire le decisioni fissate qui.

La precedente evidenza fisica rimane valida esclusivamente per le revisioni e i contratti che furono effettivamente validati.