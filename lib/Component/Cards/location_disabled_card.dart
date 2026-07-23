import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';

const Color kLocationCardPrimary = Color(0xFF795FFC);
const Color kLocationCardAccent = Color(0xFF6E62FF);

class LocationDisabledCard extends StatefulWidget {
  final VoidCallback onEnablePressed;

  final Future<bool> Function() onRetryPressed;

  const LocationDisabledCard({
    super.key,
    required this.onEnablePressed,
    required this.onRetryPressed,
  });

  @override
  State<LocationDisabledCard> createState() => _LocationDisabledCardState();
}

class _LocationDisabledCardState extends State<LocationDisabledCard>
    with SingleTickerProviderStateMixin {
  bool _isRetrying = false;
  bool _showStillOffMessage = false;

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleEnable() {
    HapticFeedback.lightImpact();
    widget.onEnablePressed();
  }

  Future<void> _handleRetry() async {
    HapticFeedback.selectionClick();
    setState(() {
      _isRetrying = true;
      _showStillOffMessage = false;
    });

    final isNowEnabled = await widget.onRetryPressed();

    if (!mounted) return;
    setState(() {
      _isRetrying = false;
      _showStillOffMessage = !isNowEnabled;
    });

    if (!isNowEnabled) {
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.scale(scale: 0.9 + (0.1 * value), child: child),
        );
      },
      child: Semantics(
        header: true,
        label: 'Location services are turned off. Enable Location to continue.',
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Card(
            elevation: 10,
            shadowColor: kLocationCardPrimary.withOpacity(0.25),
            margin: const EdgeInsets.symmetric(horizontal: 28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.12).animate(
                      CurvedAnimation(
                        parent: _pulseController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: kcPurple500,
                      child: const Icon(
                        Icons.location_off_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Turn On Location',
                    style: kfTitleMedium.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Insta Attend needs location to record attendance',
                    textAlign: TextAlign.center,
                    style: kfTitleSmall.copyWith(
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child:
                        _showStillOffMessage
                            ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 16,
                                    color: Colors.redAccent,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Still Off - Enable it, then tap Retry.',
                                      style: kfTitleSmall.copyWith(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton.icon(
                      onPressed: _handleEnable,
                      icon: const Icon(Icons.settings_rounded, size: 18),
                      label: Text(
                        'Enable Location',
                        style: kfTitleSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: kLocationCardPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: _isRetrying ? null : _handleRetry,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kLocationCardPrimary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isRetrying
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: kLocationCardPrimary,
                                ),
                              )
                              : Text(
                                'Retry',
                                style: kfTitleSmall.copyWith(
                                  color: kLocationCardPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
