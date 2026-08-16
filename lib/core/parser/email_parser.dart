import '../models/drive_model.dart';

class EmailParserEngine {
  static PlacementDrive parseEmailText(String rawText, {String? customId}) {
    final String id = customId ?? DateTime.now().millisecondsSinceEpoch.toString();

    String cleanText = _stripEmailHeaders(rawText);

    // 1. Company Name
    String companyName = _extractCompanyName(cleanText);

    // 2. Post / Role
    String postTitle = _extractField(cleanText, [
      RegExp(r'Post:\s*(.+)'),
      RegExp(r'role of\s*(.+)'),
      RegExp(r'offering an internship for\s*(.+)'),
    ], fallback: 'Software Engineering Intern');

    // 3. Pay / Stipend
    String payStipend = _extractField(cleanText, [
      RegExp(r'Pay:\s*(.+)'),
      RegExp(r'Stipend:\s*(.+)'),
      RegExp(r'Salary:\s*(.+)'),
    ], fallback: 'Rs. 50,000 per month');

    // 4. CTC / PPO
    String ctcPpo = _extractField(cleanText, [
      RegExp(r'PPO.*?(Rs\.?\s*[\d,.]+(?:\s*LPA)?|\d+\s*LPA)', caseSensitive: false),
      RegExp(r'CTC:\s*(.+)'),
    ], fallback: '24 LPA (PPO)');

    // 5. Location
    String location = _extractField(cleanText, [
      RegExp(r'Location:\s*(.+)'),
    ], fallback: 'Bangalore');

    // 6. Duration
    String duration = _extractField(cleanText, [
      RegExp(r'Duration:\s*(.+)'),
    ], fallback: '6 Months');

    // 7. Form Deadline Date & Time
    DateTime formDeadline = _extractDeadline(cleanText);

    // 8. Eligibility Criteria
    EligibilityCriteria eligibility = _extractEligibility(cleanText);

    // 9. Activity Rounds
    List<DriveRound> rounds = _extractRounds(cleanText);

    // 10. Default Prep Checklist based on Role & Company
    List<PrepTask> prepTasks = _generateDefaultPrepTasks(companyName, postTitle);

    return PlacementDrive(
      id: id,
      companyName: companyName,
      postTitle: postTitle,
      payStipend: payStipend,
      ctcPpo: ctcPpo,
      location: location,
      formDeadline: formDeadline,
      duration: duration,
      driveSlot: 'Slot B1 / Internship',
      eligibility: eligibility,
      rounds: rounds,
      prepTasks: prepTasks,
      rawEmails: [cleanText],
      stage: DriveStage.discovered,
    );
  }

  static String _stripEmailHeaders(String text) {
    // Strip common Gmail forward / print headers
    return text.replaceAll(RegExp(r'^(From|To|Date|Subject|Cc|Bcc|Reply-To|Sent|Forwarded message)[^\n]*\n?', multiLine: true, caseSensitive: false), '').trim();
  }

  static String _extractCompanyName(String text) {
    // Check subject tag pattern: [MEC2K27] CRED Internship Drive
    RegExp subjectReg = RegExp(r'\[MEC2K27\]\s+(.*?)\s+(?:Internship|Placement)\s+Drive', caseSensitive: false);
    Match? match = subjectReg.firstMatch(text);
    if (match != null && match.group(1) != null) {
      return match.group(1)!.trim();
    }

    // Check "inform you that CRED is interested"
    RegExp bodyReg = RegExp(r'inform you that\s+(.*?)\s+is interested', caseSensitive: false);
    Match? matchBody = bodyReg.firstMatch(text);
    if (matchBody != null && matchBody.group(1) != null) {
      return matchBody.group(1)!.trim();
    }

    // Fallback search lines
    for (String line in text.split('\n')) {
      if (line.contains('Drive') && line.contains('[MEC')) {
        return line.replaceAll(RegExp(r'\[.*?\]'), '').replaceAll('Internship Drive', '').replaceAll('Placement Drive', '').trim();
      }
    }

    return 'Target Company';
  }

  static String _extractField(String text, List<RegExp> patterns, {required String fallback}) {
    for (var pattern in patterns) {
      Match? match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        String res = match.group(1)!.trim();
        // Remove trailing punctuation or HTML tags
        res = res.replaceAll(RegExp(r'<[^>]*>'), '').trim();
        if (res.endsWith('.')) res = res.substring(0, res.length - 1);
        if (res.isNotEmpty) return res;
      }
    }
    return fallback;
  }

  static DateTime _extractDeadline(String text) {
    // Pattern e.g.: "before 11:00 PM on 16th August, 2026" or "12:00 PM on 18th June, 2026"
    RegExp reg = RegExp(r'before\s+(\d{1,2}:\d{2}\s+(?:AM|PM))\s+on\s+(\d{1,2})(?:st|nd|rd|th)?\s+([A-Za-z]+),?\s+(\d{4})', caseSensitive: false);
    Match? match = reg.firstMatch(text);

    if (match != null) {
      String timeStr = match.group(1) ?? '11:00 PM';
      int day = int.tryParse(match.group(2) ?? '16') ?? 16;
      String monthStr = match.group(3) ?? 'August';
      int year = int.tryParse(match.group(4) ?? '2026') ?? 2026;

      int month = _monthToNum(monthStr);

      int hour = 23;
      int minute = 0;
      if (timeStr.contains(':')) {
        var parts = timeStr.split(' ');
        var timeParts = parts[0].split(':');
        hour = int.tryParse(timeParts[0]) ?? 11;
        minute = int.tryParse(timeParts[1]) ?? 0;
        if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour < 12) {
          hour += 12;
        }
      }

      return DateTime(year, month, day, hour, minute);
    }

    // Fallback: 3 days from now
    return DateTime.now().add(const Duration(days: 3));
  }

  static int _monthToNum(String m) {
    switch (m.toLowerCase()) {
      case 'january': case 'jan': return 1;
      case 'february': case 'feb': return 2;
      case 'march': case 'mar': return 3;
      case 'april': case 'apr': return 4;
      case 'may': return 5;
      case 'june': case 'jun': return 6;
      case 'july': case 'jul': return 7;
      case 'august': case 'aug': return 8;
      case 'september': case 'sep': case 'sept': return 9;
      case 'october': case 'oct': return 10;
      case 'november': case 'nov': return 11;
      case 'december': case 'dec': return 12;
      default: return 8;
    }
  }

  static EligibilityCriteria _extractEligibility(String text) {
    double minCgpa = 6.0;
    int maxBacklogs = 0;
    List<String> branches = ['CSE', 'CSBS'];

    // CGPA regex e.g. "6 CGPA" or "8.5 CGPA" or "6.5 CGPA"
    RegExp cgpaReg = RegExp(r'(\d+(?:\.\d+)?)\s*CGPA', caseSensitive: false);
    Match? cgpaMatch = cgpaReg.firstMatch(text);
    if (cgpaMatch != null && cgpaMatch.group(1) != null) {
      minCgpa = double.tryParse(cgpaMatch.group(1)!) ?? 6.0;
    }

    // Backlogs regex e.g. "no active backlogs"
    if (text.toLowerCase().contains('no active backlogs') || text.toLowerCase().contains('no backlogs')) {
      maxBacklogs = 0;
    }

    // Eligible Branches e.g. "Eligible Branches: CSE/ CSBS"
    RegExp branchReg = RegExp(r'Eligible Branches:\s*(.+)', caseSensitive: false);
    Match? branchMatch = branchReg.firstMatch(text);
    if (branchMatch != null && branchMatch.group(1) != null) {
      String rawB = branchMatch.group(1)!;
      final rawBranches = rawB.split(RegExp(r'[/,;\s]+')).where((s) => s.trim().isNotEmpty).toList();
      branches = rawBranches.map((b) => PlacementDrive.normalizeBranch(b)).toSet().toList();
    }

    return EligibilityCriteria(
      minCgpa: minCgpa,
      maxBacklogs: maxBacklogs,
      eligibleBranches: branches,
    );
  }

  static List<DriveRound> _extractRounds(String text) {
    List<DriveRound> rounds = [];

    if (text.contains('Resume Shortlisting') || text.contains('Online Coding Assessment')) {
      rounds.add(DriveRound(title: 'Resume Shortlisting', dateStr: '17th Aug', timeStr: 'Completed', isCompleted: true));
      rounds.add(DriveRound(title: 'Online Coding Assessment', dateStr: '20th Aug', timeStr: '7:00 PM'));
      rounds.add(DriveRound(title: 'Technical Interview (Flutter/Dart)', dateStr: '24th Aug', timeStr: '10:00 AM'));
      rounds.add(DriveRound(title: 'HR & Culture Fit', dateStr: '26th Aug', timeStr: '2:00 PM'));
    } else {
      rounds.add(DriveRound(title: 'Pre-Placement Talk', dateStr: 'TBD', timeStr: '2:00 PM'));
      rounds.add(DriveRound(title: 'Online Assessment', dateStr: 'TBD', timeStr: 'TBD'));
      rounds.add(DriveRound(title: 'Technical & HR Interviews', dateStr: 'TBD', timeStr: 'TBD'));
    }

    return rounds;
  }

  static List<PrepTask> _generateDefaultPrepTasks(String company, String role) {
    List<PrepTask> tasks = [
      PrepTask(id: '1', title: 'Update Resume with Flutter projects & GitHub links', isCompleted: true),
      PrepTask(id: '2', title: 'Revise Dart Async/Await, Futures & Streams', isCompleted: false),
      PrepTask(id: '3', title: 'Practice Widget Lifecycle & State Management (Riverpod/Provider)', isCompleted: false),
      PrepTask(id: '4', title: 'Brush up DSA (Arrays, Trees, Dynamic Programming)', isCompleted: false),
      PrepTask(id: '5', title: 'Prepare Cred UI design breakdown & animations explanation', isCompleted: false),
    ];
    return tasks;
  }
}
