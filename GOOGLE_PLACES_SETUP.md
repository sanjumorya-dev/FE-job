# Google Places API Setup Guide

## Overview

The updated `CreateRequirementScreen` now includes Google Places API integration for address search and auto-fill functionality. Users can search for addresses, select from predictions, and the address fields (Address, City, State, Pincode, Country) will be automatically filled.

## Features Implemented

✅ Google Places API integration for address search
✅ Auto-complete predictions dropdown
✅ Auto-fill location details (City, State, Pincode, Country)
✅ Manual address entry fallback
✅ All required fields from the backend model
✅ Male/Female counters with validation
✅ Date range selection for duty duration

## New Fields Added

- **City** - City from selected address
- **State** - State/Province from selected address
- **Pincode** - Postal code from selected address
- **Country** - Country (defaults to India)

## Setup Instructions

### Step 1: Get Google Places API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable the following APIs:
   - Places API
   - Maps JavaScript API
   - Geocoding API
4. Create an API key (Credentials > Create Credentials > API Key)
5. Restrict the key to Android, iOS, and HTTP referrers if needed

### Step 2: Update the API Key in Code

Open `lib/ui/screens/owner/create_requirement_screen.dart` and replace:

```dart
static const String GOOGLE_PLACES_API_KEY = 'YOUR_GOOGLE_PLACES_API_KEY';
```

With your actual API key:

```dart
static const String GOOGLE_PLACES_API_KEY = 'AIzaSyD...YOUR_KEY_HERE...';
```

### Step 3: Install Dependencies

The following packages have been added to `pubspec.yaml`:

- `google_places_flutter: ^2.0.8`
- `google_maps_flutter: ^2.5.0`

Run:

```bash
flutter pub get
```

### Step 4: Platform-Specific Setup (if using Google Maps in the future)

#### Android Setup

Add to `android/app/build.gradle`:

```gradle
android {
    ...
    compileSdkVersion 33

    defaultConfig {
        ...
        minSdkVersion 20
        ...
    }
}
```

Add to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### iOS Setup

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to find nearby jobs</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs your location to find nearby jobs</string>
```

## How It Works

### Address Search Flow

1. User starts typing in the "Search Address" field
2. `_searchPlaces()` function makes API call to Google Places Autocomplete
3. Predictions appear in a dropdown below the search field
4. User taps on a prediction
5. `_getPlaceDetails()` function fetches detailed address information
6. Address fields (City, State, Pincode, Country) auto-fill

### Form Submission

All fields are validated and sent to the backend including:

- WorkTypeId
- Title
- Description
- PersonNeed
- MaleCount
- FemaleCount
- DutyStartTime
- DutyEndTime
- Salary
- Address
- City
- State
- Pincode
- Country

## Testing

### Test with Sample Data

1. Search for: "India Gate, New Delhi, India"
2. Select from predictions
3. Fields should auto-fill with:
   - Address: Full address
   - City: New Delhi
   - State: Delhi
   - Pincode: 110001
   - Country: India

### Error Handling

- Invalid API key → "Error searching places" message
- No internet → Network error message
- Empty search → No dropdown shown

## Troubleshooting

### Issue: Predictions not showing

**Solution**:

- Verify Google Places API is enabled in Google Cloud Console
- Check API key is correct (no spaces or typos)
- Ensure internet connection is active

### Issue: Address fields not auto-filling

**Solution**:

- Check that Google Places Details API is enabled
- Verify the place ID is valid
- Check network request in browser console/logs

### Issue: Different country addresses needed

**Solution**:
In `_searchPlaces()` function, modify:

```dart
final String url =
    'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$GOOGLE_PLACES_API_KEY&components=country:in';
```

Change `country:in` to your desired country code (e.g., `country:us` for USA).

## API Usage Notes

- Google Places API has usage limits and quotas
- Each autocomplete request costs ~$0.029 (as of 2024)
- Place details request costs ~$0.017
- Free tier: 1000 free requests/month after initial credit

## Future Enhancements

1. Add Google Maps widget to pin exact location
2. Implement address history/favorites
3. Add reverse geocoding for map coordinates
4. Cache frequently searched addresses
5. Add offline support with local address database

## Code Structure

### Main Components:

- **PlacePrediction**: Model class for place predictions
- **\_searchPlaces()**: Handles autocomplete API calls
- **\_getPlaceDetails()**: Extracts address components from place details
- **Address Prediction Widget**: Shows dropdown with matching results

### Key Methods:

```dart
Future<void> _searchPlaces(String input)      // Search places by text
Future<void> _getPlaceDetails(String placeId) // Get detailed place info
```

## Security Notes

⚠️ **Important**:

- Never commit actual API keys to version control
- Consider moving API key to backend for production
- Add API key restrictions in Google Cloud Console
- Implement backend proxy for API calls in production
