import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/di/injection_container.dart';
import '../../core/network/dio_client.dart';
import '../models/work_type_model.dart';

class CommonService {
  final DioClient _client = sl<DioClient>();

  /// Upload image to server
  ///
  /// API: POST /Common/uploadImage
  Future<String> uploadImage(File file) async {
    try {
      final response = await _client.postMultipart(
        '/Common/uploadImage',
        filePath: file.path,
        fileFieldName: 'file',
      );

      final body = response.body.tryParseJson();
      if (body != null) {
        if (body['url'] != null) {
          return body['url'] as String;
        }
        if (body['imageUrl'] != null) {
          return body['imageUrl'] as String;
        }
        if (body['data'] is Map && (body['data'] as Map)['url'] != null) {
          return (body['data'] as Map)['url'].toString();
        }
        if (body['data'] != null) {
          return body['data'].toString();
        }
      }

      // Handle string response
      if (response.body.isNotEmpty && !response.body.startsWith('{')) {
        return response.body;
      }

      throw Exception('Invalid response format from image upload');
    } catch (e) {
      debugPrint('Image upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Get list of work types
  ///
  /// API: GET /WorkType/list
  Future<List<WorkType>> getWorkTypes() async {
    try {
      final response = await _client.get('/WorkType/list');
      final body = response.body.tryParseJson();

      if (body == null) {
        throw Exception('Invalid response format');
      }

      // Handle nested data field
      List<dynamic> workTypesData;
      if (body['data'] is List) {
        workTypesData = body['data'] as List;
      } else if (body is List) {
        workTypesData = body as List<dynamic>;
      } else {
        return [];
      }

      return workTypesData
          .map((e) => WorkType.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get work types error: $e');
      rethrow;
    }
  }

  /// Search places for address autocomplete
  ///
  /// API: GET /common/places/search?query={query}
  Future<List<PlacePrediction>> searchPlaces(String query) async {
    try {
      final response = await _client.get('/Common/places/search?query=${Uri.encodeQueryComponent(query)}');
      final body = response.body.tryParseJson();

      if (body == null) {
        throw Exception('Invalid response format');
      }

      // Handle nested data field
      Map<String, dynamic> data = body;
      if (body['data'] is Map<String, dynamic>) {
        data = body['data'] as Map<String, dynamic>;
      }

      List<dynamic> predictionsData;
      if (data['predictions'] is List) {
        predictionsData = data['predictions'] as List;
      } else {
        return [];
      }

      return predictionsData
          .map((e) => PlacePrediction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Search places error: $e');
      rethrow;
    }
  }

  /// Get place details by place ID
  ///
  /// API: GET /common/places/details/{placeId}
  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    try {
      final response = await _client.get('/Common/places/details/$placeId');
      final body = response.body.tryParseJson();

      if (body == null) {
        throw Exception('Invalid response format');
      }

      // Handle nested data field
      Map<String, dynamic> data = body;
      if (body['data'] is Map<String, dynamic>) {
        data = body['data'] as Map<String, dynamic>;
      }

      if (data['result'] == null) {
        throw Exception('Place details not found');
      }

      return PlaceDetails.fromJson(data['result'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Get place details error: $e');
      rethrow;
    }
  }
}

/// Place prediction model for search results
class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'] ?? json['structuredFormatting'];
    String mainText = '';
    String secondaryText = '';

    if (structuredFormatting is Map<String, dynamic>) {
      mainText = structuredFormatting['main_text']?.toString() ?? '';
      secondaryText = structuredFormatting['secondary_text']?.toString() ?? '';
    }

    return PlacePrediction(
      placeId: (json['place_id'] ?? json['placeId'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      mainText: mainText,
      secondaryText: secondaryText,
    );
  }
}

/// Place details model with full address components
class PlaceDetails {
  final String formattedAddress;
  final List<AddressComponent> addressComponents;

  PlaceDetails({
    required this.formattedAddress,
    required this.addressComponents,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    List<AddressComponent> components = [];
    if (json['address_components'] is List) {
      components = (json['address_components'] as List)
          .map((e) => AddressComponent.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return PlaceDetails(
      formattedAddress: (json['formatted_address'] ?? json['formattedAddress'] ?? '').toString(),
      addressComponents: components,
    );
  }

  /// Get specific component by type
  String? getComponentByType(String type) {
    for (final component in addressComponents) {
      if (component.types.contains(type)) {
        return component.longName;
      }
    }
    return null;
  }

  /// Get city/locality
  String? get city => getComponentByType('locality');

  /// Get state
  String? get state => getComponentByType('administrative_area_level_1');

  /// Get country
  String? get country => getComponentByType('country');

  /// Get postal code
  String? get postalCode => getComponentByType('postal_code');
}

/// Address component model
class AddressComponent {
  final String longName;
  final String shortName;
  final List<String> types;

  AddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> json) {
    List<String> typesList = [];
    if (json['types'] is List) {
      typesList = (json['types'] as List).map((e) => e.toString()).toList();
    }

    return AddressComponent(
      longName: (json['long_name'] ?? json['longName'] ?? '').toString(),
      shortName: (json['short_name'] ?? json['shortName'] ?? '').toString(),
      types: typesList,
    );
  }
}
