import 'package:flutter/material.dart';
import '../core/di/injection_container.dart';
import '../core/notifications/notification_service.dart';
import '../core/storage/cache_manager.dart';
import '../data/models/requirement_model.dart';
import '../data/services/requirement_service.dart';
import '../data/services/dashboard_service.dart';

class LabourViewModel extends ChangeNotifier {
  final RequirementService _apiService = sl<RequirementService>();
  final DashboardService _dashboardService = sl<DashboardService>();
  final CacheManager _cacheManager = cacheManager;
  final NotificationService _notificationService = sl<NotificationService>();

  List<Requirement> _availableJobs = [];
  bool _isLoading = false;
  String? _error;

  List<Requirement> get availableJobs => _availableJobs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Dashboard Features (Restored)
  bool _isAvailable = true;
  double _averageRating = 0.0;
  int _totalRatings = 0;
  Map<String, String> _stats = {
    'jobsApplied': '0',
    'approved': '0',
    'ongoing': '0',
    'earnings': '0',
  };
  List<Requirement> _recentApplications = [];

  bool get isAvailable => _isAvailable;
  double get averageRating => _averageRating;
  int get totalRatings => _totalRatings;
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
        'ongoing': stats.acceptedJobs.toString(),
        'completed': stats.completedJobs.toString(),
        'earnings': stats.earnings.toStringAsFixed(0),
      };
      _averageRating = stats.averageRating;
      _totalRatings = stats.totalRatings;
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
      _stats['jobsApplied'] = _recentApplications.length.toString();
      _stats['ongoing'] = _recentApplications
          .where((a) => a.status == 1)
          .length
          .toString();
    } catch (e) {
      debugPrint("Error fetching applications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch jobs using cache-first strategy:
  /// 1. Load from cache immediately (if available)
  /// 2. Fetch from API in background and update UI
  Future<void> fetchJobs() async {
    // 1. Try to load from cache first for instant UI
    if (_cacheManager.hasValidJobsCache()) {
      _availableJobs = _cacheManager.getCachedJobs();
      _isLoading = false;
      notifyListeners();
    } else {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    // 2. Fetch from API in background
    try {
      final jobs = await _apiService.getLabourList();
      _availableJobs = jobs;
      _error = null;

      // Update cache
      await _cacheManager.cacheJobs(jobs);
    } catch (e) {
      _error = e.toString();
      // If we had cached data, keep showing it but show error
      if (_availableJobs.isEmpty) {
        _isLoading = false;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyForJob(String requirementId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.applyForRequirement(requirementId);
      await fetchRecentApplications();

      // Trigger local notification to confirm application
      await _notificationService.showLocalNotification(
        title: 'Application Submitted',
        body: 'Your application has been sent to the employer.',
        id: requirementId.hashCode,
        payload: '/profile',
      );

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