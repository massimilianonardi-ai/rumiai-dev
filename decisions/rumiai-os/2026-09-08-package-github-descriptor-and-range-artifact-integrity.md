# Decisione — GitHub repository descriptor e artifact/integrity range-level

Date: 2026-09-08  
Status: **Accepted**

## Contesto

Il repository descriptor di uno stream RumiAI è già fissato come directory dichiarativa `repository/` di file scalari e `repository/type` seleziona l'adapter RumiAI. `archive_regex`, `digest_regex` e `digest_type` sono già fissati semanticamente come dati della range definition e non del repository descriptor.

Il primo caso concreto usato per chiudere il contratto minimo è DBeaver Community, distribuito attraverso GitHub Releases nel repository upstream:

```text
dbeaver/dbeaver
```

Le release correnti verificate mostrano asset target-specific e digest SHA-256 esposto direttamente dalla GitHub Releases API. Release storiche più vecchie possono avere naming degli asset differente e `digest` assente; il catalogo corrente non deve fingere compatibilità retroattiva non verificata.

Questa decisione chiude soltanto i campi GitHub necessari al repository descriptor e il sottoinsieme artifact/integrity della range definition necessario al primo catalogo concreto. Non implementa ancora l'adapter GitHub in `rumiai-os` e non chiude la serializzazione completa di extract/integration/cmd/link/env/default/state.

---

## 1. Campi del repository type `github`

Per:

```text
repository/type
github
```

il descriptor GitHub richiede esattamente i campi comuni a questo caso:

```text
repository/type
repository/owner
repository/repository
```

Semantica:

```text
owner
    owner/organization GitHub del repository upstream

repository
    nome del repository GitHub sotto owner
```

Entrambi usano il formato scalare già fissato per `repository/<field>`.

Non viene memorizzato nel catalogo un URL GitHub completo quando `owner` e `repository` identificano già univocamente la risorsa. L'adapter costruisce gli endpoint GitHub necessari.

Credenziali, token o secret non appartengono al package-definition catalog.

Campi GitHub ulteriori richiedono un caso concreto e una decisione successiva.

---

## 2. File scalari artifact/integrity nella range definition

Il sottoinsieme corrente della directory:

```text
nNNNN=<version-minimum>/
```

può contenere i file scalari:

```text
archive_regex
digest_type
digest_regex
```

I nomi con underscore sono intenzionali perché questi identificatori machine-oriented sono già stabiliti semanticamente nel package model.

I tre file, quando presenti, seguono lo stesso contratto scalare dei campi `repository/`:

```text
file regolare non eseguibile
un solo valore non vuoto
una sola riga terminata da LF
nessun CR
nessun NUL
nessuna seconda riga
nessuna interpretazione shell
```

Non vengono source, eval o espansi come variabili/template shell.

---

## 3. `archive_regex`

`archive_regex` seleziona l'artifact upstream attraverso il suo nome/identity repository-specific esposto dall'adapter.

Il valore usa **POSIX Extended Regular Expression (ERE)**.

Il match viene effettuato sul nome completo dell'artifact della release concreta già selezionata.

La regex deve produrre esattamente un artifact applicabile:

```text
0 match       -> errore
1 match       -> artifact selezionato
>1 match      -> errore ambiguo
```

Il pattern è dato puro. Non esiste interpolazione di `<version>`, shell expansion o command substitution. Se il pattern deve riconoscere la versione nel nome dell'artifact, lo fa tramite la propria ERE.

`archive_regex` descrive la selezione dell'artifact del range; non appartiene al repository descriptor.

---

## 4. `digest_type`

`digest_type` dichiara l'algoritmo digest richiesto per l'artifact selezionato.

Il primo valore accettato e necessario al caso concreto è:

```text
sha256
```

Se `digest_type` è presente, la resolution dell'artifact deve ottenere un digest dello stesso algoritmo per l'artifact selezionato. Digest assente, algoritmo diverso o valore non valido rendono la resolution non valida.

Il digest concreto non viene salvato staticamente nel catalogo: viene ottenuto dal repository corrente durante la resolution.

Nuovi digest type vengono aggiunti soltanto quando richiesti da un caso concreto.

---

## 5. Digest fornito come metadata repository

Se `digest_type` è presente ma `digest_regex` è assente, l'adapter deve ottenere il digest direttamente dai metadata repository dell'artifact selezionato.

Per `type=github`, il caso corrente usa il campo `digest` della GitHub Releases asset API.

Per:

```text
digest_type = sha256
```

il valore GitHub deve avere forma semanticamente equivalente a:

```text
sha256:<hex-digest>
```

per lo stesso release asset selezionato da `archive_regex`.

Se GitHub restituisce `digest: null`, un algoritmo differente o un digest malformato, il requisito di integrity del range non è soddisfatto e la resolution fallisce.

Questa regola evita di introdurre `digest_regex` quando GitHub fornisce già direttamente il digest dell'asset.

---

## 6. `digest_regex`

`digest_regex` resta range-level ed è opzionale.

Viene usato soltanto quando il digest deve essere individuato tramite un artifact/risorsa repository distinta anziché essere disponibile come metadata dell'artifact selezionato.

Il valore, quando verrà usato, sarà una POSIX ERE di selezione repository-specific analoga a `archive_regex`.

Il parsing del contenuto di checksum file o altre rappresentazioni esterne non viene fissato da questa decisione perché DBeaver/GitHub non lo richiede. Prima del primo uso reale di `digest_regex` dovrà essere fissato il contratto proporzionato per estrarre il digest dalla risorsa selezionata.

L'assenza di `digest_regex` non significa assenza di verifica quando `digest_type` è presente: significa che il digest deve provenire dai metadata dell'artifact.

---

## 7. Primo catalogo concreto: DBeaver

Il package canonico usato nel catalogo è:

```text
dbeaver
```

La prima materializzazione copre soltanto gli archive Linux `.tar.gz` per i target RumiAI:

```text
linux-x86_64
linux-arm64
```

Non viene creato `catalog/` generic perché gli artifact sono target-specific.

Non vengono ancora creati stream macOS o Windows: gli artifact correnti usano rispettivamente DMG e ZIP/EXE e la relativa materializzazione/extract non viene anticipata in questa unità.

Entrambi gli stream usano:

```text
repository/type       github
repository/owner      dbeaver
repository/repository dbeaver
```

Il primo anchor è:

```text
n0001=26.1.5
```

perché 26.1.5 e 26.2.0 sono state verificate con lo stesso naming Linux corrente e con digest SHA-256 direttamente disponibile nei metadata GitHub asset.

Le release precedenti all'anchor non hanno un range applicabile in questo primo catalogo e non sono dichiarate supportate da questa definition. In particolare, release storiche verificate mostrano naming differente e/o `digest` GitHub assente.

Per `linux-x86_64`:

```text
archive_regex = ^dbeaver-ce-[A-Za-z0-9][A-Za-z0-9._+~-]*-linux-x86_64\.tar\.gz$
digest_type   = sha256
```

Per `linux-arm64`:

```text
archive_regex = ^dbeaver-ce-[A-Za-z0-9][A-Za-z0-9._+~-]*-linux-aarch64\.tar\.gz$
digest_type   = sha256
```

`digest_regex` è assente in entrambi gli stream.

Il mapping intenzionale è:

```text
RumiAI arm64  <-> upstream asset token aarch64
```

La stringa upstream resta dato del pattern e non modifica l'identificatore RumiAI `arm64`.

---

## 8. Stato di implementazione

Questa decisione autorizza la prima package definition concreta nel repository:

```text
massimilianonardi-ai/pkg-catalog
```

Non autorizza modifiche a `rumiai-os`.

L'adapter:

```text
lib/sh/pkg-repository-github.lib.sh
```

resta ancora da implementare e validare nel prodotto in una fase separata. Il catalogo concreto fissa i dati che tale adapter dovrà consumare, non costituisce da solo una `pkg install` già eseguibile.

Non esistono ancora test permanenti `pkg` nel repository `rumiai-tests`; questa unità non introduce codice prodotto né backend osservabile e non richiede physical validation separata.

---

## 9. Invarianti fissati

```text
PKG-GITHUB-DESC-01  type=github richiede repository/owner e repository/repository
PKG-GITHUB-DESC-02  URL completi e credenziali GitHub non vengono duplicati nel catalogo quando owner/repository bastano
PKG-RANGE-ARTIFACT-01 archive_regex, digest_type e digest_regex sono file scalari range-level
PKG-RANGE-ARTIFACT-02 archive_regex usa POSIX ERE sul nome completo dell'artifact e deve selezionare esattamente un artifact
PKG-RANGE-ARTIFACT-03 archive_regex non usa shell/template/interpolazione
PKG-RANGE-ARTIFACT-04 il primo digest_type supportato dal contratto concreto è sha256
PKG-RANGE-ARTIFACT-05 digest_type richiede un digest dello stesso algoritmo ottenuto durante la resolution e non salvato staticamente nel catalogo
PKG-RANGE-ARTIFACT-06 digest_regex assente significa digest ottenuto dai metadata dell'artifact tramite adapter
PKG-RANGE-ARTIFACT-07 per GitHub il metadata corrente è release-asset digest; null/mismatch/malformed -> errore se digest_type è richiesto
PKG-RANGE-ARTIFACT-08 digest_regex resta opzionale e il parsing di checksum artifact viene fissato solo al primo caso che lo richiede
PKG-DBEAVER-CATALOG-01 il primo package concreto è dbeaver
PKG-DBEAVER-CATALOG-02 il primo catalogo DBeaver contiene solo catalog-linux-x86_64 e catalog-linux-arm64
PKG-DBEAVER-CATALOG-03 entrambi usano github owner=dbeaver repository=dbeaver
PKG-DBEAVER-CATALOG-04 il primo range è n0001=26.1.5
PKG-DBEAVER-CATALOG-05 i due stream selezionano i rispettivi tar.gz correnti tramite archive_regex e richiedono sha256
PKG-DBEAVER-CATALOG-06 digest_regex è assente perché il digest è fornito direttamente dai metadata GitHub release asset
PKG-DBEAVER-CATALOG-07 release precedenti a 26.1.5 non sono dichiarate supportate dal primo catalogo
```
