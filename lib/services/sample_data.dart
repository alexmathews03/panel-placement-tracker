import '../core/models/drive_model.dart';
import '../core/models/student_profile.dart';

class SampleData {
  static StudentProfile defaultUser = StudentProfile(
    name: 'Alex Mathews',
    branch: 'CSBS',
    cgpa: 8.72,
    activeBacklogs: 0,
    targetRole: 'Flutter Developer Intern',
  );

  static List<PlacementDrive> initialDrives = [
    PlacementDrive(
      id: 'cred-flutter-2026',
      companyName: 'CRED',
      postTitle: 'Flutter Intern',
      payStipend: 'Rs. 75,000 per month',
      ctcPpo: '24 LPA (PPO)',
      location: 'Bangalore',
      formDeadline: DateTime(2026, 8, 16, 23, 0),
      duration: '6 Months',
      driveSlot: 'Slot B1 / Premium Intern',
      stage: DriveStage.shortlisted,
      eligibility: EligibilityCriteria(
        minCgpa: 6.0,
        maxBacklogs: 0,
        eligibleBranches: ['CSE', 'CSBS'],
      ),
      rounds: [
        DriveRound(title: 'Resume Shortlisting', dateStr: '16th Aug 2026', timeStr: '11:00 PM', isCompleted: true),
        DriveRound(title: 'Online Coding Assessment (DSA + Dart)', dateStr: '19th Aug 2026', timeStr: '7:00 PM', isCompleted: false),
        DriveRound(title: 'Technical Interview (Flutter Core & UI Architecture)', dateStr: '22nd Aug 2026', timeStr: '11:00 AM', isCompleted: false),
        DriveRound(title: 'Culture Fit & Offer Discussion', dateStr: '25th Aug 2026', timeStr: '4:00 PM', isCompleted: false),
      ],
      prepTasks: [
        PrepTask(id: 'c1', title: 'Complete CRED Glassmorphism & Custom Canvas Project', isCompleted: true),
        PrepTask(id: 'c2', title: 'Master CustomPainter radial gauge & smooth 60fps animations', isCompleted: true),
        PrepTask(id: 'c3', title: 'Revise Isolates, Event Loop & Dart Asynchronous programming', isCompleted: false),
        PrepTask(id: 'c4', title: 'Prepare System Share Intent & Regex Parser demo explanation', isCompleted: false),
      ],
      rawEmails: [
        '''[MEC2K27] CRED Internship Drive
From: Diya Martin <diyamartin.mec@gmail.com>
To: csapc2k27@googlegroups.com, csbspc2k27@googlegroups.com

CRED is interested in offering an internship for the 2027 batch of MEC. Please find the details below:

• Post: Flutter Intern
• Pay: Rs. 75,000 per month
• Criteria: 6 CGPA and no active backlogs
• Duration: 6 months
• Eligible Branches: CSE/ CSBS
• Location: Bangalore

NB: The students are eligible to be a part of only a single internship that is provided by the Placement Cell.
All eligible and interested students are requested to fill the form before 11:00 PM on 16th August, 2026.'''
      ],
    ),
    PlacementDrive(
      id: 'openmynz-2026',
      companyName: 'Openmynz Softlabs',
      postTitle: 'Full Stack & C++ Intern',
      payStipend: 'Rs. 25,000 - Rs. 45,000 per month',
      ctcPpo: '12 LPA (PPO)',
      location: 'Bangalore (Onsite)',
      formDeadline: DateTime(2026, 7, 30, 23, 0),
      duration: '6 months / 1 year',
      driveSlot: 'Slot B2 / Core Tech',
      stage: DriveStage.applied,
      eligibility: EligibilityCriteria(
        minCgpa: 8.5,
        maxBacklogs: 0,
        eligibleBranches: ['CSE', 'CSBS', 'EC'],
      ),
      rounds: [
        DriveRound(title: 'Resume Shortlisting', dateStr: '30th July 2026', timeStr: '11:00 PM', isCompleted: true),
        DriveRound(title: 'C/C++ & OS Technical Quiz', dateStr: '5th August 2026', timeStr: '2:00 PM', isCompleted: true),
        DriveRound(title: 'System Design & Code Pairing Interview', dateStr: '12th August 2026', timeStr: '10:00 AM', isCompleted: false),
      ],
      prepTasks: [
        PrepTask(id: 'o1', title: 'Revise C++ Pointers, Memory Management & OS Scheduling', isCompleted: true),
        PrepTask(id: 'o2', title: 'Practice Trees & Graph Algorithms on LeetCode', isCompleted: false),
      ],
      rawEmails: [
        '''[MEC2K27] Openmynz Solutions Internship Drive
From: Diya Martin <diyamartin.mec@gmail.com>

Please note that there has been a revision to the requirements for Openmynz Softlabs.
• Post: Intern
• Pay: Rs. 25,000 - Rs 45,000 per month (depending on performance)
• Criteria: 8.5 CGPA and no active backlogs
• Preferred Skill Set: Strong knowledge of C/C++, OS and Data Structures
• Location: Bangalore (Onsite)

Students are required to register through the form before 11:00 PM on 30th July, 2026.'''
      ],
    ),
    PlacementDrive(
      id: 'litmus7-2026',
      companyName: 'Litmus7 Systems Consulting',
      postTitle: 'Retail Tech Intern',
      payStipend: 'Rs. 10,000 per month',
      ctcPpo: '8 LPA (PPO)',
      location: 'Kochi (Smart City)',
      formDeadline: DateTime(2026, 4, 23, 23, 0),
      duration: '6 Months',
      driveSlot: 'Slot B2 / Campus Drive',
      stage: DriveStage.discovered,
      eligibility: EligibilityCriteria(
        minCgpa: 6.5,
        maxBacklogs: 1,
        eligibleBranches: ['CSE', 'CSBS', 'ECE', 'EV', 'EEE', 'EB'],
      ),
      rounds: [
        DriveRound(title: 'Pre-Placement Talk', dateStr: '24th April 2026', timeStr: '2:00 PM', isCompleted: true),
        DriveRound(title: 'Online Aptitude & Coding Test', dateStr: '15th July 2026', timeStr: '2:00 PM', isCompleted: true),
        DriveRound(title: 'In-person Interview at Litmus7 Campus', dateStr: '31st July 2026', timeStr: '9:30 AM', isCompleted: true),
      ],
      prepTasks: [
        PrepTask(id: 'l1', title: 'Review Retail E-commerce Architecture Basics', isCompleted: true),
      ],
      rawEmails: [
        '''[MEC2K27] Litmus7 Systems Consulting Internship Drive
From: Krishnaprasad S <krishnaprasads.mec@gmail.com>

Litmus7 Systems Consulting is interested in offering an internship for the 2027 batch of MEC.
• Post: Intern
• Pay: Rs. 10,000
• Criteria: 6.5 CGPA
• Duration: 6 months
• Eligible Branches: CSE/ CSBS/ ECE/ EV/ EEE/ EB
• Location: Kochi'''
      ],
    ),
  ];
}
