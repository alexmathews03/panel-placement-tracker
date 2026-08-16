# Panel

Panel is a cross-platform campus placement and recruitment tracking application built with Flutter. It enables students to import placement drive details from emails, track eligibility, monitor multi-stage interview progress, and stay on top of upcoming deadlines — all from a single interface.

---

## Description

Managing campus placements is tedious. Students receive placement notices over email with scattered details about roles, stipends, eligibility criteria, and deadlines. Panel solves this by letting students import that information, automatically extracting structured data from the email content, and organizing it into an intuitive dashboard to track every stage of the interview process.

---

## Features

- **Drive Import from Email**: Paste placement email content and Panel extracts company name, role, stipend, CGPA requirements, eligible branches, and form deadlines automatically.
- **Eligibility Verification**: Real-time check against the student's CGPA, active backlogs, and engineering branch to determine whether they qualify for a drive.
- **Selection Round Tracker**: Add and manage multi-stage interview rounds per drive, with date, time, and completion status for each stage.
- **Deadline Calendar**: Monthly calendar view showing all drives with upcoming deadlines, with a full agenda view for any selected date.
- **Drive Pinning**: Pin important drives to the top of the dashboard for quick access.
- **Upcoming Deadlines Panel**: At-a-glance list of drives with the nearest form submission deadlines.
- **Student Profile**: Set your CGPA, backlogs, and branch once and Panel uses it across all eligibility checks.
- **Offline Storage**: All data is stored locally on device with no account or internet connection required.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| Local Storage | SharedPreferences |
| Notifications | flutter_local_notifications |
| PDF Parsing | Syncfusion Flutter PDF |
| UI Design System | Material 3 (Dark Theme) |
| Platforms | Android, Web, Windows |

---

## Project Structure

```
lib/
  core/
    models/          # Drive and profile data models
    parser/          # Email parsing engine
    theme/           # App colors and theme configuration
  features/
    dashboard/       # Main dashboard, calendar view, drive cards
    drive_detail/    # Full drive detail screen with round tracker
    import_modal/    # Email import and drive preview modal
    profile/         # Student profile screen
  services/
    storage_service.dart      # Local persistence layer
    notification_service.dart # Deadline notification scheduling
```

---

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or above)
- Dart SDK

### Run Locally

```bash
flutter pub get
flutter run
```

### Run Tests

```bash
flutter test
```
