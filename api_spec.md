# API Specification — Dihaadi App (Full)

**Base URL:** `https://dihaadi-0lje.onrender.com/api/v1`  
**Auth Header:** `Authorization: Bearer <jwt_token>` (where marked ✅)

---

## Status Legend
- ✅ **Implemented** — Service + API call exists in the codebase  
- 🔧 **Mocked** — Screen uses hardcoded/mock data; real API call is **missing**  
- ❌ **Missing** — Screen requires this API but it does not exist at all

---

## 1. Authentication

### 1.1 Login — ✅ Implemented
| Field | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/Auth/login` |
| **Auth Required** | No |

**Request Body:**
```json
{
  "MobileNumber": "9876543210",
  "CountryCode": "+91",
  "Password": "mypassword123"
}
```
**Response:**
```json
{
  "token": "eyJhbGciOi...",
  "user": {
    "id": "guid",
    "name": "Rahul Kumar",
    "email": "rahul@example.com",
    "mobileNumber": "9876543210",
    "countryCode": "+91",
    "roleName": "worker | owner",
    "isVerified": true,
    "referralCode": "ABC123",
    "roleId": "guid",
    "isTearmAccepted": true,
    "userAddresses": []
  }
}
```

---

### 1.2 Send OTP — ✅ Implemented
| Field | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/Auth/otpRequest` |
| **Auth Required** | No |

**Request Body:**
```json
{ "MobileNumber": "9876543210", "CountryCode": "+91" }
```
**Response:** `200 OK`

---

### 1.3 Verify OTP — ✅ Implemented
| Field | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/Auth/otpVerify` |
| **Auth Required** | No |

**Request Body:**
```json
{ "MobileNumber": "9876543210", "CountryCode": "+91", "OtpCode": "123456", "OtpType": 0 }
```
**Response:**
```json
{ "token": "eyJhbGciOi..." }
```

---

### 1.4 Reset Password — ✅ Implemented
| Field | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/Auth/resetPassword` |
| **Auth Required** | No |

**Request Body:**
```json
{ "token": "reset_token_string", "newPassword": "newpassword123" }
```
**Response:** `200 OK`

---

## 2. User / Profile

### 2.1 Register (Create User) — ✅ Implemented
| Field | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/User/create` |
| **Auth Required** | No |

**Request Body:**
```json
{
  "Name": "Rahul Kumar",
  "Email": "rahul@example.com",
  "Image": "optional_image_path",
  "MobileNumber": "9876543210",
  "CountryCode": "+91",
  "AadharNo": "123412341234",
  "Password": "mypassword123",
  "Address": "123 Main Street",
  "City": "Mumbai",
  "State": "Maharashtra",
  "Pincode": "400001",
  "Country": "India",
  "Role": 0,
  "WorkTypeIds": ["guid-1", "guid-2"]
}
```
> `Role`: `0` = Worker, `1` = Owner

**Response:** `200 OK` or `201 Created`

---

### 2.2 Get Current User Profile — ✅ Implemented
| Field | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/User/details` |
| **Auth Required** | Yes |

**Response:**
```json
{
  "data": {
    "id": "guid",
    "name": "Rahul Kumar",
    "email": "rahul@example.com",
    "mobileNumber": "9876543210",
    "countryCode": "+91",
    "aadharNo": "123412341234",
    "roleName": "worker | owner",
    "referralCode": "ABC123",
    "isVerified": true,
    "roleId": "guid",
    "isTearmAccepted": true,
    "userAddresses": [
      { "address": "...", "city": "...", "state": "...", "pincode": "...", "country": "..." }
    ]
  }
}
```

---

### 2.3 Update User Profile — ✅ Implemented
| Field | Value |
|---|---|
| **Method** | `PUT` |
| **Endpoint** | `/User/update` |
| **Auth Required** | Yes |

**Request Body:**
```json
{
  "Name": "Rahul Kumar",
  "Email": "rahul@example.com",
  "AadharNo": "123412341234",
  "MobileNumber": "9876543210",
  "CountryCode": "+91",
  "Address": "New Street",
  "City": "Pune",
  "State": "Maharashtra",
  "Pincode": "411014",
  "Country": "India"
}
```
**Response:** `200 OK`

---

### 2.4 Get Worker/User Profile by ID — ❌ Missing
> **Used on:** `ApplicantProfileScreen` (Owner views a worker's profile with name, gender, experience, mobile)

| Field | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/User/{userId}` |
| **Auth Required** | Yes |

**Response:**
```json
{
  "data": {
    "id": "guid",
    "name": "Rahul Kumar",
    "mobileNumber": "9876543210",
    "gender": "Male",
    "experienceYears": 5,
    "workTypes": [{ "id": "guid", "name": "Electrician" }],
    "rating": 4.5,
    "totalJobs": 24,
    "aadharNo": "123412341234"
  }
}
```

---

## 3. Requirements (Jobs)

### 3.1 Create Requirement — ✅ Implemented
| Field | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/Requirement/create` |
| **Auth Required** | Yes |

**Request Body:**
```json
{
  "WorkTypeIds": ["guid-1"],
  "Title": "Construction Labour Needed",
  "Description": "Need strong workers for site...",
  "PersonNeed": 5,
  "MaleCount": 3,
  "FemaleCount": 2,
  "DutyStartTime": "2026-04-10T00:00:00Z",
  "DutyEndTime": "2026-04-20T00:00:00Z",
  "Salary": 600.0,
  "Address": "Plot 45, Sector 7",
  "City": "Pune",
  "State": "Maharashtra",
  "Pincode": "411014",
  "Country": "India",
  "Images": ["https://cdn.example.com/img1.jpg"]
}
```
**Response:** `200 OK` or `201 Created`

---

### 3.2 Update Requirement — ✅ Implemented
| Field | Value |
|---|---|
| **Method** | `PUT` |
| **Endpoint** | `/Requirement/{id}` |
| **Auth Required** | Yes |

**Request Body:** Same as Create Requirement  
**Response:** `200 OK`

---

### 3.3 Delete Requirement — ❌ Missing
> **Used on:** `OwnerRequirementDetailScreen` (Delete menu option — currently shows "coming soon")

| Field | Value |
|---|---|
| **Method** | `DELETE` |
| **Endpoint** | `/Requirement/{id}` |
| **Auth Required** | Yes |

**Response:** `200 OK` or `204 No Content`

---

### 3.4 Change Requirement Status (Hold/Activate) — ❌ Missing
> **Used on:** `OwnerRequirementDetailScreen` (Hold menu option — currently shows "coming soon")

| Field | Value |
|---|---|
| **Method** | `PUT` / `PATCH` |
| **Endpoint** | `/Requirement/{id}/status` |
| **Auth Required** | Yes |

**Request Body:**
```json
{ "status": 2 }
```
> `status`: `0` = Draft, `1` = Active, `2` = On Hold, `3` = Completed

**Response:** `200 OK`

---

### 3.5 List Requirements (Owner/Worker) — ✅ Implemented
| Field | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/Requirement/Owner` |
| **Auth Required** | Yes |

**Request Body:**
```json
{ "status": 1, "search": "construction", "workTypeId": "guid", "page": 1, "limit": 10 }
```
**Response:**
```json
{
  "data": [{
    "id": "guid",
    "title": "Site Labour Needed",
    "description": "...",
    "workTypeIds": ["guid"],
    "workTypes": [{ "id": "guid", "name": "Construction", "description": "..." }],
    "dutyStartTime": "2026-04-10T00:00:00Z",
    "dutyEndTime": "2026-04-20T00:00:00Z",
    "salary": 600.0,
    "status": 1,
    "personNeed": 5,
    "fullAddress": "Plot 45, Sector 7, Pune",
    "userId": "guid",
    "date": "2026-04-09T00:00:00Z"
  }]
}
```

---

### 3.6 Apply for a Requirement — ✅ Implemented
| Field | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/Requirement/apply/{requirementId}` |
| **Auth Required** | Yes |

**Body:** None  
**Response:** `200 OK`

---

### 3.7 Get My Applications (Worker) — ✅ Implemented
| Field | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/Requirement/my-applications` |
| **Auth Required** | Yes |

**Response:** Array of Requirement objects (with application `status` per item)
```json
[{ ...Requirement object with status: 0|1|2|3 ... }]
```
> `status`: `0`=Pending, `1`=Accepted, `2`=Rejected, `3`=Completed

---

### 3.8 Get Requirement by ID — ✅ Implemented
| Field | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/Requirement/{id}` |
| **Auth Required** | Yes |

**Response:** `{ "data": { ...Requirement object... } }`

---

## 4. Applications (Owner Side)

### 4.1 Get Applicants for a Requirement — 🔧 Mocked
> **Used on:** `OwnerApplicationsScreen` — currently returns **mock data**

| Field | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/Requirement/{requirementId}/applicants` |
| **Auth Required** | Yes |

**Response:**
```json
{
  "data": [{
    "id": "guid",
    "userId": "guid",
    "requirementId": "guid",
    "workerName": "Rahul Kumar",
    "gender": "Male",
    "experienceYears": 5,
    "mobileNumber": "+91 9876543210",
    "status": 0,
    "appliedDate": "2026-04-09T10:00:00Z",
    "workTypes": ["Electrician", "Wiring"]
  }]
}
```

---

### 4.2 Accept Applicant — 🔧 Mocked
> **Used on:** `OwnerApplicationsScreen` and `ApplicantProfileScreen` — currently updates local state only

| Field | Value |
|---|---|
| **Method** | `PUT` |
| **Endpoint** | `/Requirement/{requirementId}/applicants/{applicantId}/accept` |
| **Auth Required** | Yes |

**Body:** None  
**Response:** `200 OK`

---

### 4.3 Reject Applicant — 🔧 Mocked
> **Used on:** `OwnerApplicationsScreen` and `ApplicantProfileScreen` — currently updates local state only

| Field | Value |
|---|---|
| **Method** | `PUT` |
| **Endpoint** | `/Requirement/{requirementId}/applicants/{applicantId}/reject` |
| **Auth Required** | Yes |

**Body:** None  
**Response:** `200 OK`

---

## 5. Ratings & Reviews

### 5.1 Rate a Worker (Owner rates Worker) — 🔧 Mocked
> **Used on:** `WorkerRatingScreen` — uses `Future.delayed` simulation

| Field | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/Rating/worker` |
| **Auth Required** | Yes |

**Request Body:**
```json
{
  "workerId": "guid",
  "requirementId": "guid",
  "rating": 5,
  "feedback": "Excellent work, very professional",
  "tags": ["Skilled worker", "Completed on time", "Would hire again"]
}
```
**Response:** `200 OK` or `201 Created`

---

### 5.2 Rate an Owner/Employer (Worker rates Owner) — 🔧 Mocked
> **Used on:** `WorkerRateOwnerScreen` — uses `Future.delayed` simulation

| Field | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/Rating/owner` |
| **Auth Required** | Yes |

**Request Body:**
```json
{
  "ownerId": "guid",
  "requirementId": "guid",
  "rating": 4,
  "feedback": "Good communication and fair payment",
  "tags": ["Good communication", "Fair payment", "Safe working conditions"]
}
```
**Response:** `200 OK` or `201 Created`

---

## 6. Chat / Messaging

### 6.1 Get Conversation List — 🔧 Mocked
> **Used on:** `WorkerChatListScreen` and `OwnerChatListScreen` — hardcoded static list

| Field | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/Chat/conversations` |
| **Auth Required** | Yes |

**Response:**
```json
{
  "data": [{
    "id": "conv-guid",
    "participantId": "guid",
    "participantName": "Rajesh Kumar",
    "participantImage": "https://cdn.example.com/avatar.jpg",
    "jobTitle": "Electrician Needed",
    "requirementId": "guid",
    "lastMessage": "Please reach the site by 10 AM",
    "lastMessageTime": "2026-04-09T08:30:00Z",
    "unreadCount": 2,
    "isOnline": true
  }]
}
```

---

### 6.2 Get Messages in a Conversation — 🔧 Mocked
> **Used on:** `WorkerChatDetailScreen` and `OwnerChatDetailScreen` — hardcoded messages

| Field | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/Chat/conversations/{conversationId}/messages` |
| **Auth Required** | Yes |

**Query Params:** `?page=1&limit=50`

**Response:**
```json
{
  "data": [{
    "id": "msg-guid",
    "senderId": "guid",
    "text": "Hi, your application has been accepted!",
    "timestamp": "2026-04-09T08:00:00Z",
    "status": "read"
  }]
}
```

---

### 6.3 Send a Message — 🔧 Mocked
> **Used on:** `WorkerChatDetailScreen` and `OwnerChatDetailScreen` — adds to local list only, no API call

| Field | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/Chat/conversations/{conversationId}/messages` |
| **Auth Required** | Yes |

**Request Body:**
```json
{ "text": "I'll be there at 10 AM, thank you!" }
```
**Response:**
```json
{
  "id": "msg-guid",
  "senderId": "guid",
  "text": "I'll be there at 10 AM, thank you!",
  "timestamp": "2026-04-09T09:00:00Z",
  "status": "sent"
}
```

---

### 6.4 Mark Job as Completed — 🔧 Mocked
> **Used on:** `WorkerChatDetailScreen` — only updates local `_isJobCompleted` flag, no API call

| Field | Value |
|---|---|
| **Method** | `PUT` |
| **Endpoint** | `/Requirement/{requirementId}/complete` |
| **Auth Required** | Yes |

**Body:** None  
**Response:** `200 OK`

---

## 7. Notifications

### 7.1 Get Notifications — 🔧 Mocked
> **Used on:** `NotificationsScreen` — displays a hardcoded static list; no API call

| Field | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/Notification/list` |
| **Auth Required** | Yes |

**Query Params:** `?page=1&limit=20`

**Response:**
```json
{
  "data": [{
    "id": "notif-guid",
    "title": "Application Accepted",
    "body": "Your application has been accepted by an owner.",
    "type": "application_accepted | application_rejected | new_applicant | new_job",
    "isRead": false,
    "createdAt": "2026-04-09T08:00:00Z",
    "referenceId": "guid"
  }]
}
```

---

### 7.2 Mark Notification as Read — ❌ Missing
> Not yet implemented anywhere but needed once real notifications are shown

| Field | Value |
|---|---|
| **Method** | `PUT` |
| **Endpoint** | `/Notification/{id}/read` |
| **Auth Required** | Yes |

**Body:** None  
**Response:** `200 OK`

---

## 8. Dashboard Stats

### 8.1 Owner Dashboard Stats — 🔧 Mocked
> **Used on:** `OwnerDashboardNew` — uses hardcoded values (`activeReq: 12`, `totalApplicants: 48`, etc.)

| Field | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/Dashboard/owner/stats` |
| **Auth Required** | Yes |

**Response:**
```json
{
  "data": {
    "activeRequirements": 12,
    "totalApplicants": 48,
    "hiredWorkers": 5,
    "completedJobs": 24
  }
}
```

---

## 9. Work Types

### 9.1 List Work Types — ✅ Implemented
| Field | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/WorkType/list` |
| **Auth Required** | No |

**Response:**
```json
{
  "data": [{ "id": "guid", "name": "Construction", "description": "Heavy work", "icon": "url" }]
}
```

---

## 10. Places / Address Autocomplete

### 10.1 Search Places — ✅ Implemented
| Field | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/common/places/search?query=Mumbai` |
| **Auth Required** | No |

**Response:**
```json
{
  "data": {
    "predictions": [{
      "place_id": "ChIJ...",
      "description": "Mumbai, Maharashtra, India",
      "structured_formatting": {
        "main_text": "Mumbai",
        "secondary_text": "Maharashtra, India"
      }
    }]
  }
}
```

---

### 10.2 Get Place Details — ✅ Implemented
| Field | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/common/places/details/{placeId}` |
| **Auth Required** | No |

**Response:**
```json
{
  "data": {
    "result": {
      "formatted_address": "Mumbai, Maharashtra 400001, India",
      "address_components": [
        { "long_name": "Mumbai", "short_name": "Mumbai", "types": ["locality"] },
        { "long_name": "Maharashtra", "short_name": "MH", "types": ["administrative_area_level_1"] },
        { "long_name": "India", "short_name": "IN", "types": ["country"] },
        { "long_name": "400001", "short_name": "400001", "types": ["postal_code"] }
      ]
    }
  }
}
```

---

## 11. Common / Uploads

### 11.1 Upload Image — ✅ Implemented
| Field | Value |
|---|---|
| **Method** | `POST` (multipart/form-data) |
| **Endpoint** | `/common/upload-image` |
| **Auth Required** | Yes |

**Request:** `file: <binary image>`  
**Response:** `{ "imageUrl": "https://cdn.example.com/uploads/abc123.jpg" }`

---

## Full Summary Table

| # | Method | Endpoint | Auth | Status |
|---|--------|----------|------|--------|
| 1 | POST | `/Auth/login` | ❌ | ✅ Done |
| 2 | POST | `/Auth/otpRequest` | ❌ | ✅ Done |
| 3 | POST | `/Auth/otpVerify` | ❌ | ✅ Done |
| 4 | POST | `/Auth/resetPassword` | ❌ | ✅ Done |
| 5 | POST | `/User/create` | ❌ | ✅ Done |
| 6 | GET | `/User/details` | ✅ | ✅ Done |
| 7 | PUT | `/User/update` | ✅ | ✅ Done |
| 8 | GET | `/User/{userId}` | ✅ | ❌ Missing |
| 9 | POST | `/Requirement/create` | ✅ | ✅ Done |
| 10 | PUT | `/Requirement/{id}` | ✅ | ✅ Done |
| 11 | DELETE | `/Requirement/{id}` | ✅ | ❌ Missing |
| 12 | PUT | `/Requirement/{id}/status` | ✅ | ❌ Missing |
| 13 | POST | `/Requirement/Owner` | ✅ | ✅ Done |
| 14 | POST | `/Requirement/apply/{id}` | ✅ | ✅ Done |
| 15 | GET | `/Requirement/my-applications` | ✅ | ✅ Done |
| 16 | GET | `/Requirement/{id}` | ✅ | ✅ Done |
| 17 | GET | `/Requirement/{id}/applicants` | ✅ | 🔧 Mocked |
| 18 | PUT | `/Requirement/{id}/applicants/{id}/accept` | ✅ | 🔧 Mocked |
| 19 | PUT | `/Requirement/{id}/applicants/{id}/reject` | ✅ | 🔧 Mocked |
| 20 | PUT | `/Requirement/{id}/complete` | ✅ | 🔧 Mocked |
| 21 | POST | `/Rating/worker` | ✅ | 🔧 Mocked |
| 22 | POST | `/Rating/owner` | ✅ | 🔧 Mocked |
| 23 | GET | `/Chat/conversations` | ✅ | 🔧 Mocked |
| 24 | GET | `/Chat/conversations/{id}/messages` | ✅ | 🔧 Mocked |
| 25 | POST | `/Chat/conversations/{id}/messages` | ✅ | 🔧 Mocked |
| 26 | GET | `/Notification/list` | ✅ | 🔧 Mocked |
| 27 | PUT | `/Notification/{id}/read` | ✅ | ❌ Missing |
| 28 | GET | `/Dashboard/owner/stats` | ✅ | 🔧 Mocked |
| 29 | GET | `/WorkType/list` | ❌ | ✅ Done |
| 30 | GET | `/common/places/search` | ❌ | ✅ Done |
| 31 | GET | `/common/places/details/{placeId}` | ❌ | ✅ Done |
| 32 | POST | `/common/upload-image` | ✅ | ✅ Done |

---

## Summary by Status

| Status | Count | Description |
|--------|-------|-------------|
| ✅ Implemented | 17 | Fully wired in the codebase |
| 🔧 Mocked | 11 | Screen UI is built, hardcoded/mock data is used — **backend needed** |
| ❌ Missing | 4 | Feature is in the UI but API does not exist at all |
