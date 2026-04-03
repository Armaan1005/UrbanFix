import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/shadcn_theme.dart';
import '../../providers/report_provider.dart';
import '../../services/location_service.dart';
import '../../services/storage_service.dart';

class ShadcnReportIssueScreen extends StatefulWidget {
  const ShadcnReportIssueScreen({Key? key}) : super(key: key);

  @override
  State<ShadcnReportIssueScreen> createState() =>
      _ShadcnReportIssueScreenState();
}

class _ShadcnReportIssueScreenState extends State<ShadcnReportIssueScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final LocationService _locationService = LocationService();
  final StorageService _storageService = StorageService();

  File? _selectedImage;
  String? _selectedCategory;
  double? _latitude;
  double? _longitude;
  String? _address;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Pothole',
      'value': 'pothole', // Database value
      'icon': Icons.warning_rounded,
      'color': Color(0xFFD64545)
    },
    {
      'name': 'Garbage',
      'value': 'garbage', // Database value
      'icon': Icons.delete_outline_rounded,
      'color': Color(0xFFE9C46A)
    },
    {
      'name': 'Streetlight',
      'value': 'streetlight', // Database value
      'icon': Icons.lightbulb_outline_rounded,
      'color': Color(0xFFD4A574)
    },
    {
      'name': 'Footpath',
      'value': 'footpath', // Database value
      'icon': Icons.directions_walk_rounded,
      'color': Color(0xFF52B788)
    },
    {
      'name': 'Drain',
      'value': 'drain', // Database value
      'icon': Icons.water_drop_outlined,
      'color': Color(0xFF2D6A4F)
    },
    {
      'name': 'Other',
      'value': 'other', // Database value
      'icon': Icons.more_horiz_rounded,
      'color': Color(0xFF6C757D)
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _address = address;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    File? image;
    if (source == ImageSource.camera) {
      image = await _storageService.pickImageFromCamera();
    } else {
      image = await _storageService.pickImageFromGallery();
    }

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      _showError('Please capture or select an image');
      return;
    }

    if (_selectedCategory == null) {
      _showError('Please select a category');
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      _showError('Please enter a title for your report');
      return;
    }

    if (_titleController.text.trim().length < 5) {
      _showError('Title must be at least 5 characters');
      return;
    }

    if (_latitude == null || _longitude == null) {
      _showError('Unable to get location. Please try again.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageUrl = await _storageService.uploadImage(
        _selectedImage!,
        'reports',
      );

      if (imageUrl == null) {
        throw Exception('Failed to upload image');
      }

      final reportId = await context.read<ReportProvider>().createReport(
            category: _selectedCategory!,
            title: _titleController.text.trim(),
            description: _descriptionController.text,
            imageUrl: imageUrl,
            latitude: _latitude!,
            longitude: _longitude!,
            address: _address ?? 'Unknown location',
          );

      if (reportId != null && mounted) {
        // Navigate to confirmation screen
        context.go('/report-submitted/$reportId');
      } else {
        throw Exception('Failed to create report');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: ShadcnThemeConfig.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                background: Container(
                  color: Colors.white,
                ),
                title: Text(
                  'Report Issue',
                  style: theme.textTheme.h2.copyWith(
                    fontSize: 24,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: _isLoading
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Submitting your report...',
                              style: theme.textTheme.muted,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Photo Section Title
                            Text(
                              'Add Photo',
                              style: theme.textTheme.h4.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Two boxes side by side
                            Row(
                              children: [
                                // Photo Upload Box
                                Expanded(
                                  child: _buildPhotoUploadBox(theme),
                                ),
                                const SizedBox(width: 12),
                                // AI Preview Box
                                Expanded(
                                  child: _buildAIPreviewBox(theme),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Title (Required)
                            Text(
                              'Title',
                              style: theme.textTheme.h4.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: ShadcnThemeConfig.borderColor,
                                ),
                              ),
                              child: TextField(
                                controller: _titleController,
                                decoration: const InputDecoration(
                                  hintText: 'Brief summary of the issue',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                  counterText: '',
                                ),
                                maxLength: 100,
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Category Dropdown
                            Text(
                              'Issue Category',
                              style: theme.textTheme.h4.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildCategoryDropdown(theme),

                            const SizedBox(height: 24),

                            // Location
                            Text(
                              'Location',
                              style: theme.textTheme.h4.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildLocationCard(theme),

                            const SizedBox(height: 24),

                            // Description
                            Text(
                              'Description (Optional)',
                              style: theme.textTheme.h4.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: ShadcnThemeConfig.borderColor,
                                ),
                              ),
                              child: TextField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  hintText:
                                      'Provide additional details about the issue...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                                maxLines: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            // Bottom padding for navigation bar and floating button
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 180),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // Above the nav bar
        child: Container(
          width: MediaQuery.of(context).size.width - 40,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                ShadcnThemeConfig.primaryColor,
                ShadcnThemeConfig.secondaryColor,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: ShadcnThemeConfig.primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _submitReport,
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Submit Report',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Photo Upload Box
  Widget _buildPhotoUploadBox(ShadThemeData theme) {
    return GestureDetector(
      onTap: _selectedImage == null ? _showImageSourceDialog : null,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: _selectedImage != null ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ShadcnThemeConfig.borderColor,
            width: 2,
          ),
        ),
        child: _selectedImage != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.black, size: 20),
                        onPressed: () => setState(() => _selectedImage = null),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ShadcnThemeConfig.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 32,
                      color: ShadcnThemeConfig.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Take Photo',
                    style: theme.textTheme.p.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Required',
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // AI Preview Box
  Widget _buildAIPreviewBox(ShadThemeData theme) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ShadcnThemeConfig.borderColor,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ShadcnThemeConfig.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 32,
              color: ShadcnThemeConfig.accentColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'AI Preview',
            style: theme.textTheme.p.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: ShadcnThemeConfig.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: ShadcnThemeConfig.warningColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Category Dropdown
  Widget _buildCategoryDropdown(ShadThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ShadcnThemeConfig.borderColor,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: DropdownButton<String>(
          value: _selectedCategory,
          hint: Row(
            children: [
              Icon(
                Icons.category_rounded,
                color: ShadcnThemeConfig.primaryColor,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                'Select issue type',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: ShadcnThemeConfig.textSecondaryColor,
                ),
              ),
            ],
          ),
          isExpanded: true,
          underline: const SizedBox(),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: ShadcnThemeConfig.primaryColor,
            size: 24,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: 8,
          menuMaxHeight: 400,
          itemHeight: null, // Allow custom height
          items: [
            for (int i = 0; i < _categories.length; i++)
              DropdownMenuItem<String>(
                value: _categories[i]['value'] as String, // Use database value
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (_categories[i]['color'] as Color)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _categories[i]['icon'] as IconData,
                              size: 20,
                              color: _categories[i]['color'] as Color,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            _categories[i]['name'] as String, // Display name
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: ShadcnThemeConfig.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < _categories.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: ShadcnThemeConfig.borderColor,
                        ),
                      ),
                  ],
                ),
              ),
          ],
          selectedItemBuilder: (context) => _categories.map((category) {
            return Row(
              children: [
                Icon(
                  Icons.category_rounded,
                  color: ShadcnThemeConfig.primaryColor,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  category['name'] as String, // Display name when selected
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: ShadcnThemeConfig.textPrimaryColor,
                  ),
                ),
              ],
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedCategory = value),
        ),
      ),
    );
  }

  Widget _buildLocationCard(ShadThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ShadcnThemeConfig.borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ShadcnThemeConfig.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: ShadcnThemeConfig.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Location',
                  style: theme.textTheme.p.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _address ?? 'Getting location...',
                  style: theme.textTheme.muted.copyWith(
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _getCurrentLocation,
            child: Text(
              'Change',
              style: TextStyle(
                color: ShadcnThemeConfig.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ShadcnThemeConfig.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: ShadcnThemeConfig.primaryColor,
                  ),
                ),
                title: const Text('Camera',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ShadcnThemeConfig.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: ShadcnThemeConfig.secondaryColor,
                  ),
                ),
                title: const Text('Gallery',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

enum ImageSource {
  camera,
  gallery,
}
