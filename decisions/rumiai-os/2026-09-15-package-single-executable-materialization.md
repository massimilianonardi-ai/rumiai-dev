# Decisione — Materializzazione di single executable in `pkg_extract`

Date: 2026-09-15  
Status: **Accepted**

## 1. Contesto

Il contratto corrente definisce `pkg_extract` come layer repository-neutral di package materialization fra download e integrazione. Oltre ai formati delegati alla utility generale `extract`, il layer gestisce già `appimage` come materializzazione opaca package-specific.

Il package `jq` introduce un caso concreto differente: gli artifact ufficiali per i target correnti sono singoli file eseguibili già pronti all'uso, non archivi da estrarre. Deviare questo caso fuori da `pkg_extract` farebbe conoscere all'orchestratore `pkg install` la natura fisica del payload e romperebbe la pipeline già fissata.

L'utente ha approvato esplicitamente l'estensione di `pkg_extract` con una vera modalità di materializzazione single-executable, scartando sia un generico `none` sia un bypass del layer.

## 2. Nuovo format token

Il package format aggiunto è:

```text
executable
```

`executable` identifica un artifact upstream costituito da un singolo regular file che è esso stesso il programma eseguibile da materializzare.

Non è autodetection. Il token deve essere dichiarato esplicitamente dal range della package definition, come gli altri format correnti.

Non viene introdotto alcun campo separato `mode`, `chmod` o equivalente nel catalogo.

## 3. Semantica di materializzazione

Per:

```text
pkg_extract <artifact> executable <staging-dir>
```

`pkg_extract`:

1. applica le normali validazioni di artifact e staging già fissate;
2. non esegue l'artifact;
3. non delega a `extract`;
4. copia opacamente i byte dell'artifact nella raw materialization preservandone il basename;
5. rende eseguibile la copia materializzata;
6. lascia invariato l'artifact di input;
7. applica la normale useful-root discovery.

Il contratto del mode risultante è intenzionalmente minimo: il file materializzato deve soddisfare il requisito executable usato dal package launcher. Non viene fissato un mode numerico universale e non vengono introdotti permission metadata nel catalogo.

Per un payload composto dal solo executable, la raw root contiene una singola regular-file entry e quindi la structural useful-root normalization è identità. Lo staging consegnato al caller resta una directory e rappresenta direttamente la useful root:

```text
staging/
└── <upstream-basename>
```

Input e output non coincidono: l'artifact scaricato resta nel download staging del caller e la useful root resta la destination separata ricevuta come terzo argomento.

## 4. Rapporto con `appimage`

`appimage` e `executable` restano semanticamente distinti.

```text
appimage
    payload AppImage opaco
    preserva basename e mode dell'artifact
    non esegue il payload

executable
    regular-file executable generico già pronto all'uso
    preserva basename e contenuto
    garantisce executable sulla copia materializzata
    non esegue il payload
```

`appimage` non viene reinterpretato come generic executable e non viene modificato da questa decisione.

## 5. Pipeline invariata

La pipeline resta:

```text
pkg_repository_resolve_artifact
    -> pkg_download
    -> read range/format
    -> pkg_extract
    -> pkg_integrate
```

L'orchestratore non introduce branch specifici per archive/executable/AppImage e non materializza direttamente payload.

`pkg_integrate` continua a ricevere una useful root già materializzata e normalizzata e non acquisisce responsabilità di chmod del payload upstream.

## 6. Failure ed exit status

La modalità `executable` usa gli exit status già fissati per `pkg_extract`:

```text
0  materializzazione e normalizzazione riuscite
1  artifact/staging/materialization/normalization failure
2  invocazione o format token non supportato
```

Una failure durante copia o impostazione dell'executable bit invalida lo staging come ogni altra materialization failure package-level.

## 7. Testing

Il test permanente di `pkg_extract` deve proteggere almeno che `executable`:

```text
non venga delegato a extract
non esegua l'artifact
preservi il basename
preservi il contenuto byte-for-byte
produca una copia executable
non renda executable l'artifact di input
consegni lo staging come useful root senza wrapper artificiale
```

La physical validation di package concreti resta revision-specific e distinta dal contract test isolato.

## 8. Invarianti

```text
PKG-EXECUTABLE-01  format token = executable
PKG-EXECUTABLE-02  executable è una materialization mode di pkg_extract, non un branch dell'orchestratore pkg install
PKG-EXECUTABLE-03  executable non viene delegato alla utility generale extract
PKG-EXECUTABLE-04  l'artifact upstream non viene eseguito durante la materializzazione
PKG-EXECUTABLE-05  la copia materializzata preserva basename e contenuto dell'artifact
PKG-EXECUTABLE-06  la copia materializzata deve risultare executable; l'artifact di input resta invariato
PKG-EXECUTABLE-07  lo staging di output resta una directory e rappresenta direttamente la useful root normalizzata
PKG-EXECUTABLE-08  non vengono introdotti mode/chmod metadata nel catalogo
PKG-EXECUTABLE-09  appimage mantiene la propria semantica distinta e non viene reinterpretato
PKG-EXECUTABLE-10  nessuna autodetection del format viene introdotta
```
