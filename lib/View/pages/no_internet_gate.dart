import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:insta_attend/Constant/constant_color.dart';

class NoInternetGate extends StatefulWidget {
  final Widget child;
  const NoInternetGate({super.key, required this.child});

  @override
  State<NoInternetGate> createState() => _NoInternetGateState();
}

class _NoInternetGateState extends State<NoInternetGate> {
  final Connectivity _connectivity = Connectivity();
  bool _hasInternet = true;
  bool _isChecking = false;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void initState() {
    super.initState();
    _checkOnce();
    _sub = _connectivity.onConnectivityChanged.listen((result) {
      _updateStatus(result);
    });
  }

  Future<void> _checkOnce() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
  }

  void _updateStatus(List<ConnectivityResult> result) {
    if (!mounted) return;
    final connected = !result.contains(ConnectivityResult.none);
    if (connected != _hasInternet) {
      setState(() => _hasInternet = connected);
    }
  }

  Future<void> _onRetry() async {
    setState(() => _isChecking = true);
    await _checkOnce();
    if (mounted) setState(() => _isChecking = false);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_hasInternet)
          Positioned.fill(
            child: _NoInternetPage(isChecking: _isChecking, onRetry: _onRetry),
          ),
      ],
    );
  }
}

class _NoInternetPage extends StatelessWidget {
  final bool isChecking;
  final VoidCallback onRetry;
  const _NoInternetPage({required this.isChecking, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kcPurple500,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "No Internet Connection",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please check your Wi-Fi or mobile data and try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcPurple500,
                      foregroundColor:
                          Colors.white, // FIX: was kcPurple500 (invisible text)
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isChecking ? null : onRetry,
                    child:
                        isChecking
                            ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Retry',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
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
