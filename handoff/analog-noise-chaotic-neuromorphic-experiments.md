# Analog noise, synchronization and chaotic-neuron experiments

Status: Active
Updated: 2026-10-10

## Goal

Determine through reproducible open-source simulation whether nonlinear/chaotic neuron dynamics or synchronization can improve useful computation under realistic analog noise and component mismatch, while preserving enough state diversity for a reservoir. Use BrainScaleS-2 as an architectural reference for mixed-signal dynamics plus digital calibration/control/plasticity, not as evidence that chaos is superior.

This is an experimental workstream only. It does not alter RumiAI architecture or justify physical construction until a bounded result survives matched baselines and uncertainty tests.

## Current repository revisions

```text
rumiai-dev      7c4e0ab7d2ef595914082700b09f7260b2745b32 (main at latest fresh preflight)
rumiai-dev-PoCs 1e161e15b8e818ba204f571799b71d3d6d3502a3 (main at latest compare)
rumiai-dev-PoCs 8f6a64f4e375605a3a3f0b446093231c1f632331 (poc/059-chaotic-neuron-noise-screening; latest recorded PoC branch head)
rumiai-dev-PoCs 7c89467332db536d8250c0234463a87576a0fca7 (task protocol v2)
```

Resume with fresh remote HEAD checks.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
specifications/README.md
specifications/rumiai-os/CURRENT-MODEL.md
handoff/README.md
handoff/chaotic-dynamics-rumiai-research.md
```

Experiment code and revision-specific evidence belong in `rumiai-dev-PoCs`.

## Fixed task-local choices

1. Start in software simulation on Linux with open-source tools; do not build hardware or integrate into RumiAI runtime on the basis of current evidence.
2. Treat chaos, synchronization and neuronal spiking as candidate mechanisms, not assumptions or goals.
3. Separate independent per-unit process noise, shared/common-mode disturbances, observation/readout noise, fixed component mismatch and slow drift. A result for one channel must not be generalized to the others.
4. Compare synchronization/error attenuation across a coupling sweep and measure state diversity at the same time; agreement between units alone is not a useful-computation criterion.
5. Any later task-level comparison must use matched input information, readout/state budgets and tuning, with train/validation/test separation. Keep test data out of model/parameter selection.
6. A “chaotic” regime must be verified by a dynamical diagnostic such as a positive largest Lyapunov exponent; irregular/noisy activity alone does not establish deterministic chaos.
7. Borrow BrainScaleS-2 ideas selectively: continuous-time analog states with digital parameter calibration, measurement, control and learning. Do not imply access to or reproduction of BrainScaleS-2 hardware.

## Working design

### First mechanism screen

PoC 059 asks whether all-to-mean diffusive coupling changes three distinct effects in a population of identical Hindmarsh–Rose cells with common input:

- disagreement among cells under independent per-cell state disturbances;
- displacement of the population mean under common-mode disturbances and independent noise;
- loss of state diversity as coupling rises.

This screen is intentionally not an AI task or readout benchmark. It checks one possible mechanism before spending effort on a task-level reservoir claim.

### PoC 059 model and conditions

- 16 three-variable Hindmarsh–Rose cells; parameters a=1, b=3, c=1, d=5, r=0.005, s=4, x_r=-1.618, I=3.25, chosen from published chaotic-bursting examples.
- Identical iid input to each cell, injected as a 0.3-amplitude current drive; couplings k={0, 0.05, 0.2, 0.5}; RK4 at dt=0.02 with 8 substeps per input symbol.
- Process perturbations are Gaussian x-state kicks at input-symbol boundaries with sigma=5% of clean population x SD, independently per cell or identically across cells.
- Component proxy is a fixed ±1% per-cell external-current perturbation. It is explicitly not a transistor/noise model.
- Three seeds, 1,200 post-warmup input symbols per seed. Report pair disagreement, collective-mean shift, total trajectory shift and clean state effective rank. Isolated unforced-cell finite-time Lyapunov estimates at dt=0.02 and dt=0.01 gate the chaotic operating regime; they do not certify chaos of the driven coupled network.

## Completed

- PoC 058 was merged into `rumiai-dev-PoCs/main` on 2026-10-08 (merge commit `394e8d5831e63be7e529db617c3c49328da9bbcd`). It provides an electrical/optoelectronic reservoir baseline, but contains no chaotic neuron or synchronization experiment.
- The dedicated noise/chaotic-neuron handoff was created separately from the broad dynamics/control and patent-watch handoff. The latter links here and retains only the broader research/watch responsibility.
- PoC 059 was implemented and run on Linux for seeds 11, 29 and 47. `py_compile`, a one-seed quick run and the full three-seed run succeeded. Source, report and all per-seed JSON are in draft [PR 2](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/pull/2), branch `poc/059-chaotic-neuron-noise-screening`.
- The original isolated-cell Lyapunov routine had an RK4 refinement bug: its dt=0.01 update used DT=0.02 for intermediate stages. The old dt=0.01 result (0.02397) is not a valid refinement result. The routine was corrected in commit `5ec3a445e2c8db66709250a05554c476878e5c81`; a fresh full three-seed rerun reports 0.01879488 at dt=0.02 and 0.01879489 at dt=0.01 per model time unit. Evidence, hashes and provenance are in `sessions/2026-10-10-lyapunov-rk4-correction/`.
- Corrected full-run diagnostics at k=0.5: independent process noise reduced pair disagreement to 0.4802 ± 0.0237 from 0.7772 ± 0.0253 at k=0, but increased total trajectory shift to 1.3119 ± 0.0959 from 1.0589 ± 0.0345. Clean effective rank fell to 2.2379 ± 0.2119 from 3.6277 ± 0.4734. Under common-mode noise at k=0.5, collective shift was 1.0749 ± 0.2376. The descriptive coupling/noise conclusions remain essentially unchanged by the diagnostic fix.
- This supports only a limited mechanism-level conclusion: coupling can reduce relative disagreement while the collective trajectory remains noisy or diverges from its clean counterpart, and stronger coupling can reduce state diversity. No AI utility, physical noise tolerance, hardware performance, energy or speed advantage is established.
- The GitHub Actions workflow is included in PR 2. The existing hosted execution status is still unverified: commit status checks were empty, and the available workflow-run connector returns only pull-request-triggered runs, not the `push` run configured here. Those empty responses are not evidence of a pass. Local Linux execution is the validated run.

## Current state

PR 2 remains open and draft. PoC 059's mechanism screen has no trained readout or AI task score. Its exploratory noise/synchronization result is retained, with the corrected Lyapunov refinement session kept separately from the original evidence. The protocol v2 preregistration is committed at `7c89467332db536d8250c0234463a87576a0fca7`.

The preregistered regime gate was run before task fitting. Candidate I=3.25 passed the chaotic gate in 10/10 seeds. Candidate I=2.90 met the non-positive regular gate in only 6/10, below the required 8/10. Protocol v2 therefore returns **inconclusive and stop**; no task benchmark was run, no alternate I was searched, and no task score was inspected. Reproducible runner, per-seed values and report are in `sessions/2026-10-10-protocol-v2-regime-gates/`.

At latest comparison, PoC 059 branch `8f6a64f4e375605a3a3f0b446093231c1f632331` diverged from current main `1e161e15b8e818ba204f571799b71d3d6d3502a3`: 18 commits ahead and 251 behind from merge base `394e8d5831e63be7e529db617c3c49328da9bbcd`. PR metadata still records that old base SHA and reports `mergeable=true`; keep it draft until base/check state is confirmed. Hosted workflow status remains unverified: the available run connector filters out the workflow's `push` event, and empty run/status responses are not evidence of success.

PoC 058 remains on main as the electrical/optoelectronic task benchmark. Neither PoC establishes calibrated physical noise tolerance, energy/speed advantage or general AI benefit.

## Next action

1. Verify the newly triggered Ubuntu workflow for PR 2 using a run listing that includes `push` events; the currently available connector cannot establish its outcome. Keep the PR draft until hosted execution and review are complete.
2. Confirm PR 2's recorded base against current `main`; its compare is 13 ahead/19 behind from the old merge base while GitHub currently reports `mergeable=true`. Keep draft status until the current base and required checks are clear.
3. Rerun the full PoC 059 mechanism screen with the corrected RK4 Lyapunov estimator and preserve a new session; do not overwrite the original evidence. Then implement protocol v2 exactly as preregistered at `pocs/059-chaotic-neuron-noise-screening/TASK-PREREGISTRATION.md`. First evaluate only the isolated-cell Lyapunov regime gates. If either I candidate fails its preregistered gate, record comparison as inconclusive; do not tune I against task results. Then run the frozen train/validation/test and separate perturbation conditions, retaining all per-seed results.
4. Report accuracy together with state diversity, synchrony and channel-specific robustness. Do not promote an architecture or infer hardware benefit from this model-level task.

## Next action

1. Keep protocol v2 closed as inconclusive. Do not run its task benchmark or select another current under that version.
2. If the work continues, create protocol v3 before any task-level run: justify a genuinely regular comparison regime independently, validate its Lyapunov gate on fixed seeds, then freeze all conditions and only afterwards run the task benchmark. Do not use held-out task scores to choose the regime.
3. Verify the Ubuntu hosted workflow using a run listing that includes `push` events. The current connector cannot establish this result.
4. Confirm/synchronize the PoC branch to current `main` with a forward-only merge, inspect the full resulting diff and checks, and retain draft status until then.
5. Keep the broad parent handoff focused on nonlinear-dynamics research and patent watch; this handoff owns operational experiment state.

## Blockers / open questions

- The state kicks and current perturbation are model-level probes, not calibrated physical noise or component models.
- No full network Lyapunov spectrum, transverse exponent or network trajectory refinement was run. The corrected isolated-cell diagnostic is a finite-time indicator only.
- PoC 059 has no trained readout or AI-task benchmark; no task-level benefit is known.
- No claim-level freedom-to-operate analysis has been performed; the broad parent handoff retains patent-watch responsibility.
