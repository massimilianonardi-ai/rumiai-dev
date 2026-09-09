# Decisione — Baseline corrente dell'ambiente POSIX-compatible su Windows

Date: 2026-09-09  
Status: **Accepted**

## Contesto

RumiAI OS sviluppa contro POSIX e non contro le API native Windows. `RULES.md` fissa già che Windows non influenza l'architettura interna di RumiAI OS e che l'esecuzione su Windows richiede un ambiente POSIX-compatible.

Durante il completamento della package definition DBeaver è emerso il dubbio se i pathname RumiAI dovessero essere convertiti in pathname Win32 prima di lanciare un executable Windows nativo.

La correzione esplicita dell'utente del 2026-09-09 fissa che il modello RumiAI **non** deve introdurre pathname Win32, backslash, `cygpath` o conversioni package-specific per compensare un ambiente host che non preserva il contratto pathname necessario all'esecuzione normale.

Per la baseline corrente di sviluppo Windows viene assunto **MSYS2** come ambiente POSIX-compatible di riferimento.

Questa scelta è intenzionalmente distinta da un requisito esclusivo definitivo: test fisici futuri potranno stabilire se MSYS2 debba diventare un requisito formale oppure se altri ambienti POSIX-compatible soddisfino lo stesso contratto senza adattamenti RumiAI-specifici.

---

## 1. Contratto pathname interno

I pathname usati da RumiAI restano pathname POSIX e usano `/` come separatore.

Il modello interno non introduce una seconda rappresentazione persistente o package-specific del tipo:

```text
C:\\path\\to\\state
C:/path/to/state
```

perché tali forme appartengono al namespace host Windows e non al contratto interno RumiAI.

Quando un command RumiAI lancia un executable Windows nativo sotto l'ambiente POSIX-compatible corrente, gli argomenti pathname restano quelli costruiti dalle semantic root RumiAI.

---

## 2. MSYS2 come riferimento corrente

Per il lavoro corrente su Windows si assume:

```text
Windows
  -> MSYS2
      -> runtime RumiAI POSIX-compatible
      -> launch di executable Windows nativi
```

RumiAI non aggiunge conversioni pathname package-specific fra il command entry e il processo nativo.

Questa assunzione è sufficiente per completare le package definition correnti che richiedono pathname state come argomenti di launch.

---

## 3. Compatibilità di ambienti alternativi

Un ambiente Windows alternativo potrà essere considerato compatibile con questa baseline soltanto se permette a RumiAI di mantenere il proprio contratto POSIX senza introdurre nel prodotto o nelle package definition:

```text
pathname Win32 persistiti
conversioni per-package
wrapper host-specific aggiunti al modello generale
primitive come cygpath richieste dal normale package launch
```

Se un ambiente richiede tali adattamenti per il normale funzionamento dei command RumiAI, quell'ambiente non viene considerato parte della baseline corrente soltanto perché espone una shell o utility POSIX-like.

Questo non vieta una futura estensione esplicita se emergerà un requisito concreto e verrà accettata secondo il normale processo RumiAI.

---

## 4. Relazione con DBeaver

La package definition DBeaver Windows può quindi usare lo stesso command source semanticamente già fissato per Linux e macOS:

```sh
#!/usr/bin/env rumiai-os

launcher "dbeaver" \
  -configuration "$m_CONF_DIR/dbeaver/configuration" \
  -data "$m_HOME_DIR/dbeaver/.workspace" \
  "$@"
```

senza conversione a pathname Win32.

La differenza target-specific resta nel payload upstream e nel target direct-link Windows, non nel modello delle semantic root.

---

## 5. Stato della decisione

La baseline corrente fissa MSYS2 come ambiente Windows di riferimento per procedere con package definition e implementazione.

Resta aperto soltanto:

```text
physical validation su Windows
-> verificare il comportamento reale del runtime/package launch
-> decidere se MSYS2 diventa requisito esclusivo
   oppure se altri ambienti soddisfano lo stesso contratto
```

Fino a tale validazione non si dichiara MSYS2 come unico ambiente Windows ammesso in assoluto.

---

## 6. Invarianti fissati

```text
WINDOWS-POSIX-01  RumiAI mantiene un solo contratto pathname interno POSIX anche su Windows
WINDOWS-POSIX-02  il separatore pathname interno resta /
WINDOWS-POSIX-03  la baseline corrente di sviluppo Windows assume MSYS2 come ambiente POSIX-compatible di riferimento
WINDOWS-POSIX-04  MSYS2 non è ancora dichiarato requisito esclusivo definitivo prima della physical validation Windows
WINDOWS-POSIX-05  il normale package launch non introduce conversioni pathname Win32 package-specific
WINDOWS-POSIX-06  un ambiente alternativo deve soddisfare il contratto RumiAI senza richiedere adattamenti host-specific nel modello generale per essere considerato compatibile con la baseline corrente
WINDOWS-POSIX-07  una futura estensione o un requisito esclusivo Windows richiede evidence fisica e decisione esplicita
```
