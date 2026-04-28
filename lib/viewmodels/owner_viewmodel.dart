import 'package:flutter/material.dart';
import '../data/models/requirement_model.dart';
import '../data/models/applicant_model.dart';
import '../data/services/requirement_service.dart';
import '../data/services/dashboard_service.dart';

class OwnerViewModel extends ChangeNotifier {
  final RequirementService _apiService = RequirementService();
  final DashboardService _dashboardService = DashboardService();
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
    try {
      final stats = await _dashboardService.getOwnerDashboardStats();
      _stats = {
        'activeReq': stats.activeRequirements.toString(),
        'totalApplicants': stats.totalApplicants.toString(),
        'hiredLabour': stats.hiredWorkers.toString(),
        'completedJobs': stats.completedJobs.toString(),
      };
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
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

  Future<bool> updateRequirement(
      String id, CreateRequirementRequest request) async {
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

  Future<bool> deleteRequirement(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.deleteRequirement(id);
      _myRequirements.removeWhere((requirement) => requirement.id == id);
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
      _applicants = await _apiService.getApplicants(requirementId);
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> acceptApplicant(String requirementId, String applicantId) async {
    try {
      await _apiService.acceptApplicant(requirementId, applicantId);
      final index = _applicants.indexWhere((a) => a.id == applicantId);
      if (index != -1) {
        _applicants[index] =
            _applicants[index].copyWith(status: ApplicationStatus.accepted);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> rejectApplicant(String requirementId, String applicantId) async {
    try {
      await _apiService.rejectApplicant(requirementId, applicantId);
      final index = _applicants.indexWhere((a) => a.id == applicantId);
      if (index != -1) {
        _applicants[index] =
            _applicants[index].copyWith(status: ApplicationStatus.rejected);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}


