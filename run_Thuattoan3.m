%% RUN_THUATTOAN3 - diem chay duy nhat cho repository
% Chay file nay tu bat ky thu muc nao.
% De tai lap cung mot phep chia 10-fold, dung seed co dinh ben duoi.

clc;
repo_dir = fileparts(mfilename('fullpath'));
addpath(repo_dir);

% Seed chi co tac dung lam cho 10-fold tai lap duoc.
% Khong thay doi cong thuc cua Thuat toan 3.
rng(20260927, 'twister');

run(fullfile(repo_dir, 'K10_Fold_Thuattoan3_HamTrangThai.m'));
