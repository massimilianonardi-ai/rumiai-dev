# Decisione — Collocazione locale della cache `pkg-catalog`

Date: 2026-09-08  
Status: **Accepted**

## Contesto

Il repository canonico delle package definition concrete è:

```text
massimilianonardi-ai/pkg-catalog
```

La decisione `2026-09-07-package-catalog-repository.md` aveva lasciato separatamente aperti clone/fetch/cache, policy di aggiornamento e pinning/snapshot.

Durante la validation del primo adapter GitHub è emersa la necessità operativa di disporre localmente di una working copy aggiornabile del catalogo. L'utente ha escluso `/tmp` come collocazione normale e ha chiesto di scegliere fra le state area persistenti RumiAI `home`, `cache` e `data`.

Le state area correnti classificano:

```text
conf, data, home  persistent authoritative
cache             persistent non-authoritative, rigenerabile
run, tmp           transient
```

Una working copy Git di `pkg-catalog` è ricostruibile integralmente dal repository remoto autorevole e quindi non deve essere classificata come dato locale autorevole.

---

## 1. State area canonica

Quando il componente base `pkg` necessita di una working copy persistente locale di `pkg-catalog`, la state area corretta è:

```text
cache
```

Non vengono usate:

```text
home
    compatibility bucket conservativo per stato non classificabile meglio

data
    dati autorevoli/non rigenerabili

tmp
    scratch transiente
```

La working copy resta rigenerabile dal repository remoto e può essere eliminata e ricostruita senza perdere stato autorevole RumiAI.

---

## 2. Path canonico

Poiché `pkg` è un componente del sistema base, si applica il namespace state `sys/<component>` già fissato.

La working copy/cache canonica è quindi:

```text
$m_ROOT/cache/sys/pkg/pkg-catalog/
```

Il nome finale `pkg-catalog` riusa esattamente l'identità già fissata del repository e non introduce un alias ulteriore.

Il pathname è interno alla root relocatable RumiAI e non dipende da directory host-specific.

---

## 3. Autorità e rigenerabilità

Il repository GitHub `massimilianonardi-ai/pkg-catalog` resta la fonte autorevole delle package definition concrete.

La working copy sotto:

```text
$m_ROOT/cache/sys/pkg/pkg-catalog/
```

è soltanto una replica/cache locale.

Il suo contenuto non acquisisce autorità autonoma perché presente sul filesystem locale.

Se la cache viene persa o invalidata, il sistema può ricostruirla dal repository remoto secondo il futuro meccanismo di sincronizzazione fissato per `pkg`.

---

## 4. Ambito della decisione

Questa decisione fissa esclusivamente:

```text
state area = cache
path       = $m_ROOT/cache/sys/pkg/pkg-catalog/
```

Restano separatamente da fissare quando necessario:

```text
protocollo e comando di clone/fetch/update
quando effettuare l'aggiornamento
comportamento offline
failure policy durante l'aggiornamento
pinning dello snapshot usato da una singola operazione pkg
concorrenza/locking della working copy
validazione dell'origine Git e della history ricevuta
```

In particolare questa decisione non prescrive automaticamente `git pull` come API o primitive di prodotto: identifica soltanto il luogo corretto se viene mantenuta una working copy Git locale.

---

## 5. Supersession mirata

Questa decisione chiude soltanto la parte relativa alla **collocazione della cache locale** lasciata aperta da:

```text
decisions/rumiai-os/2026-09-07-package-catalog-repository.md
```

La policy di clone/fetch/update e quella di pinning/snapshot restano aperte come sopra.

---

## 6. Invarianti fissati

```text
PKG-CATALOG-CACHE-01  una working copy persistente locale di pkg-catalog appartiene alla state area cache
PKG-CATALOG-CACHE-02  il path canonico è $m_ROOT/cache/sys/pkg/pkg-catalog/
PKG-CATALOG-CACHE-03  la working copy locale è non-authoritative e rigenerabile dal repository remoto
PKG-CATALOG-CACHE-04  home e data non vengono usati per la working copy del catalogo
PKG-CATALOG-CACHE-05  tmp non è la collocazione normale della working copy persistente del catalogo
PKG-CATALOG-CACHE-06  questa decisione non fissa ancora clone/fetch/update, offline policy, locking o pinning/snapshot
```
