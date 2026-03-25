// lib/screens/fridge_screen.dart
// R3/R4 — Main fridge list with filter switching.

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
    final filteredAsync = ref.watch(filteredItemsProvider);
    final currentFilter = ref.watch(filterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Fridge'),
      ),
      body: Column(
        children: [
          // Filter switcher
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: SegmentedButton<FilterMode>(
              segments: const [
                ButtonSegment(value: FilterMode.all, label: Text('All')),
                ButtonSegment(
                    value: FilterMode.expiring, label: Text('Expiring')),
                ButtonSegment(value: FilterMode.fresh, label: Text('Fresh')),
              ],
              selected: {currentFilter},
              onSelectionChanged: (selected) {
                ref.read(filterProvider.notifier).state = selected.first;
              },
            ),
          ),

          // Item list
          Expanded(
            child: filteredAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('No items here.'));
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  children: [
                    // Item count
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('${items.length} item${items.length == 1 ? '' : 's'}'),
                    ),

                    // Item cards
                    ...items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ItemCard(
                            item: item,
                            onDelete: () => ref
                                .read(itemsProvider.notifier)
                                .deleteItem(item.id),
                          ),
                        )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
