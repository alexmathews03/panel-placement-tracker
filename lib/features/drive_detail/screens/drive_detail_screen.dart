import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/drive_model.dart';
import '../../../core/models/student_profile.dart';
import '../../../services/notification_service.dart';
import '../../../services/storage_service.dart';

class DriveDetailScreen extends StatefulWidget {
  final PlacementDrive drive;
  final StudentProfile profile;
  final Function(PlacementDrive) onDriveUpdated;

  const DriveDetailScreen({
    super.key,
    required this.drive,
    required this.profile,
    required this.onDriveUpdated,
  });

  @override
  State<DriveDetailScreen> createState() => _DriveDetailScreenState();
}

class _DriveDetailScreenState extends State<DriveDetailScreen> {
  late PlacementDrive _drive;
  final TextEditingController _taskTextController = TextEditingController();
  bool _showRawEmail = false;

  @override
  void initState() {
    super.initState();
    _drive = widget.drive;
  }

  @override
  void dispose() {
    _taskTextController.dispose();
    super.dispose();
  }

  void _notifyUpdate() async {
    setState(() {});
    await StorageService.updateDrive(_drive);
    widget.onDriveUpdated(_drive);
  }

  void _togglePin() {
    setState(() {
      _drive.isPinned = !_drive.isPinned;
    });
    _notifyUpdate();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_drive.isPinned
            ? '📌 Pinned ${_drive.companyName} to Dashboard'
            : 'Unpinned ${_drive.companyName} from Dashboard'),
        backgroundColor: AppColors.surfaceCardLight,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openRoundSheet({int? editIdx}) async {
    final bool isEditing = editIdx != null;
    final DriveRound? existing = isEditing ? _drive.rounds[editIdx] : null;

    final titleController = TextEditingController(text: existing?.title ?? '');
    String dateStr = existing?.dateStr ?? 'TBD';
    String timeStr = existing?.timeStr ?? 'TBD';
    bool isCompleted = existing?.isCompleted ?? false;

    final presetRounds = [
      'Online Assessment (OA)',
      'Technical Interview 1',
      'Technical Interview 2',
      'Coding & DSA Round',
      'System Design',
      'HR & Culture Fit',
      'Managerial Round',
      'Pre-Placement Talk',
      'Group Discussion',
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle & Title
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.timeline, color: AppColors.cyanAccent, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              isEditing ? 'Edit Selection Round' : 'Add Selection Round',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        if (isEditing)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.urgentRed, size: 20),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _confirmDeleteRound(editIdx);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Quick Preset Chips
                    const Text(
                      'QUICK TEMPLATES',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: presetRounds.map((preset) {
                        final isSel = titleController.text.trim() == preset;
                        return ChoiceChip(
                          label: Text(preset),
                          selected: isSel,
                          selectedColor: AppColors.cyanAccent,
                          backgroundColor: AppColors.surfaceContainer,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.black : AppColors.onSurface,
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          ),
                          side: BorderSide(
                            color: isSel ? AppColors.cyanAccent : Colors.white.withOpacity(0.08),
                          ),
                          onSelected: (_) {
                            setSheetState(() {
                              titleController.text = preset;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Round Title Field
                    const Text(
                      'ROUND TITLE',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'e.g. Technical Round 1 (Data Structures & Flutter)',
                        hintStyle: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.surfaceContainer,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.cyanAccent),
                        ),
                      ),
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: 14),

                    // Date & Time Selectors Row
                    Row(
                      children: [
                        // Date Picker Button
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DATE',
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.dark(
                                            primary: AppColors.cyanAccent,
                                            onPrimary: Colors.black,
                                            surface: Color(0xFF1E2230),
                                            onSurface: Colors.white,
                                            surfaceContainerHighest: Color(0xFF2E374D),
                                            onSurfaceVariant: Colors.white70,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                    setSheetState(() {
                                      dateStr = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
                                    });
                                  }
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainer,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 14, color: AppColors.cyanAccent),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          dateStr,
                                          style: const TextStyle(color: Colors.white, fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Time Picker Button
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TIME',
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.dark(
                                            primary: AppColors.cyanAccent,
                                            onPrimary: Colors.black,
                                            surface: Color(0xFF1E2230),
                                            onSurface: Colors.white,
                                            surfaceContainerHighest: Color(0xFF2E374D),
                                            onSurfaceVariant: Colors.white70,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setSheetState(() {
                                      timeStr = picked.format(context);
                                    });
                                  }
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainer,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: AppColors.cyanAccent),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          timeStr,
                                          style: const TextStyle(color: Colors.white, fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
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
                    const SizedBox(height: 14),

                    // Completed Toggle
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Round Completed', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Mark this stage as cleared/done', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                      value: isCompleted,
                      activeColor: AppColors.cyanAccent,
                      onChanged: (v) => setSheetState(() => isCompleted = v),
                    ),
                    const SizedBox(height: 16),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          final title = titleController.text.trim();
                          if (title.isEmpty) return;

                          final newRound = DriveRound(
                            title: title,
                            dateStr: dateStr,
                            timeStr: timeStr,
                            isCompleted: isCompleted,
                          );

                          if (isEditing) {
                            _drive.rounds[editIdx] = newRound;
                          } else {
                            _drive.rounds.add(newRound);
                          }
                          _notifyUpdate();
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          isEditing ? 'UPDATE SELECTION ROUND' : 'ADD SELECTION ROUND',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteRound(int idx) async {
    final round = _drive.rounds[idx];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Delete Round?', style: TextStyle(color: Colors.white)),
        content: Text('Remove "${round.title}" from the selection process?', style: const TextStyle(color: AppColors.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE', style: TextStyle(color: AppColors.urgentRed)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _drive.rounds.removeAt(idx);
      _notifyUpdate();
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Delete Drive?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this placement drive? This cannot be undone.', style: TextStyle(color: AppColors.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: AppColors.urgentRed)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.deleteDrive(_drive.id);
      widget.onDriveUpdated(_drive); // We just trigger an update so dashboard reloads from storage
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEligible = _drive.checkEligibility(
      widget.profile.cgpa,
      widget.profile.activeBacklogs,
      widget.profile.branch,
    );

    final completedTasks = _drive.prepTasks.where((t) => t.isCompleted).length;
    final totalTasks = _drive.prepTasks.length;

    final completedRounds = _drive.rounds.where((r) => r.isCompleted).length;
    final totalRounds = _drive.rounds.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Drive Details & Prep',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          // Pin Action Button
          IconButton(
            icon: Icon(
              _drive.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _drive.isPinned ? AppColors.cyanAccent : Colors.white,
              size: 22,
            ),
            tooltip: _drive.isPinned ? 'Unpin from Top' : 'Pin to Top of Dashboard',
            onPressed: _togglePin,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.urgentRed),
            tooltip: 'Delete Drive',
            onPressed: () => _confirmDelete(context),
          ),
          // Stage Selector Button
          PopupMenuButton<DriveStage>(
            initialValue: _drive.stage,
            color: AppColors.surfaceCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (stg) {
              _drive.stage = stg;
              _notifyUpdate();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _getStageColor(_drive.stage),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _drive.stage.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                ],
              ),
            ),
            itemBuilder: (context) => DriveStage.values
                .map(
                  (s) => PopupMenuItem(
                    value: s,
                    child: Row(
                      children: [
                        CircleAvatar(radius: 4, backgroundColor: _getStageColor(s)),
                        const SizedBox(width: 8),
                        Text(s.label, style: const TextStyle(color: AppColors.onSurface, fontSize: 13)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Company Banner Card
            _buildCompanyHeroCard(),
            const SizedBox(height: 16),

            // 2. Student Eligibility Check Card
            _buildEligibilityCard(isEligible),
            const SizedBox(height: 20),

            // 3. Selection Rounds Timeline
            _buildSelectionRoundsTimeline(completedRounds, totalRounds),
            const SizedBox(height: 20),

            // 4. Job Description Section (Stitch Update)
            _buildJobDescriptionSection(),
            const SizedBox(height: 20),

            // 5. Preparation Checklist
            _buildPreparationChecklist(completedTasks, totalTasks),
            const SizedBox(height: 20),

            // 6. Original Placement Notice
            if (_drive.rawEmails.isNotEmpty) _buildRawEmailSection(),
          ],
        ),
      ),
    );
  }

  // 1. Company Info Hero Panel
  Widget _buildCompanyHeroCard() {
    final payString = _drive.ctcPpo != 'N/A' && _drive.ctcPpo.isNotEmpty
        ? _drive.ctcPpo
        : _drive.payStipend;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Watermark Apartment Icon
            Positioned(
              right: -20,
              top: -20,
              child: Opacity(
                opacity: 0.04,
                child: const Icon(
                  Icons.apartment,
                  size: 160,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _drive.companyName,
                          style: const TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                _drive.stage.label,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _drive.postTitle,
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Metadata Chips Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMetaChip(Icons.location_on_outlined, _drive.location),
                      _buildMetaChip(Icons.payments_outlined, payString),
                      _buildMetaChip(Icons.work_outline, _drive.driveSlot),
                      GestureDetector(
                        onTap: _showReminderDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white.withOpacity(0.20)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.notifications_active_outlined, size: 13, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'Set Reminder',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderDialog() {
    // formDeadline is already a DateTime
    final DateTime deadline = _drive.formDeadline;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.alarm, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text(
                  'Set Drive & Test Reminder',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Receive notifications before ${_drive.companyName} deadline & selection rounds',
              style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 20),

            _buildReminderOption(
              label: '1 Hour Before Deadline',
              subtitle: 'Best for quick form submission',
              minutesBefore: 60,
              targetDate: deadline,
              notifId: _drive.id.hashCode + 1,
            ),
            _buildReminderOption(
              label: '6 Hours Before Deadline',
              subtitle: 'Review resume & submission form',
              minutesBefore: 360,
              targetDate: deadline,
              notifId: _drive.id.hashCode + 2,
            ),
            _buildReminderOption(
              label: '1 Day Before Assessment',
              subtitle: 'Full revision & coding practice',
              minutesBefore: 1440,
              targetDate: deadline,
              notifId: _drive.id.hashCode + 3,
            ),
            _buildReminderOption(
              label: 'Morning of Deadline (9:00 AM)',
              subtitle: 'Setup & final system check',
              minutesBefore: null,
              targetDate: DateTime(deadline.year, deadline.month, deadline.day, 9, 0),
              notifId: _drive.id.hashCode + 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderOption({
    required String label,
    required String subtitle,
    required int? minutesBefore,
    required DateTime targetDate,
    required int notifId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: ListTile(
        leading: const Icon(Icons.notifications_none, color: Colors.white),
        title: Text(label, style: const TextStyle(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant, size: 18),
        onTap: () async {
          Navigator.pop(context);

          if (minutesBefore != null) {
            await NotificationService.scheduleReminder(
              id: notifId,
              companyName: _drive.companyName,
              label: label,
              targetDate: targetDate,
              minutesBefore: minutesBefore,
            );
          } else {
            // Morning of deadline: targetDate IS the 9 AM date
            await NotificationService.scheduleReminder(
              id: notifId,
              companyName: _drive.companyName,
              label: label,
              targetDate: targetDate.add(const Duration(hours: 1)),
              minutesBefore: 60,
            );
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Reminder set: $label for ${_drive.companyName}'),
                backgroundColor: AppColors.surfaceCardLight,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Student Criteria Breakdown Card
  Widget _buildEligibilityCard(bool isEligible) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(isEligible ? 0.15 : 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isEligible ? Icons.verified_rounded : Icons.warning_amber_rounded,
                color: isEligible ? Colors.white : AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isEligible ? 'You Meet Placement Eligibility' : 'Eligibility Notice',
                style: TextStyle(
                  color: isEligible ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCritRow('CGPA Requirement', '${_drive.eligibility.minCgpa} Min', '${widget.profile.cgpa} (Yours)', widget.profile.cgpa >= _drive.eligibility.minCgpa),
          _buildCritRow('Active Backlogs', '${_drive.eligibility.maxBacklogs} Max', '${widget.profile.activeBacklogs} (Yours)', widget.profile.activeBacklogs <= _drive.eligibility.maxBacklogs),
          _buildCritRow('Eligible Branches', _drive.eligibility.eligibleBranches.join(', '), '${widget.profile.branch} (Yours)', isEligible),
        ],
      ),
    );
  }

  Widget _buildCritRow(String title, String req, String user, bool pass) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Row(
            children: [
              Flexible(
                child: Text(
                  req,
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Text(' | ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              Flexible(
                child: Text(
                  user,
                  style: TextStyle(
                    color: pass ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                pass ? Icons.check_circle_outline : Icons.cancel_outlined,
                size: 14,
                color: pass ? Colors.white.withOpacity(0.7) : AppColors.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Selection Rounds Timeline
  Widget _buildSelectionRoundsTimeline(int completedRounds, int totalRounds) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.timeline, color: AppColors.cyanAccent, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Selection Rounds',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$completedRounds/$totalRounds Cleared',
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _openRoundSheet(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.cyanAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cyanAccent.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: AppColors.cyanAccent),
                      SizedBox(width: 4),
                      Text('Add Round', style: TextStyle(color: AppColors.cyanAccent, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Timeline Items
          if (_drive.rounds.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No selection rounds added yet.\nTap "Add Round" to schedule interview stages.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _drive.rounds.length,
              itemBuilder: (context, idx) {
                final round = _drive.rounds[idx];
                final isLast = idx == _drive.rounds.length - 1;
                final isNextActive = !round.isCompleted &&
                    (idx == 0 || _drive.rounds[idx - 1].isCompleted);

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline Indicator Column
                      Column(
                        children: [
                          _buildTimelineCircle(round, isNextActive),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: Colors.white.withOpacity(0.1),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Round Details Column
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: InkWell(
                            onTap: () {
                              _drive.rounds[idx] = DriveRound(
                                title: round.title,
                                dateStr: round.dateStr,
                                timeStr: round.timeStr,
                                platform: round.platform,
                                isCompleted: !round.isCompleted,
                              );
                              _notifyUpdate();
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            round.title,
                                            style: TextStyle(
                                              color: round.isCompleted
                                                  ? AppColors.onSurface
                                                  : isNextActive
                                                      ? Colors.white
                                                      : AppColors.onSurfaceVariant,
                                              fontSize: 15,
                                              fontWeight: isNextActive || round.isCompleted
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            round.isCompleted
                                                ? 'Completed • ${round.dateStr}'
                                                : '${round.dateStr} • ${round.timeStr}',
                                            style: const TextStyle(
                                              color: AppColors.onSurfaceVariant,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Action buttons: Edit & Delete
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                      icon: const Icon(Icons.edit_outlined, color: Colors.white60, size: 16),
                                      tooltip: 'Edit Round',
                                      onPressed: () => _openRoundSheet(editIdx: idx),
                                    ),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                      icon: Icon(Icons.delete_outline, color: Colors.white.withOpacity(0.35), size: 16),
                                      tooltip: 'Delete Round',
                                      onPressed: () => _confirmDeleteRound(idx),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 8),
          // Large Add Round Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openRoundSheet(),
              icon: const Icon(Icons.add_circle_outline, size: 16, color: AppColors.cyanAccent),
              label: const Text(
                'Add Selection Round',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: AppColors.cyanAccent.withOpacity(0.35)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: AppColors.surfaceContainer.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCircle(DriveRound round, bool isNextActive) {
    if (round.isCompleted) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.check, size: 14, color: Colors.black),
        ),
      );
    }

    if (isNextActive) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outlineVariant, width: 2),
      ),
    );
  }

  Widget _buildTopicTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.cyanAccent,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // 4. Job Description Section (Stitch Update)
  Widget _buildJobDescriptionSection() {
    final techTags = ['Flutter', 'Dart', 'Firebase', 'Git', 'REST APIs', 'SQL'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.description_outlined, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Job Description',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Overview
          const Text(
            'OVERVIEW',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'As a ${_drive.postTitle} at ${_drive.companyName}, you will collaborate with engineering teams to build high-performance mobile and web solutions with seamless user experiences.',
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Key Responsibilities
          const Text(
            'KEY RESPONSIBILITIES',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          _buildResponsibilityBullet('Developing and maintaining scalable software architectures.'),
          _buildResponsibilityBullet('Collaborating with cross-functional teams to define & ship features.'),
          _buildResponsibilityBullet('Optimizing application performance, latency, and code quality.'),
          const SizedBox(height: 16),

          // Tech Stack
          const Text(
            'TECH STACK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: techTags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsibilityBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: AppColors.cyanAccent,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Preparation Checklist
  Widget _buildPreparationChecklist(int completedTasks, int totalTasks) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.task_alt, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Preparation Checklist',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '$completedTasks/$totalTasks Done',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.cyanAccent, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _showAddTaskDialog,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Checklist Items
          ..._drive.prepTasks.map((task) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    task.isCompleted = !task.isCompleted;
                    _notifyUpdate();
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Custom Styled Checkbox
                      Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: task.isCompleted ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: task.isCompleted ? Colors.white : AppColors.outlineVariant,
                            width: 1.5,
                          ),
                        ),
                        child: task.isCompleted
                            ? const Icon(Icons.check, size: 13, color: Colors.black)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            color: task.isCompleted
                                ? AppColors.onSurfaceVariant
                                : AppColors.onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 6. Raw Email Section
  Widget _buildRawEmailSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _showRawEmail,
          onExpansionChanged: (v) => setState(() => _showRawEmail = v),
          title: const Text(
            'Original Placement Notice',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(
                  _drive.rawEmails.first,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                    fontFamily: 'monospace',
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    _taskTextController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Add Preparation Task', style: TextStyle(color: AppColors.onSurface)),
        content: TextField(
          controller: _taskTextController,
          autofocus: true,
          style: const TextStyle(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: 'e.g. Master Riverpod & System Design',
            hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
            filled: true,
            fillColor: AppColors.surfaceContainer,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5F6FA),
              foregroundColor: const Color(0xFF0D0E15),
            ),
            onPressed: () {
              if (_taskTextController.text.trim().isNotEmpty) {
                _drive.prepTasks.add(
                  PrepTask(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _taskTextController.text.trim(),
                  ),
                );
                _notifyUpdate();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
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
        return AppColors.cyanAccent;
      case DriveStage.interview:
        return AppColors.neonPurple;
      case DriveStage.offer:
        return AppColors.credPink;
      case DriveStage.rejected:
        return AppColors.textMuted;
    }
  }
}
