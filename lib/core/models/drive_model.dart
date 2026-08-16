
enum DriveStage {
  discovered,
  applied,
  shortlisted,
  interview,
  offer,
  rejected;

  String get label {
    switch (this) {
      case DriveStage.discovered:
        return 'Discovered';
      case DriveStage.applied:
        return 'Applied';
      case DriveStage.shortlisted:
        return 'Shortlisted';
      case DriveStage.interview:
        return 'Interview';
      case DriveStage.offer:
        return 'Offer Recvd';
      case DriveStage.rejected:
        return 'Not Selected';
    }
  }
}

class EligibilityCriteria {
  final double minCgpa;
  final int maxBacklogs;
  final List<String> eligibleBranches;

  EligibilityCriteria({
    required this.minCgpa,
    required this.maxBacklogs,
    required this.eligibleBranches,
  });

  Map<String, dynamic> toJson() => {
        'minCgpa': minCgpa,
        'maxBacklogs': maxBacklogs,
        'eligibleBranches': eligibleBranches,
      };

  factory EligibilityCriteria.fromJson(Map<String, dynamic> json) =>
      EligibilityCriteria(
        minCgpa: (json['minCgpa'] as num).toDouble(),
        maxBacklogs: json['maxBacklogs'] as int,
        eligibleBranches: List<String>.from(json['eligibleBranches'] ?? []),
      );
}

class DriveRound {
  final String title;
  final String dateStr;
  final String timeStr;
  final String platform;
  final bool isCompleted;

  DriveRound({
    required this.title,
    required this.dateStr,
    this.timeStr = 'TBD',
    this.platform = 'Online / Assessment',
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'dateStr': dateStr,
        'timeStr': timeStr,
        'platform': platform,
        'isCompleted': isCompleted,
      };

  factory DriveRound.fromJson(Map<String, dynamic> json) => DriveRound(
        title: json['title'] ?? '',
        dateStr: json['dateStr'] ?? '',
        timeStr: json['timeStr'] ?? 'TBD',
        platform: json['platform'] ?? 'Online / Assessment',
        isCompleted: json['isCompleted'] ?? false,
      );
}

class PrepTask {
  final String id;
  final String title;
  bool isCompleted;

  PrepTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };

  factory PrepTask.fromJson(Map<String, dynamic> json) => PrepTask(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        isCompleted: json['isCompleted'] ?? false,
      );
}

class PlacementDrive {
  final String id;
  final String companyName;
  final String postTitle;
  final String payStipend;
  final String ctcPpo;
  final String location;
  final DateTime formDeadline;
  final String duration;
  final String driveSlot;
  final EligibilityCriteria eligibility;
  final List<DriveRound> rounds;
  final List<PrepTask> prepTasks;
  final List<String> rawEmails;
  DriveStage stage;
  final DateTime createdAt;
  bool isPinned;

  PlacementDrive({
    required this.id,
    required this.companyName,
    required this.postTitle,
    required this.payStipend,
    this.ctcPpo = 'N/A',
    required this.location,
    required this.formDeadline,
    this.duration = '6 Months',
    this.driveSlot = 'Internship Drive',
    required this.eligibility,
    required this.rounds,
    required this.prepTasks,
    required this.rawEmails,
    this.stage = DriveStage.discovered,
    DateTime? createdAt,
    this.isPinned = false,
  }) : createdAt = createdAt ?? DateTime.now();

  static String normalizeBranch(String branch) {
    final b = branch.trim().toUpperCase();
    if (b == 'EB' || b == 'EBE' || b.contains('BIOMED')) return 'EBE';
    if (b == 'EC' || b == 'ECE' || b.contains('ELECTRONIC')) return 'ECE';
    if (b == 'EE' || b == 'EEE' || b.contains('ELECTRICAL')) return 'EEE';
    if (b == 'ME' || b == 'MECH' || b.contains('MECHANICAL')) return 'ME';
    if (b == 'CS' || b == 'CSE' || b.contains('COMPUTER')) return 'CSE';
    if (b == 'CSBS' || b == 'CSB' || b.contains('BUSINESS')) return 'CSBS';
    if (b == 'EV' || b.contains('VEHICLE')) return 'EV';
    return b;
  }

  bool checkEligibility(double userCgpa, int userBacklogs, String userBranch) {
    if (userCgpa < eligibility.minCgpa) return false;
    if (userBacklogs > eligibility.maxBacklogs) return false;
    if (eligibility.eligibleBranches.isNotEmpty) {
      final normUser = normalizeBranch(userBranch);
      bool branchMatch = eligibility.eligibleBranches.any((b) {
        final normB = normalizeBranch(b);
        return normUser == normB || b.toUpperCase() == userBranch.toUpperCase();
      });
      if (!branchMatch) return false;
    }
    return true;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyName': companyName,
        'postTitle': postTitle,
        'payStipend': payStipend,
        'ctcPpo': ctcPpo,
        'location': location,
        'formDeadline': formDeadline.toIso8601String(),
        'duration': duration,
        'driveSlot': driveSlot,
        'eligibility': eligibility.toJson(),
        'rounds': rounds.map((r) => r.toJson()).toList(),
        'prepTasks': prepTasks.map((t) => t.toJson()).toList(),
        'rawEmails': rawEmails,
        'stage': stage.name,
        'createdAt': createdAt.toIso8601String(),
        'isPinned': isPinned,
      };

  factory PlacementDrive.fromJson(Map<String, dynamic> json) => PlacementDrive(
        id: json['id'] ?? '',
        companyName: json['companyName'] ?? '',
        postTitle: json['postTitle'] ?? '',
        payStipend: json['payStipend'] ?? '',
        ctcPpo: json['ctcPpo'] ?? 'N/A',
        location: json['location'] ?? '',
        formDeadline: DateTime.parse(json['formDeadline']),
        duration: json['duration'] ?? '6 Months',
        driveSlot: json['driveSlot'] ?? 'Internship Drive',
        eligibility: EligibilityCriteria.fromJson(json['eligibility']),
        rounds: (json['rounds'] as List? ?? [])
            .map((r) => DriveRound.fromJson(r))
            .toList(),
        prepTasks: (json['prepTasks'] as List? ?? [])
            .map((t) => PrepTask.fromJson(t))
            .toList(),
        rawEmails: List<String>.from(json['rawEmails'] ?? []),
        stage: DriveStage.values.firstWhere(
          (e) => e.name == json['stage'],
          orElse: () => DriveStage.discovered,
        ),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        isPinned: json['isPinned'] ?? false,
      );
}
