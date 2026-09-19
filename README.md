## Thành viên nhóm

| STT | Họ và tên | MSSV |
|:---:|-----------|:----:|
| 1 | Nguyễn Bảo Đại | 052206015018 |
| 2 | Đoàn Anh thư | 072306008525 |
| 3 | Huỳnh Kiến Hưng | 079206005377 |
| 4 | Trần Chí Nguyên | 083206008312 |
| 5 | Rcom Chiến | 064205002320 |


## Phân công công việc

Mỗi thành viên checkout vào branch tương ứng với task  của mình, sau đó làm việc trong thư mục `chapter1/thietkequanniem/`.

| Branch           | Task   |
| ---------------- | ------ |
| `chapter1-task1` | Task 1 |
| `chapter1-task2` | Task 2 |
| `chapter1-task3` | Task 3 |
| `chapter1-task4` | Task 4 |
| `chapter1-task5` | Task 5 |

### Quy trình làm việc

1. Chuyển vào branch được phân công.
2. Vào thư mục `chapter1/thietkequanniem/`.
3. Tạo/chỉnh sửa file tương ứng với task của mình.
4. Commit và push lên branch cá nhân.
5. Tạo Pull Request từ branch cá nhân → `chapter1-thietkequanniem`.



làm stage2 trên nhánh chapter2-thietkelogic
Mỗi thành viên checkout vào branch tương ứng với task của mình, sau đó làm việc trong thư mục chapter3.
| Branch                | Task         |
| `chapter2-thanhvien1` | `thanhvien1` |
| `chapter2-thanhvien2` | `thanhvien2` |
| `chapter2-thanhvien3` | `thanhvien3` |
| `chapter2-thanhvien4` | `thanhvien4` |
| `chapter2-thanhvien5` | `thanhvien5` |

Quy trình làm việc

Chuyển vào branch được phân công.
Vào thư mục chapter3.
Tạo/chỉnh sửa file tương ứng với task của mình.
Commit và push lên branch cá nhân.
Tạo Pull Request từ branch cá nhân → chapter2-thietkelogic.


xem phân công task kỹ hơn trên gg sheet đã gửi trước đó 


# HƯỚNG DẪN THIẾT KẾ DDL SQL & PHÂN CÔNG NHIỆM VỤ (STAGE 3)

Tài liệu này quy định cấu trúc phân chia thư mục script DDL, quy chuẩn thiết kế và nhiệm vụ cụ thể cho 5 thành viên để triển khai **Stage 3: Thiết kế Vật lý & Lập trình DDL SQL**.

---

## 1. Cấu trúc File & Quy chuẩn DDL Bắt buộc

Mỗi thành viên chịu trách nhiệm tạo **01 file script SQL duy nhất** nằm trong thư mục `/scripts/` của dự án với tên gọi `schema_member_<X>.sql` (với `<X>` từ 1 đến 5).

Mọi file SQL bắt buộc tuân thủ đúng **5 thành phần chuẩn hóa**:

1. **CREATE TABLE:** Đặt tên bảng và tên cột dạng `snake_case`. Sử dụng các kiểu dữ liệu chuẩn (`UUID`, `VARCHAR`, `TEXT`, `TIMESTAMP`, `BOOLEAN`).
2. **PRIMARY KEY & UNIQUE:** Khai báo khóa chính đơn lập dạng `<tên_bảng>_id` kiểu `UUID`. Khai báo đầy đủ các ràng buộc duy nhất đơn hoặc tổ hợp (`UNIQUE`).
3. **FOREIGN KEY:** Thiết lập đầy đủ khóa ngoại kèm hành vi tham chiếu rõ ràng (`ON DELETE CASCADE`, `RESTRICT`, hoặc `SET NULL`).
4. **CHECK CONSTRAINT:** Kiểm soát tập giá trị hợp lệ cho các cột trạng thái hoặc phân loại (`CHECK (status IN (...))`).
5. **CREATE INDEX:** Tạo chỉ mục phụ trên các cột Khóa ngoại (`FK`) và các cột thường xuyên tra cứu để tối ưu hiệu năng.

---

## 2. Phân công Nhiệm vụ Chi tiết

| Thành viên | Phân hệ (Domain) | Số lượng bảng | Tệp Script DDL |
| :--- | :--- | :---: | :--- |
| **Thành viên 1** | Auth & RBAC Domain | 6 | `schema_member_1.sql` |
| **Thành viên 2** | Workspace & External VCS Domain | 5 | `schema_member_2.sql` |
| **Thành viên 3** | Code Structure & AST Analysis Domain | 7 | `schema_member_3.sql` |
| **Thành viên 4** | Template Engine & Core Documentation Domain | 7 | `schema_member_4.sql` |
| **Thành viên 5** | Governance, Review, AI Evidence & Observability Domain | 6 | `schema_member_5.sql` |

---

### **Thành viên 1: Auth & RBAC Domain**
* **File script:** `schema_member_1.sql`
* **Danh sách 6 bảng:** `users`, `user_notification_preferences`, `roles`, `permissions`, `role_permissions`, `workspace_members`.
* **Yêu cầu DDL:**
  * **Surrogate PK:** Kiểu `UUID` cho tất cả các bảng.
  * **Foreign Keys:** Cài đặt FK `user_id`, `role_id`, `permission_id`.
  * **Unique Constraints:** `UNIQUE (email)` trên `users`; `UNIQUE (user_id, channel)` trên `user_notification_preferences`; `UNIQUE (role_id, permission_id)` trên `role_permissions`; `UNIQUE (workspace_id, user_id)` trên `workspace_members`.
  * **Check Constraints:** Kiểm tra trạng thái hợp lệ `CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED'))`.

---

### **Thành viên 2: Workspace & External VCS Domain**
* **File script:** `schema_member_2.sql`
* **Danh sách 5 bảng:** `workspaces`, `github_connections`, `github_connection_scopes`, `repositories`, `branches`.
* **Yêu cầu DDL:**
  * **Surrogate PK:** Kiểu `UUID` cho tất cả các bảng.
  * **Foreign Keys:** Cài đặt FK `workspace_id`, `connection_id`, `repository_id`.
  * **Unique Constraints:** `UNIQUE (connection_id, scope_value)` trên `github_connection_scopes`; `UNIQUE (workspace_id, name)` trên `workspaces`/`repositories`; `UNIQUE (repository_id, branch_name)` trên `branches`.
  * **Check Constraints:** Kiểm tra trạng thái đồng bộ `CHECK (sync_status IN ('SYNCING', 'SUCCESS', 'FAILED'))`.

---

### **Thành viên 3: Code Structure & AST Analysis Domain**
* **File script:** `schema_member_3.sql`
* **Danh sách 7 bảng:** `commits`, `pull_requests`, `pull_request_labels`, `code_diffs`, `files`, `code_entities`, `dependencies`.
* **Yêu cầu DDL:**
  * **Surrogate PK:** Kiểu `UUID` cho tất cả các bảng.
  * **Foreign Keys:** Cài đặt FK `branch_id`, `repository_id`, `commit_id`, `file_id`, `dependent_entity_id`, `target_entity_id`.
  * **Unique Constraints:** `UNIQUE (repository_id, pr_number)` trên `pull_requests`; `UNIQUE (repository_id, file_path)` trên `files`; `UNIQUE (dependent_entity_id, target_entity_id)` trên `dependencies`.
  * **Check Constraints:** Ràng buộc phân loại cho `change_type`, `entity_type`, `dependency_type`.

---

### **Thành viên 4: Template Engine & Core Documentation Domain**
* **File script:** `schema_member_4.sql`
* **Danh sách 7 bảng:** `templates`, `template_sections`, `placeholders`, `template_mappings`, `documents`, `document_versions`, `change_logs`.
* **Yêu cầu DDL:**
  * **Surrogate PK:** Kiểu `UUID` cho tất cả các bảng.
  * **Foreign Keys:** Cài đặt FK `workspace_id`, `template_id`, `section_id`, `placeholder_id`, `document_id`, `version_id`.
  * **Unique Constraints:** `UNIQUE (template_id, order_index)` trên `template_sections`; `UNIQUE (section_id, variable_name)` trên `placeholders`; `UNIQUE (placeholder_id, entity_id)` trên `template_mappings`; `UNIQUE (document_id, version_number)` trên `document_versions`.
  * **Check Constraints:** Ràng buộc hợp lệ cho `document_type`, `status`, `change_type`.

---

### **Thành viên 5: Governance, Review, AI Evidence & Observability Domain**
* **File script:** `schema_member_5.sql`
* **Danh sách 6 bảng:** `reviews`, `review_comments`, `approvals`, `grounding_evidences`, `drift_alerts`.
* **Yêu cầu DDL:**
  * **Surrogate PK:** Kiểu `UUID` cho tất cả các bảng.
  * **Foreign Keys:** Cài đặt FK `version_id`, `review_id`, `evidence_id`, `repository_id`.
  * **Check Constraints:** Ràng buộc kiểm tra các trạng thái `review_status`, `decision`, `purpose`, `drift_type`, `drift_status`.
  * **Create Index:** Tạo chỉ mục phụ `CREATE INDEX` bắt buộc trên các cột `version_id` và `repository_id`.

---

## 3. Thứ tự Thực thi Script SQL (Execution Order)

Để tránh lỗi ràng buộc Khóa ngoại (Foreign Key Constraint Violation), các file DDL SQL phải được chạy theo đúng thứ tự phụ thuộc sau:



---------------------
# PHÂN CÔNG NHÂN SỰ, NHÁNH GIT & FILE NỘP (STAGE 3)

Tài liệu quy định chi tiết phân công công việc, tên nhánh Git (`Git Branch`), đường dẫn file báo cáo TeX (`LaTeX`), và file thực thi script DDL (`SQL`) cho từng thành viên.

---

## 1. Bảng Tổng Quan Phân Công

| Thành viên | Phân hệ (Domain) | Số bảng | Nhánh Git | File Báo cáo (TeX) | File Script (SQL) |
| :--- | :--- | :---: | :--- | :--- | :--- |
| **Nguyên** (TV1) | Auth & Access Control Domain | 6 | `chapter3-tv1` | `chapter3/tv1.tex` | `scripts/schema_member_1.sql` |
| **Chiến** (TV2) | Workspace & External VCS Domain | 5 | `chapter3-tv2` | `chapter3/tv2.tex` | `scripts/schema_member_2.sql` |
| **Hưng** (TV3) | Code Structure & AST Analysis Domain | 7 | `chapter3-tv3` | `chapter3/tv3.tex` | `scripts/schema_member_3.sql` |
| **Đại** (TV4) | Template Engine & Core Doc Domain | 7 | `chapter3-tv4` | `chapter3/tv4.tex` | `scripts/schema_member_4.sql` |
| **Thư** (TV5) | Governance, Review & AI Evidence Domain | 6 | `chapter3-tv5` | `chapter3/tv5.tex` | `scripts/schema_member_5.sql` |

