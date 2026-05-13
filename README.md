# PhamMinhTai_IT202_Session11_bai1

# BÁO CÁO PHÂN TÍCH HỆ THỐNG

## Bài 1 - Sự cố Hủy lịch khám

---

# 1. Mô tả bài toán

Tại hệ thống Phòng khám đa khoa, nhân viên tiếp tân sử dụng chức năng **Hủy lịch hẹn** khi bệnh nhân gọi điện báo không thể đến khám.

Theo quy tắc nghiệp vụ của hệ thống:

* Chỉ các lịch khám đang ở trạng thái `Pending` mới được phép hủy.
* Các lịch đã `Completed` hoặc đã `Cancelled` không được thay đổi trạng thái.

Tuy nhiên, hệ thống hiện tại tồn tại lỗi logic khiến lịch khám đã hoàn tất vẫn có thể bị hủy.

Điều này gây:

* Sai lệch dữ liệu khám bệnh
* Ảnh hưởng đối soát kế toán
* Mất tính toàn vẹn dữ liệu
* Sai báo cáo thống kê vận hành

---

# 2. Phân tích nguyên nhân lỗi

## 2.1 Stored Procedure hiện tại

```sql
DELIMITER //

CREATE PROCEDURE CancelAppointment(IN p_appointment_id INT)
BEGIN

    UPDATE Appointments
    SET status = 'Cancelled'
    WHERE appointment_id = p_appointment_id;

END //

DELIMITER ;
```

---

## 2.2 Vấn đề logic

Procedure trên chỉ kiểm tra:

```sql
WHERE appointment_id = p_appointment_id
```

Mà không kiểm tra trạng thái hiện tại của lịch khám.

Kết quả:

* `Pending` → vẫn hủy được (đúng)
* `Completed` → cũng bị hủy (sai)
* `Cancelled` → tiếp tục cập nhật lại (không cần thiết)

---

# 3. Tái hiện lỗi hệ thống

## 3.1 Dữ liệu mẫu

```sql
SELECT *
FROM Appointments;
```

| appointment_id | status    |
| -------------- | --------- |
| 104            | Pending   |
| 105            | Completed |
| 106            | Cancelled |

---

## 3.2 Gọi procedure gây lỗi

```sql
CALL CancelAppointment(105);
```

---

## 3.3 Kiểm tra kết quả

```sql
SELECT *
FROM Appointments
WHERE appointment_id = 105;
```

### Kết quả lỗi

| appointment_id | status    |
| -------------- | --------- |
| 105            | Cancelled |

Lịch khám đã hoàn tất bị đổi thành `Cancelled`.

---

# 4. Hướng xử lý

## 4.1 Ý tưởng sửa lỗi

Procedure cần bổ sung điều kiện:

```sql
AND status = 'Pending'
```

Mục tiêu:

* Chỉ cho phép hủy lịch đang chờ khám
* Bảo vệ dữ liệu đã hoàn tất
* Đảm bảo đúng nghiệp vụ

---

# 5. Xóa Procedure cũ

```sql
DROP PROCEDURE IF EXISTS CancelAppointment;
```

---

# 6. Procedure đã sửa logic

```sql
DELIMITER //

CREATE PROCEDURE CancelAppointment(IN p_appointment_id INT)
BEGIN

    UPDATE Appointments
    SET status = 'Cancelled'
    WHERE appointment_id = p_appointment_id
      AND status = 'Pending';

END //

DELIMITER ;
```

---

# 7. Giải thích phiên bản đã sửa

## Logic hoạt động

Procedure mới sẽ:

1. Tìm đúng lịch khám theo `appointment_id`
2. Kiểm tra trạng thái hiện tại
3. Chỉ cập nhật nếu trạng thái là `Pending`

Nếu lịch:

* `Completed` → không cập nhật
* `Cancelled` → không cập nhật

Điều này giúp hệ thống an toàn hơn và đúng quy tắc nghiệp vụ.

---

# 8. Kiểm thử hệ thống

## 8.1 Test hợp lệ

### Input

```sql
CALL CancelAppointment(104);
```

### Kết quả mong muốn

| appointment_id | status    |
| -------------- | --------- |
| 104            | Cancelled |

---

## 8.2 Test lịch Completed

### Input

```sql
CALL CancelAppointment(105);
```

### Kết quả mong muốn

| appointment_id | status    |
| -------------- | --------- |
| 105            | Completed |

Không bị thay đổi.

---

## 8.3 Test lịch đã Cancelled

### Input

```sql
CALL CancelAppointment(106);
```

### Kết quả mong muốn

| appointment_id | status    |
| -------------- | --------- |
| 106            | Cancelled |

Không thay đổi dữ liệu.

---

# 9. Kết luận

Lỗi của hệ thống không nằm ở cú pháp SQL mà nằm ở phần logic nghiệp vụ.

Nguyên nhân chính:

* Thiếu điều kiện kiểm tra trạng thái trước khi cập nhật.

Giải pháp:

* Bổ sung điều kiện `status = 'Pending'`.

Sau khi sửa:

* Hệ thống chỉ cho phép hủy lịch hợp lệ.
* Dữ liệu kế toán và thống kê được bảo vệ.
* Tránh sai lệch nghiệp vụ trong vận hành thực tế.

---

# 10. Tổng kết kỹ thuật

| Thành phần       | Nội dung                           |
| ---------------- | ---------------------------------- |
| Loại lỗi         | Logic Business Rule                |
| Mức độ ảnh hưởng | Cao                                |
| Nguyên nhân      | Thiếu điều kiện trạng thái         |
| Giải pháp        | Kiểm tra `status = 'Pending'`      |
| Kỹ thuật sử dụng | Stored Procedure + WHERE condition |
| Kết quả sau sửa  | Đảm bảo toàn vẹn dữ liệu           |
