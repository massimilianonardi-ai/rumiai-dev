# Decisione — Piano package corrente dopo l'errore test K1 su macOS

Date: 2026-09-11  
Status: **Accepted**

## Scopo e supersession

Questo documento supersede, esclusivamente per stato operativo e sequencing corrente:

```text
decisions/rumiai-os/2026-09-11-package-current-plan-after-facility-provider-implementation.md
```

I contratti tecnici precedenti restano autorevoli nei rispettivi scope.

---

## Evidenze K1b ricevute

La validation richiesta per K1 è stata eseguita sulla coppia:

```text
rumiai-os@bd167bbaa509dbbcb8b803152e22db3895c01a5d
rumiai-tests@4c018f7c577ba6c7d9f68f94ee55366334f15742
selection: rumiai-os/pkg
```

Sono state pubblicate le evidence:

```text
Ubuntu ARM64  validation/20260911T092519+0200-117158
macOS ARM64   validation/20260911T092532+0200-20189
```

### Ubuntu ARM64

La sessione Ubuntu 26.04.1 LTS ARM64 ha prodotto:

```text
PASS 6/6
runner exit status 0
```

per:

```text
catalog-snapshot.test
default.test
facility.test
install.test
uninstall.test
versions.test
```

### macOS ARM64

La sessione macOS ARM64 ha prodotto:

```text
PASS 5/6
ERROR facility.test
runner exit status 2
```

Il log del test fallito è:

```text
chmod: --: No such file or directory
rumiai-os/pkg/facility.test: cannot mark facility executable
```

L'errore avviene nel setup interno del permanent test prima della verifica interessata e non costituisce un failure osservato di `rumiai-os`.

La causa è l'uso nel test di:

```sh
command -p -- chmod +x -- "$bad_range/facility"
```

Su macOS il `chmod` corrente non interpreta `--` come option delimiter e lo tratta come pathname. Questo viola la regola RumiAI secondo cui `--` è obbligatorio soltanto per i tool che lo supportano con quella semantica e non deve essere forzato sugli altri tool.

---

## Correzione permanente

Il permanent test è stato corretto in:

```text
rumiai-tests@fa2583d85121001d642f1f733f037c3f117ca4e5
```

La sola modifica rispetto a `4c018f7...` è:

```diff
-command -p -- chmod +x -- "$bad_range/facility"
+command -p -- chmod +x "$bad_range/facility"
```

Non è stato modificato `rumiai-os`.

La revisione prodotto K1 resta quindi:

```text
rumiai-os@bd167bbaa509dbbcb8b803152e22db3895c01a5d
```

La configurazione validation continua a selezionare:

```text
rumiai-os/pkg
```

e continua a pinning alla stessa revisione prodotto.

---

## Disciplina delle evidence

Le due evidence già pubblicate restano immutabili e revision-specific.

In particolare:

```text
validation/20260911T092519+0200-117158
    = PASS Ubuntu per rumiai-tests@4c018f7...

validation/20260911T092532+0200-20189
    = ERROR macOS per rumiai-tests@4c018f7...
```

L'evidence macOS non viene reinterpretata come product failure e non viene modificata retroattivamente.

L'evidence Ubuntu resta valida per la coppia che ha realmente eseguito, ma non può da sola chiudere K1b dopo la correzione del permanent test, perché la suite corrente è ora una revisione differente.

Per chiudere K1b entrambi i reference host devono quindi eseguire la stessa suite corrente:

```text
rumiai-os@bd167bbaa509dbbcb8b803152e22db3895c01a5d
rumiai-tests@fa2583d85121001d642f1f733f037c3f117ca4e5
selection: rumiai-os/pkg
```

---

## Sequenza operativa corrente

```text
J1   pkg uninstall: contract/test/implementation                  [completed]
J2   physical validation pkg uninstall                            [completed]
J3a  pkg versions/default naming + public contract                [completed]
J3b  permanent test + implementation                              [completed]
J3c  physical validation versions/default + pkg regression       [completed]
K0   facility/dependency serialization + resolution policy        [completed]
K1a  facility provider lifecycle implementation + permanent test  [completed]
K1b  physical validation facility + pkg regression                [current: rerun required]
K2   dependency resolution + resolved binding                     [not started]
```

K2 non parte finché K1b non è chiuso.

---

## Invarianti correnti

```text
PKG-NOW-120  rumiai-os K1 resta bd167bbaa509dbbcb8b803152e22db3895c01a5d
PKG-NOW-121  Ubuntu evidence 20260911T092519+0200-117158 è PASS 6/6 sulla suite 4c018f7
PKG-NOW-122  macOS evidence 20260911T092532+0200-20189 è ERROR nel test harness, non product FAIL
PKG-NOW-123  la causa macOS è l'uso non portabile di -- con chmod nel permanent test
PKG-NOW-124  la correzione test-only è rumiai-tests@fa2583d85121001d642f1f733f037c3f117ca4e5
PKG-NOW-125  la correzione non modifica il contratto K1 né rumiai-os
PKG-NOW-126  le evidence precedenti restano immutabili e revision-specific
PKG-NOW-127  K1b richiede nuova validation su entrambi i reference host con la suite fa2583d
PKG-NOW-128  selection resta rumiai-os/pkg e il product pin resta bd167b
PKG-NOW-129  K2 resta non iniziato finché K1b non è chiuso
PKG-NOW-130  Git resta forward-only
```
