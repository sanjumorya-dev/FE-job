import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dihaadi_app/constants/colors.dart';
import 'package:dihaadi_app/constants/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Step2AddressInfo extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController pincodeController;
  final TextEditingController countryController;

  const Step2AddressInfo({
    super.key,
    required this.formKey,
    required this.addressController,
    required this.cityController,
    required this.stateController,
    required this.pincodeController,
    required this.countryController,
  });

  @override
  State<Step2AddressInfo> createState() => _Step2AddressInfoState();
}

class _Step2AddressInfoState extends State<Step2AddressInfo> {
  List<PlacePrediction> _placePredictions = [];
  bool _showPredictions = false;
  Timer? _searchDebounce;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  // Search places by query with debounce
  Future<void> _searchPlaces(String input) async {
    _searchDebounce?.cancel();

    if (input.isEmpty) {
      setState(() {
        _showPredictions = false;
        _placePredictions = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final url = '${ApiConfig.placeSearch}?query=$input';
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final dynamic jsonResponse = jsonDecode(response.body);
          List<dynamic> data = [];

          if (jsonResponse is Map<String, dynamic>) {
            if (jsonResponse['data'] is Map<String, dynamic>) {
              final dataMap = jsonResponse['data'] as Map<String, dynamic>;
              if (dataMap['predictions'] is List) {
                data = dataMap['predictions'] as List<dynamic>;
              }
            } else if (jsonResponse['predictions'] is List) {
              data = jsonResponse['predictions'] as List<dynamic>;
            }
          } else if (jsonResponse is List) {
            data = jsonResponse;
          }

          if (mounted) {
            setState(() {
              _placePredictions = data.whereType<Map<String, dynamic>>().map((p) {
                return PlacePrediction.fromJson(p);
              }).toList();
              _showPredictions = _placePredictions.isNotEmpty;
              _isSearching = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isSearching = false;
              _showPredictions = false;
              _placePredictions = [];
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _showPredictions = false;
            _placePredictions = [];
          });
        }
      }
    });
  }

  // Get place details and auto-fill fields
  Future<void> _getPlaceDetails(String placeId) async {
    try {
      final url = '${ApiConfig.placeDetails}/$placeId';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(response.body);
        Map<String, dynamic> placeData = {};

        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse['data'] is Map<String, dynamic>) {
            final dataMap = jsonResponse['data'] as Map<String, dynamic>;
            if (dataMap['result'] is Map<String, dynamic>) {
              placeData = dataMap['result'] as Map<String, dynamic>;
            } else {
              placeData = dataMap;
            }
          } else {
            placeData = jsonResponse;
          }
        }

        String formattedAddress = '';
        String city = '';
        String state = '';
        String country = '';
        String pincode = '';

        if (placeData['formatted_address'] != null) {
          formattedAddress = placeData['formatted_address'].toString();
        } else if (placeData['description'] != null) {
          formattedAddress = placeData['description'].toString();
        }

        if (placeData['address_components'] is List) {
          final components = placeData['address_components'] as List<dynamic>;
          for (var component in components) {
            if (component is! Map<String, dynamic>) continue;
            final types = component['types'] as List<dynamic>?;
            final longName = component['long_name']?.toString() ?? '';
            final shortName = component['short_name']?.toString() ?? '';

            if (types != null && types.contains('locality') && city.isEmpty) {
              city = longName;
            }
            if (types != null && types.contains('administrative_area_level_1') && state.isEmpty) {
              state = longName;
            }
            if (types != null && types.contains('country') && country.isEmpty) {
              country = longName;
            }
            if (types != null && types.contains('postal_code') && pincode.isEmpty) {
              pincode = longName;
            }
          }
        }

        if (mounted) {
          setState(() {
            widget.addressController.text = formattedAddress;
            if (city.isNotEmpty) widget.cityController.text = city;
            if (state.isNotEmpty) widget.stateController.text = state;
            if (country.isNotEmpty) widget.countryController.text = country;
            if (pincode.isNotEmpty) widget.pincodeController.text = pincode;
            _showPredictions = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Place details error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: widget.addressController,
            label: "STREET ADDRESS",
            hint: "123 Market Road, Sector 4",
            icon: Icons.location_on_outlined,
            onChanged: _searchPlaces,
            validator: (v) => v!.isEmpty ? "Required" : null,
          ),
          if (_showPredictions) _buildAddressPredictions(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: widget.cityController,
                  label: "CITY",
                  hint: "Mumbai",
                  icon: Icons.location_city_outlined,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: widget.stateController,
                  label: "STATE",
                  hint: "Maharashtra",
                  icon: Icons.map_outlined,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: widget.countryController,
            label: "COUNTRY",
            hint: "India",
            icon: Icons.public_outlined,
            isDropdown: true,
            validator: (v) => v!.isEmpty ? "Required" : null,
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: widget.pincodeController,
            label: "PINCODE",
            hint: "400001",
            icon: Icons.pin_drop_outlined,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (v.length != 6) return 'Enter 6-digit pincode';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressPredictions() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _placePredictions.length,
          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF0F2F7)),
          itemBuilder: (context, index) {
            final prediction = _placePredictions[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text(
                prediction.mainText, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.secondary)
              ),
              subtitle: Text(
                prediction.secondaryText, 
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)
              ),
              onTap: () {
                FocusScope.of(context).unfocus();
                _getPlaceDetails(prediction.placeId);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isDropdown = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textHint,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          readOnly: isDropdown,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14, fontWeight: FontWeight.normal),
            prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
            suffixIcon: isDropdown
                ? const Icon(Icons.keyboard_arrow_down, color: AppColors.textHint)
                : null,
            filled: true,
            fillColor: AppColors.inputBackground,
            counterText: "",
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

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
    String mainText = '';
    String secondaryText = '';

    if (json['structured_formatting'] is Map<String, dynamic>) {
      final formatting = json['structured_formatting'] as Map<String, dynamic>;
      mainText = formatting['main_text']?.toString() ?? '';
      secondaryText = formatting['secondary_text']?.toString() ?? '';
    } else {
      mainText = json['main_text']?.toString() ?? '';
      secondaryText = json['secondary_text']?.toString() ?? '';
    }

    return PlacePrediction(
      placeId: json['place_id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      mainText: mainText,
      secondaryText: secondaryText,
    );
  }
}

