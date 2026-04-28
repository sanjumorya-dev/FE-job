class OwnerDashboardStats {
  final int activeRequirements;
  final int totalApplicants;
  final int hiredWorkers;
  final int completedJobs;

  OwnerDashboardStats({
    required this.activeRequirements,
    required this.totalApplicants,
    required this.hiredWorkers,
    required this.completedJobs,
  });

  factory OwnerDashboardStats.fromJson(Map<String, dynamic> json) {
    return OwnerDashboardStats(
      activeRequirements: (json['activeRequirementCount'] ??
              json['ActiveRequirementCount'] ??
              json['activeRequirements'] ??
              json['ActiveRequirements'] ??
              0)
          .toInt(),
      totalApplicants: (json['requestCount'] ??
              json['RequestCount'] ??
              json['totalApplicants'] ??
              json['TotalApplicants'] ??
              0)
          .toInt(),
      hiredWorkers: (json['hiredWorkers'] ?? json['HiredWorkers'] ?? 0).toInt(),
      completedJobs: (json['completedJobs'] ??
              json['CompletedJobs'] ??
              json['requirementCount'] ??
              json['RequirementCount'] ??
              0)
          .toInt(),
    );
  }
}

class WorkerDashboardStats {
  final int appliedJobs;
  final int acceptedJobs;
  final int completedJobs;
  final double earnings;
  final double averageRating;
  final int totalRatings;

  WorkerDashboardStats({
    required this.appliedJobs,
    required this.acceptedJobs,
    required this.completedJobs,
    required this.earnings,
    required this.averageRating,
    required this.totalRatings,
  });

  factory WorkerDashboardStats.fromJson(Map<String, dynamic> json) {
    return WorkerDashboardStats(
      appliedJobs:
          (json['totalInvolved'] ?? json['TotalInvolved'] ?? json['appliedJobs'] ?? json['AppliedJobs'] ?? 0)
              .toInt(),
      acceptedJobs: (json['acceptedRequests'] ??
              json['AcceptedRequests'] ??
              json['acceptedJobs'] ??
              json['AcceptedJobs'] ??
              0)
          .toInt(),
      completedJobs: (json['completedJobs'] ?? json['CompletedJobs'] ?? 0).toInt(),
      earnings: (json['earnings'] ?? json['Earnings'] ?? 0.0).toDouble(),
      averageRating: (json['averageRating'] ?? json['AverageRating'] ?? 0.0).toDouble(),
      totalRatings: (json['totalRatings'] ?? json['TotalRatings'] ?? 0).toInt(),
    );
  }
}
