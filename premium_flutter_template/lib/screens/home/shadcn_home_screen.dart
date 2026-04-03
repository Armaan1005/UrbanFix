import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../config/shadcn_theme.dart';

class ShadcnHomeScreen extends StatefulWidget {
  const ShadcnHomeScreen({super.key});

  @override
  State<ShadcnHomeScreen> createState() => _ShadcnHomeScreenState();
}

class _ShadcnHomeScreenState extends State<ShadcnHomeScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

                        GestureDetector(
                          onTap = () => context.push('/notifications'),
                          child = Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.notifications_outlined,
                              color: ShadcnThemeConfig.primaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height = 20),
                    // Location
                    Row(
                      children = [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: ShadcnThemeConfig.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'San Francisco, CA',
                            style: theme.textTheme.small.copyWith(
                              color: ShadcnThemeConfig.textSecondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height = 20),

              // Premium Stats Cards
              Padding(
                padding = const EdgeInsets.symmetric(horizontal: 20),
                child = Row(
                  children: [
                    Expanded(
                      child: _buildPremiumStatCard(
                        'Active',
                        '12',
                        'Issues nearby',
                        ShadcnThemeConfig.errorColor,
                        Icons.error_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPremiumStatCard(
                        'Resolved',
                        '45',
                        'This month',
                        ShadcnThemeConfig.successColor,
                        Icons.check_circle_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPremiumStatCard(
                        'In Progress',
                        '8',
                        'Active work',
                        ShadcnThemeConfig.warningColor,
                        Icons.construction_rounded,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height = 20),

              // Section Header
              Padding(
                padding = const EdgeInsets.symmetric(horizontal: 20),
                child = Row(
                  children: [
                    Text(
                      'Nearby Issues',
                      style: theme.textTheme.h3.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go('/feed'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              color: ShadcnThemeConfig.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: ShadcnThemeConfig.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height = 12),

              // Map Placeholder with Premium Styling
              Expanded(
                child = Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ShadcnThemeConfig.primaryColor.withOpacity(0.1),
                          Colors.white,
                        ],
                      ),
                      border: Border.all(
                        color: ShadcnThemeConfig.primaryColor.withOpacity(0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              ShadcnThemeConfig.primaryColor.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 48,
                            color: ShadcnThemeConfig.primaryColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Map View Placeholder',
                            style: theme.textTheme.h4.copyWith(
                              color: ShadcnThemeConfig.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height = 110),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding = const EdgeInsets.only(bottom: 80), // Above the nav bar
        child = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ShadcnThemeConfig.primaryColor,
                ShadcnThemeConfig.secondaryColor,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: ShadcnThemeConfig.primaryColor.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/report'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Report Issue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildPremiumStatCard(
    String label,
    String value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon in top-right corner
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          // Label
          Text(
            label,
            style: theme.textTheme.small.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ShadcnThemeConfig.textSecondaryColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          // Subtitle
          Text(
            subtitle,
            style: theme.textTheme.muted.copyWith(
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // Map view removed for template
}
