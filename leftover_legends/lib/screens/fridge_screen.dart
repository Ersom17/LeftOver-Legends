// lib/screens/fridge_screen.dart
// R3 — Main fridge list. Engineer 1 owns this file.
// Reads from itemsProvider — works with mock data on day 1.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../widgets/item_card.dart';

class FridgeScreen extends ConsumerWidget {
  const FridgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F1C),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning 🌿',
              style: TextStyle(
                color: Color(0xFF8A9E90),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'My Fridge',
              style: TextStyle(
                color: Color(0xFFF5EFE0),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          // Streak badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F1C),
              border: Border.all(color: const Color(0xFFE8A83840)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Text('🔥', style: TextStyle(fontSize: 14)),
                SizedBox(width: 4),
                Text(
                  '12',
                  style: TextStyle(
                    color: Color(0xFFE8A838),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF5C9E6E)),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: Color(0xFFF5EFE0))),
        ),
        data: (items) => items.isEmpty
            ? _buildEmptyState()
            : _buildList(context, ref, items),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        backgroundColor: const Color(0xFF5C9E6E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildList(
      BuildContext context, WidgetRef ref, List<FridgeItem> items) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      children: [
        // Expiry alert banner (if any danger items)
        if (items.any((i) => i.status == ExpiryStatus.danger))
          _buildAlertBanner(items.firstWhere(
              (i) => i.status == ExpiryStatus.danger)),
        const SizedBox(height: 8),

        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fridge Contents',
                style: TextStyle(
                  color: Color(0xFFD9CEB2),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.4,
                ),
              ),
              Text(
                '${items.length} items',
                style: const TextStyle(
                  color: Color(0xFF8A9E90),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        // Item cards
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ItemCard(
                item: item,
                onDelete: () =>
                    ref.read(itemsProvider.notifier).deleteItem(item.id),
              ),
            )),
      ],
    );
  }

  Widget _buildAlertBanner(FridgeItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F1C),
        border: Border.all(color: const Color(0xFFE8A83840)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('⏰', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${item.name} expires soon! · Tap to take action',
              style: const TextStyle(
                color: Color(0xFFE8A838),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Text('›',
              style: TextStyle(color: Color(0xFFE8A83888), fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🎉', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text(
            'Your fridge is clear!',
            style: TextStyle(
              color: Color(0xFF8A9E90),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF242C27),
      selectedItemColor: const Color(0xFF7FAF8A),
      unselectedItemColor: const Color(0xFF8A9E90),
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
