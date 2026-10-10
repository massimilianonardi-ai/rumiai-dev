# Analog noise, synchronization and chaotic-neuron experiments

Status: Active
Updated: 2026-10-10

## Goal

Determine through reproducible open-source simulation whether nonlinear/chaotic neuron dynamics or synchronization can improve useful computation under realistic analog noise and component mismatch, while preserving enough state diversity for a reservoir. Use BrainScaleS-2 as an architectural reference for mixed-signal dynamics plus digital calibration/control/plasticity, not as evidence that chaos is superior.

This is an experimental workstream only. It does not alter RumiAI architecture or justify physical construction until a bounded result survives matched baselines and uncertainty tests.

## Current repository revisions

```text
rumiai-dev      e77414507435def79aa9a4086ca07127e72ea806 (main; latest handoff checkpoint)
rumiai-dev-PoCs 888aa6d4c520fdc6266c37b505ba3b938a8a6135 (main at latest compare)
rumiai-dev-PoCs da0d5c8de0975872f4efa2f416fd9de857fa1fa1 (poc/059-chaotic-neuron-noise-screening; corrected code, protocol, and rerun evidence)
rumiai-dev-PoCs 7c89467332db536d8250c0234463a87576a0fca7 (same branch; task protocol v2)
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
- The original isolated-cell Lyapunov routine had an RK4 refinement bug: its `dt=0.01` update used `DT=0.02` for intermediate stages. The `dt=0.02` estimate remains valid; the original `dt=0.01` value (0.02397) is not a valid refinement result. The routine is corrected in branch commit `5ec3a445e2c8db66709250a05554c476878e5c81`; `py_compile` and a one-seed quick run pass, yielding 0.01879488 at both `dt=0.02` and `dt=0.01`. The original three-seed full screen has not yet been rerun with the corrected diagnostic, so the valid convergence check is limited to that quick run.
- Corrected full-run diagnostics at k=0.5: independent process noise reduced pair disagreement to 0.4802 ± 0.0237 from 0.7772 ± 0.0253 at k=0, but increased total trajectory shift to 1.3119 ± 0.0959 from 1.0589 ± 0.0345. Clean effective rank fell to 2.2379 ± 0.2119 from 3.6277 ± 0.4734. Under common-mode noise at k=0.5, collective shift was 1.0749 ± 0.2376. The descriptive coupling/noise conclusions remain essentially unchanged by the diagnostic fix.
- This supports only a limited mechanism-level conclusion: coupling can reduce relative disagreement while the collective trajectory remains noisy or diverges from its clean counterpart, and stronger coupling can reduce state diversity. No AI utility, physical noise tolerance, hardware performance, energy or speed advantage is established.
- The GitHub Actions workflow is included in PR 2. The existing hosted execution status is still unverified: commit status checks were empty, and the available workflow-run connector returns only pull-request-triggered runs, not the `push` run configured here. Those empty responses are not evidence of a pass. Local Linux execution is the validated run.

## Current state

PR 2 remains draft. Its original mechanism screen is exploratory and has no task metric. A separate task-level protocol v2 is preregistered in `pocs/059-chaotic-neuron-noise-screening/TASK-PREREGISTRATION.md` at commit `7c89467332db536d8250c0234463a87576a0fca7`; no task-level outcomes have been inspected. It fixes the synthetic regression, two candidate HR regimes, coherent Lyapunov protocol, coupling sweep, data splits, exact 16-state ESN baseline, perturbation channels and reporting rules before implementation. PoC 058 remains the electrical/optoelectronic task benchmark and is on main. At the latest compare, PoC 059 branch `da0d5c8de0975872f4efa2f416fd9de857fa1fa1` diverged from main `888aa6d4c520fdc6266c37b505ba3b938a8a6135` (13 commits ahead, 19 behind); PR 2 remains draft and now reports `mergeable=false`. The PR metadata still reports its old base SHA `394e8d5831e63be7e529db617c3c49328da9bbcd`. Keep it draft; synchronize with current main through a forward-only merge commit, inspect the resulting tree and diff, and confirm checks before considering it ready.

## Next action

1. Verify the newly triggered Ubuntu workflow for PR 2 using a run listing that includes `push` events; the currently available connector cannot establish its outcome. Keep the PR draft until hosted execution and review are complete.
2. Reconcile PoC 059 with current `main` using a forward-only update, inspect the resulting diff, and confirm required checks. The branch is 13 ahead/19 behind and the PR reports `mergeable=false`.
3. Rerun the full PoC 059 mechanism screen with the corrected RK4 Lyapunov estimator and preserve a new session; do not overwrite the original evidence. Then implement protocol v2 exactly as preregistered at `pocs/059-chaotic-neuron-noise-screening/TASK-PREREGISTRATION.md`. First evaluate only the isolated-cell Lyapunov regime gates. If either I candidate fails its preregistered gate, record comparison as inconclusive; do not tune I against task results. Then run the frozen train/validation/test and separate perturbation conditions, retaining all per-seed results.
4. Report accuracy together with state diversity, synchrony and channel-specific robustness. Do not promote an architecture or infer hardware benefit from this model-level task.

## Blockers / open questions

- The state kicks and current perturbation are model-level probes, not calibrated physical noise or component models.
- The original full-run dt=0.01 Lyapunov field is invalid because of the RK4 stage-step bug; it must not be used as a convergence result. The corrected diagnostic passed `py_compile`, a one-seed quick run and a fresh full three-seed rerun. No full network Lyapunov spectrum, transverse exponent or network trajectory refinement was run.
- PoC 059 has no trained readout or AI-task benchmark; no task-level benefit is known.
- No claim-level freedom-to-operate analysis has been performed; the broad parent handoff retains patent-watch responsibility.
