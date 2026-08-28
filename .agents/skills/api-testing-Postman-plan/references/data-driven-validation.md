# Data-driven validation cho Postman

Đọc reference này chỉ khi người dùng muốn dùng CSV/Excel/JSON để chạy nhiều test input, hoặc khi API được chọn nhận file CSV/XLSX thực tế.

## 1. Chọn đúng loại file

| Nhu cầu | Cách dùng | Lưu ý lập kế hoạch |
|---|---|---|
| Nhiều input cho cùng request | CSV hoặc JSON làm iteration data cho Collection Runner/Postman CLI | Một row là một iteration; data variables là local, không persist sau run. |
| Người test soạn ma trận bằng Excel | XLSX là authoring source, chuyển tab đã duyệt sang CSV UTF-8 hoặc JSON trước khi chạy | Version source và file chuyển đổi phải trace được; giữ string/leading zero/blank semantics. |
| Workspace có Postman Datasets | Chỉ dùng spreadsheet source trực tiếp khi quyền/plan và beta support đã được người dùng xác nhận | Ghi dataset, data source và view; chuẩn bị fallback CSV/JSON. |
| API nhận file upload | File CSV/XLSX là fixture ở request multipart/binary, không phải iteration input | Test contract upload: file type, MIME, schema, encoding, size, corrupt/missing file, content validation. |

Postman Collection Runner và Postman CLI nhận iteration data CSV/JSON. Postman Datasets hiện hỗ trợ spreadsheet data source nhưng là beta và phụ thuộc plan/quyền; không dùng nó làm assumption mặc định.

## 2. Khi nào dùng matrix

Dùng matrix cho nhiều biến thể độc lập có cùng method/path/payload shape, như valid/invalid/boundary cho `age`, length/format của một field, enum, date format, hoặc các tổ hợp input đã được requirement xác định.

Không dùng matrix để thay thế các test cần request sequence hoặc state riêng: login/logout, create-read-update-delete, ownership/RBAC với role khác nhau, concurrency, recovery/retry, idempotency, external dependency, hay destructive case. Chúng thuộc workflow/run profile riêng.

Khi một field có nhiều invalid value nhưng cùng expected status/error/behavior, có thể nhóm thành một Basic TC và nhiều rows. Nếu outcome khác nhau, có side effect khác, hoặc source requirement khác, tách BTC/condition tương ứng.

## 3. Schema matrix khuyến nghị

Dùng tên cột ASCII, camelCase hoặc snake_case nhất quán, không đổi hoa/thường. Cột tối thiểu:

| Cột | Ý nghĩa |
|---|---|
| `rowId` | Khóa duy nhất, ổn định, hiển thị trong test output và evidence. |
| `basicTcId` | BTC/condition mà row thực thi; bảo đảm trace ngược. |
| `apiId` | API ID được contract định nghĩa. |
| `requestKey` | Request/folder data-driven được phép chạy; dùng khi cần routing rõ ràng. |
| `fieldPath` | Đường dẫn field trong request (ví dụ `body.age`), không thay contract bằng name tự suy diễn. |
| `inputMode` | `literal`, `omit`, `jsonNull`, `emptyString`, `whitespace`, hoặc mode được dự án định nghĩa. |
| `inputValue` | Giá trị raw chỉ có nghĩa cùng `inputMode` và `valueType`. Không dùng ô trống để ngầm chỉ null/omit. |
| `valueType` | Ví dụ `number`, `string`, `boolean`, `object`, `array`; dùng để downstream serialize an toàn. |
| `expectedStatus` | HTTP status được contract/requirement xác nhận. |
| `expectedErrorCode` | Error code được xác nhận; để trống có chủ đích khi không được contract hóa. |
| `expectedOutcome` | Tag có kiểm soát như `success`, `validationError`, `noStateChange`; định nghĩa/trace trong plan. |
| `sourceRef` | API Contract/Convention/FRD section hoặc requirement ID. |

Cột tùy chọn: `expectedFieldPath`, `expectedValueRule`, `expectedHeader`, `dataProfileId`, `priority`, `notes`, `fixtureId`, `cleanupRule`. Không chứa password, JWT, API key hay PII.

Ví dụ **schema**, không phải test data được phê duyệt:

```csv
rowId,basicTcId,apiId,requestKey,fieldPath,inputMode,inputValue,valueType,expectedStatus,expectedErrorCode,expectedOutcome,sourceRef
AGE-NEG-001,BTC-API-USER-001-02,API-USER-001,update-user-age,body.age,literal,[value-defined-in-approved-data],number,[status-from-contract],[code-from-contract],validationError,API Contract §[endpoint]
```

## 4. Quy tắc CSV/Excel và chuyển đổi

- CSV có header đúng tên variable/cột; tất cả row có cùng số cột; kiểm tra delimiter, quote/escape và encoding UTF-8 trước khi chạy.
- Giữ các dữ liệu định danh hoặc string có leading zero là text khi export. Không để Excel tự đổi long number, date, scientific notation, boolean hay trim whitespace.
- Không dùng formula Excel làm expected result runtime. Materialize giá trị có review trước khi chuyển đổi; matrix không được là nơi tính business rule bí mật/khó audit.
- Mỗi workbook phải chỉ rõ sheet/view được dùng, source version, owner và thời điểm export. Một CSV/JSON được generate phải được đối chiếu row count + header + rowId unique với source.
- JSON phù hợp nếu request input có nested object/array hoặc cần giữ number/boolean/null mà CSV khó biểu diễn. Cấu trúc là array object với cùng schema logical.
- Validate matrix trước run: header bắt buộc, `rowId` unique, `apiId/requestKey` thuộc scope, `expectedStatus` hợp lệ theo contract, `inputMode`/`valueType` được hỗ trợ, không có secret/PII.

## 5. Thiết kế collection/run

1. Tạo folder hoặc collection hẹp `Data-driven validation — [API ID] — [payload]` chứa một request chính và chỉ các helper/assertion cần thiết.
2. Chạy folder đó với một matrix matching endpoint/payload. Không chạy collection CRUD hoàn chỉnh theo mỗi row trừ khi đó là behavior đã chủ ý và có cleanup cô lập.
3. Pre-request specification của downstream phải map row → payload theo `fieldPath`, `inputMode`, `valueType`; preserve omitted/null/empty/whitespace khác nhau và fail-fast khi row không hợp lệ.
4. Test specification phải assert response theo `expectedStatus`, `expectedErrorCode`, `expectedOutcome` của row; log/report `rowId`, `basicTcId`, `apiId`, request and sourceRef khi fail.
5. Chọn continue để thu đủ failure matrix validation; chọn fail-fast chỉ khi setup/auth/matrix schema lỗi khiến các row sau không đáng tin. Quyết định này phải nằm trong run profile.
6. Với endpoint mutation, xác nhận mỗi row không làm hỏng data của row sau. Ưu tiên invalid validation trước persistence; nếu success row tạo state, thêm namespace/unique data và verification/cleanup riêng được phê duyệt.

## 6. Evidence và traceability

Artifact plan phải lưu `Matrix ID`, source workbook/file, sheet/view, exported file/version, row count, row ID range, collection/folder, run profile và execution evidence location. Khi một row fail, evidence phải nêu ít nhất `rowId`, `basicTcId`, API/request, actual status/error envelope và response correlation/request ID nếu có.

Không biến toàn bộ spreadsheet thành test case text trong plan. Plan trace nhóm condition/BTC đến từng `rowId` hoặc range; file matrix là test asset versioned riêng. Khi sửa row, đánh giá impact lên BTC, assertion script, expected outcome và coverage traceability.
