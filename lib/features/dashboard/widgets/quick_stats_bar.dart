import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/drive_model.dart';

class QuickStatsBar extends StatelessWidget {
  final List<PlacementDrive> drives;

  const QuickStatsBar({Key? key, required this.drives}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int total = drives.length;
    int applied = drives.where((d) => d.stage != DriveStage.discovered).length;
    int shortlisted = drives.where((d) => d.stage == DriveStage.shortlisted || d.stage == DriveStage.interview || d.stage == DriveStage.offer).length;
    int offers = drives.where((d) => d.stage == DriveStage.offer).length;

    return Row(
      children: [
        _buildStatItem('Total', total.toString(), Icons.folder_open, AppColors.vividBlue),
        const SizedBox(width: 10),
        _buildStatItem('Applied', applied.toString(), Icons.send_rounded, AppColors.electricGold),
        const SizedBox(width: 10),
        _buildStatItem('Shortlist', shortlisted.toString(), Icons.verified_user_rounded, AppColors.cyberTeal),
        const SizedBox(width: 10),
        _buildStatItem('Offers', offers.toString(), Icons.workspace_premium, AppColors.credPink),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF252A38)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
