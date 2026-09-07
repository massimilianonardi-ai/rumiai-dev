# Decisione — Pathname delle versioni concrete e selector `current`

Date: 2026-09-07  
Status: **Accepted**

## Contesto

Le decisioni correnti hanno già fissato:

- `$m_ROOT/pkg/` come dominio locale dei package gestiti;
- coesistenza di più versioni concrete dello stesso package;
- `current` come concetto di selezione persistente della versione predefinita;
- selector rappresentato da symbolic link relativo;
- `<osarch>` canonico nella forma `<platform>-<architecture>`;
- `current` seleziona una versione ma non costruisce l'esecuzione.

Era rimasta aperta la grammatica fisica del pathname della versione concreta e del selector.

Questa decisione chiude entrambi i punti.

Questa unità modifica soltanto `rumiai-dev`. Non autorizza modifiche a `rumiai-os` o `rumiai-tests`.

---

## 1. Pathname della versione concreta

Una versione concreta installata usa esattamente la forma:

```text
$m_ROOT/pkg/<pkg>@<version>!<osarch>/
```

Esempio:

```text
$m_ROOT/pkg/java@21.0.2+13!macos-arm64/
```

Componenti semantiche:

```text
<pkg>      identità canonica del package
<version>  versione upstream della release installata
<osarch>   target RumiAI canonico
```

La forma non introduce revisioni RumiAI, token platform separati aggiuntivi, percent encoding o altri campi del design storico del 2026-08-30.

---

## 2. Versione upstream

`<version>` preserva direttamente la versione upstream entro il seguente dominio ammesso:

```text
[A-Za-z0-9][A-Za-z0-9._+~-]*
```

Quindi sono ammessi, per esempio:

```text
1
1.2.3
v1.2.3
1.2.3-rc.1
21.0.2+13
2.0~beta1
current
```

Non sono ammessi nella singola componente `<version>`:

```text
@
!
/
whitespace
control characters
```

La versione upstream non viene interpretata come versione di compatibilità dependency e non implica un comparatore universale delle release software.

La stringa `current` non è riservata come versione upstream perché il selector corrente non usa una pseudo-versione testuale `current`.

---

## 3. Selector della versione corrente

Il selector persistente della versione predefinita usa esattamente la forma:

```text
$m_ROOT/pkg/<pkg>!<osarch>
```

ed è un symbolic link relativo verso la versione concreta selezionata:

```text
$m_ROOT/pkg/<pkg>!<osarch>
    -> <pkg>@<version>!<osarch>
```

Esempio:

```text
$m_ROOT/pkg/java!macos-arm64
    -> java@21.0.2+13!macos-arm64
```

`current` resta il nome concettuale della responsabilità del selector, non una componente letterale del pathname.

---

## 4. Assenza del campo versione come discriminante strutturale

La distinzione è interamente strutturale:

```text
<pkg>@<version>!<osarch>
    versione concreta

<pkg>!<osarch>
    selector current
```

Il selector è quindi riconoscibile per l'assenza del campo:

```text
@<version>
```

Non viene introdotto un sentinel artificiale né una pseudo-versione riservata.

Questo evita collisioni fra il selector e qualsiasi `<version>` upstream valida, inclusa la stringa letterale:

```text
current
```

---

## 5. Ruolo di `<osarch>`

`<osarch>` usa il vocabulary RumiAI già fissato:

```text
<platform>-<architecture>
```

con i token correnti definiti dalla decisione `2026-09-03-lang-and-osarch-utilities.md`.

Il pathname concreto e il selector sono entrambi qualificati da `<osarch>`.

La decisione precedente che lasciava aperta una eventuale selezione non qualificata per package target-independent è chiusa dal modello corrente: il package store usa sempre l'identità `<osarch>` del package/selector materializzato.

Questa decisione non introduce il vecchio token storico `any-any` né un'altra identità target-independent speciale.

---

## 6. Separatori e assenza di collisione con State Instance

Nel package store:

```text
@
    separa <pkg> da <version> nelle versioni concrete

!
    separa la parte package/versione da <osarch>
```

Lo state package usa invece il separatore già riservato:

```text
<pkg>@!<state-instance>
```

Le due grammatiche sono semanticamente distinte:

```text
pkg store concrete     <pkg>@<version>!<osarch>
pkg store current      <pkg>!<osarch>
state instance          <pkg>@!<state-instance>
```

Nel package store una versione concreta non può contenere `@` o `!`, quindi la sequenza `@!` non può essere prodotta accidentalmente come confine package/versione.

L'uso di `@` e `!` nei pathname del package store è un'eccezione semantica esplicita alla naming convention generica RumiAI, limitata alle forme fissate qui.

---

## 7. Relocability

Il selector:

```text
<pkg>!<osarch>
```

è sempre un symbolic link relativo.

Il target testuale normale è il basename della versione concreta nello stesso dominio `$m_ROOT/pkg/`:

```text
<pkg>@<version>!<osarch>
```

Nessun pathname assoluto della root RumiAI viene persistito nel selector.

---

## 8. Relazione con il launch path

Il normale binding pubblico continua a risolvere attraverso il selector current verso il command entry della versione concreta:

```text
bin/ext*/<pkg-command>
    -> $m_ROOT/pkg/<pkg>!<osarch>/cmd/<pkg-command>
        -> $m_ROOT/pkg/<pkg>@<version>!<osarch>/cmd/<pkg-command>
```

Le frecce descrivono la risoluzione semantica; i target testuali dei symlink devono restare relativi secondo il layout concreto.

`current` continua esclusivamente a selezionare la versione. Non costruisce environment, dependency o launch line.

---

## 9. Supersession mirata

Da `2026-09-05-package-manager-current-and-run-model.md` sono chiusi/superseded i punti che lasciavano aperti:

```text
pathname esatto della versione concreta
pathname esatto del selector current
grammatica con cui package name e osarch compaiono nel selector
possibile selector condiviso non qualificato per package target-independent
```

Restano validi:

```text
$m_ROOT/pkg/ come store locale
coesistenza di più versioni
current presente anche con una sola versione selezionata
current come symlink relativo
current seleziona una versione e non costruisce l'esecuzione
override per-invocation non modifica automaticamente current
```

I pathname storici del design 2026-08-30 restano superseded.

---

## 10. Implementazione e test

Alla data di questa decisione il layout non è ancora implementato da un comando `pkg` stabile in `rumiai-os` e non esistono test permanenti `pkg` in `rumiai-tests`.

Quando verrà implementato, i test dovranno proteggere almeno:

```text
creazione <pkg>@<version>!<osarch>
validazione del regex di <version>
versione upstream letterale current ammessa
selector <pkg>!<osarch> relativo
selector che punta alla versione concreta corretta
assenza di pseudo-versione current nel selector
assenza di @ e ! dentro <version>
coesistenza di più versioni concrete
relocatability del selector
```

---

## 11. Invarianti fissati

```text
PKG-PATH-01  una versione concreta usa $m_ROOT/pkg/<pkg>@<version>!<osarch>/
PKG-PATH-02  <version> usa esattamente [A-Za-z0-9][A-Za-z0-9._+~-]*
PKG-PATH-03  <version> è la versione upstream e non una versione di compatibilità dependency
PKG-PATH-04  la stringa upstream current è una <version> valida e non è riservata
PKG-PATH-05  il selector current usa $m_ROOT/pkg/<pkg>!<osarch>
PKG-PATH-06  <pkg>!<osarch> è un symlink relativo verso <pkg>@<version>!<osarch>
PKG-PATH-07  l'assenza di @<version> distingue strutturalmente il selector dalla versione concreta
PKG-PATH-08  package concreto e selector sono sempre qualificati da <osarch>
PKG-PATH-09  non viene introdotto alcun token target-independent speciale come any-any
PKG-PATH-10  @ separa pkg/version e ! separa package-version/osarch esclusivamente nel package store secondo questa grammatica
PKG-PATH-11  la grammatica del package store non modifica il separatore state @!
PKG-PATH-12  current resta il nome concettuale della selezione, non una pseudo-versione nel filesystem
```
