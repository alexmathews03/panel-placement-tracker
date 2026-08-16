import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const PanelApp());
}

class PanelApp extends StatelessWidget {
  const PanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panel - Placement & Recruitment Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}

// Alias for test backward compatibility
typedef DriveDeckApp = PanelApp;
