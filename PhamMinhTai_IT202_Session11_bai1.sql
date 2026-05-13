-- =========================================
-- KHỞI TẠO DATABASE
-- =========================================

CREATE DATABASE RikkeiClinicDB;
USE RikkeiClinicDB;

-- =========================================
-- PHẦN 1: TẠO BẢNG
-- =========================================

-- 1. Bệnh nhân
CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    date_of_birth DATE
);

-- 2. Nhân sự
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(18,2) NOT NULL
);

-- 3. Khoa
CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL
);

-- 4. Giường bệnh
CREATE TABLE Beds (
    bed_id INT PRIMARY KEY,
    dept_id INT NOT NULL,
    patient_id INT DEFAULT NULL,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

-- 5. Lịch khám
CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Employees(employee_id)
);

-- 6. Kho vật tư
CREATE TABLE Inventory (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0
);

-- 7. Thuốc
CREATE TABLE Medicines (
    medicine_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0
);

-- 8. Công nợ
CREATE TABLE Patient_Invoices (
    patient_id INT PRIMARY KEY,
    total_due DECIMAL(18,2) NOT NULL DEFAULT 0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

-- 9. Sản phẩm
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0
);

-- 10. Dịch vụ
CREATE TABLE Services (
    service_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(18,2) NOT NULL
);

-- 11. Ví điện tử
CREATE TABLE Wallets (
    patient_id INT PRIMARY KEY,
    balance DECIMAL(18,2) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

-- 12. Lịch sử sử dụng dịch vụ
CREATE TABLE Service_Usages (
    usage_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    service_id INT NOT NULL,
    actual_price DECIMAL(18,2) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (service_id) REFERENCES Services(service_id)
);

-- =========================================
-- PHẦN 2: DỮ LIỆU MẪU
-- =========================================

-- Patients
INSERT INTO Patients (patient_id, full_name, phone, date_of_birth) VALUES
(1, 'Nguyen Van An', '0901111222', '1990-05-15'),
(2, 'Tran Thi Binh', '0912222333', '1985-08-20'),
(3, 'Le Hoang Cuong', '0923333444', '2000-12-01');

-- Employees
INSERT INTO Employees (employee_id, full_name, position, salary) VALUES
(101, 'Dr. Hoang Minh', 'Doctor', 20000.00),
(102, 'Dr. Lan Anh', 'Doctor', 25000.00),
(103, 'Nurse Thu Ha', 'Nurse', 12000.00);

-- Departments
INSERT INTO Departments (dept_id, dept_name) VALUES
(1, 'Khoa Ngoai'),
(2, 'Khoa Noi'),
(3, 'Khoa ICU');

-- Beds
INSERT INTO Beds (bed_id, dept_id, patient_id) VALUES
(101, 1, 1),
(201, 2, NULL),
(301, 3, 2);

-- Appointments
INSERT INTO Appointments (appointment_id, patient_id, doctor_id, appointment_date, status) VALUES
(104, 1, 101, '2026-06-10 08:30:00', 'Pending'),
(105, 2, 102, '2026-05-01 09:00:00', 'Completed'),
(106, 3, 101, '2026-05-02 10:00:00', 'Cancelled');

-- Inventory
INSERT INTO Inventory (item_id, item_name, stock_quantity) VALUES
(10, 'Khau trang y te N95', 1000),
(11, 'Gang tay vo trung', 500),
(12, 'Dung dich sat khuan', 200);

-- Medicines
INSERT INTO Medicines (medicine_id, name, price, stock) VALUES
(1, 'Amoxicillin 500mg', 15000, 100),
(2, 'Panadol Extra', 5000, 5);

-- Patient Invoices
INSERT INTO Patient_Invoices (patient_id, total_due) VALUES
(1, 1500000.00),
(2, 0),
(3, 0);

-- Products
INSERT INTO Products (name, price, stock) VALUES
('May do huyet ap Omron', 850000.00, 20),
('May do duong huyet', 450000.00, 15);

-- Services
INSERT INTO Services (service_id, name, price) VALUES
(1, 'Sieu am o bung', 200000.00),
(2, 'Xet nghiem mau', 150000.00),
(3, 'Chup X-Quang', 250000.00);

-- Wallets
INSERT INTO Wallets (patient_id, balance, status) VALUES
(1, 500000.00, 'Active'),
(2, 50000.00, 'Active'),
(3, 1000000.00, 'Inactive');

-- =========================================
-- PHẦN 3: STORED PROCEDURE BỊ LỖI
-- =========================================

DELIMITER //

CREATE PROCEDURE CancelAppointment(IN p_appointment_id INT)
BEGIN

    UPDATE Appointments
    SET status = 'Cancelled'
    WHERE appointment_id = p_appointment_id;

END //

DELIMITER ;

-- =========================================
-- PHẦN 4: TÁI HIỆN LỖI
-- =========================================

-- Lịch 105 đã Completed nhưng vẫn bị hủy

CALL CancelAppointment(105);

SELECT *
FROM Appointments
WHERE appointment_id = 105;

-- =========================================
-- GIẢI THÍCH LỖI
-- =========================================

-- Procedure không kiểm tra trạng thái hiện tại.
-- Vì thiếu điều kiện status = 'Pending'
-- nên mọi lịch khám đều bị cập nhật thành Cancelled.

-- =========================================
-- PHẦN 5: XÓA PROCEDURE BỊ LỖI
-- =========================================

DROP PROCEDURE IF EXISTS CancelAppointment;

-- =========================================
-- PHẦN 6: TẠO LẠI PROCEDURE ĐÚNG
-- =========================================

DELIMITER //

CREATE PROCEDURE CancelAppointment(IN p_appointment_id INT)
BEGIN

    UPDATE Appointments
    SET status = 'Cancelled'
    WHERE appointment_id = p_appointment_id
      AND status = 'Pending';

END //

DELIMITER ;

-- =========================================
-- PHẦN 7: KIỂM THỬ
-- =========================================

-- Test 1: Pending -> Cancelled
CALL CancelAppointment(104);

SELECT *
FROM Appointments
WHERE appointment_id = 104;

-- Kết quả mong muốn:
-- status = 'Cancelled'

-- =========================================

-- Test 2: Completed KHÔNG được hủy
CALL CancelAppointment(105);

SELECT *
FROM Appointments
WHERE appointment_id = 105;

-- Kết quả mong muốn:
-- status vẫn là 'Completed'

-- =========================================

-- Test 3: Cancelled sẵn KHÔNG đổi
CALL CancelAppointment(106);

SELECT *
FROM Appointments
WHERE appointment_id = 106;

-- Kết quả mong muốn:
-- status vẫn là 'Cancelled'