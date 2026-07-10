import 'dart:io';

enum UserRole {
  worker,
  owner,
}

class CreateUserRequest {
  final String name;
  final String? email;
  final File? image;
  final String? mobileNumber;
  final String? countryCode;
  final String? aadharNo;
  final String password;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;
  final UserRole role; // 0 for Worker, 1 for Owner
  final List<String>? workTypeIds; // Using String for Guid

  CreateUserRequest({
    required this.name,
    this.email,
    this.image,
    this.mobileNumber,
    this.countryCode,
    this.aadharNo,
    required this.password,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.country,
    required this.role,
    this.workTypeIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Email': email,
      'Image': image?.path,
      'MobileNumber': mobileNumber,
      'CountryCode': countryCode,
      'AadharNo': aadharNo,
      'Password': password,
      'Address': address,
      'City': city,
      'State': state,
      'Pincode': pincode,
      'Country': country,
      'Role': role.index, // Enum index: Worker=0, Owner=1
      'WorkTypeIds': workTypeIds,
    };
  }
}

class User {
  final String id;
  final String name;
  final String? email;
  final String? imageUrl;
  final String? mobileNumber;
  final String? countryCode;
  final String? aadharNo;
  final String? roleName;
  final String? referralCode;
  final bool? isVerified;
  final UserRole role;
  final List<Map<String, dynamic>>? addresses;
  final String? roleId;
  final bool? isTearmAccepted;
  // Add other fields as needed for response

  User({
    required this.id,
    required this.name,
    this.email,
    this.imageUrl,
    this.mobileNumber,
    this.countryCode,
    this.aadharNo,
    this.roleName,
    this.referralCode,
    this.isVerified,
    required this.role,
    this.addresses,
    this.roleId,
    this.isTearmAccepted,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Determine role from roleName string
    final String? roleName = json['roleName'] ?? json['RoleName'];
    UserRole userRole = UserRole.worker; // default
    if (roleName != null) {
      if (roleName.toLowerCase() == 'owner') {
        userRole = UserRole.owner;
      } else if (roleName.toLowerCase() == 'worker' ||
          roleName.toLowerCase() == 'labour') {
        userRole = UserRole.worker;
      }
    } else {
      // Fallback to role index if roleName is not available
      userRole = UserRole.values[(json['role'] ?? json['Role'] ?? 0) as int];
    }

    // Handle addresses - API returns userAddresses
    List<Map<String, dynamic>>? userAddresses;
    if (json['userAddresses'] is List) {
      userAddresses = List<Map<String, dynamic>>.from(json['userAddresses']);
    } else if (json['addresses'] is List) {
      userAddresses = List<Map<String, dynamic>>.from(json['addresses']);
    }

    return User(
      id: json['id'] ?? json['Id'] ?? '',
      name: json['name'] ?? json['Name'] ?? '',
      email: json['email'] ?? json['Email'],
      imageUrl: json['imageUrl'] ?? json['ImageUrl'] ?? json['image'] ?? json['Image'],
      mobileNumber: json['mobileNumber'] ?? json['MobileNumber'],
      countryCode: json['countryCode'] ?? json['CountryCode'],
      aadharNo: json['aadharNo'] ?? json['AadharNo'],
      roleName: roleName,
      referralCode: json['referralCode'] ?? json['ReferralCode'],
      isVerified: json['isVerified'] ?? json['IsVerified'],
      role: userRole,
      addresses: userAddresses,
      roleId: json['roleId'] ?? json['RoleId'],
      isTearmAccepted: json['isTearmAccepted'] ?? json['IsTearmAccepted'],
    );
  }
}
