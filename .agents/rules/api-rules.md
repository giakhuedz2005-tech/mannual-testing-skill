---
trigger: always_on
---

# API Automation Testing Rules (API Testing Rules)

> Applies to all API Automation test suites in the project (REST Assured - Java, Playwright API - TypeScript, Requests - Python, Supertest - JavaScript/TypeScript).

---

## 1. API Framework Architecture

- Enforce clear separation of responsibilities:
  - **API Client / Service Layer:** Contains HTTP Request initialization logic (URL, Headers, Params, Auth) and execution. Must NOT contain assertions.
  - **Model / DTO Layer:** Defines Request / Response Data Transfer Objects (POJO, Pydantic, TypeScript Interface).
  - **Test Layer:** Contains test scenarios, invokes API Client, and performs assertions.
  - **Test Data / Utility Layer:** Functions for random data generation, config reading, and JSON Schema parsing.
- Apply **API Object Pattern** or **Builder Pattern** when constructing complex Request Payloads.

---

## 2. Assertions Standard

Every API Test Case **MUST** perform the following verifications:

1. **HTTP Status Code:** Exact match with expected status code (e.g., `200 OK`, `201 Created`, `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`, `409 Conflict`).
2. **Response Schema:** Validate that Response Body strictly conforms to defined JSON Schema / Contract.
3. **Key Business Fields:** Check critical data fields in Response Body via exact value or pattern match (use Soft Assertions when verifying multiple fields simultaneously).
4. **Error Response Detail (Negative Cases):** For failure scenarios, verify exact `errorCode`, `message`, or `details` returned, not just Status Code.
5. **Response Time / SLA:** Verify response time stays within allowed threshold (e.g., `< 2000ms`) if SLA requirements exist.
6. **Headers Check:** Verify Content-Type (e.g., `application/json`) and essential Security Headers when required.

---

## 3. Authentication & Security Management

- **DO NOT hardcode** passwords, secret keys, or API tokens directly in source code or test data files.
- Read credentials and base URLs from environment variables (`.env`, config files, or system environment variables).
- Manage **Token Lifecycle** efficiently:
  - Acquire Auth Token in Setup phase (`beforeAll`, `@BeforeClass`, or Shared Fixture).
  - Reuse tokens across test cases to optimize execution time.
  - Implement automatic token refresh logic when tokens expire.
- **Masking Sensitive Data:** Automatically mask sensitive information (Passwords, Tokens, Credit Cards) in log files and test execution reports.

---

## 4. Test Data Rules

- Newly created data via API (Username, Email, Code/ID) **MUST** be dynamic, independent, and **traceable**:
  ```text
  Format: auto_api_[testName]_[timestamp]_[random]
  Example: auto_api_createUser_1712049200_a8f2@test.com
  ```
- **Cleanup / Teardown:** Test cases that create test data (`POST`) should include cleanup steps (`DELETE`) in Teardown (`afterEach`, `@AfterClass`, `afterAll`) to prevent polluting the test database.
- Use **Data-Driven Testing** (TestNG DataProvider, Pytest Parametrize, Playwright Parameterized) when testing the same API against multiple datasets (Input Validation Matrix).

---

## 5. HTTP Standards & Idempotency

| HTTP Method | Operation | Expected Status | Idempotent | Testing Considerations |
|---|---|---|---|---|
| **GET** | Read | 200 OK | ✅ Yes | Read-only. Does NOT alter server data. |
| **POST** | Create | 201 Created / 200 OK | ❌ No | Returns ID or newly created resource info. Calling twice with same payload creates two distinct records. |
| **PUT** | Update (Replace) | 200 OK / 204 No Content | ✅ Yes | Replaces entire object. Missing optional fields may reset those fields. Calling N times produces identical state. |
| **PATCH** | Update (Partial) | 200 OK | ❌/✅ Varies | Updates only specified fields. Unsent fields must remain unchanged. |
| **DELETE** | Remove | 200 OK / 204 No Content | ✅ Yes | Removes resource. Subsequent `GET` request on deleted resource MUST return `404 Not Found`. |

---

## 6. Execution & Auto-Heal Workflow

When running API Automation tests via command line:

1. **Analyze Specific Error Logs:**
   - **Status Code mismatch:** Re-check Request Body payload, Headers, or Auth.
   - **Schema Mismatch:** Verify whether backend API response structure has changed.
   - **401/403 Error:** Check whether acquired token is valid or expired.
   - **404 Not Found:** Re-verify Path variables, Base URL, or if Resource ID was deleted.
   - **500 Internal Server Error:** Log server backend error (report to dev if sent data matches spec).
2. **Fix Code & Re-run:** Update test code/models and re-verify until test PASSES stably.

---

## 7. OWASP API Security & Advanced Protocol Checklist (MANDATORY)

All generated API Test Cases **MUST** apply the following advanced security rules:

| # | Test Rule | Description & Expectation | Status Code |
|---|---|---|---|
| 1 | **BOLA / IDOR (Broken Object Level Auth)** | User A sends their own token but modifies `id` to User B's resource in URL/Body. | **403 Forbidden** |
| 2 | **Mass Assignment** | Send unauthorized administrative/system properties (`role: "ADMIN"`, `isAdmin: true`, `createdAt`, `id`). | **200/201** (sanitized) or **400** |
| 3 | **Content Negotiation & Content-Type** | Send `Content-Type: text/plain` or `application/xml` instead of `application/json`. | **415 Unsupported Media Type** |
| 4 | **Malformed Payload** | Send JSON Request Body with syntax errors (`{ "name": }`). | **400 Bad Request** |
| 5 | **Oversized Payload** | Send Request Body exceeding payload size limits (e.g. > 10MB JSON). | **413 Payload Too Large** |
| 6 | **Unrestricted Resource Consumption** | Spam N requests rapidly within a very short timeframe. | **429 Too Many Requests** |
| 7 | **Race Condition / Concurrency** | Send 2 parallel requests creating duplicate unique data at the exact same millisecond. | 1 **201 Created**, 1 **409 Conflict** |
| 8 | **ReDoS / Stress Payload** | Send extremely long string (e.g. 10,000 chars) in input/password fields to test server resiliency. | **400 / 422** |
| 9 | **Sensitive Data Exposure** | Verify Response Body **NEVER** returns `password`, `hash`, or `secretKey` in any endpoint. | **200 OK** (No Secrets in Body) |
