import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/drive_model.dart';
import '../core/models/student_profile.dart';
import 'sample_data.dart';

class StorageService {
  static const String _drivesKey = 'panel_drives_v1';
  static const String _profileKey = 'panel_profile_v1';

  static Future<List<PlacementDrive>> loadDrives() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_drivesKey);
      if (jsonStr == null || jsonStr.isEmpty) {
        // Save initial sample data first time
        await saveDrives(SampleData.initialDrives);
        return SampleData.initialDrives;
      }
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((item) => PlacementDrive.fromJson(item)).toList();
    } catch (e) {
      return SampleData.initialDrives;
    }
  }

  static Future<void> saveDrives(List<PlacementDrive> drives) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonStr = jsonEncode(drives.map((d) => d.toJson()).toList());
    await prefs.setString(_drivesKey, jsonStr);
  }

  static Future<void> deleteDrive(String id) async {
    final drives = await loadDrives();
    drives.removeWhere((d) => d.id == id);
    await saveDrives(drives);
  }

  static Future<void> updateDrive(PlacementDrive updatedDrive) async {
    final drives = await loadDrives();
    final idx = drives.indexWhere((d) => d.id == updatedDrive.id);
    if (idx != -1) {
      drives[idx] = updatedDrive;
      await saveDrives(drives);
    }
  }

  static Future<StudentProfile> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_profileKey);
      if (jsonStr == null || jsonStr.isEmpty) {
        return SampleData.defaultUser;
      }
      return StudentProfile.fromJson(jsonDecode(jsonStr));
    } catch (e) {
      return SampleData.defaultUser;
    }
  }

  static Future<void> saveProfile(StudentProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }
}
