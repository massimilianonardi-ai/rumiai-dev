# Decisione — Pathname delle versioni concrete e selector `current`

Date: 2026-09-07  
Updated: 2026-09-07  
Status: **Accepted**

## Contesto

Le decisioni correnti hanno già fissato:

- `$m_ROOT/pkg/` come dominio locale dei package gestiti;
- coesistenza di più versioni concrete dello stesso package;
- `current` come concetto di selezione persistente della versione predefinita;
- selector rappresentato da symbolic link relativo;
- `<osarch>` canonico nella forma `<platform>-<architecture>`;
- `bin/ext/` per binding third-party platform-independent e `bin/ext-<osarch>/` per binding specifici del target;
- `current` seleziona una versione ma non costruisce l'esecuzione.

La prima versione di questa decisione aveva imposto `<osarch>` a ogni versione concreta e selector, anche quando il package materializzato era realmente platform-independent.

La correzione esplicita del 2026-09-07 riallinea il package store alla stessa distinzione semantica già presente nel runtime `bin/ext*`: i package realmente platform-independent usano identità non qualificate, mentre quelli target-specific usano `!<osarch>`.

Questa unità modifica soltanto `rumiai-dev`. Non autorizza modifiche a `rumiai-os` o `rumiai-tests`.

---

## 1. Due forme di concrete package identity

Una versione concreta platform-independent usa:

```text
$m_ROOT/pkg/<pkg>@<version>/
```

Una versione concreta specifica di un target usa:

```text
$m_ROOT/pkg/<pkg>@<version>!<osarch>/
```

Esempi:

```text
$m_ROOT/pkg/my-tool@1.2/
$m_ROOT/pkg/java@21.0.2+13!macos-arm64/
```

Componenti semantiche:

```text
<pkg>      identità canonica del package
<version>  versione upstream della release installata
<osarch>   target RumiAI canonico, presente solo per package target-specific
```

Non viene introdotto un token `any`, `any-any` o equivalente per rappresentare l'indipendenza dal target.

La target-independence appartiene strutturalmente all'assenza di `!<osarch>`.

---

## 2. Versione upstream

`<version>` preserva direttamente la versione upstream entro il dominio:

```text
[A-Za-z0-9][A-Za-z0-9._+~-]*
```

Sono quindi ammessi, per esempio:

```text
1
1.2.3
v1.2.3
1.2.3-rc.1
21.0.2+13
2.0~beta1
2026-Q1
v01-Kidding-Penguin
current
```

Non sono ammessi nella singola componente `<version>`:

```text
@
!
=
/
whitespace
control characters
```

`=` non apparteneva già alla grammatica della versione upstream ed è ora usato separatamente soltanto come delimitatore nelle directory range del package-definition catalog secondo `2026-09-07-package-definition-catalog-and-version-ranges.md`.

La versione upstream non viene interpretata come compatibility version dependency e non implica un comparatore universale delle release software.

La stringa `current` non è riservata come versione upstream perché il selector corrente non usa una pseudo-versione testuale `current`.

---

## 3. Due forme di selector `current`

Per un package platform-independent il selector persistente è:

```text
$m_ROOT/pkg/<pkg>
```

ed è un symlink relativo verso:

```text
<pkg>@<version>
```

Esempio:

```text
$m_ROOT/pkg/my-tool
    -> my-tool@1.2
```

Per un package target-specific il selector persistente è:

```text
$m_ROOT/pkg/<pkg>!<osarch>
```

ed è un symlink relativo verso:

```text
<pkg>@<version>!<osarch>
```

Esempio:

```text
$m_ROOT/pkg/java!macos-arm64
    -> java@21.0.2+13!macos-arm64
```

`current` resta il nome concettuale della responsabilità del selector, non una componente letterale del pathname.

---

## 4. Discriminante strutturale

Le quattro forme sono:

```text
<pkg>@<version>
    versione concreta platform-independent

<pkg>
    selector current platform-independent

<pkg>@<version>!<osarch>
    versione concreta target-specific

<pkg>!<osarch>
    selector current target-specific
```

L'assenza di `@<version>` distingue un selector dalla corrispondente versione concreta.

L'assenza di `!<osarch>` distingue una identity realmente platform-independent da una target-specific.

Non viene introdotto alcun sentinel artificiale.

---

## 5. Ruolo di `<osarch>` e rapporto con il catalogo

`<osarch>` usa il vocabulary RumiAI già fissato:

```text
<platform>-<architecture>
```

con i token correnti definiti da `2026-09-03-lang-and-osarch-utilities.md`.

La decisione `2026-09-07-package-definition-catalog-and-version-ranges.md` determina la qualificazione della concrete identity:

```text
package definition selezionata da <pkg>/catalog
    -> concrete identity non qualificata
    -> selector non qualificato

package definition selezionata da <pkg>/catalog-<osarch>
    -> concrete identity qualificata da !<osarch>
    -> selector qualificato da !<osarch>
```

Un operand CLI può specificare un target per scegliere lo stream da usare senza obbligare il package risultante a essere target-specific: se manca `catalog-<osarch>` e viene selezionato il `catalog` realmente platform-independent, l'identity resta non qualificata.

La target-independence riguarda l'intero package materializzato, non soltanto i byte upstream. Se la materializzazione incorpora dependency binding o altri elementi specifici del target, deve usare una identity qualificata.

---

## 6. Separatori e State Instance

Nel package store:

```text
@
    separa <pkg> da <version> nelle versioni concrete

!
    introduce <osarch> solo nelle forme target-specific
```

Lo state package usa invece il separatore già riservato:

```text
<pkg>@!<state-instance>
```

Le grammatiche restano semanticamente distinte:

```text
pkg concrete generic    <pkg>@<version>
pkg current generic     <pkg>
pkg concrete target     <pkg>@<version>!<osarch>
pkg current target      <pkg>!<osarch>
state instance           <pkg>@!<state-instance>
```

La versione concreta non può contenere `@` o `!`, quindi `@!` non può essere prodotto accidentalmente come confine package/versione.

L'uso di `@` e `!` nei pathname package-manager resta una eccezione semantica limitata alle forme qui fissate.

---

## 7. Relocability

Entrambe le forme di selector sono sempre symbolic link relativi.

Target normali:

```text
<pkg>
    -> <pkg>@<version>

<pkg>!<osarch>
    -> <pkg>@<version>!<osarch>
```

Nessun pathname assoluto della root RumiAI viene persistito nei selector.

---

## 8. Relazione con i binding pubblici

Per un package platform-independent, il normale binding pubblico appartiene a:

```text
bin/ext/<pkg-command>
```

e risolve semanticamente attraverso:

```text
$m_ROOT/pkg/<pkg>/cmd/<pkg-command>
    -> $m_ROOT/pkg/<pkg>@<version>/cmd/<pkg-command>
```

Per un package target-specific, il binding appartiene a:

```text
bin/ext-<osarch>/<pkg-command>
```

e risolve semanticamente attraverso:

```text
$m_ROOT/pkg/<pkg>!<osarch>/cmd/<pkg-command>
    -> $m_ROOT/pkg/<pkg>@<version>!<osarch>/cmd/<pkg-command>
```

Le frecce descrivono la risoluzione semantica; i target testuali dei symlink devono restare relativi secondo il layout concreto.

L'ordine runtime già fissato fra `bin/ext-<osarch>` e `bin/ext` continua a governare eventuali nomi pubblici coincidenti.

`current` continua esclusivamente a selezionare la versione. Non costruisce environment, dependency o launch line.

---

## 9. Coesistenza

La stessa root può contenere contemporaneamente:

```text
foo@1.2
foo -> foo@1.2

foo@2.0!linux-arm64
foo!linux-arm64 -> foo@2.0!linux-arm64

foo@2.1!macos-arm64
foo!macos-arm64 -> foo@2.1!macos-arm64
```

solo quando tali concrete package identity derivano da package definition realmente distinte e coerenti con i rispettivi stream.

La presenza di una forma generica non elimina la possibilità di forme target-specific per target che dispongono di `catalog-<osarch>`.

---

## 10. Supersession mirata

La prima versione di questa decisione del 2026-09-07 è superseded nei punti che imponevano:

```text
<pkg>@<version>!<osarch> come unica concrete identity
<pkg>!<osarch> come unico selector
qualificazione <osarch> obbligatoria anche per package target-independent
esclusione della selezione condivisa non qualificata per package target-independent
```

Tale correzione riapre e chiude in senso affermativo il punto che `2026-09-05-package-manager-current-and-run-model.md` aveva lasciato aperto: un package realmente target-independent può condividere una selezione non qualificata.

Restano validi:

```text
$m_ROOT/pkg/ come store locale
coesistenza di più versioni
current presente anche con una sola versione selezionata
current come symlink relativo
current seleziona una versione e non costruisce l'esecuzione
override per-invocation non modifica automaticamente current
versione upstream separata dalla compatibility dependency
```

I pathname storici del design 2026-08-30 restano superseded.

---

## 11. Implementazione e test

Alla data di questa decisione il layout non è ancora implementato da un comando `pkg` stabile in `rumiai-os` e non esistono test permanenti `pkg` in `rumiai-tests`.

Quando verrà implementato, i test dovranno proteggere almeno:

```text
creazione <pkg>@<version> per catalog platform-independent
creazione <pkg>@<version>!<osarch> per catalog target-specific
validazione del regex di <version>
versione upstream letterale current ammessa
selector <pkg> relativo verso <pkg>@<version>
selector <pkg>!<osarch> relativo verso <pkg>@<version>!<osarch>
assenza di any/any-any
coesistenza di versioni generic e target-specific quando prevista dal catalogo
relocatability di entrambe le forme di selector
binding generic sotto bin/ext e target-specific sotto bin/ext-<osarch>
```

Questa correzione è documentale e non dichiara physical validation del futuro `pkg`.

---

## 12. Invarianti fissati

```text
PKG-PATH-01  concrete identity = <pkg>@<version> per package platform-independent oppure <pkg>@<version>!<osarch> per package target-specific
PKG-PATH-02  <version> usa esattamente [A-Za-z0-9][A-Za-z0-9._+~-]*
PKG-PATH-03  <version> è la versione upstream e non una compatibility dependency
PKG-PATH-04  la stringa upstream current è una <version> valida e non è riservata
PKG-PATH-05  selector current = <pkg> per package platform-independent oppure <pkg>!<osarch> per package target-specific
PKG-PATH-06  ogni selector è un symlink relativo verso la concrete identity della stessa classe generic/target-specific
PKG-PATH-07  l'assenza di @<version> distingue strutturalmente selector e versione concreta
PKG-PATH-08  l'assenza di !<osarch> identifica una concrete identity/selector platform-independent; la presenza identifica un target-specific
PKG-PATH-09  non viene introdotto alcun token target-independent speciale come any o any-any
PKG-PATH-10  @ separa pkg/version e ! introduce osarch esclusivamente nelle forme package target-specific fissate qui
PKG-PATH-11  la grammatica package-store non modifica il separatore state @!
PKG-PATH-12  current resta il nome concettuale della selezione, non una pseudo-versione nel filesystem
PKG-PATH-13  catalog produce forme non qualificate; catalog-<osarch> produce forme qualificate
PKG-PATH-14  target-independence riguarda l'intero package materializzato, inclusi i resolved binding
PKG-PATH-15  binding pubblico generic appartiene a bin/ext; binding target-specific appartiene a bin/ext-<osarch>
```
