import 'package:flutter_test/flutter_test.dart';
import 'package:drivedeck/core/models/drive_model.dart';
import 'package:drivedeck/core/parser/email_parser.dart';

void main() {
  group('Standard Branch & Eligibility Tests', () {
    test('normalizeBranch handles standard branches and aliases', () {
      expect(PlacementDrive.normalizeBranch('cse'), equals('CSE'));
      expect(PlacementDrive.normalizeBranch('CSBS'), equals('CSBS'));
      expect(PlacementDrive.normalizeBranch('eee'), equals('EEE'));
      expect(PlacementDrive.normalizeBranch('EE'), equals('EEE'));
      expect(PlacementDrive.normalizeBranch('ev'), equals('EV'));
      expect(PlacementDrive.normalizeBranch('ece'), equals('ECE'));
      expect(PlacementDrive.normalizeBranch('EC'), equals('ECE'));
      expect(PlacementDrive.normalizeBranch('ebe'), equals('EBE'));
      expect(PlacementDrive.normalizeBranch('EB'), equals('EBE'));
      expect(PlacementDrive.normalizeBranch('me'), equals('ME'));
      expect(PlacementDrive.normalizeBranch('MECH'), equals('ME'));
    });

    test('checkEligibility correctly matches student branch', () {
      final drive = PlacementDrive(
        id: 'test-1',
        companyName: 'TechCorp',
        postTitle: 'Engineer',
        payStipend: '50k',
        location: 'Bangalore',
        formDeadline: DateTime.now().add(const Duration(days: 5)),
        eligibility: EligibilityCriteria(
          minCgpa: 7.0,
          maxBacklogs: 0,
          eligibleBranches: ['CSE', 'CSBS', 'ECE', 'ME'],
        ),
        rounds: [],
        prepTasks: [],
        rawEmails: [],
      );

      // Eligible student
      expect(drive.checkEligibility(8.0, 0, 'CSE'), isTrue);
      expect(drive.checkEligibility(7.5, 0, 'MECH'), isTrue);
      expect(drive.checkEligibility(7.0, 0, 'EC'), isTrue);
      expect(drive.checkEligibility(9.0, 0, 'CSBS'), isTrue);

      // Ineligible branch
      expect(drive.checkEligibility(8.0, 0, 'EEE'), isFalse);
      expect(drive.checkEligibility(8.0, 0, 'EBE'), isFalse);
      expect(drive.checkEligibility(8.0, 0, 'EV'), isFalse);

      // Ineligible CGPA / Backlogs
      expect(drive.checkEligibility(6.5, 0, 'CSE'), isFalse);
      expect(drive.checkEligibility(8.5, 1, 'CSE'), isFalse);
    });

    test('DriveRound supports platform, date, time and status', () {
      final round = DriveRound(
        title: 'Technical Round 1',
        dateStr: '20th Aug 2026',
        timeStr: '10:00 AM',
        platform: 'Google Meet',
        isCompleted: true,
      );

      expect(round.title, equals('Technical Round 1'));
      expect(round.platform, equals('Google Meet'));
      expect(round.isCompleted, isTrue);

      final json = round.toJson();
      final roundFromJson = DriveRound.fromJson(json);
      expect(roundFromJson.title, equals('Technical Round 1'));
      expect(roundFromJson.platform, equals('Google Meet'));
      expect(roundFromJson.isCompleted, isTrue);
    });

    test('EmailParser normalizes multi-branch notice correctly', () {
      const email = '''
[MEC2K27] Tesla EV Internship Drive
• Post: Firmware Intern
• Pay: Rs. 60,000 per month
• Criteria: 7.0 CGPA
• Eligible Branches: CSE/ ECE/ EEE/ EV/ ME/ EB
• Location: Pune
fill before 11:00 PM on 22nd August, 2026.
''';

      final drive = EmailParserEngine.parseEmailText(email);
      expect(drive.eligibility.eligibleBranches, contains('CSE'));
      expect(drive.eligibility.eligibleBranches, contains('ECE'));
      expect(drive.eligibility.eligibleBranches, contains('EEE'));
      expect(drive.eligibility.eligibleBranches, contains('EV'));
      expect(drive.eligibility.eligibleBranches, contains('ME'));
      expect(drive.eligibility.eligibleBranches, contains('EBE'));
    });
  });
}
