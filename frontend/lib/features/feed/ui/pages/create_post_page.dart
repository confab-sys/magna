import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/spacing.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/feed/data/post_create_api.dart';
import 'package:magna_coders/features/feed/domain/create_post_request.dart';
import 'package:magna_coders/features/feed/ui/widgets/post_form_section.dart';
import 'package:magna_coders/features/feed/ui/widgets/post_image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _api = PostCreateApi();
  
  bool _isLoading = false;
  
  // Form values
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  XFile? _imageFile;
  String? _categoryId;
  String _postType = 'regular';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final request = CreatePostRequest(
        title: _titleController.text,
        content: _contentController.text.isNotEmpty ? _contentController.text : null,
        postType: _postType,
        categoryId: _categoryId,
      );
      
      final postId = await _api.createPost(request, imageFile: _imageFile);
      
      if (mounted) {
        setState(() => _isLoading = false);
        if (postId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post created successfully')),
          );
          context.pushReplacement('/post/$postId');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create post')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
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
                    PostFormSection(
                      title: '1. Media Attachment',
                      child: PostImagePicker(
                        onImageSelected: (file) => setState(() => _imageFile = file),
                      ),
                    ),
                    PostFormSection(
                      title: '2. Core Content',
                      isRequired: true,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              hintText: 'What’s happening at Magna today?',
                            ),
                            maxLength: 120,
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _contentController,
                            decoration: const InputDecoration(
                              labelText: 'Content (Optional)',
                              hintText: 'Write your post here...',
                            ),
                            maxLines: 8,
                          ),
                        ],
                      ),
                    ),
                    PostFormSection(
                      title: '3. Classification',
                      child: DropdownButtonFormField<String>(
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
                      onPressed: _isLoading ? null : () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: const Text('Publish Post'),
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
