import 'package:appwrite/appwrite.dart';
import '../appwrite/appwrite_client.dart';
import '../appwrite/appwrite_constants.dart';

enum ItemRemovalReason { thrownAway, consumed, deleted }

class ItemRemovalService {
  /// Delete an item and optionally increment totalWasted in user profile
  /// 
  /// [itemId]: The item to delete
  /// [userId]: The owner of the item
  /// [reason]: Why the item is being removed
  /// - [ItemRemovalReason.thrownAway]: Increment totalWasted counter
  /// - [ItemRemovalReason.consumed]: Just delete, no counter update
  /// - [ItemRemovalReason.deleted]: Just delete, no counter update
  Future<void> removeItem({
    required String itemId,
    required String userId,
    required ItemRemovalReason reason,
  }) async {
    try {
      // If thrown away, increment the totalWasted counter
      if (reason == ItemRemovalReason.thrownAway) {
        await _incrementTotalWasted(userId);
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

  /// Increment the totalWasted counter in the user profile
  Future<void> _incrementTotalWasted(String userId) async {
    try {
      // Fetch current user profile
      final doc = await databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.userProfileTableId,
        documentId: userId,
      );

      final currentWasted = (doc.data['totalWasted'] as num?)?.toInt() ?? 0;

      // Update with incremented value
      await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.userProfileTableId,
        documentId: userId,
        data: {
          'totalWasted': currentWasted + 1,
        },
      );
    } catch (e) {
      throw Exception('Failed to update totalWasted: $e');
    }
  }
}
