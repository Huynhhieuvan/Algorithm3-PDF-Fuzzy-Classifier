clc; clear; tic;

%% --- 1. LOAD DU LIEU ---
% Chi thay doi cach tim duong dan file; KHONG thay doi thuat toan.
repo_dir = fileparts(mfilename('fullpath'));
addpath(repo_dir);
data_dir = fullfile(repo_dir, 'data');
result_dir = fullfile(repo_dir, 'results');
if ~exist(result_dir, 'dir'), mkdir(result_dir); end

train_file = fullfile(data_dir, 'train.mat');
test_file  = fullfile(data_dir, 'test.mat');

if exist(train_file, 'file') && exist(test_file, 'file')
    S1 = load(train_file); f1 = fields(S1); train = S1.(f1{1});
    S2 = load(test_file);  f2 = fields(S2); test_data = S2.(f2{1});
    data_all = [train; test_data];
else
    error(['Khong tim thay data/train.mat va data/test.mat. ', ...
           'Hay giu nguyen cau truc thu muc cua repository.']);
end

X = double(data_all(:, 1:end-1));
Y = data_all(:, end);

% Giu nguyen cach tao 10-fold cua code goc.
% KHONG chen rng(...) de tranh thay doi phan hoach thuc nghiem hien co.
K = 10;
cv = cvpartition(Y, 'KFold', K);

%% --- 2. KHOI TAO BIEN LUU KET QUA ---
fold_ACC  = zeros(K,1);
fold_Sens = zeros(K,1);
fold_Spec = zeros(K,1);
fold_AUC  = zeros(K,1);

% Bien thong ke co che trang thai/kich hoat chi_t.
fold_iter = zeros(K,1);
fold_activation_count = zeros(K,1);
fold_min_deltaJV = nan(K,1);
fold_max_deltaJV = nan(K,1);

% Log chi tiet tat ca cac vong lap.
Log_fold       = [];
Log_iter       = [];
Log_Jprev      = [];
Log_Jcandidate = [];
Log_deltaJV    = [];
Log_chi        = [];
Log_chuan      = [];

% Dung sai so hoc cho phep so sanh J.
tolJ = 1e-12;

%% --- 3. 10-FOLD ---
for fold = 1:K
    fprintf('Dang thuc thi Fold %d/%d...\n', fold, K);

    tr_idx = training(cv, fold);
    ts_idx = test(cv, fold);

    Z1 = X(tr_idx, :); L_train = Y(tr_idx);
    Z2 = X(ts_idx, :); L_test  = Y(ts_idx);
    C = max(L_train);

    %% --- THUAT TOAN 3: FCM CORE GOC ---
    U1 = zeros(C, size(Z1,1));
    for i = 1:size(Z1,1)
        U1(L_train(i), i) = 1;
    end

    V_train = cell(C,1);
    for c = 1:C
        V_train{c} = Z1(L_train == c, :);
    end

    fm = 2;
    Umoi = U1;
    chuan = 999;
    x_range = 0:0.01:1;
    max_iter = 50;
    iter = 0;

    % W_prev luu S(f_j, f_v_i) cua bo dai dien o vong truoc.
    % O vong dau chua co bo dai dien truoc de so sanh.
    W_prev = [];
    delta_list = [];

    while chuan > 0.001 && iter < max_iter
        U = Umoi;

        %% (A) CAP NHAT PDF DAI DIEN - GIU NGUYEN CONG THUC GOC
        u_m = U.^fm;
        u_m_sum = sum(u_m, 2) + eps;
        v_candidate = bsxfun(@rdivide, u_m * Z1, u_m_sum);

        %% (B) TINH MA TRAN TUONG TU - GIU NGUYEN THU TU TINH CUA CODE GOC
        W_candidate = zeros(C, size(Z1,1));
        for i = 1:size(Z1,1)
            for j = 1:C
                W_candidate(j,i) = ...
                    tuongtuchum([v_candidate(j,:)' Z1(i,:)'], x_range);
            end
        end

        %% (C) HAM TRANG THAI / BIEN KICH HOAT chi_t
        % chi_t = 0 neu cap nhat ung vien khong lam tang J.
        % chi_t = 1 neu J(U,V_candidate) > J(U,V_previous) + tolJ.
        [chi_t, J_prev, J_candidate, deltaJ_V] = ...
            hamtrangthai(U, W_candidate, W_prev, tolJ);

        if ~isnan(deltaJ_V)
            delta_list(end+1,1) = deltaJ_V; %#ok<SAGROW>
        end

        if chi_t == 1
            fprintf(['  *** HAM TRANG THAI KICH HOAT: fold=%d, ', ...
                     'loop=%d, DeltaJ_V=%.15g > %.3g ***\n'], ...
                     fold, iter+1, deltaJ_V, tolJ);
        end

        %% (D) BAO TOAN QUY DAO THUAT TOAN GOC
        % File nay la ban TICH HOP + GIAM SAT chi_t.
        % De dam bao ket qua thuc nghiem khong thay doi khi chi_t = 0,
        % ta chap nhan dung v_candidate va W_candidate nhu code goc.
        %
        % Neu chi_t = 1, file nay VAN giu quy dao goc de chan doan va ghi log.
        % Khi do KHONG duoc coi la da thuc hien buoc hieu chinh
        % argmin_{V in C^k} J(U,V) cua phien ban ly thuyet cap nhat.
        v = v_candidate;
        W = W_candidate;

        %% (E) CAP NHAT MA TRAN U - GIU NGUYEN CODE GOC
        for j = 1:size(U,2)
            if all(W(:,j) ~= 1)
                dist = (1 - W(:,j) + eps).^(2/(fm-1));
                for i = 1:C
                    Umoi(i,j) = 1 / sum(dist(i) ./ dist);
                end
            else
                idx = find(W(:,j) == 1);
                Umoi(:,j) = 0;
                Umoi(idx,j) = 1/length(idx);
            end
        end

        chuan = max(abs(Umoi(:) - U(:)));
        iter = iter + 1;

        %% (F) GHI LOG
        Log_fold(end+1,1)       = fold; %#ok<SAGROW>
        Log_iter(end+1,1)       = iter; %#ok<SAGROW>
        Log_Jprev(end+1,1)      = J_prev; %#ok<SAGROW>
        Log_Jcandidate(end+1,1) = J_candidate; %#ok<SAGROW>
        Log_deltaJV(end+1,1)    = deltaJ_V; %#ok<SAGROW>
        Log_chi(end+1,1)        = chi_t; %#ok<SAGROW>
        Log_chuan(end+1,1)      = chuan; %#ok<SAGROW>

        % W_candidate tro thanh W_prev cua vong tiep theo.
        W_prev = W_candidate;
    end

    fold_iter(fold) = iter;
    fold_activation_count(fold) = sum(Log_chi(Log_fold == fold));

    if ~isempty(delta_list)
        fold_min_deltaJV(fold) = min(delta_list);
        fold_max_deltaJV(fold) = max(delta_list);
    end

    %% --- 4. DU BAO VA TINH CHI SO - GIU NGUYEN CODE GOC ---
    W_test = zeros(C, size(Z2,1));
    W_SCC = zeros(C, size(Z2,1));

    for i = 1:size(Z2,1)
        for j = 1:C
            W_test(j,i) = tuongtuchum([v(j,:)' Z2(i,:)'], x_range);
            W_SCC(j,i)  = tuongtuchum([V_train{j}' Z2(i,:)'], x_range);
        end
    end

    PLmatrix = W_test .* W_SCC;
    [~, classes] = max(PLmatrix, [], 1);
    classes = classes';

    cm = confusionmat(L_test, classes);
    if size(cm,1) >= 2
        tp = cm(1,1);
        fn = sum(cm(1,2:end));
        fp = sum(cm(2:end,1));
        tn = sum(sum(cm(2:end,2:end)));

        fold_ACC(fold)  = (tp+tn)/sum(cm(:));
        fold_Sens(fold) = tp/(tp+fn+eps);
        fold_Spec(fold) = tn/(tn+fp+eps);

        try
            [~,~,~,fold_AUC(fold)] = ...
                perfcurve(L_test, PLmatrix(1,:), 1);
        catch
            fold_AUC(fold) = 0.5;
        end
    end
end

%% --- 5. THONG KE SO LAN KICH HOAT ---
ActivationTable = table((1:K)', fold_iter, fold_activation_count, ...
    fold_min_deltaJV, fold_max_deltaJV, ...
    'VariableNames', {'Fold','Iterations','ActivationCount', ...
                      'MinDeltaJ_V','MaxDeltaJ_V'});

disp('===== THONG KE HAM TRANG THAI chi_t =====');
disp(ActivationTable);

TotalActivation = sum(fold_activation_count);
TotalIterations = sum(fold_iter);
ActivationRate = TotalActivation / max(TotalIterations,1);

fprintf('Tong so lan chi_t = 1: %d\n', TotalActivation);
fprintf('Tong so vong lap:  %d\n', TotalIterations);
fprintf('Ty le kich hoat:   %.8f\n', ActivationRate);

if TotalActivation == 0
    fprintf(['KET LUAN: chi_t = 0 tai tat ca cac vong lap. ', ...
             'Ham trang thai khong can can thiep; quy dao cap nhat ', ...
             'va ket qua thuc nghiem trung voi code goc ', ...
             '(den sai so may).\n']);
else
    fprintf(['CAN LUU Y: Phat hien %d lan chi_t = 1. ', ...
             'File nay dang o che do GIAM SAT nen van giu quy dao goc. ', ...
             'Can cai dat rieng buoc hieu chinh ', ...
             'V in argmin_{V in C^k} J(U,V) neu muon chay ', ...
             'day du phien ban safeguard cua luan an.\n'], ...
             TotalActivation);
end

%% --- 6. TONG HOP KET QUA PHAN LOAI ---
Method = {'Thuat toan 3 + ham trang thai (monitor)'};
ACC_Final  = mean(fold_ACC) * 100;
ACC_Std    = std(fold_ACC) * 100;
Sens_Final = mean(fold_Sens);
Spec_Final = mean(fold_Spec);
AUC_Final  = mean(fold_AUC);
AUC_Std    = std(fold_AUC);

SummaryTable = table(Method, ACC_Final, ACC_Std, Sens_Final, ...
    Spec_Final, AUC_Final, AUC_Std, ...
    'VariableNames', {'Method','ACC_Avg','ACC_Std','Sensitivity', ...
                      'Specificity','AUC_Avg','AUC_Std'});

fprintf('\n===== KET QUA KIEM DINH TINH ON DINH (10-FOLD) =====\n');
disp(SummaryTable);

%% --- 7. LUU KET QUA ---
ActivationLog = table(Log_fold, Log_iter, Log_Jprev, Log_Jcandidate, ...
    Log_deltaJV, Log_chi, Log_chuan, ...
    'VariableNames', {'Fold','Iter','J_PreviousV','J_CandidateV', ...
                      'DeltaJ_V','Chi_t','DeltaU'});

writetable(SummaryTable,   fullfile(result_dir,'KetQua_VNU_10Fold_HamTrangThai.csv'));
writetable(ActivationTable,fullfile(result_dir,'HamTrangThai_Summary.csv'));
writetable(ActivationLog,  fullfile(result_dir,'HamTrangThai_Log.csv'));

fprintf('Da luu cac bang ket qua va log ham trang thai.\n');
toc;
