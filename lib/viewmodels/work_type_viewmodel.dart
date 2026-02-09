import 'package:flutter/foundation.dart';
import '../data/models/work_type_model.dart';
import '../data/services/work_type_service.dart';

class WorkTypeViewModel extends ChangeNotifier {
  final WorkTypeService _workTypeService = WorkTypeService();

  List<WorkType> _workTypes = [];
  bool _isLoading = false;
  String? _error;

  List<WorkType> get workTypes => _workTypes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWorkTypes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _workTypes = await _workTypeService.getWorkTypes();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _workTypes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
