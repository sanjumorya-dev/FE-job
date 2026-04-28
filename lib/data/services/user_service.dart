import 'package:flutter/foundation.dart';
import '../../core/http_client.dart';
import '../models/user_model.dart';

class UserService {
  final SecureHttpClient _client = SecureHttpClient();

  /// Get current user profile
  Future<User> getProfile() async {
    try {
      final response = await _client.get('/User/details');
      final body = response.body.tryParseJson();

      if (body == null) {
        throw Exception('Invalid user data in response');
      }

      // Handle response wrapper with 'data' field
      dynamic userData = body;
      if (body.containsKey('data')) {
        userData = body['data'];
      }

      if (userData == null || userData is! Map<String, dynamic>) {
        throw Exception('Invalid user data format');
      }

      return User.fromJson(userData);
    } catch (e) {
      debugPrint('Get profile error: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile(Map<String, dynamic> payload) async {
    try {
      await _client.put('/User/update', body: payload);
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  /// Get worker/user profile by ID
  ///
  /// Used when owner views a worker's profile with name, gender, experience, mobile
  Future<UserProfile> getUserById(String userId) async {
    try {
      final response = await _client.get('/User/$userId');
      final body = response.body.tryParseJson();

      if (body == null) {
        throw Exception('Invalid user data in response');
      }

      // Handle response wrapper with 'data' field
      dynamic userData = body;
      if (body.containsKey('data')) {
        userData = body['data'];
      }

      if (userData == null || userData is! Map<String, dynamic>) {
        throw Exception('Invalid user data format');
      }

      return UserProfile.fromJson(userData);
    } catch (e) {
      debugPrint('Get user by ID error: $e');
      rethrow;
    }
  }
}

/// User profile model for viewing other users (workers)
class UserProfile {
  final String id;
  final String name;
  final String mobileNumber;
  final String? gender;
  final int? experienceYears;
  final List<String> workTypes;
  final double? rating;
  final int? totalJobs;
  final String? aadharNo;

  UserProfile({
    required this.id,
    required this.name,
    required this.mobileNumber,
    this.gender,
    this.experienceYears,
    this.workTypes = const [],
    this.rating,
    this.totalJobs,
    this.aadharNo,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Parse workTypes
    List<String> workTypesList = [];
    if (json['workTypes'] is List) {
      for (var wt in json['workTypes'] as List) {
        if (wt is String) {
          workTypesList.add(wt);
        } else if (wt is Map && wt['name'] != null) {
          workTypesList.add(wt['name'].toString());
        }
      }
    }

    return UserProfile(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      name: (json['name'] ?? json['Name'] ?? '').toString(),
      mobileNumber: (json['mobileNumber'] ?? json['MobileNumber'] ?? '').toString(),
      gender: json['gender']?.toString() ?? json['Gender']?.toString(),
      experienceYears: json['experienceYears']?.toInt() ?? json['ExperienceYears']?.toInt(),
      workTypes: workTypesList,
      rating: json['rating']?.toDouble() ?? json['Rating']?.toDouble(),
      totalJobs: json['totalJobs']?.toInt() ?? json['TotalJobs']?.toInt(),
      aadharNo: json['aadharNo']?.toString() ?? json['AadharNo']?.toString(),
    );
  }
}
