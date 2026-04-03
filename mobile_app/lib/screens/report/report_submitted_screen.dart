import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:confetti/confetti.dart';
import '../../config/shadcn_theme.dart';

class ReportSubmittedScreen extends StatefulWidget {
  final String reportId;
  final String issueNumber;

  const ReportSubmittedScreen({
    Key? key,
    required this.reportId,
    required this.issueNumber,
  }) : super(key: key);

  @override
  State<ReportSubmittedScreen> createState() => _ReportSubmittedScreenState();
}

class _ReportSubmittedScreenState extends State<ReportSubmittedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Start animations
    _animationController.forward();
    _confettiController.play();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: [
                ShadcnThemeConfig.primaryColor,
                ShadcnThemeConfig.secondaryColor,
                ShadcnThemeConfig.accentColor,
                ShadcnThemeConfig.successColor,
              ],
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success Icon
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: ShadcnThemeConfig.successColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: ShadcnThemeConfig.successColor
                                  .withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Success Message
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Report Submitted!',
                            style: theme.textTheme.h1.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: ShadcnThemeConfig.primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Thank you for making your community better',
                            style: theme.textTheme.p.copyWith(
                              fontSize: 16,
                              color: ShadcnThemeConfig.textSecondaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Issue Number Card
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Issue Number',
                              style: theme.textTheme.small.copyWith(
                                fontSize: 14,
                                color: ShadcnThemeConfig.textSecondaryColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: ShadcnThemeConfig.primaryColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: ShadcnThemeConfig.primaryColor
                                      .withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                widget.issueNumber,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: ShadcnThemeConfig.primaryColor,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Track your report with this number',
                              style: theme.textTheme.muted.copyWith(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Action Buttons
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // View Report Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Go to feed, then immediately push report
                                // This sets up the navigation stack: feed -> report
                                context.go('/feed');
                                Future.microtask(() {
                                  context.push('/report/${widget.reportId}');
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ShadcnThemeConfig.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                  horizontal: 32,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.visibility_rounded,
                                      size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    'View Report',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Go to Feed Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                context.go('/feed');
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ShadcnThemeConfig.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                  horizontal: 32,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: BorderSide(
                                  color: ShadcnThemeConfig.primaryColor,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.feed_rounded, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Go to Community Feed',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Back to Home
                          TextButton(
                            onPressed: () {
                              context.go('/home');
                            },
                            child: Text(
                              'Back to Home',
                              style: TextStyle(
                                fontSize: 14,
                                color: ShadcnThemeConfig.textSecondaryColor,
                              ),
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
        ],
      ),
    );
  }
}
