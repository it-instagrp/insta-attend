import 'package:flutter/material.dart';
import 'package:insta_attend/Constant/constant_color.dart';

enum PendingStatus { review, approved, rejected }

class StatusBar extends StatefulWidget {
  final VoidCallback? onReview;
  final VoidCallback? onApproved;
  final VoidCallback? onRejected;

  final Map<PendingStatus, int>? counts;

  const StatusBar({
    super.key,
    this.onReview,
    this.onApproved,
    this.onRejected,
    this.counts,
  });

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  PendingStatus selected = PendingStatus.review;

  final Duration animationDuration = const Duration(milliseconds: 300);

  Alignment _getAlignment(PendingStatus status) {
    switch (status) {
      case PendingStatus.review:
        return Alignment.centerLeft;
      case PendingStatus.approved:
        return Alignment.center;
      case PendingStatus.rejected:
        return Alignment.centerRight;
    }
  }

  String _label(PendingStatus status) {
    switch (status) {
      case PendingStatus.review:
        return 'Review';
      case PendingStatus.approved:
        return 'Approved';
      case PendingStatus.rejected:
        return 'Rejected';
    }
  }

  void _handleTap(PendingStatus status) {
    setState(() {
      selected = status;
    });

    switch (status) {
      case PendingStatus.review:
        widget.onReview?.call();
        break;
      case PendingStatus.approved:
        widget.onApproved?.call();
        break;
      case PendingStatus.rejected:
        widget.onRejected?.call();
        break;
    }
  }

  int _getCount(PendingStatus status) {
    return widget.counts?[status] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 366,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: animationDuration,
            alignment: _getAlignment(selected),
            curve: Curves.easeInOut,
            child: Container(
              width: 122,
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: kcPurple500,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          Row(
            children:
                PendingStatus.values.map((status) {
                  final isSelected = selected == status;
                  return Expanded(
                    child: GestureDetector(
                      behavior:
                          HitTestBehavior
                              .opaque, // <== ensures full area is tappable
                      onTap: () => _handleTap(status),
                      child: TweenAnimationBuilder<double>(
                        duration: animationDuration,
                        tween: Tween<double>(
                          begin: isSelected ? 0.0 : 1.0,
                          end: isSelected ? 1.0 : 0.0,
                        ),
                        builder: (context, value, child) {
                          final textColor =
                              Color.lerp(Colors.black87, Colors.white, value)!;
                          final badgeColor =
                              Color.lerp(
                                Colors.grey.shade300,
                                Colors.red,
                                value,
                              )!;
                          final badgeTextColor =
                              Color.lerp(Colors.black, Colors.white, value)!;

                          return Container(
                            height: double.infinity,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _label(status),
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if(_getCount(status)>0)Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: badgeColor,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${_getCount(status)}',
                                    style: TextStyle(
                                      color: badgeTextColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
