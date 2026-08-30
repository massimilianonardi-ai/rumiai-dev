# TOML vs JSON — parsing/query performance note

Data: 2026-08-30

Stato: **engineering note — JSON selected; benchmark retained as rationale**

Questa nota conserva il confronto prestazionale eseguito prima della decisione finale.

Decisione normativa successiva:

```text
RumiAI structured data standard v0 = JSON UTF-8
package-manager metadata = JSON
integrity bulk inventory = separate canonical TSV
```

---

# 1. Risultato sintetico del micro-benchmark

Ambiente misurato:

```text
CPython 3.13.5
stdlib json.loads
stdlib tomllib.loads
Linux x86_64
```

Nel test eseguito JSON risultava sensibilmente più veloce nel full parsing.

Con inventory rappresentato come singolo bulk text invece che migliaia di stringhe strutturate, il costo TOML restava comunque modesto, ma JSON manteneva un vantaggio netto.

Ordini di grandezza osservati:

| Dimensione indicativa | TOML parse | JSON parse |
|---:|---:|---:|
| ~1.5 KB | ~0.098 ms | ~0.006 ms |
| ~92 KB | ~0.88 ms | ~0.15 ms |
| ~0.92 MB | ~7.99 ms | ~1.45 ms |
| ~4.48 MB | ~38.8 ms | ~6.65 ms |

Questi numeri dipendono dal parser/runtime e NON sono una performance guarantee universale dei formati.

---

# 2. Query dopo parsing

Una volta parsati, entrambi producevano normali object/list/dict equivalenti nel runtime del benchmark.

Lookup semplici risultavano sostanzialmente equivalenti:

```text
TOML parsed object ~155 ns
JSON parsed object ~153 ns
```

Conclusione:

```text
query performance after parse ≈ equivalent
main difference = parsing/deserialization
```

---

# 3. Ragioni finali per JSON

La decisione JSON non deriva soltanto dalla velocità.

JSON viene preferito perché RumiAI intende usarlo come formato strutturato standard e perché può essere letto/modificato con tool portabili e ampiamente disponibili:

```text
jq
Node.js
browser/JavaScript runtime
standard library di quasi ogni linguaggio
```

Questo evita di introdurre Python come dipendenza implicita del control plane RumiAI.

---

# 4. Integrity inventory separato

Il benchmark ha anche rafforzato una seconda decisione:

```text
non mettere decine di migliaia di inventory entry nel descriptor JSON
```

Gli inventory sono file TSV canonici separati:

```text
@integrity-root.tsv
@integrity-run-default.tsv
```

Questo permette:

```text
streaming
hash incrementale
awk/shell parsing
nessuna materializzazione JSON dell'intera lista file
bounded memory
```

Il normale launch non deve parsare né verificare integralmente questi inventory.

---

# 5. Performance consequence

Nel percorso normale:

```text
active pointer
→ resolved JSON
→ exact bindings
→ @package JSON dei package necessari
→ launch
```

Gli inventory TSV completi appartengono principalmente a:

```text
admission
integrity verification
repair/recovery
explicit package health check
```

Quindi il bulk file count non deve trasformarsi in un costo di parsing JSON per ogni launch.

---

# 6. Decisione

```text
JSON chosen
TOML rejected as reference metadata format
TSV chosen for integrity inventory bulk data
```

La nota rimane utile come evidenza tecnica della decisione, non come parte dello schema normativo.
