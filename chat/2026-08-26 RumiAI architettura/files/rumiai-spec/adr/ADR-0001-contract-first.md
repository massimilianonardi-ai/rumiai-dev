# ADR-0001 Contract-First Architecture

Status: Accepted

## Context
The project evolved from implementation discussions toward abstract contracts.

## Decision
RumiAI is specified through contracts rather than concrete components.

## Consequences
- Kernel implements contracts.
- Gateways implement contracts.
- Implementations remain replaceable.
