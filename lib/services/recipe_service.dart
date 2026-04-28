import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import '../appwrite/appwrite_client.dart';
import '../appwrite/appwrite_constants.dart';
import '../models/item.dart';

class RecipeService {
  final Functions functions = Functions(client);

  Future<Map<String, dynamic>> generateRecipes({
    required List<FridgeItem> items,
    required String culture,
  }) async {
    final payload = {
      'culture': culture,
      'items': items.map((item) {
        final priority = item.daysLeft <= 1
            ? 1
            : (item.daysLeft <= 4 ? 2 : 3);

        return {
          'name': item.name,
          'expirationDate': item.expiryDate.toIso8601String(),
          'priority': priority,
        };
      }).toList(),
    };

    final execution = await functions.createExecution(
      functionId: AppwriteConstants.recipeFunctionId,
      body: jsonEncode(payload),
      xasync: false,
      path: '/',
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final responseBody = execution.responseBody;

    if (responseBody.isEmpty) {
      throw Exception('Empty response from recipe function');
    }

    final decoded = jsonDecode(responseBody) as Map<String, dynamic>;

    if (decoded['ok'] != true) {
      throw Exception(decoded['error'] ?? 'Recipe generation failed');
    }

    return decoded;
  }
}