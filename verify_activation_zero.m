%% VERIFY_ACTIVATION_ZERO
% Chay sau run_Thuattoan3.m de kiem tra tong so lan chi_t = 1.

repo_dir = fileparts(mfilename('fullpath'));
summary_file = fullfile(repo_dir, 'results', 'HamTrangThai_Summary.csv');

if ~exist(summary_file, 'file')
    error(['Chua co HamTrangThai_Summary.csv. ', ...
           'Hay chay run_Thuattoan3.m truoc.']);
end

T = readtable(summary_file);
TotalActivation = sum(T.ActivationCount);
TotalIterations = sum(T.Iterations);
ActivationRate = TotalActivation / max(TotalIterations,1);

fprintf('\n===== XAC MINH CO CHE KICH HOAT =====\n');
fprintf('Tong so vong lap      : %d\n', TotalIterations);
fprintf('Tong so lan chi_t = 1 : %d\n', TotalActivation);
fprintf('Ty le kich hoat       : %.8f\n', ActivationRate);

if TotalActivation == 0
    fprintf('PASS: Khong co lan nao co che bao dam can kich hoat.\n');
else
    fprintf('NOTICE: Co %d lan chi_t = 1; xem results/HamTrangThai_Log.csv.\n', ...
            TotalActivation);
end
