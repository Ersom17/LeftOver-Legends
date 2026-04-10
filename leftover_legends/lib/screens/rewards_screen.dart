// lib/screens/rewards_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../providers/rewards_provider.dart';

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
      backgroundColor: const Color(0xFF1A1F1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F1C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8A9E90)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rewards',
          style: TextStyle(
            color: Color(0xFFF5EFE0),
            fontWeight: FontWeight.w900,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF5C9E6E),
          labelColor: const Color(0xFF5C9E6E),
          unselectedLabelColor: const Color(0xFF8A9E90),
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(text: 'Shop'),
            Tab(text: 'My Wallet'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Points banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3D7A56), Color(0xFF5C9E6E)],
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
                        color: Color(0xFFB8DBBE),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '$points Seeds',
                      style: const TextStyle(
                        color: Colors.white,
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
                        color: Color(0xFFB8DBBE),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '1 item consumed = 1 Seed',
                      style: TextStyle(
                        color: Color(0xFFB8DBBE),
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

// ─── Shop Tab ────────────────────────────────────────────────────────────────

class _ShopTab extends ConsumerWidget {
  final int points;
  const _ShopTab({required this.points});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionLabel('🛒 Supermarkets'),
        const SizedBox(height: 10),
        _CouponCard(
          store: 'Migros',
          emoji: '🛍️',
          color: const Color(0xFFE8A838),
          discount: '5% off your next shop',
          description: 'Valid on any purchase over CHF 30',
          pointsCost: 20,
          userPoints: points,
          expiryDays: 30,
        ),
        _CouponCard(
          store: 'Coop',
          emoji: '🏪',
          color: const Color(0xFFE84040),
          discount: '10% off fresh produce',
          description: 'Valid on fruits, vegetables & dairy',
          pointsCost: 35,
          userPoints: points,
          expiryDays: 21,
        ),
        _CouponCard(
          store: 'Denner',
          emoji: '🍷',
          color: const Color(0xFF9B59B6),
          discount: 'CHF 5 off wines',
          description: 'Valid on any bottle over CHF 12',
          pointsCost: 25,
          userPoints: points,
          expiryDays: 14,
        ),
        const SizedBox(height: 20),
        _sectionLabel('🍽️ Restaurants'),
        const SizedBox(height: 10),
        _CouponCard(
          store: 'Nordsee',
          emoji: '🐟',
          color: const Color(0xFF2980B9),
          discount: '15% off any meal',
          description: 'Valid Mon–Thu, dine-in only',
          pointsCost: 50,
          userPoints: points,
          expiryDays: 60,
        ),
        _CouponCard(
          store: 'Pizza Hut',
          emoji: '🍕',
          color: const Color(0xFFC0392B),
          discount: 'Buy 1 get 1 free pizza',
          description: 'Valid on medium or large pizzas',
          pointsCost: 80,
          userPoints: points,
          expiryDays: 30,
        ),
        _CouponCard(
          store: 'Starbucks',
          emoji: '☕',
          color: const Color(0xFF1E8449),
          discount: 'Free size upgrade',
          description: 'Upgrade any drink to the next size',
          pointsCost: 15,
          userPoints: points,
          expiryDays: 14,
        ),
        const SizedBox(height: 20),
        _sectionLabel('🌱 Eco & Organic'),
        const SizedBox(height: 10),
        _CouponCard(
          store: 'Alnatura',
          emoji: '🌿',
          color: const Color(0xFF27AE60),
          discount: '10% off entire basket',
          description: 'Organic products only, min CHF 20',
          pointsCost: 40,
          userPoints: points,
          expiryDays: 30,
        ),
        _CouponCard(
          store: 'Too Good To Go',
          emoji: '♻️',
          color: const Color(0xFF16A085),
          discount: 'CHF 3 off a magic bag',
          description: 'Rescue food, save money',
          pointsCost: 10,
          userPoints: points,
          expiryDays: 7,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: Color(0xFFF5EFE0),
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      );
}

// ─── Coupon Card ─────────────────────────────────────────────────────────────

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
        backgroundColor: const Color(0xFF232B25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Redeem coupon?',
          style: const TextStyle(
            color: Color(0xFFF5EFE0),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.store} — ${widget.discount}',
              style: const TextStyle(color: Color(0xFFF5EFE0), fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '${widget.pointsCost} Seeds',
                  style: const TextStyle(
                    color: Color(0xFF5C9E6E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  ' will be deducted',
                  style: const TextStyle(color: Color(0xFF8A9E90), fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF8A9E90))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF5C9E6E)),
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
          SnackBar(
            content: Text('🎉 Coupon saved to your wallet!'),
            backgroundColor: const Color(0xFF3D7A56),
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
        color: const Color(0xFF232B25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _canAfford
              ? widget.color.withOpacity(0.4)
              : const Color(0xFF2E3830),
        ),
      ),
      child: Stack(
        children: [
          // Dashed divider line (visual coupon effect)
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
                // Store icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.color.withOpacity(0.3)),
                  ),
                  child: Center(
                    child:
                        Text(widget.emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.store,
                        style: const TextStyle(
                          color: Color(0xFF8A9E90),
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
                              ? const Color(0xFFF5EFE0)
                              : const Color(0xFF4A5550),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.description,
                        style: const TextStyle(
                          color: Color(0xFF6E7D74),
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
                                  : const Color(0xFF4A5550),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '· ${widget.expiryDays}d validity',
                            style: const TextStyle(
                              color: Color(0xFF4A5550),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Redeem button area (right side of coupon)
                SizedBox(
                  width: 72,
                  child: _redeeming
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
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
                                    color: Color(0xFF3A4540), size: 18),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.pointsCost - widget.userPoints} more',
                                  style: const TextStyle(
                                    color: Color(0xFF3A4540),
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

// ─── Wallet Tab ───────────────────────────────────────────────────────────────

class _WalletTab extends ConsumerWidget {
  const _WalletTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsAsync = ref.watch(rewardsProvider);

    return rewardsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error: $e',
            style: const TextStyle(color: Color(0xFFF5EFE0))),
      ),
      data: (coupons) {
        if (coupons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎟️', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                const Text(
                  'No coupons yet',
                  style: TextStyle(
                    color: Color(0xFFF5EFE0),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Redeem Seeds in the Shop tab\nto save coupons here.',
                  style: TextStyle(color: Color(0xFF8A9E90), fontSize: 13),
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
          color: Color(0xFF8A9E90),
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
    final color =
        expired ? const Color(0xFF3A4540) : const Color(0xFF5C9E6E);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: expired
            ? const Color(0xFF1E2420)
            : const Color(0xFF232B25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          // Coupon code circle
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
                  style: TextStyle(
                    color: expired
                        ? const Color(0xFF4A5550)
                        : const Color(0xFF8A9E90),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  coupon.discount,
                  style: TextStyle(
                    color: expired
                        ? const Color(0xFF4A5550)
                        : const Color(0xFFF5EFE0),
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
                            ? const Color(0xFF4A5550)
                            : daysLeft <= 3
                                ? const Color(0xFFE8A838)
                                : const Color(0xFF6E7D74),
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

// ─── Dashed line painter ──────────────────────────────────────────────────────

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
