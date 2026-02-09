import 'package:flutter/material.dart';
import '../data/models/requirement_model.dart';
import '../data/services/requirement_service.dart';

class LabourViewModel extends ChangeNotifier {
  final RequirementService _apiService = RequirementService();
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
    await Future.delayed(const Duration(milliseconds: 300));
    _stats = {
      'jobsApplied': '8',
      'approved': '2',
      'ongoing': '1',
      'earnings': '1,250',
    };
    notifyListeners();
  }

  Future<void> fetchRecentApplications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _recentApplications = [
      Requirement(
        id: '101', title: 'Roof Repair Helpers', description: 'Need help with roofing',
        salary: 120, address: 'Skyline Roofing Co.', status: 1, workTypeId: '1',
        date: DateTime.now(), userId: 'owner1',
      ),
      Requirement(
        id: '102', title: 'Interior Woodwork', description: 'Detailing',
        salary: 18, address: 'Harbor View', status: 2, workTypeId: '2',
        date: DateTime.now().subtract(const Duration(days: 2)), userId: 'owner2',
      ),
    ];
    notifyListeners();
  }

  Future<void> fetchJobs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availableJobs =
          await _apiService.getRequirements(); // Fetch all/filtered jobs
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
      // Mock apply logic or implement in API service if endpoint existed
      await Future.delayed(const Duration(seconds: 1));
      // await _apiService.apply(requirementId);
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


