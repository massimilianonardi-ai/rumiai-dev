# VoiceStudio

Status: **Current reference snapshot / non-normative**  
Evaluated: 2026-09-28

## Identity

- Upstream: `debpalash/VoiceStudio`
- Upstream branch: `main`
- Evaluated revision: `08a1592e3cb9b4c36beef5fa3185ec2313bb1fea`
- Application license: AGPL-3.0-only as declared upstream
- Default bundled OmniVoice code: Apache-2.0 according to upstream license notice
- Model weights and third-party assets: separately licensed; must be checked per model
- Main desktop stack: Electron/TypeScript plus a local Python speech backend and Rust native-control sidecar

## Purpose and upstream model

VoiceStudio is an open-source local speech platform and desktop application covering voice cloning, voice design, dictation, transcription, video dubbing, audiobook/story production and model management.

The current product is not only a GUI. Upstream explicitly exposes a headless/local-service model and several integration surfaces for applications and agents.

Local operation is the default path. Remote workers and network sharing are optional, and upstream states that analytics require consent.

## Runtime and architecture

The current runtime is split into two principal local planes:

- a Rust native-control sidecar for microphone activation, target capture, clipboard-safe insertion and desktop control;
- a Python speech backend that keeps ASR/TTS models warm and serves the audio/data plane.

The Electron application supervises the local backend. The renderer uses same-origin application-relative API calls rather than directly addressing the backend from the UI.

This split allows integrations to choose how much of the stack they own: native dictation control, custom microphone capture, direct transcription/synthesis, or agent-facing tools.

## Integration surfaces

Current upstream documentation exposes:

- OpenAI-compatible HTTP for transcription;
- WebSocket streaming for live audio and partial/final transcripts;
- MCP over Streamable HTTP;
- MCP stdio shim for clients that require stdio;
- JSON-RPC for native dictation control;
- native CLI flags for dictation control;
- local REST APIs for configuration and agent/voice bindings;
- machine-readable capability discovery endpoints;
- optional remote access with authentication/tunneling guidance.

The MCP surface currently provides tools for:

- speech generation;
- voice cloning;
- transcription;
- voice/language/personality enumeration;
- backend health and active-device inspection.

Voice bindings may be associated with an agent/client identifier so different agents can use different configured voices.

## Engine and model model

VoiceStudio supports a catalog of speech engines rather than a single hard-coded engine. The default path is currently based on k2-fsa/OmniVoice, while additional engines can be selected according to capability and hardware.

The runtime contains explicit device/routing behavior for CPU, CUDA, ROCm and Apple Silicon/MPS paths, plus queueing and timeout controls for expensive generation work.

The architecture therefore separates, at least operationally:

```text
desktop/application workflow
    ↓
speech platform APIs
    ↓
engine/model selection
    ↓
hardware execution
```

This separation is relevant to provider-independent speech capabilities.

## Local-first and remote execution

The default documented workflow runs on local hardware.

Remote operation is optional. Upstream supports scenarios such as a local microphone with a remote GPU backend and warns that authentication alone does not provide network isolation. It recommends trusted networks or encrypted transport/proxying for non-loopback use.

The native control sidecar binds only to loopback and is intentionally separated from remotely shareable audio APIs.

## Security-relevant mechanisms

Useful mechanisms include:

- loopback-only native control;
- browser-origin rejection for native microphone-control paths;
- explicit distinction between local control and remotely shareable data-plane APIs;
- API-key/PIN/ticket mechanisms for remote access;
- path confinement for MCP file inputs and outputs;
- symlink resolution and no-follow file opening;
- per-agent/client voice bindings;
- explicit warnings around untrusted networks;
- preserving clipboard/target semantics during dictation insertion.

These mechanisms are upstream implementation choices and are not independently security-audited by this record.

## RumiAI relevance

### Reuse

Potentially high as an external local speech application/service if its license and target model licenses are acceptable for the intended deployment.

It could provide a substantial amount of speech functionality without RumiAI needing to implement voice cloning, transcription, dubbing, model management and device routing itself.

### Integration

Strong candidate for integration behind a future provider-independent speech/audio capability boundary.

Particularly useful interfaces are:

- OpenAI-compatible transcription;
- streaming WebSocket ASR;
- MCP speech tools;
- headless/local service operation;
- local versus remote execution separation.

A RumiAI integration should depend on an explicit RumiAI-owned speech contract rather than importing VoiceStudio's endpoint names, environment variables or engine vocabulary as project primitives.

### Reference

Very strong for studying:

- local-first multimodal service architecture;
- speech control plane versus audio data plane;
- reusable local service behind desktop and agent clients;
- capability discovery;
- provider/model/hardware separation;
- agent-facing MCP speech tools;
- client-specific voice identity;
- secure handling of local files and remote sharing;
- optional remote acceleration without making cloud execution mandatory.

## Strengths and useful mechanisms

The most interesting property for RumiAI is that VoiceStudio treats speech as a reusable platform rather than a feature embedded only in one UI.

The same backend can support:

- desktop dictation;
- custom editors and GUIs;
- shell/TUI integration;
- OpenAI-compatible clients;
- agent tools via MCP;
- local or remote compute.

That architecture is a useful reference for a future RumiAI audio/speech facility because interface, model engine and execution placement remain partially separable.

## Risks and mismatches

### License

The application is AGPL-3.0-only.

Upstream explicitly offers a separate commercial license for proprietary embedding. Any reuse or distribution inside a closed-source product would therefore require deliberate legal/licensing review rather than assuming ordinary permissive-library reuse.

### Model licensing

Model licensing is independent of the application license.

Upstream currently notes that the default OmniVoice code is Apache-2.0 while the pretrained weights are identified as CC-BY-NC, with additional tokenizer/model components carrying their own terms. Commercial or redistributable use must therefore be verified per selected model.

### Dependency surface

The maintained desktop application combines:

- Electron/Node/Bun;
- Python backend/runtime;
- Rust native sidecar;
- native multimedia/model dependencies;
- optional ffmpeg and GPU stacks.

This is reasonable for an external application but is a substantial dependency footprint and should not dictate RumiAI-owned implementation choices.

### Security and identity

Voice cloning and agent-specific voices create consent, impersonation and provenance concerns. A future RumiAI speech capability would need explicit policy around:

- consent and authorization for cloned voices;
- provenance of generated audio;
- identity versus presentation voice;
- storage and deletion of reference recordings;
- access control for agent-triggered speech generation.

### Product breadth

VoiceStudio covers many workflows beyond the likely minimal RumiAI speech boundary. Reuse should avoid inheriting the entire product ontology if only transcription, synthesis or cloning is required.

## Current assessment

```text
reference     very strong for local speech-platform architecture and agent integration
integration   strong candidate behind a provider-independent speech/audio boundary
reuse         potentially substantial, subject to AGPL and per-model licensing
foundation    no current basis for making VoiceStudio-specific semantics a RumiAI contract
```

## Verification notes

Before any implementation or adoption decision, refresh upstream and verify:

- exact API/MCP stability and versioning;
- current engine catalog and supported capabilities;
- target operating-system and hardware behavior;
- local/offline behavior of the selected engines;
- network/telemetry defaults;
- reference-audio storage and deletion behavior;
- AGPL implications for the intended deployment;
- every selected model's code and weight license;
- commercial-use restrictions;
- authentication and remote-sharing configuration.
