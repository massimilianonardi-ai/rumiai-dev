# Analog noise, synchronization and chaotic-neuron experiments

Status: Active
Updated: 2026-10-08

## Goal

Determine through reproducible open-source simulation whether nonlinear/chaotic neuron dynamics or synchronization can improve useful computation under realistic analog noise and component mismatch, while preserving enough state diversity for a reservoir. Use BrainScaleS-2 as an architectural reference for mixed-signal dynamics plus digital calibration/control/plasticity, not as evidence that chaos is superior.

This is an experimental workstream only. It does not alter RumiAI architecture or justify physical construction until a bounded result survives matched baselines and uncertainty tests.

## Current repository revisions

```text
rumiai-dev      d4fd11cabce7c659641153738380c11847502c6b
rumiai-dev-PoCs 394e8d5831e63be7e529db617c3c49328da9bbcd (PoC 058 merged into main)
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

1. Start in software simulation on Linux with open-source tools; do not build hardware or integrate into RumiAI runtime on the basis of the current evidence.
2. Treat chaos, synchronization and neuronal spiking as candidate mechanisms, not assumptions or goals.
3. Separate independent per-unit process noise, shared/common-mode disturbances, observation/readout noise, fixed component mismatch and slow drift. A result for one channel must not be generalized to the others.
4. Compare synchronized and unsynchronized regimes across a coupling sweep. Measure task performance and state diversity together; excessive synchronization can erase useful reservoir dimensions.
5. Use a matched input stream, task, readout and tuning budget, with a simple delayed-input baseline and a digital recurrent/reservoir baseline. Keep test data out of tuning.
6. A “chaotic” regime must be verified by a dynamical diagnostic such as a positive largest Lyapunov exponent; irregular/noisy activity alone does not establish deterministic chaos.
7. Borrow BrainScaleS-2 ideas selectively: continuous-time analog states with digital parameter calibration, measurement, control and learning. Do not imply access to or reproduction of BrainScaleS-2 hardware.

## Working design

### Experimental question

Under a bounded temporal/nonlinear task, do neuronal or oscillator reservoirs in a verified chaotic regime, with tunable diffusive coupling, improve held-out robustness to specific noise and mismatch channels relative to regular dynamics—without collapsing effective rank or memory?

### Candidate comparison

- Regular versus chaotic/bursting regimes of one neuron-family model, once a primary source and reproducible parameter ranges are verified.
- Uncoupled, weakly coupled, intermediate and strongly coupled populations.
- If a suitable neuron model does not give a controllable synchronization benchmark, first validate the coupling/noise instrumentation on a canonical chaotic oscillator, then test a neuron model separately.
- Frozen readout versus calibration/re-fit and noise-aware training are distinct conditions.

### Measurements and gates

Report held-out task NMSE and temporal-memory scores, population synchronization error, effective rank/state covariance, parameter sensitivity, and chaos diagnostics. Use multiple seeds. A candidate advances only if the advantage survives matched baselines, uncertainty bands and independent versus common-mode/readout perturbations. Any parameter sweep and selection rule must be fixed from training/validation data before test evaluation.

## Completed

- PoC 058 was merged into `rumiai-dev-PoCs/main` on 2026-10-08 (merge commit `394e8d5831e63be7e529db617c3c49328da9bbcd`). It provides an electrical/optoelectronic reservoir baseline but contains no chaotic neuron or synchronization experiment.
- Read its report and source. Current evidence is simulation-only: diode features help the square task, physical candidates do not beat the simple delayed digital temporal baseline, and frozen-readout sensitivity is high. The 1% feature perturbation and ±5% component probes are not a complete model of circuit noise.
- Reviewed primary descriptions of BrainScaleS-2's analog/digital partition and research on synchronization under noise. These motivate channel-specific tests, not a conclusion that synchronization removes noise.

## Current state

The dedicated research/experiment lifecycle is now separate from the broad chaos/control and patent-watch handoff. No chaotic-neuron simulation has yet been run. PoC 058 results must remain labeled as its own revision-specific evidence.

## Next action

Create a preregistered PoC 059 in `rumiai-dev-dev-PoCs`: select and cite a model/parameterization, define the task and matched baselines, implement independent/common/readout noise plus mismatch probes, and run the minimal coupling/regime matrix. Record raw and summarized results in a new PoC session and update this handoff at each material checkpoint.

## Blockers / open questions

- Select a neuron-family model and operating regimes from primary sources; verify that the proposed chaotic regime is reproducible before using it in the comparison.
- Fix normalization and noise amplitudes in physical/model terms before testing; PoC 058's feature-jitter percentage is not a circuit-noise calibration.
- Determine which realistic measurement/readout and component models are feasible in the first bounded simulation.
