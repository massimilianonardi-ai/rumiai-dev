# Specifica — Bootstrap lingua (`lang`)

Date: 2026-09-14  
Status: **Current**

## 1. Scopo

Questa specifica definisce il contratto bootstrap/runtime della localizzazione testuale tecnica di `m` e della selezione globale della lingua.

Il resource layout generale è definito da:

```text
specifications/rumiai-os/RESOURCE-MODEL.md
```

La facility tecnica resta denominata:

```text
lang
```

Il precedente nome `i18n` è superseded.

---

## 2. Environment

Il bootstrap espone:

```text
m_RES_DIR=$m_ROOT/res
m_LANG_DIR=$m_RES_DIR/sys/lang
m_LANGUAGE_FALLBACK=en_US
m_TEXT_ENCODING=UTF-8
m_LANG_CURRENT_DIR=$m_LANG_DIR/current
m_LANG_FALLBACK_DIR=$m_LANG_DIR/$m_LANGUAGE_FALLBACK
```

`m_RES_DIR` è la semantic root top-level delle risorse globali.

`m_LANG_DIR` resta l'interfaccia semantica esistente della facility tecnica `lang` e identifica esclusivamente il catalogo owner `sys`.

Queste variabili sono derivate da `m_ROOT` e restano relocatable.

---

## 3. Cataloghi tecnici

Il layout canonico dei cataloghi tecnici è:

```text
$res = $m_RES_DIR

$res/sys/lang/<locale>/<domain>/<message-id>
```

Esempio:

```text
res/sys/lang/en_US/filesystem/path-invalid
res/sys/lang/it_IT/filesystem/path-invalid
```

Ogni message file contiene testo UTF-8 trattato esclusivamente come dati.

Il contenuto dei cataloghi non viene valutato come shell code.

Il nome `<domain>` e `<message-id>` deve rispettare il contratto corrente della funzione `lang`: componenti non vuoti, con caratteri ammessi `a-z`, `0-9`, `.`, `_`, `-`, senza iniziare con separatori e senza terminare con `.`, `_` o `-`.

---

## 4. Cataloghi branded

Le risorse linguistiche del layer branded sono separate:

```text
$res/ai/lang/<locale>/...
```

Il fatto che `res/ai/lang` partecipi alla selezione globale non trasferisce tali cataloghi alla facility tecnica `lang`.

La funzione shell `lang` di `m` non risolve `ai` e non effettua merge o fallback tra owner.

Un locale supportato da un owner può avere un catalogo vuoto.

---

## 5. Selector `current`

Ogni language tree globale materializzato sotto:

```text
$res/*/lang/
```

contiene:

```text
current -> <locale>
```

`current` deve essere un symbolic link relativo verso una directory locale disponibile nello stesso language tree.

La baseline distribuita usa:

```text
res/sys/lang/current -> en_US
res/ai/lang/current  -> en_US
```

Tutti i selector globali materializzati devono rappresentare lo stesso locale.

La co-locazione del selector mutabile con i cataloghi non riclassifica i cataloghi come state.

---

## 6. Resolver tecnico `lang`

La funzione:

```text
lang <domain> <message-id>
```

usa esclusivamente il tree tecnico identificato da `m_LANG_DIR`.

L'ordine di lookup resta:

1. catalogo della lingua selezionata:

   ```text
   $m_LANG_CURRENT_DIR/<domain>/<message-id>
   ```

2. catalogo fallback tecnico:

   ```text
   $m_LANG_FALLBACK_DIR/<domain>/<message-id>
   ```

3. fallback identificativo:

   ```text
   <domain>.<message-id>
   ```

La selezione globale e il fallback sono concetti distinti: `current` esprime la lingua impostata, mentre `en_US` resta il fallback di lookup quando un messaggio manca nel catalogo selezionato.

Il comando pubblico:

```text
bin/sys/lang <domain> <message-id>
```

delega alla facility shell `lang` secondo il normale integrated command model di `m`.

---

## 7. `lang-set` — query

Il comando pubblico è:

```text
bin/sys/lang-set
```

Con zero argomenti:

```text
lang-set
```

restituisce esclusivamente il locale selezionato da:

```text
$m_RES_DIR/sys/lang/current
```

seguito da newline.

Esempio:

```text
it_IT
```

Non restituisce elenco dei locale, conteggi di messaggi o prefissi tabellari.

La query richiede che il selector `sys` sia un symbolic link relativo valido verso un locale disponibile nello stesso tree. Un selector assente, non-symlink, broken o esterno al tree è errore e non viene sostituito implicitamente dal fallback.

---

## 8. `lang-set` — selezione

Con esattamente un argomento:

```text
lang-set <locale>
```

il comando opera sui language tree globali materializzati nella forma:

```text
$m_RES_DIR/*/lang
```

Il contratto è:

1. deve esistere almeno il tree tecnico `$m_LANG_DIR`;
2. `<locale>` deve corrispondere a una directory locale disponibile in ogni language tree partecipante;
3. ogni selector `current` esistente deve essere un symbolic link relativo valido verso un locale disponibile nello stesso tree;
4. tutte le verifiche avvengono prima di cambiare un selector;
5. i nuovi selector sono symbolic link relativi con target esattamente `<locale>`;
6. i tree non-`sys` vengono aggiornati prima del tree `sys`;
7. il tree `sys` viene aggiornato per ultimo come commit logico della selezione osservata dalla query;
8. se un errore ordinario interrompe l'aggiornamento, il comando tenta di ripristinare tutti i selector alla selezione precedente;
9. al successo il comando non produce output.

Se `<locale>` manca anche in un solo language tree partecipante, il comando fallisce senza mutazioni.

Il comando non codifica il nome `ai`: la sincronizzazione usa la forma generale dei language tree sotto `m_RES_DIR` e quindi non crea una dipendenza semantica `m -> RumiAI`.

L'operazione multi-owner non promette crash-atomicity filesystem. Non vengono introdotti journal, generation directory, lock framework o transaction manager.

---

## 9. Package

`lang-set` non visita `$m_PKG_DIR` e non modifica resource tree, selector o configurazioni dei package.

Ogni package mantiene le proprie risorse, inclusi eventuali cataloghi di lingua, nel proprio tree/versione gestita.

La specifica integrazione di un package può configurare l'upstream affinché segua la lingua globale oppure un proprio override. L'eventuale mapping tra locale RumiAI e locale upstream è responsabilità dell'integrazione specifica.

Non viene introdotta una API universale package-language.

---

## 10. Error handling

Il comportamento resta coerente con il logging/fatal model corrente:

- numero argomenti non valido: fatal `execution.invalid-arguments`;
- locale richiesto non disponibile in tutti i tree partecipanti: fatal `execution.invalid-arguments` con il locale richiesto come field quando applicabile;
- selector o path strutturalmente non valido: fatal `filesystem.path-invalid`;
- errore operativo durante preparazione, aggiornamento o rollback: fatal `execution.execution-failed` quando il normale path di logging è disponibile.

Il comando non deve sovrascrivere oggetti non-symlink collocati nel pathname `current`.

---

## 11. Invarianti

```text
LANG-01  m_LANGUAGE_FALLBACK resta en_US
LANG-02  m_TEXT_ENCODING resta UTF-8
LANG-03  m_LANG_DIR vale $m_RES_DIR/sys/lang
LANG-04  m_LANG_CURRENT_DIR vale $m_LANG_DIR/current
LANG-05  m_LANG_FALLBACK_DIR vale $m_LANG_DIR/en_US
LANG-06  lang risolve selected -> fallback -> domain.message-id nel solo owner sys
LANG-07  il contenuto dei cataloghi è dati e non viene eseguito come shell code
LANG-08  res/*/lang/current è un symlink relativo verso un locale disponibile nello stesso tree
LANG-09  tutti i selector lang globali materializzati rappresentano lo stesso locale
LANG-10  lang-set senza argomenti restituisce soltanto il locale selezionato da sys/current
LANG-11  lang-set con un locale prevalida tutti i tree partecipanti prima di mutare
LANG-12  lang-set aggiorna sys per ultimo e tenta rollback sugli errori ordinari gestiti
LANG-13  lang-set non modifica package resources o package configuration
LANG-14  m non dipende semanticamente dal catalogo ai
LANG-15  la selezione iniziale distribuita è en_US
```
