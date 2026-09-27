# Manifest

- `run_Thuattoan3.m`: canonical entry point; runs repository self-check, sets a fixed RNG seed, and starts the experiment.
- `selfcheck_repository.m`: checks required files and MATLAB functions before execution.
- `K10_Fold_Thuattoan3_HamTrangThai.m`: 10-fold experiment with `chi_t` monitoring and CSV logs.
- `hamtrangthai.m`: computes `J_prev`, `J_candidate`, `DeltaJ_V`, and `chi_t` without changing the candidate representative.
- `tuongtuchum.m`: original cluster-similarity routine.
- `verify_activation_zero.m`: summarizes the number and rate of `chi_t=1` events after a run.
- `data/train.mat`, `data/test.mat`: input data supplied for the experiment.
- `original/K10_Fold_Thuattoan3_original.m`: original MATLAB script supplied by the researcher for comparison.
- `results/`: generated evidence tables; initially contains only `.gitkeep`.
