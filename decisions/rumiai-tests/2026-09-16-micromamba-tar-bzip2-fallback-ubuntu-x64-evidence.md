# Evidence — Micromamba tar+bzip2 fallback su Ubuntu x64

Date: 2026-09-16  
Status: **Accepted / Physical validation negative — micromamba linux-x86_64 remains BLOCKED**

## 1. Scope

Questa evidence registra il primo run fisico Ubuntu x64 della remediation fissata da:

```text
decisions/rumiai-os/2026-09-16-extract-tar-bzip2-tar-fallback.md
```

Il work unit mantiene invariati:

```text
package      micromamba
artifact     archive tar.bz2 corrente
pkg-catalog  invariato
pkg_extract  API e structural normalization invariati
```

La remediation esercitata appartiene esclusivamente a `extract`.

Le evidence precedenti restano immutabili.

## 2. Revisioni esercitate

Il validation scope `package-release-micromamba` ha esercitato:

```text
rumiai-os     ea0a06f04b5f7429d31a22bebcf165496825ae5c
rumiai-tests  a52c50114ec8ba63528fb5413edb4c987edbd290
```

Il target era:

```text
linux-x86_64
```

sull'host Ubuntu x64 gia' usato per il package release gate.

## 3. Selection `rumiai-os/extract`

Sessione:

```text
20260916T102725+0200-1012126
```

Risultati:

```text
SKIP  rumiai-os/extract/bzip2-fallback.test
PASS  rumiai-os/extract/dispatch.test
PASS  rumiai-os/extract/real-targz.test
```

Lo `SKIP` non costituisce evidence negativa del contratto `extract`: il nuovo test permanente conteneva un errore di self-discovery della suite e tentava di caricare:

```text
.../src/lib/rumiai-os-target.lib
```

invece di:

```text
.../src/rumiai-tests/lib/rumiai-os-target.lib
```

La diagnostica pubblicata era:

```text
.: cannot open /m/src/git/rumiai-os/src/lib/rumiai-os-target.lib: No such file
```

Il difetto del test e' stato corretto forward-only in:

```text
rumiai-tests  8a6d1ee345ede7885c76c1db473b49d01ca0bf54
```

con la sola correzione del calcolo di `suite_root`. Il file resta executable `100755`.

Questa correzione non reinterpreta la sessione storica e non costituisce da sola physical validation della remediation prodotto.

## 4. Selection `pkg_extract`

Sessione:

```text
20260916T102728+0200-1012809
```

Risultato:

```text
PASS  rumiai-os/pkg-extract/contract.test
```

Questo conferma che il contratto corrente di `pkg_extract` resta integro sulla revisione esercitata; non dimostra da solo la riuscita del backend fisico tar+bzip2.

## 5. Infrastruttura package-release

Sessioni:

```text
20260916T102731+0200-1013090
20260916T102734+0200-1013477
```

Risultati:

```text
PASS  rumiai-tests/lib/package-release-reference.test
PASS  rumiai-tests/lib/package-release-wrapper-reference.test
```

L'infrastruttura condivisa del release gate risulta quindi esercitabile nella stessa validation unit.

## 6. Physical release-live micromamba

Sessione:

```text
20260916T102736+0200-1013650
```

Risultato:

```text
FAIL  external/micromamba/release-live.test
```

Il test ha raggiunto l'installazione reale di micromamba. Poiche' il comando host `bzip2` non era disponibile, `extract@ea0a06f...` ha selezionato il percorso fissato dalla decisione corrente:

```text
tar diretto sull'artifact tar.bz2
```

Il `tar` realmente presente sull'host non ha pero' materializzato autonomamente la compressione bzip2. Ha tentato di eseguire un helper esterno:

```text
lbzip2
```

che non era disponibile. La diagnostica fisica ha riportato:

```text
tar (child): lbzip2: funzione "exec" non riuscita: File o directory non esistente
tar: Child returned status 2
reason="extraction-failed"
format="tar.bz2"
```

La pipeline ha quindi correttamente terminato con failure:

```text
extract -> pkg-extract -> pkg-install
```

senza raggiungere `pkg-analyze`.

## 7. Interpretazione

Il run dimostra due proprietà distinte:

1. il ramo di fallback di `extract` viene realmente raggiunto quando `bzip2` non e' disponibile;
2. sul `tar` presente nell'host Ubuntu x64 esercitato, `tar -xf <artifact.tar.bz2>` dipende a sua volta da un decompressor bzip2-compatible esterno e non soddisfa autonomamente la capability richiesta.

Questo esito e' previsto dal limite gia' esplicitato nella decisione `2026-09-16-extract-tar-bzip2-tar-fallback.md`: la disponibilita' del comando `tar` non implica che il backend fisico possa decomprimere bzip2 senza helper esterni.

Non viene introdotto automaticamente alcun backend differente (`7z`, Python, BusyBox o altro), perche' cio' modificherebbe il backend-selection contract fissato dalla decisione corrente.

Non viene modificato l'artifact micromamba e non viene modificato `pkg-catalog`.

## 8. Stato

Lo scope complessivo ha prodotto:

```text
NOT VALIDATED
```

Lo stato release resta:

```text
micromamba/linux-x86_64  BLOCKED
```

Il precedente blocker generico "comando bzip2 assente" e' ora raffinato dall'evidence fisica:

```text
il fallback direct-tar viene selezionato,
ma il GNU tar dell'host richiede comunque un helper bzip2-compatible esterno (lbzip2)
```

Finche' il contratto resta `bzip2 assente -> tar diretto`, questa revisione non puo' essere dichiarata positiva su questo host.

Una eventuale estensione della selezione backend o una diversa definizione della capability richiede una correzione esplicita della decisione prima dell'implementazione; non viene introdotta da questa evidence.

## 9. Invarianti dell'evidence

```text
MICROMAMBA-BZ2-X64-01  artifact micromamba tar.bz2 invariato
MICROMAMBA-BZ2-X64-02  target esercitato = linux-x86_64
MICROMAMBA-BZ2-X64-03  rumiai-os esercitato = ea0a06f04b5f7429d31a22bebcf165496825ae5c
MICROMAMBA-BZ2-X64-04  assenza bzip2 seleziona realmente il ramo tar diretto
MICROMAMBA-BZ2-X64-05  il tar fisico esercitato tenta lbzip2 e fallisce quando tale helper e' assente
MICROMAMBA-BZ2-X64-06  pkg install non completa e pkg-analyze non viene raggiunto
MICROMAMBA-BZ2-X64-07  micromamba/linux-x86_64 resta BLOCKED
MICROMAMBA-BZ2-X64-08  lo SKIP di bzip2-fallback.test era un difetto di self-discovery del test, corretto forward-only in rumiai-tests@8a6d1ee345ede7885c76c1db473b49d01ca0bf54
MICROMAMBA-BZ2-X64-09  le sessioni storiche non vengono reinterpretate
MICROMAMBA-BZ2-X64-10  nessun backend alternativo viene introdotto implicitamente
MICROMAMBA-BZ2-X64-11  pkg-catalog resta invariato
MICROMAMBA-BZ2-X64-12  Git resta forward-only
```
