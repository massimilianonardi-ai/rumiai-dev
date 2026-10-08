# Analog noise, synchronization and chaotic-neuron experiments

Status: Active
Updated: 2026-10-08

## Goal

Determine through reproducible open-source simulation whether nonlinear/chaotic neuron dynamics or synchronization can improve useful computation under realistic analog noise and component mismatch, while preserving enough state diversity for a reservoir. Use BrainScaleS-2 as an architectural reference for mixed-signal dynamics plus digital calibration/control/plasticity, not as evidence that chaos is superior.

This is an experimental workstream only. It does not alter RumiAI architecture or justify physical construction until a bounded result survives matched baselines and uncertainty tests.

## Current repository revisions

```text
rumiai-dev      a18e845f49c0399ae7e79d395d9d2f76e66aa300
rumiai-dev-PoCs 394e8d5831e63be7e529db617c3c49328da9bbcd (main; PoC 058 merge)
rumiai-dev-PoCs 1530d3646b75099c4d9b10854a8679e4dc2a07d9 (poc/059-chaotic-neuron-noise-screening)
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
- Isolated-cell finite-time largest-Lyapunov estimates were positive at both step sizes: 0.01879 at dt=0.02 and 0.02397 at dt=0.01 per model time unit.
- At k=0.5, independent process noise reduced normalized pair disagreement to 0.480 ± 0.024 from 0.777 ± 0.025 at k=0, but increased total trajectory shift to 1.312 ± 0.096 from 1.059 ± 0.035. Clean effective rank fell to 2.24 ± 0.21 from 3.63 ± 0.47. Under common-mode noise at k=0.5, collective shift was 1.075 ± 0.238.
- This supports only a limited mechanism-level conclusion: coupling can reduce relative disagreement while the collective trajectory remains noisy or diverges from its clean counterpart, and stronger coupling can reduce state diversity. No AI utility, physical noise tolerance, hardware performance, energy or speed advantage is established.
- The GitHub Actions workflow is included in PR 2, but hosted workflow execution is not yet verified. Local Linux execution is the validated run.

## Current state

PR 2 remains draft. PoC 059 is exploratory rather than preregistered; its fixed protocol and revision-specific evidence are recorded in the PoC. This first screen had no readout or task metric. PoC 058 remains the task-level electrical/optoelectronic benchmark and is on main.

## Next action

Verify the hosted Linux workflow for PR 2 and correct any failure. Then preregister a separate task-level experiment before evaluating AI usefulness: compare regular and verified chaotic neuron regimes over a selected coupling range, include matched non-chaotic and digital baselines, separate noise/mismatch channels, and measure task performance alongside synchrony and state diversity. Do not select thresholds using test outcomes.

## Blockers / open questions

- The state kicks and current perturbation are model-level probes, not calibrated physical noise or component models.
- The isolated-cell finite-time Lyapunov estimate is positive at two step sizes, but no full network Lyapunov spectrum, transverse exponent or network trajectory refinement was run.
- PoC 059 has no trained readout or AI-task benchmark; no task-level benefit is known.
- No claim-level freedom-to-operate analysis has been performed; the broad parent handoff retains patent-watch responsibility.
