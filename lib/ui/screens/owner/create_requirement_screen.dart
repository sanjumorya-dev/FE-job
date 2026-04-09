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
import 'package:dihaadi_app/viewmodels/work_type_viewmodel.dart';
import 'package:dihaadi_app/constants/colors.dart';
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
  List<String> selectedWorkTypeIds = [];
  int personNeed = 1;
  int maleCount = 1;
  int femaleCount = 0;
  List<String> images = [];
  DateTime? dutyStartTime;
  DateTime? dutyEndTime;
  bool _isLoading = false;
  List<PlacePrediction> _placePredictions = [];
  bool _showPredictions = false;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkTypeViewModel>().fetchWorkTypes().then((_) {
        if (mounted && selectedWorkTypeIds.isEmpty) {
          final types = context.read<WorkTypeViewModel>().workTypes;
          if (types.isNotEmpty) {
            setState(() {
              selectedWorkTypeIds = [types.first.id];
            });
          }
        }
      });
    });
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
      if (selectedWorkTypeIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select at least one work type")));
        return;
      }

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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to upload images: $e")),
          );
        }
        return;
      }

      final request = CreateRequirementRequest(
        workTypeIds: selectedWorkTypeIds,
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

      final ownerViewModel = context.read<OwnerViewModel>();
      final success = await ownerViewModel.createRequirement(request);
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Requirement Created Successfully!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ownerViewModel.error ??
                "Failed to create requirement")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Custom Header
                    _buildHeader(),
                    
                    const SizedBox(height: 20),
                    // 2. Intro Banner
                    _buildIntroBanner(),
                    
                    const SizedBox(height: 30),
                    
                    // 3. Basic Details Section
                    _buildSectionHeader("Basic details", "Required"),
                    const SizedBox(height: 12),
                    _buildBasicDetailsSection(),
                    
                    const SizedBox(height: 30),
                    
                    // 4. Job Info Section
                    _buildSectionHeader("Job info", "Premium form"),
                    const SizedBox(height: 12),
                    _buildJobInfoSection(),
                    
                    const SizedBox(height: 30),
                    
                    // 5. Images Section
                    _buildSectionHeader("Images", "Optional"),
                    const SizedBox(height: 12),
                    _buildImagesSection(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Owner workspace',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9AA1B4),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Create Requirement',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntroBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Post requirement in\none clean form',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F3A50),
                  height: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2182F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Single form',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Add core job info, worker count, dates, and site details with less scrolling.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6D7487),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String badge) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F3A50),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F5FA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badge,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9AA1B4),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputContainer({required Widget child, Color? color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFF3F5FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildBasicDetailsSection() {
    return Column(
      children: [
        // Work Types
        _buildInputContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WORK TYPES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHint,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Consumer<WorkTypeViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading && viewModel.workTypes.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: viewModel.workTypes.map((type) {
                      final isSelected = selectedWorkTypeIds.contains(type.id);
                      return FilterChip(
                        label: Text(type.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedWorkTypeIds.add(type.id);
                            } else {
                              selectedWorkTypeIds.remove(type.id);
                            }
                          });
                        },
                        selectedColor: AppColors.primary,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.secondary,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : Colors.grey.shade200,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Job Title
        _buildInputContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Job title', style: TextStyle(fontSize: 12, color: Color(0xFF9AA1B4), fontWeight: FontWeight.w500)),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter job title',
                  hintStyle: TextStyle(color: Color(0xFF728EAC), fontSize: 16),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 6),
                ),
                style: const TextStyle(fontSize: 16, color: Color(0xFF4A5568), fontWeight: FontWeight.w500),
                validator: (v) => v!.isEmpty ? 'Title is required' : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Description
        _buildInputContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Description', style: TextStyle(fontSize: 12, color: Color(0xFF9AA1B4), fontWeight: FontWeight.w500)),
              TextFormField(
                controller: descController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Describe the work, site condition, tools, timing, and expectations for selected workers.',
                  hintStyle: TextStyle(color: Color(0xFF728EAC), height: 1.5, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                style: const TextStyle(fontSize: 15, color: Color(0xFF4A5568), height: 1.5),
                validator: (v) => v!.isEmpty ? 'Description is required' : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobInfoSection() {
    return Column(
      children: [
        // Salary
        _buildInputContainer(
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(color: const Color(0xFFF3F5FA), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.currency_rupee, size: 22, color: Color(0xFF9AA1B4)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Salary', style: TextStyle(fontSize: 12, color: Color(0xFF9AA1B4), fontWeight: FontWeight.w500)),
                    TextFormField(
                      controller: salaryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter daily wage in ₹',
                        hintStyle: TextStyle(color: Color(0xFF728EAC), fontSize: 16),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                      ),
                      style: const TextStyle(fontSize: 16, color: Color(0xFF4A5568), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Address
        _buildInputContainer(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(color: const Color(0xFFF3F5FA), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.location_on_outlined, size: 22, color: Color(0xFF9AA1B4)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Address',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9AA1B4),
                                fontWeight: FontWeight.w500)),
                        if (_isSearching)
                          const SizedBox(
                            height: 12,
                            width: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                          ),
                      ],
                    ),
                    TextFormField(
                      controller: addressController,
                      focusNode: _addressFocusNode,
                      onChanged: _searchPlaces,
                      decoration: const InputDecoration(
                        hintText: 'Add city, area, or full a...',
                        hintStyle: TextStyle(color: Color(0xFF728EAC), fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                      ),
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF4A5568), height: 1.2),
                      validator: (v) => v!.isEmpty ? 'Address is required' : null,
                    ),
                    if (_showPredictions && _placePredictions.isNotEmpty)
                       _buildAddressPredictions(),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {}, // TODO: GPS logic
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(color: const Color(0xFFF3F5FA), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.near_me_outlined, size: 20, color: Color(0xFF9AA1B4)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Counters
        Row(
          children: [
            Expanded(child: _buildCounterBox("Male\nrequired", maleCount, Icons.person_outline_rounded, (v) => setState(() => maleCount = v), (maleCount + femaleCount < personNeed))),
            const SizedBox(width: 8),
            Expanded(child: _buildCounterBox("Female\nrequired", femaleCount, Icons.group_outlined, (v) => setState(() => femaleCount = v), (maleCount + femaleCount < personNeed))),
            const SizedBox(width: 8),
            Expanded(child: _buildCounterBox("Total\nneeded", personNeed, Icons.work_outline_rounded, (v) => setState(() => personNeed = v), true)),
          ],
        ),
        const SizedBox(height: 12),
        
        // Dates
        Row(
          children: [
            Expanded(
              child: _buildDateBox("Start date", dutyStartTime, () => _selectDate(context, true)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateBox("End date", dutyEndTime, () => _selectDate(context, false)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterBox(String label, int value, IconData icon, ValueChanged<int> onChanged, bool canIncrease) {
    return _buildInputContainer(
      child: Column(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: const Color(0xFF9AA1B4)),
          ),
          const SizedBox(height: 12),
          Text(
            label, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Color(0xFF9AA1B4), fontWeight: FontWeight.w500, height: 1.2),
          ),
          const SizedBox(height: 12),
          Text('$value', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2F3A50))),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () { if (value > 0) onChanged(value - 1); },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.remove, size: 14, color: Color(0xFF2F3A50)),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () { if (canIncrease) onChanged(value + 1); },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: const Color(0xFF2F3A50), borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.add, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: _buildInputContainer(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9AA1B4), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text(
                    date != null ? DateFormat('dd MMM, yyyy').format(date) : 'Select date',
                    style: TextStyle(
                      fontSize: 13, 
                      fontWeight: FontWeight.bold, 
                      color: date != null ? const Color(0xFF2182F3) : const Color(0xFF728EAC),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 36,
              width: 36,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.calendar_month_outlined, size: 18, color: Color(0xFF9AA1B4)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressPredictions() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _placePredictions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final prediction = _placePredictions[index];
          return ListTile(
            dense: true,
            title: Text(prediction.mainText, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(prediction.secondaryText),
            onTap: () {
              FocusScope.of(context).unfocus();
              _getPlaceDetails(prediction.placeId);
            },
          );
        },
      ),
    );
  }

  Widget _buildImagesSection() {
    return Row(
      children: [
        // Add Image Button
        Expanded(
          child: InkWell(
            onTap: _pickImage,
            child: _buildInputContainer(
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 30, color: Color(0xFF9AA1B4)),
                  SizedBox(height: 12),
                  Text('Add image', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2F3A50))),
                  SizedBox(height: 4),
                  Text('Max 3', style: TextStyle(fontSize: 11, color: Color(0xFF9AA1B4))),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Image Preview
        Expanded(
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _selectedImages.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: const Text('Site photo', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF9AA1B4))),
                      ),
                      const SizedBox(height: 10),
                      const Text('No images', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF9AA1B4))),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(8),
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_selectedImages[index].path), 
                            width: 100, 
                            height: 100, 
                            fit: BoxFit.cover
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 14, color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: TextButton(
              onPressed: () {}, // TODO: Save Draft
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Save Draft', style: TextStyle(color: Color(0xFF2F3A50), fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2182F3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Create Requirement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 12),
                  Icon(Icons.arrow_forward, size: 18),
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

