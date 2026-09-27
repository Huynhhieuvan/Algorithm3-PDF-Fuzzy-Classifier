%% RUN_THUATTOAN3 - diem chay duy nhat cua repository
% Chay file nay de tai lap thuc nghiem 10-fold va theo doi chi_t.

clc;
repo_dir = fileparts(mfilename('fullpath'));
addpath(repo_dir);

% Kiem tra nhanh cau truc repository.
run(fullfile(repo_dir, 'selfcheck_repository.m'));

% Seed co dinh de phep chia 10-fold co the tai lap.
% Lenh clear trong script chinh khong reset trang thai RNG.
rng(20260927, 'twister');

run(fullfile(repo_dir, 'K10_Fold_Thuattoan3_HamTrangThai.m'));
