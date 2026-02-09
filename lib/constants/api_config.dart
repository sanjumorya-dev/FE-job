/// API Configuration for backend endpoints
class ApiConfig {
  // Base API URL
  static const String baseUrl = 'https://dihaadi-0lje.onrender.com/api/v1';

  // Place/Address endpoints (implemented on backend)
  static const String placeSearch = '$baseUrl/common/places/search';
  static const String placeDetails = '$baseUrl/common/places/details';

  // Requirements endpoints
  static const String createRequirement = '$baseUrl/requirement/create';
  static const String getRequirements = '$baseUrl/requirement/list';
  static const String getRequirementDetail = '$baseUrl/requirement';
  static const String getWorkTypes = '$baseUrl/common/worktypes';
  static const String uploadImage = '$baseUrl/common/upload-image';

  // Auth endpoints
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String registerEndpoint = '$baseUrl/auth/register';
}
