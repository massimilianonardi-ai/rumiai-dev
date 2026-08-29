## 001 — USER

- Node ID: `e231017c-2b2a-49bb-87f4-7fdb50c136ad`
- Timestamp: `2026-07-29T07:58:21.387+02:00`

obiettivo: architettura software IA sovrana, locale e open source.
sistema operativo cognitivo personale.
nome del progetto: RumiAI.
Principi:
- Zero costi obbligatori: nessun abbonamento, nessun servizio cloud necessario;
- Local-first: elaborazione e dati sul dispositivo dell’utente, il sistema deve funzionare anche senza connessione internet, senza account esterni e senza API proprietarie;
- Open source: componenti verificabili e modificabili;
- Modulare: ogni componente può essere sostituito o migliorato;
- Distribuibile: futura evoluzione verso una rete di nodi IA cooperanti;
- i dati personali appartengano all’utente, ma l’architettura, le regole e l’evoluzione di RumiAI sono governate dagli sviluppatori;
- Data ownership: l’utente possiede modelli, dati, memoria e configurazioni, può usare il sistema, configurarlo entro i limiti previsti, fornire dati e contenuti, concedere o negare permessi previsti, scegliere tra opzioni disponibili;
- Governance ownership: gli sviluppatori mantengono la responsabilità di definire il modello cognitivo, stabilire quali moduli esistono, decidere le modalità di estensione, governare l’evoluzione del progetto;
Architettura di livello 0: utente - interfaccia ia - core ia.
Architettura di livello 1:
- utente: persona, operatore o nodo;
- interfaccia ia: chat, voce, immagini, video, documenti, conversazione multimodale;
- core ia: interpretazione, ragionamento, pianificazione, esecuzione, apprendimento;

---

## 002 — ASSISTANT

- Node ID: `2ff00df8-1e1b-47c0-975b-de6e4e3ba4d1`
- Timestamp: `2026-07-29T07:58:21.876+02:00`

La direzione è coerente e ben definita: non stai descrivendo semplicemente un assistente IA, ma un **sistema operativo cognitivo personale**. La distinzione tra *ownership dei dati* e *governance dell'architettura* è particolarmente importante perché separa chiaramente ciò che appartiene all'utente da ciò che definisce l'identità del progetto.

Ti propongo una versione strutturata che può diventare la base del manifesto tecnico di **RumiAI**.

---

# RumiAI
## Sistema Operativo Cognitivo Personale

### Visione

RumiAI è un sistema operativo cognitivo personale, locale e open source, progettato affinché ogni utente possa disporre di una propria intelligenza artificiale privata, funzionante senza dipendere da servizi cloud, abbonamenti o API proprietarie.

L'obiettivo è costruire un'architettura software sovrana, nella quale l'utente mantiene il pieno controllo dei propri dati e della propria memoria, mentre il progetto conserva una governance tecnica coerente e verificabile.

---

# Principi Fondamentali

## 1. Zero Costi Obbligatori

RumiAI deve poter essere utilizzato senza:

- abbonamenti
- servizi cloud
- API proprietarie
- licenze obbligatorie

Ogni componente essenziale deve poter funzionare gratuitamente.

---

## 2. Local First

L'elaborazione avviene sul dispositivo dell'utente.

Il sistema deve funzionare anche:

- senza Internet
- senza account esterni
- senza autenticazioni remote
- senza dipendenze da infrastrutture proprietarie

Internet rappresenta un'estensione facoltativa, non un requisito operativo.

---

## 3. Open Source

Ogni componente critico deve essere:

- ispezionabile
- verificabile
- modificabile
- sostituibile

Il progetto deve poter essere compilato e distribuito senza dipendenze chiuse obbligatorie.

---

## 4. Modularità

Ogni modulo è indipendente.

Ogni componente può essere:

- sostituito
- aggiornato
- migliorato
- esteso

senza compromettere il funzionamento dell'intero sistema.

---

## 5. Distribuibilità

L'architettura è progettata per evolvere verso una rete di nodi IA cooperanti.

Ogni installazione di RumiAI può operare:

- completamente isolata;
- come nodo di una rete privata;
- come nodo di una futura rete distribuita.

---

# Proprietà dei Dati (Data Ownership)

I dati appartengono esclusivamente all'utente.

L'utente possiede:

- memoria personale
- documenti
- conoscenza importata
- modelli locali installati
- configurazioni
- cronologia
- preferenze
- permessi concessi

L'utente può:

- utilizzare il sistema;
- esportare i propri dati;
- eliminarli;
- eseguire backup;
- ripristinarli;
- scegliere i modelli installati;
- concedere o negare i permessi previsti dall'architettura.

---

# Governance del Progetto (Governance Ownership)

L'architettura cognitiva di RumiAI è governata dagli sviluppatori del progetto.

La governance comprende:

- definizione del modello cognitivo;
- progettazione dell'architettura;
- definizione dei moduli ufficiali;
- protocolli di comunicazione;
- regole di estensione;
- evoluzione del sistema;
- compatibilità tra versioni;
- politiche di sicurezza.

Gli utenti possono configurare il sistema entro le possibilità previste dall'architettura, ma non ridefiniscono il modello cognitivo ufficiale del progetto.

---

# Architettura

## Livello 0

```
Utente
    │
    ▼
Interfaccia IA
    │
    ▼
Core IA
```

Tre livelli fondamentali:

- Utente
- Interfaccia
- Intelligenza

---

# Livello 1

## 1. Utente

Rappresenta qualsiasi entità che utilizza il sistema.

Può essere:

- Persona
- Operatore
- Nodo remoto

---

## 2. Interfaccia IA

È il livello di comunicazione tra l'utente e il sistema cognitivo.

Supporta modalità multimodali:

- Chat
- Voce
- Immagini
- Video
- Documenti
- Conversazione multimodale

L'interfaccia è responsabile esclusivamente della gestione dell'interazione, senza prendere decisioni cognitive.

---

## 3. Core IA

Il Core rappresenta il motore cognitivo di RumiAI.

Le sue funzioni fondamentali sono:

- Interpretazione
- Ragionamento
- Pianificazione
- Esecuzione
- Apprendimento

Il Core coordina i moduli specializzati, mantiene lo stato cognitivo del sistema e orchestra il flusso decisionale.

---

# Principio di Separazione

RumiAI adotta una netta separazione tra interazione e cognizione.

L'interfaccia si occupa esclusivamente di ricevere e presentare informazioni.

Il Core IA interpreta, ragiona, pianifica ed esegue.

Questa separazione consente di sostituire qualsiasi interfaccia (chat, voce, API, interfacce grafiche o realtà aumentata) senza modificare il motore cognitivo.

---

## Evoluzione proposta

Questa può essere considerata la **specifica di Livello 0 e Livello 1**. Il passo successivo naturale è definire il **Livello 2**, scomponendo il Core IA in sottosistemi distinti, ad esempio:

- **Kernel Cognitivo** (orchestrazione e ciclo cognitivo)
- **Memoria** (breve termine, lungo termine, conoscenza)
- **Reasoning Engine** (ragionamento e inferenza)
- **Planner** (pianificazione di obiettivi e task)
- **Tool Engine** (esecuzione di strumenti e automazioni)
- **Knowledge Engine** (RAG, indicizzazione e ricerca locale)
- **Learning Engine** (apprendimento e adattamento)
- **Security & Permissions** (permessi, sandbox e controllo accessi)
- **Node Engine** (cooperazione tra nodi RumiAI)
- **Model Manager** (gestione di LLM, embedding, modelli multimodali e loro sostituzione)

Questa decomposizione mantiene la filosofia di RumiAI: un **kernel cognitivo modulare**, analogo a un sistema operativo, in cui ogni componente è sostituibile senza compromettere l'intero ecosistema.

---

## 003 — USER

- Node ID: `006424d1-3d4d-4d9d-8159-ad00a5b5143b`
- Timestamp: `2026-07-29T08:04:01.312+02:00`

evoluzione proposta per il livello 2 accettata

---

## 004 — ASSISTANT

- Node ID: `9a63927b-ad5b-493b-a74f-64b7b8eab8ae`
- Timestamp: `2026-07-29T08:04:01.762+02:00`

Ottimo. Con questa decisione l'architettura di RumiAI assume una struttura gerarchica chiara:

- **Livello 0** → Visione generale
- **Livello 1** → Macro-componenti
- **Livello 2** → Architettura interna del Core IA
- **Livelli successivi** → Moduli, servizi, API e implementazione.

Propongo quindi la specifica del **Livello 2**.

---

# RumiAI
## Architettura di Livello 2 – Core IA

Il Core IA costituisce il nucleo cognitivo del sistema operativo RumiAI.

È composto da moduli indipendenti, cooperanti e sostituibili, coordinati dal Kernel Cognitivo.

```text
                         CORE IA

                    ┌───────────────────┐
                    │ Kernel Cognitivo  │
                    └─────────┬─────────┘
                              │
 ┌──────────────┬─────────────┼─────────────┬──────────────┐
 │              │             │             │              │
 ▼              ▼             ▼             ▼              ▼

Memory     Reasoning      Planner      Tool Engine   Knowledge

 │              │             │             │              │

 └──────┬───────┴──────┬──────┴──────┬──────┴──────────────┐
        ▼              ▼             ▼                     ▼

 Learning      Security & Permissions      Model Manager

                          │
                          ▼

                    Node Engine
```

---

# 2.1 Kernel Cognitivo

È il supervisore dell'intero sistema.

Responsabilità:

- orchestrazione dei moduli;
- gestione del ciclo cognitivo;
- controllo dello stato interno;
- coordinamento dei flussi informativi;
- gestione delle priorità;
- monitoraggio delle prestazioni;
- gestione degli errori e del recupero.

Il Kernel Cognitivo non esegue direttamente il ragionamento: coordina i moduli specializzati.

---

# 2.2 Memory Engine

Gestisce tutte le forme di memoria.

Comprende:

- memoria di lavoro;
- memoria conversazionale;
- memoria episodica;
- memoria semantica;
- memoria documentale;
- memoria delle preferenze;
- memoria procedurale.

Caratteristiche:

- completamente locale;
- esportabile;
- cifrabile;
- versionabile.

---

# 2.3 Reasoning Engine

È il motore del ragionamento.

Responsabilità:

- interpretazione;
- deduzione;
- induzione;
- pianificazione logica;
- valutazione delle alternative;
- verifica della coerenza;
- gestione delle incertezze.

È indipendente dal modello linguistico utilizzato.

---

# 2.4 Planner

Trasforma gli obiettivi in piani eseguibili.

Funzioni:

- decomposizione dei problemi;
- definizione delle priorità;
- pianificazione multi-step;
- gestione delle dipendenze;
- monitoraggio dello stato di avanzamento;
- revisione dinamica del piano.

---

# 2.5 Tool Engine

Gestisce l'utilizzo degli strumenti.

Può controllare:

- filesystem;
- database;
- browser;
- terminale;
- automazioni;
- sensori;
- dispositivi locali;
- servizi remoti opzionali.

Ogni strumento opera attraverso permessi espliciti.

---

# 2.6 Knowledge Engine

Gestisce la conoscenza.

Responsabilità:

- indicizzazione;
- ricerca semantica;
- RAG locale;
- gestione dei documenti;
- ontologie;
- basi di conoscenza;
- collegamenti tra informazioni.

Può operare completamente offline.

---

# 2.7 Learning Engine

Permette al sistema di migliorare nel tempo.

Può apprendere:

- preferenze;
- abitudini;
- procedure;
- pattern ricorrenti;
- nuove conoscenze autorizzate.

Non modifica autonomamente il Kernel Cognitivo.

---

# 2.8 Security & Permissions

Controlla sicurezza e autorizzazioni.

Responsabilità:

- autenticazione locale;
- autorizzazioni;
- sandbox;
- isolamento dei moduli;
- gestione dei privilegi;
- audit;
- registrazione delle operazioni.

Nessun modulo può aggirare questo componente.

---

# 2.9 Model Manager

Gestisce tutti i modelli IA.

Comprende:

- LLM;
- modelli embedding;
- OCR;
- STT (Speech-to-Text);
- TTS (Text-to-Speech);
- modelli di visione;
- classificatori;
- modelli futuri.

Responsabilità:

- installazione;
- aggiornamento;
- sostituzione;
- selezione automatica;
- ottimizzazione delle risorse;
- compatibilità tra versioni.

Il resto dell'architettura non dipende da uno specifico modello.

---

# 2.10 Node Engine

È il modulo dedicato alla futura evoluzione distribuita.

Responsabilità:

- comunicazione tra nodi;
- sincronizzazione autorizzata;
- federazione;
- cooperazione;
- condivisione selettiva della conoscenza;
- esecuzione distribuita.

Può essere completamente disabilitato senza compromettere il funzionamento locale.

---

# Principi Architetturali del Livello 2

Ogni modulo del Core IA deve rispettare i seguenti principi:

- **Singola responsabilità**: ogni modulo ha un compito ben definito.
- **Modularità**: ogni componente può essere sostituito senza modificare il resto del sistema.
- **Interoperabilità**: i moduli comunicano tramite interfacce standardizzate.
- **Local-first**: tutte le funzionalità essenziali operano senza connessione Internet.
- **Sicurezza**: ogni operazione è soggetta ai controlli del modulo Security & Permissions.
- **Estensibilità**: nuovi moduli possono essere integrati senza alterare il Kernel Cognitivo.
- **Governance centrale**: l'evoluzione dell'architettura e dei protocolli è definita dagli sviluppatori del progetto, mentre l'utente mantiene il controllo dei propri dati, modelli e configurazioni.

Con questo Livello 2, RumiAI assume una struttura assimilabile a quella di un sistema operativo moderno: il **Kernel Cognitivo** coordina un insieme di servizi specializzati che costituiscono il nucleo dell'intelligenza artificiale, mantenendo indipendenza dai modelli sottostanti e garantendo modularità, sicurezza ed evolvibilità.

---

## 005 — USER

- Node ID: `97271258-ec7b-4107-96b3-51b1beb7ff51`
- Timestamp: `2026-07-29T08:13:35.712+02:00`

ora pensiamo ad un prototipo molto semplice che rispetti l'architettura, ma la cui implementazione parta con un prompt via chat ed il core ia sia in grado di rispondere testualmente e di eseguire comandi su terminale linux

---
