# Hướng Dẫn Kết Nối Điện Thoại Android Cho Flutter Qua Wi-Fi (< 1 Phút)
> **Dành riêng cho Codex / AI Assistant / Developers**
> Thiết bị mục tiêu: Android 11+ (HyperOS / MIUI / OneUI / ColorOS / AOSP)  
> Workspace: `D:\NIVEX-FLUTTER`

---

## 1. TẠI SAO CODEX LÀM RẤT LÂU & RẮC RỐI? (POST-MORTEM)

Codex thường mất 30–45 phút và đi lòng vòng vì **4 sai lầm cốt tử**:

| Sai lầm của Codex | Sự thật kỹ thuật | Hậu quả |
| :--- | :--- | :--- |
| **1. Cố chấp kết nối cổng 5555** (`adb connect 192.168.1.x`) | Android 11+ dùng **Gỡ lỗi qua Wi-Fi gốc (Native Wireless Debugging)** với **cổng TLS ngẫu nhiên** (VD: `37711`, `39203`), mặc định KHÔNG mở cổng 5555. | Báo lỗi `10061: Connection refused`. |
| **2. Bắt cắm dây cáp USB** | Đây là tư duy của Android 10 cũ (`adb tcpip 5555` qua USB). Trên Android 11-15 hoàn toàn không cần cáp. | Làm phiền người dùng đi tìm cáp, mất bản chất "không dây". |
| **3. Lẫn lộn Cổng Ghép Nối (Pair Port) & Cổng Kết Nối (Connect Port)** | Màn hình ghép nối hiện mã 6 số + cổng ghép nối (chỉ dùng 1 lần để handshake key). Cổng kết nối nằm ở màn hình ngoài. | Codex lấy cổng này cắm vào lệnh kia gây timeout. |
| **4. Vòng lặp đoán mò & đổ lỗi** | Khi bị từ chối cổng 5555, Codex đoán: lỗi Firewall, lỗi Router AP isolation, lỗi driver ADB... | Bắt user cấu hình linh tinh mà không sửa đúng nguyên nhân. |

---

## 2. QUY TRÌNH CHUẨN CỦA ANTIGRAVITY (CHỈ CẦN ĐỊA CHỈ IP)

### Bản chất kỹ thuật:
1. **Thiết bị đã ghép nối từ trước**: Máy tính đã lưu khóa public key trong `~/.android/adbkey.pub`. Điện thoại đã thêm máy tính vào danh sách tin cậy. **Không cần pair lại lần 2**.
2. **Chiêu thức ghim cổng 5555 qua Wi-Fi (The Master Move)**:
   - Khi kết nối được vào cổng động (ví dụ `37711`), chạy ngay:
     ```bash
     adb -s 192.168.1.11:37711 tcpip 5555
     ```
   - Lệnh này kích hoạt daemon ADB trên điện thoại mở vĩnh viễn cổng `5555` qua chính phiên Wi-Fi đó mà **KHÔNG CẦN CẮM DÂY**.
   - Kể từ giây đó, bất kỳ ai gõ `adb connect 192.168.1.11` (không cần port) đều kết nối thành công 100%!

---

## 3. HƯỚNG DẪN 1-CLICK DÀNH CHO CODEX

Trong thư mục `D:\NIVEX-FLUTTER` đã có sẵn công cụ tự động hóa:

### Cách 1 (Khuyên dùng nhất - 3 giây):
Codex chỉ cần chạy lệnh sau trong terminal:
```cmd
.\connect-phone.cmd 192.168.1.11
```
*(Script sẽ tự kiểm tra cổng 5555, nếu chưa mở sẽ tự quét tìm cổng động Android 11+, kết nối và ghim lại cổng 5555, sau đó verify bằng `flutter devices`).*

### Cách 2 (Lệnh thủ công khi người dùng gửi `IP:PORT`):
Nếu người dùng báo: `192.168.1.11:37711`:
```bash
# Bước 1: Kết nối cổng động
adb connect 192.168.1.11:37711

# Bước 2: Ghim về cổng 5555 để lần sau không cần hỏi port nữa
adb -s 192.168.1.11:37711 tcpip 5555

# Bước 3: Kết nối cổng chuẩn 5555
adb connect 192.168.1.11:5555

# Bước 4: Kiểm tra Flutter
flutter devices
```

### Cách 3 (Lần đầu tiên ghép nối trên mạng Wi-Fi mới):
Chỉ làm khi chưa từng kết nối máy tính này với điện thoại bao giờ:
1. Mở Cài đặt cho nhà phát triển -> Gỡ lỗi qua Wi-Fi -> Ghép nối thiết bị bằng mã ghép nối.
2. Nhìn thấy: `IP:PAIR_PORT` (VD: `192.168.1.11:42135`) và Mã 6 số (VD: `849201`).
3. Chạy:
   ```bash
   adb pair 192.168.1.11:42135
   # Nhập mã 849201
   ```
4. Quay lại màn hình ngoài, lấy `CONNECT_PORT` (VD: `37711`) và chạy:
   ```bash
   adb connect 192.168.1.11:37711
   adb -s 192.168.1.11:37711 tcpip 5555
   ```

---

## 4. QUY TẮC PHỤC HỒI KHI BỊ MẤT KẾT NỐI (RECONNECTION)
Nếu điện thoại bị tắt màn hình lâu dẫn đến rớt kết nối (`offline` hoặc `connection terminated`):
1. Nhắc người dùng: Bật sáng màn hình điện thoại, gạt tắt rồi bật lại công tắc "Gỡ lỗi qua Wi-Fi".
2. Chạy lại:
   ```cmd
   .\connect-phone.cmd 192.168.1.11
   ```
3. Chạy Flutter:
   ```bash
   flutter run -d 192.168.1.11:5555
   ```
