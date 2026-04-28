import 'package:flutter/material.dart';
import '../data/models/requirement_model.dart';
import '../data/services/requirement_service.dart';
import '../data/services/dashboard_service.dart';

class LabourViewModel extends ChangeNotifier {
  final RequirementService _apiService = RequirementService();
  final DashboardService _dashboardService = DashboardService();
  List<Requirement> _availableJobs = [];
  bool _isLoading = false;
  String? _error;

  List<Requirement> get availableJobs => _availableJobs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Dashboard Features (Restored)
  bool _isAvailable = true;
  Map<String, String> _stats = {
    'jobsApplied': '0',
    'approved': '0',
    'ongoing': '0',
    'earnings': '0',
  };
  List<Requirement> _recentApplications = [];

  bool get isAvailable => _isAvailable;
  Map<String, String> get stats => _stats;
  List<Requirement> get recentApplications => _recentApplications;

  void toggleAvailability(bool value) {
    _isAvailable = value;
    notifyListeners();
  }

  Future<void> fetchDashboardStats() async {
    try {
      final stats = await _dashboardService.getWorkerDashboardStats();
      _stats = {
        'jobsApplied': stats.appliedJobs.toString(),
        'approved': stats.acceptedJobs.toString(),
        'ongoing': stats.completedJobs.toString(),
        'earnings': stats.earnings.toStringAsFixed(0),
      };
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchRecentApplications() async {
    _isLoading = true;
    notifyListeners();
    try {
      _recentApplications = await _apiService.getMyApplications();
      // Update stats based on fetched applications
      _stats['jobsApplied'] = _recentApplications.length.toString();
    } catch (e) {
      debugPrint("Error fetching applications: $e");
      // Keep empty list on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchJobs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availableJobs = await _apiService.getLabourList();
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<bool> applyForJob(String requirementId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.applyForRequirement(requirementId);
      // Refresh applications list
      await fetchRecentApplications();
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
}


