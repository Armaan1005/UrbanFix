import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../config/shadcn_theme.dart';
import '../../providers/report_provider.dart';
import '../../models/report.dart';
import '../../models/comment.dart';

class ShadcnReportDetailsScreen extends StatefulWidget {
  final String reportId;

  const ShadcnReportDetailsScreen({
    Key? key,
    required this.reportId,
  }) : super(key: key);

  @override
  State<ShadcnReportDetailsScreen> createState() =>
      _ShadcnReportDetailsScreenState();
}

class _ShadcnReportDetailsScreenState extends State<ShadcnReportDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _commentController = TextEditingController();
  bool _isBookmarked = false;
  final _supabase = Supabase.instance.client;

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
    _loadReportDetails();
    _checkBookmarkStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadReportDetails() async {
    await context.read<ReportProvider>().fetchReportById(widget.reportId);
    await context.read<ReportProvider>().fetchComments(widget.reportId);
  }

  Future<void> _checkBookmarkStatus() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    try {
      final response = await _supabase
          .from('saved_reports')
          .select()
          .eq('user_id', currentUserId)
          .eq('report_id', widget.reportId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _isBookmarked = response != null;
        });
      }
    } catch (e) {
      print('Error checking bookmark status: $e');
    }
  }

  Future<void> _toggleBookmark() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to bookmark reports')),
      );
      return;
    }

    try {
      if (_isBookmarked) {
        // Remove bookmark
        await _supabase
            .from('saved_reports')
            .delete()
            .eq('user_id', currentUserId)
            .eq('report_id', widget.reportId);

        if (mounted) {
          setState(() {
            _isBookmarked = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from saved reports')),
          );
        }
      } else {
        // Add bookmark
        await _supabase.from('saved_reports').insert({
          'user_id': currentUserId,
          'report_id': widget.reportId,
        });

        if (mounted) {
          setState(() {
            _isBookmarked = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved to bookmarks')),
          );
        }
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'acknowledged':
        return ShadcnThemeConfig.warningColor;
      case 'in_progress':
        return ShadcnThemeConfig.primaryColor;
      case 'resolved':
        return ShadcnThemeConfig.successColor;
      case 'rejected':
        return ShadcnThemeConfig.errorColor;
      default:
        return ShadcnThemeConfig.textSecondaryColor;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'acknowledged':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'acknowledged':
        return Icons.schedule_rounded;
      case 'in_progress':
        return Icons.construction_rounded;
      case 'resolved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Consumer<ReportProvider>(
        builder: (context, reportProvider, child) {
          if (reportProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: ShadcnThemeConfig.primaryColor,
              ),
            );
          }

          final report = reportProvider.selectedReport;
          if (report == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: ShadcnThemeConfig.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Report not found',
                    style: theme.textTheme.h3,
                  ),
                ],
              ),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // Premium App Bar with Image
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: ShadcnThemeConfig.primaryColor,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: _isBookmarked
                              ? ShadcnThemeConfig.primaryColor
                              : ShadcnThemeConfig.textPrimaryColor,
                        ),
                        onPressed: _toggleBookmark,
                        tooltip:
                            _isBookmarked ? 'Remove from saved' : 'Save report',
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          report.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: ShadcnThemeConfig.backgroundColor,
                              child: Icon(
                                Icons.broken_image_rounded,
                                size: 64,
                                color: ShadcnThemeConfig.textSecondaryColor,
                              ),
                            );
                          },
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Container(
                    color: theme.colorScheme.background,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Location and Time Info Card
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category and Status
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Category badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ShadcnThemeConfig.secondaryColor
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: ShadcnThemeConfig.secondaryColor
                                            .withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      _capitalizeFirst(report.category),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: ShadcnThemeConfig.secondaryColor,
                                      ),
                                    ),
                                  ),
                                  // Status badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(report.status)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _getStatusColor(report.status)
                                            .withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getStatusIcon(report.status),
                                          size: 14,
                                          color: _getStatusColor(report.status),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _getStatusText(report.status),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                _getStatusColor(report.status),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Title
                              Text(
                                report.title,
                                style: theme.textTheme.h3.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Location
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 16,
                                    color: ShadcnThemeConfig.textSecondaryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      report.location.address,
                                      style: theme.textTheme.muted.copyWith(
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Time
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 16,
                                    color: ShadcnThemeConfig.textSecondaryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Reported ${timeago.format(report.createdAt)}',
                                    style: theme.textTheme.muted.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Upvote Button
                              _buildUpvoteButton(report, reportProvider, theme),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Description
                        if (report.description != null &&
                            report.description!.isNotEmpty) ...[
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Description',
                                  style: theme.textTheme.h4.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    report.description!,
                                    style: theme.textTheme.p.copyWith(
                                      fontSize: 15,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Reported By
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reported By',
                                style: theme.textTheme.h4.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () {
                                  // Navigate to user profile
                                  context.push(
                                      '/user/${report.reportedBy.userId}');
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: ShadcnThemeConfig.primaryColor
                                        .withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: ShadcnThemeConfig.primaryColor
                                          .withOpacity(0.1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: ShadcnThemeConfig
                                            .primaryColor
                                            .withOpacity(0.2),
                                        backgroundImage:
                                            report.reportedBy.avatar != null
                                                ? NetworkImage(
                                                    report.reportedBy.avatar!)
                                                : null,
                                        child: report.reportedBy.avatar == null
                                            ? Text(
                                                report.reportedBy.name[0]
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: ShadcnThemeConfig
                                                      .primaryColor,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              report.reportedBy.name,
                                              style: theme.textTheme.p.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              'Tap to view profile',
                                              style: theme.textTheme.muted
                                                  .copyWith(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: ShadcnThemeConfig
                                            .textSecondaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Comments Section
                        _buildCommentsSection(report, reportProvider, theme),

                        const SizedBox(height: 12),

                        // Timeline
                        if (report.timeline.isNotEmpty) ...[
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Timeline',
                                  style: theme.textTheme.h4.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildTimeline(report.timeline, theme),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Agency Info
                        if (report.assignedAgency != null) ...[
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assigned Agency',
                                  style: theme.textTheme.h4.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: ShadcnThemeConfig.primaryColor
                                        .withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: ShadcnThemeConfig.primaryColor
                                          .withOpacity(0.1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: ShadcnThemeConfig.primaryColor
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.business_rounded,
                                          color: ShadcnThemeConfig.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              report.assignedAgency!.name,
                                              style: theme.textTheme.p.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (report
                                                    .assignedAgency!.contact !=
                                                null)
                                              Text(
                                                report.assignedAgency!.contact!,
                                                style: theme.textTheme.muted
                                                    .copyWith(
                                                  fontSize: 13,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ), // Close SliverToBoxAdapter

                // Bottom padding for navigation bar
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: 100),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpvoteButton(
      Report report, ReportProvider reportProvider, ShadThemeData theme) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    bool isUpvoted = false;

    return StatefulBuilder(
      builder: (context, setState) {
        // Check upvote status when building
        if (currentUserId != null) {
          Supabase.instance.client
              .from('upvotes')
              .select()
              .eq('report_id', report.reportId)
              .eq('user_id', currentUserId)
              .maybeSingle()
              .then((existing) {
            if (existing != null && !isUpvoted) {
              setState(() {
                isUpvoted = true;
              });
            }
          });
        }

        return InkWell(
          onTap: () async {
            if (currentUserId == null) return;

            try {
              final supabase = Supabase.instance.client;

              // Check if already upvoted
              final existing = await supabase
                  .from('upvotes')
                  .select()
                  .eq('report_id', report.reportId)
                  .eq('user_id', currentUserId)
                  .maybeSingle();

              if (existing != null) {
                // Remove upvote
                await supabase
                    .from('upvotes')
                    .delete()
                    .eq('report_id', report.reportId)
                    .eq('user_id', currentUserId);
                setState(() {
                  isUpvoted = false;
                });
              } else {
                // Add upvote
                await supabase.from('upvotes').insert({
                  'report_id': report.reportId,
                  'user_id': currentUserId,
                });
                setState(() {
                  isUpvoted = true;
                });
              }

              // Refresh report details
              await reportProvider.fetchReportById(report.reportId);
            } catch (e) {
              print('Error toggling upvote: $e');
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isUpvoted ? ShadcnThemeConfig.successColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUpvoted
                    ? ShadcnThemeConfig.successColor
                    : ShadcnThemeConfig.primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isUpvoted ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                  color:
                      isUpvoted ? Colors.white : ShadcnThemeConfig.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${report.upvotes} Upvotes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isUpvoted
                        ? Colors.white
                        : ShadcnThemeConfig.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeline(List<TimelineEvent> timeline, ShadThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: timeline.length,
      itemBuilder: (context, index) {
        final event = timeline[index];
        final isLast = index == timeline.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getStatusColor(event.status),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor(event.status).withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    color: ShadcnThemeConfig.dividerColor,
                  ),
              ],
            ),

            const SizedBox(width: 16),

            // Event details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.message,
                      style: theme.textTheme.p.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeago.format(event.timestamp),
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommentsSection(
    Report report,
    ReportProvider reportProvider,
    ShadThemeData theme,
  ) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comments',
                style: theme.textTheme.h4.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ShadcnThemeConfig.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${reportProvider.comments.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ShadcnThemeConfig.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Comment Input
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: theme.textTheme.muted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: ShadcnThemeConfig.borderColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: ShadcnThemeConfig.borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: ShadcnThemeConfig.primaryColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 12),
              ShadButton(
                onPressed: () async {
                  if (_commentController.text.trim().isEmpty) return;

                  final success = await reportProvider.addComment(
                    report.reportId,
                    _commentController.text.trim(),
                  );

                  if (success) {
                    _commentController.clear();
                    FocusScope.of(context).unfocus();
                  }
                },
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Comments List
          if (reportProvider.isLoadingComments)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  color: ShadcnThemeConfig.primaryColor,
                ),
              ),
            )
          else if (reportProvider.comments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 48,
                      color: ShadcnThemeConfig.textSecondaryColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No comments yet',
                      style: theme.textTheme.muted,
                    ),
                    Text(
                      'Be the first to comment!',
                      style: theme.textTheme.muted.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reportProvider.comments.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final comment = reportProvider.comments[index];
                return _buildCommentItem(comment, reportProvider, theme);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(
    Comment comment,
    ReportProvider reportProvider,
    ShadThemeData theme,
  ) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isOwnComment = currentUserId == comment.userId;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 20,
          backgroundColor: ShadcnThemeConfig.primaryColor.withOpacity(0.1),
          backgroundImage:
              comment.userAvatar != null && comment.userAvatar!.isNotEmpty
                  ? NetworkImage(comment.userAvatar!)
                  : null,
          child: comment.userAvatar == null || comment.userAvatar!.isEmpty
              ? Text(
                  comment.userName[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ShadcnThemeConfig.primaryColor,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        // Comment Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    comment.userName,
                    style: theme.textTheme.p.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (isOwnComment)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: ShadcnThemeConfig.errorColor,
                      ),
                      onPressed: () async {
                        await reportProvider.deleteComment(
                          comment.id,
                          comment.reportId,
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.commentText,
                style: theme.textTheme.p.copyWith(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                timeago.format(comment.createdAt),
                style: theme.textTheme.muted.copyWith(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
