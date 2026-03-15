class CreateRequirementRequest {
  final List<String> workTypeIds;
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
  final int? status;
  final DateTime? date;

  CreateRequirementRequest({
    required this.workTypeIds,
    required this.title,
    required this.description,
    required this.personNeed,
    this.maleCount = 0,
    this.femaleCount = 0,
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
      'WorkTypeIds': workTypeIds,
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

class RequirementWorkType {
  final String id;
  final String name;
  final String description;

  const RequirementWorkType({
    required this.id,
    required this.name,
    required this.description,
  });

  factory RequirementWorkType.fromJson(Map<String, dynamic> json) {
    return RequirementWorkType(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      name: (json['name'] ?? json['Name'] ?? '').toString(),
      description: (json['description'] ?? json['Description'] ?? '').toString(),
    );
  }
}

class Requirement {
  final String id;
  final List<String> workTypeIds;
  final List<RequirementWorkType> workTypes;
  final String title;
  final String description;
  final DateTime? dutyStartTime;
  final DateTime? dutyEndTime;
  final double? salary;
  final int status;
  final int? personNeed;
  final String? address;
  final String? userId;
  final DateTime? date;

  String get workTypeId => workTypeIds.isNotEmpty ? workTypeIds.first : '';

  Requirement({
    required this.id,
    required this.workTypeIds,
    required this.workTypes,
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
    final dynamic workTypeIdsValue = json['workTypeIds'] ?? json['WorkTypeIds'];
    final List<String> parsedWorkTypeIds = workTypeIdsValue is List
        ? workTypeIdsValue.map((e) => e.toString()).toList()
        : [
            if ((json['workTypeId'] ?? json['WorkTypeId']) != null)
              (json['workTypeId'] ?? json['WorkTypeId']).toString(),
          ];

    final dynamic workTypesValue = json['workTypes'] ?? json['WorkTypes'];
    final List<RequirementWorkType> parsedWorkTypes = workTypesValue is List
        ? workTypesValue
            .whereType<Map>()
            .map((e) => RequirementWorkType.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : const [];

    return Requirement(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      workTypeIds: parsedWorkTypeIds,
      workTypes: parsedWorkTypes,
      title: (json['title'] ?? json['Title'] ?? '').toString(),
      description: (json['description'] ?? json['Description'] ?? '').toString(),
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
      address: (json['fulladdress'] ?? json['fullAddress'] ?? json['address'] ?? json['Address'])
          ?.toString(),
      userId: (json['userId'] ?? json['UserId'])?.toString(),
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : json['Date'] != null
              ? DateTime.tryParse(json['Date'].toString())
              : null,
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
