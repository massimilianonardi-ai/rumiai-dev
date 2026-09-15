# Decisione — Trust Git process-local per workspace condivisi

Date: 2026-09-15  
Status: **Accepted / Active**

## 1. Contesto

`rumiai-validate` deve funzionare quando il workspace RumiAI canonico è collocato su un volume condiviso tra host differenti, incluso il caso macOS/Linux.

Su tali volumi Git può rifiutare un checkout con il controllo `safe.directory` anche quando l'utente ha avviato esplicitamente il launcher corretto e il layout del workspace è quello canonico.

Il launcher non deve aggirare globalmente il controllo di sicurezza e non deve modificare persistentemente la configurazione Git dell'utente.

## 2. Regola

Dopo avere risolto dal proprio pathname la root canonica di `rumiai-tests`, il launcher può installare nella sola configurazione Git **command scope** del proprio processo un record:

```text
safe.directory=<rumiai-tests-root>
```

Quando la root della suite corrisponde al layout canonico:

```text
<rumiai-os-root>/src/rumiai-tests
```

e la root `rumiai-os` contiene il proprio metadata Git, il launcher aggiunge anche:

```text
safe.directory=<rumiai-os-root>
```

I record sono esportati ai processi figli della validation in modo che `rumiai-test` e i test eseguiti sulla stessa coppia di checkout non falliscano soltanto per ownership resa differente dal volume condiviso.

## 3. Limiti di sicurezza

Il launcher:

- non usa `safe.directory=*`;
- non aggiunge wildcard;
- non modifica `~/.gitconfig`, configurazioni system o configurazioni repository;
- non rende trusted directory dedotte da input dello scope;
- rende trusted soltanto la propria root già risolta e, nel layout canonico, l'esatta root prodotto che la contiene.

Il trust termina con il processo `rumiai-validate` e i suoi figli.

## 4. Diagnostica

Il primo controllo Git che verifica la root della suite non deve sopprimere stderr.

Se Git rifiuta comunque il repository per una ragione diversa dal caso gestito, il messaggio Git originale deve restare visibile prima della diagnostica del launcher. Il launcher non deve trasformare indistintamente ogni errore Git in una falsa conclusione che la directory non sia un repository.

## 5. Relazione con il selettore interattivo

Questa decisione integra `2026-09-15-interactive-validation-scope-selector.md` senza modificarne la semantica:

```text
self-location
→ trust process-local delle root esatte applicabili
→ verifica root Git
→ cd nella suite
→ self-update
→ discovery/menu
→ validation
```

Restano invariati scope, exit status, evidence revision-specific, worktree temporanei, cleanliness gate e Git forward-only.

## 6. Invarianti

```text
VAL-GIT-01  nessun safe.directory globale o system viene scritto dal launcher
VAL-GIT-02  safe.directory=* e wildcard equivalenti sono vietati
VAL-GIT-03  la root rumiai-tests risolta dal launcher può essere trusted nel solo command scope
VAL-GIT-04  nel layout canonico può essere trusted anche l'esatta root rumiai-os contenente la suite
VAL-GIT-05  il trust process-local viene ereditato da runner e test figli
VAL-GIT-06  l'errore Git iniziale non viene soppresso
VAL-GIT-07  nessuna modifica a rumiai-os è richiesta
VAL-GIT-08  Git resta forward-only
```

## 7. Testing richiesto

La suite permanente deve includere una prova che simuli un Git che rifiuta suite/prodotto in assenza dei due `safe.directory` esatti e verifichi che:

```text
il launcher parte da una cwd estranea
la suite è trusted prima del primo comando Git
la root prodotto canonica è trusted
il trust è esportato ai processi figli
nessuna wildcard è necessaria
```
