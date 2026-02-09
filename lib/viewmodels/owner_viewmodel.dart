import 'package:flutter/material.dart';
import '../data/models/requirement_model.dart';
import '../data/models/applicant_model.dart';
import '../data/services/requirement_service.dart';

class OwnerViewModel extends ChangeNotifier {
  final RequirementService _apiService = RequirementService();
  List<Requirement> _myRequirements = [];
  List<Applicant> _applicants = []; // Added this line
  bool _isLoading = false;
  String? _error;

  List<Requirement> get myRequirements => _myRequirements;
  List<Applicant> get applicants => _applicants; // Added this line
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Dashboard Stats (Restored)
  Map<String, String> _stats = {
    'activeReq': '0',
    'totalApplicants': '0',
    'hiredLabour': '0',
    'completedJobs': '0',
  };
  Map<String, String> get stats => _stats;

  Future<void> fetchDashboardStats() async {
    // Mock stats for dashboard
    await Future.delayed(const Duration(milliseconds: 300));
    _stats = {
      'activeReq': '12', 
      'totalApplicants': '48',
      'hiredLabour': '5',
      'completedJobs': '24',
    };
    notifyListeners();
  }

  Future<void> fetchMyRequirements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myRequirements = await _apiService
          .getRequirements(); // TODO: Filter by Owner ID API side or here
      _isLoading = false;
      debugPrint('Fetched ${_myRequirements.length} requirements for owner.');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<bool> createRequirement(CreateRequirementRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.createRequirement(request);
      await fetchMyRequirements(); // Refresh list
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRequirement(String id, CreateRequirementRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.updateRequirement(id, request);
      await fetchMyRequirements(); // Refresh list
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Applicant Management Methods
  Future<void> fetchApplicantsForRequirement(String requirementId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Mock data for applicants
      await Future.delayed(const Duration(milliseconds: 500));
      _applicants = _generateMockApplicants(requirementId);
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> acceptApplicant(String requirementId, String applicantId) async {
    // Mock accept logic
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _applicants.indexWhere((a) => a.id == applicantId);
    if (index != -1) {
      _applicants[index] = _applicants[index].copyWith(status: ApplicationStatus.accepted);
      notifyListeners();
    }
  }

  Future<void> rejectApplicant(String requirementId, String applicantId) async {
    // Mock reject logic
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _applicants.indexWhere((a) => a.id == applicantId);
    if (index != -1) {
      _applicants[index] = _applicants[index].copyWith(status: ApplicationStatus.rejected);
      notifyListeners();
    }
  }

  List<Applicant> _generateMockApplicants(String requirementId) {
    return [
      Applicant(
        id: '1', userId: 'user-1', requirementId: requirementId, workerName: 'Rahul Kumar',
        gender: 'Male', experienceYears: 5, mobileNumber: '+91 98765 43210',
        status: ApplicationStatus.pending, appliedDate: DateTime.now(),
      ),
      Applicant(
        id: '2', userId: 'user-2', requirementId: requirementId, workerName: 'Priya Singh',
        gender: 'Female', experienceYears: 3, mobileNumber: '+91 98765 43211',
        status: ApplicationStatus.pending, appliedDate: DateTime.now(),
      ),
    ];
  }
}


