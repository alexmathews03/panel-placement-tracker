import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/drive_model.dart';
import '../../../core/parser/email_parser.dart';

class ImportDriveModal extends StatefulWidget {
  final String? initialEmailText;
  final Function(PlacementDrive) onImport;

  const ImportDriveModal({
    super.key,
    this.initialEmailText,
    required this.onImport,
  });

  @override
  State<ImportDriveModal> createState() => _ImportDriveModalState();
}

class _ImportDriveModalState extends State<ImportDriveModal> {
  late TextEditingController _emailController;
  PlacementDrive? _parsedDrive;
  bool _isParsed = false;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmailText ?? '');
    if (_emailController.text.isNotEmpty) {
      _parseEmail();
    }
  }

  void _parseEmail() {
    if (_emailController.text.trim().isEmpty) return;
    setState(() {
      _parsedDrive = EmailParserEngine.parseEmailText(_emailController.text);
      _isParsed = true;
    });
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null && data.text != null && data.text!.trim().isNotEmpty) {
        setState(() {
          _emailController.text = data.text!;
          _selectedFileName = null;
        });
        _parseEmail();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📋 Pasted and parsed email from clipboard!'),
              backgroundColor: AppColors.surfaceCardLight,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clipboard is empty. Copy placement email text first!'),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Clipboard error: $e");
    }
  }

  Future<void> _pickFile() async {
    try {
      // file_picker v12: FilePicker.pickFiles() returns List<PlatformFile> directly
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        setState(() {
          _selectedFileName = file.name;
        });

        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          final extractedText = _extractTextFromBytes(file.name, bytes);
          if (extractedText.isNotEmpty) {
            _emailController.text = extractedText;
            _parseEmail();
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not extract readable text from the file.'),
                  backgroundColor: Colors.orangeAccent,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  String _extractTextFromBytes(String filename, List<int> bytes) {
    if (filename.toLowerCase().endsWith('.pdf')) {
      try {
        final PdfDocument document = PdfDocument(inputBytes: bytes);
        final String text = PdfTextExtractor(document).extractText();
        document.dispose();
        if (text.trim().isNotEmpty) {
          return text;
        }
      } catch (e) {
        debugPrint('PDF extraction error: $e');
      }
    }

    try {
      return utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      return String.fromCharCodes(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Import Placement Email / PDF',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Upload PDF / Document Action Card
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedFileName != null ? Colors.white : const Color(0xFF2E3445),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFileName ?? 'Upload Placement PDF or Text Document',
                            style: TextStyle(
                              color: _selectedFileName != null ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Tap to select .pdf or .txt placement notice from phone',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.upload_file_rounded, color: AppColors.textMuted, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Or Divider
            Row(
              children: const [
                Expanded(child: Divider(color: Color(0xFF292E3E))),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('OR PASTE EMAIL TEXT', style: TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 1.0)),
                ),
                Expanded(child: Divider(color: Color(0xFF292E3E))),
              ],
            ),
            const SizedBox(height: 14),

            // Raw Email Text Area
            TextField(
              controller: _emailController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Paste placement notification email body here...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2E3445)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2E3445)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
              onChanged: (_) {
                if (_isParsed) setState(() => _isParsed = false);
              },
            ),
            const SizedBox(height: 12),

            // Action Buttons: Paste Clipboard & Parse
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pasteFromClipboard,
                    icon: const Icon(Icons.content_paste_rounded, size: 16, color: Colors.white),
                    label: const Text('Paste Clipboard'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceCard,
                      foregroundColor: AppColors.onSurface,
                      side: BorderSide(color: Colors.white.withOpacity(0.12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _parseEmail,
                    icon: const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF0D0E15)),
                    label: const Text('Parse Notice'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0D0E15),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Parsed Result Card Preview
            if (_isParsed && _parsedDrive != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_isParsed)
                          const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _isParsed ? 'Proceed to Review' : 'Extract Data',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFF292E3E), height: 20),
                    _buildPreviewRow('Company', _parsedDrive!.companyName),
                    _buildPreviewRow('Role', _parsedDrive!.postTitle),
                    _buildPreviewRow('Stipend', _parsedDrive!.payStipend),
                    _buildPreviewRow('CTC / PPO', _parsedDrive!.ctcPpo),
                    _buildPreviewRow('Min CGPA', '${_parsedDrive!.eligibility.minCgpa} CGPA (Max ${_parsedDrive!.eligibility.maxBacklogs} Backlogs)'),
                    _buildPreviewRow('Location', _parsedDrive!.location),
                    _buildPreviewRow('Deadline', '${_parsedDrive!.formDeadline.day}/${_parsedDrive!.formDeadline.month}/${_parsedDrive!.formDeadline.year} @ ${_parsedDrive!.formDeadline.hour.toString().padLeft(2, '0')}:${_parsedDrive!.formDeadline.minute.toString().padLeft(2, '0')}'),
                    const SizedBox(height: 10),
                    // Branch Selector
                    const Text(
                      'ELIGIBLE BRANCHES (TAP TO TOGGLE)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: ['CSE', 'CSBS', 'EEE', 'EV', 'ECE', 'EBE', 'ME'].map((b) {
                        final isElig = _parsedDrive!.eligibility.eligibleBranches.any(
                          (eb) => PlacementDrive.normalizeBranch(eb) == b || eb.toUpperCase() == b,
                        );
                        return FilterChip(
                          label: Text(b),
                          selected: isElig,
                          selectedColor: AppColors.cyanAccent,
                          backgroundColor: AppColors.surfaceContainer,
                          labelStyle: TextStyle(
                            color: isElig ? Colors.black : AppColors.onSurfaceVariant,
                            fontWeight: isElig ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 11,
                          ),
                          side: BorderSide(
                            color: isElig ? AppColors.cyanAccent : Colors.white.withOpacity(0.08),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              final list = List<String>.from(_parsedDrive!.eligibility.eligibleBranches);
                              if (selected) {
                                if (!list.contains(b)) list.add(b);
                              } else {
                                list.removeWhere((eb) => PlacementDrive.normalizeBranch(eb) == b || eb.toUpperCase() == b);
                              }
                              _parsedDrive = PlacementDrive(
                                id: _parsedDrive!.id,
                                companyName: _parsedDrive!.companyName,
                                postTitle: _parsedDrive!.postTitle,
                                payStipend: _parsedDrive!.payStipend,
                                ctcPpo: _parsedDrive!.ctcPpo,
                                location: _parsedDrive!.location,
                                formDeadline: _parsedDrive!.formDeadline,
                                duration: _parsedDrive!.duration,
                                driveSlot: _parsedDrive!.driveSlot,
                                eligibility: EligibilityCriteria(
                                  minCgpa: _parsedDrive!.eligibility.minCgpa,
                                  maxBacklogs: _parsedDrive!.eligibility.maxBacklogs,
                                  eligibleBranches: list,
                                ),
                                rounds: _parsedDrive!.rounds,
                                prepTasks: _parsedDrive!.prepTasks,
                                rawEmails: _parsedDrive!.rawEmails,
                                stage: _parsedDrive!.stage,
                                createdAt: _parsedDrive!.createdAt,
                                isPinned: _parsedDrive!.isPinned,
                              );
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Save to Dashboard Button
              ElevatedButton(
                onPressed: () {
                  widget.onImport(_parsedDrive!);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                ),
                child: const Text(
                  'CONFIRM & ADD TO DASHBOARD',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
