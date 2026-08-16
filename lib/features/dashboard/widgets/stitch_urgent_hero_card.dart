import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/drive_model.dart';

class StitchUrgentHeroCard extends StatefulWidget {
  final PlacementDrive drive;
  final VoidCallback onTap;

  const StitchUrgentHeroCard({
    super.key,
    required this.drive,
    required this.onTap,
  });

  @override
  State<StitchUrgentHeroCard> createState() => _StitchUrgentHeroCardState();
}

class _StitchUrgentHeroCardState extends State<StitchUrgentHeroCard> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemaining());
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final diff = widget.drive.formDeadline.difference(now);
    if (mounted) {
      setState(() {
        _remaining = diff.isNegative ? Duration.zero : diff;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds <= 0) return 'Deadline Ended';
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    if (days > 0) {
      return '${days.toString().padLeft(2, '0')}d ${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m';
    }
    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cyanAccent.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Top Right Cyan Glow Accent
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cyanAccent.withOpacity(0.12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Urgent Tag & Company Initial Logo
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Urgent Pill
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.urgentRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'URGENT',
                                  style: TextStyle(
                                    color: AppColors.urgentRed,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${widget.drive.companyName} Assessment',
                              style: const TextStyle(
                                color: AppColors.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.drive.postTitle,
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Company Square Badge
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.drive.companyName.isNotEmpty
                                ? widget.drive.companyName.substring(0, 1).toUpperCase()
                                : 'D',
                            style: const TextStyle(
                              color: AppColors.cyanAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Countdown Gauge Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Time Remaining',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDuration(_remaining),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                fontFeatures: [FontFeature.tabularFigures()],
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        // Circular Gauge Icon
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: _remaining.inSeconds > 0
                                    ? ((_remaining.inHours % 24) / 24).clamp(0.1, 1.0)
                                    : 0.0,
                                strokeWidth: 3.5,
                                backgroundColor: AppColors.surfaceVariant,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyanAccent),
                              ),
                              const Icon(
                                Icons.timer_outlined,
                                size: 18,
                                color: AppColors.cyanAccent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: widget.onTap,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surfaceVariant,
                        foregroundColor: AppColors.onSurface,
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'View Drive Details & Prep',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
