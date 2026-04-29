// lib/repositories/appwrite_recipe_favorites_repository.dart
//
// Per-user saved favorite recipes. Mirrors the AppwriteItemRepository
// pattern: scoped to one ownerId, exposes getAll / add / delete.
//
// We do not expose a generic update API — favorites are toggle-only, so
// callers add the recipe (with a fresh document) or delete by docId.

import 'package:appwrite/appwrite.dart';
import '../appwrite/appwrite_client.dart';
import '../appwrite/appwrite_constants.dart';
import '../models/recipe.dart';

class StoredRecipe {
  /// Appwrite document id — needed to delete the favorite later.
  final String docId;
  final Recipe recipe;
  final DateTime savedAt;

  const StoredRecipe({
    required this.docId,
    required this.recipe,
    required this.savedAt,
  });
}

class AppwriteRecipeFavoritesRepository {
  final String ownerId;
  AppwriteRecipeFavoritesRepository(this.ownerId);

  /// Newest first.
  Future<List<StoredRecipe>> getAll() async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.recipeFavoritesTableId,
      queries: [
        Query.equal('ownerId', ownerId),
        Query.orderDesc('savedAt'),
        Query.limit(100),
      ],
    );
    return result.documents.map(_fromDoc).toList();
  }

  Future<void> add(Recipe recipe) async {
    await databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.recipeFavoritesTableId,
      documentId: ID.unique(),
      data: _toMap(recipe),
      permissions: [
        Permission.read(Role.user(ownerId)),
        Permission.update(Role.user(ownerId)),
        Permission.delete(Role.user(ownerId)),
      ],
    );
  }

  Future<void> deleteByDocId(String docId) async {
    await databases.deleteDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.recipeFavoritesTableId,
      documentId: docId,
    );
  }

  /// Convenience: delete by (title, culture) — matches the existing
  /// `isFavorite` heuristic so toggles by Recipe object still work.
  Future<void> deleteByTitleCulture(String title, String culture) async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.recipeFavoritesTableId,
      queries: [
        Query.equal('ownerId', ownerId),
        Query.equal('title', title),
        Query.equal('culture', culture),
        Query.limit(10),
      ],
    );
    for (final doc in result.documents) {
      await databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.recipeFavoritesTableId,
        documentId: doc.$id,
      );
    }
  }

  Map<String, dynamic> _toMap(Recipe r) => {
        'ownerId': ownerId,
        'title': r.title,
        'description': r.description,
        'culture': r.culture,
        'ingredientsUsed': r.ingredientsUsed,
        'priorityIngredientsUsed': r.priorityIngredientsUsed,
        'missingIngredients': r.missingIngredients,
        'steps': r.steps,
        'savedAt': DateTime.now().toIso8601String(),
      };

  StoredRecipe _fromDoc(dynamic doc) {
    final data = Map<String, dynamic>.from(doc.data);
    final recipe = Recipe(
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      culture: data['culture'] as String? ?? '',
      ingredientsUsed:
          List<String>.from(data['ingredientsUsed'] ?? const []),
      priorityIngredientsUsed:
          List<String>.from(data['priorityIngredientsUsed'] ?? const []),
      missingIngredients:
          List<String>.from(data['missingIngredients'] ?? const []),
      steps: List<String>.from(data['steps'] ?? const []),
    );
    final savedAt = DateTime.tryParse(data['savedAt'] as String? ?? '') ??
        DateTime.now();
    return StoredRecipe(
      docId: doc.$id as String,
      recipe: recipe,
      savedAt: savedAt,
    );
  }
}
