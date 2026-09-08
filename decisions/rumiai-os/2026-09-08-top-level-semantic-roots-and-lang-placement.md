# Decisione — Semantic root top-level e collocazione di `lang`

Date: 2026-09-08  
Status: **Accepted**

## Contesto

Il bootstrap/runtime aveva consolidato inizialmente come semantic root esportate `bin`, `lib`, `conf`, `lang` e successivamente `src`.

Le decisioni Accepted del package manager hanno nel frattempo fissato anche:

- `$m_ROOT/pkg/` come store locale dei package gestiti;
- `conf`, `data`, `home`, `cache`, `log`, `run`, `tmp` come state area canoniche e come root fisiche top-level separate;
- l'assenza di una root intermedia comune per tali state area;
- il divieto di una root globale `$m_ROOT/var/`, con `var/` riservata al routing view package-local.

Il 2026-09-08 l'utente ha riallineato esplicitamente il prodotto aggiungendo al bootstrap le environment variables corrispondenti alle semantic root top-level mancanti e mantenendo `lang` come root top-level autonoma:

```text
massimilianonardi-ai/rumiai-os@262316902997319b56f1d5097d636b38de9dd2c4
```

Questa decisione consolida tale correzione e chiude la valutazione sulla possibile ricollocazione di `lang` sotto `data` o sotto una nuova root generica di risorse.

---

## 1. Semantic root top-level correnti

Le semantic root top-level correnti sotto `m_ROOT` e le rispettive environment variables sono:

```text
bin/    -> m_BIN_DIR=$m_ROOT/bin
lib/    -> m_LIB_DIR=$m_ROOT/lib
pkg/    -> m_PKG_DIR=$m_ROOT/pkg
lang/   -> m_LANG_DIR=$m_ROOT/lang
src/    -> m_SRC_DIR=$m_ROOT/src
conf/   -> m_CONF_DIR=$m_ROOT/conf
data/   -> m_DATA_DIR=$m_ROOT/data
home/   -> m_HOME_DIR=$m_ROOT/home
cache/  -> m_CACHE_DIR=$m_ROOT/cache
log/    -> m_LOG_DIR=$m_ROOT/log
run/    -> m_RUN_DIR=$m_ROOT/run
tmp/    -> m_TMP_DIR=$m_ROOT/tmp
```

`m_ROOT` resta la root fisica fondamentale stabilita dalla Phase 0. Le variabili sopra identificano semanticamente le root top-level del layout corrente e restano relocatable perché sono derivate da `m_ROOT`.

La presenza della environment variable identifica il pathname canonico della semantic root; non implica che la directory debba essere materializzata dal bootstrap. Le root che non sono ancora necessarie possono essere assenti e vengono create dal sottosistema responsabile quando il relativo lifecycle lo richiede.

---

## 2. Regola per le environment variables di root

Ogni directory top-level che viene fissata come semantic root canonica di RumiAI deve avere una corrispondente environment variable nel namespace `m_*`, normalmente nella forma:

```text
m_<NAME>_DIR
```

Questa regola non autorizza a creare alias per ogni sottodirectory.

I sottopercorsi ordinari continuano a essere derivati dalla semantic root appropriata. In particolare resta valido il contratto già fissato per `lib/`: non vengono introdotte variabili come `m_LIB_SH_DIR` o `m_LIB_JS_DIR` soltanto per abbreviare `$m_LIB_DIR/sh` o `$m_LIB_DIR/js`.

Le variabili già fissate per sottodirectory di `bin/` restano eccezioni motivate da ruoli runtime autonomi nel modello degli executable e nel `PATH`:

```text
m_BIN_SYS_DIR
m_BIN_SYS_OSARCH_DIR
m_BIN_EXT_DIR
m_BIN_EXT_OSARCH_DIR
```

Una futura nuova semantic root top-level richiede una decisione esplicita sul layout; la corrispondente root variable viene definita insieme a tale decisione e non deve essere dedotta introducendo autonomamente nuovi namespace filesystem.

---

## 3. State area e assenza di `var/` globale

Le state area canoniche restano esattamente:

```text
conf
data
home
cache
log
run
tmp
```

con la classificazione già fissata da `2026-09-05-package-state-var-default.md`:

```text
persistent authoritative      conf, data, home
persistent non-authoritative  cache, log
transient                     run, tmp
```

Le nuove root variables non modificano tali semantiche: ne espongono soltanto i pathname canonici nell'environment del runtime.

Non viene introdotta:

```text
m_VAR_DIR
```

perché non esiste e non deve esistere una semantic root globale:

```text
$m_ROOT/var/
```

`var/` mantiene esclusivamente il significato package-local già fissato.

---

## 4. `lang/` resta una semantic root top-level

La collocazione corrente resta:

```text
m_LANG_DIR=$m_ROOT/lang
```

I cataloghi di lingua sono risorse di prodotto statiche in UTF-8 usate dal resolver `lang`; non sono state applicativo classificato nella state area `data`.

La root:

```text
m_DATA_DIR=$m_ROOT/data
```

mantiene il significato già fissato di state persistente autorevole. Non assume il significato generico di "directory contenente qualunque dato" e quindi non ingloba i cataloghi `lang`.

Di conseguenza non vengono adottati:

```text
$m_DATA_DIR/lang/
$m_DATA_DIR/sys/lang/
```

come collocazione dei cataloghi correnti.

`lang/current` resta, nel contratto attuale, il symbolic link relativo che rappresenta la selezione della lingua ed è co-locato nella root `lang/` insieme ai cataloghi. Questa co-locazione non riclassifica l'intera root `lang/` come state area.

Un'eventuale futura separazione del selector dai cataloghi richiede una decisione distinta. Non viene introdotta ora una nuova root generica come `share/`, `resources/` o equivalente soltanto per annidare `lang/`.

---

## 5. Implementazione e test permanenti

Il contratto delle semantic root top-level qui fissato è implementato nel prodotto a partire da:

```text
massimilianonardi-ai/rumiai-os@262316902997319b56f1d5097d636b38de9dd2c4
```

La suite permanente deve proteggere almeno:

- il valore di ogni root variable top-level corrente;
- `m_SRC_DIR`, già parte del contratto ma precedentemente non verificata da `semantic-roots.test`;
- il mantenimento di `m_LANG_DIR=$m_ROOT/lang`;
- l'assenza di `m_VAR_DIR` quando non è ereditata dall'ambiente chiamante;
- l'esportazione delle root variables ai processi figli, coerentemente con il loro ruolo di environment variables.

L'allineamento dei test non costituisce da solo una validation run del prodotto. La revisione `rumiai-os@262316902997319b56f1d5097d636b38de9dd2c4` resta fisicamente non validata rispetto a questa estensione delle semantic root finché i test permanenti pertinenti non vengono eseguiti in una validation session appropriata.

---

## 6. Supersession mirata

Questa decisione supersede soltanto gli elenchi correnti incompleti delle semantic root top-level nei documenti bootstrap/Phase 1 precedenti.

Non modifica:

- le semantiche delle state area già fissate;
- il package-store model sotto `pkg/`;
- il divieto di `$m_ROOT/var/`;
- il resolver `lang`, il layout dei cataloghi o `lang/current`;
- il modello degli executable sotto `bin/`;
- il ruolo locale e non-runtime di `src/`;
- POSIX, relocatability e Git forward-only.

---

## 7. Invarianti fissati

```text
SEMROOT-01  le semantic root top-level correnti sono bin, lib, pkg, lang, src, conf, data, home, cache, log, run, tmp
SEMROOT-02  ciascuna semantic root top-level corrente ha la propria environment variable m_<NAME>_DIR
SEMROOT-03  una root variable identifica il pathname canonico ma non obbliga il bootstrap a materializzare la directory
SEMROOT-04  la regola top-level non autorizza alias environment per normali sottodirectory
SEMROOT-05  le sub-root bin già fissate restano motivate dai loro ruoli autonomi nel PATH/runtime
SEMROOT-06  conf, data, home, cache, log, run, tmp conservano la classificazione state già fissata
SEMROOT-07  non esiste m_VAR_DIR e non esiste una semantic root globale $m_ROOT/var
SEMROOT-08  m_LANG_DIR resta $m_ROOT/lang e i cataloghi non vengono spostati sotto m_DATA_DIR
SEMROOT-09  data conserva il significato di state persistente autorevole e non diventa un contenitore generico di risorse
SEMROOT-10  lang/current resta il selector relativo corrente co-locato sotto lang/
SEMROOT-11  non viene introdotta una nuova root generica share/resources soltanto per contenere lang
SEMROOT-12  la prima implementazione prodotto di questo contratto esteso è rumiai-os@262316902997319b56f1d5097d636b38de9dd2c4
```
