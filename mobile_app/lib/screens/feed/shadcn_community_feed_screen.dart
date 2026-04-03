import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../config/shadcn_theme.dart';
import '../../providers/report_provider.dart';
import '../../widgets/shadcn_report_card.dart';
import '../../services/location_service.dart';

class ShadcnCommunityFeedScreen extends StatefulWidget {
  const ShadcnCommunityFeedScreen({Key? key}) : super(key: key);

  @override
  State<ShadcnCommunityFeedScreen> createState() =>
      _ShadcnCommunityFeedScreenState();
}

class _ShadcnCommunityFeedScreenState extends State<ShadcnCommunityFeedScreen>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'all';
  String _selectedSort = 'recent'; // recent, upvotes, nearest

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _loadFeed();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadFeed() async {
    await context.read<ReportProvider>().fetchAllReports();
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
                  'Community Feed',
                  style: theme.textTheme.h2.copyWith(
                    fontSize: 24,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),

            // Filter Tabs
            SliverPersistentHeader(
              pinned: true,
              delegate: _FilterTabsDelegate(
                selectedFilter: _selectedFilter,
                child: Container(
                  color: theme.colorScheme.background,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          context,
                          'All',
                          'all',
                          Icons.grid_view_rounded,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          'Pending',
                          'pending',
                          Icons.error_outline_rounded,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          'In Progress',
                          'in_progress',
                          Icons.construction_outlined,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          'Resolved',
                          'resolved',
                          Icons.check_circle_outline_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Sort Options
            SliverToBoxAdapter(
              child: Container(
                color: theme.colorScheme.background,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_rounded,
                      size: 18,
                      color: ShadcnThemeConfig.textSecondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sort by:',
                      style: theme.textTheme.small.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ShadcnThemeConfig.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildSortChip(
                              context,
                              'Recent',
                              'recent',
                              Icons.access_time_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildSortChip(
                              context,
                              'Most Upvoted',
                              'upvotes',
                              Icons.thumb_up_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildSortChip(
                              context,
                              'Nearest',
                              'nearest',
                              Icons.location_on_rounded,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Consumer<ReportProvider>(
              builder: (context, reportProvider, child) {
                if (reportProvider.isLoading) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading reports...',
                            style: theme.textTheme.muted,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Filter reports based on selected tab
                // Map UI filter names to database status values
                String getStatusFilter(String filter) {
                  switch (filter) {
                    case 'pending':
                      return 'reported';
                    case 'in_progress':
                      return 'in_progress';
                    case 'resolved':
                      return 'resolved';
                    default:
                      return filter;
                  }
                }

                final filteredReports = _selectedFilter == 'all'
                    ? reportProvider.reports
                    : reportProvider.reports.where((report) {
                        final reportStatus = report.status.toLowerCase().trim();
                        final filterStatus = getStatusFilter(_selectedFilter);
                        return reportStatus == filterStatus;
                      }).toList();

                // Apply sorting
                final sortedReports = List.from(filteredReports);

                // For nearest sorting, we need to wait for location
                if (_selectedSort == 'nearest') {
                  // This will be handled asynchronously
                  // For now, show reports in original order while location loads
                  _sortByDistance(sortedReports);
                } else {
                  // Synchronous sorting
                  switch (_selectedSort) {
                    case 'upvotes':
                      sortedReports
                          .sort((a, b) => b.upvotes.compareTo(a.upvotes));
                      break;
                    case 'recent':
                    default:
                      sortedReports
                          .sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      break;
                  }
                }

                if (sortedReports.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.muted,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.feed_outlined,
                              size: 64,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No reports found',
                            style: theme.textTheme.h3.copyWith(
                              color: theme.colorScheme.foreground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedFilter == 'all'
                                ? 'Be the first to report an issue!'
                                : 'No ${_selectedFilter.replaceAll('_', ' ')} reports',
                            style: theme.textTheme.muted,
                          ),
                          const SizedBox(height: 24),
                          ShadButton(
                            onPressed: () => context.go('/report'),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.add_rounded,
                                    size: 20, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Create Report',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final report = sortedReports[index];
                        return ShadcnReportCard(
                          report: report,
                          onTap: () {
                            context.push('/report/${report.reportId}');
                          },
                          onUpvote: () async {
                            await reportProvider.toggleUpvote(report.reportId);
                          },
                        );
                      },
                      childCount: sortedReports.length,
                    ),
                  ),
                );
              },
            ),

            // Bottom padding for floating nav bar
            const SliverPadding(padding: EdgeInsets.only(bottom: 110)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () {
        print('Filter tapped: $value'); // Debug print
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? ShadcnThemeConfig.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ShadcnThemeConfig.primaryColor
                : ShadcnThemeConfig.borderColor,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : ShadcnThemeConfig.textPrimaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              overflow: TextOverflow.visible,
              maxLines: 1,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : ShadcnThemeConfig.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final isSelected = _selectedSort == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSort = value;
        });
        // Trigger re-sort
        _loadFeed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? ShadcnThemeConfig.primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? ShadcnThemeConfig.primaryColor
                : ShadcnThemeConfig.borderColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: !isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? ShadcnThemeConfig.primaryColor
                  : ShadcnThemeConfig.textSecondaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? ShadcnThemeConfig.primaryColor
                    : ShadcnThemeConfig.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sortByDistance(List reports) async {
    final locationService = LocationService();
    final userPosition = await locationService.getCurrentLocation();

    if (userPosition == null) {
      // If we can't get location, keep original order
      print('Could not get user location for sorting');
      return;
    }

    // Sort by distance from user
    reports.sort((a, b) {
      final distanceA = locationService.calculateDistance(
        userPosition.latitude,
        userPosition.longitude,
        a.location.latitude,
        a.location.longitude,
      );
      final distanceB = locationService.calculateDistance(
        userPosition.latitude,
        userPosition.longitude,
        b.location.latitude,
        b.location.longitude,
      );
      return distanceA.compareTo(distanceB);
    });
  }
}

// Custom delegate for pinned filter tabs
class _FilterTabsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final String selectedFilter;

  _FilterTabsDelegate({
    required this.child,
    required this.selectedFilter,
  });

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_FilterTabsDelegate oldDelegate) {
    return oldDelegate.selectedFilter != selectedFilter;
  }
}
