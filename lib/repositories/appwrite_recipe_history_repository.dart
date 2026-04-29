// lib/repositories/appwrite_recipe_history_repository.dart
//
// Per-user rolling history of generated recipes. Capped to [maxEntries] —
// adding a new batch evicts the oldest documents so the collection size
// stays bounded.

import 'package:appwrite/appwrite.dart';
import '../appwrite/appwrite_client.dart';
import '../appwrite/appwrite_constants.dart';
import '../models/recipe.dart';

class AppwriteRecipeHistoryRepository {
  final String ownerId;
  static const int maxEntries = 20;

  AppwriteRecipeHistoryRepository(this.ownerId);

  Future<List<Recipe>> getAll() async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.recipeHistoryTableId,
      queries: [
        Query.equal('ownerId', ownerId),
        Query.orderDesc('generatedAt'),
        Query.limit(maxEntries),
      ],
    );
    return result.documents.map(_recipeFromDoc).toList();
  }

  /// Insert recipes (newest first) and prune the tail beyond [maxEntries].
  /// Dedupe by (title, culture) within the incoming batch and against any
  /// existing entries, mirroring the previous local-only behavior.
  Future<void> addMany(List<Recipe> recipes) async {
    if (recipes.isEmpty) return;

    // Existing keys to avoid duplicates.
    final existing = await _allDocs();
    final existingKeys = existing
        .map((d) => '${d.data['title']}|${d.data['culture']}')
        .toSet();

    final now = DateTime.now();
    int n = 0;
    for (final r in recipes) {
      final key = '${r.title}|${r.culture}';
      if (existingKeys.contains(key)) continue;
      // Spread the timestamps so orderDesc gives a stable order.
      final ts = now.subtract(Duration(milliseconds: n));
      n++;
      await databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.recipeHistoryTableId,
        documentId: ID.unique(),
        data: {
          'ownerId': ownerId,
          'title': r.title,
          'description': r.description,
          'culture': r.culture,
          'ingredientsUsed': r.ingredientsUsed,
          'priorityIngredientsUsed': r.priorityIngredientsUsed,
          'missingIngredients': r.missingIngredients,
          'steps': r.steps,
          'generatedAt': ts.toIso8601String(),
        },
        permissions: [
          Permission.read(Role.user(ownerId)),
          Permission.update(Role.user(ownerId)),
          Permission.delete(Role.user(ownerId)),
        ],
      );
      existingKeys.add(key);
    }

    await _prune();
  }

  Future<void> _prune() async {
    final all = await _allDocs();
    if (all.length <= maxEntries) return;
    final toDelete = all.skip(maxEntries);
    for (final doc in toDelete) {
      await databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.recipeHistoryTableId,
        documentId: doc.$id,
      );
    }
  }

  Future<List<dynamic>> _allDocs() async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.recipeHistoryTableId,
      queries: [
        Query.equal('ownerId', ownerId),
        Query.orderDesc('generatedAt'),
        // 100 is more than the cap so prune always sees the full picture.
        Query.limit(100),
      ],
    );
    return result.documents;
  }

  Recipe _recipeFromDoc(dynamic doc) {
    final data = Map<String, dynamic>.from(doc.data);
    return Recipe(
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
  }
}
