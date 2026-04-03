import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/shadcn_theme.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _userReports = [];
  int _totalUpvotes = 0;
  int _resolvedReports = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final supabase = Supabase.instance.client;

      // Fetch user data
      final userResponse = await supabase
          .from('users')
          .select()
          .eq('id', widget.userId)
          .single();

      // Fetch user's reports
      final reportsResponse = await supabase
          .from('reports')
          .select()
          .eq('user_id', widget.userId)
          .order('created_at', ascending: false);

      // Calculate stats
      int totalUpvotes = 0;
      int resolvedCount = 0;

      for (var report in reportsResponse) {
        totalUpvotes += (report['upvotes'] as int?) ?? 0;
        if (report['status'] == 'resolved') {
          resolvedCount++;
        }
      }

      setState(() {
        _userData = userResponse;
        _userReports = List<Map<String, dynamic>>.from(reportsResponse);
        _totalUpvotes = totalUpvotes;
        _resolvedReports = resolvedCount;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('User Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: ShadcnThemeConfig.primaryColor,
              ),
            )
          : _userData == null
              ? Center(
                  child: Text(
                    'User not found',
                    style: theme.textTheme.h3,
                  ),
                )
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.only(bottom: 100), // Space for nav bar
                  child: Column(
                    children: [
                      // Profile Header
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ShadcnThemeConfig.borderColor,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: ShadcnThemeConfig.primaryColor
                                  .withOpacity(0.1),
                              backgroundImage:
                                  _userData!['avatar_url'] != null &&
                                          _userData!['avatar_url']
                                              .toString()
                                              .isNotEmpty
                                      ? NetworkImage(_userData!['avatar_url'])
                                      : null,
                              child: _userData!['avatar_url'] == null ||
                                      _userData!['avatar_url']
                                          .toString()
                                          .isEmpty
                                  ? Text(
                                      _userData!['name'][0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: ShadcnThemeConfig.primaryColor,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            // Name
                            Text(
                              _userData!['name'],
                              style: theme.textTheme.h2.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // City
                            if (_userData!['city'] != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 16,
                                    color: ShadcnThemeConfig.textSecondaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _userData!['city'],
                                    style: theme.textTheme.muted,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      // Stats
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ShadcnThemeConfig.borderColor,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard(
                              'Reports',
                              _userReports.length.toString(),
                              Icons.report_outlined,
                              theme,
                            ),
                            _buildStatCard(
                              'Upvotes',
                              _totalUpvotes.toString(),
                              Icons.thumb_up_outlined,
                              theme,
                            ),
                            _buildStatCard(
                              'Resolved',
                              _resolvedReports.toString(),
                              Icons.check_circle_outline,
                              theme,
                            ),
                            _buildStatCard(
                              'Points',
                              (_userData!['points'] ?? 0).toString(),
                              Icons.star_outline,
                              theme,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Recent Reports
                      if (_userReports.isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ShadcnThemeConfig.borderColor,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recent Reports',
                                style: theme.textTheme.h4.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _userReports.length > 5
                                    ? 5
                                    : _userReports.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 24),
                                itemBuilder: (context, index) {
                                  final report = _userReports[index];
                                  return _buildReportItem(report, theme);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    ShadThemeData theme,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ShadcnThemeConfig.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: ShadcnThemeConfig.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.h3.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.muted.copyWith(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildReportItem(Map<String, dynamic> report, ShadThemeData theme) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            report['image_url'],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: ShadcnThemeConfig.backgroundColor,
                child: Icon(
                  Icons.broken_image_rounded,
                  color: ShadcnThemeConfig.textSecondaryColor,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report['title'] ?? report['category'],
                style: theme.textTheme.p.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.thumb_up_outlined,
                    size: 14,
                    color: ShadcnThemeConfig.textSecondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${report['upvotes'] ?? 0}',
                    style: theme.textTheme.muted.copyWith(fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      report['status'],
                      style: TextStyle(
                        fontSize: 11,
                        color: _getStatusColor(report['status']),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'reported':
      case 'acknowledged':
        return ShadcnThemeConfig.warningColor;
      case 'in_progress':
      case 'in progress':
        return ShadcnThemeConfig.primaryColor;
      case 'resolved':
        return ShadcnThemeConfig.successColor;
      case 'rejected':
        return ShadcnThemeConfig.errorColor;
      default:
        return ShadcnThemeConfig.textSecondaryColor;
    }
  }
}
