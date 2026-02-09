enum ApplicationStatus { pending, accepted, rejected }

class Applicant {
  final String id;
  final String userId;
  final String requirementId;
  final String workerName;
  final String gender;
  final int experienceYears;
  final String mobileNumber;
  final ApplicationStatus status;
  final DateTime appliedDate;

  Applicant({
    required this.id,
    required this.userId,
    required this.requirementId,
    required this.workerName,
    required this.gender,
    required this.experienceYears,
    required this.mobileNumber,
    required this.status,
    required this.appliedDate,
  });

  Applicant copyWith({
    String? id,
    String? userId,
    String? requirementId,
    String? workerName,
    String? gender,
    int? experienceYears,
    String? mobileNumber,
    ApplicationStatus? status,
    DateTime? appliedDate,
  }) {
    return Applicant(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      requirementId: requirementId ?? this.requirementId,
      workerName: workerName ?? this.workerName,
      gender: gender ?? this.gender,
      experienceYears: experienceYears ?? this.experienceYears,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
    );
  }
}
