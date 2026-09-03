# Decisione — Disciplina delle doppie virgolette in shell

Date: 2026-09-03  
Status: **Accepted**

## Contesto

Il codice shell di RumiAI deve privilegiare una forma difensiva uniforme anche quando il valore corrente di una variabile è già noto, controllato o apparentemente sicuro.

L'obiettivo è evitare che la correttezza di una riga dipenda incidentalmente dal contenuto attuale di una variabile e rendere visibile nel sorgente che espansioni e valori sono trattati come singoli argomenti/dati quando questa è la semantica desiderata.

## Regola

Nel codice `sh` di RumiAI si usano le doppie virgolette `"..."` ogni volta che la sintassi e la semantica dell'operazione lo consentono senza alterare intenzionalmente il comportamento.

La regola vale in particolare per:

- espansioni di parametri e variabili;
- command substitution usata come valore;
- valori assegnati, inclusi valori costanti;
- operandi passati a comandi;
- confronti e test;
- parole esaminate da `case`;
- concatenazioni di pathname e stringhe.

Esempi canonici:

```sh
value="fixed"
path="$m_ROOT/lib"
result="$(command ...)"
[ "$value" = "fixed" ]
case "$value" in
  "fixed") ... ;;
esac
command -- "$path"
```

La conoscenza preventiva del contenuto di una variabile non è una ragione sufficiente per omettere le doppie virgolette.

## Eccezioni semantiche

Le doppie virgolette non devono essere introdotte quando cambierebbero la semantica richiesta o quando l'elemento non è un valore da quotare ma sintassi shell.

Esempi includono:

- pattern di `case` per le porzioni che devono mantenere metacaratteri attivi, come `*`;
- nomi di variabili usati come nomi sintattici da `export`, `readonly` o primitive equivalenti;
- operatori, keyword, redirection e altra sintassi shell;
- casi in cui word splitting o pathname expansion siano intenzionalmente richiesti e documentati.

Quando una parte letterale di un pattern può essere quotata senza disattivare il metacarattere necessario, si preferisce comunque quotarla, per esempio:

```sh
case "$value" in
  "MINGW"*) ... ;;
esac
```

## Ambito

La regola si applica al nuovo codice shell e al codice shell modificato. Un intervento non deve trasformarsi automaticamente in una riformattazione indiscriminata di file o sottosistemi non coinvolti; le porzioni toccate devono però essere portate alla forma corrente quando ciò è proporzionato e non altera il comportamento.

Il bootstrap root `rumiai-os` costituisce il riferimento stilistico principale per l'uso difensivo delle doppie virgolette già presente nel bootstrap. Eventuali residui preesistenti che possono essere ulteriormente quotati senza variazione semantica non autorizzano a indebolire questa regola e possono essere riallineati in un intervento dedicato o quando quelle righe vengono modificate.
