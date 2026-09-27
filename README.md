# Thuật toán 3 – phân loại PDF với hàm trạng thái / cơ chế giám sát

Repository này đóng gói mã MATLAB dùng để tái lập thí nghiệm 10-fold của Thuật toán 3 và theo dõi biến kích hoạt `chi_t` của cơ chế bảo đảm tính giảm.

## 1. Cấu trúc

```text
Thuattoan3_GitHub_Ready/
├── K10_Fold_Thuattoan3_HamTrangThai.m   # mã chính đã tích hợp giám sát
├── hamtrangthai.m                       # tính J_prev, J_candidate, DeltaJ_V, chi_t
├── tuongtuchum.m                        # hệ số tương tự chùm
├── run_Thuattoan3.m                     # file nên chạy
├── verify_activation_zero.m             # kiểm tra số lần chi_t = 1
├── data/
│   ├── train.mat
│   └── test.mat
├── original/
│   └── K10_Fold_Thuattoan3_original.m   # mã gốc do NCS cung cấp
└── results/                              # CSV sinh ra sau khi chạy
```

## 2. Yêu cầu MATLAB

- MATLAB có `cvpartition`, `confusionmat`, `perfcurve` (Statistics and Machine Learning Toolbox).
- Không cần Optimization Toolbox cho bản **monitor** hiện tại.

## 3. Cách chạy

1. Clone/download toàn bộ repository.
2. Mở MATLAB.
3. Chạy:

```matlab
run_Thuattoan3
```

File này đặt seed cố định `rng(20260927,'twister')` để phép chia 10-fold có thể tái lập.

Sau đó chạy:

```matlab
verify_activation_zero
```

## 4. Các file kết quả

Sau khi chạy, thư mục `results/` có:

- `KetQua_VNU_10Fold_HamTrangThai.csv`: ACC, độ lệch chuẩn ACC, Sensitivity, Specificity, AUC.
- `HamTrangThai_Summary.csv`: số vòng lặp và số lần kích hoạt theo từng fold.
- `HamTrangThai_Log.csv`: log từng vòng lặp (`J_PreviousV`, `J_CandidateV`, `DeltaJ_V`, `Chi_t`, `DeltaU`).

## 5. Định nghĩa biến kích hoạt

Với `U` cố định tại vòng lặp đang xét:

```text
J_candidate = J(U, V_candidate)
J_prev      = J(U, V_previous)
DeltaJ_V    = J_candidate - J_prev
```

và

```text
chi_t = 0  nếu DeltaJ_V <= 1e-12
chi_t = 1  nếu DeltaJ_V >  1e-12.
```

Dung sai `1e-12` dùng để tránh kích hoạt giả do sai số dấu chấm động.

## 6. Bảo toàn kết quả của mã gốc

Bản hiện tại là **monitor**: `hamtrangthai.m` chỉ đo và ghi nhận trạng thái; nó không thay đổi `v_candidate`, `W_candidate`, công thức cập nhật `U` hay phần dự báo. Vì vậy, với cùng một phân hoạch cross-validation, đường tính toán phân loại của bản monitor giữ nguyên như mã gốc.

Đặc biệt, nếu `chi_t = 0` tại mọi vòng lặp, cơ chế bảo đảm không cần can thiệp, đúng với trường hợp bảo toàn thuật toán ban đầu trong phần lý thuyết cập nhật.

Nếu xuất hiện `chi_t = 1`, bản monitor chỉ ghi log và vẫn giữ quỹ đạo gốc. Khi đó muốn thực thi đầy đủ nhánh lý thuyết cần cài đặt bộ giải cho bài toán

```text
V^(t) in argmin_{V in C^k} J(U^(t),V).
```

Không nên tuyên bố bản monitor đã thực hiện nhánh `argmin` khi `chi_t = 1`.

## 7. Minh chứng khi bảo vệ

Có thể trình bày trực tiếp:

1. Git commit/tag của phiên bản đã dùng.
2. `HamTrangThai_Summary.csv` để cho thấy số lần kích hoạt ở từng fold.
3. `HamTrangThai_Log.csv` để kiểm tra từng vòng lặp.
4. Mã `hamtrangthai.m` để đối chiếu định nghĩa `chi_t` với luận án.

Nên tạo một GitHub Release (ví dụ `v1.0-defense`) và không sửa release đó sau khi đã dùng trong hồ sơ bảo vệ.

## 8. Dữ liệu

Hai file `data/train.mat` và `data/test.mat` được đóng gói để chạy lại mã. Trước khi công khai repository, NCS cần bảo đảm có quyền công bố/redistribute bộ dữ liệu hoặc các đặc trưng đã trích xuất. Nếu không, hãy bỏ hai file này khỏi repository công khai và ghi rõ nguồn/cách tạo dữ liệu.
