# Physical validation — package `setuid_root` ed Electron

Date: 2026-09-12  
Status: **Validated**

## 1. Scope

Questo documento registra la physical validation revision-specific dell'unità definita da:

```text
decisions/rumiai-os/2026-09-11-package-setuid-root-and-electron.md
decisions/rumiai-os/2026-09-11-package-setuid-root-privilege-authorization.md
```

La validation copre:

- materializzazione `setuid_root` come responsabilità di `pkg_integrate`;
- autorizzazione amministrativa limitata alle sole operazioni fisse `chown 0:0` e `chmod 4755` quando l'euid non è `0`;
- installazione reale di Electron Linux ARM64 dal catalogo e dall'upstream;
- risultato reale `uid=0 gid=0 mode=4755` su `chrome-sandbox`;
- regressione completa della selection permanente `rumiai-os/pkg` sui due reference host ARM64 correnti.

Non viene introdotta alcuna nuova primitive o fase.

---

## 2. Revisioni esercitate

Prodotto:

```text
rumiai-os@f121a7c843a1cbc26bfab2866e04ea2a3add98f9
```

Catalogo osservato dal gate live e ancora HEAD corrente al momento della registrazione:

```text
pkg-catalog@0b2257c8cd79534eeb8f19870d1aa93c317cb707
```

Suite usata dal gate live Electron:

```text
rumiai-tests@cd03d487b557937ef1389c0b743c2f1dce5b0b5f
selection: external/electron/install-live.test
```

Alla revisione live, `rumiai-validate.conf` pinna esattamente:

```text
rumiai-os-commit	f121a7c843a1cbc26bfab2866e04ea2a3add98f9
selection	external/electron/install-live.test
```

Suite usata per la regressione package finale sui due host:

```text
rumiai-tests@364a7c223cbe7670097f26fcb2b44012171147ef
selection: rumiai-os/pkg
```

`364a7c223cbe7670097f26fcb2b44012171147ef` discende dal commit live e modifica soltanto la configurazione del launcher di validation per selezionare `rumiai-os/pkg`; il test live Electron resta quello già esercitato.

---

## 3. Gate live Electron — Ubuntu ARM64

Validation branch:

```text
validation/20260912T075602+0200-278005
```

Evidence commit:

```text
47dc6e069d4dc28c0b36a3b45cdf6f746885740a
```

Parent dell'evidence commit:

```text
cd03d487b557937ef1389c0b743c2f1dce5b0b5f
```

Host:

```text
OS:           Linux
OS version:   Ubuntu 26.04.1 LTS
architecture: aarch64
kernel:       Linux 7.0.0-31-generic
```

Risultato:

```text
PASS   external/electron/install-live.test
runner exit status: 0
```

L'evidence persistita registra:

```text
installed=electron@v44.3.0!linux-arm64
catalog-head=0b2257c8cd79534eeb8f19870d1aa93c317cb707
electron-target=electron
chrome-sandbox=uid:0 gid:0 mode:4755
```

Sul percorso non-root il test ha inoltre osservato prima dell'elevazione:

- il messaggio esplicito che spiega perché serve autorizzazione amministrativa;
- il comando effettivo `sudo -- /usr/bin/chown 0:0 <target>`;
- il comando effettivo `sudo -- /usr/bin/chmod 4755 <target>`;
- il prompt di autenticazione gestito da `sudo`.

La password amministrativa non appartiene a RumiAI e non viene acquisita, memorizzata o inoltrata dal test o dal package manager.

Il gate live prova quindi sul reference host Linux ARM64 che l'installazione reale termina con il sandbox di Electron root-owned e con modo setuid esattamente `4755`, senza ricorrere a `--no-sandbox`.

---

## 4. Regressione package finale — Ubuntu ARM64

Validation branch:

```text
validation/20260912T084020+0200-278759
```

Evidence commit:

```text
521f6e216784228bcff3de7235167fd2558e773b
```

Parent dell'evidence commit:

```text
364a7c223cbe7670097f26fcb2b44012171147ef
```

Host:

```text
Ubuntu 26.04.1 LTS
aarch64
Linux 7.0.0-31-generic
```

Risultato:

```text
PASS   10
FAIL   0
SKIP   0
ERROR  0
TOTAL  10
runner exit status: 0
```

Passano tutti i test della selection `rumiai-os/pkg`, incluso `rumiai-os/pkg/setuid.test`.

---

## 5. Regressione package finale — macOS ARM64

Validation branch:

```text
validation/20260912T084039+0200-41424
```

Evidence commit:

```text
78582f058f3f5f1a5cbf6844e04496bf01ebc94d
```

Parent dell'evidence commit:

```text
364a7c223cbe7670097f26fcb2b44012171147ef
```

Host:

```text
macOS 26.6.2
arm64
Darwin 25.6.0
```

Risultato:

```text
PASS   10
FAIL   0
SKIP   0
ERROR  0
TOTAL  10
runner exit status: 0
```

Passano gli stessi dieci test della selection `rumiai-os/pkg`, incluso il comportamento non-Linux protetto da `setuid.test`.

Il gate live Electron non viene eseguito su macOS: la primitive `setuid_root` è ammessa soltanto nelle definizioni target-specific Linux e la definizione Electron macOS è fuori dallo scope di questa unità.

---

## 6. Chiusura della unità

Per la revisione prodotto indicata risultano completati:

```text
contract setuid_root                         completed
privilege authorization contract            completed
implementation                              completed
permanent tests                             completed
Linux ARM64 real Electron install           completed
Linux ARM64 real uid/gid/mode validation    completed
Ubuntu ARM64 package regression             completed
macOS ARM64 package regression              completed
```

La unità `setuid_root` / Electron può quindi considerarsi completata e fisicamente validata sui reference host ARM64 correnti.

Non è richiesta alcuna ulteriore modifica a `rumiai-os`, `rumiai-tests` o `pkg-catalog` per chiudere questa unità.

---

## 7. Confini della evidence

Questa evidence non estende retroattivamente la validazione ad altre revisioni.

In particolare:

- Electron Linux x86_64 resta coperto dal contratto e dai test permanenti, ma non è stato esercitato fisicamente su un reference host x86_64 in questa sessione;
- Electron macOS e Windows restano fuori dallo scope fissato dalla decisione originale;
- non viene autorizzata alcuna elevazione diversa dai due comandi fissi già approvati;
- non vengono introdotti hook privilegiati, shell privilegiata, owner/group/mode arbitrari, capability, ACL o `--no-sandbox`;
- provider publication resta il commit point semantico dell'integrazione;
- le evidence precedenti restano immutabili e revision-specific;
- Git resta forward-only.

Il package manager ritorna alla pianificazione ordinaria. Nessuna feature successiva e nessun nuovo nome di fase vengono fissati da questo documento.
