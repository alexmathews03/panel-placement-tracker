import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CountdownGauge extends StatefulWidget {
  final DateTime targetDate;
  final String companyName;
  final String postTitle;

  const CountdownGauge({
    Key? key,
    required this.targetDate,
    required this.companyName,
    this.postTitle = '',
  }) : super(key: key);

  @override
  State<CountdownGauge> createState() => _CountdownGaugeState();
}

class _CountdownGaugeState extends State<CountdownGauge> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = widget.targetDate.difference(now);

    final bool isExpired = difference.isNegative;
    final int hours = difference.inHours.abs();
    final int days = difference.inDays.abs();
    final int minutes = (difference.inMinutes.abs() % 60);

    String timeLabel;
    if (isExpired) {
      timeLabel = 'FORM CLOSED';
    } else if (days > 0) {
      timeLabel = '$days d $hours h left';
    } else {
      timeLabel = '$hours h $minutes m left';
    }

    // Progress value between 0.0 and 1.0 (assuming max deadline period 5 days)
    double progress = isExpired ? 0.0 : math.max(0.1, math.min(1.0, difference.inHours / (5 * 24)));

    final String driveTitleLabel = widget.postTitle.isNotEmpty
        ? '${widget.companyName} — ${widget.postTitle}'
        : widget.companyName;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppColors.surfaceCard,
            border: Border.all(
              color: Colors.white.withOpacity(0.08 + (_animController.value * 0.06)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Custom Radial Canvas Gauge
              SizedBox(
                width: 76,
                height: 76,
                child: CustomPaint(
                  painter: RadialProgressPainter(
                    progress: progress,
                    pulse: _animController.value,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.timer_outlined,
                      color: isExpired ? AppColors.textMuted : AppColors.credPink,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              // Deadline Info Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.credPink.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'NEXT DEADLINE',
                            style: TextStyle(
                              color: AppColors.credPink,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Prominent Drive Name & Role Title
                    Text(
                      driveTitleLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeLabel,
                      style: TextStyle(
                        color: isExpired ? AppColors.textMuted : AppColors.cyberTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Form closes at ${widget.targetDate.hour.toString().padLeft(2, '0')}:${widget.targetDate.minute.toString().padLeft(2, '0')} (${widget.targetDate.day}/${widget.targetDate.month}/${widget.targetDate.year})',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RadialProgressPainter extends CustomPainter {
  final double progress;
  final double pulse;

  RadialProgressPainter({required this.progress, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;

    // Track Paint
    final trackPaint = Paint()
      ..color = const Color(0xFF222634)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Glow Arc Paint
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.08 + (pulse * 0.08))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Active Arc Paint
    final arcPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      glowPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant RadialProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pulse != pulse;
  }
}
