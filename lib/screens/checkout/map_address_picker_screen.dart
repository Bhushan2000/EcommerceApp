import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/address_lookup_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

class MapAddressPickerScreen extends StatefulWidget {
  final String? initialStreet;
  final String? initialCity;
  final String? initialState;
  final String? initialZip;

  const MapAddressPickerScreen({
    super.key,
    this.initialStreet,
    this.initialCity,
    this.initialState,
    this.initialZip,
  });

  @override
  State<MapAddressPickerScreen> createState() => _MapAddressPickerScreenState();
}

class _MapAddressPickerScreenState extends State<MapAddressPickerScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Location & Map State
  LatLng _currentLatLng = const LatLng(37.7749, -122.4194);
  MapType _currentMapType = MapType.normal;
  bool _isCameraMoving = false;
  bool _isGeocoding = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _searchDebounce;

  // Real Permission & Geolocation Status
  bool _isLocating = true;
  bool _hasLocationPermission = false;
  bool _locationServiceDisabled = false;
  bool _permissionPermanentlyDenied = false;
  bool _hasSelectedLocation = false;

  // Address fields obtained from real reverse-geocoding
  String _street = '';
  String _city = '';
  String _state = '';
  String _zip = '';
  String _country = 'United States';

  bool get _supportsNativeGoogleMaps =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();

    // Check if initial address is already available
    if (widget.initialStreet != null && widget.initialStreet!.trim().isNotEmpty) {
      _street = widget.initialStreet!.trim();
      _city = widget.initialCity?.trim() ?? '';
      _state = widget.initialState?.trim() ?? '';
      _zip = widget.initialZip?.trim() ?? '';
      _hasSelectedLocation = true;
    }

    // Automatically trigger Google Maps real location permission & detection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestAndFetchCurrentLocation();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  /// Requests user location permission, enables GPS if needed, and fetches real coordinates
  Future<void> _requestAndFetchCurrentLocation({bool showFeedback = false}) async {
    if (!mounted) return;
    setState(() {
      _isLocating = true;
      _locationServiceDisabled = false;
      _permissionPermanentlyDenied = false;
    });

    try {
      // 1. Verify if device GPS / Location services are enabled
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        if (mounted) {
          setState(() {
            _isLocating = false;
            _locationServiceDisabled = true;
          });
          if (showFeedback) {
            _showLocationSnackbar(
              'Location services are turned off on this device',
              actionLabel: 'SETTINGS',
              onAction: () => Geolocator.openLocationSettings(),
              isWarning: true,
            );
          }
        }
        return;
      }

      // 2. Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _isLocating = false;
            _hasLocationPermission = false;
          });
          if (showFeedback) {
            _showLocationSnackbar(
              'Location permission denied. Please allow access to detect your delivery address.',
            );
          }
        }
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLocating = false;
            _hasLocationPermission = false;
            _permissionPermanentlyDenied = true;
          });
          if (showFeedback) {
            _showLocationSnackbar(
              'Location permission permanently denied. Enable it in App Settings.',
              actionLabel: 'SETTINGS',
              onAction: () => Geolocator.openAppSettings(),
            );
          }
        }
        return;
      }

      // 3. Permission granted: fetch current position
      if (mounted) {
        setState(() {
          _hasLocationPermission = true;
        });
      }

      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (_) {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          position = lastKnown;
        } else {
          rethrow;
        }
      }

      final userLatLng = LatLng(position.latitude, position.longitude);
      _currentLatLng = userLatLng;

      // Animate Google Maps camera to real GPS location
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLatLng, zoom: 17.0),
        ),
      );

      // 4. Reverse geocode the real location
      if (mounted) {
        setState(() {
          _isGeocoding = true;
        });
      }

      final geocoded = await AddressLookupService.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _isLocating = false;
          _isGeocoding = false;
          if (geocoded != null) {
            _street = geocoded['street'] ?? 'Current Location';
            _city = geocoded['city'] ?? '';
            _state = geocoded['state'] ?? '';
            _zip = geocoded['zip'] ?? '';
            _country = geocoded['country'] ?? 'United States';
          } else {
            _street = 'Selected Location';
          }
          // Now and only now show the bottom address confirmation card!
          _hasSelectedLocation = true;
        });
      }
    } catch (e) {
      debugPrint('Geolocator error: $e');
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
        if (showFeedback) {
          _showLocationSnackbar('Could not retrieve current location.');
        }
      }
    }
  }

  void _showLocationSnackbar(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    bool isWarning = false,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isWarning ? AppColors.warning : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  /// Triggers whenever camera finishes moving (user stopped panning/zooming)
  void _onCameraIdle() async {
    setState(() {
      _isGeocoding = true;
    });

    final geocoded = await AddressLookupService.reverseGeocode(
      _currentLatLng.latitude,
      _currentLatLng.longitude,
    );

    if (mounted) {
      setState(() {
        _isGeocoding = false;
        if (geocoded != null) {
          _street = geocoded['street'] ?? _street;
          _city = geocoded['city'] ?? _city;
          _state = geocoded['state'] ?? _state;
          _zip = geocoded['zip'] ?? _zip;
          _country = geocoded['country'] ?? _country;
        }
        // User interacted with map, reveal the confirmation card!
        _hasSelectedLocation = true;
      });
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() {
        _isSearching = true;
      });
      final results = await AddressLookupService.searchPlaces(query);
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = results;
        });
      }
    });
  }

  void _selectSearchResult(Map<String, dynamic> item) {
    final lat = item['lat'] as double?;
    final lng = item['lng'] as double?;
    if (lat != null && lng != null) {
      final newPos = LatLng(lat, lng);
      setState(() {
        _currentLatLng = newPos;
        _street = item['street'] ?? '';
        _city = item['city'] ?? '';
        _state = item['state'] ?? '';
        _zip = item['zip'] ?? '';
        _country = item['country'] ?? 'United States';
        _searchResults = [];
        _searchController.clear();
        _hasSelectedLocation = true;
      });
      _searchFocusNode.unfocus();

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newPos, zoom: 17.0),
        ),
      );
    }
  }

  void _toggleMapType() {
    setState(() {
      if (_currentMapType == MapType.normal) {
        _currentMapType = MapType.satellite;
      } else if (_currentMapType == MapType.satellite) {
        _currentMapType = MapType.terrain;
      } else {
        _currentMapType = MapType.normal;
      }
    });
  }

  String get _mapTypeLabel {
    switch (_currentMapType) {
      case MapType.normal:
        return 'Streets';
      case MapType.satellite:
        return 'Satellite';
      case MapType.terrain:
        return 'Terrain';
      default:
        return 'Streets';
    }
  }

  IconData get _mapTypeIcon {
    switch (_currentMapType) {
      case MapType.normal:
        return Icons.map_rounded;
      case MapType.satellite:
        return Icons.satellite_alt_rounded;
      case MapType.terrain:
        return Icons.terrain_rounded;
      default:
        return Icons.map_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card(context).withAlpha(230),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary(context),
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.card(context).withAlpha(230),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://developers.google.com/static/maps/images/google-maps-icon.png',
                width: 18,
                height: 18,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.location_on,
                  color: AppColors.borderLight,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Google Maps',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. REAL GOOGLE MAP VIEW
          Positioned.fill(
            child: _supportsNativeGoogleMaps
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLatLng,
                      zoom: 16.0,
                    ),
                    mapType: _currentMapType,
                    myLocationEnabled: _hasLocationPermission,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    compassEnabled: true,
                    mapToolbarEnabled: false,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      if (_hasSelectedLocation) {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLng(_currentLatLng),
                        );
                      }
                    },
                    onCameraMoveStarted: () {
                      setState(() {
                        _isCameraMoving = true;
                      });
                    },
                    onCameraMove: (position) {
                      _currentLatLng = position.target;
                    },
                    onCameraIdle: () {
                      setState(() {
                        _isCameraMoving = false;
                      });
                      _onCameraIdle();
                    },
                    onTap: (latLng) {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLng(latLng),
                      );
                    },
                  )
                : Container(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.map_rounded, size: 64, color: AppColors.primary),
                          const SizedBox(height: 12),
                          const Text(
                            'Google Maps Active (Android, iOS & Web)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Current Position: ${_currentLatLng.latitude.toStringAsFixed(4)}, ${_currentLatLng.longitude.toStringAsFixed(4)}',
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // 2. INTERACTIVE CENTER PIN WITH DROP & BOUNCE ANIMATION
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 42.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    transform: Matrix4.translationValues(
                      0,
                      _isCameraMoving ? -14 : 0,
                      0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isLocating || _isGeocoding) ...[
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                _isLocating
                                    ? 'Locating you...'
                                    : (_isCameraMoving
                                        ? 'Moving pin...'
                                        : (_isGeocoding
                                            ? 'Fetching address...'
                                            : 'Deliver Here')),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Icon(
                          Icons.location_on,
                          size: 46,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  // Animated Contact Shadow
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: _isCameraMoving ? 8 : 16,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(_isCameraMoving ? 30 : 90),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. TOP SEARCH BAR (NO STATIC DATA - LIVE AUTOCOMPLETE ONLY)
          Positioned(
            top: MediaQuery.of(context).padding.top + 56,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card(context).withAlpha(245),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border(context)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search city, street, or landmark...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults = [];
                                });
                              },
                            )
                          : (_isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : null),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                // Live search suggestions dropdown
                if (_searchResults.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 240),
                    decoration: BoxDecoration(
                      color: AppColors.card(context).withAlpha(250),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border(context)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: AppColors.border(context),
                      ),
                      itemBuilder: (context, idx) {
                        final item = _searchResults[idx];
                        return ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          title: Text(
                            item['street'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${item['city']}, ${item['state']} ${item['country']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                          onTap: () => _selectSearchResult(item),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 4. FLOATING MAP ACTION BUTTONS (Map Type, My Location, Zoom)
          Positioned(
            right: 16,
            bottom: _hasSelectedLocation
                ? 260
                : (_locationServiceDisabled || !_hasLocationPermission ? 210 : 36),
            child: Column(
              children: [
                // Toggle Map Type (Streets / Satellite / Terrain)
                FloatingActionButton.small(
                  heroTag: 'map_type_btn',
                  backgroundColor: AppColors.card(context).withAlpha(240),
                  onPressed: _toggleMapType,
                  tooltip: 'Switch Map View ($_mapTypeLabel)',
                  child: Icon(
                    _mapTypeIcon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                // Zoom In
                FloatingActionButton.small(
                  heroTag: 'zoom_in_btn',
                  backgroundColor: AppColors.card(context).withAlpha(240),
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomIn());
                  },
                  child: Icon(
                    Icons.add_rounded,
                    color: AppColors.textPrimary(context),
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                // Zoom Out
                FloatingActionButton.small(
                  heroTag: 'zoom_out_btn',
                  backgroundColor: AppColors.card(context).withAlpha(240),
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomOut());
                  },
                  child: Icon(
                    Icons.remove_rounded,
                    color: AppColors.textPrimary(context),
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                // "My Location" GPS Crosshair Button (Real Google Maps flow)
                FloatingActionButton.small(
                  heroTag: 'my_location_btn',
                  backgroundColor: AppColors.primary,
                  onPressed: _isLocating
                      ? null
                      : () => _requestAndFetchCurrentLocation(showFeedback: true),
                  tooltip: 'Center on My Current Location',
                  child: _isLocating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.my_location_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ],
            ),
          ),

          // 5. BOTTOM FLOW: ONLY SHOW CONFIRMATION CARD ONCE LOCATION IS DETERMINED
          if (_hasSelectedLocation)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                offset: Offset.zero,
                curve: Curves.easeOutCubic,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.card(context).withAlpha(245),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border(context)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _street.isNotEmpty ? _street : 'Selected Pin Location',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (_isGeocoding) ...[
                                      const SizedBox(width: 8),
                                      const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '$_city, $_state $_zip • $_country',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'GPS: ${_currentLatLng.latitude.toStringAsFixed(4)}, ${_currentLatLng.longitude.toStringAsFixed(4)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Confirm & Use This Address',
                        icon: Icons.check_circle_outline_rounded,
                        onPressed: () {
                          Navigator.pop(context, {
                            'street': _street,
                            'city': _city,
                            'state': _state,
                            'zip': _zip,
                            'country': _country,
                            'latitude': _currentLatLng.latitude.toString(),
                            'longitude': _currentLatLng.longitude.toString(),
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          // 5b. IF LOCATION IS STILL BEING DETECTED: SHOW PULSING LOCATING PILL
          else if (_isLocating)
            Positioned(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).padding.bottom + 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.card(context).withAlpha(240),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border(context)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Locating your delivery address...',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Detecting precise GPS coordinates via Google Maps',
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          // 5c. IF LOCATION SERVICES ARE DISABLED: PROMPT TO TURN ON GPS
          else if (_locationServiceDisabled)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card(context).withAlpha(245),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border(context)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_off_rounded,
                            color: AppColors.warning,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Device Location is Off',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Turn on GPS to find your address automatically on Google Maps.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Turn On Location',
                            icon: Icons.settings_rounded,
                            onPressed: () => Geolocator.openLocationSettings(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          onPressed: () => _searchFocusNode.requestFocus(),
                          child: const Text('Search Manually'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          // 5d. IF PERMISSION NOT GRANTED: SHOW PROPER PERMISSION REQUEST SHEET
          else if (!_hasLocationPermission)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card(context).withAlpha(245),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border(context)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.near_me_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Use Your Current Location',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Allow location access so we can pinpoint your delivery location accurately.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: _permissionPermanentlyDenied
                                ? 'Open App Settings'
                                : 'Allow Location Access',
                            icon: Icons.my_location_rounded,
                            onPressed: () {
                              if (_permissionPermanentlyDenied) {
                                Geolocator.openAppSettings();
                              } else {
                                _requestAndFetchCurrentLocation(showFeedback: true);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          onPressed: () => _searchFocusNode.requestFocus(),
                          child: const Text('Search Manually'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
