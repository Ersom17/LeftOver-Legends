// lib/widgets/mascot_tour/mascot_tour_host.dart
//
// Registers the first-run auto-start for the mascot tour on the pantry
// screen, and exposes the "?" launcher used beside the FAB and in the
// profile screen. The overlay itself is mounted at the app level (see
// main.dart) so it survives route changes.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/locale_provider.dart';
import '../../providers/mascot_tour_provider.dart';
import '../../theme/app_theme.dart';
import 'mascot_tour_anchors.dart';
import 'mascot_tour_i18n.dart';

class MascotTourHost extends ConsumerStatefulWidget {
  final Widget child;
  const MascotTourHost({super.key, required this.child});

  @override
  ConsumerState<MascotTourHost> createState() => _MascotTourHostState();
}

class _MascotTourHostState extends ConsumerState<MascotTourHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mascotTourProvider.notifier).maybeStartFirstRun();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// A compact "?" replay control, designed to sit alongside a FAB.
class MascotTourLauncher extends ConsumerWidget {
  const MascotTourLauncher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);
    final s = MascotStrings.forLanguage(lang);

    return Container(
      key: MascotAnchors.keyFor(MascotAnchorIds.helpButton),
      decoration: BoxDecoration(
        color: AppColors.lightBeige,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.darkGreen.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        tooltip: s.replayTooltip,
        onPressed: () =>
            ref.read(mascotTourProvider.notifier).restart(),
        icon: const Icon(
          Icons.help_outline,
          color: AppColors.darkGreen,
        ),
      ),
    );
  }
}
