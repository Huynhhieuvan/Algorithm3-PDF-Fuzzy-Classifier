# Algorithm 3 – PDF Fuzzy Classifier with activation-state monitoring

MATLAB code used to reproduce the 10-fold experiment of Algorithm 3 and to monitor the activation variable `chi_t` associated with the descent safeguard.

## Repository structure

```text
Algorithm3-PDF-Fuzzy-Classifier/
├── README.md
├── MANIFEST.md
├── run_Thuattoan3.m
├── selfcheck_repository.m
├── K10_Fold_Thuattoan3_HamTrangThai.m
├── hamtrangthai.m
├── tuongtuchum.m
├── verify_activation_zero.m
├── data/
│   ├── train.mat
│   └── test.mat
├── original/
│   └── K10_Fold_Thuattoan3_original.m
└── results/
    └── .gitkeep
```

## MATLAB requirements

The experiment uses `cvpartition`, `confusionmat`, and `perfcurve` from MATLAB's Statistics and Machine Learning Toolbox.

## How to run

Open MATLAB, set the repository as the current folder, and run:

```matlab
run_Thuattoan3
```

The entry script first runs `selfcheck_repository.m`, fixes the random seed with

```matlab
rng(20260927,'twister')
```

and then runs the 10-fold experiment.

After the experiment, run:

```matlab
verify_activation_zero
```

## Objective and activation variable

For fixed `U`, the monitor computes

```text
J_candidate = J(U,V_candidate)
J_prev      = J(U,V_previous)
DeltaJ_V    = J_candidate - J_prev
```

with

```text
J(U,V) = sum_i sum_j U(i,j)^2 [1-S(f_j,f_vi)]^2.
```

The numerical monitor uses

```text
chi_t = 0  if DeltaJ_V <= tolJ
chi_t = 1  if DeltaJ_V >  tolJ,
```

where `tolJ = 1e-12` prevents activation caused only by floating-point noise.

## Important scope of this repository

This version is a **monitoring implementation**. `hamtrangthai.m` evaluates the safeguard condition and logs `chi_t`; it does not replace `V_candidate` when `chi_t=1`. Therefore the original numerical trajectory is preserved.

If `chi_t=0` for every monitored iteration, the safeguard does not need to intervene, and the monitored implementation follows the original update trajectory (up to machine precision).

If `chi_t=1` occurs, the code reports and logs it but does **not** claim to have solved the corrective subproblem

```text
V^(t) in argmin_{V in C^k} J(U^(t),V).
```

A separate numerical optimizer would be required to implement that branch fully.

## Output files

After running, `results/` contains:

- `KetQua_VNU_10Fold_HamTrangThai.csv`
- `HamTrangThai_Summary.csv`
- `HamTrangThai_Log.csv`

The detailed log contains `Fold`, `Iter`, `J_PreviousV`, `J_CandidateV`, `DeltaJ_V`, `Chi_t`, and `DeltaU`.

## Reproducibility for the dissertation defense

For a fixed public version used in the defense, create a GitHub tag/release such as `v1.0-defense`. Keep the generated CSV evidence in `results/` if redistribution is permitted.

## Data note

Before keeping `data/train.mat` and `data/test.mat` in a public repository, verify that redistribution is permitted. If not, remove the data files and provide a public source or reconstruction instructions instead.
