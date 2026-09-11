# Decisione — Autorizzazione privilegiata per package `setuid_root`

Date: 2026-09-11  
Status: **Accepted**

## 1. Relazione con la decisione precedente

Questa decisione aggiorna esclusivamente il privilege boundary fissato in:

```text
decisions/rumiai-os/2026-09-11-package-setuid-root-and-electron.md
```

In particolare supersede:

```text
§10 Privilege boundary
PKG-SETUID-10
il requisito di test "assenza di sudo/su/pkexec nel nuovo path di integrazione"
```

Tutti gli altri invarianti `PKG-SETUID-*` e `PKG-ELECTRON-*` della decisione precedente restano validi salvo quanto esplicitamente precisato qui.

La correzione deriva dall'istruzione esplicita dell'utente del 2026-09-11: per il requisito reale di `setuid_root`, l'uso di `sudo` è considerato giustificato purché l'utente venga informato del motivo dell'autorizzazione e dei comandi privilegiati che verranno eseguiti.

---

## 2. Confine di responsabilità invariato

La trasformazione filesystem resta responsabilità di:

```text
pkg_integrate
```

Non viene spostata in:

```text
pkg_extract
launcher
repository adapter
package command wrapper
```

Non si esegue l'intero:

```text
pkg install ...
```

con privilegi elevati.

Download, repository access, extraction, catalog handling, dependency resolution, state routing e le altre operazioni del package manager continuano quindi ad avvenire con le credenziali normali del processo.

L'elevazione è limitata alla minima porzione che richiede realmente privilegi amministrativi.

---

## 3. Operazioni privilegiabili

Per ogni pathname dichiarata in `setuid_root`, le sole operazioni che possono essere eseguite tramite elevazione sono semanticamente:

```text
chown 0:0 <target>
chmod 4755 <target>
```

nell'ordine già fissato:

```text
chown
-> chmod
```

Non sono autorizzati tramite questo meccanismo:

```text
shell privilegiata
sudo sh -c
script privilegiato
postinstall/preinstall
command proveniente dal catalogo
owner/group/mode arbitrari
rm/mv/cp privilegiati
download o network privilegiati
repository adapter privilegiati
```

Il catalogo continua a fornire soltanto pathname dichiarative. Non controlla il comando eseguito con privilegi.

---

## 4. Processo già privilegiato

Se il processo corrente ha effective uid numerico:

```text
0
```

`pkg_integrate` esegue direttamente le utility richieste senza invocare `sudo`.

La semantica materiale resta esattamente:

```text
uid 0
gid 0
mode 4755
```

---

## 5. Processo non privilegiato

Se l'effective uid è diverso da `0`, `pkg_integrate` può usare:

```text
sudo
```

esclusivamente per le due operazioni fisse della sezione precedente.

`sudo` è una dipendenza implementation-specific e non POSIX. Il suo uso è una eccezione esplicita al baseline POSIX autorizzata dall'utente per questo requisito concreto.

Ragione tecnica:

```text
setuid_root richiede ownership uid=0,gid=0
un normale utente POSIX non può assegnare uid 0
eseguire tutto pkg install come root allargherebbe inutilmente il privilege boundary
limitare sudo a chown/chmod mantiene download, parsing e integrazione generale non privilegiati
```

La risoluzione di `sudo` deve usare il path sicuro fornito dalla primitive POSIX `command -p`; non deve affidarsi a un eventuale executable omonimo inserito arbitrariamente nel `PATH` del chiamante.

Se `sudo` non è disponibile nel path sicuro, l'operazione fallisce con status operativo `1`.

---

## 6. Trasparenza verso l'utente

Prima della prima invocazione privilegiata per un target, RumiAI deve informare l'utente che l'autorizzazione amministrativa serve a impostare ownership root e mode setuid richiesti dal package.

Devono essere mostrati anche i due comandi semanticamente equivalenti che verranno eseguiti tramite `sudo`, inclusa la pathname target effettiva.

L'output non deve nascondere o sostituire il comando con un generico "installazione richiede privilegi".

La pathname mostrata deve essere rappresentata in forma shell-quoted non ambigua entro il dominio già ammesso da `setuid_root`.

L'eventuale prompt/password è gestito da `sudo`; RumiAI non legge, memorizza o inoltra direttamente la password amministrativa.

---

## 7. Failure e rollback

Se l'utente nega l'autorizzazione, se `sudo` fallisce, oppure se uno dei due comandi privilegiati fallisce:

```text
pkg_integrate -> status 1
```

Il failure model resta quello già fissato:

```text
target trasformati ritirati
originali ripristinati
state creato dalla stessa integrazione rollbackato
useful root restituita al caller
nessun provider marker residuo
```

Non viene introdotto fallback `--no-sandbox`.

---

## 8. Commit point e cleanup dei backup

La provider publication resta l'ultima operazione semanticamente rollback-relevant dell'integrazione `setuid_root`.

Finché la provider publication non è riuscita, i backup originali necessari al rollback devono restare integri.

Dopo provider publication riuscita la concrete version è semanticamente committed. Il successivo cleanup dei backup transienti non deve tentare un rollback dopo aver iniziato a distruggere gli originali, perché un cleanup parziale non può garantire la reversibilità completa.

Quindi:

```text
provider publication fallisce
    -> rollback completo usando backup ancora integri

provider publication riesce
    -> commit point
    -> cleanup transienti
```

Il normale success path deve comunque eliminare completamente il materiale transiente e i test permanenti devono verificarlo.

Un eventuale failure eccezionale del solo cleanup dopo il commit point deve essere segnalato ma non deve avviare un rollback parziale della concrete version già pubblicata.

Questo non introduce crash recovery, journal o transaction engine generale.

---

## 9. Testing aggiornato

La copertura permanente deve proteggere almeno:

```text
processo uid 0 -> nessun sudo
processo non-root -> uso di sudo limitato a chown 0:0 e chmod 4755
sudo risolto tramite command -p
nessun sudo sh -c o script privilegiato
motivo dell'elevazione mostrato all'utente
comandi privilegiati mostrati prima dell'esecuzione
ordine chown prima di chmod
sudo assente/failure/denial -> status 1 e rollback
provider publication non precede la materializzazione setuid_root
provider failure -> rollback con backup integri
cleanup normale -> nessun transient object persistente
cleanup post-commit non avvia rollback parziale
nessun fallback --no-sandbox
```

I test non privilegiati possono simulare l'esecutore `sudo` interno per verificare deterministicamente il lifecycle senza richiedere password o root.

La physical validation del path reale deve invece verificare su un host Linux di riferimento che il risultato concreto abbia realmente:

```text
uid 0
gid 0
mode 4755
```

---

## 10. Invarianti correnti

```text
PKG-SETUID-10A  sudo è ammesso soltanto quando euid != 0 e soltanto per chown 0:0 e chmod 4755 dei target setuid_root
PKG-SETUID-10B  l'intero pkg install non viene eseguito come root
PKG-SETUID-10C  nessuna shell/script/catalog command viene eseguita con sudo
PKG-SETUID-10D  prima dell'elevazione l'utente vede motivo e comandi privilegiati
PKG-SETUID-10E  RumiAI non acquisisce direttamente la password amministrativa
PKG-SETUID-10F  sudo è una eccezione non-POSIX esplicitamente autorizzata e risolta tramite command -p
PKG-SETUID-10G  sudo assente, negato o fallito produce status 1 e rollback
PKG-SETUID-10H  nessun fallback --no-sandbox viene introdotto
PKG-SETUID-16   provider publication è il commit point; il cleanup successivo non può innescare rollback parziale dopo distruzione dei backup
```
