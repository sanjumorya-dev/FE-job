/// API Configuration for backend endpoints
class ApiConfig {
  // Base API URL
  static const String baseUrl = 'https://dihaadi-0lje.onrender.com/api/v1';

  // ========== AUTHENTICATION ==========
  static const String login = '$baseUrl/Auth/login';
  static const String sendOtp = '$baseUrl/Auth/otpRequest';
  static const String verifyOtp = '$baseUrl/Auth/otpVerify';
  static const String resetPassword = '$baseUrl/Auth/resetPassword';

  // ========== USER / PROFILE ==========
  static const String register = '$baseUrl/User/create';
  static const String getProfile = '$baseUrl/User/details';
  static const String updateProfile = '$baseUrl/User/update';
  static const String getUserById = '$baseUrl/User'; // GET /User/{userId}

  // ========== REQUIREMENTS (JOBS) ==========
  static const String createRequirement = '$baseUrl/Requirement/create';
  static const String updateRequirement = '$baseUrl/Requirement/update'; // PUT
  static const String deleteRequirement = '$baseUrl/Requirement'; // DELETE /Requirement/{id}
  static const String changeRequirementStatus = '$baseUrl/Requirement'; // PUT /Requirement/{id}/status
  static const String getRequirements = '$baseUrl/Requirement/Owner'; // POST
  static const String applyForRequirement = '$baseUrl/Requirement/apply'; // POST /apply/{id}
  static const String getMyApplications = '$baseUrl/Requirement/my-applications';
  static const String getRequirementById = '$baseUrl/Requirement'; // GET /Requirement/{id}
  static const String getApplicants = '$baseUrl/Requirement'; // GET /Requirement/{id}/applicants
  static const String acceptApplicant = '$baseUrl/Requirement'; // PUT /Requirement/{id}/applicants/{applicantId}/accept
  static const String rejectApplicant = '$baseUrl/Requirement'; // PUT /Requirement/{id}/applicants/{applicantId}/reject
  static const String completeJob = '$baseUrl/Requirement'; // PUT /Requirement/{id}/complete

  // ========== RATINGS ==========
  static const String rateWorker = '$baseUrl/Rating/worker';
  static const String rateOwner = '$baseUrl/Rating/owner';

  // ========== CHAT / MESSAGING ==========
  static const String getConversations = '$baseUrl/Chat/conversations';
  static const String getMessages = '$baseUrl/Chat/conversations'; // GET /conversations/{id}/messages
  static const String sendMessage = '$baseUrl/Chat/conversations'; // POST /conversations/{id}/messages

  // ========== NOTIFICATIONS ==========
  static const String getNotifications = '$baseUrl/Notification/list';
  static const String markNotificationRead = '$baseUrl/Notification'; // PUT /Notification/{id}/read

  // ========== DASHBOARD ==========
  static const String getOwnerDashboardStats = '$baseUrl/Dashboard/owner/stats';

  // ========== WORK TYPES ==========
  static const String getWorkTypes = '$baseUrl/WorkType/list';

  // ========== PLACES / ADDRESS ==========
  static const String placeSearch = '$baseUrl/common/places/search';
  static const String placeDetails = '$baseUrl/common/places/details'; // GET /details/{placeId}

  // ========== COMMON / UPLOADS ==========
  static const String uploadImage = '$baseUrl/common/upload-image';
}
