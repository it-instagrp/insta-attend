import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:insta_attend/Component/Cards/location_disabled_card.dart';
import 'package:insta_attend/API/app_constants.dart';

class LocationServiceManager {
  LocationServiceManager._internal();
  static final LocationServiceManager instance =
  LocationServiceManager._internal();

  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;
  bool _isDialogShowing = false;

  // ✓ CHANGE 1: Add in-memory location holder (NOT persistent)
  final Rxn<Position> _currentPosition = Rxn<Position>();

  /// Get the current in-memory location (fetched during this app session)
  Position? getCurrentPosition() => _currentPosition.value;

  /// Set the current in-memory location
  void setCurrentPosition(Position? position) {
    _currentPosition.value = position;
    if (position != null) {
      debugPrint(
        'LocationServiceManager: Location updated - Lat: ${position.latitude}, Lng: ${position.longitude}',
      );
    }
  }

  /// Fetch and store location in memory (called when app comes to foreground)
  Future<Position?> fetchCurrentLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('LocationServiceManager: Location services disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever ||
            permission == LocationPermission.denied) {
          debugPrint('LocationServiceManager: Location permission denied');
          return null;
        }
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      // ✓ CHANGE 2: Store in memory (Rx), NOT in SharedPreferences
      setCurrentPosition(position);
      return position;
    } catch (e) {
      debugPrint('LocationServiceManager: Error fetching location: $e');
      return null;
    }
  }

  /// Clear location from memory (called when app goes to background)
  void clearCurrentPosition() {
    _currentPosition.value = null;
    debugPrint('LocationServiceManager: Location cleared from memory');
  }

  Future<void> init() async {
    debugPrint('LocationServiceManager.init() called');
    final isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      _showLocationDisabledDialog();
    }
    _serviceStatusSubscription ??= Geolocator.getServiceStatusStream().listen((
        status,
        ) {
      debugPrint('LOCATION SERVICE STATUS: $status');
      if (status == ServiceStatus.disabled) {
        _showLocationDisabledDialog();
      } else if (status == ServiceStatus.enabled) {
        _dismissDialogIfShowing();
      }
    });
  }

  void _showLocationDisabledDialog() {
    if (_isDialogShowing) return;
    final context = globalNavigatorKey.currentState?.overlay?.context;
    if (context == null) return;
    _isDialogShowing = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 0),
          child: LocationDisabledCard(
            onEnablePressed: () async {
              await Geolocator.openLocationSettings();
            },
            onRetryPressed: () async {
              final isEnabled = await Geolocator.isLocationServiceEnabled();
              if (isEnabled && dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              return isEnabled;
            },
          ),
        ),
      ),
    ).whenComplete(() {
      _isDialogShowing = false;
    });
  }

  void _dismissDialogIfShowing() {
    if (!_isDialogShowing) return;
    final nav = globalNavigatorKey.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    }
    _isDialogShowing = false;
  }

  void dispose() {
    _serviceStatusSubscription?.cancel();
    _serviceStatusSubscription = null;
    clearCurrentPosition();  // ✓ CHANGE 3: Clear location on dispose
  }
}