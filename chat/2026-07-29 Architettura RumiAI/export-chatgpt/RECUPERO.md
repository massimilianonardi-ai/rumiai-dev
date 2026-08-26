# Recupero informativo dall'export

## Sequenza consolidata

La conversazione parte dal PoC Level 0 con due pod: Open-WebUI come interfaccia IA e Ollama come Core IA, modello gemma4. Viene sviluppato un Terminal Gateway inizialmente con `ollama.Client`, poi migrato al client OpenAI. Il Core-AI viene realizzato come server FastAPI sulla porta 2000 con compatibilità OpenAI (`/v1/chat/completions`, poi estesa agli endpoint necessari). Il flusso Terminal Gateway → Core-AI → Ollama viene validato realmente; viene validato anche Open-WebUI → Core-AI.

Da questi PoC viene consolidato il principio che l'interfaccia IA può essere composta da gateway indipendenti sviluppabili in parallelo; Terminal Gateway e REST Gateway sono esempi. Il protocollo OpenAI-compatible viene scelto come implementazione concreta iniziale, non come astrazione definitiva.

La discussione evolve verso un Core-AI a microkernel: kernel minimale per dispatch, lifecycle, logging/trace del flusso e caricamento plugin; orchestratore come kernel-mod; kernel-mod descritti attraverso capability. Viene rifiutata una pipeline rigida e preferita un'orchestrazione sostituibile, anche a grafo. Il confronto con LangGraph introduce l'interesse per uno stato condiviso aggiornabile dagli agenti, senza assumere LangGraph come fondamento dell'architettura.

Le capability di comunicazione richieste comprendono almeno: full-duplex streaming, eventi asincroni e request/response bloccante. Viene riconosciuto che OpenAI API non copre naturalmente tutte queste modalità e non risolve da sola output cross-gateway, ad esempio voce in ingresso e risposta su un altro canale.

La discussione sugli I/O multimodali estende il problema oltre l'utente: mouse, tastiera, computer-use, sensori, temperatura, smart home e futuri dispositivi devono poter essere integrati senza cambiare il modello cognitivo. Da qui nasce la necessità di standardizzare gli I/O e il concetto di `ai-channel`, successivamente interpretato come canale/nervo trasmissivo tra sensi/espressioni e RumiAI.

## Decisioni forti recuperate

- local-first, open source, componenti sostituibili;
- dati e modelli sotto controllo dell'utente;
- governance del modello cognitivo separata dalle implementazioni;
- OpenAI-compatible come protocollo pratico iniziale, non come fondamento concettuale;
- microkernel minimale;
- orchestrazione come modulo sostituibile;
- capability come linguaggio comune dei kernel-mod;
- niente pipeline rigida come assunzione architetturale;
- logging/trace centrale del flusso;
- necessità di comunicazioni RR, asincrone e full-duplex;
- standardizzazione degli I/O multimodali verso utenti e dispositivi;
- PoC reali come strumento di validazione delle scelte.

## Metodo

La conversazione conferma il metodo top-down / divide et impera, ma con validazione rapida tramite prototipi. La progettazione non deve allontanarsi a lungo dalla possibilità di implementazione concreta.
