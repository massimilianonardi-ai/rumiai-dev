# Decisione — Tie-break della successione GitHub Releases

Date: 2026-09-08  
Status: **Accepted**

## Contesto

Il contratto corrente del repository adapter GitHub stabilisce che `pkg_repository_list_versions` restituisce la successione completa delle full release installabili in ordine:

```text
oldest -> latest
```

senza interpretare semanticamente le version string. Il primo criterio fissato era `created_at`, con fallimento quando due release installabili esponevano lo stesso valore e non esisteva un ulteriore ordine autorevole.

La physical validation sul repository reale `dbeaver/dbeaver` ha mostrato un caso concreto incompatibile con l'ipotesi di unicità di `created_at`:

```text
5.2.0  created_at=2018-09-12T14:27:35Z
5.2.1  created_at=2018-09-12T14:27:35Z
```

Le due release espongono però `published_at` distinti e coerenti con la loro successione di pubblicazione.

L'utente ha approvato esplicitamente l'uso di `published_at` come tie-break repository-native quando `created_at` coincide.

---

## 1. Ordine canonico delle full release GitHub

Per `pkg_repository_list_versions`, l'adapter GitHub ordina le full release installabili usando esattamente la chiave composta:

```text
1. created_at
2. published_at
```

entrambi in ordine temporale crescente.

`created_at` resta il criterio primario.

`published_at` viene consultato esclusivamente per distinguere release con lo stesso `created_at`.

Poiché i valori GitHub usati dal contratto corrente sono timestamp UTC nella forma:

```text
YYYY-MM-DDTHH:MM:SSZ
```

l'ordinamento bytewise con `LC_ALL=C` coincide con l'ordinamento cronologico per tali valori.

---

## 2. Ambiguità residua

Se due full release installabili differenti hanno contemporaneamente:

```text
created_at   identico
published_at identico
```

l'adapter fallisce.

Non viene introdotto nessun terzo tie-break implicito.

In particolare non sono ammessi come criterio di successione:

```text
version string
tag_name
SemVer
confronto numerico
confronto lessicografico della versione
GitHub release id
ordine accidentale della pagina API
ordine di ricezione
```

Un eventuale ulteriore criterio repository-native richiede un nuovo caso concreto e una nuova decisione esplicita.

---

## 3. Version string opache

Questa correzione non modifica il contratto generale secondo cui le versioni upstream sono stringhe opache al core `pkg`.

La successione continua a essere stabilita dall'adapter repository-specific attraverso metadata autorevoli del repository e non dal contenuto del tag.

`pkg` continua a usare soltanto la posizione della versione nella successione restituita da `pkg_repository_list_versions`.

---

## 4. Relazione con `latest`

Questa decisione non modifica `pkg_repository_resolve_version <repository-dir>` senza versione esplicita, che continua a usare il normale endpoint GitHub Releases `latest` previsto dal contratto corrente.

La full release risolta come latest deve restare coerente con l'ultima versione della successione completa restituita da `pkg_repository_list_versions` per lo stesso repository/context.

---

## 5. Implementazione e test

L'implementazione GitHub deve estrarre da ogni release installabile almeno:

```text
tag_name
draft
prerelease
created_at
published_at
```

`published_at` deve essere validato con lo stesso formato temporale UTC richiesto per `created_at` prima di essere usato nella chiave di ordinamento.

Il test permanente `tests/rumiai-os/pkg-repository-github/versions.test` deve proteggere almeno:

```text
stesso created_at + published_at differenti
    -> successione deterministica secondo published_at

stesso created_at + stesso published_at
    -> fallimento
```

Le evidenze di validation precedenti restano riferite alle revisioni effettivamente esercitate e non vengono riscritte.

---

## 6. Supersession mirata

Questa decisione supersede esclusivamente la regola incompatibile contenuta in:

```text
decisions/rumiai-os/2026-09-08-http-fetch-json-and-github-adapter-contract.md
```

secondo cui la successione GitHub usa soltanto `created_at` e ogni collisione su `created_at` causa necessariamente errore.

In particolare, l'invariante precedente `PKG-GITHUB-API-05` deve ora essere interpretato secondo la regola composta fissata qui.

Tutte le altre parti della decisione precedente restano valide.

---

## 7. Invarianti fissati

```text
PKG-GITHUB-ORDER-01  created_at resta il criterio primario della successione GitHub
PKG-GITHUB-ORDER-02  published_at è il tie-break esclusivo quando created_at coincide
PKG-GITHUB-ORDER-03  created_at e published_at sono ordinati cronologicamente crescente, oldest -> latest
PKG-GITHUB-ORDER-04  stesso created_at e stesso published_at fra release differenti rende la successione ambigua e causa errore
PKG-GITHUB-ORDER-05  tag/version string non viene mai interpretato o confrontato per risolvere la successione
PKG-GITHUB-ORDER-06  nessun ulteriore tie-break viene inferito senza una nuova decisione esplicita
```
