# Backend Proxy Setup for Google Places API

## Problem Solved

✅ Fixed CORS error when calling Google Places API from web client  
✅ API key now secure on backend (not exposed in frontend)  
✅ Better performance and reliability

---

## Backend Implementation (C# .NET)

### Add these endpoints to your backend API controller

```csharp
using Microsoft.AspNetCore.Mvc;
using System.Net.Http;
using System.Threading.Tasks;
using System.Text.Json;

[ApiController]
[Route("api/v1")]
public class PlacesProxyController : ControllerBase
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;

    public PlacesProxyController(HttpClient httpClient, IConfiguration configuration)
    {
        _httpClient = httpClient;
        _configuration = configuration;
    }

    // Get autocomplete suggestions for address search
    [HttpGet("place-autocomplete")]
    public async Task<IActionResult> GetPlaceAutocomplete([FromQuery] string input)
    {
        if (string.IsNullOrWhiteSpace(input))
        {
            return BadRequest("Input is required");
        }

        try
        {
            // Get API key from appsettings.json or environment variable
            var apiKey = _configuration["GooglePlaces:ApiKey"];

            var url = $"https://maps.googleapis.com/maps/api/place/autocomplete/json?" +
                     $"input={Uri.EscapeDataString(input)}" +
                     $"&key={apiKey}" +
                     $"&components=country:in";

            var response = await _httpClient.GetAsync(url);
            var content = await response.Content.ReadAsStringAsync();

            if (response.IsSuccessStatusCode)
            {
                var json = JsonSerializer.Deserialize<dynamic>(content);
                return Ok(json);
            }
            else
            {
                return StatusCode((int)response.StatusCode,
                    new { error = "Failed to fetch predictions from Google API" });
            }
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = ex.Message });
        }
    }

    // Get detailed information about a place
    [HttpGet("place-details")]
    public async Task<IActionResult> GetPlaceDetails([FromQuery] string placeId)
    {
        if (string.IsNullOrWhiteSpace(placeId))
        {
            return BadRequest("Place ID is required");
        }

        try
        {
            var apiKey = _configuration["GooglePlaces:ApiKey"];

            var url = $"https://maps.googleapis.com/maps/api/place/details/json?" +
                     $"place_id={placeId}" +
                     $"&key={apiKey}" +
                     $"&fields=formatted_address,address_components,geometry";

            var response = await _httpClient.GetAsync(url);
            var content = await response.Content.ReadAsStringAsync();

            if (response.IsSuccessStatusCode)
            {
                var json = JsonSerializer.Deserialize<dynamic>(content);
                return Ok(json);
            }
            else
            {
                return StatusCode((int)response.StatusCode,
                    new { error = "Failed to fetch place details from Google API" });
            }
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = ex.Message });
        }
    }
}
```

### Update appsettings.json

Add your Google Places API key to the configuration:

```json
{
  "GooglePlaces": {
    "ApiKey": "YOUR_GOOGLE_PLACES_API_KEY_HERE"
  }
  // ... other settings
}
```

### Update Startup Configuration (Program.cs)

Make sure HttpClient is registered:

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add HttpClient for making external API calls
builder.Services.AddHttpClient();

// Add CORS policy
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterWeb", builder =>
    {
        builder.AllowAnyOrigin()
               .AllowAnyMethod()
               .AllowAnyHeader();
    });
});

builder.Services.AddControllers();
var app = builder.Build();

app.UseCors("AllowFlutterWeb");
app.MapControllers();
app.Run();
```

---

## Frontend Changes (Already Done ✅)

The Flutter code has been updated to call your backend endpoints:

```dart
// Before (Direct API call - CORS issue)
final String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$GOOGLE_PLACES_API_KEY&components=country:in';

// After (Via backend proxy - No CORS issue)
final String backendUrl = 'https://dihaadi-0lje.onrender.com/api/v1/place-autocomplete?input=${Uri.encodeComponent(input)}';
```

---

## Testing the Integration

### 1. Test Autocomplete Endpoint

```bash
GET https://dihaadi-0lje.onrender.com/api/v1/place-autocomplete?input=India+Gate
```

**Expected Response:**

```json
{
  "predictions": [
    {
      "place_id": "ChIJ...",
      "description": "India Gate, New Delhi, Delhi, India",
      "structured_formatting": {
        "main_text": "India Gate",
        "secondary_text": "New Delhi, Delhi, India"
      }
    }
    // ... more predictions
  ]
}
```

### 2. Test Details Endpoint

```bash
GET https://dihaadi-0lje.onrender.com/api/v1/place-details?placeId=ChIJ...
```

**Expected Response:**

```json
{
  "result": {
    "formatted_address": "India Gate, New Delhi, Delhi 110001, India",
    "address_components": [
      {
        "long_name": "New Delhi",
        "types": ["locality"]
      }
      // ... more components
    ]
  }
}
```

### 3. Test in Flutter App

1. Run the app
2. Type an address in the search field
3. Verify predictions dropdown appears
4. Select a prediction
5. Verify fields auto-fill

---

## Benefits of This Approach

✅ **CORS Issue Fixed** - No more cross-origin errors  
✅ **API Key Secure** - Not exposed in frontend code  
✅ **Rate Limiting** - Can implement on backend  
✅ **Caching** - Can cache results on backend  
✅ **Monitoring** - Can track API usage  
✅ **Flexibility** - Easy to add authentication, logging, etc.

---

## Security Best Practices

### ✅ Do's

- Store API key in backend environment variables
- Use configuration management for sensitive data
- Implement rate limiting on backend
- Log API calls for monitoring
- Use HTTPS for all requests

### ❌ Don'ts

- Don't hardcode API key in frontend
- Don't expose API key in source control
- Don't share API key publicly
- Don't commit sensitive data to git

---

## Environment Variables Setup

### For Production

Set environment variable on your server:

```bash
export GOOGLE_PLACES_API_KEY="AIzaSy..."
```

### Or use appsettings.{Environment}.json

```json
{
  "GooglePlaces": {
    "ApiKey": "${GOOGLE_PLACES_API_KEY}"
  }
}
```

### For Local Development

Create `appsettings.Development.json`:

```json
{
  "GooglePlaces": {
    "ApiKey": "YOUR_DEV_API_KEY"
  }
}
```

---

## Troubleshooting

### Issue: 401 Unauthorized from Google API

**Solution:** Verify API key is correct and enabled in Google Cloud Console

### Issue: 403 Forbidden

**Solution:** Check API key restrictions and quota in Google Cloud Console

### Issue: Backend returning 500 error

**Solution:**

- Check logs on backend
- Verify HttpClient is properly configured
- Verify configuration section exists in appsettings.json

### Issue: Still getting CORS error

**Solution:**

- Verify CORS policy is added in Program.cs
- Check backend URL in Flutter code matches your API URL
- Verify backend is running and accessible

---

## Summary of Changes

| Component        | Change                           | Status  |
| ---------------- | -------------------------------- | ------- |
| Flutter Frontend | Updated API calls to use backend | ✅ Done |
| Backend API      | Add two new endpoints            | TODO    |
| Configuration    | Add API key to appsettings       | TODO    |
| Environment      | Set environment variable         | TODO    |

---

## Next Steps

1. **Add the controller code to your backend** (.NET project)
2. **Configure API key** in appsettings.json
3. **Test the endpoints** using the examples above
4. **Deploy backend** to your server
5. **Test in Flutter app** - should work without CORS error

---

**Status:** Frontend updated ✅, Waiting for backend implementation

**Questions?** Refer to the Flutter file - all changes are documented in comments.
