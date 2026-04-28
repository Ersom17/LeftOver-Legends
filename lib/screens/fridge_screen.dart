// lib/screens/fridge_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/item.dart';
import '../models/recipe.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/mascot_tour_provider.dart';
import '../providers/recipe_favorites_provider.dart';
import '../providers/user_settings_provider.dart';
import '../widgets/item_card.dart';
import '../providers/recipe_provider.dart';
import 'recipes_screen.dart';
import 'recipe_options_sheet.dart';
import '../providers/receipt_provider.dart';
import 'receipt_review_screen.dart';
import 'rewards_screen.dart';
import 'learn_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/mascot_tour/mascot_tour_anchors.dart';
import '../widgets/mascot_tour/mascot_tour_host.dart';

class FridgeScreen extends ConsumerWidget {
  const FridgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredItemsProvider);
    final currentFilter = ref.watch(filterProvider);
    final strings = ref.watch(appStringsProvider);

    return MascotTourHost(
      child: Scaffold(
      backgroundColor: AppColors.lightBeige,
      appBar: AppBar(
        title: Text(strings.pantryTitle),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              ref.invalidate(itemsProvider);
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            key: MascotAnchors.keyFor(MascotAnchorIds.filterSegmented),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: SegmentedButton<FilterMode>(
              segments: [
                ButtonSegment(
                    value: FilterMode.all, label: Text(strings.filterAll)),
                ButtonSegment(
                  value: FilterMode.expiring,
                  label: Text(strings.filterExpiring),
                ),
                ButtonSegment(
                    value: FilterMode.fresh,
                    label: Text(strings.filterFresh)),
              ],
              selected: {currentFilter},
              onSelectionChanged: (selected) {
                ref.read(filterProvider.notifier).state = selected.first;
              },
            ),
          ),
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (items) {
                if (items.isEmpty) {
                  return Center(child: Text(strings.noItemsHere));
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(itemsProvider.notifier).refreshItems(),
                  // Single-column list: on any screen size, pantry items stack
                  // rather than sitting in a crowded grid.
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '${items.length} ${items.length == 1 ? strings.itemCountOne : strings.itemCountMany}',
                          style: const TextStyle(
                            color: AppColors.softGrayText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      KeyedSubtree(
                        key: MascotAnchors.keyFor(
                            MascotAnchorIds.generateRecipes),
                        child: _GenerateRecipesButton(items: items),
                      ),
                      const SizedBox(height: 12),
                      ...items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ItemCard(
                            item: item,
                            onTap: () => context.push('/edit', extra: item),
                            onEdit: () => context.push('/edit', extra: item),
                            onDelete: () => ref
                                .read(itemsProvider.notifier)
                                .deleteItem(item.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          MascotTourLauncher(),
          SizedBox(width: 12),
          _AddItemFab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home), label: strings.navHome),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite,
                key: MascotAnchors.keyFor(MascotAnchorIds.navRecipes)),
            label: strings.navRecipes,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book,
                key: MascotAnchors.keyFor(MascotAnchorIds.navLearn)),
            label: strings.navLearn,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard,
                key: MascotAnchors.keyFor(MascotAnchorIds.navRewards)),
            label: strings.navRewards,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,
                key: MascotAnchors.keyFor(MascotAnchorIds.navProfile)),
            label: strings.navProfile,
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            context.push('/recipes/favorites');
          }
          if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LearnScreen()),
            );
          }
          if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RewardsScreen()),
            );
          }
          if (index == 4) {
            context.push('/profile');
          }
        },
      ),
    ),
    );
  }
}

// ─── FAB ─────────────────────────────────────────────────────────────────────

class _AddItemFab extends ConsumerWidget {
  const _AddItemFab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    return FloatingActionButton.extended(
      key: MascotAnchors.keyFor(MascotAnchorIds.addItemFab),
      onPressed: () {
        ref
            .read(mascotTourProvider.notifier)
            .notifyAction(MascotActions.tapAddFab);
        _showSourcePicker(context, ref);
      },
      icon: const Icon(Icons.receipt_long),
      backgroundColor: AppColors.darkGreen,
      foregroundColor: AppColors.white,
      label: Text(
        strings.addItem,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  Future<void> _showSourcePicker(BuildContext context, WidgetRef ref) async {
    final strings = ref.read(appStringsProvider);
    final source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.lightBeige,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                key: MascotAnchors.keyFor(MascotAnchorIds.sourceManual),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add,
                      color: AppColors.darkGreen, size: 20),
                ),
                title: Text(
                  strings.addManually,
                  style: const TextStyle(
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  strings.addManuallySubtitle,
                  style: const TextStyle(
                      color: AppColors.softGrayText, fontSize: 12),
                ),
                onTap: () {
                  ref
                      .read(mascotTourProvider.notifier)
                      .notifyAction(MascotActions.tapAddManual);
                  Navigator.pop(ctx, 'manual');
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_long,
                      color: AppColors.darkGreen, size: 20),
                ),
                title: Text(
                  strings.scanReceipt,
                  style: const TextStyle(
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  strings.scanReceiptSubtitle,
                  style: const TextStyle(
                      color: AppColors.softGrayText, fontSize: 12),
                ),
                onTap: () => Navigator.pop(ctx, 'scan'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted) return;

    if (source == 'manual') {
      final tourActive = ref.read(mascotTourProvider).active;
      context.push(tourActive ? '/add?tour=1' : '/add');
      return;
    }

    if (source == 'scan') {
      await _runScan(context, ref);
    }
  }

  Future<void> _runScan(BuildContext context, WidgetRef ref) async {
    // Push a transparent full-screen overlay while scanning
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => const _ScanningOverlayPage(),
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );

    try {
      final result = await ref
          .read(receiptScanServiceProvider)
          .scanReceiptFromCamera();

      if (context.mounted) Navigator.of(context).pop();
      if (!context.mounted) return;

      if (result == null || result.items.isEmpty) {
        final strings = ref.read(appStringsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.noItemsDetected),
            backgroundColor: AppColors.darkGreen,
          ),
        );
        return;
      }

      final added = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => ReceiptReviewScreen(items: result.items),
        ),
      );

      if (added == true && context.mounted) {
        ref.read(itemsProvider.notifier).refreshItems();
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) {
        final strings = ref.read(appStringsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${strings.receiptScanFailed}: $e')),
        );
      }
    }
  }
}

// ─── Full-screen scanning overlay ────────────────────────────────────────────

class _ScanningOverlayPage extends ConsumerStatefulWidget {
  const _ScanningOverlayPage();

  @override
  ConsumerState<_ScanningOverlayPage> createState() =>
      _ScanningOverlayPageState();
}

class _ScanningOverlayPageState extends ConsumerState<_ScanningOverlayPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  int _stepIndex = 0;
  bool _alive = true;

  List<String> _scanSteps() {
    final s = ref.read(appStringsProvider);
    return [
      s.scanCapturing,
      s.scanReadingNames,
      s.scanDetectingPrices,
      s.scanEstimatingExpiry,
      s.scanAlmostDone,
    ];
  }

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _cycleSteps();
  }

  Future<void> _cycleSteps() async {
    final count = _scanSteps().length;
    while (_alive) {
      await Future.delayed(const Duration(milliseconds: 1900));
      if (!_alive || !mounted) break;
      setState(() => _stepIndex = (_stepIndex + 1) % count);
    }
  }

  @override
  void dispose() {
    _alive = false;
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final steps = _scanSteps();
    return Material(
      color: AppColors.lightBeige.withOpacity(0.96),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) => Transform.scale(
                  scale: _pulseAnim.value,
                  child: child,
                ),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.darkGreen.withOpacity(0.6),
                      width: 2.5,
                    ),
                  ),
                  child: const Center(
                    child: Text('🧾', style: TextStyle(fontSize: 52)),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: Text(
                  steps[_stepIndex],
                  key: ValueKey(_stepIndex),
                  style: const TextStyle(
                    color: AppColors.darkGreen,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.scanning,
                style: const TextStyle(
                  color: AppColors.softGrayText,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                strings.scanImperfectNotice,
                style: const TextStyle(
                  color: AppColors.softGrayText,
                  fontSize: 12,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Generate Recipes Button ──────────────────────────────────────────────────

class _GenerateRecipesButton extends ConsumerStatefulWidget {
  final List<FridgeItem> items;

  const _GenerateRecipesButton({required this.items});

  @override
  ConsumerState<_GenerateRecipesButton> createState() =>
      _GenerateRecipesButtonState();
}

class _GenerateRecipesButtonState
    extends ConsumerState<_GenerateRecipesButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    return ElevatedButton.icon(
      onPressed: _loading ? null : _generate,
      icon: _loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.restaurant_menu),
      label: Text(_loading ? strings.generating : strings.generateRecipes),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.mutedOlive,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Future<void> _generate() async {
    ref
        .read(mascotTourProvider.notifier)
        .notifyAction(MascotActions.tapGenerateRecipes);

    final defaultCulture = ref.read(userDefaultCultureProvider);
    final defaultCountry = ref.read(userCountryProvider);

    final options = await showModalBottomSheet<RecipeOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: RecipeOptionsSheet(
          defaultCulture: defaultCulture,
          defaultCountry: defaultCountry,
        ),
      ),
    );

    if (options == null) return;

    setState(() => _loading = true);
    try {
      final validItems =
          widget.items.where((item) => item.daysLeft >= 0).toList();

      final result = await ref.read(recipeServiceProvider).generateRecipes(
            items: validItems,
            culture: options.culture,
          );

      final recipesRaw =
          (result['data']?['recipes'] as List<dynamic>?) ?? [];
      final recipes = recipesRaw
          .map((r) => Recipe.fromJson(r as Map<String, dynamic>))
          .toList();

      if (recipes.isNotEmpty) {
        // Keep a rolling local history of generated recipes.
        await ref.read(recipeHistoryProvider.notifier).addMany(recipes);
      }

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RecipesScreen(
              recipes: recipes,
              fridgeItems: validItems,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final strings = ref.read(appStringsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${strings.recipesError}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
