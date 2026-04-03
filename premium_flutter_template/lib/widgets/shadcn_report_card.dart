import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../config/shadcn_theme.dart';
import '../models/report.dart';

class ShadcnReportCard extends StatefulWidget {
  final Report report;
  final VoidCallback? onTap;
  final VoidCallback? onUpvote;

  const ShadcnReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.onUpvote,
  });

  @override
  State<ShadcnReportCard> createState() => _ShadcnReportCardState();
}

class _ShadcnReportCardState extends State<ShadcnReportCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (widget.report.status.toLowerCase()) {
      case 'reported':
      case 'pending':
        return ShadcnThemeConfig.errorColor;
      case 'acknowledged':
        return ShadcnThemeConfig.warningColor;
      case 'in_progress':
        return ShadcnThemeConfig.primaryColor;
      case 'resolved':
        return ShadcnThemeConfig.successColor;
      default:
        return ShadcnThemeConfig.textMutedColor;
    }
  }

  String _getStatusLabel() {
    switch (widget.report.status.toLowerCase()) {
      case 'reported':
      case 'pending':
        return 'Pending';
      case 'acknowledged':
        return 'Acknowledged';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      default:
        return widget.report.status;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.report.status.toLowerCase()) {
      case 'reported':
      case 'pending':
        return Icons.error_outline_rounded;
      case 'acknowledged':
        return Icons.visibility_outlined;
      case 'in_progress':
        return Icons.construction_outlined;
      case 'resolved':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.info_outline;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _animationController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with overlay gradient
                if (widget.report.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        // Image
                        Image.network(
                          widget.report.imageUrl,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: double.infinity,
                              height: 220,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.muted,
                                    theme.colorScheme.muted.withOpacity(0.5),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                    strokeWidth: 3,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint(
                              'Image load error for ${widget.report.imageUrl}: $error',
                            );
                            return Container(
                              width: double.infinity,
                              height: 220,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.muted,
                                    theme.colorScheme.muted.withOpacity(0.7),
                                  ],
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_rounded,
                                    size: 56,
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Image unavailable',
                                    style: theme.textTheme.muted,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // Gradient overlay at bottom for better text readability
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Status badge with icon
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(),
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getStatusLabel(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Issue number and category
                      Row(
                        children: [
                          // Category badge
                          Flexible(
                            child: ShadBadge.secondary(
                              child: Text(
                                _capitalizeFirst(widget.report.category),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.secondaryForeground,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Title
                      Text(
                        widget.report.title,
                        style: theme.textTheme.h4.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.foreground,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Description
                      if (widget.report.description != null &&
                          widget.report.description!.isNotEmpty)
                        Text(
                          widget.report.description!,
                          style: theme.textTheme.p.copyWith(
                            fontSize: 13,
                            height: 1.5,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 12),

                      // Location with icon
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.report.location.address,
                              style: theme.textTheme.muted.copyWith(
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Divider
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.border,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Footer with actions
                      Row(
                        children: [
                          // Upvote button
                          InkWell(
                            onTap: widget.onUpvote,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    widget.report.upvotedByUser
                                        ? theme.colorScheme.primary.withOpacity(
                                          0.1,
                                        )
                                        : Colors.transparent,
                                border: Border.all(
                                  color:
                                      widget.report.upvotedByUser
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.border,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.report.upvotedByUser
                                        ? Icons.thumb_up_rounded
                                        : Icons.thumb_up_outlined,
                                    size: 16,
                                    color:
                                        widget.report.upvotedByUser
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.mutedForeground,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${widget.report.upvotes}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          widget.report.upvotedByUser
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.foreground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Comments indicator
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.comment_outlined,
                                size: 16,
                                color: theme.colorScheme.mutedForeground,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.report.comments}',
                                style: theme.textTheme.muted.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // Time ago
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: theme.colorScheme.mutedForeground,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                timeago.format(widget.report.createdAt),
                                style: theme.textTheme.muted.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
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
