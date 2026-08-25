---
name: analyze-requirement
description: Phân tích tài liệu yêu cầu (BRD, FRD, SRS, User Stories, Jira Tickets, UI Mockups) của bất kỳ dự án phần mềm nào — kiểm tra tính đầy đủ theo tiêu chuẩn "Ready for Vibe Coding", trích xuất AC, business rules, field specs, phát hiện điểm mơ hồ (AMB-XX) và rủi ro kiểm thử (RISK-XX). KHÔNG sinh test cases.
---

# Workflow: Phân Tích Tài Liệu Yêu Cầu (Requirement Analyzer)

Skill này hướng dẫn AI phân tích, bóc tách và rà soát các tài liệu yêu cầu (BRD, FRD, SRS, User Stories, Jira tickets, Wireframe/Mockups) cho **bất kỳ dự án phần mềm nào** (Web, Mobile, Desktop, API). Skill tập trung vào việc làm sáng tỏ logic nghiệp vụ, đặc tả chi tiết các trường dữ liệu, ma trận phân quyền (RBAC), phát hiện rủi ro/điểm mơ hồ và đánh giá tính sẵn sàng của tài liệu theo tiêu chuẩn **"Ready for Vibe Coding / Ready for QA"**.

> ⚠️ **LƯU Ý QUAN TRỌNG:** Workflow này **KHÔNG sinh test cases** — chỉ tập trung phân rã, kiểm tra độ phủ logic, trích xuất đặc tả trường dữ liệu, quy tắc nghiệp vụ và phát hiện các lỗ hổng trong yêu cầu trước khi chuyển giao cho Developer hoặc QA.

---

## 1. Đầu Vào (Input Requirements)

Agent có thể nhận từ User một hoặc nhiều thành phần đầu vào sau:
1. **Requirement Document:** File `.md`, `.doc`, `.pdf`, nội dung Jira Ticket, User Story, PRD, FRD, BRD hoặc SRS.
2. **UI Mockup / Screenshot / Wireframe (Tùy chọn):** Hình ảnh thiết kế giao diện, sơ đồ Use Case, Figma screenshot hoặc DOM/HTML của trang web.
3. **Bối cảnh Dự án & Phụ thuộc (Tùy chọn):** Các ticket liên quan, tài liệu kiến trúc hệ thống hiện tại hoặc ghi chú nghiệp vụ.

---

## 2. Tiêu Chuẩn Đánh Giá "Ready For Vibe Coding / Ready For QA"

Một tài liệu yêu cầu đạt chuẩn phải trả lời rõ ràng **12 câu hỏi vàng** (12 Quality Gates):

1. **Who (Actor & Role):** Ai là người thực hiện hành động (Phân định rõ Actor/Role)?
2. **Preconditions:** Điều kiện tiên quyết cần thỏa mãn trước khi thực hiện là gì?
3. **Inputs:** Dữ liệu đầu vào gồm những thành phần nào?
4. **Validation Rules:** Quy tắc kiểm tra tính hợp lệ dữ liệu là gì (min/max length, format, trim space, unique constraint, boundary)?
5. **Data State Changes:** Dữ liệu nào được tạo mới, cập nhật, xóa hoặc giữ nguyên (CRUD)?
6. **Success Flow:** Luồng xử lý thành công (Happy Path) diễn ra như thế nào?
7. **Failure Flow:** Luồng xử lý thất bại / ngoại lệ (Validation error, System error, Timeout, Rate limit, Permission denied) được xử lý ra sao?
8. **Empty States:** Trạng thái trống (chưa có dữ liệu, danh sách rỗng) hiển thị như thế nào?
9. **Permission Checks:** Kiểm tra quyền hạn tại API & UI như thế nào (RBAC)?
10. **Business Rules & Formulas:** Công thức tính toán, quy tắc nghiệp vụ hoặc thuật toán áp dụng là gì?
11. **Downstream Impacts:** Tác động dây chuyền tới các module/tính năng khác trong hệ thống là gì?
12. **Acceptance Criteria (AC):** Tiêu chí nghiệm thu rõ ràng, đo lường và kiểm thử được là gì?

---

## 3. Quy Trình Phân Tích 6 Bước (6-Step Workflow)

### Bước 1: Thu thập và Đọc hiểu Bối cảnh (Information Gathering & Context)
1. Đọc toàn bộ tài liệu yêu cầu được cung cấp.
2. Trích xuất Metadata: Mã ticket/yêu cầu, Tên tính năng, Module/Hệ thống, Trọng yếu (Priority), Actor liên quan.
3. Nhận diện bối cảnh tổng quan của hệ thống, các Actors tham gia và các Module bị ảnh hưởng.

### Bước 2: Phân tích UI Mockup & Phân rã Phạm vi (UI Analysis & Scope)
Nếu User cung cấp Mockup/Screenshot/DOM:
1. **Layout & Navigation:** Breadcrumb, Header, Sidebar, Main Content, Footer.
2. **UI Components:** Bảng (Tables), Form nhập liệu, Modals, Buttons, Dropdowns, Tabs, Badges.
3. **Phạm vi (Scope):** Phân định rõ những gì thuộc phạm vi thực hiện (**In Scope**) và những gì nằm ngoài phạm vi (**Out of Scope**).

### Bước 3: Chi tiết hóa User Story, AC & Đặc Tả Trường Dữ Liệu (AC & Field Specs)
1. **User Story Format:** Trích xuất dạng chuẩn: *"Là một [Actor], tôi muốn [Hành động] để [Mục đích]"*.
2. **Phân rã Acceptance Criteria (AC):** Nhóm AC theo từng luồng logic (Happy path, Alternative flow, Edge cases).
3. **Lập Bảng Đặc Tả Trường Dữ Liệu (Field Specifications Table):**
   - Tên trường (Field Label/Name)
   - Loại UI / Control Type (Input text, Dropdown, Datepicker, Checkbox, Radio, File upload...)
   - Bắt buộc (Required / Optional)
   - Validation Rules / Constraints (Ràng buộc độ dài min/max, Định dạng regex/email/phone, Trim space, Trùng lặp/Unique, Giới hạn ngày...)
   - Giá trị mặc định (Default Value)
   - Ghi chú (Notes / Dependencies)

### Bước 4: Trích xuất Quy Tắc Nghiệp Vụ, Phân Quyền & Tác Động (Business Rules, RBAC & Impact)
1. **Business Rules & Formulas:** Liệt kê các quy tắc nghiệp vụ, công thức tính toán, trạng thái dữ liệu (State Transitions).
2. **Ma trận Phân quyền (RBAC Matrix):** Bảng kiểm tra quyền hạn của từng Actor (Ví dụ: Admin, User, Guest/Public) đối với các hành động Create/Read/Update/Delete.
3. **Tác động Dây chuyền (Downstream Impacts):** Phân tích sự ảnh hưởng đến các màn hình, API, cơ sở dữ liệu hoặc module khác khi tính năng này thay đổi.

### Bước 5: Đánh giá Chất lượng "Ready for Vibe Coding" (12 Quality Gates Audit)
Đối chiếu tài liệu yêu cầu với **12 Tiêu chuẩn tại Mục 2**. Đánh dấu trạng thái:
- ✅ **Đã rõ ràng:** Yêu cầu đã mô tả chi tiết, đủ để Dev viết code / QA viết test.
- ⚠️ **Thiếu sót / Mơ hồ:** Yêu cầu chưa mô tả hoặc mô tả thiếu ràng buộc (cần clarify).

### Bước 6: Phát hiện Điểm Mơ Hồ (Ambiguities) & Rủi Ro Kiểm Thử (Testing Risks)
> [!IMPORTANT]
> Đây là bước mang lại giá trị cao nhất — phát hiện những điểm yêu cầu KHÔNG nói rõ, nói mâu thuẫn hoặc thiếu xử lý biên.

1. **Danh sách Điểm Mơ Hồ (Ambiguities - AMB-XX):**
   - Từ khóa mơ hồ, cảm tính: *"phù hợp", "tương tự", "nếu cần", "nhanh chóng", "etc."*
   - Lỗi thiếu Boundary: Không quy định max length, không rõ định dạng date/time, thiếu rate limit/pagination size.
   - Thiếu xử lý ngoại lệ: Khi mất mạng giữa chừng, khi API bên thứ 3 bị lỗi/timeout, khi dữ liệu rỗng.
   - Mâu thuẫn: Sai lệch giữa mô tả text trong document và hình ảnh trong UI Mockup.
   - Đánh số **AMB-01, AMB-02...** kèm mức độ (🔴 High / 🟡 Medium / 🟢 Low) và câu hỏi khuyến nghị cho PO/BA.
2. **Danh sách Rủi Ro Kiểm Thử (Testing Risks - RISK-XX):**
   - Đánh giá các rủi ro về mặt logic, hiệu năng, đồng bộ dữ liệu, bảo mật hoặc trải nghiệm người dùng.
   - Đánh số **RISK-01, RISK-02...** kèm biện pháp giảm thiểu (Mitigation Strategy).

---

## 4. Cấu Trúc Tài Liệu Đầu Ra (Output Template Artifact)

Kết quả phân tích PHẢI được xuất dưới dạng Artifact Markdown (`analysis_report.md` hoặc `requirements_spec_[FEATURE].md`) theo cấu trúc tổng quát chuẩn sau:

```markdown
# 📋 Tài Liệu Phân Tích Yêu Cầu: [TÊN TÍNH NĂNG / TICKET ID]
> **Dự án:** [Tên Dự Án] | **Module:** [Tên Module] | **Ngày phân tích:** [YYYY-MM-DD]

---

## 1. Tổng Quan & Phạm Vi (Overview & Scope)
- **Tên tính năng / Yêu cầu:** ...
- **Actors tham gia:** [Danh sách các Actor / Role]
- **Mục đích nghiệp vụ:** ...
- **Phạm vi áp dụng (In Scope):** ...
- **Phạm vi loại trừ (Out of Scope):** ...

---

## 2. User Story & Acceptance Criteria (AC)
### 2.1. User Story
> *As a* [Actor], *I want* [Hành động], *So that* [Giá trị mang lại].

### 2.2. Phân Rã Acceptance Criteria
- **AC-01 [Tên AC]:** Mô tả chi tiết luồng xử lý...
- **AC-02 [Tên AC]:** Mô tả chi tiết luồng xử lý...

---

## 3. Đặc Tả Trường Dữ Liệu (Field Specifications)
| Tên Trường (Label) | UI Type | Required | Validation Rules / Constraints | Default Value | Notes |
|---|---|---|---|---|---|
| [Tên trường 1] | Input Text | Yes | Min 3, Max 50 chars, trimmed, unique | N/A | ... |
| [Tên trường 2] | Dropdown | No | Option values: [A, B, C] | Option A | ... |

---

## 4. Quy Tắc Nghiệp Vụ & Luồng Xử Lý (Business Rules & Logic)
- **BR-01:** Quy tắc kiểm tra/tính toán nghiệp vụ 1...
- **BR-02:** Trạng thái chuyển đổi dữ liệu (State transitions)...

---

## 5. Ma Trận Phân Quyền (RBAC) & Tác Động Dây Chuyền
### 5.1. Ma Trận Phân Quyền (RBAC Matrix)
| Hành động / Feature | [Role 1] | [Role 2] | [Role 3] |
|---|---|---|---|
| Xem danh sách | ✅ Allowed | ✅ Allowed | ❌ Denied |
| Tạo / Chỉnh sửa | ✅ Allowed | ❌ Denied | ❌ Denied |

### 5.2. Tác động Dây chuyền (Downstream Impacts)
- Ảnh hưởng tới **Module/Màn hình A:** ...
- Ảnh hưởng tới **API/Cơ sở dữ liệu B:** ...

---

## 6. Đánh Giá Tiêu Chuẩn "Ready For Vibe Coding" (12 Quality Gates)
- [x] 1. Who (Actor & Role): ...
- [x] 2. Preconditions: ...
- [x] 3. Inputs: ...
- [x] 4. Validations: ...
- [x] 5. Data State Changes: ...
- [x] 6. Success Flow: ...
- [ ] 7. Failure Flow: ⚠️ (Cần làm rõ hành vi khi API timeout)
- [x] 8. Empty States: ...
- [x] 9. Permission Checks: ...
- [x] 10. Business Rules & Formulas: ...
- [x] 11. Downstream Impacts: ...
- [x] 12. Acceptance Criteria: ...

---

## 7. Các Điểm Mơ Hồ (Ambiguities) & Rủi Ro Kiểm Thử (Testing Risks)

### 7.1. Danh Sách Điểm Mơ Hồ (Ambiguities)
| Mã AMB | Câu hỏi / Điểm chưa rõ | Nguy cơ / Tác động | Mức độ | Khuyến nghị cho PO/BA |
|---|---|---|---|---|
| AMB-01 | [Mô tả chi tiết điểm chưa rõ] | [Impact nếu không làm rõ] | 🔴 High | [Đề xuất hướng giải quyết] |
| AMB-02 | ... | ... | 🟡 Medium | ... |

### 7.2. Danh Sách Rủi Ro Kiểm Thử (Testing Risks)
| Mã RISK | Tên Rủi Ro | Mô tả Chi tiết Rủi Ro | Biện pháp giảm thiểu (Mitigation) |
|---|---|---|---|
| RISK-01 | [Tên rủi ro] | [Mô tả nguy cơ sai sót logic/hiệu năng] | [Giải pháp phòng ngừa khi test] |
| RISK-02 | ... | ... | ... |

---

## 8. Tóm Tắt Acceptance Criteria (Checklist Cho QA)
- [ ] AC-01: Kiểm tra thực hiện luồng thành công với dữ liệu hợp lệ.
- [ ] AC-02: Kiểm tra báo lỗi Validation khi nhập sai định dạng/vượt giới hạn.
- [ ] AC-03: Kiểm tra xử lý khoảng trắng đầu/cuối (trimming).
- [ ] AC-04: Kiểm tra phân quyền truy cập theo từng Role.
```

---

## 5. Quy Tắc Bắt Buộc (Strict Rules)

1. 🇻🇳 **Ngôn ngữ:** Xuất báo cáo phân tích bằng **Tiếng Việt** chuyên nghiệp, chuẩn mực.
2. ❌ **KHÔNG sinh test cases:** Tuyệt đối không sinh danh sách test cases chi tiết (dành cho skill `$generate-manual-testcases-rbt` hoặc `$generate-testcases-from-requirements`).
3. ❌ **KHÔNG tự suy diễn logic:** Nếu tài liệu chưa nói rõ hoặc có sự mâu thuẫn, PHẢI đưa vào mục **Ambiguities (AMB-XX)** để clarify với PO/BA.
4. ✅ **Tính Tổng Quát (Generality):** Áp dụng linh hoạt cho mọi miền bài toán (E-commerce, EdTech, Fintech, CRM, Healthcare...) và mọi nền tảng (Web, App, API, Desktop).
