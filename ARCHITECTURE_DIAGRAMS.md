# Implementation Architecture & Flow Diagrams

## 1. Form Structure Overview

```
┌─────────────────────────────────────────────────────────┐
│                  CreateRequirementScreen                 │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │         SECTION 1: Job Details                   │   │
│  ├──────────────────────────────────────────────────┤   │
│  │  Work Type:        [Dropdown ▼]                  │   │
│  │  Job Title:        [Text Field]                  │   │
│  │  Description:      [Text Area (3 lines)]         │   │
│  │  Salary:           [Number Field]                │   │
│  └──────────────────────────────────────────────────┘   │
│                                                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │       SECTION 2: Location Details                │   │
│  ├──────────────────────────────────────────────────┤   │
│  │  Search Address:   [Text Field + Google Search]  │   │
│  │                    ┌─ Prediction 1              │   │
│  │                    ├─ Prediction 2              │   │
│  │                    ├─ Prediction 3              │   │
│  │                    └─ Prediction 4              │   │
│  │  City:             [Text Field - Auto-fill]     │   │
│  │  State:            [Text Field - Auto-fill]     │   │
│  │  Pincode:          [Number Field - Auto-fill]   │   │
│  │  Country:          [Text Field - Auto-fill]     │   │
│  └──────────────────────────────────────────────────┘   │
│                                                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │     SECTION 3: People Requirements               │   │
│  ├──────────────────────────────────────────────────┤   │
│  │  Total Needed:  [- 1 +]  (1-999)                │   │
│  │  Male Count:    [- 1 +]  (max: Total)           │   │
│  │  Female Count:  [- 0 +]  (max: Total)           │   │
│  └──────────────────────────────────────────────────┘   │
│                                                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │       SECTION 4: Duty Duration                   │   │
│  ├──────────────────────────────────────────────────┤   │
│  │  Start Date:       [Date Picker: 01/01/2025]   │   │
│  │  End Date:         [Date Picker: 02/01/2025]   │   │
│  └──────────────────────────────────────────────────┘   │
│                                                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │  [Create Requirement Button / Loading...]        │   │
│  └──────────────────────────────────────────────────┘   │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Google Places API Integration Flow

```
USER INTERACTION FLOW:
═════════════════════════════════════════════════════════════

START
  │
  ├─ User Opens Create Requirement Screen
  │
  ├─ User Types in "Search Address" Field
  │  │
  │  └─→ _searchPlaces(input) called
  │      │
  │      └─→ HTTP Request to Google Places API
  │          │
  │          ├─ Endpoint: /place/autocomplete/json
  │          ├─ Parameter: input text
  │          ├─ Parameter: API Key
  │          ├─ Parameter: country=in (India)
  │          │
  │          └─→ Response with Predictions List
  │              │
  │              ├─ placeId
  │              ├─ mainText (place name)
  │              ├─ secondaryText (address)
  │              └─ description
  │
  ├─ Dropdown Shows Predictions to User
  │  │
  │  ├─ Prediction 1: India Gate, New Delhi
  │  ├─ Prediction 2: Gate No. 1, India Gate Complex
  │  ├─ Prediction 3: India Gate Lawn, New Delhi
  │  │
  │  └─ User Taps on Prediction
  │
  ├─ _getPlaceDetails(placeId) Called
  │  │
  │  └─→ HTTP Request to Google Places Details API
  │      │
  │      ├─ Endpoint: /place/details/json
  │      ├─ Parameter: placeId
  │      ├─ Parameter: API Key
  │      │
  │      └─→ Response with Place Details
  │          │
  │          ├─ formatted_address: "India Gate, New Delhi, Delhi 110001, India"
  │          ├─ address_components:
  │          │  ├─ street_number
  │          │  ├─ route
  │          │  ├─ locality (City)
  │          │  ├─ administrative_area_level_1 (State)
  │          │  ├─ postal_code (Pincode)
  │          │  └─ country
  │          │
  │          └─ geometry:
  │             ├─ lat
  │             └─ lng
  │
  ├─ Auto-Fill Location Fields
  │  │
  │  ├─ Address:     "India Gate, New Delhi, Delhi 110001, India"
  │  ├─ City:        "New Delhi"
  │  ├─ State:       "Delhi"
  │  ├─ Pincode:     "110001"
  │  └─ Country:     "India"
  │
  ├─ User Reviews/Modifies Data (Optional)
  │
  ├─ User Completes Other Fields (Title, Description, etc.)
  │
  ├─ User Clicks "Create Requirement" Button
  │  │
  │  └─→ Form Validation
  │      │
  │      ├─ Check Required Fields (✓ or ✗)
  │      ├─ Check Date Range (startDate < endDate)
  │      ├─ Check Gender Count (male + female ≤ total)
  │      │
  │      └─→ If Valid: Proceed to Submit
  │
  ├─ Submit to Backend
  │  │
  │  └─→ HTTP POST to Backend API
  │      │
  │      ├─ Endpoint: /Requirement/Requirement
  │      ├─ Body: CreateRequirementRequest JSON
  │      │  {
  │      │    "WorkTypeId": "1",
  │      │    "Title": "Site Supervisor",
  │      │    "Description": "...",
  │      │    "PersonNeed": 5,
  │      │    "MaleCount": 3,
  │      │    "FemaleCount": 2,
  │      │    "DutyStartTime": "2025-02-01T00:00:00Z",
  │      │    "DutyEndTime": "2025-03-01T00:00:00Z",
  │      │    "Salary": 50000,
  │      │    "Address": "India Gate...",
  │      │    "City": "New Delhi",
  │      │    "State": "Delhi",
  │      │    "Pincode": "110001",
  │      │    "Country": "India"
  │      │  }
  │      │
  │      └─→ Backend Response
  │          │
  │          ├─ Success (200/201)
  │          │  └─→ Show Success Message
  │          │  └─→ Navigate Back
  │          │  └─→ Refresh Requirements List
  │          │
  │          └─→ Error (4xx/5xx)
  │             └─→ Show Error Message
  │             └─→ User Can Retry
  │
  END
```

---

## 3. Data Flow Architecture

```
┌──────────────────────────────────────────────────────────┐
│                   STATE MANAGEMENT                        │
├──────────────────────────────────────────────────────────┤
│                                                            │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  _CreateRequirementScreenState                      │ │
│  │                                                      │ │
│  │  Controllers:                                       │ │
│  │  ├─ titleController                                │ │
│  │  ├─ descController                                 │ │
│  │  ├─ salaryController                               │ │
│  │  ├─ addressController                              │ │
│  │  ├─ cityController                                 │ │
│  │  ├─ stateController                                │ │
│  │  ├─ pincodeController                              │ │
│  │  └─ countryController                              │ │
│  │                                                      │ │
│  │  State Variables:                                   │ │
│  │  ├─ selectedWorkType: String                        │ │
│  │  ├─ personNeed: int                                 │ │
│  │  ├─ maleCount: int                                  │ │
│  │  ├─ femaleCount: int                                │ │
│  │  ├─ dutyStartTime: DateTime?                        │ │
│  │  ├─ dutyEndTime: DateTime?                          │ │
│  │  ├─ _isLoading: bool                                │ │
│  │  ├─ _placePredictions: List<PlacePrediction>       │ │
│  │  └─ _showPredictions: bool                          │ │
│  │                                                      │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  Data Model                                         │ │
│  │                                                      │ │
│  │  PlacePrediction                                    │ │
│  │  ├─ placeId: String                                 │ │
│  │  ├─ description: String                             │ │
│  │  ├─ mainText: String                                │ │
│  │  └─ secondaryText: String                           │ │
│  │                                                      │ │
│  │  CreateRequirementRequest (from models)             │ │
│  │  ├─ workTypeId: String                              │ │
│  │  ├─ title: String                                   │ │
│  │  ├─ description: String                             │ │
│  │  ├─ personNeed: int                                 │ │
│  │  ├─ maleCount: int                                  │ │
│  │  ├─ femaleCount: int                                │ │
│  │  ├─ dutyStartTime: DateTime?                        │ │
│  │  ├─ dutyEndTime: DateTime?                          │ │
│  │  ├─ salary: double?                                 │ │
│  │  ├─ address: String?                                │ │
│  │  ├─ city: String?                                   │ │
│  │  ├─ state: String?                                  │ │
│  │  ├─ pincode: String?                                │ │
│  │  └─ country: String?                                │ │
│  │                                                      │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                            │
└──────────────────────────────────────────────────────────┘

        ↓↓↓ FORM SUBMISSION ↓↓↓

┌──────────────────────────────────────────────────────────┐
│               API COMMUNICATION LAYER                      │
├──────────────────────────────────────────────────────────┤
│                                                            │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  Google Places APIs                                 │ │
│  │  └─ HTTP GET/POST Requests                          │ │
│  │     ├─ Autocomplete API                             │ │
│  │     └─ Details API                                  │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  Backend Service (RequirementService)               │ │
│  │  └─ createRequirement(CreateRequirementRequest)     │ │
│  │     └─ HTTP POST to Backend API                     │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  ViewModel Layer (OwnerViewModel)                   │ │
│  │  └─ createRequirement(request)                      │ │
│  │     ├─ Call service                                 │ │
│  │     ├─ Refresh requirements list                    │ │
│  │     └─ Notify listeners                             │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                            │
└──────────────────────────────────────────────────────────┘

        ↓↓↓ RESPONSE HANDLING ↓↓↓

┌──────────────────────────────────────────────────────────┐
│                    UI UPDATES                            │
├──────────────────────────────────────────────────────────┤
│                                                            │
│  ├─ Success ✓
│  │  ├─ Show: "Requirement Created Successfully!"
│  │  ├─ Navigate: Pop back to previous screen
│  │  └─ Action: Refresh owner dashboard
│  │
│  └─ Error ✗
│     ├─ Show: Error message from ViewModel
│     ├─ Keep: Form visible for retry
│     └─ Action: User can modify and submit again
│                                                            │
└──────────────────────────────────────────────────────────┘
```

---

## 4. Method Call Stack

```
_submit()
  │
  ├─→ Validate Form
  │    ├─ Check required fields non-empty
  │    ├─ Check dates selected
  │    └─ Validate gender count
  │
  ├─→ Create CreateRequirementRequest
  │    └─ Gather all form data into object
  │
  ├─→ Call OwnerViewModel.createRequirement(request)
  │    │
  │    └─→ RequirementService.createRequirement(request)
  │         │
  │         └─→ HTTP POST to Backend
  │             └─ Returns Future<void>
  │
  ├─→ Handle Response
  │    ├─ Success: Pop screen + Show SnackBar
  │    └─ Error: Show SnackBar with error message
  │
  └─→ Update Loading State
       └─ Hide loading indicator
```

---

## 5. Gender Counter Logic

```
VALID COMBINATIONS:
═════════════════════════════════════════════════

Total=1
├─ Male=1, Female=0 ✓
├─ Male=0, Female=1 ✓

Total=2
├─ Male=2, Female=0 ✓
├─ Male=1, Female=1 ✓
├─ Male=0, Female=2 ✓

Total=5
├─ Male=5, Female=0 ✓
├─ Male=4, Female=1 ✓
├─ Male=3, Female=2 ✓
├─ Male=2, Female=3 ✓
├─ Male=1, Female=4 ✓
├─ Male=0, Female=5 ✓
├─ Male=6, Female=0 ✗ (exceeds total)
├─ Male=3, Female=3 ✗ (exceeds total)

CONSTRAINTS:
═════════════════════════════════════════════════
male + female ≤ total (checked on each increment)

Counter Logic:
├─ TOTAL +1: Always allow (1-999)
├─ TOTAL -1: Only if > 1
├─ MALE +1: Only if male + female < total
├─ MALE -1: Only if > 0
├─ FEMALE +1: Only if male + female < total
├─ FEMALE -1: Only if > 0
```

---

## 6. API Endpoints Used

```
GOOGLE PLACES APIs:
═════════════════════════════════════════════════

1. AUTOCOMPLETE API
   URL: https://maps.googleapis.com/maps/api/place/autocomplete/json
   Method: GET
   Parameters:
   ├─ input: "New Delhi" (search text)
   ├─ key: API_KEY
   └─ components: "country:in" (optional, region limit)

   Response:
   ├─ predictions[]
   │  ├─ place_id: "ChIJ..."
   │  ├─ description: "New Delhi, Delhi, India"
   │  ├─ structured_formatting
   │  │  ├─ main_text: "New Delhi"
   │  │  └─ secondary_text: "Delhi, India"
   │  └─ types[]

2. DETAILS API
   URL: https://maps.googleapis.com/maps/api/place/details/json
   Method: GET
   Parameters:
   ├─ place_id: "ChIJ..."
   ├─ key: API_KEY
   └─ fields: "formatted_address,address_components,geometry"

   Response:
   ├─ result
   │  ├─ formatted_address: "123 Main St, New Delhi, Delhi 110001, India"
   │  ├─ address_components[]
   │  │  ├─ long_name: "123"
   │  │  ├─ short_name: "123"
   │  │  └─ types: ["street_number"]
   │  └─ geometry
   │     ├─ location
   │     │  ├─ lat: 28.6234
   │     │  └─ lng: 77.1855
   │     └─ bounds

BACKEND API:
═════════════════════════════════════════════════

CREATE REQUIREMENT
   URL: https://dihaadi-0lje.onrender.com/api/v1/Requirement/Requirement
   Method: POST
   Headers:
   ├─ Content-Type: application/json
   └─ Authorization: Bearer {token}

   Body: CreateRequirementRequest JSON

   Response:
   ├─ 200/201: Success
   └─ 4xx/5xx: Error with message
```

---

## 7. Validation Rules Summary

```
REQUIRED FIELDS:
├─ WorkTypeId (non-empty)
├─ Title (non-empty)
├─ Description (non-empty)
├─ DutyStartTime (must be selected)
└─ DutyEndTime (must be selected > StartTime)

OPTIONAL FIELDS:
├─ Salary (empty allowed, must be numeric if provided)
├─ Address (empty allowed)
├─ City (empty allowed)
├─ State (empty allowed)
├─ Pincode (empty allowed, numeric if provided)
└─ Country (defaults to "India")

BUSINESS RULES:
├─ PersonNeed: 1-999
├─ MaleCount: 0 to PersonNeed
├─ FemaleCount: 0 to PersonNeed
├─ MaleCount + FemaleCount ≤ PersonNeed
├─ DutyStartTime < DutyEndTime
└─ Salary: positive number or empty
```

---

**Diagram Generated:** January 2025  
**Purpose:** Visual reference for implementation  
**Status:** Complete and Ready for Implementation
