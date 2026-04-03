import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/shadcn_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
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
              title: Text(
                'Help & Support',
                style: theme.textTheme.h2.copyWith(
                  fontSize: 24,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Contact Options
                _buildSectionCard(
                  theme,
                  'Contact Us',
                  [
                    _buildContactOption(
                      theme,
                      Icons.email_outlined,
                      'Email Support',
                      'support@urbanfix.com',
                      () => _launchEmail('support@urbanfix.com'),
                    ),
                    _buildDivider(),
                    _buildContactOption(
                      theme,
                      Icons.phone_outlined,
                      'Phone Support',
                      '+1 (555) 123-4567',
                      () => _launchPhone('+15551234567'),
                    ),
                    _buildDivider(),
                    _buildContactOption(
                      theme,
                      Icons.chat_outlined,
                      'Live Chat',
                      'Chat with our team',
                      () {
                        // TODO: Implement live chat
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Live chat coming soon!'),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // FAQ Section
                _buildSectionCard(
                  theme,
                  'Frequently Asked Questions',
                  [
                    _buildFAQItem(
                      theme,
                      'How do I report an issue?',
                      'Tap the Report button in the bottom navigation, take a photo of the issue, select the category, and submit.',
                    ),
                    _buildDivider(),
                    _buildFAQItem(
                      theme,
                      'How long does it take to resolve issues?',
                      'Resolution time varies by issue type and severity. You\'ll receive updates on your report\'s progress.',
                    ),
                    _buildDivider(),
                    _buildFAQItem(
                      theme,
                      'Can I track my reports?',
                      'Yes! Go to Profile > My Reports to see all your submissions and their current status.',
                    ),
                    _buildDivider(),
                    _buildFAQItem(
                      theme,
                      'What are points and levels?',
                      'Earn points by reporting issues and helping resolve them. Points increase your level and unlock achievements!',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // About Section
                _buildSectionCard(
                  theme,
                  'About UrbanFix',
                  [
                    _buildInfoRow(theme, 'Version', '1.0.0'),
                    _buildDivider(),
                    _buildInfoRow(theme, 'Build', '2024.01'),
                    _buildDivider(),
                    _buildActionItem(
                      theme,
                      'Privacy Policy',
                      () {
                        // TODO: Open privacy policy
                      },
                    ),
                    _buildDivider(),
                    _buildActionItem(
                      theme,
                      'Terms of Service',
                      () {
                        // TODO: Open terms of service
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Feedback Button
                Container(
                  width: double.infinity,
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
                    children: [
                      Icon(
                        Icons.feedback_outlined,
                        size: 48,
                        color: ShadcnThemeConfig.primaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Send Feedback',
                        style: theme.textTheme.h4.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Help us improve UrbanFix',
                        style: theme.textTheme.muted,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              _launchEmail('feedback@urbanfix.com'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ShadcnThemeConfig.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Send Feedback',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    ShadThemeData theme,
    String title,
    List<Widget> children,
  ) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: theme.textTheme.h4.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildContactOption(
    ShadThemeData theme,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.p.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.muted.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: ShadcnThemeConfig.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(ShadThemeData theme, String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: theme.textTheme.p.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: theme.textTheme.muted.copyWith(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ShadThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.p.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.muted,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    ShadThemeData theme,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.p.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: ShadcnThemeConfig.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: ShadcnThemeConfig.borderColor,
      indent: 20,
      endIndent: 20,
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=UrbanFix Support',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}
