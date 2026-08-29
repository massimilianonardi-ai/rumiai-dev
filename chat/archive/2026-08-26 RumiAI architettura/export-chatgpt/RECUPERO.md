# Recupero informativo dall'export

> Titolo originale nell'export: `[prj] RumiAI architettura`. Titolo successivamente stabilito dall'utente: `RumiAI architettura`.

La conversazione prosegue la formalizzazione architetturale di RumiAI. Il lavoro si sposta progressivamente dalla discussione di componenti concreti alla definizione di una specifica architetturale indipendente dall'implementazione.

## Elementi recuperati materialmente dallo ZIP

Sono presenti e sono stati copiati senza sostituire i file già archiviati:

- `000-core-ontology.md`
- `001-vision.md`
- `002-principles.md`
- `003-architecture-overview.md`
- `ADR-0001-contract-first.md`
- `ADR-0002-akb-first.md`
- `README.md`

Questi file documentano una fase in cui vengono formalizzati: specification-first, contract-first, local-first, user data ownership, componenti sostituibili e contratti standardizzati. Le astrazioni elencate includono Contracts, Messages, Context, Capabilities, Communication, Kernel, Kernel-Mod e Gateway. Il kernel instrada e applica i contratti senza interpretare il payload di dominio.

ADR-0001 registra la scelta Contract-First: RumiAI è specificato tramite contratti anziché componenti concreti; kernel e gateway implementano contratti e le implementazioni rimangono sostituibili.

ADR-0002 registra la scelta Architecture Knowledge Base First: la knowledge base architetturale viene considerata fonte autorevole da cui derivano specifiche, RFC e ADR.

## Nota di conservazione

Questi documenti rappresentano lo stato della progettazione in quella fase della conversazione e non devono essere automaticamente interpretati come più recenti o più autorevoli delle successive revisioni concettuali del progetto. Sono conservati come fonte storica esatta recuperata dall'export.
