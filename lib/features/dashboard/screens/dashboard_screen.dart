import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/drive_model.dart';
import '../../../core/models/student_profile.dart';
import '../../../core/parser/email_parser.dart';
import '../../../services/storage_service.dart';
import '../widgets/stitch_urgent_hero_card.dart';
import '../widgets/stitch_drive_card.dart';
import '../widgets/stitch_calendar_view.dart';
import '../../drive_detail/screens/drive_detail_screen.dart';
import '../../import_modal/widgets/import_drive_modal.dart';
import '../../profile/screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  List<PlacementDrive> _drives = [];
  late StudentProfile _profile;
  bool _isLoading = true;
  int _currentNavIndex = 0;
  
  // Search & Filter State
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  DriveStage? _selectedFilterStage;

  static const _shareChannel = MethodChannel('com.example.drivedeck/share');
  String? _lastCheckedClipboard;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _initShareIntent();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkInitialShare();
    }
  }
  void _initShareIntent() {
    // Listen for text shared while app is running
    _shareChannel.setMethodCallHandler((call) async {
      if (call.method == 'onSharedText') {
        final text = call.arguments as String?;
        if (text != null && text.trim().isNotEmpty && mounted) {
          _showImportModal(initialText: text);
        }
      }
    });

    _checkInitialShare();
  }

  void _checkInitialShare() {
    _shareChannel.invokeMethod<String>('getInitialSharedText').then((text) {
      if (text != null && text.trim().isNotEmpty && mounted) {
        _showImportModal(initialText: text);
      }
    }).catchError((_) {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final loadedDrives = await StorageService.loadDrives();
    final loadedProfile = await StorageService.loadProfile();
    if (mounted) {
      setState(() {
        _drives = loadedDrives;
        _profile = loadedProfile;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveDrives() async {
    await StorageService.saveDrives(_drives);
    if (mounted) setState(() {});
  }

  PlacementDrive? get _nextUpcomingDrive {
    final activeDrives = _drives.where((d) => d.formDeadline.isAfter(DateTime.now())).toList();
    if (activeDrives.isEmpty) return _drives.isNotEmpty ? _drives.first : null;
    activeDrives.sort((a, b) => a.formDeadline.compareTo(b.formDeadline));
    return activeDrives.first;
  }

  List<PlacementDrive> get _filteredDrives {
    final now = DateTime.now();
    return _drives.where((drive) {
      // Exclude fully expired drives (deadline passed) and not pinned and not in active stage
      final isExpired = drive.formDeadline.isBefore(now) &&
          drive.stage != DriveStage.shortlisted &&
          drive.stage != DriveStage.interview &&
          drive.stage != DriveStage.offer &&
          !drive.isPinned;
      if (isExpired) return false;

      final matchesSearch = _searchQuery.isEmpty ||
          drive.companyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          drive.postTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          drive.location.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStage = _selectedFilterStage == null || drive.stage == _selectedFilterStage;

      return matchesSearch && matchesStage;
    }).toList();
  }

  Future<void> _togglePin(PlacementDrive drive) async {
    drive.isPinned = !drive.isPinned;
    await StorageService.updateDrive(drive);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.cyanAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Stitch TopAppBar
            _buildTopAppBar(),

            // Search Bar (if search is active)
            if (_isSearching) _buildSearchBar(),

            // Main Content Body (switchable by BottomNavBar)
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.cyanAccent,
                backgroundColor: AppColors.surfaceCard,
                child: _buildCurrentTabContent(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // 1. Top App Bar (Stitch Header)
  Widget _buildTopAppBar() {
    final initial = _profile.name.isNotEmpty ? _profile.name[0].toUpperCase() : 'A';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.85),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: User Avatar & App Title
          Row(
            children: [
              GestureDetector(
                onTap: _showProfileModal,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),

          // Right: Search Toggle Button
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: AppColors.onSurfaceVariant,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Search Field Bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: AppColors.surfaceContainer,
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search drives by company, role or location...',
          hintStyle: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: AppColors.cyanAccent, size: 20),
          filled: true,
          fillColor: AppColors.surfaceCard,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
        onChanged: (val) {
          setState(() {
            _searchQuery = val.trim();
          });
        },
      ),
    );
  }

  // 3. Tab Body Switcher
  Widget _buildCurrentTabContent() {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildDrivesTab();
      case 2:
        return _buildCalendarTab();
      default:
        return _buildHomeTab();
    }
  }

  // 4. Tab 0: Stitch Home / Overview Tab
  Widget _buildHomeTab() {
    final upcoming = _nextUpcomingDrive;
    final pinnedDrives = _drives.where((d) => d.isPinned).toList();
    final drivesToDisplay = _filteredDrives.where((d) => !d.isPinned).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      physics: const BouncingScrollPhysics(),
      children: [
        // Header Actions: "Overview" + "Import Drive" Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showImportModal,
              icon: const Icon(Icons.add, size: 16, color: Color(0xFF0D0E15)),
              label: const Text(
                'Import Drive',
                style: TextStyle(
                  color: Color(0xFF0D0E15),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5F6FA),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Hero Urgent Card
        if (upcoming != null && _searchQuery.isEmpty) ...[
          StitchUrgentHeroCard(
            drive: upcoming,
            onTap: () => _openDriveDetail(upcoming),
          ),
          const SizedBox(height: 20),
        ],

        // Pinned Drives Section
        if (pinnedDrives.isNotEmpty && _searchQuery.isEmpty) ...[
          Row(
            children: [
              const Icon(Icons.push_pin, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              const Text(
                'Pinned',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...pinnedDrives.map(
            (drive) => StitchDriveCard(
              drive: drive,
              onTap: () => _openDriveDetail(drive),
              onPinToggle: () => _togglePin(drive),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Section Title: "Active Drives"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Drives',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${drivesToDisplay.length} Drives',
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Drive Cards List
        if (drivesToDisplay.isEmpty)
          Container(
            padding: const EdgeInsets.all(36),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                const Icon(Icons.work_outline, color: AppColors.onSurfaceVariant, size: 36),
                const SizedBox(height: 12),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No drives matching "$_searchQuery"'
                      : 'No active placement drives yet.\nTap "Import Drive" to parse an email or document.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ...drivesToDisplay.map(
            (drive) => StitchDriveCard(
              drive: drive,
              onTap: () => _openDriveDetail(drive),
              onPinToggle: () => _togglePin(drive),
            ),
          ),
      ],
    );
  }

  // 5. Tab 1: Drives Kanban / Pipeline View
  Widget _buildDrivesTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text(
          'Pipeline Tracker',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),

        // Stage Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All', null),
              ...DriveStage.values.map(
                (stage) => _buildFilterChip(stage.label, stage),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Drive List
        if (_filteredDrives.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No drives found in this stage.',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ),
          )
        else
          ..._filteredDrives.map(
            (drive) => StitchDriveCard(
              drive: drive,
              onTap: () => _openDriveDetail(drive),
              onPinToggle: () => _togglePin(drive),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip(String label, DriveStage? stage) {
    final isSelected = _selectedFilterStage == stage;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.cyanAccent,
        backgroundColor: AppColors.surfaceCard,
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : AppColors.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.cyanAccent : Colors.white.withOpacity(0.08),
        ),
        onSelected: (_) {
          setState(() {
            _selectedFilterStage = stage;
          });
        },
      ),
    );
  }

  // 6. Tab 2: Calendar & Rounds Timeline
  Widget _buildCalendarTab() {
    return StitchCalendarView(
      drives: _drives,
      profile: _profile,
      onDrivesUpdated: () => _saveDrives(),
    );
  }

  // 7. Bottom Navigation Bar (Stitch BottomNavBar)
  Widget _buildBottomNavBar() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.dashboard, Icons.dashboard_outlined, 'Home'),
          _buildNavItem(1, Icons.work, Icons.work_outline, 'Drives'),
          _buildNavItem(2, Icons.event_note, Icons.event_note_outlined, 'Calendar'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentNavIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Actions & Modals
  Future<void> _openDriveDetail(PlacementDrive drive) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriveDetailScreen(
          drive: drive,
          profile: _profile,
          onDriveUpdated: (_) => _loadData(),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  void _showImportModal({String? initialText}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImportDriveModal(
        initialEmailText: initialText,
        onImport: (newDrive) {
          _drives.insert(0, newDrive);
          _saveDrives();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${newDrive.companyName} to your drives!'),
              backgroundColor: AppColors.cyanAccent,
            ),
          );
        },
      ),
    );
  }

  void _showProfileModal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          profile: _profile,
          drives: _drives,
          onProfileSaved: (updated) {
            setState(() {
              _profile = updated;
            });
          },
        ),
      ),
    );
  }
}
