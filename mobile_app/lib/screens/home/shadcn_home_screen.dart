import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../config/shadcn_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../services/location_service.dart';

class ShadcnHomeScreen extends StatefulWidget {
  const ShadcnHomeScreen({Key? key}) : super(key: key);

  @override
  State<ShadcnHomeScreen> createState() => _ShadcnHomeScreenState();
}

class _ShadcnHomeScreenState extends State<ShadcnHomeScreen>
    with SingleTickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  final _supabase = Supabase.instance.client;
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  Set<Marker> _markers = {};
  String _currentAddress = 'Loading...';

  int _activeCount = 0;
  int _resolvedCount = 0;
  int _pendingCount = 0;
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
    _loadData();
    _loadStats();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final activeResponse = await _supabase
          .from('reports')
          .select('id')
          .inFilter('status', ['reported', 'in_progress']);

      final resolvedResponse =
          await _supabase.from('reports').select('id').eq('status', 'resolved');

      final pendingResponse = await _supabase
          .from('reports')
          .select('id')
          .eq('status', 'acknowledged');

      if (mounted) {
        setState(() {
          _activeCount = (activeResponse as List).length;
          _resolvedCount = (resolvedResponse as List).length;
          _pendingCount = (pendingResponse as List).length;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  Future<void> _loadData() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null && mounted) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Get address from coordinates
      final address = await _locationService.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );
      if (mounted) {
        setState(() {
          _currentAddress = address ?? 'Unknown location';
        });
      }
    }

    if (mounted) {
      await context.read<ReportProvider>().fetchNearbyReports(
            _currentLocation?.latitude ?? 0,
            _currentLocation?.longitude ?? 0,
          );
      _updateMarkers();
    }
  }

  void _updateMarkers() {
    final reports = context.read<ReportProvider>().reports;
    setState(() {
      _markers = reports.map((report) {
        return Marker(
          markerId: MarkerId(report.reportId),
          position: LatLng(
            report.location.latitude,
            report.location.longitude,
          ),
          infoWindow: InfoWindow(
            title: report.category,
            snippet: report.issueNumber,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerColor(report.status),
          ),
        );
      }).toSet();
    });
  }

  double _getMarkerColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BitmapDescriptor.hueOrange;
      case 'in_progress':
        return BitmapDescriptor.hueBlue;
      case 'resolved':
        return BitmapDescriptor.hueGreen;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final userName = user?.userMetadata?['name'] ?? 'User';
    final userCity = user?.userMetadata?['city'] ?? 'Chennai';

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Premium Header with Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ShadcnThemeConfig.primaryColor.withOpacity(0.1),
                      ShadcnThemeConfig.secondaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Top Bar
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'UrbanFix',
                                style: theme.textTheme.h2.copyWith(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: ShadcnThemeConfig.primaryColor,
                                ),
                              ),
                              Text(
                                'Civic Reporting Platform',
                                style: theme.textTheme.muted.copyWith(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Notification Bell
                        GestureDetector(
                          onTap: () => context.push('/notifications'),
                          child: Container(
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
                    const SizedBox(height: 20),
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: ShadcnThemeConfig.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _currentAddress,
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

              const SizedBox(height: 20),

              // Premium Stats Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPremiumStatCard(
                        'Active',
                        _activeCount.toString(),
                        'Issues nearby',
                        ShadcnThemeConfig.errorColor,
                        Icons.error_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPremiumStatCard(
                        'Resolved',
                        _resolvedCount.toString(),
                        'This month',
                        ShadcnThemeConfig.successColor,
                        Icons.check_circle_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPremiumStatCard(
                        'In Progress',
                        _pendingCount.toString(),
                        'Active work',
                        ShadcnThemeConfig.warningColor,
                        Icons.construction_rounded,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
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

              const SizedBox(height: 12),

              // Map with Premium Styling
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color:
                              ShadcnThemeConfig.primaryColor.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: _buildMapView(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // Above the nav bar
        child: Container(
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

  Widget _buildMapView() {
    if (_currentLocation == null) {
      return Container(
        color: ShadcnThemeConfig.backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: ShadcnThemeConfig.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading map...',
                style: ShadTheme.of(context).textTheme.muted,
              ),
            ],
          ),
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _currentLocation!,
        zoom: 14,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }
}
