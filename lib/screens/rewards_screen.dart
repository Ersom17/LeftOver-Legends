// lib/screens/rewards_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/region_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/rewards_provider.dart';
import '../theme/app_theme.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rewardsProvider.notifier).refresh();
      ref.read(userProfileProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final points = profileAsync.value?.points ?? 0;

    return Scaffold(
      backgroundColor: AppColors.lightBeige,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text('Rewards'),
            const SizedBox(width: 10),
            _BetaBadge(),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.darkGreen,
          labelColor: AppColors.darkGreen,
          unselectedLabelColor: AppColors.softGrayText,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(text: 'Shop'),
            Tab(text: 'My Wallet'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                const Text('⭐', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your balance',
                      style: TextStyle(
                        color: AppColors.lightBeige,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '$points Seeds',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Eat food, earn Seeds.',
                      style: TextStyle(
                        color: AppColors.lightBeige,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '1 item consumed = 1 Seed',
                      style: TextStyle(
                        color: AppColors.lightBeige,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ShopTab(points: points),
                const _WalletTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BetaBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.warmGold.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.warmGold.withOpacity(0.5)),
      ),
      child: const Text(
        'BETA',
        style: TextStyle(
          color: AppColors.warmGold,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ─── Shop Tab ────────────────────────────────────────────────────────────────

/// Catalog entry for a coupon. Region-specific catalogs live below.
class _CouponSpec {
  final String store;
  final String emoji;
  final Color color;
  final String discount;
  final String description;
  final int pointsCost;
  final int expiryDays;

  const _CouponSpec({
    required this.store,
    required this.emoji,
    required this.color,
    required this.discount,
    required this.description,
    required this.pointsCost,
    required this.expiryDays,
  });
}

class _CouponSection {
  final String title;
  final List<_CouponSpec> items;
  const _CouponSection(this.title, this.items);
}

class _ShopTab extends ConsumerWidget {
  final int points;
  const _ShopTab({required this.points});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final region = ref.watch(regionProvider);
    final sections = region == AppRegion.us ? _usCatalog : _euCatalog;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final section in sections) ...[
          _sectionLabel(section.title),
          const SizedBox(height: 10),
          ...section.items.map(
            (s) => _CouponCard(
              store: s.store,
              emoji: s.emoji,
              color: s.color,
              discount: s.discount,
              description: s.description,
              pointsCost: s.pointsCost,
              userPoints: points,
              expiryDays: s.expiryDays,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.darkGreen,
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      );

  // ─── Switzerland / Europe catalog ───────────────────────────────────────
  static const List<_CouponSection> _euCatalog = [
    _CouponSection('🛒 Supermarkets', [
      _CouponSpec(
        store: 'Migros',
        emoji: '🛍️',
        color: AppColors.warn,
        discount: '5% off your next shop',
        description: 'Valid on any purchase over CHF 30',
        pointsCost: 20,
        expiryDays: 30,
      ),
      _CouponSpec(
        store: 'Coop',
        emoji: '🏪',
        color: AppColors.danger,
        discount: '10% off fresh produce',
        description: 'Valid on fruits, vegetables & dairy',
        pointsCost: 35,
        expiryDays: 21,
      ),
      _CouponSpec(
        store: 'Denner',
        emoji: '🍷',
        color: AppColors.warmGold,
        discount: 'CHF 5 off wines',
        description: 'Valid on any bottle over CHF 12',
        pointsCost: 25,
        expiryDays: 14,
      ),
      _CouponSpec(
        store: 'Aldi Suisse',
        emoji: '🛒',
        color: AppColors.mutedOlive,
        discount: '10% off entire basket',
        description: 'Min CHF 25, in-store only',
        pointsCost: 30,
        expiryDays: 21,
      ),
      _CouponSpec(
        store: 'Lidl',
        emoji: '🥬',
        color: AppColors.good,
        discount: 'CHF 3 off CHF 20',
        description: 'Valid on weekday shops',
        pointsCost: 18,
        expiryDays: 14,
      ),
    ]),
    _CouponSection('🍽️ Restaurants', [
      _CouponSpec(
        store: 'Nordsee',
        emoji: '🐟',
        color: AppColors.mutedOlive,
        discount: '15% off any meal',
        description: 'Valid Mon–Thu, dine-in only',
        pointsCost: 50,
        expiryDays: 60,
      ),
      _CouponSpec(
        store: 'Pizza Hut',
        emoji: '🍕',
        color: AppColors.danger,
        discount: 'Buy 1 get 1 free pizza',
        description: 'Valid on medium or large pizzas',
        pointsCost: 80,
        expiryDays: 30,
      ),
      _CouponSpec(
        store: 'Starbucks',
        emoji: '☕',
        color: AppColors.good,
        discount: 'Free size upgrade',
        description: 'Upgrade any drink to the next size',
        pointsCost: 15,
        expiryDays: 14,
      ),
    ]),
    _CouponSection('🌱 Eco & Organic', [
      _CouponSpec(
        store: 'Alnatura',
        emoji: '🌿',
        color: AppColors.darkGreen,
        discount: '10% off entire basket',
        description: 'Organic products only, min CHF 20',
        pointsCost: 40,
        expiryDays: 30,
      ),
      _CouponSpec(
        store: 'Too Good To Go',
        emoji: '♻️',
        color: AppColors.good,
        discount: 'CHF 3 off a magic bag',
        description: 'Rescue food, save money',
        pointsCost: 10,
        expiryDays: 7,
      ),
    ]),
  ];

  // ─── United States catalog ──────────────────────────────────────────────
  static const List<_CouponSection> _usCatalog = [
    _CouponSection('🛒 Supermarkets', [
      _CouponSpec(
        store: 'Walmart',
        emoji: '🛒',
        color: AppColors.warn,
        discount: '\$5 off \$40 grocery order',
        description: 'In-store or pickup, exclusions apply',
        pointsCost: 25,
        expiryDays: 30,
      ),
      _CouponSpec(
        store: 'Wegmans',
        emoji: '🥗',
        color: AppColors.darkGreen,
        discount: '10% off fresh produce',
        description: 'Valid on fruits, vegetables & deli',
        pointsCost: 35,
        expiryDays: 21,
      ),
      _CouponSpec(
        store: 'Trader Joe\'s',
        emoji: '🥑',
        color: AppColors.danger,
        discount: '\$5 off \$30',
        description: 'In-store, one per customer',
        pointsCost: 30,
        expiryDays: 21,
      ),
      _CouponSpec(
        store: 'Whole Foods',
        emoji: '🥦',
        color: AppColors.good,
        discount: '15% off organic produce',
        description: 'Prime members only, weekly limit',
        pointsCost: 45,
        expiryDays: 14,
      ),
      _CouponSpec(
        store: 'Kroger',
        emoji: '🏪',
        color: AppColors.mutedOlive,
        discount: '\$3 off \$25',
        description: 'In-store, exclusions apply',
        pointsCost: 18,
        expiryDays: 21,
      ),
    ]),
    _CouponSection('🍽️ Restaurants', [
      _CouponSpec(
        store: 'Chipotle',
        emoji: '🌯',
        color: AppColors.warmGold,
        discount: 'Free guacamole add-on',
        description: 'On any entrée, in-app or in-store',
        pointsCost: 20,
        expiryDays: 30,
      ),
      _CouponSpec(
        store: 'Starbucks',
        emoji: '☕',
        color: AppColors.good,
        discount: 'Free size upgrade',
        description: 'Upgrade any drink to the next size',
        pointsCost: 15,
        expiryDays: 14,
      ),
      _CouponSpec(
        store: 'Panera',
        emoji: '🥖',
        color: AppColors.mutedOlive,
        discount: '\$3 off any soup & sandwich',
        description: 'Valid Mon–Fri, in-app order',
        pointsCost: 25,
        expiryDays: 30,
      ),
    ]),
    _CouponSection('🌱 Eco & Organic', [
      _CouponSpec(
        store: 'Imperfect Foods',
        emoji: '🥕',
        color: AppColors.darkGreen,
        discount: '\$10 off first box',
        description: 'Rescued produce delivered to your door',
        pointsCost: 30,
        expiryDays: 30,
      ),
      _CouponSpec(
        store: 'Too Good To Go',
        emoji: '♻️',
        color: AppColors.good,
        discount: '\$3 off a Surprise Bag',
        description: 'Rescue food, save money',
        pointsCost: 10,
        expiryDays: 7,
      ),
      _CouponSpec(
        store: 'Misfits Market',
        emoji: '🥦',
        color: AppColors.warn,
        discount: '20% off your first order',
        description: 'Organic groceries shipped nationwide',
        pointsCost: 35,
        expiryDays: 21,
      ),
    ]),
  ];
}

class _CouponCard extends ConsumerStatefulWidget {
  final String store;
  final String emoji;
  final Color color;
  final String discount;
  final String description;
  final int pointsCost;
  final int userPoints;
  final int expiryDays;

  const _CouponCard({
    required this.store,
    required this.emoji,
    required this.color,
    required this.discount,
    required this.description,
    required this.pointsCost,
    required this.userPoints,
    required this.expiryDays,
  });

  @override
  ConsumerState<_CouponCard> createState() => _CouponCardState();
}

class _CouponCardState extends ConsumerState<_CouponCard> {
  bool _redeeming = false;

  bool get _canAfford => widget.userPoints >= widget.pointsCost;

  Future<void> _redeem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Redeem coupon?',
          style: TextStyle(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.store} — ${widget.discount}',
              style: const TextStyle(color: AppColors.darkGreen, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '${widget.pointsCost} Seeds',
                  style: const TextStyle(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  ' will be deducted',
                  style: TextStyle(color: AppColors.softGrayText, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.softGrayText)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _redeeming = true);
    try {
      await ref.read(rewardsProvider.notifier).redeemCoupon(
            storeName: widget.store,
            discount: widget.discount,
            pointsCost: widget.pointsCost,
            expiryDays: widget.expiryDays,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Coupon saved to your wallet!'),
            backgroundColor: AppColors.darkGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _redeeming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _canAfford
              ? widget.color.withOpacity(0.4)
              : AppColors.cardBackground,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 88,
            top: 0,
            bottom: 0,
            child: CustomPaint(painter: _DashedLinePainter(widget.color)),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.color.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(widget.emoji,
                        style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.store,
                        style: const TextStyle(
                          color: AppColors.softGrayText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.discount,
                        style: TextStyle(
                          color: _canAfford
                              ? AppColors.darkGreen
                              : AppColors.softGrayText,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.description,
                        style: const TextStyle(
                          color: AppColors.softGrayText,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '⭐ ${widget.pointsCost} Seeds',
                            style: TextStyle(
                              color: _canAfford
                                  ? widget.color
                                  : AppColors.softGrayText,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '· ${widget.expiryDays}d validity',
                            style: const TextStyle(
                              color: AppColors.softGrayText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 72,
                  child: _redeeming
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _canAfford
                          ? GestureDetector(
                              onTap: _redeem,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
                                decoration: BoxDecoration(
                                  color: widget.color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: widget.color.withOpacity(0.5)),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.redeem,
                                        color: widget.color, size: 18),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Redeem',
                                      style: TextStyle(
                                        color: widget.color,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock_outline,
                                    color: AppColors.softGrayText, size: 18),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.pointsCost - widget.userPoints} more',
                                  style: const TextStyle(
                                    color: AppColors.softGrayText,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
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

class _WalletTab extends ConsumerWidget {
  const _WalletTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsAsync = ref.watch(rewardsProvider);

    return rewardsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error: $e',
            style: const TextStyle(color: AppColors.darkGreen)),
      ),
      data: (coupons) {
        if (coupons.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🎟️', style: TextStyle(fontSize: 48)),
                SizedBox(height: 16),
                Text(
                  'No coupons yet',
                  style: TextStyle(
                    color: AppColors.darkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Redeem Seeds in the Shop tab\nto save coupons here.',
                  style: TextStyle(color: AppColors.softGrayText, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final now = DateTime.now();
        final active = coupons.where((c) => c.expiresAt.isAfter(now)).toList();
        final expired =
            coupons.where((c) => !c.expiresAt.isAfter(now)).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (active.isNotEmpty) ...[
              _walletSectionLabel('Active (${active.length})'),
              const SizedBox(height: 10),
              ...active.map((c) => _WalletCouponCard(coupon: c, expired: false)),
            ],
            if (expired.isNotEmpty) ...[
              const SizedBox(height: 20),
              _walletSectionLabel('Expired (${expired.length})'),
              const SizedBox(height: 10),
              ...expired
                  .map((c) => _WalletCouponCard(coupon: c, expired: true)),
            ],
          ],
        );
      },
    );
  }

  Widget _walletSectionLabel(String text) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.mutedOlive,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      );
}

class _WalletCouponCard extends StatelessWidget {
  final RedeemedCoupon coupon;
  final bool expired;

  const _WalletCouponCard({required this.coupon, required this.expired});

  @override
  Widget build(BuildContext context) {
    final daysLeft =
        coupon.expiresAt.difference(DateTime.now()).inDays.clamp(0, 9999);
    final color = expired ? AppColors.softGrayText : AppColors.darkGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: expired
            ? AppColors.cardBackground.withOpacity(0.5)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Center(
              child: Text(
                expired ? '✗' : '🎟️',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.storeName,
                  style: const TextStyle(
                    color: AppColors.softGrayText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  coupon.discount,
                  style: TextStyle(
                    color: expired
                        ? AppColors.softGrayText
                        : AppColors.darkGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    decoration:
                        expired ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Text(
                        coupon.couponCode,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      expired
                          ? 'Expired'
                          : '$daysLeft day${daysLeft == 1 ? '' : 's'} left',
                      style: TextStyle(
                        color: expired
                            ? AppColors.softGrayText
                            : daysLeft <= 3
                                ? AppColors.warn
                                : AppColors.softGrayText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashHeight = 5.0;
    const dashSpace = 4.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
