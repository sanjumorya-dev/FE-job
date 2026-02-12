class CreateRequirementRequest {
  final String workTypeId;
  final String title;
  final String description;
  final int personNeed;
  final int maleCount;
  final int femaleCount;
  final DateTime? dutyStartTime;
  final DateTime? dutyEndTime;
  final double? salary;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;
  final List<String> images;
  final int? status; // Added for edit
  final DateTime? date; // Added for edit

  CreateRequirementRequest({
    required this.workTypeId,
    required this.title,
    required this.description,
    required this.personNeed,
    this.maleCount = 0, // Made optional
    this.femaleCount = 0, // Made optional
    this.dutyStartTime,
    this.dutyEndTime,
    this.salary,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.country,
    this.images = const [],
    this.status,
    this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'WorkTypeId': workTypeId,
      'Title': title,
      'Description': description,
      'PersonNeed': personNeed,
      'MaleCount': maleCount,
      'FemaleCount': femaleCount,
      'DutyStartTime': dutyStartTime?.toUtc().toIso8601String(),
      'DutyEndTime': dutyEndTime?.toUtc().toIso8601String(),
      'Salary': salary,
      'Address': address,
      'City': city,
      'State': state,
      'Pincode': pincode,
      'Country': country,
      'Images': images,
      if (status != null) 'Status': status,
      if (date != null) 'Date': date?.toUtc().toIso8601String(),
    };
  }
}

class Requirement {
  final String id;
  final String workTypeId;
  final String title;
  final String description;
  final DateTime? dutyStartTime;
  final DateTime? dutyEndTime;
  final double? salary;
  final int status;
  final int? personNeed;
  final String? address;
  final String? userId; // Added for Owner/Labour association
  final DateTime? date; // Creation date

  Requirement({
    required this.id,
    required this.workTypeId,
    required this.title,
    required this.description,
    this.dutyStartTime,
    this.dutyEndTime,
    this.salary,
    this.status = 0,
    this.personNeed,
    this.address,
    this.userId,
    this.date,
  });

  factory Requirement.fromJson(Map<String, dynamic> json) {
    return Requirement(
      // Map backend response fields
      id: json['id'] ?? json['Id'] ?? '',
      workTypeId: json['workTypeId'] ?? json['WorkTypeId'] ?? '',
      title: json['title'] ?? json['Title'] ?? '',
      description: json['description'] ?? json['Description'] ?? '',
      dutyStartTime: json['dutyStartTime'] != null
          ? DateTime.tryParse(json['dutyStartTime'].toString())
          : json['DutyStartTime'] != null
              ? DateTime.tryParse(json['DutyStartTime'].toString())
              : null,
      dutyEndTime: json['dutyEndTime'] != null
          ? DateTime.tryParse(json['dutyEndTime'].toString())
          : json['DutyEndTime'] != null
              ? DateTime.tryParse(json['DutyEndTime'].toString())
              : null,
      salary: json['salary'] != null
          ? (json['salary'] as num).toDouble()
          : json['Salary'] != null
              ? (json['Salary'] as num).toDouble()
              : null,
      status: json['status'] is int
          ? json['status']
          : json['Status'] is int
              ? json['Status']
              : 0,
      personNeed: json['personNeed'] != null
          ? (json['personNeed'] as num).toInt()
          : json['PersonNeed'] != null
              ? (json['PersonNeed'] as num).toInt()
              : null,
      address: json['fulladdress'] ?? json['fullAddress'],
    );
  }
}

class OwnerRequirementsRequest {
  final int status;
  final String? search;
  final String? workTypeId;
  final int page;
  final int limit;

  OwnerRequirementsRequest({
    required this.status,
    this.search,
    this.workTypeId,
    required this.page,
    required this.limit,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (search != null) 'search': search,
      if (workTypeId != null) 'workTypeId': workTypeId,
      'page': page,
      'limit': limit,
    };
  }
}
