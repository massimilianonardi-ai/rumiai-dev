# Decisione — Policy Git per store, state runtime e metadata host

Date: 2026-09-08  
Status: **Accepted**

## Contesto

Il checkout `rumiai-os` puo essere usato anche come root operativa di RumiAI OS. Le decisioni correnti hanno gia fissato:

- `$m_ROOT/pkg/` come store locale dei package gestiti;
- `conf`, `data`, `home`, `cache`, `log`, `run`, `tmp` come state area top-level;
- `data` e `home` come state persistente autorevole;
- `cache` e `log` come state persistente non autorevole;
- `run` e `tmp` come state transient;
- `conf/sys/...` come namespace della configurazione base RumiAI versionata nel prodotto.

Quando store o state runtime vengono materializzati dentro un checkout Git del prodotto, non devono trasformare il repository in una working tree dirty soltanto perche RumiAI e stato eseguito. Lo stesso vale per metadata host estranei al prodotto come `.DS_Store` su macOS.

Il 2026-09-08 l'utente ha autorizzato esplicitamente l'introduzione della `.gitignore` di `rumiai-os` per le root runtime appropriate.

## 1. Root ignorate

La `.gitignore` di `rumiai-os` ignora integralmente e soltanto al top-level le seguenti root runtime/store:

```text
/pkg/
/data/
/home/
/cache/
/log/
/run/
/tmp/
```

I pattern sono root-anchored. Un pathname omonimo sotto un altro sottalbero, per esempio `src/cache/`, non viene ignorato da questa policy.

## 2. `conf/` resta versionabile

`conf/` non viene ignorata integralmente.

La root contiene configurazione base di prodotto versionata, attualmente sotto `conf/sys/...`, oltre a essere la semantic root dello state di configurazione persistente. La separazione futura fra configurazione base versionata e configurazione runtime non viene ridefinita da questa decisione.

Di conseguenza non viene introdotto:

```text
/conf/
```

nella `.gitignore` corrente.

## 3. Metadata host

Il file:

```text
.DS_Store
```

viene ignorato a qualsiasi profondita del checkout come metadata host macOS privo di semantica RumiAI.

Questa regola non introduce una categoria generale di ignore host-specific: ulteriori pattern host vengono aggiunti soltanto quando emerge una necessita concreta.

## 4. Effetto della policy

La policy Git non modifica la semantica delle root RumiAI e non autorizza a cancellarne il contenuto.

In particolare:

- `data/` e `home/` restano state autorevole pur essendo ignorate dal repository sorgente;
- `cache/` e `log/` restano state persistente non autorevole;
- `run/` e `tmp/` restano transient;
- `pkg/` resta lo store locale dei package gestiti;
- file gia tracked non diventano untracked per effetto di una regola `.gitignore`;
- il launcher di validation puo continuare a richiedere una working tree Git clean: state runtime conforme alla policy non compare come modifica untracked.

## 5. Implementazione corrente

La prima implementazione prodotto di questa policy e:

```text
massimilianonardi-ai/rumiai-os@7d17bd8b3c5158f3c367c708669c81ddc5a1839c
```

Il commit aggiunge soltanto la `.gitignore` del repository e non modifica il bootstrap o altro codice runtime.

La suite permanente protegge il contratto con:

```text
tests/rumiai-os/bootstrap/runtime-state-ignore.test
```

Il test usa una repository Git temporanea isolata per verificare la semantica della `.gitignore`, evitando che exclude globali o `.git/info/exclude` dell'host possano produrre falsi positivi.

## 6. Physical validation corrente

Il nuovo commit `rumiai-os@7d17bd8b3c5158f3c367c708669c81ddc5a1839c` contiene invariato anche il contratto delle semantic root introdotto in `262316902997319b56f1d5097d636b38de9dd2c4`.

La physical validation corrente viene quindi riallineata a:

```text
rumiai-os-commit<TAB>7d17bd8b3c5158f3c367c708669c81ddc5a1839c
selection<TAB>rumiai-os/bootstrap
```

Questa configurazione supersede specificamente il target `262316902997319b56f1d5097d636b38de9dd2c4` indicato nella sezione "Configurazione della validation corrente" della decisione `decisions/rumiai-tests/2026-09-08-validation-launcher.md`. Il commit `262316...` resta la prima implementazione delle semantic root estese, ma non e piu il target operativo della validation corrente.

La validation resta da eseguire sugli host di riferimento; l'allineamento di codice, test e configurazione non costituisce da solo evidenza fisica.

## 7. Test permanente

La suite permanente deve verificare almeno che:

- `pkg`, `data`, `home`, `cache`, `log`, `run`, `tmp` siano ignorate al top-level;
- gli stessi nomi non siano ignorati automaticamente quando annidati sotto un altro sottalbero;
- `conf/` resti tracciabile;
- `.DS_Store` sia ignorato anche fuori dalla root;
- la verifica sia isolata dagli exclude locali/globali dell'host.

## 8. Invarianti

```text
GITIGNORE-01  le root top-level pkg data home cache log run tmp appartengono a store/state runtime e sono ignorate dal repository sorgente
GITIGNORE-02  i pattern delle root RumiAI sono root-anchored
GITIGNORE-03  conf non e ignorata integralmente perche contiene configurazione base versionata
GITIGNORE-04  .DS_Store e ignorato a qualsiasi profondita come metadata host privo di semantica RumiAI
GITIGNORE-05  la policy ignore non modifica la classificazione semantica dello state e non autorizza cancellazioni
GITIGNORE-06  il comportamento e protetto da un test permanente isolato dagli exclude dell'host
GITIGNORE-07  la prima implementazione prodotto e rumiai-os@7d17bd8b3c5158f3c367c708669c81ddc5a1839c
GITIGNORE-08  la validation corrente usa target 7d17bd8b3c5158f3c367c708669c81ddc5a1839c e selection rumiai-os/bootstrap
```