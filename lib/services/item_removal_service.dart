import 'package:appwrite/appwrite.dart';
import '../appwrite/appwrite_client.dart';
import '../appwrite/appwrite_constants.dart';
import '../models/item.dart';

enum ItemRemovalReason { thrownAway, consumed, deleted }

class ItemRemovalService {
  /// Delete an item and update user profile stats accordingly.
  ///
  /// [ItemRemovalReason.thrownAway]: adds item price to totalWasted
  /// [ItemRemovalReason.consumed]:   adds 1 point to user profile
  /// [ItemRemovalReason.deleted]:    just deletes, no stat change
  Future<void> removeItem({
    required String itemId,
    required String userId,
    required ItemRemovalReason reason,
  }) async {
    try {
      // Fetch the item first so we have the price before deleting it
      FridgeItem? item;
      try {
        final doc = await databases.getDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.itemsTableId,
          documentId: itemId,
        );
        final data = Map<String, dynamic>.from(doc.data);
        data[r'$id'] = doc.$id;
        data[r'$createdAt'] = doc.$createdAt;
        item = FridgeItem.fromAppwrite(data);
      } catch (e) {
        // Item might already be gone — still attempt profile update with 0
        item = null;
      }

      final price = item?.price ?? 0.0;

      // Update profile stats before deleting
      if (reason == ItemRemovalReason.thrownAway) {
        await _addToTotalWasted(userId, price);
      } else if (reason == ItemRemovalReason.consumed) {
        await _addPoints(userId, 1);
      }

      // Delete the item
      await databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.itemsTableId,
        documentId: itemId,
      );
    } catch (e) {
      throw Exception('Failed to remove item: $e');
    }
  }

  /// Adds the given monetary amount to totalWasted in the user profile.
  Future<void> _addToTotalWasted(String userId, double amount) async {
    try {
      final doc = await databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.userProfileTableId,
        documentId: userId,
      );
      final current = (doc.data['totalWasted'] as num?)?.toDouble() ?? 0.0;
      await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.userProfileTableId,
        documentId: userId,
        data: {'totalWasted': current + amount},
      );
    } catch (e) {
      throw Exception('Failed to update totalWasted: $e');
    }
  }

  /// Adds points to the user profile.
  Future<void> _addPoints(String userId, int points) async {
    try {
      final doc = await databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.userProfileTableId,
        documentId: userId,
      );
      final current = (doc.data['points'] as num?)?.toInt() ?? 0;
      await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.userProfileTableId,
        documentId: userId,
        data: {'points': current + points},
      );
    } catch (e) {
      throw Exception('Failed to update points: $e');
    }
  }
}
