enum UserRole { resident, freelancer, admin }

UserRole userRoleFromValue(Object? value) {
  final normalized = value
      ?.toString()
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z]'), '');

  if (normalized == 'admin' || normalized == 'administrator') {
    return UserRole.admin;
  }
  if (normalized == 'freelancer' ||
      normalized == 'provider' ||
      normalized == 'serviceprovider' ||
      normalized == 'worker' ||
      normalized == 'userrolefreelancer') {
    return UserRole.freelancer;
  }
  // 'client', 'resident', 'user', or anything else -> resident
  return UserRole.resident;
}