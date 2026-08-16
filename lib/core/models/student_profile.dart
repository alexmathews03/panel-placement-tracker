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

  factory StudentProfile.defaultProfile() {
    return StudentProfile(
      name: 'Alex Mathews',
      branch: 'CSBS',
      cgpa: 8.72,
      activeBacklogs: 0,
      targetRole: 'Flutter / Mobile Engineer',
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
        name: json['name'] ?? 'Alex Mathews',
        branch: json['branch'] ?? 'CSBS',
        cgpa: (json['cgpa'] as num?)?.toDouble() ?? 8.72,
        activeBacklogs: json['activeBacklogs'] as int? ?? 0,
        targetRole: json['targetRole'] ?? 'Flutter / Mobile Engineer',
      );
}
