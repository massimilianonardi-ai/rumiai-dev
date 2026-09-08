# Decisione — Policy Git per store, state runtime e metadata host

Date: 2026-09-08  
Status: **Accepted**  
Updated: 2026-09-09

## Contesto

Il checkout `rumiai-os` puo essere usato anche come root operativa di RumiAI OS. Le decisioni correnti hanno gia fissato:

- `$m_ROOT/pkg/` come store locale dei package gestiti;
- `conf`, `data`, `home`, `cache`, `log`, `run`, `tmp` come state area top-level;
- `src/` come workspace locale di sviluppo;
- `data` e `home` come state persistente autorevole;
- `cache` e `log` come state persistente non autorevole;
- `run` e `tmp` come state transient;
- `conf/sys/...` come namespace della configurazione base RumiAI versionata nel prodotto.

Quando workspace, store o state runtime vengono materializzati dentro un checkout Git del prodotto, il loro contenuto operativo non deve rendere dirty il repository soltanto per l'uso normale di RumiAI.

La prima implementazione usava pattern root-anchored nella `.gitignore` della root per `pkg`, `data`, `home`, `cache`, `log`, `run`, `tmp`, mentre `src` usava gia una `.gitignore` locale. Il 2026-09-08 l'utente ha corretto esplicitamente questa difformita e ha scelto un unico modello: ogni root locale/non-versionabile usa la stessa `.gitignore` interna di `src`; la `.gitignore` root resta dedicata soltanto a `.DS_Store`.

## 1. Modello uniforme per-root

Le seguenti root usano tutte la stessa policy locale:

```text
src/
pkg/
data/
home/
cache/
log/
run/
tmp/
```

Ciascuna contiene un file versionato:

```text
.gitignore
```

con contenuto esatto:

```text
*
!.gitignore
```

Questo significa che:

- il contenuto operativo della root e ignorato;
- il file `.gitignore` della root resta versionabile;
- la policy e confinata naturalmente al sottotree in cui il file si trova;
- non servono pattern root-anchored duplicati nella `.gitignore` globale.

`src/.gitignore` e la forma canonica gia esistente e le altre root la riusano senza varianti.

## 2. `.gitignore` della root

La `.gitignore` top-level contiene soltanto:

```text
.DS_Store
```

Non contiene pattern per:

```text
src
pkg
data
home
cache
log
run
tmp
conf
```

`.DS_Store` resta ignorato a qualsiasi profondita del checkout come metadata host macOS privo di semantica RumiAI.

## 3. `conf/` resta versionabile

`conf/` non adotta la policy `* / !.gitignore`.

La root contiene configurazione base di prodotto versionata, attualmente sotto `conf/sys/...`, oltre a essere la semantic root dello state di configurazione persistente. La separazione futura fra configurazione base versionata e configurazione runtime non viene ridefinita da questa decisione.

## 4. Presenza fisica delle root

Poiche Git non versiona directory vuote, i file `.gitignore` locali fanno anche da placeholder versionato e rendono fisicamente presenti nel checkout sorgente le root:

```text
src pkg data home cache log run tmp
```

Questa presenza non implica che il bootstrap debba crearle o modificarle; resta valida la distinzione tra semantic root esportata e lifecycle/materializzazione dello state.

## 5. Effetto semantico

La policy Git non modifica la classificazione delle root e non autorizza cancellazioni del loro contenuto.

In particolare:

- `src/` resta workspace locale di sviluppo e non runtime dependency;
- `pkg/` resta store locale dei package;
- `data/` e `home/` restano state persistente autorevole;
- `cache/` e `log/` restano state persistente non autorevole;
- `run/` e `tmp/` restano transient;
- `conf/` resta versionabile secondo il proprio contratto corrente;
- file gia tracked non diventano untracked per effetto di una regola `.gitignore`.

## 6. Implementazione corrente

La policy uniforme per-root e implementata in:

```text
massimilianonardi-ai/rumiai-os@c6b3027cfef278b69681ba414337e4b357aca537
```

La root `.gitignore` contiene soltanto `.DS_Store` e i file:

```text
src/.gitignore
pkg/.gitignore
data/.gitignore
home/.gitignore
cache/.gitignore
log/.gitignore
run/.gitignore
tmp/.gitignore
```

hanno tutti lo stesso contenuto `*` / `!.gitignore`.

La precedente implementazione `rumiai-os@7d17bd8...` resta evidenza storica ma la sua modalita root-anchored e superseded.

## 7. Test permanente

La suite protegge la policy con:

```text
tests/rumiai-os/bootstrap/runtime-state-ignore.test
```

Il test deve verificare in una repository Git temporanea isolata che:

- la `.gitignore` root contenga soltanto `.DS_Store`;
- `src`, `pkg`, `data`, `home`, `cache`, `log`, `run`, `tmp` usino la stessa policy locale;
- il contenuto operativo di ciascuna root sia ignorato;
- il rispettivo `.gitignore` resti tracciabile;
- directory omonime annidate altrove non siano ignorate automaticamente;
- `conf/` resti tracciabile;
- `.DS_Store` sia ignorato anche fuori dalla root;
- exclude globali o `.git/info/exclude` dell'host non possano produrre falsi positivi.

La revisione della suite usata per la physical validation di questa policy e:

```text
massimilianonardi-ai/rumiai-tests@7a28fe32ed30f0ea1108b4eab5572216e5551167
```

Il riallineamento sostanziale del test bootstrap era gia presente in `aa64b512...`; `7a28fe32...` e la revisione esatta della suite usata per la physical validation finale della coppia descritta sotto. Revisioni successive della suite non modificano retroattivamente questa evidenza.

## 8. Physical validation

La physical validation e stata eseguita con configurazione identica sui due host stabili di riferimento:

```text
rumiai-os-commit<TAB>c6b3027cfef278b69681ba414337e4b357aca537
selection<TAB>rumiai-os/bootstrap
rumiai-tests<TAB>7a28fe32ed30f0ea1108b4eab5572216e5551167
```

Evidenza macOS ARM64:

```text
validation/20260909T000836+0200-18820
Darwin/arm64
PASS 13
FAIL 0
SKIP 0
ERROR 0
```

Evidenza Ubuntu 26.04 ARM64:

```text
validation/20260909T001235+0200-7713
Ubuntu 26.04.1 LTS / aarch64
PASS 13
FAIL 0
SKIP 0
ERROR 0
```

Entrambe le sessioni registrano `runner-exit-status=0` e la stessa selection `rumiai-os/bootstrap`.

La physical validation della policy per-root e delle proprieta bootstrap incluse nella selection e quindi completata per questa coppia esatta di revisioni. L'evidenza non si trasferisce automaticamente a revisioni successive del prodotto o della suite.

## 9. Invarianti

```text
GITIGNORE-01  src pkg data home cache log run tmp usano tutti la stessa .gitignore locale
GITIGNORE-02  il contenuto esatto della policy locale e '*' seguito da '!.gitignore'
GITIGNORE-03  la .gitignore top-level contiene soltanto .DS_Store
GITIGNORE-04  conf non adotta la policy di ignore integrale perche contiene configurazione base versionata
GITIGNORE-05  .DS_Store e ignorato a qualsiasi profondita come metadata host privo di semantica RumiAI
GITIGNORE-06  la policy ignore non modifica la classificazione semantica dello state e non autorizza cancellazioni
GITIGNORE-07  le root locali sono fisicamente presenti tramite il proprio .gitignore ma il bootstrap non acquisisce per questo responsabilita di creazione
GITIGNORE-08  il comportamento e protetto da un test permanente isolato dagli exclude dell'host
GITIGNORE-09  l'implementazione corrente e rumiai-os@c6b3027cfef278b69681ba414337e4b357aca537
GITIGNORE-10  la validation di questa implementazione usa rumiai-tests@7a28fe32ed30f0ea1108b4eab5572216e5551167, target c6b3027cfef278b69681ba414337e4b357aca537 e selection rumiai-os/bootstrap sui due host stabili di riferimento
```
