// lib/repositories/appwrite_coupon_catalog_repository.dart
//
// Read-only repository for the admin-managed coupon catalog. Public read
// (Role.users) — there's no per-user data here, so no ownerId scoping.

import 'package:appwrite/appwrite.dart';

import '../appwrite/appwrite_client.dart';
import '../appwrite/appwrite_constants.dart';
import '../models/coupon_spec.dart';

class AppwriteCouponCatalogRepository {
  /// Fetch active coupons for the given region, sorted by section then
  /// sortOrder. Region is one of `'us'` or `'europe'`.
  Future<List<CouponSpec>> getForRegion(String region) async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.couponCatalogTableId,
      queries: [
        Query.equal('region', region),
        Query.equal('active', true),
        Query.orderAsc('sortOrder'),
        Query.limit(100),
      ],
    );
    return result.documents
        .map((doc) => CouponSpec.fromAppwrite(
              Map<String, dynamic>.from(doc.data),
              doc.$id,
            ))
        .toList();
  }
}
