%% SELFCHECK_REPOSITORY - kiem tra bo ma truoc khi chay
clc;
repo_dir = fileparts(mfilename('fullpath'));

required_files = {
    'K10_Fold_Thuattoan3_HamTrangThai.m'
    'hamtrangthai.m'
    'tuongtuchum.m'
    'run_Thuattoan3.m'
    'verify_activation_zero.m'
    fullfile('data','train.mat')
    fullfile('data','test.mat')
    };

fprintf('===== KIEM TRA REPOSITORY =====\n');
all_ok = true;
for i = 1:numel(required_files)
    p = fullfile(repo_dir, required_files{i});
    if exist(p, 'file')
        fprintf('[OK]      %s\n', required_files{i});
    else
        fprintf('[MISSING] %s\n', required_files{i});
        all_ok = false;
    end
end

% Kiem tra cac ham MATLAB/Toolbox can cho chuong trinh chinh.
needed_functions = {'cvpartition','confusionmat','perfcurve'};
for i = 1:numel(needed_functions)
    if exist(needed_functions{i}, 'file') || exist(needed_functions{i}, 'builtin')
        fprintf('[OK]      MATLAB function: %s\n', needed_functions{i});
    else
        fprintf('[WARNING] Khong tim thay MATLAB function: %s\n', needed_functions{i});
    end
end

if all_ok
    fprintf('\nPASS: Cau truc repository day du. Co the chay run_Thuattoan3.m\n');
else
    error('Repository chua du file. Hay sua cac muc [MISSING] truoc khi chay.');
end
