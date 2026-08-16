class StudentProfile {
  final String name;
  final String branch;
  final double cgpa;
  final int activeBacklogs;
  final String targetRole;

  StudentProfile({
    required this.name,
    required this.branch,
    required this.cgpa,
    required this.activeBacklogs,
    required this.targetRole,
  });

  /// True when the user has never set up their profile.
  bool get isNew => name.isEmpty;

  factory StudentProfile.defaultProfile() {
    return StudentProfile(
      name: '',
      branch: 'CSE',
      cgpa: 0.0,
      activeBacklogs: 0,
      targetRole: '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'branch': branch,
        'cgpa': cgpa,
        'activeBacklogs': activeBacklogs,
        'targetRole': targetRole,
      };

  factory StudentProfile.fromJson(Map<String, dynamic> json) => StudentProfile(
        name: json['name'] ?? '',
        branch: json['branch'] ?? 'CSE',
        cgpa: (json['cgpa'] as num?)?.toDouble() ?? 0.0,
        activeBacklogs: json['activeBacklogs'] as int? ?? 0,
        targetRole: json['targetRole'] ?? '',
      );
}
