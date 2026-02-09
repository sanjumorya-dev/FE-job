# Quick Reference - CreateRequirementScreen Updates

## ✅ What's Been Done

### 1. All Backend Fields Implemented

✓ WorkTypeId, Title, Description, PersonNeed, MaleCount, FemaleCount
✓ DutyStartTime, DutyEndTime, Salary
✓ **NEW:** City, State, Pincode, Country

### 2. Google Places API Integration

✓ Address autocomplete search
✓ Predictions dropdown with descriptions
✓ Auto-fill location details
✓ Manual entry fallback

### 3. Enhanced UI

✓ Better organized sections
✓ Male/Female counter constraints
✓ Full form validation
✓ Loading states and error handling

---

## 🚀 Next Steps (For You To Do)

### Step 1: Get Google Places API Key

```
1. Go to https://console.cloud.google.com/
2. Create a new project
3. Enable "Places API"
4. Create API key under Credentials
5. Copy the API key
```

### Step 2: Update API Key in Code

Open: `lib/ui/screens/owner/create_requirement_screen.dart`

Find line ~44:

```dart
static const String GOOGLE_PLACES_API_KEY = 'YOUR_GOOGLE_PLACES_API_KEY';
```

Replace with your key:

```dart
static const String GOOGLE_PLACES_API_KEY = 'AIzaSyD...YourKeyHere...';
```

### Step 3: Install Dependencies

```bash
flutter pub get
```

### Step 4: Test the Implementation

- Run the app
- Navigate to Create Requirement screen
- Type an address in "Search Address" field
- Select from dropdown
- Verify auto-fill works

---

## 📋 Form Fields Overview

### Required Fields (Must have value)

- Work Type
- Job Title
- Description
- Start Date
- End Date

### Optional Fields (Nice to have)

- Salary
- Address
- City
- State
- Pincode
- Country

### Auto-Calculated Fields

- Total Needed (Person count)
- Male Count (Constrained by total)
- Female Count (Constrained by total)

---

## 🎯 User Interaction Flow

### Scenario 1: Using Google Places

```
1. Click on "Search Address" field
2. Start typing address (e.g., "Delhi")
3. Dropdown shows predictions
4. Click on a prediction
5. Address, City, State, Pincode, Country auto-fill
6. Can modify if needed
7. Submit form
```

### Scenario 2: Manual Entry

```
1. Skip the search or manually type address
2. Manually fill City, State, Pincode, Country
3. Submit form
```

### Scenario 3: Modify Auto-Filled Data

```
1. Use Google Places to auto-fill
2. Edit any field as needed
3. Submit form
```

---

## 🔧 Code Structure

### Main Component

**File:** `lib/ui/screens/owner/create_requirement_screen.dart`

### Key Classes

- `CreateRequirementScreen` - StatefulWidget
- `_CreateRequirementScreenState` - State with form logic
- `PlacePrediction` - Model for place data

### Key Methods

```dart
_searchPlaces(String input)      // Call Google Autocomplete API
_getPlaceDetails(String placeId) // Call Google Details API
_selectDate(context, isStart)    // Date picker
_submit()                         // Submit form with all data
```

---

## 🐛 Common Issues & Solutions

### Issue: "No results found" in dropdown

**Fix:** Ensure:

- Internet connection is active
- API key is correct and has Places API enabled
- Search text is not empty

### Issue: Address fields not auto-filling

**Fix:**

- Check network request is successful
- Verify Google Places Details API is enabled
- Check browser console for API errors

### Issue: Can't find specific location

**Change:** The search is currently restricted to India (country:in)

- To search worldwide, find this line in `_searchPlaces()`:

```dart
final String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$GOOGLE_PLACES_API_KEY&components=country:in';
```

- Remove `&components=country:in` for worldwide search
- Or change to `&components=country:us` for USA, etc.

---

## 📊 Form Data Sent to Backend

When user submits, this is sent:

```json
{
  "WorkTypeId": "1",
  "Title": "Site Supervisor",
  "Description": "Experienced supervisor needed...",
  "PersonNeed": 5,
  "MaleCount": 3,
  "FemaleCount": 2,
  "DutyStartTime": "2024-02-01T00:00:00Z",
  "DutyEndTime": "2024-03-01T00:00:00Z",
  "Salary": 50000,
  "Address": "123 Main Street, New Delhi",
  "City": "New Delhi",
  "State": "Delhi",
  "Pincode": "110001",
  "Country": "India"
}
```

---

## ✨ Features Summary

| Feature            | Status | Details                       |
| ------------------ | ------ | ----------------------------- |
| All Backend Fields | ✅     | 14 fields implemented         |
| Address Search     | ✅     | Google Places Autocomplete    |
| Auto-Fill          | ✅     | City, State, Pincode, Country |
| Manual Entry       | ✅     | Override auto-filled values   |
| Gender Counters    | ✅     | Constrained by total          |
| Date Selection     | ✅     | Range picker with validation  |
| Form Validation    | ✅     | Required field checks         |
| Error Handling     | ✅     | User-friendly messages        |
| Loading State      | ✅     | Button feedback               |
| Success Feedback   | ✅     | SnackBar messages             |

---

## 📱 Responsive Design

The form is fully responsive:

- Works on mobile devices
- Works on tablets
- Works on web
- Scrollable for long content
- Touch-friendly buttons and inputs

---

## 🔐 Important Notes

### API Key Security

⚠️ For production:

- Don't hardcode API key in app
- Move to backend proxy server
- Use API key restrictions
- Monitor usage in Google Cloud Console

### Data Privacy

- Address data is stored as-is
- No tracking or analytics by default
- Users can override auto-filled data

### Costs

- Google Places API is not free
- ~$0.03 per autocomplete request
- ~$0.02 per details request
- Plan budget accordingly for production

---

## 📚 Documentation Files

1. **GOOGLE_PLACES_SETUP.md** - Detailed setup guide
2. **IMPLEMENTATION_SUMMARY.md** - Complete implementation details
3. **QUICK_REFERENCE.md** - This file

---

## ✅ Verification Checklist

Before deployment, verify:

- [ ] Google Places API key is valid
- [ ] Dependencies installed (`flutter pub get`)
- [ ] App compiles without errors
- [ ] Address search works
- [ ] Auto-fill populates fields correctly
- [ ] All form fields are required/optional as needed
- [ ] Form submission sends correct data
- [ ] Success message appears after submission
- [ ] Loading indicator shows during API calls
- [ ] Manual entry works if needed

---

## 🆘 Need Help?

1. **Setup Issues**: See `GOOGLE_PLACES_SETUP.md`
2. **Code Questions**: Check inline comments in the screen file
3. **API Issues**: Visit Google Places API documentation
4. **Flutter Help**: Check pub.dev packages

---

## 📞 Support

For Google Places API support:

- Documentation: https://developers.google.com/maps/documentation/places
- API Quotas: https://console.cloud.google.com/ → APIs & Services → Quotas

For Flutter-specific issues:

- Flutter Docs: https://flutter.dev/docs
- Pub Packages: https://pub.dev/

---

**Last Updated:** January 2025
**Version:** 1.0
**Status:** ✅ Ready for Testing
