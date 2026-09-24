enum ApplicationStatus { pending, approved, rejected, completed }

class FreelancerApplication {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String requestedService;
  ApplicationStatus status;

  FreelancerApplication({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.requestedService,
    this.status = ApplicationStatus.pending,
  });
}