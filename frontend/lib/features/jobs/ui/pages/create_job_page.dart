import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/spacing.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/jobs/data/job_create_api.dart';
import 'package:magna_coders/features/jobs/domain/create_job_request.dart';
import 'package:magna_coders/features/jobs/ui/widgets/job_banner_picker.dart';
import 'package:magna_coders/features/jobs/ui/widgets/job_form_section.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CreateJobPage extends StatefulWidget {
  const CreateJobPage({super.key});

  @override
  State<CreateJobPage> createState() => _CreateJobPageState();
}

class _CreateJobPageState extends State<CreateJobPage> {
  final _formKey = GlobalKey<FormState>();
  final _api = JobCreateApi();
  
  bool _isLoading = false;
  
  // Form values
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _companyNameController = TextEditingController();
  
  XFile? _imageFile;
  String? _companyId;
  String? _categoryId;
  String _jobType = 'Full-time';
  DateTime? _deadline;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final request = CreateJobRequest(
        title: _titleController.text,
        description: _descriptionController.text,
        companyId: _companyId,
        companyName: _companyNameController.text.isNotEmpty ? _companyNameController.text : null,
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        salary: _salaryController.text.isNotEmpty ? _salaryController.text : null,
        jobType: _jobType,
        deadline: _deadline,
        categoryId: _categoryId,
      );
      
      final jobId = await _api.createJob(request, imageFile: _imageFile);
      
      if (mounted) {
        setState(() => _isLoading = false);
        if (jobId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job created successfully')),
          );
          context.pushReplacement('/job/$jobId');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create job')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    
    if (date != null) {
      setState(() => _deadline = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Job'),
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
                    JobFormSection(
                      title: '1. Job Banner',
                      child: JobBannerPicker(
                        onImageSelected: (file) => setState(() => _imageFile = file),
                      ),
                    ),
                    JobFormSection(
                      title: '2. Company',
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _companyId,
                            decoration: const InputDecoration(
                              labelText: 'Select Company (optional)',
                              hintText: 'Select an existing company (optional)',
                            ),
                            items: const [
                              DropdownMenuItem(value: 'magna-tech-id', child: Text('Magna Tech')),
                              DropdownMenuItem(value: 'cloud-services-id', child: Text('Cloud Services')),
                            ],
                            onChanged: (v) => setState(() => _companyId = v),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _companyNameController,
                            decoration: const InputDecoration(
                              labelText: 'Or enter company name',
                              hintText: 'e.g. Alvin AI Labs',
                            ),
                          ),
                        ],
                      ),
                    ),
                    JobFormSection(
                      title: '3. Core Details',
                      isRequired: true,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(labelText: 'Job Title'),
                            maxLength: 120,
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(labelText: 'Job Description'),
                            maxLines: 8,
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    JobFormSection(
                      title: '4. Logistics',
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              hintText: 'e.g. Remote, Nairobi, Kenya',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _salaryController,
                            decoration: const InputDecoration(
                              labelText: 'Salary',
                              hintText: 'e.g. KES 150k - 200k, Negotiable',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          InkWell(
                            onTap: _pickDeadline,
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Application Deadline'),
                              child: Text(
                                _deadline != null 
                                    ? DateFormat('MMM d, yyyy').format(_deadline!)
                                    : 'Select deadline date',
                                style: _deadline != null ? null : TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    JobFormSection(
                      title: '5. Classification',
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _jobType,
                            decoration: const InputDecoration(labelText: 'Job Type'),
                            items: const [
                              DropdownMenuItem(value: 'Full-time', child: Text('Full-time')),
                              DropdownMenuItem(value: 'Part-time', child: Text('Part-time')),
                              DropdownMenuItem(value: 'Contract', child: Text('Contract')),
                              DropdownMenuItem(value: 'Internship', child: Text('Internship')),
                              DropdownMenuItem(value: 'Freelance', child: Text('Freelance')),
                            ],
                            onChanged: (v) => setState(() => _jobType = v!),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          DropdownButtonFormField<String>(
                            value: _categoryId,
                            decoration: const InputDecoration(labelText: 'Category'),
                            items: const [
                              DropdownMenuItem(value: 'tech', child: Text('Technology')),
                              DropdownMenuItem(value: 'design', child: Text('Design')),
                              DropdownMenuItem(value: 'business', child: Text('Business')),
                              DropdownMenuItem(value: 'social', child: Text('Social')),
                            ],
                            onChanged: (v) => setState(() => _categoryId = v),
                          ),
                        ],
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
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () {
                        // Draft functionality placeholder
                      },
                      child: const Text('Save Draft'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: const Text('Publish Job'),
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
