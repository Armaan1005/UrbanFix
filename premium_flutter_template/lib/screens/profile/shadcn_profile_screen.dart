import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../config/shadcn_theme.dart';

class ShadcnProfileScreen extends StatefulWidget {
  const ShadcnProfileScreen({super.key});

  @override
  State<ShadcnProfileScreen> createState() => _ShadcnProfileScreenState();
}

class _ShadcnProfileScreenState extends State<ShadcnProfileScreen>
    with SingleTickerProviderStateMixin {
  // Mock Data
  final String _mockName = 'Alex Templator';
  final String _mockCity = 'San Francisco';

  final int _issuesReported = 15;
  final int _issuesResolved = 8;
  final int _points = 550;
  final int _level = 2;
  final int _streak = 12; // Days active
  final int _rank = 42; // Leaderboard position
  bool _isLoadingStats = true;

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
    _loadUserStats();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserStats() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isLoadingStats = false;
      });
    }
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
            // Premium Gradient Header
            SliverAppBar(
              expandedHeight: 320,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: ShadcnThemeConfig.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ShadcnThemeConfig.primaryColor,
                        ShadcnThemeConfig.secondaryColor,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // Avatar with animated gradient border
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                ShadcnThemeConfig.accentColor,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Text(
                              _mockName[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: ShadcnThemeConfig.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Name
                        Text(
                          _mockName,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Location
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _mockCity,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Level, Points & Rank Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Level Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.stars_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Level $_level',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Points Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: ShadcnThemeConfig.warningColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: ShadcnThemeConfig.warningColor
                                        .withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.bolt_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$_points pts',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                // Share Profile Button
                IconButton(
                  icon: const Icon(Icons.share_rounded, color: Colors.white),
                  onPressed: () {
                    // TODO: Implement share functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share feature coming soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Quick Stats Row (Streak & Rank)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildQuickStatCard(
                            theme,
                            '🔥 $_streak Day Streak',
                            'Keep it going!',
                            ShadcnThemeConfig.errorColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickStatCard(
                            theme,
                            '🏆 Rank #$_rank',
                            'Top contributor',
                            ShadcnThemeConfig.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Progress to Next Level
                  _buildProgressCard(theme),

                  const SizedBox(height: 16),

                  // Impact Metrics
                  _buildImpactMetrics(theme),

                  const SizedBox(height: 16),

                  // Stats Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            theme,
                            'Issues Reported',
                            _issuesReported.toString(),
                            Icons.report_problem_outlined,
                            ShadcnThemeConfig.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            theme,
                            'Issues Resolved',
                            _issuesResolved.toString(),
                            Icons.check_circle_outline_rounded,
                            ShadcnThemeConfig.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Achievements Section (Enhanced)
                  _buildAchievementsSection(theme),

                  const SizedBox(height: 24),

                  // Recent Activity Timeline
                  _buildActivityTimeline(theme),

                  const SizedBox(height: 24),

                  // Menu Items
                  _buildMenuSection(theme, context),

                  const SizedBox(height: 24),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: InkWell(
                      onTap: () {
                        context.go('/login');
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ShadcnThemeConfig.errorColor.withOpacity(0.1),
                              ShadcnThemeConfig.errorColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ShadcnThemeConfig.errorColor.withOpacity(
                              0.3,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: ShadcnThemeConfig.errorColor,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ShadcnThemeConfig.errorColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatCard(
    ShadThemeData theme,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.muted.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildImpactMetrics(ShadThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ShadcnThemeConfig.successColor.withOpacity(0.1),
            ShadcnThemeConfig.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ShadcnThemeConfig.successColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.eco_rounded,
                color: ShadcnThemeConfig.successColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Your Impact',
                style: theme.textTheme.h4.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildImpactItem(
                theme,
                '${_issuesResolved * 5}',
                'Trees Saved',
                Icons.park_outlined,
              ),
              _buildImpactItem(
                theme,
                '${_issuesReported * 10}',
                'People Helped',
                Icons.people_outline,
              ),
              _buildImpactItem(
                theme,
                '${_issuesResolved * 2}kg',
                'CO₂ Reduced',
                Icons.cloud_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpactItem(
    ShadThemeData theme,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: ShadcnThemeConfig.successColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ShadcnThemeConfig.successColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.muted.copyWith(fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressCard(ShadThemeData theme) {
    final nextLevelPoints = _level * 500;
    final currentLevelPoints = (_level - 1) * 500;
    final progress =
        (_points - currentLevelPoints) / (nextLevelPoints - currentLevelPoints);
    final pointsToGo = nextLevelPoints - _points;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ShadcnThemeConfig.primaryColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                'Progress to Level ${_level + 1}',
                style: theme.textTheme.h4.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: ShadcnThemeConfig.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$pointsToGo pts to go',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: ShadcnThemeConfig.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar with Gradient
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: ShadcnThemeConfig.dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ShadcnThemeConfig.primaryColor,
                        ShadcnThemeConfig.secondaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_points points',
                style: theme.textTheme.small.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ShadcnThemeConfig.textSecondaryColor,
                ),
              ),
              Text(
                '$nextLevelPoints points',
                style: theme.textTheme.small.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ShadcnThemeConfig.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ShadThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.small.copyWith(
              fontSize: 11,
              color: ShadcnThemeConfig.textSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(ShadThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: theme.textTheme.h3.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_getUnlockedCount()}/6 Unlocked',
                style: theme.textTheme.muted.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            children: [
              _buildAchievementCard(
                theme,
                'First Reporter',
                'Reported your first issue',
                Icons.flag_outlined,
                ShadcnThemeConfig.primaryColor,
                _issuesReported >= 1,
                _issuesReported >= 1 ? 1.0 : 0.0,
              ),
              _buildAchievementCard(
                theme,
                'Community Hero',
                'Helped resolve 10+ issues',
                Icons.people_outline_rounded,
                ShadcnThemeConfig.secondaryColor,
                _issuesResolved >= 10,
                _issuesResolved / 10,
              ),
              _buildAchievementCard(
                theme,
                'Popular Voice',
                'Received 100+ upvotes',
                Icons.thumb_up_outlined,
                ShadcnThemeConfig.accentColor,
                false,
                0.3,
              ),
              _buildAchievementCard(
                theme,
                'Speed Demon',
                'Quick response time',
                Icons.flash_on_outlined,
                ShadcnThemeConfig.warningColor,
                false,
                0.6,
              ),
              _buildAchievementCard(
                theme,
                'Eco Warrior',
                'Saved 50+ trees',
                Icons.eco_outlined,
                ShadcnThemeConfig.successColor,
                _issuesResolved >= 10,
                _issuesResolved / 10,
              ),
              _buildAchievementCard(
                theme,
                'Streak Master',
                '30 day streak',
                Icons.local_fire_department_outlined,
                ShadcnThemeConfig.errorColor,
                _streak >= 30,
                _streak / 30,
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _getUnlockedCount() {
    int count = 0;
    if (_issuesReported >= 1) count++;
    if (_issuesResolved >= 10) count++;
    if (_streak >= 30) count++;
    return count;
  }

  Widget _buildAchievementCard(
    ShadThemeData theme,
    String title,
    String description,
    IconData icon,
    Color color,
    bool unlocked,
    double progress,
  ) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            unlocked ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              unlocked ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
          width: 2,
        ),
        boxShadow:
            unlocked
                ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
                : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:
                  unlocked
                      ? color.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: unlocked ? color : Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.small.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: unlocked ? color : Colors.grey,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: theme.textTheme.muted.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!unlocked) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityTimeline(ShadThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Recent Activity',
            style: theme.textTheme.h3.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ShadcnThemeConfig.borderColor),
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
              _buildTimelineItem(
                theme,
                Icons.check_circle,
                'Issue Resolved',
                'Streetlight fixed on MG Road',
                '2 hours ago',
                ShadcnThemeConfig.successColor,
              ),
              const SizedBox(height: 16),
              _buildTimelineItem(
                theme,
                Icons.report_outlined,
                'New Report',
                'Reported pothole on Anna Salai',
                '1 day ago',
                ShadcnThemeConfig.primaryColor,
              ),
              const SizedBox(height: 16),
              _buildTimelineItem(
                theme,
                Icons.thumb_up_outlined,
                'Upvote Received',
                'Your report got 5 upvotes',
                '2 days ago',
                ShadcnThemeConfig.accentColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    ShadThemeData theme,
    IconData icon,
    String title,
    String description,
    String time,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.p.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.muted.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        Text(time, style: theme.textTheme.muted.copyWith(fontSize: 11)),
      ],
    );
  }

  Widget _buildMenuSection(ShadThemeData theme, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ShadcnThemeConfig.borderColor),
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
          _buildMenuItem(
            theme,
            Icons.leaderboard_outlined,
            'Leaderboard',
            'See top contributors',
            () => context.push('/leaderboard'),
          ),
          _buildDivider(),
          _buildMenuItem(
            theme,
            Icons.history_outlined,
            'My Reports',
            'View your submissions',
            () => context.push('/my-reports'),
          ),
          _buildDivider(),
          _buildMenuItem(
            theme,
            Icons.bookmark_outline,
            'Saved Reports',
            'Your bookmarked issues',
            () => context.push('/saved-reports'),
          ),
          _buildDivider(),
          _buildMenuItem(
            theme,
            Icons.notifications_outlined,
            'Notifications',
            'Updates and alerts',
            () => context.push('/notifications'),
          ),
          _buildDivider(),
          _buildMenuItem(
            theme,
            Icons.help_outline,
            'Help & Support',
            'Get assistance',
            () => context.push('/help-support'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    ShadThemeData theme,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ShadcnThemeConfig.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: ShadcnThemeConfig.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.p.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.muted.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: ShadcnThemeConfig.textMutedColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: ShadcnThemeConfig.dividerColor,
    );
  }

  Widget _buildNotLoggedIn(BuildContext context, ShadThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ShadcnThemeConfig.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_off_outlined,
              size: 64,
              color: ShadcnThemeConfig.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text('Not logged in', style: theme.textTheme.h3),
          const SizedBox(height: 8),
          Text(
            'Please login to view your profile',
            style: theme.textTheme.muted,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ShadcnThemeConfig.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
