import 'package:flutter_test/flutter_test.dart';
import 'package:drivedeck/core/parser/email_parser.dart';
import 'package:drivedeck/core/models/drive_model.dart';

void main() {
  group('EmailParserEngine Tests', () {
    test('Parses CRED Placement Email correctly', () {
      const sampleCredEmail = '''
[MEC2K27] CRED Internship Drive
Diya Martin <diyamartin.mec@gmail.com>

Dear All,

CRED is interested in offering an internship for the 2027 batch of MEC. Please find the details below.

• Post: Flutter Intern
• Pay: Rs. 75,000 per month
• Criteria: 6 CGPA and no active backlogs
• Duration: 6 months
• Eligible Branches: CSE/ CSBS
• Location: Bangalore

All eligible and interested students are requested to fill the form before 11:00 PM on 16th August, 2026.
''';

      PlacementDrive drive = EmailParserEngine.parseEmailText(sampleCredEmail);

      expect(drive.companyName.toUpperCase(), contains('CRED'));
      expect(drive.postTitle, equals('Flutter Intern'));
      expect(drive.payStipend, equals('Rs. 75,000 per month'));
      expect(drive.location, equals('Bangalore'));
      expect(drive.eligibility.minCgpa, equals(6.0));
      expect(drive.eligibility.maxBacklogs, equals(0));
      expect(drive.eligibility.eligibleBranches, contains('CSE'));
      expect(drive.formDeadline.month, equals(8)); // August
      expect(drive.formDeadline.day, equals(16));
    });

    test('Parses Openmynz Placement Email correctly', () {
      const sampleOpenmynzEmail = '''
[MEC2K27] Openmynz Solutions Internship Drive

• Post: Full Stack Developer Intern
• Pay: Rs. 25,000 - Rs 45,000 per month
• Criteria: 8.5 CGPA and no active backlogs
• Location: Bangalore

All eligible students fill form before 12:00 PM on 18th June, 2026.
''';

      PlacementDrive drive = EmailParserEngine.parseEmailText(sampleOpenmynzEmail);

      expect(drive.companyName.toUpperCase(), contains('OPENMYNZ'));
      expect(drive.eligibility.minCgpa, equals(8.5));
      expect(drive.formDeadline.month, equals(6)); // June
      expect(drive.formDeadline.day, equals(18));
    });
  });
}
