# Cách cập nhật repository GitHub hiện tại

Repository tải xuống trước đó đặt `train.mat` và `test.mat` ở thư mục gốc, trong khi mã chính tìm trong `data/`. Vì vậy bản đó có thể báo lỗi không tìm thấy dữ liệu.

Cách an toàn nhất:

1. Sao lưu repository hiện tại nếu cần.
2. Xóa các file cũ trên repository GitHub (hoặc dùng GitHub Desktop để thay toàn bộ working tree).
3. Upload **nội dung bên trong** thư mục corrected này vào cấp gốc của repository, không upload thêm một thư mục bọc bên ngoài.
4. Kiểm tra trên GitHub phải thấy ngay ở cấp gốc: `README.md`, `run_Thuattoan3.m`, `hamtrangthai.m`, `data/`, `original/`, `results/`.
5. Trong MATLAB, clone/download repository và chạy `run_Thuattoan3`.
6. Sau khi chạy xong, chạy `verify_activation_zero`.
7. Nếu cần minh chứng trước Hội đồng, commit ba CSV trong `results/` và tạo tag/release `v1.0-defense`.
