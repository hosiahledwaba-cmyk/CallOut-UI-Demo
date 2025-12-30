import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter
import '../theme/design_tokens.dart';

class InAppNotificationOverlay {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + DesignTokens.paddingMedium,
        left: DesignTokens.paddingMedium,
        right: DesignTokens.paddingMedium,
        child: Material(
          color: Colors.transparent,
          child: _SlideDownWidget(
            child: GestureDetector(
              onTap: onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  DesignTokens.borderRadiusMedium,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: DesignTokens.blurSigma,
                    sigmaY: DesignTokens.blurSigma,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(DesignTokens.paddingMedium),
                    decoration: BoxDecoration(
                      color: DesignTokens.glassDark, // Using premium dark glass
                      border: Border.all(color: DesignTokens.glassBorderDark),
                      borderRadius: BorderRadius.circular(
                        DesignTokens.borderRadiusMedium,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: DesignTokens.accentPrimary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: DesignTokens.accentPrimary,
                            size: DesignTokens.iconSizeMedium,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: DesignTokens.textPrimaryDark,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                message,
                                style: const TextStyle(
                                  color: DesignTokens.textSecondaryDark,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      overlayEntry.remove();
    });
  }
}

// Simple Animation Wrapper
class _SlideDownWidget extends StatefulWidget {
  final Widget child;
  const _SlideDownWidget({required this.child});

  @override
  State<_SlideDownWidget> createState() => _SlideDownWidgetState();
}

class _SlideDownWidgetState extends State<_SlideDownWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.durationMedium,
      vsync: this,
    )..forward();

    _offsetAnimation =
        Tween<Offset>(
          begin: const Offset(0.0, -1.0), // Start above screen
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: DesignTokens.animationCurve,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _offsetAnimation, child: widget.child);
  }
}
