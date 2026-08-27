# Decisione — baseline POSIX e sintassi CLI

Data: 2026-08-27  
Status: **Accepted**

## Decisione

RumiAI OS adotta come standard POSIX di riferimento la revisione più recente concretamente utilizzabile sugli host di riferimento correnti.

Alla data della decisione:

```text
standard di riferimento: POSIX.1-2024 / Issue 8
host di riferimento:     Ubuntu 26.04 LTS + macOS Tahoe 26 stabile
```

Il portable core non assume automaticamente che ogni feature di Issue 8 sia già implementata integralmente da entrambi gli host. La baseline runtime effettiva è il **profilo comune verificato** delle feature necessarie a RumiAI OS.

Una feature recente dello standard può essere usata quando:

1. appartiene allo standard POSIX di riferimento;
2. la semantica necessaria è disponibile sui due host di riferimento;
3. viene verificata tramite documentazione e, per le parti critiche, tramite test runtime.

Se una feature non è ancora comune, deve essere esclusa dal portable core oppure coperta da fallback/adapter esplicito.

## Motivazione

RumiAI è un sistema orientato a workload IA recenti e hardware moderno. Non esiste un requisito progettuale di mantenere compatibilità artificiale con sistemi obsoleti quando ciò impedisce di usare primitive ormai standard e disponibili sugli OS moderni di riferimento.

La portabilità rimane definita dallo standard e dal profilo comune, non da estensioni GNU/Bash o peculiarità di un host.

## Sintassi CLI

I comandi RumiAI che supportano opzioni seguono per default le POSIX Utility Syntax Guidelines.

Il delimitatore:

```text
--
```

viene adottato, quando supportato, per chiudere il parsing delle opzioni e separare in modo non ambiguo opzioni e operandi/parametri.

Nel codice che invoca altre utility, `--` viene usato quando la utility lo supporta e l'uso protegge gli operandi da interpretazione come opzioni, soprattutto per valori che possono iniziare con `-`.

`--` non viene passato a utility che, per specifica o implementazione verificata, non lo supportano.

## Conseguenze

- il codice non deve essere limitato automaticamente a POSIX.1-2017 se una primitive Issue 8 necessaria è già comune agli host di riferimento;
- la compatibilità va testata sulla matrice reale, non dedotta soltanto dalla data dello standard;
- nuovi comandi RumiAI devono progettare il parsing degli argomenti in modo coerente e prevedibile;
- le eccezioni alle Utility Syntax Guidelines devono essere deliberate e documentate.
