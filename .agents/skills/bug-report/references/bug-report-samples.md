**Bug ID:** OHRM-REC-001

**Summary:** Candidate and Status columns do not sort records correctly in Candidates list

**Module:** Recruitment \> Candidates

**Environment:**

* OrangeHRM Open Source Demo  
* URL: [https://opensource-demo.orangehrmlive.com/](https://opensource-demo.orangehrmlive.com/)  
* Browser: Chrome   
* OS: Windows 11  
* Date: 11-Aug-2026

**Precondition:**

* User is logged in as Admin.  
* At least three candidate records with different Candidate names and Status values exist.

**Steps to Reproduce:**

1. Login as Admin.  
2. Navigate to **Recruitment \> Candidates**.  
3. Click the sort control on the **Candidate** column.  
4. Observe the displayed order of candidate names.  
5. Click the sort control again to reverse the order.  
6. Repeat steps 3-5 for the **Status** column.

**Test Data:**

* Existing candidate records available in the OrangeHRM demo environment.

**Actual Result:**  
The records displayed in the **Candidate** and **Status** columns are not sorted correctly after applying ascending or descending sorting. The resulting order does not follow a consistent sorting rule.

**Expected Result:**  
Records in the **Candidate** and **Status** columns should be sorted correctly in ascending and descending order according to the application’s defined sorting rule.

**Severity:** Medium

**Priority:** High

**Reproducibility:** Always

**Bug ID:** OHRM-REC-002

**Summary:** Candidate list sorting is not preserved after returning from Candidate details using the browser Back button

**Module:** Recruitment \> Candidates

**Environment:**

* OrangeHRM Open Source Demo  
* URL: [https://opensource-demo.orangehrmlive.com/](https://opensource-demo.orangehrmlive.com/)  
* Browser: Chrome   
* OS: Windows 11  
* Date: 11-Aug-2026

**Precondition:**

* User is logged in as Admin.  
* At least three candidate records exist.  
* A sortable column (e.g., Candidate, Vacancy, Status, Hiring Manager, or Date of Application) has been sorted in ascending or descending order.

**Steps to Reproduce:**

1. Login as Admin.  
2. Navigate to **Recruitment \> Candidates**.  
3. Sort any supported column in ascending or descending order.  
4. Note the active sort indicator and the order of the first few records.  
5. Open a candidate using the **View** action.  
6. Return to the Candidate List using the browser **Back** button.

**Test Data:**

* Existing candidate records in the OrangeHRM demo environment.

**Actual Result:**  
The previously applied sorting is cleared after returning from Candidate details, and the Candidate List is displayed in its default order.

**Expected Result:**  
The previously applied sorting should remain active and the Candidate List should preserve the same sorted order after returning from Candidate details.

**Severity:** Low

**Priority:** Medium

**Reproducibility:** Always

**Status Recommendation:** Need Clarification / Suspected Bug

**Bug ID:** OHRM-REC-003

**Summary:** Resume download redirects to browser HTTP 400 error page after the resume is deleted in another active session

**Module:** Recruitment \> Candidates

**Environment:**

* OrangeHRM Open Source Demo  
* URL: [https://opensource-demo.orangehrmlive.com/](https://opensource-demo.orangehrmlive.com/)  
* Browser: Google Chrome   
* OS: Windows 11  
* Date: 11-Aug-2026

**Precondition:**

* Two browser sessions (Session A and Session B) are logged in as Admin.  
* Candidate **CAND-RES-STALE** initially has a resume attached.  
* Session B is on the Candidate List page and displays the **Download** action for the candidate.

**Steps to Reproduce:**

1. In **Session B**, open **Recruitment \> Candidates** and confirm that **CAND-RES-STALE** shows the **Download** action.  
2. In **Session A**, open the same candidate profile in **Edit** mode.  
3. Remove the existing resume and save the changes.  
4. Return to **Session B** without refreshing the Candidate List.  
5. Click **Download** for **CAND-RES-STALE**.

**Test Data:**

* Candidate: CAND-RES-STALE  
* Initial resume: RES-STALE

**Actual Result:**  
The application redirects to a browser error page displaying **HTTP ERROR 400** instead of handling the stale download request within the application.

**Expected Result:**  
The system should safely handle the stale download request by displaying an appropriate in-application error message or preventing the download, and should not redirect the user to a browser HTTP error page.

**Severity:** Medium

**Priority:** Medium

**Reproducibility:** Always

**Bug ID:** OHRM-REC-004

**Summary:** Emoji characters entered in Candidate Name fields are converted to question marks after saving

**Module:** Recruitment \> Candidates \> Add Candidate

**Environment:**

* OrangeHRM Open Source Demo  
* URL: [https://opensource-demo.orangehrmlive.com/](https://opensource-demo.orangehrmlive.com/)  
* Browser: Google Chrome  
* OS: Windows 11  
* Date: 11-Aug-2026

**Precondition:**

* User is logged in as Admin.  
* Other required candidate information is valid and unique.

**Steps to Reproduce:**

1. Login as Admin.  
2. Navigate to **Recruitment \> Candidates**.  
3. Click **Add**.  
4. Enter a valid First Name and Last Name.  
5. Enter an emoji in the **Middle Name** field (e.g., **😀**).  
6. Complete the remaining required fields with valid data.  
7. Click **Save**.  
8. Reopen the saved candidate profile and inspect the Middle Name field.

**Test Data:**

* First Name: Alice😂🤣  
* Middle Name: 😀  
* Last Name: Nguyen

**Actual Result:**  
The emoji entered in the Name field is automatically converted to the character **?** after saving.

**Expected Result:**  
The system should either preserve the entered emoji exactly as submitted or reject the input with a clear validation message. It should not silently replace the emoji with a question mark.

**Severity:** Medium

**Priority:** Medium

**Reproducibility:** Always

**Bug ID:** OHRM-REC-005

**Summary:** System allows creation of a Candidate record with data identical to an existing Candidate

**Module:** Recruitment \> Candidates \> Add Candidate

**Environment:**

* OrangeHRM Open Source Demo  
* URL: [https://opensource-demo.orangehrmlive.com/](https://opensource-demo.orangehrmlive.com/)  
* Browser: Google Chrome  
* OS: Windows 11  
* Date: 11-Aug-2026

**Precondition:**

* User is logged in as Admin.  
* Candidate **CAND-DUP-A** already exists.  
* The complete data of **CAND-DUP-A** is known.

**Steps to Reproduce:**

1. Login as Admin.  
2. Navigate to **Recruitment \> Candidates**.  
3. Click **Add**.  
4. Enter exactly the same data as **CAND-DUP-A** (First Name, Middle Name, Last Name, Email, Contact Number, Vacancy, Keywords, Date of Application, Notes, and Consent).  
5. Click **Save**.  
6. Return to **Candidate List**.  
7. Search for the duplicated candidate data.

**Test Data:**

* Existing candidate: **CAND-DUP-A**  
* New candidate: identical values for all available fields.

**Actual Result:**  
A new Candidate record is created successfully even though all entered data is identical to an existing Candidate record.

**Expected Result:**  
The system should prevent creation of a Candidate record with data identical to an existing Candidate and display an appropriate duplicate-record notification.

**Severity:** Medium

**Priority:** Medium

**Reproducibility:** Always

**Status Recommendation:** Need Clarification / Suspected Bug

**Bug ID:** OHRM-REC-006

**Summary:** No validation or error message is displayed when uploading a zero-byte Resume file during Candidate creation

**Module:** Recruitment \> Candidates \> Add Candidate

**Environment:**

* OrangeHRM Open Source Demo  
* URL: [https://opensource-demo.orangehrmlive.com/](https://opensource-demo.orangehrmlive.com/)  
* Browser: Google Chrome  
* OS: Windows 11  
* Date: 11-Aug-2026

**Precondition:**

* User is logged in as Admin.  
* Add Candidate form is open.  
* Required Candidate fields contain valid data.

**Steps to Reproduce:**

1. Login as Admin.  
2. Navigate to **Recruitment \> Candidates**.  
3. Click **Add**.  
4. Fill all required Candidate fields with valid data.  
5. Select a **0-byte Resume file** (e.g., EMPTY.pdf).  
6. Click **Save**.

**Test Data:**

* Resume file: EMPTY.pdf (0 KB / 0 byte)

**Actual Result:**  
The Resume file is not uploaded, but the system does not display any validation message, error message, or other feedback indicating why the upload failed.

**Expected Result:**  
The system should provide clear feedback when a zero-byte Resume file cannot be uploaded, such as a validation or error message explaining that the file is invalid or unsupported. The upload outcome should be communicated explicitly to the user.

**Severity:** Medium

**Priority:** Medium

**Reproducibility:** Always

**Bug ID:** OHRM-REC-007

**Summary:** Candidate Name autocomplete does not display suggestions for a valid full name containing spaces

**Module:** Recruitment \> Candidates \> Search

**Environment:**

* OrangeHRM Open Source Demo  
* URL: [https://opensource-demo.orangehrmlive.com/](https://opensource-demo.orangehrmlive.com/)  
* Browser: Google Chrome  
* OS: Windows 11  
* Date: 11-Aug-2026

**Precondition:**

* User is logged in as Admin.  
* A candidate with a known full name containing a space (e.g., **John Smith**) already exists.  
* The Candidate List page is loaded.

**Steps to Reproduce:**

1. Login as Admin.  
2. Navigate to **Recruitment \> Candidates**.  
3. Click the **Candidate Name** search field.  
4. Enter the exact full name of an existing candidate, including the space (e.g., **John Smith**).  
5. Observe the autocomplete suggestions.

**Test Data:**

* Existing candidate full name containing at least one space.

**Actual Result:**  
No autocomplete suggestion is displayed even when the exact valid full name containing a space is entered.

**Expected Result:**  
The autocomplete suggestion list should display the matching candidate when the user enters a valid existing full name, including names that contain spaces.

**Severity:** Medium

**Priority:** High

**Reproducibility:** Always

**Bug ID:** OHRM-REC-008

**Summary:** Candidate search rejects a valid single-day date range when From Date equals To Date

**Module:** Recruitment \> Candidates \> Search

**Environment:**

* OrangeHRM Open Source Demo  
* URL: [https://opensource-demo.orangehrmlive.com/](https://opensource-demo.orangehrmlive.com/)  
* Browser: Google Chrome  
* OS: Windows 11  
* Date: 11-Aug-2026

**Precondition:**

* User is logged in as Admin.  
* At least one candidate exists with **Date of Application \= target date**.

**Steps to Reproduce:**

1. Login as Admin.  
2. Navigate to **Recruitment \> Candidates**.  
3. Enter the same valid date in **From Date** and **To Date** (e.g., **2026-08-01**).  
4. Click **Search**.

**Test Data:**

* From Date: 2026-08-01  
* To Date: 2026-08-01

**Actual Result:**  
The system displays a toast notification indicating that **From Date must be earlier than To Date**, and the search is not executed.

**Expected Result:**  
The system should accept **From Date \= To Date** as a valid single-day search range and return candidates whose **Date of Application** equals the selected date.

**Severity:** Medium

**Priority:** Medium

**Reproducibility:** Always

**Bug ID:** OHRM-REC-009

**Summary:** Resume download from Candidate Profile returns HTTP 400 after the resume is removed in another active session

**Module:** Recruitment \> Candidates \> Candidate Profile

**Environment:**

* OrangeHRM Open Source Demo  
* URL: [https://opensource-demo.orangehrmlive.com/](https://opensource-demo.orangehrmlive.com/)  
* Browser: Google Chrome  
* OS: Windows 11  
* Date: 11-Aug-2026

**Precondition:**

* Two browser sessions (Session A and Session B) are logged in as Admin.  
* Candidate **RES-STALE** initially has a resume attached.  
* Session B keeps the Candidate Profile page open before the resume is removed.

**Steps to Reproduce:**

1. In **Session B**, open the profile of **RES-STALE**.  
2. In **Session A**, open the same candidate profile in **Edit** mode.  
3. Remove the existing resume and save the changes.  
4. Return to **Session B** without refreshing the page.  
5. Click **Download** for the stale resume.

**Test Data:**

* Candidate: RES-STALE  
* Initial resume: existing attached file

**Actual Result:**  
The application redirects to a browser error page displaying **HTTP ERROR 400** when attempting to download the stale resume from the Candidate Profile page.

**Expected Result:**  
The system should safely handle the stale download request by displaying an appropriate in-application error message or preventing the download, and should not redirect the user to a browser HTTP error page.

**Severity:** Medium

**Priority:** Medium

**Reproducibility:** Always

**Bug ID:** OHRM-REC-010

**Summary:** No validation or error message is displayed when replacing an existing Resume with a zero-byte file

**Module:** Recruitment \> Candidates \> Candidate Profile

**Environment:**

* OrangeHRM Open Source Demo  
* URL: [https://opensource-demo.orangehrmlive.com/](https://opensource-demo.orangehrmlive.com/)  
* Browser: Google Chrome  
* OS: Windows 11  
* Date: 11-Aug-2026

**Precondition:**

* User is logged in as Admin.  
* Candidate **RES-EMPTY** has an existing resume attached.  
* Edit mode is enabled.

**Steps to Reproduce:**

1. Login as Admin.  
2. Navigate to **Recruitment \> Candidates**.  
3. Open candidate **RES-EMPTY**.  
4. Click **Edit**.  
5. Select a **0-byte Resume file** (e.g., **EMPTY.pdf**) as a replacement for the existing resume.  
6. Click **Save**.

**Test Data:**

* Existing Resume: OLD\_RESUME.pdf  
* Replacement Resume: EMPTY.pdf (0 KB / 0 byte)

**Actual Result:**  
The zero-byte file is not uploaded, but the system does not display any validation message, error message, or other feedback indicating why the replacement failed.

**Expected Result:**  
The system should provide clear feedback when a zero-byte Resume file cannot be uploaded as a replacement, such as a validation or error message explaining that the file is invalid or unsupported.

**Severity:** Medium

**Priority:** Medium

**Reproducibility:** Always

**Bug ID:** OHRM-REC-011

**Summary:** No validation or error message is displayed when adding a zero-byte Resume to a Candidate without an existing Resume

**Module:** Recruitment \> Candidates \> Candidate Profile

**Environment:**

* OrangeHRM Open Source Demo  
* URL: [https://opensource-demo.orangehrmlive.com/](https://opensource-demo.orangehrmlive.com/)  
* Browser: Google Chrome  
* OS: Windows 11  
* Date: 11-Aug-2026

**Precondition:**

* User is logged in as Admin.  
* Candidate **RES-NONE** has no Resume attached.  
* Edit mode is enabled.

**Steps to Reproduce:**

1. Login as Admin.  
2. Navigate to **Recruitment \> Candidates**.  
3. Open candidate **RES-NONE**.  
4. Click **Edit**.  
5. Select a **0-byte Resume file** (e.g., **EMPTY.pdf**).  
6. Click **Save**.

**Test Data:**

* Resume: EMPTY.pdf (0 KB / 0 byte)

**Actual Result:**  
The zero-byte file is not uploaded, but the system does not display any validation message, error message, or other feedback indicating why the upload failed.

**Expected Result:**  
The system should provide clear feedback when a zero-byte Resume file cannot be uploaded, such as a validation or error message explaining that the file is invalid or unsupported.

**Severity:** Medium

**Priority:** Medium

**Reproducibility:** Always

**Bug ID:** OHRM-REC-012

**Summary:** Candidate Profile remains in endless loading state after stale update request returns “Record not found”

**Module:** Recruitment \> Candidates \> Candidate Profile

**Environment:**

* OrangeHRM Open Source Demo  
* URL: [https://opensource-demo.orangehrmlive.com/](https://opensource-demo.orangehrmlive.com/)  
* Browser: Google Chrome  
* OS: Windows 11  
* Date: 11-Aug-2026

**Precondition:**

* Two browser sessions (Session A and Session B) are logged in as Admin.  
* Candidate **CAND-DEL** exists.  
* Session B has the Candidate Profile page open and Edit mode enabled.

**Steps to Reproduce:**

1. In **Session B**, open **CAND-DEL** Profile and enable **Edit** mode.  
2. In **Session A**, delete **CAND-DEL** from Candidate List and confirm deletion.  
3. Return to **Session B** without refreshing the page.  
4. Modify any editable field.  
5. Click **Save**.

**Test Data:**

* Candidate: CAND-DEL

**Actual Result:**  
The system returns a **“Record not found”** response, but the Candidate Profile page remains in an **endless loading/skeleton state** and does not recover to a usable UI state.

**Expected Result:**  
After detecting that the Candidate record no longer exists, the system should display an appropriate not-found/error message and return the page to a stable state (e.g., navigate back to Candidate List, close Edit mode, or display a recoverable error screen). The loading indicator should stop.

**Severity:** Medium

**Priority:** High

**Reproducibility:** Always

**Bug ID:** OHRM-REC-013

**Summary:** Candidate Notes exceeding the maximum length is not validated before save and leaves the profile page in an endless loading state

**Module:** Recruitment \> Candidates \> Candidate Profile

**Environment:**

* OrangeHRM Open Source Demo  
* URL: [https://opensource-demo.orangehrmlive.com/](https://opensource-demo.orangehrmlive.com/)  
* Browser: Google Chrome  
* OS: Windows 11  
* Date: 11-Aug-2026

**Precondition:**

* User is logged in as Admin.  
* Candidate **CAND-NOTES** exists.  
* Edit mode is enabled.

**Steps to Reproduce:**

1. Login as Admin.  
2. Navigate to **Recruitment \> Candidates**.  
3. Open candidate **CAND-NOTES**.  
4. Click **Edit**.  
5. Enter a **Notes** value exceeding the maximum allowed length (e.g., **251 characters**).  
6. Click **Save**.

**Test Data:**

* Notes: 251-character string (max \+ 1\)

**Actual Result:**  
The system does not display a maximum-length validation for the **Notes** field before saving. After clicking **Save**, a toast notification **“Invalid Parameter”** is displayed and the Candidate Profile page enters an **endless loading/skeleton state**.

**Expected Result:**  
The system should validate the **Notes** field against the maximum allowed length before submitting the update, display an appropriate validation message, prevent the update from being saved, and return the page to a stable state without entering an endless loading condition.

**Severity:** Medium

**Priority:** High

**Reproducibility:** Always