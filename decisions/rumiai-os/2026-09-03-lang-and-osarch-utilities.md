# Decisione — Utility `lang`, `lang-set` e `osarch-update`

Date: 2026-09-03  
Status: **Accepted**

## Contesto

La decisione `2026-09-02-bootstrap-runtime-standards.md` ha fissato il modello `lang/current`, il layout `bin/sys-<osarch>` / `bin/ext-<osarch>` e i relativi symlink attivi, lasciando esplicitamente aperte le utility che gestiscono queste risorse.

Questa decisione chiude tali punti senza modificare il bootstrap automatico, l'ordine del `PATH`, il resolver `lang` o il modello degli executable root.

## 1. Comando `lang`

`bin/sys/lang` è il comando platform-independent che espone l'API shell `lang` già inizializzata dal bootstrap.

Il comando usa il normale command entry:

```text
#!/usr/bin/env rumiai-os
```

ed equivale semanticamente a:

```sh
lang "$@"
```

Non introduce un secondo resolver e non duplica la logica del bootstrap.

## 2. Comando `lang-set`

`bin/sys/lang-set` gestisce la lingua selezionata da RumiAI.

Le lingue disponibili sono le directory immediate sotto:

```text
$m_LANG_DIR
```

escludendo `current`, che è il symlink di selezione e non un catalogo.

### Invocazione senza argomenti

```text
lang-set
```

emette:

```text
current<TAB><language>
<language><TAB><non-empty-message-count>
...
```

La prima riga identifica la lingua effettiva corrente. Se `lang/current` non identifica una directory disponibile, la lingua effettiva è il fallback `m_LANGUAGE_FALLBACK`.

Per ogni lingua disponibile il conteggio include soltanto i message file regolari e non vuoti presenti nella forma canonica:

```text
<language>/<domain>/<message-id>
```

Directory, file vuoti e oggetti fuori da questa profondità non incrementano il totale.

### Invocazione con una lingua

```text
lang-set <language>
```

accetta esattamente una lingua il cui nome corrisponde esattamente a una directory disponibile sotto `m_LANG_DIR`.

Su successo aggiorna:

```text
lang/current -> <language>
```

Il target del symlink è relativo. Il comando non deduce mai la lingua dalle locale dell'host.

Se `lang/current` esiste come oggetto non-symlink, il comando non lo sovrascrive.

Più di un argomento o una lingua non disponibile producono errore e non modificano la selezione esistente.

## 3. Comando `osarch-update`

`bin/sys/osarch-update` rileva la piattaforma nativa corrente e aggiorna l'active executable layout.

L'identificatore usa il vocabulary già fissato:

```text
<platform>-<architecture>
```

Platform correnti:

```text
linux
macos
windows
```

Architecture correnti:

```text
arm64
x86_64
```

Normalizzazione host iniziale:

```text
uname -s
    Linux                  -> linux
    Darwin                 -> macos
    CYGWIN* / MSYS* / MINGW* -> windows

uname -m
    arm64 / aarch64        -> arm64
    x86_64 / amd64 / x64   -> x86_64
```

Le comparazioni host possono accettare equivalenti differenze di maiuscole quando necessarie, ma il token prodotto resta sempre canonico.

Una piattaforma o architettura non riconosciuta produce errore; non viene inventato un nuovo token.

Per l'`osarch` rilevato, il comando garantisce l'esistenza di:

```text
bin/sys-<osarch>/
bin/ext-<osarch>/
```

quindi aggiorna i symlink relativi:

```text
bin/sys-osarch -> sys-<osarch>
bin/ext-osarch -> ext-<osarch>
```

Se uno dei pathname dei symlink attivi esiste come oggetto non-symlink, il comando non lo sovrascrive.

Il comando non modifica l'ordine del `PATH` e non introduce nuove environment variables pubbliche.

## 4. Invocazione di `osarch-update`

`osarch-update` è un comando esplicito. Questa decisione non aggiunge alcun richiamo automatico dal bootstrap.

L'eventuale futura invocazione automatica durante installazione, attivazione o altro lifecycle richiede una decisione separata.

## 5. Invarianti preservati

Restano invariati:

- POSIX.1-2024 / Issue 8 come baseline;
- root discovery dal bootstrap fisico;
- namespace `m_*` limitato alle environment variables RumiAI;
- `bin/sys/` per comandi RumiAI platform-independent;
- `bin/sys-osarch` / `bin/ext-osarch` come semantic roots già presenti nel `PATH`;
- `lang/current` come symlink relativo;
- fallback `en_US`;
- assenza di host-locale inference;
- resolver `lang(domain, message-id)` e cataloghi statici UTF-8;
- Git forward-only.
