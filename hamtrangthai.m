function [chi_t, J_prev, J_candidate, deltaJ_V] = hamtrangthai(U, W_candidate, W_prev, tolJ)
% HAMTRANGTHAI  Kiem tra bien kich hoat chi_t cua co che bao dam tinh giam.
%
%   [chi_t, J_prev, J_candidate, deltaJ_V] = ...
%       hamtrangthai(U, W_candidate, W_prev, tolJ)
%
% Dau vao
%   U           : ma tran phan chum hien tai, kich thuoc C x N.
%   W_candidate : W_candidate(i,j) = S(f_j, f_v_i_candidate).
%   W_prev      : W_prev(i,j)      = S(f_j, f_v_i_previous).
%                 O vong khoi tao, dat W_prev = [].
%   tolJ        : dung sai so hoc cho phep so sanh J, mac dinh 1e-12.
%
% Ham muc tieu
%   J(U,V) = sum_i sum_j U(i,j)^2 * [1 - S(f_j,f_v_i)]^2.
%
% Bien kich hoat
%   chi_t = 0  neu J(U,V_candidate) <= J(U,V_prev) + tolJ
%   chi_t = 1  neu J(U,V_candidate) >  J(U,V_prev) + tolJ
%
% Luu y
%   Ham nay CHI danh gia trang thai/kich hoat. Ham khong tu dong thay doi
%   V_candidate. Vi vay co the chen vao code goc de thong ke so lan kich
%   hoat ma khong lam thay doi quy dao cua thuat toan goc.
%
%   Neu chi_t = 0 tai moi vong lap, co che bao dam khong can can thiep;
%   khi do ket qua thuc nghiem cua code goc duoc bao toan (den sai so may).

    if nargin < 4 || isempty(tolJ)
        tolJ = 1e-12;
    end

    if ~isequal(size(U), size(W_candidate))
        error('hamtrangthai:SizeMismatch', ...
            'U va W_candidate phai co cung kich thuoc.');
    end

    % J(U, V_candidate)
    J_candidate = sum(sum((U.^2) .* (1 - W_candidate).^2));

    % Vong khoi tao: chua co V^(t-1) de so sanh.
    if isempty(W_prev)
        chi_t = 0;
        J_prev = NaN;
        deltaJ_V = NaN;
        return;
    end

    if ~isequal(size(U), size(W_prev))
        error('hamtrangthai:SizeMismatch', ...
            'U va W_prev phai co cung kich thuoc.');
    end

    % J(U, V_previous) duoc danh gia tren CUNG ma tran U hien tai.
    J_prev = sum(sum((U.^2) .* (1 - W_prev).^2));

    deltaJ_V = J_candidate - J_prev;

    % tolJ ngan kich hoat gia do sai so dau cham dong.
    chi_t = double(deltaJ_V > tolJ);
end
