import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/spacing.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/projects/data/project_create_api.dart';
import 'package:magna_coders/features/projects/ui/widgets/project_form_section.dart';
import 'package:magna_coders/features/projects/ui/widgets/project_photo_picker.dart';
import 'package:magna_coders/features/projects/ui/widgets/tech_stack_input.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _api = ProjectCreateApi();
  
  bool _isLoading = false;
  
  // Form values
  final _titleController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _fullDescController = TextEditingController();
  final _repoUrlController = TextEditingController();
  
  XFile? _imageFile;
  List<String> _techStack = [];
  String? _categoryId;
  String _visibility = 'public';
  bool _lookingForContributors = false;
  int? _maxContributors;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescController.dispose();
    _fullDescController.dispose();
    _repoUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit(String status) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final request = CreateProjectRequest(
      title: _titleController.text,
      shortDescription: _shortDescController.text,
      description: _fullDescController.text,
      status: status,
      categoryId: _categoryId,
      visibility: _visibility,
      techStack: _techStack,
      lookingForContributors: _lookingForContributors,
      maxContributors: _maxContributors,
      startDate: _startDate,
      endDate: _endDate,
      repositoryUrl: _repoUrlController.text.isNotEmpty ? _repoUrlController.text : null,
      imageFile: _imageFile,
    );
    
    final projectId = await _api.createProject(request);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (projectId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project created successfully')),
        );
        context.pushReplacement('/project/$projectId');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create project')),
        );
      }
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final initialDate = isStart ? (_startDate ?? now) : (_endDate ?? (_startDate ?? now));
    
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Project'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    ProjectFormSection(
                      title: '1. Project Photo',
                      child: ProjectPhotoPicker(
                        onImageSelected: (file) => setState(() => _imageFile = file),
                      ),
                    ),
                    ProjectFormSection(
                      title: '2. Project Basics',
                      isRequired: true,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(labelText: 'Project Title'),
                            maxLength: 120,
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _shortDescController,
                            decoration: const InputDecoration(labelText: 'Short Description'),
                            maxLength: 200,
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _fullDescController,
                            decoration: const InputDecoration(labelText: 'Full Description'),
                            maxLines: 5,
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          DropdownButtonFormField<String>(
                            value: _categoryId,
                            decoration: const InputDecoration(labelText: 'Category (Optional)'),
                            items: const [
                              DropdownMenuItem(value: 'tech', child: Text('Technology')),
                              DropdownMenuItem(value: 'design', child: Text('Design')),
                              DropdownMenuItem(value: 'business', child: Text('Business')),
                              DropdownMenuItem(value: 'social', child: Text('Social')),
                            ],
                            onChanged: (v) => setState(() => _categoryId = v),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          DropdownButtonFormField<String>(
                            value: _visibility,
                            decoration: const InputDecoration(labelText: 'Visibility'),
                            items: const [
                              DropdownMenuItem(value: 'public', child: Text('Public')),
                              DropdownMenuItem(value: 'private', child: Text('Private')),
                            ],
                            onChanged: (v) => setState(() => _visibility = v!),
                          ),
                        ],
                      ),
                    ),
                    ProjectFormSection(
                      title: '3. Tech Stack',
                      child: TechStackInput(
                        initialTags: _techStack,
                        onChanged: (tags) => setState(() => _techStack = tags),
                      ),
                    ),
                    ProjectFormSection(
                      title: '4. Contributors',
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Looking for contributors'),
                            value: _lookingForContributors,
                            onChanged: (v) => setState(() => _lookingForContributors = v),
                            contentPadding: EdgeInsets.zero,
                          ),
                          if (_lookingForContributors)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Max contributors',
                                helperText: 'How many collaborators are you looking for?',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) => _maxContributors = int.tryParse(v),
                            ),
                        ],
                      ),
                    ),
                    ProjectFormSection(
                      title: '5. Timeline',
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickDate(true),
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text(_startDate == null ? 'Start Date' : DateFormat('MMM dd, yyyy').format(_startDate!)),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickDate(false),
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text(_endDate == null ? 'End Date' : DateFormat('MMM dd, yyyy').format(_endDate!)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ProjectFormSection(
                      title: '6. Project Link',
                      child: TextFormField(
                        controller: _repoUrlController,
                        decoration: InputDecoration(
                          labelText: 'Repository URL',
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: TextButton.icon(
                              onPressed: () {
                                // Logic to open a GitHub picker or similar could go here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Import from GitHub coming soon!')),
                                );
                              },
                              icon: PhosphorIcon(PhosphorIcons.githubLogo()),
                              label: const Text('Import'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                              ),
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.url,
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          final uri = Uri.tryParse(v);
                          if (uri == null || !uri.hasAbsolutePath) return 'Invalid URL';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _submit('published'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Publish Project'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
