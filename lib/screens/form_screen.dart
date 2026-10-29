import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../l10n/app_strings.dart';
import '../models/cv_model.dart';
import '../state/cv_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme.dart';
import 'preview_screen.dart';

class FormScreen extends StatefulWidget {
  final CvModel cv;
  final CvProvider cvProvider;
  final SettingsProvider settingsProvider;
  final int initialStep;

  const FormScreen({
    super.key,
    required this.cv,
    required this.cvProvider,
    required this.settingsProvider,
    this.initialStep = 0,
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  late int _currentStep;
  late CvModel _cv;
  Timer? _debounceTimer;

  // Controllers for Personal Details
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;

  // Controller for Objective
  late TextEditingController _objectiveController;

  // Validation errors
  String? _nameError;
  String? _phoneError;

  final ScrollController _chipScrollController = ScrollController();

  final List<String> _stepTitles = [
    'Personal',
    'Objective',
    'Education',
    'Experience',
    'Skills',
    'Languages',
    'Projects',
    'Certifications',
    'References',
    'Hobbies',
  ];

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _cv = widget.cv;

    _nameController = TextEditingController(text: _cv.personal.fullName);
    _phoneController = TextEditingController(text: _cv.personal.phone);
    _emailController = TextEditingController(text: _cv.personal.email);
    _cityController = TextEditingController(text: _cv.personal.city);
    _addressController = TextEditingController(text: _cv.personal.address);
    _objectiveController = TextEditingController(text: _cv.objective);

    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _cityController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
    _objectiveController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _saveDraftImmediate();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _objectiveController.dispose();
    _chipScrollController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    _cv.personal.fullName = _nameController.text;
    _cv.personal.phone = _phoneController.text;
    _cv.personal.email = _emailController.text;
    _cv.personal.city = _cityController.text;
    _cv.personal.address = _addressController.text;
    _cv.objective = _objectiveController.text;

    // Debounce autosave to SQLite
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      _saveDraftImmediate();
    });
  }

  Future<void> _saveDraftImmediate() async {
    _cv.personal.fullName = _nameController.text;
    _cv.personal.phone = _phoneController.text;
    _cv.personal.email = _emailController.text;
    _cv.personal.city = _cityController.text;
    _cv.personal.address = _addressController.text;
    _cv.objective = _objectiveController.text;

    // Update title automatically if it's default and name is entered
    if ((_cv.title == 'My CV' || _cv.title.isEmpty) && _cv.personal.fullName.trim().isNotEmpty) {
      _cv.title = "${_cv.personal.fullName.trim()}'s CV";
    }

    await widget.cvProvider.updateCv(_cv);
  }

  void _saveButtonTapped() async {
    await _saveDraftImmediate();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.settingsProvider.strings.saved),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.emerald,
      ),
    );
  }

  bool _validateCurrentStep() {
    // Only Step 1 (Personal) has blocking validation: Full Name and Phone
    if (_currentStep == 0) {
      bool valid = true;
      setState(() {
        if (_nameController.text.trim().isEmpty) {
          _nameError = widget.settingsProvider.strings.fullNameError;
          valid = false;
        } else {
          _nameError = null;
        }

        if (_phoneController.text.trim().isEmpty) {
          _phoneError = widget.settingsProvider.strings.phoneError;
          valid = false;
        } else {
          _phoneError = null;
        }
      });
      return valid;
    }
    return true;
  }

  void _onNextTapped() async {
    if (!_validateCurrentStep()) return;

    await _saveDraftImmediate();

    if (_currentStep < 9) {
      setState(() {
        _currentStep++;
      });
      _scrollToCurrentChip();
    } else {
      // Last step -> go to Live Preview
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PreviewScreen(
            cv: _cv,
            cvProvider: widget.cvProvider,
            settingsProvider: widget.settingsProvider,
          ),
        ),
      );
    }
  }

  void _onBackTapped() async {
    await _saveDraftImmediate();
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _scrollToCurrentChip();
    } else {
      // Step 0 Back returns to Home without discard dialog (already saved)
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _scrollToCurrentChip() {
    if (_chipScrollController.hasClients) {
      final target = (_currentStep * 90.0).clamp(0.0, _chipScrollController.position.maxScrollExtent);
      _chipScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800);
      if (picked != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'cv_photo_${_cv.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedFile = await File(picked.path).copy('${appDir.path}/$fileName');

        setState(() {
          _cv.photoPath = savedFile.path;
          _cv.personal.photoEnabled = true;
        });
        await _saveDraftImmediate();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo error: $e')),
        );
      }
    }
  }

  void _removePhoto() async {
    setState(() {
      _cv.photoPath = null;
    });
    await _saveDraftImmediate();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.settingsProvider.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _onBackTapped,
        ),
        title: Text(
          _cv.personal.fullName.isNotEmpty ? s.editCv : s.createCv,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveButtonTapped,
            icon: const Icon(Icons.check, color: AppColors.goldLight, size: 20),
            label: Text(
              s.save,
              style: const TextStyle(
                color: AppColors.goldLight,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Step Indicator Bar
          _buildStepIndicatorBar(s, isDark),

          // Active Step Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _buildCurrentStepContent(s, isDark),
            ),
          ),

          // Bottom Navigation Buttons
          _buildBottomButtons(s),
        ],
      ),
    );
  }

  Widget _buildStepIndicatorBar(AppStrings s, bool isDark) {
    return Container(
      color: AppColors.emerald,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress & Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${s.stepOf} ${_currentStep + 1} ${s.stepOutOf}: ${_getStepLabel(_currentStep, s)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                '${((_currentStep + 1) / 10 * 100).toInt()}%',
                style: const TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          // Scrollable Step Chips
          SizedBox(
            height: 32,
            child: ListView.separated(
              controller: _chipScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == _currentStep;
                return ChoiceChip(
                  label: Text(
                    '${index + 1}. ${_stepTitles[index]}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.emeraldDark : Colors.white70,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.gold,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (selected) {
                    if (selected && _validateCurrentStep()) {
                      _saveDraftImmediate();
                      setState(() {
                        _currentStep = index;
                      });
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getStepLabel(int index, AppStrings s) {
    switch (index) {
      case 0:
        return s.stepPersonal;
      case 1:
        return s.stepObjective;
      case 2:
        return s.stepEducation;
      case 3:
        return s.stepExperience;
      case 4:
        return s.stepSkills;
      case 5:
        return s.stepLanguages;
      case 6:
        return s.stepProjects;
      case 7:
        return s.stepCertifications;
      case 8:
        return s.stepReferences;
      case 9:
      default:
        return s.stepHobbies;
    }
  }

  Widget _buildCurrentStepContent(AppStrings s, bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildStepPersonal(s, isDark);
      case 1:
        return _buildStepObjective(s, isDark);
      case 2:
        return _buildStepEducation(s, isDark);
      case 3:
        return _buildStepExperience(s, isDark);
      case 4:
        return _buildStepSkills(s, isDark);
      case 5:
        return _buildStepLanguages(s, isDark);
      case 6:
        return _buildStepProjects(s, isDark);
      case 7:
        return _buildStepCertifications(s, isDark);
      case 8:
        return _buildStepReferences(s, isDark);
      case 9:
      default:
        return _buildStepHobbies(s, isDark);
    }
  }

  // --- Step 0: Personal ---
  Widget _buildStepPersonal(AppStrings s, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo Picker
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.emeraldTint,
                    border: Border.all(color: AppColors.emerald, width: 2),
                    image: _cv.photoPath != null && File(_cv.photoPath!).existsSync()
                        ? DecorationImage(
                            image: FileImage(File(_cv.photoPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _cv.photoPath == null || !File(_cv.photoPath!).existsSync()
                      ? const Icon(Icons.camera_alt, size: 36, color: AppColors.emerald)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.addPhoto,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              if (_cv.photoPath != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: _pickPhoto,
                      child: Text(s.changePhoto, style: const TextStyle(fontSize: 12)),
                    ),
                    TextButton(
                      onPressed: _removePhoto,
                      child: Text(s.removePhoto, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Full Name (Required)
        Text(s.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: s.fullNameHint,
            errorText: _nameError,
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),

        // Phone Number (Required)
        Text(s.phoneNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: s.phoneNumberHint,
            errorText: _phoneError,
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 16),

        // Email (Optional)
        Text(s.email, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: s.emailHint,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),

        // City (Required, Pakistan city)
        Text(s.city, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: _cityController,
          decoration: InputDecoration(
            hintText: s.cityHint,
            prefixIcon: const Icon(Icons.location_city_outlined),
          ),
        ),
        const SizedBox(height: 16),

        // Address (Optional, short)
        Text(s.address, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: _addressController,
          decoration: InputDecoration(
            hintText: s.addressHint,
            prefixIcon: const Icon(Icons.home_outlined),
          ),
        ),
      ],
    );
  }

  // --- Step 1: Objective ---
  Widget _buildStepObjective(AppStrings s, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.objectiveTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        Text(
          s.objectiveHint,
          style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _objectiveController,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'e.g. Dedicated professional with expertise in...',
          ),
        ),
      ],
    );
  }

  // --- Step 2: Education ---
  Widget _buildStepEducation(AppStrings s, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(s.stepEducation, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: Text(s.addItem),
              onPressed: () {
                setState(() {
                  _cv.education.add(EducationItem(degree: '', institution: '', passingYear: ''));
                });
                _saveDraftImmediate();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_cv.education.isEmpty)
          _buildEmptySectionMessage('Abhi koi taleem shamil nahi ki. Upar button daba kar add karein.')
        else
          ..._cv.education.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Taleem #${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.emerald)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                          onPressed: () {
                            setState(() {
                              _cv.education.removeAt(idx);
                            });
                            _saveDraftImmediate();
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      initialValue: item.degree,
                      decoration: const InputDecoration(labelText: 'Degree / Certificate', hintText: 'e.g. BS Computer Science, Matric...'),
                      onChanged: (v) {
                        item.degree = v;
                        _saveDraftImmediate();
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: item.institution,
                      decoration: const InputDecoration(labelText: 'Institute / University / Board', hintText: 'e.g. Punjab University'),
                      onChanged: (v) {
                        item.institution = v;
                        _saveDraftImmediate();
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: item.city,
                            decoration: const InputDecoration(labelText: 'City', hintText: 'e.g. Lahore'),
                            onChanged: (v) {
                              item.city = v;
                              _saveDraftImmediate();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            initialValue: item.passingYear,
                            decoration: const InputDecoration(labelText: 'Passing Year', hintText: 'e.g. 2022'),
                            onChanged: (v) {
                              item.passingYear = v;
                              _saveDraftImmediate();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: item.marksOrGrade,
                      decoration: const InputDecoration(labelText: 'Grade / CGPA / Marks', hintText: 'e.g. 3.5 CGPA / Grade A'),
                      onChanged: (v) {
                        item.marksOrGrade = v;
                        _saveDraftImmediate();
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // --- Step 3: Experience ---
  Widget _buildStepExperience(AppStrings s, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(s.stepExperience, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: Text(s.addItem),
              onPressed: () {
                setState(() {
                  _cv.experience.add(ExperienceItem(jobTitle: '', company: ''));
                });
                _saveDraftImmediate();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_cv.experience.isEmpty)
          _buildEmptySectionMessage('Koi tajurba shamil nahi. Upar button se shamil karein.')
        else
          ..._cv.experience.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tajurba #${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.emerald)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                          onPressed: () {
                            setState(() {
                              _cv.experience.removeAt(idx);
                            });
                            _saveDraftImmediate();
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      initialValue: item.jobTitle,
                      decoration: const InputDecoration(labelText: 'Job Title', hintText: 'e.g. Senior Teacher, Cashier...'),
                      onChanged: (v) {
                        item.jobTitle = v;
                        _saveDraftImmediate();
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: item.company,
                      decoration: const InputDecoration(labelText: 'Company / Organization', hintText: 'e.g. Systems Limited, HBL...'),
                      onChanged: (v) {
                        item.company = v;
                        _saveDraftImmediate();
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: item.startDate,
                            decoration: const InputDecoration(labelText: 'Start Date', hintText: 'e.g. Jan 2021'),
                            onChanged: (v) {
                              item.startDate = v;
                              _saveDraftImmediate();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            initialValue: item.endDate,
                            enabled: !item.isCurrent,
                            decoration: const InputDecoration(labelText: 'End Date', hintText: 'e.g. Dec 2023'),
                            onChanged: (v) {
                              item.endDate = v;
                              _saveDraftImmediate();
                            },
                          ),
                        ),
                      ],
                    ),
                    CheckboxListTile(
                      title: const Text('Mojooda Naukri (Currently working here)', style: TextStyle(fontSize: 13)),
                      value: item.isCurrent,
                      onChanged: (val) {
                        setState(() {
                          item.isCurrent = val ?? false;
                        });
                        _saveDraftImmediate();
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    TextFormField(
                      initialValue: item.description,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Responsibilities / Kaam', hintText: 'Briefly describe responsibilities...'),
                      onChanged: (v) {
                        item.description = v;
                        _saveDraftImmediate();
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // --- Step 4: Skills ---
  Widget _buildStepSkills(AppStrings s, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(s.stepSkills, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: Text(s.addItem),
              onPressed: () {
                setState(() {
                  _cv.skills.add(SkillItem(skillName: '', level: 'Intermediate'));
                });
                _saveDraftImmediate();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_cv.skills.isEmpty)
          _buildEmptySectionMessage('Koi hunar shamil nahi kiya.')
        else
          ..._cv.skills.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        initialValue: item.skillName,
                        decoration: const InputDecoration(labelText: 'Hunar / Skill Name', hintText: 'e.g. MS Office, Flutter...'),
                        onChanged: (v) {
                          item.skillName = v;
                          _saveDraftImmediate();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: ['Beginner', 'Intermediate', 'Advanced', 'Expert'].contains(item.level) ? item.level : 'Intermediate',
                        items: ['Beginner', 'Intermediate', 'Advanced', 'Expert']
                            .map((lvl) => DropdownMenuItem(value: lvl, child: Text(lvl, style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            item.level = val;
                            _saveDraftImmediate();
                          }
                        },
                        decoration: const InputDecoration(labelText: 'Level'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                      onPressed: () {
                        setState(() {
                          _cv.skills.removeAt(idx);
                        });
                        _saveDraftImmediate();
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // --- Step 5: Languages ---
  Widget _buildStepLanguages(AppStrings s, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(s.stepLanguages, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: Text(s.addItem),
              onPressed: () {
                setState(() {
                  _cv.languages.add(LanguageItem(languageName: '', proficiency: 'Fluent'));
                });
                _saveDraftImmediate();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_cv.languages.isEmpty)
          _buildEmptySectionMessage('Koi zuban shamil nahi ki.')
        else
          ..._cv.languages.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        initialValue: item.languageName,
                        decoration: const InputDecoration(labelText: 'Zuban / Language', hintText: 'e.g. Urdu, English, Pashto...'),
                        onChanged: (v) {
                          item.languageName = v;
                          _saveDraftImmediate();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: ['Native', 'Fluent', 'Intermediate', 'Basic'].contains(item.proficiency) ? item.proficiency : 'Fluent',
                        items: ['Native', 'Fluent', 'Intermediate', 'Basic']
                            .map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            item.proficiency = val;
                            _saveDraftImmediate();
                          }
                        },
                        decoration: const InputDecoration(labelText: 'Proficiency'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                      onPressed: () {
                        setState(() {
                          _cv.languages.removeAt(idx);
                        });
                        _saveDraftImmediate();
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // --- Step 6: Projects ---
  Widget _buildStepProjects(AppStrings s, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(s.stepProjects, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: Text(s.addItem),
              onPressed: () {
                setState(() {
                  _cv.projects.add(ProjectItem(title: '', description: ''));
                });
                _saveDraftImmediate();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_cv.projects.isEmpty)
          _buildEmptySectionMessage('Optional: Agar koi project kiya hai to shamil karein.')
        else
          ..._cv.projects.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Project #${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.emerald)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                          onPressed: () {
                            setState(() {
                              _cv.projects.removeAt(idx);
                            });
                            _saveDraftImmediate();
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      initialValue: item.title,
                      decoration: const InputDecoration(labelText: 'Project Title', hintText: 'e.g. Food Delivery App'),
                      onChanged: (v) {
                        item.title = v;
                        _saveDraftImmediate();
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: item.linkOrTools,
                      decoration: const InputDecoration(labelText: 'Tools / Tech Used', hintText: 'e.g. Flutter, SQLite, Python'),
                      onChanged: (v) {
                        item.linkOrTools = v;
                        _saveDraftImmediate();
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: item.description,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Description', hintText: 'Brief summary of the project...'),
                      onChanged: (v) {
                        item.description = v;
                        _saveDraftImmediate();
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // --- Step 7: Certifications ---
  Widget _buildStepCertifications(AppStrings s, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(s.stepCertifications, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: Text(s.addItem),
              onPressed: () {
                setState(() {
                  _cv.certifications.add(CertificationItem(title: '', institute: ''));
                });
                _saveDraftImmediate();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_cv.certifications.isEmpty)
          _buildEmptySectionMessage('Optional: Agar koi certificate mila hai to shamil karein.')
        else
          ..._cv.certifications.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Certificate #${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.emerald)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                          onPressed: () {
                            setState(() {
                              _cv.certifications.removeAt(idx);
                            });
                            _saveDraftImmediate();
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      initialValue: item.title,
                      decoration: const InputDecoration(labelText: 'Certificate Title', hintText: 'e.g. Modern Pedagogy Workshop'),
                      onChanged: (v) {
                        item.title = v;
                        _saveDraftImmediate();
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            initialValue: item.institute,
                            decoration: const InputDecoration(labelText: 'Institute / Issuer', hintText: 'e.g. British Council'),
                            onChanged: (v) {
                              item.institute = v;
                              _saveDraftImmediate();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: item.year,
                            decoration: const InputDecoration(labelText: 'Year', hintText: 'e.g. 2023'),
                            onChanged: (v) {
                              item.year = v;
                              _saveDraftImmediate();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // --- Step 8: References ---
  Widget _buildStepReferences(AppStrings s, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(s.stepReferences, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: Text(s.addItem),
              onPressed: () {
                setState(() {
                  _cv.references.add(ReferenceItem(name: '', designation: ''));
                });
                _saveDraftImmediate();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_cv.references.isEmpty)
          _buildEmptySectionMessage('Optional: e.g. "Available upon request" ya kisi ustad/supervisor ka naam.')
        else
          ..._cv.references.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Reference #${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.emerald)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                          onPressed: () {
                            setState(() {
                              _cv.references.removeAt(idx);
                            });
                            _saveDraftImmediate();
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      initialValue: item.name,
                      decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Available upon request / Prof. Ali'),
                      onChanged: (v) {
                        item.name = v;
                        _saveDraftImmediate();
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: item.designation,
                      decoration: const InputDecoration(labelText: 'Designation / Relationship', hintText: 'e.g. Head of Department'),
                      onChanged: (v) {
                        item.designation = v;
                        _saveDraftImmediate();
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: item.contact,
                      decoration: const InputDecoration(labelText: 'Contact / Email', hintText: 'e.g. Provided on demand'),
                      onChanged: (v) {
                        item.contact = v;
                        _saveDraftImmediate();
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // --- Step 9: Hobbies ---
  Widget _buildStepHobbies(AppStrings s, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(s.stepHobbies, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: Text(s.addItem),
              onPressed: () {
                setState(() {
                  _cv.hobbies.add(HobbyItem(name: ''));
                });
                _saveDraftImmediate();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_cv.hobbies.isEmpty)
          _buildEmptySectionMessage('Optional: Apne mashghale shamil karein (Reading, Cricket, etc.)')
        else
          ..._cv.hobbies.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: item.name,
                        decoration: const InputDecoration(labelText: 'Mashghala / Hobby', hintText: 'e.g. Reading, Cricket, Travel'),
                        onChanged: (v) {
                          item.name = v;
                          _saveDraftImmediate();
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                      onPressed: () {
                        setState(() {
                          _cv.hobbies.removeAt(idx);
                        });
                        _saveDraftImmediate();
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildEmptySectionMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.emeraldTint.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.emerald, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: AppColors.emeraldDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(AppStrings s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, -3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: const BorderSide(color: AppColors.emerald, width: 1.2),
              ),
              onPressed: _onBackTapped,
              child: Text(
                s.back,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Next / Preview Button
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              onPressed: _onNextTapped,
              child: Text(
                _currentStep == 9 ? s.preview : s.next,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
