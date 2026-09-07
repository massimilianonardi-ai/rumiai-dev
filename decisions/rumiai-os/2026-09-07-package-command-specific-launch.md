# Decisione — Launch command-specific in `cmd/` e ruolo invariato di `link/`

Date: 2026-09-07  
Status: **Accepted**

## Contesto

Il modello package corrente ha fissato `cmd/<pkg-command>` come command entry RumiAI, `link/<pkg-command>` come binding package-local verso un executable upstream e `launcher` come primitive comune del sistema base.

La decisione `2026-09-06-package-command-entry-link-and-launcher.md` aveva inizialmente imposto una relazione uno-a-uno fra `cmd/` e `link/` e una forma canonica del command entry che delegava senza adattamenti command-specific.

Questa decisione precisa il modello dopo aver esaminato command che richiedono una launch line specifica, per esempio:

```text
java -jar application.jar [argomenti utente]
```

oppure command che richiedono argomenti fissi o una working directory specifica.

Questa unità modifica soltanto `rumiai-dev`. Non autorizza modifiche a `rumiai-os` o `rumiai-tests`.

---

## 1. `cmd/<pkg-command>` possiede la logica di launch specifica del command

`cmd/<pkg-command>` resta sempre il command entry package-local RumiAI del command esposto.

Oltre alla delega alla primitive comune `launcher`, il command entry può contenere la minima preparazione necessaria allo specifico command, inclusi quando realmente necessari:

```text
scelta della launch line
argomenti fissi
composizione degli argomenti con quelli ricevuti dall'utente
working directory specifica
path package-local necessari alla launch line
```

Esempio concettuale:

```text
cmd/myapp
    -> launcher java -jar application.jar [argomenti utente]
```

La conoscenza che `myapp` deve essere avviato tramite `java -jar application.jar` appartiene al packaging/command entry di `myapp`, non a `link/`, non al file `env` e non alla logica generica del `launcher`.

Il command entry non deve duplicare la preparazione comune del runtime che appartiene al `launcher`, come isolamento environment, sourcing degli `env` e finalizzazione dell'esecuzione.

---

## 2. `link/` mantiene una sola responsabilità

Quando esiste:

```text
<package-version>/link/<pkg-command>
```

resta un symbolic link relativo verso un executable sotto:

```text
<package-version>/root/
```

della **stessa versione concreta dello stesso package**.

`link/` non può puntare:

```text
fuori dal root/ del package concreto
verso un altro package
verso una dependency
verso un selector current di un altro package
```

Non vengono codificati in `link/`:

```text
argomenti fissi
working directory
variabili environment
State Instance
dependency selection
launch line composta
```

Questa decisione riafferma quindi integralmente la semantica di `link/ -> root/` dello stesso package.

---

## 3. `link/<pkg-command>` non è obbligatorio per ogni command entry

La precedente regola secondo cui `cmd/` e `link/` dovevano avere esattamente lo stesso insieme di nomi è superseded.

Regola corrente:

```text
ogni command esposto
    -> deve avere cmd/<pkg-command>

command che usa un executable upstream del proprio root/ come target diretto
    -> può usare link/<pkg-command>

command la cui launch line è composta esplicitamente da cmd/<pkg-command>
    -> non richiede un link/<pkg-command> artificiale
```

Non deve essere creato un wrapper artificiale dentro `root/` soltanto per mantenere una relazione uno-a-uno con `link/`.

La presenza o assenza di `link/<pkg-command>` deve derivare dalla reale struttura del command, non da uniformità cosmetica del layout.

---

## 4. Separazione delle responsabilità

Il modello corrente è:

```text
cmd/<pkg-command>
    identità del command RumiAI package-local
    adattamento/launch line specifica del command quando necessario
    delega alla primitive launcher

launcher
    preparazione runtime comune
    isolation environment
    source degli env applicabili
    finalizzazione ed exec

link/<pkg-command>
    quando necessario, puro binding relativo verso executable nello stesso root/

root/
    tree upstream del package concreto
```

Una dependency usata dalla launch line non cambia la semantica di `link/`: la dependency deve essere resa disponibile attraverso il modello dependency/environment che verrà fissato separatamente.

---

## 5. Firma del `launcher`

Questa decisione fissa che la launch line specifica appartiene a `cmd/<pkg-command>` e può essere consegnata al `launcher`.

Non fissa ancora la forma finale della firma shell del `launcher` nei casi:

```text
command con link/<pkg-command>
command con launch line esplicita e senza link/<pkg-command>
```

La firma verrà chiusa insieme alla prima implementazione del launcher, senza riaprire le responsabilità fissate qui.

In particolare, qualunque forma finale venga scelta deve permettere semanticamente casi come:

```text
launcher java -jar application.jar [argomenti utente]
```

senza trasformare `link/` in un binding cross-package.

---

## 6. Supersession mirata

Da `2026-09-06-package-command-entry-link-and-launcher.md` sono superseded esclusivamente le regole incompatibili che impongono:

```text
relazione obbligatoria uno-a-uno fra ogni cmd/<pkg-command> e link/<pkg-command>
link/<pkg-command> obbligatorio per ogni command esposto
command entry limitato alla sola delega senza adattamento command-specific
argomenti del command entry necessariamente coincidenti con i soli argomenti ricevuti dal command pubblico
launcher obbligatoriamente vincolato a <package-version>/link/<pkg-command> come unico target possibile
```

Restano validi:

```text
cmd/<pkg-command> come command entry package-local
#!/usr/bin/env rumiai-os come entrypoint canonico
launcher come primitive comune in core.lib.sh
m_COMMAND_BIN come pathname canonico del command interpretato
link/<pkg-command>, quando presente, come symlink relativo verso root/ dello stesso package
assenza di scansione di root/
package != command
```

---

## 7. Implementazione e test

Alla data di questa decisione il modello non è ancora implementato in `rumiai-os` e non esistono test permanenti `pkg`/launcher in `rumiai-tests`.

Quando verrà implementato, i test dovranno proteggere almeno:

```text
command semplice con link/ verso root/ dello stesso package
command con argomenti fissi definiti in cmd/
command con working directory specifica definita in cmd/
command con launch line composta e senza link/ artificiale
link/ mai cross-package
argomenti utente preservati esattamente nella launch line
runtime comune ancora delegato a launcher
```

---

## 8. Invarianti fissati

```text
PKG-CMD-LAUNCH-01  ogni command esposto possiede sempre cmd/<pkg-command>
PKG-CMD-LAUNCH-02  cmd/<pkg-command> è il luogo della minima logica di launch specifica del command
PKG-CMD-LAUNCH-03  argomenti fissi e working directory command-specific appartengono a cmd/, non a link/
PKG-CMD-LAUNCH-04  link/<pkg-command>, quando presente, è sempre un symlink relativo verso root/ della stessa versione concreta dello stesso package
PKG-CMD-LAUNCH-05  link/ non può puntare a dependency o package differenti
PKG-CMD-LAUNCH-06  link/<pkg-command> non è obbligatorio quando cmd/<pkg-command> definisce esplicitamente una launch line che non usa un executable diretto del proprio root/
PKG-CMD-LAUNCH-07  non si crea un wrapper artificiale in root/ soltanto per mantenere cmd/link uno-a-uno
PKG-CMD-LAUNCH-08  launcher conserva esclusivamente la preparazione runtime comune; la logica specifica resta nel command entry
PKG-CMD-LAUNCH-09  la firma shell finale di launcher per i due casi resta da fissare senza modificare queste responsabilità
```
