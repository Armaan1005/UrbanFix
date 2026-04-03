import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/shadcn_theme.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';

class ShadcnLeaderboardScreen extends StatefulWidget {
  const ShadcnLeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<ShadcnLeaderboardScreen> createState() =>
      _ShadcnLeaderboardScreenState();
}

class _ShadcnLeaderboardScreenState extends State<ShadcnLeaderboardScreen>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;

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
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    try {
      // Get all users with their report counts
      final usersResponse = await _supabase
          .from('users')
          .select('id, name, email, city')
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> leaderboardData = [];

      for (var user in usersResponse) {
        // Get user's reports
        final reportsResponse = await _supabase
            .from('reports')
            .select('status')
            .eq('user_id', user['id']);

        final reports = reportsResponse as List;
        final reported = reports.length;
        final resolved = reports.where((r) => r['status'] == 'resolved').length;
        final points = (reported * 10) + (resolved * 50);

        leaderboardData.add({
          'id': user['id'],
          'name': user['name'] ?? 'User',
          'email': user['email'],
          'city': user['city'] ?? 'Unknown',
          'reportsCount': reported,
          'resolvedCount': resolved,
          'points': points,
        });
      }

      // Sort by points
      leaderboardData.sort((a, b) => b['points'].compareTo(a['points']));

      if (mounted) {
        setState(() {
          _leaderboard = leaderboardData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading leaderboard: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
            // Collapsing App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: ShadcnThemeConfig.textPrimaryColor),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Row(
                  children: [
                    Text(
                      'Leaderboard',
                      style: theme.textTheme.h2.copyWith(
                        fontSize: 24,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.emoji_events_rounded,
                      color: ShadcnThemeConfig.warningColor,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),

            // Content
            if (_isLoading)
              SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: ShadcnThemeConfig.primaryColor,
                  ),
                ),
              )
            else if (_leaderboard.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color:
                              ShadcnThemeConfig.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.leaderboard_outlined,
                          size: 64,
                          color: ShadcnThemeConfig.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No data available',
                        style: theme.textTheme.h3,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to contribute!',
                        style: theme.textTheme.muted,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Top 3 Podium
                    if (_leaderboard.length >= 3) _buildPodium(theme),

                    const SizedBox(height: 24),

                    // Rest of the list
                    if (_leaderboard.length > 3)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: List.generate(
                            _leaderboard.length - 3,
                            (index) => _buildLeaderboardItem(
                              theme,
                              _leaderboard[index + 3],
                              index + 4,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium(ShadThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (_leaderboard.length >= 2)
            _buildPodiumItem(
              theme,
              _leaderboard[1],
              2,
              140,
              ShadcnThemeConfig.textSecondaryColor,
              Colors.grey.shade300,
            ),

          const SizedBox(width: 12),

          // 1st Place
          _buildPodiumItem(
            theme,
            _leaderboard[0],
            1,
            180,
            ShadcnThemeConfig.warningColor,
            ShadcnThemeConfig.warningColor.withOpacity(0.2),
          ),

          const SizedBox(width: 12),

          // 3rd Place
          if (_leaderboard.length >= 3)
            _buildPodiumItem(
              theme,
              _leaderboard[2],
              3,
              120,
              Colors.brown.shade400,
              Colors.brown.shade100,
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    ShadThemeData theme,
    Map<String, dynamic> userData,
    int rank,
    double height,
    Color color,
    Color bgColor,
  ) {
    final name = userData['name'] ?? 'User';
    final points = userData['points'] ?? 0;

    IconData crownIcon = Icons.emoji_events_rounded;

    return Column(
      children: [
        // Crown
        Icon(
          crownIcon,
          color: color,
          size: rank == 1 ? 48 : 36,
        ),

        const SizedBox(height: 8),

        // Avatar
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.5)],
            ),
          ),
          child: CircleAvatar(
            radius: rank == 1 ? 40 : 32,
            backgroundColor: Colors.white,
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                fontSize: rank == 1 ? 28 : 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Name
        SizedBox(
          width: 100,
          child: Text(
            name,
            style: theme.textTheme.p.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(height: 4),

        // Points
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$points pts',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Podium
        Container(
          width: 100,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: rank == 1 ? 36 : 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    ShadThemeData theme,
    Map<String, dynamic> userData,
    int rank,
  ) {
    final name = userData['name'] ?? 'User';
    final points = userData['points'] ?? 0;
    final reportsCount = userData['reportsCount'] ?? 0;
    final city = userData['city'] ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ShadcnThemeConfig.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ShadcnThemeConfig.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ShadcnThemeConfig.primaryColor,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: ShadcnThemeConfig.primaryColor.withOpacity(0.1),
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ShadcnThemeConfig.primaryColor,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.p.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: ShadcnThemeConfig.textMutedColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      city,
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.report_outlined,
                      size: 12,
                      color: ShadcnThemeConfig.textMutedColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$reportsCount reports',
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$points',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ShadcnThemeConfig.primaryColor,
                ),
              ),
              Text(
                'points',
                style: theme.textTheme.muted.copyWith(
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
