// lib/screens/fridge_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/item.dart';
import '../models/recipe.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../providers/user_settings_provider.dart';
import '../widgets/item_card.dart';
import '../providers/recipe_provider.dart';
import 'recipes_screen.dart';
import 'recipe_options_sheet.dart';
import '../providers/receipt_provider.dart';
import 'receipt_review_screen.dart';
import 'rewards_screen.dart';

class FridgeScreen extends ConsumerWidget {
  const FridgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredItemsProvider);
    final currentFilter = ref.watch(filterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Fridge'),
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
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: SegmentedButton<FilterMode>(
              segments: const [
                ButtonSegment(value: FilterMode.all, label: Text('All')),
                ButtonSegment(
                  value: FilterMode.expiring,
                  label: Text('Expiring'),
                ),
                ButtonSegment(value: FilterMode.fresh, label: Text('Fresh')),
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
                  return const Center(child: Text('No items here.'));
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(itemsProvider.notifier).refreshItems(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '${items.length} item${items.length == 1 ? '' : 's'}',
                        ),
                      ),
                      _GenerateRecipesButton(items: items),
                      const SizedBox(height: 12),
                      ...items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ItemCard(
                            item: item,
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
      floatingActionButton: const _AddItemFab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard), label: 'Rewards'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RewardsScreen()),
            );
          }
          if (index == 2) {
            context.push('/profile');
          }
        },
      ),
    );
  }
}

// ─── FAB ─────────────────────────────────────────────────────────────────────

class _AddItemFab extends ConsumerWidget {
  const _AddItemFab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () => _showSourcePicker(context, ref),
      icon: const Icon(Icons.receipt_long),
      label: const Text(
        'Add item',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  Future<void> _showSourcePicker(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1A1F1C),
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
                  color: const Color(0xFF2E3830),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C9E6E).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add,
                      color: Color(0xFF5C9E6E), size: 20),
                ),
                title: const Text(
                  'Add manually',
                  style: TextStyle(
                      color: Color(0xFFF5EFE0),
                      fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Fill in item details yourself',
                  style:
                      TextStyle(color: Color(0xFF6E7D74), fontSize: 12),
                ),
                onTap: () => Navigator.pop(ctx, 'manual'),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C9E6E).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_long,
                      color: Color(0xFF5C9E6E), size: 20),
                ),
                title: const Text(
                  'Scan receipt',
                  style: TextStyle(
                      color: Color(0xFFF5EFE0),
                      fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Snap a photo of your grocery receipt',
                  style:
                      TextStyle(color: Color(0xFF6E7D74), fontSize: 12),
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
      context.push('/add');
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

      // Dismiss overlay
      if (context.mounted) Navigator.of(context).pop();
      if (!context.mounted) return;

      if (result == null || result.items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No items detected on the receipt.'),
            backgroundColor: Color(0xFF3A4540),
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
      if (context.mounted) Navigator.of(context).pop(); // dismiss overlay
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receipt scan failed: $e')),
        );
      }
    }
  }
}

// ─── Full-screen scanning overlay ────────────────────────────────────────────

class _ScanningOverlayPage extends StatefulWidget {
  const _ScanningOverlayPage();

  @override
  State<_ScanningOverlayPage> createState() => _ScanningOverlayPageState();
}

class _ScanningOverlayPageState extends State<_ScanningOverlayPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  static const _steps = [
    'Capturing receipt…',
    'Reading item names…',
    'Detecting prices…',
    'Estimating expiry dates…',
    'Almost done…',
  ];
  int _stepIndex = 0;
  bool _alive = true;

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
    while (_alive) {
      await Future.delayed(const Duration(milliseconds: 1900));
      if (!_alive || !mounted) break;
      setState(() => _stepIndex = (_stepIndex + 1) % _steps.length);
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
    return Material(
      color: const Color(0xE61A1F1C), // ~90% opaque dark overlay
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing receipt icon
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
                  color: const Color(0xFF232B25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF5C9E6E).withOpacity(0.6),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5C9E6E).withOpacity(0.28),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🧾', style: TextStyle(fontSize: 52)),
                ),
              ),
            ),
            const SizedBox(height: 36),

            // Spinner
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF5C9E6E),
              ),
            ),
            const SizedBox(height: 24),

            // Animated step label
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
                _steps[_stepIndex],
                key: ValueKey(_stepIndex),
                style: const TextStyle(
                  color: Color(0xFFF5EFE0),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'AI is reading your receipt',
              style: TextStyle(
                color: Color(0xFF6E7D74),
                fontSize: 13,
              ),
            ),
          ],
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
    return ElevatedButton.icon(
      onPressed: _loading ? null : _generate,
      icon: _loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.restaurant_menu),
      label: Text(_loading ? 'Generating...' : 'Generate recipes'),
    );
  }

  Future<void> _generate() async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recipe error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
