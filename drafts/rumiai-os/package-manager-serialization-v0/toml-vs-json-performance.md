# TOML vs JSON — parsing/query performance note

Data: 2026-08-30

Stato: **engineering note — micro-benchmark, non normative performance guarantee**

Scopo: stimare l'impatto della scelta `restricted TOML 1.0` rispetto a JSON per metadata package-manager RumiAI, con particolare attenzione agli inventory integrity grandi.

## Ambiente benchmark

```text
CPython 3.13.5
Linux x86_64
Linux 6.18.35
glibc 2.41
stdlib tomllib.loads
stdlib json.loads
```

Il confronto misura quindi **queste specifiche implementazioni**, non una proprietà intrinseca universale dei due formati. In CPython il parser JSON stdlib è particolarmente ottimizzato; altri runtime/parser possono produrre rapporti differenti.

## Rappresentazione testata

TOML usa il formato v0 corrente:

```toml
[integrity.root]
records = '''
<canonical line 1>
<canonical line 2>
...
'''
```

JSON rappresenta lo stesso manifest come una singola stringa JSON.

Entrambi includono inoltre metadata rappresentativi di identity, release, integrity e requirement.

Questa forma sostituisce la precedente idea di un array TOML con una stringa per ogni inventory record: il singolo blocco line-oriented riduce drasticamente l'overhead del parser TOML ed è più coerente con il manifest find-like fissato.

## Full parse

Valori indicativi migliori di 5 run; tempo per un singolo parse completo in memoria.

| Inventory records | TOML size | JSON size | TOML parse | JSON parse | rapporto TOML/JSON |
|---:|---:|---:|---:|---:|---:|
| 10 | 1.45 KiB | 1.48 KiB | 0.098 ms | 0.006 ms | 16.1x |
| 1,000 | 92.3 KiB | 96.2 KiB | 0.880 ms | 0.149 ms | 5.9x |
| 10,000 | 918.5 KiB | 957.6 KiB | 7.99 ms | 1.45 ms | 5.5x |
| 50,000 | 4.48 MiB | 4.67 MiB | 38.84 ms | 6.65 ms | 5.8x |

Conclusione: JSON è nettamente più veloce nel parsing completo con queste implementazioni, ma il costo assoluto TOML rimane nell'ordine di:

```text
~0.1 ms   descriptor piccolo
~0.9 ms   ~100 KiB
~8 ms     ~1 MiB
~39 ms    ~4.5 MiB
```

Gli inventory molto grandi non appartengono al critical launch parsing path: vengono letti principalmente per admission, integrity verification, repair/recovery e operazioni amministrative.

## Inventory line processing

Dopo il parse TOML, dividere la multiline `records` in righe costa indicativamente:

```text
1,000 records     ~0.08 ms
10,000 records    ~0.80 ms
50,000 records    ~4.0 ms
```

Il costo è indipendente dal formato sorgente una volta ottenuta la stringa manifest.

Un'implementazione può inoltre processare il blocco line-oriented senza costruire strutture ricche per ogni entry quando non necessario.

## Query dopo parsing

Sono state misurate tre lookup rappresentative sulla struttura già parsata:

```text
requirements[0].constraint
identity.name
integrity.root.manifest-digest
```

Risultato indicativo combinato:

```text
TOML-parsed object   ~155 ns
JSON-parsed object   ~153 ns
```

Differenza trascurabile/rumore di misura.

Motivo: dopo parsing entrambi sono normali strutture Python `dict`/`list`/scalar. Quindi la performance di query sul data model non dipende sostanzialmente dalla sintassi TOML o JSON che lo ha prodotto.

## Impatto architetturale

La scelta v0 resta TOML perché:

```text
human readability migliore per descriptor complessi
schema dichiarativo/typed
un solo formato per @package + desired/resolved state
nessun codice eseguibile
performance assoluta adeguata fuori dal critical path
query performance equivalente dopo parse
```

La performance viene protetta da queste regole:

```text
1. integrity records = singola multiline canonical string, non migliaia di TOML objects
2. launch usa active resolved generation; non verifica tutti gli inventory a ogni invocazione
3. parsed object/cache in-memory può essere derivata e ricostruibile
4. authoritative source resta TOML; eventuali future cache JSON/binary non diventano source of truth
5. optimization futura deve essere guidata da profiling reale
```

Se benchmark reali futuri mostrassero il parse TOML come collo di bottiglia, la prima risposta architetturale prevista è una **cache derivata** del parsed/validated model, non la sostituzione prematura del formato autorevole.

## Decisione

```text
AUTHORITATIVE FORMAT v0 = restricted TOML 1.0

JSON
    non scelto come formato autorevole
    resta tecnicamente valido come possibile rappresentazione/cache derivata futura

large integrity inventory
    canonical multiline line-oriented string
```
