import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dihaadi_app/data/models/requirement_model.dart';
import 'package:dihaadi_app/viewmodels/owner_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:dihaadi_app/constants/api_config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dihaadi_app/data/services/common_service.dart';
import 'dart:io';

class CreateRequirementScreen extends StatefulWidget {
  const CreateRequirementScreen({super.key});

  @override
  State<CreateRequirementScreen> createState() =>
      _CreateRequirementScreenState();
}

class _CreateRequirementScreenState extends State<CreateRequirementScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final salaryController = TextEditingController();
  final addressController = TextEditingController();

  // State
  String selectedWorkType = '';
  int personNeed = 1;
  int maleCount = 1;
  int femaleCount = 0;
  List<String> images = [];
  DateTime? dutyStartTime;
  DateTime? dutyEndTime;
  bool _isLoading = false;
  List<PlacePrediction> _placePredictions = [];
  bool _showPredictions = false;
  List<WorkType> _workTypes = [];
  String? _selectedCity;
  String? _selectedState;
  String? _selectedCountry;
  String? _selectedPincode;
  Timer? _searchDebounce;
  bool _isSearching = false;
  late FocusNode _addressFocusNode;

  // Image Upload State
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  final CommonService _commonService = CommonService();


  @override
  void initState() {
    super.initState();
    _addressFocusNode = FocusNode();
    _fetchWorkTypes();
  }

  // Fetch work types from API
  Future<void> _fetchWorkTypes() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.getWorkTypes),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('Work types status: ${response.statusCode}');
      debugPrint('Work types body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(response.body);
        List<dynamic> data = [];

        // Handle different response formats
        if (jsonData is List) {
          data = jsonData;
        } else if (jsonData is Map && jsonData['data'] != null) {
          data = jsonData['data'] is List ? jsonData['data'] : [];
        }

        debugPrint('Parsed data: $data');

        if (mounted) {
          setState(() {
            _workTypes = data.map((w) => WorkType.fromJson(w)).toList();
            debugPrint('Work types count: ${_workTypes.length}');

            if (_workTypes.isNotEmpty && selectedWorkType.isEmpty) {
              selectedWorkType = _workTypes.first.id;
              debugPrint('Set initial work type: $selectedWorkType');
            }
          });
        }
      } else {
        debugPrint('Failed to fetch work types: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Fetch work types error: $e');
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    salaryController.dispose();
    addressController.dispose();
    _searchDebounce?.cancel();
    _addressFocusNode.dispose();
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
        debugPrint('Searching for: $input');
        final url = '${ApiConfig.placeSearch}?query=$input';
        debugPrint('API URL: $url');

        final response = await http
            .get(
              Uri.parse(url),
            )
            .timeout(const Duration(seconds: 10));

        debugPrint('Response status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final dynamic jsonResponse = jsonDecode(response.body);
          List<dynamic> data = [];

          // Handle the response structure: {success, data: {predictions: [...]}}
          if (jsonResponse is Map<String, dynamic>) {
            if (jsonResponse['data'] is Map<String, dynamic>) {
              final dataMap = jsonResponse['data'] as Map<String, dynamic>;
              if (dataMap['predictions'] is List) {
                data = dataMap['predictions'] as List<dynamic>;
              }
            }
            // Fallback: check if predictions is directly in response
            else if (jsonResponse['predictions'] is List) {
              data = jsonResponse['predictions'] as List<dynamic>;
            }
          } else if (jsonResponse is List) {
            data = jsonResponse;
          }

          if (mounted) {
            setState(() {
              _placePredictions =
                  data.whereType<Map<String, dynamic>>().map((p) {
                return PlacePrediction.fromJson(p);
              }).toList();
              _showPredictions = _placePredictions.isNotEmpty;
              _isSearching = false;
            });
          }
        } else {
          debugPrint('API error: ${response.statusCode}');
          if (mounted) {
            setState(() {
              _isSearching = false;
              _showPredictions = false;
              _placePredictions = [];
            });
          }
        }
      } catch (e) {
        debugPrint('Search error: $e');
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
      debugPrint('Fetching details for place ID: $placeId');
      final url = '${ApiConfig.placeDetails}/$placeId';
      debugPrint('Details API URL: $url');

      final response = await http
          .get(
            Uri.parse(url),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('Details response status: ${response.statusCode}');
      debugPrint('Details response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(response.body);
        Map<String, dynamic> placeData = {};

        // Handle response structure: {success, data: {result: {...}}} - Google Places format
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

        debugPrint('Extracted place data: $placeData');

        String formattedAddress = '';
        String city = '';
        String state = '';
        String country = '';
        String pincode = '';

        // Get formatted address
        if (placeData['formatted_address'] != null) {
          formattedAddress = placeData['formatted_address'].toString();
        } else if (placeData['description'] != null) {
          formattedAddress = placeData['description'].toString();
        } else if (placeData['name'] != null) {
          formattedAddress = placeData['name'].toString();
        }

        // Parse address_components array to extract city, state, postal code
        if (placeData['address_components'] is List) {
          final components = placeData['address_components'] as List<dynamic>;
          debugPrint('Address components count: ${components.length}');

          for (var component in components) {
            if (component is! Map<String, dynamic>) continue;

            final types = component['types'] as List<dynamic>?;
            final longName = component['long_name']?.toString() ?? '';
            final shortName = component['short_name']?.toString() ?? '';

            // Extract locality (city)
            if (types != null && types.contains('locality') && city.isEmpty) {
              city = longName.isNotEmpty ? longName : shortName;
            }

            // Extract administrative_area_level_1 (state)
            if (types != null &&
                types.contains('administrative_area_level_1') &&
                state.isEmpty) {
              state = shortName.isNotEmpty ? shortName : longName;
            }
            // Extract Country
            if (types != null && types.contains('country') && country.isEmpty) {
              country = shortName.isNotEmpty ? shortName : longName;
            }

            // Extract postal_code
            if (types != null &&
                types.contains('postal_code') &&
                pincode.isEmpty) {
              pincode = longName;
            }
          }
        }

        // Fallback to flat field names if components parsing didn't work
        if (city.isEmpty && placeData['city'] != null) {
          city = placeData['city'].toString();
        }
        if (state.isEmpty && placeData['state'] != null) {
          state = placeData['state'].toString();
        }
        debugPrint('Intermediate - State: $state, Country: $country, Pincode: $pincode');
        if (country.isEmpty && placeData['country'] != null) {
          country = placeData['country'].toString();
        }
        if (pincode.isEmpty && placeData['postal_code'] != null) {
          pincode = placeData['postal_code'].toString();
        }
debugPrint('Parsed - State: $state, Country: $country, Pincode: $pincode');
        if (mounted) {
          setState(() {
            addressController.text = formattedAddress;
            _selectedCity = city.isNotEmpty ? city : null;
            _selectedState = state.isNotEmpty ? state : null;
            _selectedCountry = country.isNotEmpty ? country : null;
            _selectedPincode = pincode.isNotEmpty ? pincode : null;
            _showPredictions = false;
          });
        }
      } else {
        debugPrint('Place details API error: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Failed to load place details: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Place details error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading place details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          dutyStartTime = picked;
        } else {
          dutyEndTime = picked;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum 3 images allowed")),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (dutyStartTime == null || dutyEndTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select start and end dates")));
        return;
      }

      setState(() => _isLoading = true);

      List<String> imageUrls = [];
      try {
        if (_selectedImages.isNotEmpty) {
          for (var image in _selectedImages) {
            String uploadedUrl = await _commonService.uploadImage(File(image.path));
            imageUrls.add(uploadedUrl);
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload images: $e")),
        );
        return;
      }

      final request = CreateRequirementRequest(
        workTypeId: selectedWorkType,
        title: titleController.text.trim(),
        description: descController.text.trim(),
        personNeed: personNeed,
        maleCount: maleCount,
        femaleCount: femaleCount,
        dutyStartTime: dutyStartTime,
        dutyEndTime: dutyEndTime,
        salary: double.tryParse(salaryController.text),
        address: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        city: _selectedCity,
        state: _selectedState,
        pincode: _selectedPincode,
        country: _selectedCountry,
        images: imageUrls,
      );

      final success =
          await context.read<OwnerViewModel>().createRequirement(request);
      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Requirement Created Successfully!")));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.read<OwnerViewModel>().error ??
                "Failed to create requirement")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Requirement")),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Work Type Dropdown
                  DropdownButtonFormField<String>(
                    value:
                        selectedWorkType.isNotEmpty ? selectedWorkType : null,
                    decoration: InputDecoration(
                      labelText: "Work Type",
                      border: const OutlineInputBorder(),
                      suffixIcon: _workTypes.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : null,
                    ),
                    items: _workTypes.isEmpty
                        ? [
                            const DropdownMenuItem(
                              value: '',
                              child: Text('Loading work types...'),
                            )
                          ]
                        : _workTypes
                            .map((e) => DropdownMenuItem(
                                value: e.id, child: Text(e.name)))
                            .toList(),
                    onChanged: _workTypes.isEmpty
                        ? null
                        : (v) {
                            debugPrint('Selected work type: $v');
                            setState(() => selectedWorkType = v ?? '');
                          },
                    validator: (v) => v == null || v.isEmpty
                        ? "Please select a work type"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Title Field
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Job Title",
                      hintText: "e.g. Site Supervisor",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Title is required" : null,
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      hintText: "Job description and responsibilities",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (v) =>
                        v!.isEmpty ? "Description is required" : null,
                  ),
                  const SizedBox(height: 16),

                  // Salary Field
                  TextFormField(
                    controller: salaryController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Salary (₹)",
                      hintText: "Monthly salary",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Address Field with Search
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: addressController,
                        focusNode: _addressFocusNode,
                        decoration: InputDecoration(
                          labelText: "Address",
                          hintText: "Search and select address",
                          border: const OutlineInputBorder(),
                          suffixIcon: _isSearching
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        onChanged: (value) => _searchPlaces(value),
                        validator: (v) =>
                            v!.isEmpty ? "Address is required" : null,
                      ),
                      if (_showPredictions && _placePredictions.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Card(
                          elevation: 8,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                            ),
                            constraints: const BoxConstraints(maxHeight: 280),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: _placePredictions.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1, thickness: 0.5),
                              itemBuilder: (context, index) {
                                final prediction = _placePredictions[index];
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      debugPrint(
                                          'Selected: ${prediction.placeId}');
                                      // Dismiss keyboard
                                      FocusScope.of(context).unfocus();
                                      // Fetch place details
                                      _getPlaceDetails(prediction.placeId);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            prediction.mainText,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            prediction.secondaryText,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ] else if (_isSearching) ...[
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),



                  // Image Upload Section
                  const Text(
                    "Images (Max 3)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._selectedImages.asMap().entries.map((entry) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(File(entry.value.path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: InkWell(
                                onTap: () => _removeImage(entry.key),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      if (_selectedImages.length < 3)
                        InkWell(
                          onTap: _pickImage,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[400]!),
                            ),
                            child: const Icon(Icons.add_a_photo,
                                color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // People Requirements Section
                  const Text(
                    "People Requirements",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Total Needed Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Needed"),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => setState(
                                () => personNeed > 1 ? personNeed-- : null),
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            "$personNeed",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => personNeed++),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Male Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Male"),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => setState(
                                () => maleCount > 0 ? maleCount-- : null),
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            "$maleCount",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (maleCount + femaleCount < personNeed) {
                                setState(() => maleCount++);
                              }
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Female Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Female"),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => setState(
                                () => femaleCount > 0 ? femaleCount-- : null),
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            "$femaleCount",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (maleCount + femaleCount < personNeed) {
                                setState(() => femaleCount++);
                              }
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Duty Duration Section
                  const Text(
                    "Duty Duration",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration:
                                const InputDecoration(labelText: "Start Date"),
                            child: Text(dutyStartTime != null
                                ? DateFormat('dd/MM/yyyy')
                                    .format(dutyStartTime!)
                                : "Select Date"),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration:
                                const InputDecoration(labelText: "End Date"),
                            child: Text(dutyEndTime != null
                                ? DateFormat('dd/MM/yyyy').format(dutyEndTime!)
                                : "Select Date"),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Create Requirement",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Model class for place predictions
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
    // Extract main_text and secondary_text from structured_formatting
    String mainText = '';
    String secondaryText = '';

    if (json['structured_formatting'] is Map<String, dynamic>) {
      final formatting = json['structured_formatting'] as Map<String, dynamic>;
      mainText = formatting['main_text']?.toString() ?? '';
      secondaryText = formatting['secondary_text']?.toString() ?? '';
    } else {
      // Fallback to top-level keys if structured_formatting doesn't exist
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

// Model class for work types
class WorkType {
  final String id;
  final String name;

  WorkType({
    required this.id,
    required this.name,
  });

  factory WorkType.fromJson(Map<String, dynamic> json) {
    return WorkType(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
    );
  }
}
