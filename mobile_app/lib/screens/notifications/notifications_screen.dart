import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../config/shadcn_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Sample notifications data
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Report Status Updated',
      'message': 'Your pothole report #12345 is now in progress',
      'time': '2 hours ago',
      'icon': Icons.construction,
      'color': ShadcnThemeConfig.warningColor,
      'isRead': false,
    },
    {
      'id': '2',
      'title': 'Report Resolved',
      'message': 'Garbage collection issue #12340 has been resolved',
      'time': '5 hours ago',
      'icon': Icons.check_circle,
      'color': ShadcnThemeConfig.successColor,
      'isRead': false,
    },
    {
      'id': '3',
      'title': 'New Update',
      'message': 'UrbanFix now supports voice reporting!',
      'time': '1 day ago',
      'icon': Icons.campaign,
      'color': ShadcnThemeConfig.primaryColor,
      'isRead': true,
    },
    {
      'id': '4',
      'title': 'Achievement Unlocked',
      'message': 'You\'ve earned the "Civic Hero" badge!',
      'time': '2 days ago',
      'icon': Icons.emoji_events,
      'color': ShadcnThemeConfig.accentColor,
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final unreadCount = _notifications.where((n) => !n['isRead']).length;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar matching Report/Community screens
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
              title: Text(
                'Notifications',
                style: theme.textTheme.h2.copyWith(
                  fontSize: 24,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            actions: [
              if (unreadCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        for (var notification in _notifications) {
                          notification['isRead'] = true;
                        }
                      });
                    },
                    child: Text(
                      'Mark all read',
                      style: theme.textTheme.small.copyWith(
                        color: ShadcnThemeConfig.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Content
          _notifications.isEmpty
              ? SliverFillRemaining(
                  child: _buildEmptyState(theme),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final notification = _notifications[index];
                        return _buildNotificationCard(notification, theme);
                      },
                      childCount: _notifications.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ShadThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: ShadcnThemeConfig.textMutedColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: theme.textTheme.h3.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when something happens',
            style: theme.textTheme.muted.copyWith(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
      Map<String, dynamic> notification, ShadThemeData theme) {
    final isRead = notification['isRead'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead
            ? Colors.white
            : ShadcnThemeConfig.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead
              ? ShadcnThemeConfig.borderColor
              : ShadcnThemeConfig.primaryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              notification['isRead'] = true;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (notification['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notification['icon'] as IconData,
                    color: notification['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'] as String,
                              style: theme.textTheme.p.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: ShadcnThemeConfig.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['message'] as String,
                        style: theme.textTheme.muted.copyWith(
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification['time'] as String,
                        style: theme.textTheme.small.copyWith(
                          fontSize: 12,
                          color: ShadcnThemeConfig.textMutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
