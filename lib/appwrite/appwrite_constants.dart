// lib/appwrite/appwrite_constants.dart

class AppwriteConstants {
  static const String endpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String projectId = '69d4fc7600175f1aabb6';
  static const String databaseId = '69d4fce5000a6e19aca9';

  // ─── Collections ─────────────────────────────────────────────────────────
  static const String itemsTableId = 'item';
  static const String userProfileTableId = 'user_profile';
  static const String rewardsTableId = 'rewards';

  /// Per-user list of saved favorite recipes.
  /// Fields: ownerId, title, description, culture, ingredientsUsed[],
  /// priorityIngredientsUsed[], missingIngredients[], steps[], savedAt
  static const String recipeFavoritesTableId = 'recipe_favorites';

  /// Per-user rolling history of generated recipes (capped client-side).
  /// Same shape as favorites but uses generatedAt instead of savedAt.
  static const String recipeHistoryTableId = 'recipe_history';

  /// Per-user log of pantry events that powers the Insights screen.
  /// Fields: ownerId, timestamp, name, category, kind, daysLeftAtEvent
  static const String pantryEventsTableId = 'pantry_events';

  /// Admin-managed coupon catalog. Public-read for logged-in users.
  /// Fields: region, section, store, emoji, discount, description,
  /// pointsCost, expiryDays, colorHex, active, sortOrder
  static const String couponCatalogTableId = 'coupon_catalog';

  // ─── Functions ───────────────────────────────────────────────────────────
  static const String recipeFunctionId = '69d61f280023825a2f5b';
  static const String receiptFunctionId = '69d76bfe00255ed49499';
}
