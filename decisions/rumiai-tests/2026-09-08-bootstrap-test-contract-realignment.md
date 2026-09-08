# Decisione — Riallineamento dei test permanenti bootstrap al contratto corrente

Date: 2026-09-08  
Status: **Accepted**

## Contesto

La validation macOS del target:

```text
rumiai-os@7d17bd8b3c5158f3c367c708669c81ddc5a1839c
rumiai-tests@7aae99daadaa6534af79b343f07f42e6ef85d7e5
selection=rumiai-os/bootstrap
```

ha prodotto la sessione locale:

```text
20260908T231406+0200-17700
```

con risultato:

```text
PASS   9
FAIL   18
SKIP   0
ERROR  0
TOTAL  27
```

La sessione non e ancora integrata nel repository e non costituisce una validation riuscita del target.

L'analisi dei FAIL contro le fonti autorevoli correnti mostra che la maggioranza dei test bootstrap rimasti dalla Phase 0/1 protegge contratti successivamente superseded dalla baseline bootstrap/runtime consolidata il 2026-09-02. Il prodotto corrente non deve essere modificato per ripristinare tali contratti storici.

Questa decisione riallinea la suite permanente alla semantica corrente senza modificare `rumiai-os`.

## 1. Autorita corrente

Il riallineamento segue in particolare:

```text
RULES.md
CONSISTENCY-GATE.md
TESTING.md
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/LANG-BOOTSTRAP.md
specifications/rumiai-os/I18N-BOOTSTRAP.md
decisions/rumiai-os/2026-08-28-i18n-message-fields.md
decisions/rumiai-os/2026-09-02-bootstrap-runtime-standards.md
decisions/rumiai-os/2026-09-03-runtime-library-layout.md
```

Le precedenti aspettative incompatibili presenti nei test non prevalgono su queste fonti.

## 2. Test bootstrap da rimuovere

I seguenti test proteggono esclusivamente contratti superseded e vengono rimossi dalla suite corrente:

```text
tests/rumiai-os/bootstrap/i18n-load-missing.test
tests/rumiai-os/bootstrap/i18n-load-source-failure.test
tests/rumiai-os/bootstrap/language-config-data-not-code.test
tests/rumiai-os/bootstrap/language-config-invalid.test
tests/rumiai-os/bootstrap/language-config-precedence.test
tests/rumiai-os/bootstrap/language-locale-selection.test
tests/rumiai-os/bootstrap/log-load-missing.test
tests/rumiai-os/bootstrap/log-load-source-failure.test
tests/rumiai-os/bootstrap/system-data-apis.test
tests/rumiai-os/bootstrap/system-function-naming.test
tests/rumiai-os/bootstrap/system-platform-primitives.test
tests/rumiai-os/bootstrap/text-encoding-config-invalid.test
tests/rumiai-os/bootstrap/text-encoding-config-normalization.test
tests/rumiai-os/bootstrap/text-encoding-fallback.test
```

Motivi principali:

- `i18n` e superseded da `lang` e non esiste come alias corrente;
- il bootstrap non carica piu `lib/i18n.lib`, `lib/log.lib`, `lib/data.lib` o `lib/platform.lib`;
- la lingua non viene scelta da configurazione bootstrap o locale host;
- l'encoding e fisso a UTF-8 e non viene negoziato/configurato;
- le environment variables `RumiAI_*` sono superseded da `m_*`;
- non esiste un namespace generale `RumiAI_*` per le funzioni shell;
- il vecchio platform/data API model non appartiene al runtime corrente.

La rimozione non riduce il contratto prodotto corrente: elimina soltanto guardie riferite a comportamenti che non fanno piu parte del contratto.

## 3. Test bootstrap da riallineare

Quattro proprieta restano correnti ma i test esistenti usano aspettative storiche.

### `circular-symlink-failure.test`

Resta valida la proprieta che un bootstrap entrypoint non risolvibile a causa di un ciclo di symlink fallisca senza proseguire nel runtime.

Il test corrente viene riallineato al comportamento consolidato:

```text
status=1
stderr=bootstrap bin resolution error
```

Non viene ripristinato il precedente token Phase 0.

### `path-resolution-failure.test`

Resta valida la proprieta che un command name non risolvibile durante la root discovery del bootstrap fallisca.

Il test viene riallineato allo stesso errore bootstrap corrente:

```text
status=1
stderr=bootstrap bin resolution error
```

### `language-fallback.test`

Il fallback resta un contratto corrente, ma non deriva dal locale host e non usa `RumiAI_LANGUAGE`.

Il test deve verificare:

```text
m_LANGUAGE_FALLBACK=en_US
m_LANG_FALLBACK_DIR=$m_ROOT/lang/en_US
```

anche con locale host arbitrario.

Il comportamento funzionale del resolver resta protetto dal gruppo corrente `tests/rumiai-os/lang/`.

### `text-encoding-default.test`

Il concetto di encoding configurabile/default e superseded. La proprieta corrente e invece che l'encoding RumiAI sia sempre:

```text
UTF-8
```

Il vecchio test viene sostituito da:

```text
tests/rumiai-os/bootstrap/text-encoding-fixed.test
```

che verifica `m_TEXT_ENCODING=UTF-8` indipendentemente dal locale host.

## 4. Riallineamento dei test `lang`

I test correnti:

```text
tests/rumiai-os/lang/catalog-data-not-code.test
tests/rumiai-os/lang/public-command.test
tests/rumiai-os/lang/selection.test
```

proteggono proprieta ancora valide, ma le loro fixture copiano `rumiai-os`, `bin/` e `lang/` senza `lib/`.

Poiche il bootstrap corrente carica obbligatoriamente:

```text
lib/sh/core.lib.sh
```

le fixture devono includere anche il tree `lib/` del target.

Questa e una correzione della fixture, non una nuova dipendenza di prodotto.

## 5. Riallineamento dei test `log`

Il contratto corrente conserva il modello:

```text
log severity domain message-id [field-name field-value]...
```

con severity esplicita/validata e structured fields separati.

I test `tests/rumiai-os/log/` sono pero ancora legati a:

```text
RumiAI_LANG_DIR
RumiAI_LANGUAGE
RumiAI_TEXT_ENCODING
RumiAI_LOG_LEVEL
lib/i18n.lib
lib/log.lib
```

Queste dipendenze vengono rimosse.

I test devono esercitare il logger attraverso il bootstrap corrente e `lib/sh/core.lib.sh`, usando `m_LOG_LEVEL`, e proteggere soltanto proprieta correnti:

- filtro per severity/threshold;
- rifiuto di severity non valida;
- rifiuto di `m_LOG_LEVEL` non valido;
- parita delle coppie field/value;
- rendering dei field value come valori, senza reintrodurre l'obbligo storico di escaping non presente nel contratto corrente.

I codici interni specifici del logger non vengono promossi a nuova API normativa se non gia fissati da una fonte autorevole.

## 6. Nessuna modifica prodotto

Questa unita di lavoro non modifica `rumiai-os`.

Il target della physical validation resta:

```text
rumiai-os@7d17bd8b3c5158f3c367c708669c81ddc5a1839c
```

La selection corrente resta:

```text
rumiai-os/bootstrap
```

perche il prodotto non cambia e il gate fisico da ripetere e quello che ha esposto il drift dei test bootstrap.

Le correzioni ai gruppi `lang` e `log` sono maintenance della suite corrente e devono essere verificate con development run/prove proporzionate; non ampliano da sole il gate fisico corrente.

## 7. Stato della validation macOS fallita

La sessione locale:

```text
20260908T231406+0200-17700
```

resta un'evidenza di validation fallita contro la suite `7aae99d...`.

Non deve essere reinterpretata come fallimento del contratto bootstrap corrente ne come validation riuscita del target. Non viene riscritta o cancellata da questa decisione.

Una nuova physical validation e necessaria con la suite riallineata.

## 8. Invarianti

```text
TEST-REALIGN-01  i test permanenti proteggono soltanto contratti correnti, non meccanismi superseded
TEST-REALIGN-02  rumiai-os non viene modificato per soddisfare aspettative storiche della suite
TEST-REALIGN-03  i18n, RumiAI_* e le vecchie librerie root-level non vengono reintrodotti
TEST-REALIGN-04  path resolution failure e circular symlink failure restano protetti secondo il comportamento bootstrap corrente
TEST-REALIGN-05  language fallback resta fisso a en_US e indipendente dal locale host
TEST-REALIGN-06  text encoding resta fisso a UTF-8 e non configurabile dal bootstrap
TEST-REALIGN-07  le fixture lang includono lib/ per eseguire il bootstrap corrente
TEST-REALIGN-08  i test log usano il runtime corrente e non promuovono codici interni non normativi a nuova API
TEST-REALIGN-09  la validation corrente resta rumiai-os@7d17bd8... con selection rumiai-os/bootstrap
TEST-REALIGN-10  la sessione 20260908T231406+0200-17700 resta evidenza storica fallita e non viene riscritta
```
