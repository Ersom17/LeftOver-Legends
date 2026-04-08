import 'package:appwrite/appwrite.dart';
import '../appwrite/appwrite_client.dart';
import '../appwrite/appwrite_constants.dart';
import '../models/item.dart';
import 'item_repository.dart';

class AppwriteItemRepository implements ItemRepository {
  final String ownerId;

  AppwriteItemRepository(this.ownerId);

  @override
  Future<List<FridgeItem>> getAll() async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.itemsTableId,
      queries: [
        Query.equal('ownerId', ownerId),
        Query.orderAsc('expirationDate'),
      ],
    );

    return result.documents.map((doc) {
      final data = Map<String, dynamic>.from(doc.data);
      data[r'$id'] = doc.$id;
      data[r'$createdAt'] = doc.$createdAt;
      return FridgeItem.fromAppwrite(data);
    }).toList();
  }

  @override
  Future<void> add(FridgeItem item) async {
    await databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.itemsTableId,
      documentId: ID.unique(),
      data: item.toAppwriteMap(),
      permissions: [
        Permission.read(Role.user(item.ownerId)),
        Permission.update(Role.user(item.ownerId)),
        Permission.delete(Role.user(item.ownerId)),
      ],
    );
  }

  @override
  Future<void> delete(String id) async {
    await databases.deleteDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.itemsTableId,
      documentId: id,
    );
  }

  @override
  Future<void> update(FridgeItem item) async {
    await databases.updateDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.itemsTableId,
      documentId: item.id,
      data: item.toAppwriteMap(),
    );
  }
}