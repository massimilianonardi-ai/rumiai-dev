# Decisione — Namespace state dei componenti del sistema base RumiAI

Date: 2026-09-06  
Status: **Accepted**  
Updated: 2026-09-06

## Contesto

Le decisioni correnti hanno gia fissato:

- le root semantiche RumiAI `conf`, `data`, `home`, `cache`, `log`, `run`, `tmp`;
- i componenti del sistema base RumiAI come componenti non gestiti e non rimovibili tramite `pkg`;
- `pkg` come meccanismo di espansione del sistema base tramite package aggiuntivi;
- lo state normale dei package sotto `$m_ROOT/<area>/<pkg>/`;
- le State Instance nominate sotto `$m_ROOT/<area>/<pkg>@!<state-instance>/`;
- `@!` come separatore strutturale riservato esclusivamente fra package e State Instance;
- `sys` come termine gia usato dal runtime per gli executable/binding propri di RumiAI (`bin/sys*`), distinto dai binding third-party `bin/ext*`.

Finora i componenti base potevano usare direttamente una root semantica, per esempio `$m_ROOT/conf/shell/`. Questo lascia pero nello stesso namespace fisico i componenti del sistema base e i package di espansione.

Questa decisione introduce un namespace esplicito e uniforme per lo state/configurazione dei componenti del sistema base.

Il primo riallineamento prodotto di questo namespace è stato effettuato per il componente `shell` in:

```text
massimilianonardi-ai/rumiai-os@90a68a7c5e8c80e36bad12035c39b6d3e8d75b56
```

Il commit sposta la configurazione shell da `conf/shell/` a `conf/sys/shell/` senza modificare la semantica degli adapter.

---

## 1. Forma canonica

Per ogni state area canonica, un componente `<component>` del sistema base usa:

```text
$m_ROOT/<area>/sys/<component>/
```

Esempi:

```text
$m_ROOT/conf/sys/shell/
$m_ROOT/data/sys/<component>/
$m_ROOT/cache/sys/<component>/
$m_ROOT/log/sys/<component>/
$m_ROOT/run/sys/<component>/
$m_ROOT/tmp/sys/<component>/
```

`home` segue la stessa regola quando un componente base necessita realmente della relativa area:

```text
$m_ROOT/home/sys/<component>/
```

Non tutte le aree devono esistere per ogni componente.

---

## 2. `sys` e namespace riservato del sistema base

Sotto ciascuna root semantica:

```text
$m_ROOT/<area>/
```

la prima entry:

```text
sys/
```

ha significato riservato: contiene esclusivamente state/configurazione appartenente ai componenti del sistema base RumiAI.

Questa scelta riusa il termine `sys` gia fissato dal runtime per distinguere elementi propri di RumiAI da elementi third-party, senza introdurre un nuovo namespace arbitrario.

Il significato e coerente ma il dominio e distinto:

```text
bin/sys*                 executable/binding propri di RumiAI
$m_ROOT/<area>/sys/*     state/configurazione dei componenti base RumiAI
```

---

## 3. Separazione dal namespace dei package

I package di espansione continuano a usare:

```text
$m_ROOT/<area>/<pkg>/
```

per lo state standard e:

```text
$m_ROOT/<area>/<pkg>@!<state-instance>/
```

per una State Instance nominata.

Di conseguenza, sotto una root semantica la struttura concettuale e:

```text
$m_ROOT/<area>/
├── sys/
│   ├── <component>/
│   └── ...
├── <pkg>/
├── <pkg>@!<state-instance>/
└── ...
```

`sys` e riservato come primo componente del namespace state e non puo essere interpretato come normale `<pkg>` in quella posizione.

Questa riserva risolve la collisione precedentemente aperta fra nomi di componenti base e nomi package: i componenti base sono sempre sotto `sys/`, mentre i package restano direttamente sotto la root semantica.

La policy generale dei nomi package al di fuori di questo vincolo non viene ampliata da questa decisione.

---

## 4. Nessun uso di `@!sys`

Non viene usata alcuna forma come:

```text
$m_ROOT/<area>/@!sys/<component>/
```

La sequenza `@!` resta riservata esclusivamente alla composizione:

```text
<pkg>@!<state-instance>
```

secondo `specifications/rumiai-os/FILESYSTEM-NAMING.md` e la decisione package-state corrente.

`sys` e un normale pathname component conforme alle regole generali di naming e non richiede eccezioni sintattiche.

---

## 5. Relazione con `pkg`

I componenti sotto:

```text
$m_ROOT/<area>/sys/<component>/
```

restano componenti del sistema base:

- non sono package gestiti da `pkg`;
- non sono rimovibili tramite `pkg`;
- non acquisiscono una Package State Instance;
- non richiedono package virtuali.

`pkg` continua a gestire esclusivamente le espansioni del sistema base.

Questa decisione non introduce un meccanismo di installazione/upgrade dei componenti base e non estende `pkg` al loro lifecycle.

---

## 6. Esempio `shell`

Il pathname canonico della configurazione RumiAI del componente base `shell` e:

```text
$m_ROOT/conf/sys/shell/
```

Quindi, per esempio, gli adapter POSIX del componente `shell` appartengono semanticamente al sottalbero:

```text
$m_ROOT/conf/sys/shell/sh/
```

Il prodotto corrente implementa questa collocazione fisica a partire da:

```text
massimilianonardi-ai/rumiai-os@90a68a7c5e8c80e36bad12035c39b6d3e8d75b56
```

Il precedente pathname `$m_ROOT/conf/shell/` resta esclusivamente riferimento storico alle revisioni precedenti.

---

## 7. Supersession mirata

Questa decisione supersede esclusivamente, nei documenti Accepted precedenti, le affermazioni incompatibili relative alla collocazione diretta dei componenti base sotto `$m_ROOT/<area>/` e l'open item relativo alla collisione fra componenti base e package nelle root semantiche.

In particolare:

- in `2026-09-05-package-state-var-default.md`, il precedente esempio `$m_ROOT/conf/shell/` e sostituito semanticamente da `$m_ROOT/conf/sys/shell/`, e la collisione fra componenti base e package non e piu un open item;
- in `2026-09-05-package-manager-current-and-run-model.md`, la stessa regola aggiorna il modello del sistema base e chiude il relativo open item;
- in `2026-09-05-interactive-shell-startup.md`, ogni riferimento strutturale a `conf/shell/...` deve essere interpretato come `conf/sys/shell/...` per il layout canonico corrente.

Le parti comportamentali di tali decisioni restano valide salvo quanto esplicitamente modificato qui.

---

## 8. Implementazione e test

Il primo riallineamento prodotto osservabile di questa decisione e:

```text
massimilianonardi-ai/rumiai-os@90a68a7c5e8c80e36bad12035c39b6d3e8d75b56
```

Per il componente `shell`, `conf/` contiene ora il namespace `sys/` e gli adapter vivono sotto `conf/sys/shell/`; i riferimenti corrispondenti in `lib/sh/core.lib.sh` usano lo stesso pathname canonico.

La suite permanente corrente che protegge il contratto shell, inclusa l'aspettativa fisica dell'adapter POSIX, e:

```text
massimilianonardi-ai/rumiai-tests@c39b1a2c0b6e96e8e43809a6e66d16918cf90a7d
```

Questo riallineamento di prodotto e test **non costituisce validazione fisica** di `rumiai-os@90a68a7c...`. Le evidenze fisiche precedenti restano riferite alle revisioni e ai pathname effettivamente validati all'epoca.

---

## 9. Invarianti fissati

```text
SYS-STATE-01  i componenti del sistema base usano $m_ROOT/<area>/sys/<component>/ nelle state area che necessitano
SYS-STATE-02  sys/ e riservato come primo componente sotto ciascuna root semantica per il sistema base RumiAI
SYS-STATE-03  sys non e interpretato come normale <pkg> nel namespace state
SYS-STATE-04  i package continuano a usare $m_ROOT/<area>/<pkg>/ e $m_ROOT/<area>/<pkg>@!<state-instance>/
SYS-STATE-05  @! resta riservato esclusivamente al separatore package/State Instance e non viene usato per il namespace system
SYS-STATE-06  i componenti sotto sys/ non sono package, non sono rimovibili tramite pkg e non richiedono package virtuali
SYS-STATE-07  la configurazione canonica del componente base shell vive sotto $m_ROOT/conf/sys/shell/
SYS-STATE-08  SYS-STATE-07 e implementato nel prodotto a partire da rumiai-os@90a68a7c5e8c80e36bad12035c39b6d3e8d75b56
```
