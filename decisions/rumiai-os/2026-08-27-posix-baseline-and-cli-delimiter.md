# Decisione — Baseline POSIX e delimitatore CLI

Date: 2026-08-27  
Status: **Accepted**

## Contesto

RumiAI OS usa POSIX come contratto di piattaforma e necessita di una baseline esplicita, senza inseguire automaticamente ogni revisione successiva. È inoltre richiesta una regola uniforme sull'uso di `--` che rispetti il contratto reale di ciascun tool.

## Decisione

### 1. Baseline iniziale

La baseline POSIX iniziale di RumiAI OS è:

**POSIX.1-2024 / The Open Group Base Specifications Issue 8**.

Questa scelta è esplicita e non deriva da una politica di adozione automatica della revisione POSIX più recente o della revisione maggiormente implementata dagli host correnti.

### 2. Evoluzione della baseline

La baseline viene rivalutata solo quando RumiAI introduce una necessità concreta relativa a una feature, utility, interfaccia o garanzia semantica appartenente a una revisione successiva.

Quando ciò accade:

1. si identifica il requisito reale;
2. si verifica che la nuova feature sia effettivamente necessaria;
3. si verifica la specifica normativa pertinente;
4. si verifica il comportamento reale sugli OS di riferimento quando materialmente rilevante, con PoC quando opportuno;
5. se la necessità è validata e la revisione successiva è il contratto corretto, si adotta esplicitamente la nuova baseline;
6. se il comportamento reale di uno o più OS di riferimento diverge dal contratto POSIX atteso, si valutano soluzione, compatibilità, fallback, astrazione e/o modifica della baseline prima del consolidamento.

Le feature delle revisioni successive che RumiAI non usa non devono essere verificate preventivamente.

### 3. Regola generale per `--`

Per ogni tool, POSIX o non-POSIX, che supporta `--` con la funzione di terminare il parsing delle opzioni e delimitare gli operandi/argomenti dati successivi:

- con uno o più operandi/argomenti dati, `--` è **mandatory**;
- con zero operandi/argomenti dati, `--` **non deve essere presente**;
- se il tool non supporta `--` con questa funzione, il delimitatore non deve essere forzato;
- il supporto va stabilito dal contratto reale del tool e, quando necessario, verificato empiricamente.

Non tutti i tool POSIX supportano Guideline 10; la sola appartenenza a POSIX non autorizza ad assumere il supporto.

## Conseguenze

- La baseline normativa corrente è Issue 8.
- Il codice e i PoC devono usare `--` sistematicamente dove il tool lo supporta e sono presenti operandi.
- Le eccezioni POSIX che non supportano Guideline 10 devono essere rispettate.
- Una divergenza reale fra Issue 8 e un OS di riferimento diventa un problema da valutare solo quando RumiAI dipende concretamente dalla facility coinvolta.

## Authorization

Questa decisione non autorizza modifiche al repository `rumiai-os` durante la fase iniziale senza consenso esplicito dell'utente.
