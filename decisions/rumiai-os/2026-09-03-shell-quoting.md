# Decisione — Quoting difensivo nel codice shell

Date: 2026-09-03  
Status: **Accepted**

## Regola

Nel codice `sh` di RumiAI si devono usare le doppie virgolette `"..."` intorno a variabili, espansioni e valori ogni volta che la sintassi e la semantica lo consentono senza alterare intenzionalmente il comportamento.

La regola vale anche quando:

- il valore è costante;
- il contenuto della variabile è già noto;
- il contenuto è considerato sicuro;
- word splitting o pathname expansion non produrrebbero oggi effetti osservabili.

La protezione deve quindi dipendere dalla forma del codice, non da assunzioni sul contenuto corrente dei dati.

Esempi:

```sh
value="fixed"
path="$m_ROOT/lib"
result="$(command -p -- uname -s)"
[ "$value" = "fixed" ]
case "$value" in
  "fixed") : ;;
esac
```

## Eccezioni

Le virgolette non devono essere aggiunte quando disattiverebbero semantica shell intenzionale o quando l'elemento è sintassi e non un valore. Esempi: metacaratteri attivi nei pattern di `case`, keyword, operatori, redirection e nomi sintattici di variabili passati a `export`/`readonly`.

Quando una parte letterale di un pattern può essere quotata senza disattivare il wildcard richiesto, si preferisce quotare la parte letterale:

```sh
case "$value" in
  "MINGW"*) : ;;
esac
```

## Propagazione

La regola si applica al nuovo codice e al codice modificato. Non richiede una riformattazione indiscriminata di sottosistemi non coinvolti, ma ogni porzione toccata deve essere portata alla forma corrente quando possibile e senza cambiamenti semantici.

Il bootstrap root `rumiai-os` è il riferimento stilistico principale per questa disciplina. L'esistenza di eventuali residui preesistenti ulteriormente quotabili non costituisce eccezione alla regola e tali residui possono essere riallineati quando vengono toccati o in un intervento dedicato.
