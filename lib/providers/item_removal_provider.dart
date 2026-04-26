import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/item_removal_service.dart';

final itemRemovalServiceProvider = Provider<ItemRemovalService>((ref) {
  return ItemRemovalService();
});
