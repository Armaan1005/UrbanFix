import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/shadcn_theme.dart';

class SavedReportsScreen extends StatefulWidget {
  const SavedReportsScreen({Key? key}) : super(key: key);

  @override
  State<SavedReportsScreen> createState() => _SavedReportsScreenState();
}

class _SavedReportsScreenState extends State<SavedReportsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _savedReports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedReports();
  }

  Future<void> _loadSavedReports() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get saved report IDs
      final savedResponse = await _supabase
          .from('saved_reports')
          .select('report_id')
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false);

      if (savedResponse.isEmpty) {
        setState(() {
          _savedReports = [];
          _isLoading = false;
        });
        return;
      }

      // Get report IDs
      final reportIds =
          (savedResponse as List).map((e) => e['report_id']).toList();

      // Fetch full report details
      final reportsResponse = await _supabase
          .from('reports')
          .select('*, users(name)')
          .inFilter('id', reportIds);

      setState(() {
        _savedReports = List<Map<String, dynamic>>.from(reportsResponse);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading saved reports: $e');
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
                'Saved Reports',
                style: theme.textTheme.h2.copyWith(
                  fontSize: 24,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
          ),

          // Content
          _isLoading
              ? SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: ShadcnThemeConfig.primaryColor,
                    ),
                  ),
                )
              : _savedReports.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(32),
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bookmark_outline,
                                size: 64,
                                color: ShadcnThemeConfig.textSecondaryColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Saved Reports',
                                style: theme.textTheme.h3.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Bookmark reports to save them for later',
                                style: theme.textTheme.muted,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: ShadcnThemeConfig.primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: ShadcnThemeConfig.primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Tap the bookmark icon on any report to save it',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: ShadcnThemeConfig.primaryColor,
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
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final report = _savedReports[index];
                            return _buildReportCard(report, theme);
                          },
                          childCount: _savedReports.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, ShadThemeData theme) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/report-details',
          arguments: report['id'],
        );
      },
      child: Container(
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
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                report['image_url'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report['address'] ?? '',
                    style: theme.textTheme.muted.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
