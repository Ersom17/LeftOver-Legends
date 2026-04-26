// lib/screens/insights_screen.dart
//
// Insights / Analysis page. Reads the local pantry event log
// (pantryEventsProvider) and shows the user how their food behaviour has
// trended: what they eat vs throw, which categories slip past expiry, and a
// short list of "names you let expire most often".
//
// All numbers come from local events — there's no server call involved here.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item.dart';
import '../providers/locale_provider.dart';
import '../providers/pantry_events_provider.dart';
import '../providers/recipe_favorites_provider.dart';
import '../theme/app_theme.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(pantryEventsProvider);
    final recipes = ref.watch(recipeHistoryProvider);
    final lang = ref.watch(localeProvider);
    final isIt = lang == AppLanguage.it;

    final stats = _InsightsStats.from(events);

    return Scaffold(
      backgroundColor: AppColors.lightBeige,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(isIt ? 'Le tue abitudini' : 'Your habits'),
      ),
      body: events.isEmpty
          ? _EmptyState(isIt: isIt)
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Hero — save rate is the headline metric.
                _HeroSaveRate(stats: stats, isIt: isIt),
                const SizedBox(height: 20),

                _SectionLabel(isIt ? 'PANORAMICA' : 'OVERVIEW'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStatCard(
                        emoji: '➕',
                        title: isIt ? 'Aggiunti' : 'Added',
                        value: stats.added.toString(),
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniStatCard(
                        emoji: '😋',
                        title: isIt ? 'Consumati' : 'Consumed',
                        value: stats.consumed.toString(),
                        color: AppColors.good,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStatCard(
                        emoji: '🗑️',
                        title: isIt ? 'Sprecati' : 'Wasted',
                        value: stats.wasted.toString(),
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniStatCard(
                        emoji: '🍳',
                        title: isIt ? 'Ricette generate' : 'Recipes generated',
                        value: recipes.length.toString(),
                        color: AppColors.warmGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // "Heads up" insight — most-wasted item name + category.
                if (stats.wasted > 0) ...[
                  _SectionLabel(isIt ? 'DA TENERE D\'OCCHIO' : 'HEADS UP'),
                  const SizedBox(height: 10),
                  if (stats.topWastedName != null)
                    _Callout(
                      emoji: '🔔',
                      title: isIt
                          ? '"${stats.topWastedName}" tende a scadere'
                          : '"${stats.topWastedName}" tends to expire on you',
                      body: isIt
                          ? 'L\'hai sprecato ${stats.topWastedNameCount} volte. Prova a comprarne meno o congelarlo prima.'
                          : 'You\'ve wasted it ${stats.topWastedNameCount} times. Try buying less or freezing it earlier.',
                    ),
                  if (stats.topWastedCategory != null) ...[
                    const SizedBox(height: 10),
                    _Callout(
                      emoji: '📊',
                      title: isIt
                          ? 'Categoria più sprecata: ${_categoryLabel(stats.topWastedCategory!, isIt)}'
                          : 'Most wasted category: ${_categoryLabel(stats.topWastedCategory!, isIt)}',
                      body: isIt
                          ? '${stats.topWastedCategoryCount} prodotti finiti nel cestino in questa categoria.'
                          : '${stats.topWastedCategoryCount} items thrown away in this category.',
                    ),
                  ],
                  const SizedBox(height: 20),
                ],

                // Per-category breakdown of consumed vs wasted.
                _SectionLabel(isIt ? 'PER CATEGORIA' : 'BY CATEGORY'),
                const SizedBox(height: 10),
                _CategoryBreakdown(stats: stats, isIt: isIt),
                const SizedBox(height: 20),

                // Recent activity, last 5 events.
                _SectionLabel(isIt ? 'ATTIVITÀ RECENTE' : 'RECENT ACTIVITY'),
                const SizedBox(height: 10),
                ...events.take(5).map((e) => _EventTile(event: e, isIt: isIt)),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

// ─── Stats model ──────────────────────────────────────────────────────────

class _InsightsStats {
  final int added;
  final int consumed;
  final int wasted;
  final int deleted;

  /// Save rate = consumed / (consumed + wasted). 0..1, or null if neither
  /// kind has happened yet.
  final double? saveRate;

  /// Per-category counts.
  final Map<ItemCategory, int> consumedByCategory;
  final Map<ItemCategory, int> wastedByCategory;

  /// Most-wasted item name (case-insensitive collapsed).
  final String? topWastedName;
  final int topWastedNameCount;

  /// Most-wasted category.
  final ItemCategory? topWastedCategory;
  final int topWastedCategoryCount;

  const _InsightsStats({
    required this.added,
    required this.consumed,
    required this.wasted,
    required this.deleted,
    required this.saveRate,
    required this.consumedByCategory,
    required this.wastedByCategory,
    required this.topWastedName,
    required this.topWastedNameCount,
    required this.topWastedCategory,
    required this.topWastedCategoryCount,
  });

  factory _InsightsStats.from(List<PantryEvent> events) {
    int added = 0, consumed = 0, wasted = 0, deleted = 0;
    final consumedByCategory = <ItemCategory, int>{};
    final wastedByCategory = <ItemCategory, int>{};
    final wastedNames = <String, int>{};

    for (final e in events) {
      switch (e.kind) {
        case PantryEventKind.added:
          added++;
          break;
        case PantryEventKind.consumed:
          consumed++;
          consumedByCategory.update(e.category, (v) => v + 1,
              ifAbsent: () => 1);
          break;
        case PantryEventKind.thrownAway:
          wasted++;
          wastedByCategory.update(e.category, (v) => v + 1,
              ifAbsent: () => 1);
          final key = e.name.trim().toLowerCase();
          if (key.isNotEmpty) {
            wastedNames.update(key, (v) => v + 1, ifAbsent: () => 1);
          }
          break;
        case PantryEventKind.deleted:
          deleted++;
          break;
      }
    }

    String? topWastedName;
    int topWastedNameCount = 0;
    wastedNames.forEach((name, count) {
      // Threshold of 2 — single waste isn't a pattern, just bad luck.
      if (count > topWastedNameCount && count >= 2) {
        topWastedName = _titleCase(name);
        topWastedNameCount = count;
      }
    });

    ItemCategory? topWastedCategory;
    int topWastedCategoryCount = 0;
    wastedByCategory.forEach((cat, count) {
      if (count > topWastedCategoryCount) {
        topWastedCategory = cat;
        topWastedCategoryCount = count;
      }
    });

    final double? saveRate = (consumed + wasted) > 0
        ? consumed / (consumed + wasted)
        : null;

    return _InsightsStats(
      added: added,
      consumed: consumed,
      wasted: wasted,
      deleted: deleted,
      saveRate: saveRate,
      consumedByCategory: consumedByCategory,
      wastedByCategory: wastedByCategory,
      topWastedName: topWastedName,
      topWastedNameCount: topWastedNameCount,
      topWastedCategory: topWastedCategory,
      topWastedCategoryCount: topWastedCategoryCount,
    );
  }
}

String _titleCase(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

String _categoryLabel(ItemCategory c, bool isIt) {
  if (isIt) {
    switch (c) {
      case ItemCategory.dairy:
        return 'Latticini';
      case ItemCategory.veggies:
        return 'Verdura';
      case ItemCategory.fruit:
        return 'Frutta';
      case ItemCategory.protein:
        return 'Proteine';
      case ItemCategory.grains:
        return 'Cereali';
      case ItemCategory.other:
        return 'Altro';
    }
  }
  switch (c) {
    case ItemCategory.dairy:
      return 'Dairy';
    case ItemCategory.veggies:
      return 'Veggies';
    case ItemCategory.fruit:
      return 'Fruit';
    case ItemCategory.protein:
      return 'Protein';
    case ItemCategory.grains:
      return 'Grains';
    case ItemCategory.other:
      return 'Other';
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isIt;
  const _EmptyState({required this.isIt});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📊', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              isIt ? 'Nessun dato ancora' : 'No data yet',
              style: const TextStyle(
                color: AppColors.darkGreen,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isIt
                  ? 'Aggiungi prodotti, segna ciò che cucini o butti via, e qui vedrai le tue tendenze.'
                  : 'Add items and mark what you cook or throw away — your patterns will show up here.',
              style: const TextStyle(
                color: AppColors.softGrayText,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSaveRate extends StatelessWidget {
  final _InsightsStats stats;
  final bool isIt;
  const _HeroSaveRate({required this.stats, required this.isIt});

  @override
  Widget build(BuildContext context) {
    final pct = stats.saveRate == null
        ? null
        : (stats.saveRate! * 100).round();
    final tagline = pct == null
        ? (isIt
            ? 'Segna i tuoi consumi per misurarti.'
            : 'Mark what you cook to start measuring.')
        : pct >= 80
            ? (isIt ? 'Ottimo lavoro!' : 'Excellent work!')
            : pct >= 50
                ? (isIt ? 'Sulla buona strada.' : 'On the right track.')
                : (isIt ? 'C\'è margine.' : 'Room to improve.');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkGreen, AppColors.mutedOlive],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIt ? 'TASSO DI SALVATAGGIO' : 'SAVE RATE',
                  style: const TextStyle(
                    color: AppColors.lightBeige,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  pct == null ? '—' : '$pct%',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tagline,
                  style: const TextStyle(
                    color: AppColors.lightBeige,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Text('🌱', style: TextStyle(fontSize: 44)),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String value;
  final Color color;

  const _MiniStatCard({
    required this.emoji,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;
  const _Callout({
    required this.emoji,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warmGold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warmGold.withOpacity(0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.darkGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.softGrayText,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final _InsightsStats stats;
  final bool isIt;
  const _CategoryBreakdown({required this.stats, required this.isIt});

  @override
  Widget build(BuildContext context) {
    // Combine the keys so a category that's only ever wasted still shows up.
    final categories = <ItemCategory>{
      ...stats.consumedByCategory.keys,
      ...stats.wastedByCategory.keys,
    }.toList();

    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          isIt
              ? 'Niente da mostrare ancora.'
              : 'Nothing to show here yet.',
          style: const TextStyle(
            color: AppColors.softGrayText,
            fontSize: 12,
          ),
        ),
      );
    }

    // Sort by total activity, descending, so the most-active categories
    // appear first.
    categories.sort((a, b) {
      final ta = (stats.consumedByCategory[a] ?? 0) +
          (stats.wastedByCategory[a] ?? 0);
      final tb = (stats.consumedByCategory[b] ?? 0) +
          (stats.wastedByCategory[b] ?? 0);
      return tb.compareTo(ta);
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: categories.map((cat) {
          final consumed = stats.consumedByCategory[cat] ?? 0;
          final wasted = stats.wastedByCategory[cat] ?? 0;
          final total = consumed + wasted;
          final ratio = total == 0 ? 0.0 : consumed / total;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _categoryLabel(cat, isIt),
                        style: const TextStyle(
                          color: AppColors.darkGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '$consumed / $total',
                      style: const TextStyle(
                        color: AppColors.softGrayText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        color: AppColors.danger.withOpacity(0.25),
                      ),
                      FractionallySizedBox(
                        widthFactor: ratio,
                        child: Container(
                          height: 6,
                          color: AppColors.good,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final PantryEvent event;
  final bool isIt;
  const _EventTile({required this.event, required this.isIt});

  String get _verb {
    if (isIt) {
      switch (event.kind) {
        case PantryEventKind.added:
          return 'aggiunto';
        case PantryEventKind.consumed:
          return 'consumato';
        case PantryEventKind.thrownAway:
          return 'buttato';
        case PantryEventKind.deleted:
          return 'eliminato';
      }
    }
    switch (event.kind) {
      case PantryEventKind.added:
        return 'added';
      case PantryEventKind.consumed:
        return 'consumed';
      case PantryEventKind.thrownAway:
        return 'thrown away';
      case PantryEventKind.deleted:
        return 'deleted';
    }
  }

  Color get _color {
    switch (event.kind) {
      case PantryEventKind.added:
        return AppColors.darkGreen;
      case PantryEventKind.consumed:
        return AppColors.good;
      case PantryEventKind.thrownAway:
        return AppColors.danger;
      case PantryEventKind.deleted:
        return AppColors.softGrayText;
    }
  }

  String _ago() {
    final diff = DateTime.now().difference(event.timestamp);
    if (diff.inMinutes < 1) return isIt ? 'adesso' : 'just now';
    if (diff.inHours < 1) {
      return isIt ? '${diff.inMinutes} min fa' : '${diff.inMinutes}m ago';
    }
    if (diff.inDays < 1) {
      return isIt ? '${diff.inHours} h fa' : '${diff.inHours}h ago';
    }
    return isIt ? '${diff.inDays} g fa' : '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: _color, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: const TextStyle(
                    color: AppColors.darkGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_categoryLabel(event.category, isIt)} · $_verb',
                  style: TextStyle(
                    color: _color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _ago(),
            style: const TextStyle(
              color: AppColors.softGrayText,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.mutedOlive,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }
}
