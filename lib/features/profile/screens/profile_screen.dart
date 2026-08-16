import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/student_profile.dart';
import '../../../core/models/drive_model.dart';
import '../../../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  final StudentProfile profile;
  final List<PlacementDrive> drives;
  final Function(StudentProfile) onProfileSaved;

  const ProfileScreen({
    super.key,
    required this.profile,
    required this.drives,
    required this.onProfileSaved,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _cgpaController;
  late TextEditingController _roleController;
  late String _selectedBranch;
  late int _backlogs;

  static const Map<String, String> branchFullNames = {
    'CSE': 'Computer Science & Engineering',
    'CSBS': 'Computer Science & Business Systems',
    'EEE': 'Electrical & Electronics Engineering',
    'EV': 'Electric Vehicles Engineering',
    'ECE': 'Electronics & Communication Engineering',
    'EBE': 'Electronics & Biomedical Engineering',
    'ME': 'Mechanical Engineering',
  };

  final List<String> _branchOptions = [
    'CSE', 'CSBS', 'EEE', 'EV', 'ECE', 'EBE', 'ME'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _cgpaController = TextEditingController(
        text: widget.profile.cgpa > 0 ? widget.profile.cgpa.toString() : '');
    _roleController = TextEditingController(text: widget.profile.targetRole);
    final norm = PlacementDrive.normalizeBranch(widget.profile.branch);
    _selectedBranch = _branchOptions.contains(norm)
        ? norm
        : (_branchOptions.contains(widget.profile.branch)
            ? widget.profile.branch
            : 'CSE');
    _backlogs = widget.profile.activeBacklogs;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cgpaController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  int get _eligibleDriveCount {
    final double cgpa =
        double.tryParse(_cgpaController.text.trim()) ?? widget.profile.cgpa;
    return widget.drives
        .where((d) => d.checkEligibility(cgpa, _backlogs, _selectedBranch))
        .length;
  }

  Future<void> _saveProfile() async {
    final trimmedName = _nameController.text.trim();
    if (trimmedName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name.'),
          backgroundColor: AppColors.urgentRed,
        ),
      );
      return;
    }

    final double cgpa = double.tryParse(_cgpaController.text.trim()) ?? 0.0;
    final updatedProfile = StudentProfile(
      name: trimmedName,
      branch: _selectedBranch,
      cgpa: cgpa.clamp(0.0, 10.0),
      activeBacklogs: _backlogs,
      targetRole: _roleController.text.trim().isNotEmpty
          ? _roleController.text.trim()
          : 'Software Engineer',
    );

    await StorageService.saveProfile(updatedProfile);
    widget.onProfileSaved(updatedProfile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: AppColors.cyanAccent,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eligibleCount = _eligibleDriveCount;
    final totalCount = widget.drives.length;
    final hasName = _nameController.text.trim().isNotEmpty;
    final displayName = hasName ? _nameController.text.trim() : 'Your Name';
    final displayCgpa = _cgpaController.text.trim().isNotEmpty
        ? '${_cgpaController.text.trim()} CGPA'
        : 'Set CGPA';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Student Profile & Eligibility',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.cyanAccent,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.cyanAccent.withOpacity(0.4),
                          width: 2),
                    ),
                    child: Center(
                      child: hasName
                          ? Text(
                              _nameController.text.trim()[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.cyanAccent,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Icon(Icons.person_outline,
                              color: AppColors.cyanAccent, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            color: hasName ? AppColors.onSurface : AppColors.onSurfaceVariant,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$_selectedBranch • $displayCgpa',
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Live Eligibility Indicator Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.cyanAccent.withOpacity(0.25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cyanAccent.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified, color: AppColors.cyanAccent, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live Eligibility Match',
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'You currently qualify for $eligibleCount of $totalCount placement drives',
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Form Input Fields
            const Text(
              'PERSONAL & ACADEMIC CRITERIA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            // Full Name
            _buildLabel('Full Name'),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
              decoration: _inputDecoration('e.g. Alex Mathews', Icons.person_outline),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Branch Selection Dropdown
            _buildLabel('Engineering Branch'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBranch,
                  isExpanded: true,
                  dropdownColor: AppColors.surfaceCard,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.cyanAccent),
                  style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                  borderRadius: BorderRadius.circular(12),
                  items: _branchOptions.map((branch) {
                    final fullName = branchFullNames[branch] ?? branch;
                    return DropdownMenuItem<String>(
                      value: branch,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.cyanAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              branch,
                              style: const TextStyle(
                                color: AppColors.cyanAccent,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              fullName,
                              style: const TextStyle(
                                color: AppColors.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedBranch = val;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cumulative CGPA
            _buildLabel('Current CGPA (out of 10.0)'),
            TextField(
              controller: _cgpaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
              decoration: _inputDecoration('e.g. 8.72', Icons.grade_outlined),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Active Backlogs Stepper
            _buildLabel('Active Standing Backlogs'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_backlogs Backlogs',
                    style: TextStyle(
                      color: _backlogs == 0 ? AppColors.cyanAccent : AppColors.urgentRed,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.onSurfaceVariant),
                        onPressed: _backlogs > 0 ? () => setState(() => _backlogs--) : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.cyanAccent),
                        onPressed: () => setState(() => _backlogs++),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Target Role
            _buildLabel('Target Role / Career Goal'),
            TextField(
              controller: _roleController,
              style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
              decoration: _inputDecoration('e.g. Flutter / Mobile Engineer', Icons.work_outline),
            ),
            const SizedBox(height: 32),

            // Confirm & Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F6FA),
                  foregroundColor: const Color(0xFF0D0E15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text(
                  'SAVE PROFILE & CRITERIA',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.cyanAccent, size: 18),
      filled: true,
      fillColor: AppColors.surfaceCard,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cyanAccent),
      ),
    );
  }
}
