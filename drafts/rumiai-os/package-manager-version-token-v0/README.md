# RumiAI package manager — version token v0

Data: 2026-08-30

Stato: **design decision — canonical reversible version pathname encoding fissato**

Il Package Instance pathname usa:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

`version-token` rappresenta reversibilmente la upstream software version senza attribuirle semantica di ordinamento.

---

# 1. Obiettivi

Il token deve essere:

```text
canonical
reversible
filesystem-safe sulle reference platform
case-insensitive-safe
ASCII
senza `@`
facilmente validabile
leggibile per versioni comuni
```

Non deve richiedere al local package manager di comprendere SemVer, Java version syntax, Python version syntax o altra grammatica upstream.

---

# 2. Input

`identity.version` è una stringa upstream opaca UTF-8.

Nel system configuration format v0 non sono rappresentabili:

```text
NUL
TAB
CR
LF
```

quindi una upstream version che richieda questi caratteri non è ammissibile nel package schema v0.

Non viene applicata Unicode normalization alla software version: i byte UTF-8 rappresentano esattamente la stringa identity fornita dal producer.

---

# 3. Safe literal byte set

I byte ASCII seguenti possono essere copiati letteralmente nel token:

```text
a-z
0-9
.
_
-
+
```

Ogni altro byte viene percent-encoded.

In particolare vengono sempre encoded:

```text
A-Z
%
@
space
/
\\
:
*
?
"
<
>
|
ASCII controls
non-ASCII UTF-8 bytes
```

---

# 4. Percent encoding

Un byte non-safe viene rappresentato come:

```text
%hh
```

con esattamente due cifre hex **lowercase**:

```text
0-9a-f
```

Esempi byte:

```text
@  -> %40
%  -> %25
A  -> %41
space -> %20
```

Il token canonico non contiene uppercase ASCII.

---

# 5. Esempi

Versioni comuni restano leggibili:

```text
21.0.8+9      -> 21.0.8+9
8u462         -> 8u462
2.0-beta-3    -> 2.0-beta-3
1.0_rc1       -> 1.0_rc1
```

Case upstream viene preservato tramite encoding:

```text
1.0-RC1
    -> 1.0-%52%431
```

Spazio:

```text
1.0 beta
    -> 1.0%20beta
```

Reserved separator:

```text
1@2
    -> 1%402
```

Literal percent:

```text
100%
    -> 100%25
```

Unicode esempio:

```text
é
UTF-8 bytes c3 a9
    -> %c3%a9
```

---

# 6. Canonicality

Un token è canonico se e solo se:

```text
ogni literal byte appartiene al safe set
ogni `%` introduce esattamente due lowercase hex digit
nessun byte safe è percent-encoded
nessun uppercase literal compare
il decoded byte sequence è valid UTF-8
re-encoding del decoded value produce byte-per-byte lo stesso token
```

Quindi forme come:

```text
%2F
%2f quando `/` rappresenta byte 2f?  canonical sì per hex lowercase
%61 per `a`
```

sono gestite così:

```text
%2F    invalid: uppercase hex
%2f    canonical encoding di `/`
%61    invalid: `a` è safe e deve essere literal
```

---

# 7. Reversibility

Decoder:

```text
literal safe byte -> stesso byte
%hh              -> byte hex hh
```

Dopo decoding:

```text
byte sequence deve essere valid UTF-8
value deve rispettare SCF representability constraints
```

Il risultato è `identity.version` esatto.

---

# 8. Case-insensitive filesystem safety

Il token usa soltanto:

```text
lowercase ASCII safe literals
numeric characters
punctuation safe
lowercase hex escapes
```

Upstream case-sensitive differences vengono trasformate in byte sequence differenti:

```text
a  -> a
A  -> %41
```

Quindi non dipendono dalla case sensitivity del filesystem pathname.

---

# 9. Filesystem safety

Il token non può contenere letteralmente:

```text
/
\\
@
Windows reserved punctuation
ASCII control
space
%
uppercase ASCII
```

La Package Instance directory contiene inoltre name/revision/platform, quindi il version token non costituisce da solo l'intero pathname component.

La lunghezza finale resta soggetta ai limiti fisici validati sulle Reference Installation/filesystem.

Se l'encoding produce un Package Instance pathname non materializzabile sulla target reference platform/filesystem, il package non è ammissibile con quel pathname v0.

---

# 10. No version ordering semantics

Il token NON viene confrontato lessicograficamente per decidere release più nuova.

Selection usa:

```text
release-order
capability compatibility version
Selection Policy
RumiAI revision tie-break
```

secondo il resolver model.

---

# 11. Local validation

Il local package manager può validare:

```text
pathname split
version-token grammar/canonicality
@package identity.version
round-trip identity.version <-> version-token
```

La primitive byte-wise encode/decode può vivere nel bootstrap Rumi se la pura implementazione POSIX sh non è sufficientemente robusta/portabile per UTF-8 byte processing.

Non viene introdotta dipendenza da Base32, JSON o language-specific version parser.

---

# 12. Invarianti

```text
VT-01 version-token è canonical reversible encoding di identity.version UTF-8
VT-02 safe literal set = [a-z0-9._+-]
VT-03 ogni byte fuori dal safe set usa %hh lowercase
VT-04 `%` literal viene sempre encoded %25
VT-05 `@` viene sempre encoded %40
VT-06 uppercase ASCII upstream viene percent-encoded
VT-07 non-ASCII viene encoded per singolo UTF-8 byte
VT-08 safe byte non può essere percent-encoded in forma canonica
VT-09 decoded bytes devono essere valid UTF-8
VT-10 token non introduce upstream version ordering semantics
VT-11 full Package Instance pathname resta soggetto a Physical Platform Validation
```
