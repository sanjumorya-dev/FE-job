import 'package:flutter/material.dart';
import '../data/models/requirement_model.dart';
import '../data/services/requirement_service.dart';

class RequirementViewModel extends ChangeNotifier {
  final RequirementService _requirementService = RequirementService();

  List<Requirement> _requirements = [];
  bool _isLoading = false;
  String? _error;
  int _status = 0;
  String? _search;
  String? _workTypeId;
  int _page = 1;
  int _limit = 10;

  // Getters
  List<Requirement> get requirements => _requirements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get status => _status;
  String? get search => _search;
  String? get workTypeId => _workTypeId;
  int get page => _page;
  int get limit => _limit;

  /// Fetch owner requirements - called when owner clicks on requirement tab
  Future<void> fetchOwnerRequirements({
    int? status,
    String? search,
    String? workTypeId,
    int? page,
    int? limit,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update filter parameters
      if (status != null) _status = status;
      if (search != null) _search = search;
      if (workTypeId != null) _workTypeId = workTypeId;
      if (page != null) _page = page;
      if (limit != null) _limit = limit;

      _requirements = await _requirementService.getRequirements(
        status: _status,
        search: _search,
        workTypeId: _workTypeId,
        page: _page,
        limit: _limit,
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
      _requirements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new requirement
  Future<void> createRequirement(CreateRequirementRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _requirementService.createRequirement(request);
      // Refresh the requirements list after creation
      await fetchOwnerRequirements();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset filters and reload requirements
  Future<void> resetFilters() async {
    _status = 0;
    _search = null;
    _workTypeId = null;
    _page = 1;
    await fetchOwnerRequirements();
  }

  /// Change status filter
  Future<void> changeStatus(int newStatus) async {
    _page = 1; // Reset to first page when changing filter
    await fetchOwnerRequirements(status: newStatus);
  }

  /// Search requirements
  Future<void> searchRequirements(String searchQuery) async {
    _page = 1; // Reset to first page when searching
    await fetchOwnerRequirements(search: searchQuery);
  }

  /// Filter by work type
  Future<void> filterByWorkType(String workTypeId) async {
    _page = 1; // Reset to first page when filtering
    await fetchOwnerRequirements(workTypeId: workTypeId);
  }

  /// Load next page
  Future<void> loadNextPage() async {
    await fetchOwnerRequirements(page: _page + 1);
  }

  /// Load previous page
  Future<void> loadPreviousPage() async {
    if (_page > 1) {
      await fetchOwnerRequirements(page: _page - 1);
    }
  }
}
