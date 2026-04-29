// lib/providers/mascot_tour_provider.dart
//
// Drives the interactive mascot walkthrough. The tour runs automatically
// on the user's first visit to the pantry and can be replayed from the
// "?" button or the profile screen.
//
// Steps are either:
//   - passive: user taps Next to advance, OR
//   - action-gated: user must perform a real in-app action (tap FAB,
//     tap Save, etc.). The UI calls [notifyAction] and the tour advances
//     only if the incoming action matches the current step.
//
// Persistence is dual: a SharedPreferences flag for instant boot, plus
// the user_profile.mascotTourCompleted column so the "seen" state follows
// the user across devices.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/mascot_tour/mascot_tour_anchors.dart';
import 'user_profile_provider.dart';

enum MascotPose { left, right, up, end }

/// Action identifiers that gate step advancement. When a step declares
/// an action, the "Next" button is hidden and the tour waits until the
/// corresponding tap handler calls `notifyAction(actionId)`.
class MascotActions {
  static const tapAddFab = 'tap_add_fab';
  static const tapAddManual = 'tap_add_manual';
  static const tapSaveItem = 'tap_save_item';
  static const tapGenerateRecipes = 'tap_generate_recipes';
  static const tapConfirmRecipeOptions = 'tap_confirm_recipe_options';
  static const tapRecipeCard = 'tap_recipe_card';
  static const tapYoutubeButton = 'tap_youtube_button';
}

class MascotStep {
  final String? anchorId; // null = free-floating (welcome / end)
  final MascotPose pose;
  final String titleKey;
  final String bodyKey;
  final String? action; // when set, waits for notifyAction(action)
  final bool isFinale;

  const MascotStep({
    this.anchorId,
    required this.pose,
    required this.titleKey,
    required this.bodyKey,
    this.action,
    this.isFinale = false,
  });
}

const mascotSteps = <MascotStep>[
  // ─── Welcome ──────────────────────────────────────────────────────────────
  MascotStep(
    pose: MascotPose.up,
    titleKey: 'welcomeTitle',
    bodyKey: 'welcomeBody',
  ),

  // ─── Pantry orientation ───────────────────────────────────────────────────
  MascotStep(
    anchorId: MascotAnchorIds.filterSegmented,
    pose: MascotPose.up,
    titleKey: 'filterTitle',
    bodyKey: 'filterBody',
  ),

  // ─── Add-item walkthrough (prefilled) ────────────────────────────────────
  MascotStep(
    pose: MascotPose.right,
    titleKey: 'addWalkIntroTitle',
    bodyKey: 'addWalkIntroBody',
  ),
  MascotStep(
    anchorId: MascotAnchorIds.addItemFab,
    pose: MascotPose.right,
    titleKey: 'addWalkFabTitle',
    bodyKey: 'addWalkFabBody',
    action: MascotActions.tapAddFab,
  ),
  MascotStep(
    anchorId: MascotAnchorIds.sourceManual,
    pose: MascotPose.right,
    titleKey: 'addWalkManualTitle',
    bodyKey: 'addWalkManualBody',
    action: MascotActions.tapAddManual,
  ),
  MascotStep(
    anchorId: MascotAnchorIds.addItemSave,
    pose: MascotPose.up,
    titleKey: 'addWalkSaveTitle',
    bodyKey: 'addWalkSaveBody',
    action: MascotActions.tapSaveItem,
  ),
  MascotStep(
    pose: MascotPose.up,
    titleKey: 'addWalkDoneTitle',
    bodyKey: 'addWalkDoneBody',
  ),

  // ─── Recipe walkthrough ───────────────────────────────────────────────────
  MascotStep(
    anchorId: MascotAnchorIds.generateRecipes,
    pose: MascotPose.right,
    titleKey: 'recipeWalkIntroTitle',
    bodyKey: 'recipeWalkIntroBody',
    action: MascotActions.tapGenerateRecipes,
  ),
  MascotStep(
    anchorId: MascotAnchorIds.recipeOptionsConfirm,
    pose: MascotPose.up,
    titleKey: 'recipeWalkOptionsTitle',
    bodyKey: 'recipeWalkOptionsBody',
    action: MascotActions.tapConfirmRecipeOptions,
  ),
  MascotStep(
    anchorId: MascotAnchorIds.recipeCardFirst,
    pose: MascotPose.up,
    titleKey: 'recipeWalkPickTitle',
    bodyKey: 'recipeWalkPickBody',
    action: MascotActions.tapRecipeCard,
  ),
  MascotStep(
    anchorId: MascotAnchorIds.recipeYoutube,
    pose: MascotPose.left,
    titleKey: 'recipeWalkYoutubeTitle',
    bodyKey: 'recipeWalkYoutubeBody',
  ),

  // ─── Bottom-nav orientation ──────────────────────────────────────────────
  MascotStep(
    anchorId: MascotAnchorIds.navRecipes,
    pose: MascotPose.left,
    titleKey: 'recipesTitle',
    bodyKey: 'recipesBody',
  ),
  MascotStep(
    anchorId: MascotAnchorIds.navLearn,
    pose: MascotPose.left,
    titleKey: 'learnTitle',
    bodyKey: 'learnBody',
  ),
  MascotStep(
    anchorId: MascotAnchorIds.navRewards,
    pose: MascotPose.left,
    titleKey: 'rewardsTitle',
    bodyKey: 'rewardsBody',
  ),
  MascotStep(
    anchorId: MascotAnchorIds.navProfile,
    pose: MascotPose.left,
    titleKey: 'profileTitle',
    bodyKey: 'profileBody',
  ),

  // ─── Finale ───────────────────────────────────────────────────────────────
  MascotStep(
    pose: MascotPose.end,
    titleKey: 'endTitle',
    bodyKey: 'endBody',
    isFinale: true,
  ),
];

class MascotTourState {
  final bool active;
  final int stepIndex;
  final bool firstVisitChecked;

  const MascotTourState({
    required this.active,
    required this.stepIndex,
    required this.firstVisitChecked,
  });

  MascotStep get step => mascotSteps[stepIndex];

  MascotTourState copyWith({
    bool? active,
    int? stepIndex,
    bool? firstVisitChecked,
  }) =>
      MascotTourState(
        active: active ?? this.active,
        stepIndex: stepIndex ?? this.stepIndex,
        firstVisitChecked: firstVisitChecked ?? this.firstVisitChecked,
      );
}

class MascotTourNotifier extends Notifier<MascotTourState> {
  static const _prefKey = 'mascot_tour_complete';

  @override
  MascotTourState build() {
    _listenToProfile();
    return const MascotTourState(
      active: false,
      stepIndex: 0,
      firstVisitChecked: false,
    );
  }

  /// Adopt the server-side completion flag the first time the profile
  /// lands. We never *demote* completed → not-completed from here — that
  /// path goes through [restart] which owns the round-trip writeback.
  void _listenToProfile() {
    ref.listen(userProfileProvider, (_, next) {
      final profile = next.value;
      if (profile == null) return;
      if (!profile.mascotTourCompleted) return;
      // Persist the local flag so the next cold launch doesn't auto-start.
      SharedPreferences.getInstance().then((p) => p.setBool(_prefKey, true));
      if (state.active) {
        // The tour was running locally but the server says it's done —
        // probably another device finished it. Stop without re-firing the
        // server write.
        state = state.copyWith(active: false, firstVisitChecked: true);
      }
    });
  }

  /// Called once by the pantry screen. If the user has never seen the tour,
  /// it starts automatically; otherwise it stays dormant until restart().
  Future<void> maybeStartFirstRun() async {
    if (state.firstVisitChecked) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final localDone = prefs.getBool(_prefKey) ?? false;
      // Cross-device hint: if any synced profile has marked this complete,
      // honor that even if the local cache hasn't caught up.
      final serverDone =
          ref.read(userProfileProvider).value?.mascotTourCompleted ?? false;
      final done = localDone || serverDone;
      state = state.copyWith(
        firstVisitChecked: true,
        active: !done,
        stepIndex: 0,
      );
    } catch (e) {
      debugPrint('Mascot tour flag read failed: $e');
      state = state.copyWith(firstVisitChecked: true);
    }
  }

  /// True when the current step is waiting for a user action rather than
  /// a Next-button press.
  bool get waitingForAction =>
      state.active && state.step.action != null;

  /// Tap handlers call this. Advances only if the running step is
  /// waiting for this specific action.
  void notifyAction(String actionId) {
    if (!state.active) return;
    final current = state.step.action;
    if (current == null || current != actionId) return;
    _advance();
  }

  void next() {
    if (!state.active) return;
    // Block Next for action-gated steps — the user must do the thing.
    if (state.step.action != null) return;
    _advance();
  }

  void _advance() {
    if (state.stepIndex >= mascotSteps.length - 1) {
      _finish();
      return;
    }
    state = state.copyWith(stepIndex: state.stepIndex + 1);
  }

  void back() {
    if (!state.active) return;
    if (state.stepIndex == 0) return;
    state = state.copyWith(stepIndex: state.stepIndex - 1);
  }

  Future<void> skip() => _finish();

  Future<void> restart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, false);
    } catch (e) {
      debugPrint('Mascot tour flag reset failed: $e');
    }
    // Mirror to the profile so other devices know the user wants the
    // tour again.
    await ref.read(userProfileProvider.notifier).updateTourState(
          completed: false,
          stepIndex: 0,
        );
    state = state.copyWith(active: true, stepIndex: 0);
  }

  Future<void> _finish() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, true);
    } catch (e) {
      debugPrint('Mascot tour flag write failed: $e');
    }
    final lastIndex = state.stepIndex;
    await ref.read(userProfileProvider.notifier).updateTourState(
          completed: true,
          stepIndex: lastIndex,
        );
    state = state.copyWith(active: false, stepIndex: 0);
  }
}

final mascotTourProvider =
    NotifierProvider<MascotTourNotifier, MascotTourState>(
        MascotTourNotifier.new);
