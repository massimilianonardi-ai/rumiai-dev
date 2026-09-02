# Decisione — Entrypoint e root fisici/canonicalizzati

Date: 2026-08-27  
Status: **Partially superseded 2026-09-02**

## Rationale ancora valido

Resta accettato il principio fondamentale secondo cui il bootstrap `rumiai-os` determina la propria root fisica/canonicalizzata indipendentemente da:

```text
invocazione diretta
PATH
symbolic link
caller CWD
```

La root deriva dal pathname fisico/canonicalizzato del bootstrap reale, non dal pathname di un alias esterno.

Resta inoltre valido il principio di usare facility standard e una canonicalizzazione esplicita, senza resolver ricorsivi custom basati su parsing di output umano.

## Parti superseded

Sono superseded da decisioni e specifiche successive:

```text
RumiAI_BOOTSTRAP_BIN
RumiAI_ROOT
```

che sono sostituiti da:

```text
m_BOOTSTRAP_BIN
m_ROOT
```

È inoltre superseded la descrizione storica dell'algoritmo che assumeva direttamente `command -v` quando `$0` non conteneva slash.

Il bootstrap stabilizzato può prima riconoscere un pathname esistente/symlink nel caller CWD e, solo altrimenti, ricorrere a `PATH`.

La regola corrente di canonicalizzazione è:

```text
VALIDATE EXISTENCE
→ CANONICALIZE EXISTING PATH
→ VALIDATE REQUIRED TYPE
```

ed è definita normativamente in:

```text
specifications/rumiai-os/ENTRYPOINT-ROOT-RESOLUTION.md
```

## Autorità corrente

Decisione di riallineamento:

```text
decisions/rumiai-os/2026-09-02-bootstrap-runtime-standards.md
```

Specifica corrente:

```text
specifications/rumiai-os/ENTRYPOINT-ROOT-RESOLUTION.md
```

Il contenuto storico completo precedente a questo riallineamento resta disponibile in Git history e costituisce rationale/evidenza storica, non contratto corrente per le parti sostituite.
