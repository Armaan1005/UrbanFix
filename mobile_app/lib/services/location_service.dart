import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Caching
  Position? _cachedPosition;
  DateTime? _lastPositionFetchTime;
  Map<String, String> _addressCache = {};
  Map<String, DateTime> _addressCacheTimes = {};

  static const Duration _positionCacheDuration = Duration(minutes: 2);
  static const Duration _addressCacheDuration = Duration(minutes: 5);

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permission
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Check if position cache is valid
  bool _isPositionCacheValid() {
    if (_lastPositionFetchTime == null || _cachedPosition == null) {
      return false;
    }
    return DateTime.now().difference(_lastPositionFetchTime!) <
        _positionCacheDuration;
  }

  // Get current location with caching
  Future<Position?> getCurrentLocation({bool forceRefresh = false}) async {
    // Return cached position if valid
    if (!forceRefresh && _isPositionCacheValid()) {
      print('Using cached location');
      return _cachedPosition;
    }

    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return _cachedPosition; // Return cached if available
      }

      // Check permission
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return _cachedPosition; // Return cached if available
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return _cachedPosition; // Return cached if available
      }

      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Location request timed out');
        },
      );

      // Cache the position
      _cachedPosition = position;
      _lastPositionFetchTime = DateTime.now();
      print('Fetched fresh location from GPS');

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return _cachedPosition; // Return cached if available
    }
  }

  // Get address from coordinates with caching
  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    // Create cache key from coordinates
    final cacheKey =
        '${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}';

    // Check if we have cached address
    if (_addressCache.containsKey(cacheKey)) {
      final cacheTime = _addressCacheTimes[cacheKey];
      if (cacheTime != null &&
          DateTime.now().difference(cacheTime) < _addressCacheDuration) {
        print('Using cached address for $cacheKey');
        return _addressCache[cacheKey]!;
      }
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final address =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}';

        // Cache the address
        _addressCache[cacheKey] = address;
        _addressCacheTimes[cacheKey] = DateTime.now();
        print('Fetched fresh address from geocoding API');

        return address;
      }

      return 'Unknown location';
    } catch (e) {
      print('Error getting address: $e');
      // Return cached address if available, otherwise unknown
      return _addressCache[cacheKey] ?? 'Unknown location';
    }
  }

  // Alias for getAddressFromCoordinates
  Future<String?> getAddressFromLatLng(
      double latitude, double longitude) async {
    return await getAddressFromCoordinates(latitude, longitude);
  }

  // Calculate distance between two points (in meters)
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Format distance for display
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)}km';
    }
  }

  // Get location stream for real-time updates
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }
}
