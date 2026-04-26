// lib/widgets/mascot_tour/mascot_tour_overlay.dart
//
// Full-screen overlay rendered above the app while the mascot tour is
// active. Paints a dimmed scrim with a spotlight cutout around the
// current step's anchor, parks a speech bubble + mascot next to it, and
// explodes confetti on the finale.
//
// Cutout taps pass through to the underlying widget (so the user can
// really tap the highlighted control); taps outside the cutout are
// intercepted so the tour can't be bypassed accidentally.

import 'dart:async';
import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/locale_provider.dart';
import '../../providers/mascot_tour_provider.dart';
import '../../router.dart';
import '../../theme/app_theme.dart';
import 'mascot_figure.dart';
import 'mascot_tour_anchors.dart';
import 'mascot_tour_i18n.dart';

class MascotTourOverlay extends ConsumerStatefulWidget {
  const MascotTourOverlay({super.key});

  @override
  ConsumerState<MascotTourOverlay> createState() => _MascotTourOverlayState();
}

class _MascotTourOverlayState extends ConsumerState<MascotTourOverlay> {
  final _confetti = ConfettiController(duration: const Duration(seconds: 2));
  int _lastStep = -1;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Re-measure anchor rects ~10× per second so the cutout follows modals
    // that slide up, list scrolls, or any widget that mounts after the step
    // changes (e.g. the bottom sheet's "Add manually" tile).
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      final tour = ref.read(mascotTourProvider);
      if (tour.active) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tour = ref.watch(mascotTourProvider);
    if (!tour.active) return const SizedBox.shrink();

    final step = mascotSteps[tour.stepIndex];
    final lang = ref.watch(localeProvider);
    final s = MascotStrings.forLanguage(lang);

    // When the step changes, schedule exactly one post-frame rebuild so
    // anchor GlobalKeys that mounted during this frame get measured.
    if (_lastStep != tour.stepIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
      if (step.isFinale) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _confetti.play());
      }

      // The bottom-nav orientation steps anchor widgets that only exist on
      // /fridge. By the time we reach them the user has pushed RecipesScreen
      // and RecipeDetailScreen on top — pop those routes so the nav is
      // visible and tappable again. We go through GoRouter's navigatorKey
      // directly because the overlay lives above the navigator in the
      // widget tree and `Navigator.of(context)` can't see it.
      final needsFridge = step.anchorId == MascotAnchorIds.navRecipes ||
          step.anchorId == MascotAnchorIds.navLearn ||
          step.anchorId == MascotAnchorIds.navRewards ||
          step.anchorId == MascotAnchorIds.navProfile;
      if (needsFridge) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final nav = rootNavigatorKey.currentState;
          if (nav != null && nav.canPop()) {
            nav.popUntil((r) => r.isFirst);
          }
        });
      }
    }
    _lastStep = tour.stepIndex;

    final screen = MediaQuery.of(context).size;
    final targetRect = step.anchorId == null
        ? null
        : MascotAnchors.rectFor(step.anchorId!);

    return Positioned.fill(
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            // Dimming + spotlight paint (no hit testing).
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _SpotlightPainter(
                    target: step.isFinale ? null : targetRect,
                    dim: step.isFinale ? 0.72 : 0.58,
                  ),
                ),
              ),
            ),

            // Hit shield around the spotlight: absorbs stray taps outside
            // the cutout, but the cutout itself is fully tap-through so the
            // user can hit the highlighted control.
            Positioned.fill(
              child: _CutoutHitShield(
                cutout: step.isFinale ? null : targetRect,
              ),
            ),

            // Bubble + mascot
            if (step.isFinale)
              _FinaleLayer(strings: s, controller: _confetti)
            else
              _StepLayer(
                step: step,
                strings: s,
                targetRect: targetRect,
                screenSize: screen,
              ),
          ],
        ),
      ),
    );
  }

}

/// Fills the screen and absorbs all taps that land *outside* the optional
/// [cutout] rect. Taps inside the cutout return `false` from hitTest so they
/// fall through to widgets underneath (e.g. the highlighted FAB).
class _CutoutHitShield extends SingleChildRenderObjectWidget {
  final Rect? cutout;

  const _CutoutHitShield({this.cutout});

  @override
  _RenderCutoutHitShield createRenderObject(BuildContext context) =>
      _RenderCutoutHitShield(cutout: cutout);

  @override
  void updateRenderObject(
      BuildContext context, _RenderCutoutHitShield renderObject) {
    renderObject.cutout = cutout;
  }
}

class _RenderCutoutHitShield extends RenderProxyBox {
  _RenderCutoutHitShield({Rect? cutout}) : _cutout = cutout;

  Rect? _cutout;
  set cutout(Rect? value) {
    if (_cutout == value) return;
    _cutout = value;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // The shield fills the screen so local coords equal the global coords we
    // stored in [_cutout] (they came from render.localToGlobal earlier).
    if (_cutout != null && _cutout!.contains(position)) {
      return false;
    }
    result.add(BoxHitTestEntry(this, position));
    return true;
  }

  @override
  bool hitTestSelf(Offset position) => true;
}

// ─── Spotlight painter ────────────────────────────────────────────────────────

class _SpotlightPainter extends CustomPainter {
  final Rect? target;
  final double dim;

  _SpotlightPainter({required this.target, required this.dim});

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;
    final backgroundPaint = Paint()..color = Colors.black.withOpacity(dim);

    if (target == null) {
      canvas.drawRect(full, backgroundPaint);
      return;
    }

    final inflated = target!.inflate(10);
    final rrect = RRect.fromRectAndRadius(
      inflated,
      const Radius.circular(16),
    );

    canvas.saveLayer(full, Paint());
    canvas.drawRect(full, backgroundPaint);
    canvas.drawRRect(
      rrect,
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = AppColors.warmGold.withOpacity(0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter old) =>
      old.target != target || old.dim != dim;
}

// ─── Mid-tour step layer ──────────────────────────────────────────────────────

class _StepLayer extends ConsumerWidget {
  final MascotStep step;
  final MascotStrings strings;
  final Rect? targetRect;
  final Size screenSize;

  const _StepLayer({
    required this.step,
    required this.strings,
    required this.targetRect,
    required this.screenSize,
  });

  String _title() => _resolve(step.titleKey, strings);
  String _body() => _resolve(step.bodyKey, strings);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rect = targetRect;
    final placeAbove = rect != null && rect.center.dy > screenSize.height / 2;
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    final bubble = _Bubble(
      title: _title(),
      body: _body(),
      stepIndex: mascotSteps.indexOf(step),
      totalSteps: mascotSteps.length,
      strings: strings,
      pose: step.pose,
      waitingForAction: step.action != null,
    );

    if (rect == null) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: bubble,
          ),
        ),
      );
    }

    // Pick the side with more room. We reserve a small margin around the
    // target so the bubble can never visually overlap the highlighted control,
    // and fall back to the other side if the chosen one is too cramped.
    const minSlotHeight = 180.0;
    final spaceAbove = rect.top - safeTop - 24;
    final spaceBelow = screenSize.height - rect.bottom - safeBottom - 24;
    final effectiveAbove = placeAbove
        ? (spaceAbove >= minSlotHeight || spaceAbove >= spaceBelow)
        : (spaceBelow < minSlotHeight && spaceAbove > spaceBelow);

    if (effectiveAbove) {
      // Bubble lives in the space ABOVE the target. `reverse: true` pins
      // the content to the bottom of the slot so it sits right above the
      // highlight rather than floating up against the status bar.
      return Positioned(
        left: 16,
        right: 16,
        top: safeTop + 12,
        height: math.max(0, rect.top - safeTop - 24),
        child: SingleChildScrollView(
          reverse: true,
          child: bubble,
        ),
      );
    }

    // Bubble lives in the space BELOW the target.
    return Positioned(
      left: 16,
      right: 16,
      top: rect.bottom + 12,
      bottom: safeBottom + 12,
      child: SingleChildScrollView(
        child: bubble,
      ),
    );
  }
}

String _resolve(String key, MascotStrings s) {
  switch (key) {
    case 'welcomeTitle':
      return s.welcomeTitle;
    case 'welcomeBody':
      return s.welcomeBody;
    case 'filterTitle':
      return s.filterTitle;
    case 'filterBody':
      return s.filterBody;
    case 'addWalkIntroTitle':
      return s.addWalkIntroTitle;
    case 'addWalkIntroBody':
      return s.addWalkIntroBody;
    case 'addWalkFabTitle':
      return s.addWalkFabTitle;
    case 'addWalkFabBody':
      return s.addWalkFabBody;
    case 'addWalkManualTitle':
      return s.addWalkManualTitle;
    case 'addWalkManualBody':
      return s.addWalkManualBody;
    case 'addWalkSaveTitle':
      return s.addWalkSaveTitle;
    case 'addWalkSaveBody':
      return s.addWalkSaveBody;
    case 'addWalkDoneTitle':
      return s.addWalkDoneTitle;
    case 'addWalkDoneBody':
      return s.addWalkDoneBody;
    case 'recipeWalkIntroTitle':
      return s.recipeWalkIntroTitle;
    case 'recipeWalkIntroBody':
      return s.recipeWalkIntroBody;
    case 'recipeWalkOptionsTitle':
      return s.recipeWalkOptionsTitle;
    case 'recipeWalkOptionsBody':
      return s.recipeWalkOptionsBody;
    case 'recipeWalkPickTitle':
      return s.recipeWalkPickTitle;
    case 'recipeWalkPickBody':
      return s.recipeWalkPickBody;
    case 'recipeWalkYoutubeTitle':
      return s.recipeWalkYoutubeTitle;
    case 'recipeWalkYoutubeBody':
      return s.recipeWalkYoutubeBody;
    case 'recipesTitle':
      return s.recipesTitle;
    case 'recipesBody':
      return s.recipesBody;
    case 'learnTitle':
      return s.learnTitle;
    case 'learnBody':
      return s.learnBody;
    case 'rewardsTitle':
      return s.rewardsTitle;
    case 'rewardsBody':
      return s.rewardsBody;
    case 'profileTitle':
      return s.profileTitle;
    case 'profileBody':
      return s.profileBody;
    case 'endTitle':
      return s.endTitle;
    case 'endBody':
      return s.endBody;
    default:
      return '';
  }
}

// ─── Speech bubble widget ─────────────────────────────────────────────────────

class _Bubble extends ConsumerWidget {
  final String title;
  final String body;
  final int stepIndex;
  final int totalSteps;
  final MascotStrings strings;
  final MascotPose pose;
  final bool waitingForAction;

  const _Bubble({
    required this.title,
    required this.body,
    required this.stepIndex,
    required this.totalSteps,
    required this.strings,
    required this.pose,
    required this.waitingForAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(mascotTourProvider.notifier);
    final isLast = stepIndex == totalSteps - 1;
    final isFirst = stepIndex == 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // The mascot + speech bubble card is purely decorative. Ignoring
        // pointers here ensures the card can never steal a tap from the
        // highlighted target below (it can be drawn above the target on
        // narrow screens or when the text wraps tall).
        IgnorePointer(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MascotFigure(pose: pose, height: 110),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  decoration: BoxDecoration(
                    color: AppColors.lightBeige,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.darkGreen.withOpacity(0.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.darkGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        body,
                        style: const TextStyle(
                          color: Color(0xFF2A2A2A),
                          fontSize: 13.5,
                          height: 1.4,
                        ),
                      ),
                      if (waitingForAction) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.touch_app,
                                size: 14, color: AppColors.warmGold),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                strings.tapToContinue,
                                style: const TextStyle(
                                  color: AppColors.warmGold,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        '${stepIndex + 1} / $totalSteps',
                        style: const TextStyle(
                          color: AppColors.softGrayText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (!isFirst)
              TextButton(
                onPressed: notifier.back,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.cardBackground,
                  foregroundColor: AppColors.darkGreen,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  strings.back,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            if (!isFirst) const SizedBox(width: 8),
            TextButton(
              onPressed: notifier.skip,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.cardBackground,
                foregroundColor: AppColors.softGrayText,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                strings.skip,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            if (!waitingForAction) const SizedBox(width: 8),
            if (!waitingForAction)
              FilledButton(
                onPressed: notifier.next,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isLast ? strings.finish : strings.next,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ─── Finale layer ─────────────────────────────────────────────────────────────

class _FinaleLayer extends ConsumerWidget {
  final MascotStrings strings;
  final ConfettiController controller;

  const _FinaleLayer({required this.strings, required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(mascotTourProvider.notifier);

    return SafeArea(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: controller,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.04,
              numberOfParticles: 24,
              maxBlastForce: 22,
              minBlastForce: 8,
              gravity: 0.25,
              colors: const [
                AppColors.darkGreen,
                AppColors.mutedOlive,
                AppColors.warmGold,
                AppColors.good,
                Color(0xFFE7222A),
              ],
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MascotFigure(pose: MascotPose.end, height: 220),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.lightBeige,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.darkGreen.withOpacity(0.25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          strings.endTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.darkGreen,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          strings.endBody,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF2A2A2A),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: notifier.skip,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.darkGreen,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              strings.finish,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
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
