CREATE DATABASE IF NOT EXISTS archive_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE archive_db;

DROP TABLE IF EXISTS password_resets;
DROP TABLE IF EXISTS archive_files;
DROP TABLE IF EXISTS users;

-- user types: user | admin | subject (විෂය නිලධාරී)
-- status: pending = admin අනුමත කරන තෙක්, active = login විය හැක, disabled = අක්‍රීය
CREATE TABLE users (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    full_name      VARCHAR(150) NOT NULL,
    name           VARCHAR(150) NULL,
    nic            VARCHAR(15)  NOT NULL UNIQUE,
    email          VARCHAR(150) NOT NULL UNIQUE,
    designation    VARCHAR(120) NOT NULL,
    subject_number VARCHAR(40)  NOT NULL,
    role           ENUM('user','admin','subject') NOT NULL DEFAULT 'user',
    department     ENUM('ආයතන','සභා','ගිණුම්') NOT NULL,
    username       VARCHAR(60)  NOT NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    status         ENUM('pending','active','disabled','deleted') NOT NULL DEFAULT 'pending',
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at     DATETIME NULL,
    INDEX (role), INDEX (status), INDEX (department)
) ENGINE=InnoDB;

CREATE TABLE archive_files (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    submitted_by   INT NOT NULL,
    submit_date    DATE NOT NULL,
    subject_number VARCHAR(40)  NOT NULL,
    subject_no     VARCHAR(40)  NOT NULL,
    department     ENUM('ආයතන','සභා','ගිණුම්') NOT NULL,
    file_number    VARCHAR(60)  NOT NULL,
    file_no        VARCHAR(60)  NOT NULL,
    file_name      VARCHAR(255) NOT NULL,
    start_date     DATE NOT NULL,
    end_date       DATE NOT NULL,
    page_count     INT NOT NULL,
    pages          INT NOT NULL,
    right_side     INT NULL,
    left_side      INT NULL,
    archive_number VARCHAR(60) NULL UNIQUE,
    archive_no     VARCHAR(60) NULL UNIQUE,
    rack_no        VARCHAR(60) NULL,
    status         ENUM('pending','archived','rejected','waiting_approval','active','deleted') NOT NULL DEFAULT 'pending',
    reviewed_by    INT NULL,
    reviewed_at    DATETIME NULL,
    sent_by        INT NULL,
    sent_date      DATETIME NULL,
    approved_by    INT NULL,
    approved_at    DATETIME NULL,
    rejected_at    DATETIME NULL,
    reject_reason  TEXT NULL,
    deleted_at     DATETIME NULL,
    deleted_by     INT NULL,
    delete_reason  TEXT NULL,
    file_path      VARCHAR(500) NULL,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX (department), INDEX (subject_number), INDEX (subject_no), INDEX (status),
    INDEX (archive_number), INDEX (archive_no), INDEX (file_number), INDEX (file_no),
    FOREIGN KEY (submitted_by) REFERENCES users(id),
    FOREIGN KEY (reviewed_by)  REFERENCES users(id),
    FOREIGN KEY (sent_by)      REFERENCES users(id),
    FOREIGN KEY (approved_by)  REFERENCES users(id),
    FOREIGN KEY (deleted_by)   REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE password_resets (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL,
    token_hash CHAR(64) NOT NULL,
    expires_at DATETIME NOT NULL,
    INDEX (token_hash),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ===== පරීක්ෂා කිරීමට default accounts (පසුව password වෙනස් කරන්න) =====
--   admin    / Admin@123
--   subject1 / Subject@123
--   minasha  / User@123
INSERT INTO users (full_name, nic, email, designation, subject_number, role, department, username, password_hash, status) VALUES
('System Administrator', '199000000001', 'admin@example.com',   'Administrator',   'ADM-001', 'admin',   'ආයතන', 'admin',
 '$6$Pk9Ptna6ub4vRyQP$Jf7dM2YMx2zatZFirk/QItGcBMf9nL2u4E7RO9QVzwtle12dqM14DvwzQT/IL98gBlIOrIwe2fWgz82KvM7VV1', 'active'),
('Subject Officer',      '198500000002', 'subject@example.com', 'Subject Officer', 'SUB-100', 'subject', 'ගිණුම්', 'subject1',
 '$6$fEqLeEnJJYuCEynP$20d.w6EbnBvlJwoenHNf6OyHl8GKcJ4enBBzKEQvCdwGY3POVAa5UQnZKXe7NFLfmHpyPzIp7dah5dMcl3ir/1', 'active'),
('P.G. Minasha Shenali', '199500000003', 'minasha@example.com', 'Management Assistant', 'SUB-015', 'user', 'ආයතන', 'minasha',
 '$6$sCPSpyvZHQNnzGZO$MDu4uMQpMV6Y0utQ3Jg354reSXw1tH7tiSbKhznrMWkk/Yp407KPocFq6qH83rMWF2m47POHcRjjUG1gQqCU0.', 'active');

INSERT INTO archive_files (submitted_by, submit_date, subject_number, subject_no, department, file_number, file_no, file_name, start_date, end_date, page_count, pages, right_side, left_side, archive_number, archive_no, rack_no, status, reviewed_by, reviewed_at, sent_by, sent_date, approved_by, approved_at) VALUES
(3,'2026-06-15','SUB-001','SUB-001','ගිණුම්','F-101','F-101','වාර්ෂික මුදල් වාර්තාව 2026','2026-01-01','2026-05-30',120,120,60,60,'ARC-001','ARC-001','R-001','archived',2,NOW(),3,NOW(),1,NOW()),
(3,'2026-06-10','SUB-002','SUB-002','ගිණුම්','F-102','F-102','වාර්ෂික අයවැය සැලැස්ම','2026-01-01','2026-04-30',85,85,42,43,'ARC-002','ARC-002','R-002','archived',2,NOW(),3,NOW(),1,NOW()),
(3,'2025-12-01','SUB-015','SUB-015','ආයතන','F-115','F-115','කාර්ය මණ්ඩල විස්තර','2025-01-01','2025-11-30',64,64,32,32,'ARC-015','ARC-015','R-003','archived',2,NOW(),3,NOW(),1,NOW()),
(3,'2026-05-20','SUB-021','SUB-021','සභා','F-121','F-121','චක්‍රලේඛ අංක 07/2026','2026-03-01','2026-05-15',12,12,6,6,'ARC-021','ARC-021','R-004','archived',2,NOW(),3,NOW(),1,NOW()),
(3,'2026-04-18','SUB-030','SUB-030','ආයතන','F-130','F-130','තොරතුරු පද්ධති යෝජනාව','2026-02-01','2026-04-10',40,40,20,20,'ARC-030','ARC-030','R-005','archived',2,NOW(),3,NOW(),1,NOW()),
(3,'2025-11-25','SUB-045','SUB-045','සභා','F-145','F-145','ව්‍යාපෘති වාර්තාව','2025-06-01','2025-11-20',210,210,105,105,'ARC-045','ARC-045','R-006','archived',2,NOW(),3,NOW(),1,NOW()),
(3,'2025-11-20','SUB-046','SUB-046','සභා','F-146','F-146','මාසික ප්‍රගති වාර්තාව','2025-10-01','2025-10-31',18,18,9,9,'ARC-046','ARC-046','R-007','archived',2,NOW(),3,NOW(),1,NOW()),
(3,'2026-03-15','SUB-058','SUB-058','සභා','F-158','F-158','රැස්වීම් වාර්තා','2026-01-05','2026-03-10',33,33,16,17,'ARC-058','ARC-058','R-008','archived',2,NOW(),3,NOW(),1,NOW()),
(3,'2025-10-12','SUB-063','SUB-063','ගිණුම්','F-163','F-163','ප්‍රසම්පාදන සැලැස්ම','2025-04-01','2025-09-30',76,76,38,38,'ARC-063','ARC-063','R-009','archived',2,NOW(),3,NOW(),1,NOW()),
(3,'2025-09-30','SUB-070','SUB-070','ආයතන','F-170','F-170','නිවාඩු වාර්තා','2025-01-01','2025-09-15',52,52,26,26,'ARC-070','ARC-070','R-010','archived',2,NOW(),3,NOW(),1,NOW()),
(3,'2026-02-08','SUB-074','SUB-074','ආයතන','F-174','F-174','ජාලය විගණනය','2025-11-01','2026-01-31',28,28,14,14,'ARC-074','ARC-074','R-011','archived',2,NOW(),3,NOW(),1,NOW()),
(3,'2026-01-22','SUB-081','SUB-081','සභා','F-181','F-181','පුහුණු කාලසටහන','2026-01-01','2026-01-20',9,9,4,5,'ARC-081','ARC-081','R-012','archived',2,NOW(),3,NOW(),1,NOW()),
(3,'2026-10-12','SUB-090','SUB-090','ගිණුම්','F-190','F-190','සැපයුම් ගිණුම් වාර්තාව','2026-07-01','2026-09-30',44,44,22,22,NULL,NULL,NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL);
