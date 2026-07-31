import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:insta_attend/Component/Cards/location_disabled_card.dart';
import 'package:insta_attend/API/app_constants.dart';

class LocationServiceManager {
  LocationServiceManager._internal();
  static final LocationServiceManager instance =
      LocationServiceManager._internal();

  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;
  bool _isDialogShowing = false;

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
  }
}
