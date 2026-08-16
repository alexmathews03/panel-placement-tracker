import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/drive_model.dart';

class StitchDriveCard extends StatelessWidget {
  final PlacementDrive drive;
  final VoidCallback onTap;
  final VoidCallback? onPinToggle;

  const StitchDriveCard({
    super.key,
    required this.drive,
    required this.onTap,
    this.onPinToggle,
  });

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(drive.stage);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onPinToggle,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.cyanAccent.withOpacity(0.08),
          highlightColor: Colors.white.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row: Company Title + Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Company Info
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                drive.companyName.isNotEmpty
                                    ? drive.companyName.substring(0, 1).toUpperCase()
                                    : 'D',
                                style: TextStyle(
                                  color: statusConfig.color,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  drive.companyName,
                                  style: const TextStyle(
                                    color: AppColors.onSurface,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  drive.postTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Pin & Stage Pill
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onPinToggle != null)
                            InkWell(
                              onTap: onPinToggle,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: drive.isPinned ? AppColors.cyanAccent.withOpacity(0.18) : Colors.white.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: drive.isPinned ? AppColors.cyanAccent.withOpacity(0.4) : Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Icon(
                                  drive.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                  size: 20,
                                  color: drive.isPinned ? AppColors.cyanAccent : Colors.white60,
                                ),
                              ),
                            ),
                          // Stage Pill
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusConfig.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: statusConfig.color.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: statusConfig.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      drive.stage.label.toUpperCase(),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: statusConfig.color,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bottom Row Divider & Subtitle Details
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 13,
                              color: AppColors.onSurfaceVariant.withOpacity(0.8),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                _getNextStepText(drive),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getNextStepText(PlacementDrive drive) {
    final pendingRounds = drive.rounds.where((r) => !r.isCompleted).toList();
    if (pendingRounds.isNotEmpty) {
      final round = pendingRounds.first;
      return '${round.title} (${round.dateStr})';
    }
    return 'Deadline: ${drive.formDeadline.day}/${drive.formDeadline.month}/${drive.formDeadline.year}';
  }

  _StatusConfig _getStatusConfig(DriveStage stage) {
    switch (stage) {
      case DriveStage.discovered:
        return _StatusConfig(AppColors.statusDiscovered, 'Discovered');
      case DriveStage.applied:
        return _StatusConfig(AppColors.statusApplied, 'Applied');
      case DriveStage.shortlisted:
        return _StatusConfig(AppColors.cyanAccent, 'Shortlisted');
      case DriveStage.interview:
        return _StatusConfig(AppColors.neonPurple, 'Interview');
      case DriveStage.offer:
        return _StatusConfig(AppColors.credPink, 'Offer Recvd');
      case DriveStage.rejected:
        return _StatusConfig(AppColors.textMuted, 'Not Selected');
    }
  }
}

class _StatusConfig {
  final Color color;
  final String label;
  const _StatusConfig(this.color, this.label);
}
