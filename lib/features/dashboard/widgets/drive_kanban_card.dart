import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/drive_model.dart';
import '../../../core/models/student_profile.dart';

class DriveKanbanCard extends StatelessWidget {
  final PlacementDrive drive;
  final StudentProfile profile;
  final VoidCallback onTap;
  final Function(DriveStage) onStageChanged;

  const DriveKanbanCard({
    Key? key,
    required this.drive,
    required this.profile,
    required this.onTap,
    required this.onStageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEligible = drive.checkEligibility(profile.cgpa, profile.activeBacklogs, profile.branch);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEligible ? const Color(0xFF2E3446) : Colors.redAccent.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Company & Eligibility Pill
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Initial Avatar Container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: _getCompanyGradient(drive.companyName),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _getCompanyColor(drive.companyName).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          drive.companyName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            drive.companyName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            drive.postTitle,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Eligibility Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isEligible
                            ? AppColors.cyberTeal.withOpacity(0.15)
                            : Colors.redAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isEligible
                              ? AppColors.cyberTeal.withOpacity(0.4)
                              : Colors.redAccent.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isEligible ? Icons.check_circle : Icons.cancel,
                            size: 12,
                            color: isEligible ? AppColors.cyberTeal : Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isEligible ? 'Eligible' : 'Not Eligible',
                            style: TextStyle(
                              color: isEligible ? AppColors.cyberTeal : Colors.redAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Pay / Stipend Badge & Location
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: AppColors.pinkGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        drive.payStipend,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (drive.ctcPpo != 'N/A')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.electricGold.withOpacity(0.5)),
                        ),
                        child: Text(
                          drive.ctcPpo,
                          style: const TextStyle(
                            color: AppColors.electricGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            drive.location,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                const Divider(color: Color(0xFF222634), height: 1),
                const SizedBox(height: 12),

                // Bottom Row: Pipeline Selector & Checklist progress
                Row(
                  children: [
                    // Round Progress Chip
                    const Icon(Icons.checklist_rtl_rounded, size: 16, color: AppColors.cyberTeal),
                    const SizedBox(width: 6),
                    Text(
                      '${drive.prepTasks.where((t) => t.isCompleted).length}/${drive.prepTasks.length} Prep Tasks',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    // Stage Action Dropdown Menu
                    PopupMenuButton<DriveStage>(
                      initialValue: drive.stage,
                      color: AppColors.surfaceCardLight,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: onStageChanged,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStageColor(drive.stage).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _getStageColor(drive.stage)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              drive.stage.label,
                              style: TextStyle(
                                color: _getStageColor(drive.stage),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down, color: _getStageColor(drive.stage), size: 16),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => DriveStage.values
                          .map(
                            (stg) => PopupMenuItem<DriveStage>(
                              value: stg,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 4,
                                    backgroundColor: _getStageColor(stg),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    stg.label,
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStageColor(DriveStage stage) {
    switch (stage) {
      case DriveStage.discovered:
        return AppColors.statusDiscovered;
      case DriveStage.applied:
        return AppColors.statusApplied;
      case DriveStage.shortlisted:
        return AppColors.statusShortlisted;
      case DriveStage.interview:
        return AppColors.statusInterview;
      case DriveStage.offer:
        return AppColors.statusOffer;
      case DriveStage.rejected:
        return AppColors.textMuted;
    }
  }

  Color _getCompanyColor(String name) {
    if (name.toUpperCase().contains('CRED')) return AppColors.credPink;
    if (name.toUpperCase().contains('OPENMYNZ')) return AppColors.cyberTeal;
    if (name.toUpperCase().contains('LITMUS7')) return AppColors.neonPurple;
    return AppColors.vividBlue;
  }

  LinearGradient _getCompanyGradient(String name) {
    if (name.toUpperCase().contains('CRED')) {
      return AppColors.pinkGradient;
    }
    if (name.toUpperCase().contains('OPENMYNZ')) {
      return AppColors.tealGradient;
    }
    return const LinearGradient(
      colors: [Color(0xFF7B2CBF), Color(0xFF9D4EDD)],
    );
  }
}
