import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../appwrite/appwrite_client.dart';
import '../appwrite/appwrite_constants.dart';
import '../models/scanned_receipt_item.dart';

class ReceiptScanResult {
  final List<ScannedReceiptItem> items;

  const ReceiptScanResult({required this.items});
}

class ReceiptScanService {
  final ImagePicker _picker = ImagePicker();
  final Functions _functions = Functions(client);

  Future<ReceiptScanResult?> scanReceiptFromCamera() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (photo == null) return null;
    return _scanFromXFile(photo);
  }

  Future<ReceiptScanResult?> scanReceiptFromGallery() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (photo == null) return null;
    return _scanFromXFile(photo);
  }

  Future<ReceiptScanResult> _scanFromXFile(XFile file) async {
    // XFile.readAsBytes() works on all platforms including web — no dart:io needed
    final bytes = await file.readAsBytes();

    // Pure-Dart compression — works on web, mobile, desktop
    final compressed = await compute(_compressImage, bytes);

    debugPrint('Original: ${bytes.length} bytes → Compressed: ${compressed.length} bytes');

    final base64Image = base64Encode(compressed);

    final execution = await _functions.createExecution(
      functionId: AppwriteConstants.receiptFunctionId,
      body: jsonEncode({'image': base64Image}),
      xasync: false,
      path: '/',
      headers: {'Content-Type': 'application/json'},
    );

    final responseBody = execution.responseBody;
    if (responseBody.isEmpty) {
      throw Exception('Empty response from receipt function.');
    }

    final decoded = jsonDecode(responseBody) as Map<String, dynamic>;

    if (decoded['ok'] != true) {
      throw Exception(decoded['error'] ?? 'Receipt parsing failed.');
    }

    final itemsRaw = (decoded['items'] as List? ?? const []);
    final items = itemsRaw
        .map((e) => ScannedReceiptItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return ReceiptScanResult(items: items);
  }
}

// Runs in a separate isolate via compute() to keep UI smooth
Uint8List _compressImage(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('Could not decode image.');

  // Resize so longest side is max 1200px — enough for receipt text
  final resized = decoded.width > decoded.height
      ? img.copyResize(decoded, width: 1200)
      : img.copyResize(decoded, height: 1200);

  // 65% JPEG quality — good balance between size and legibility
  return Uint8List.fromList(img.encodeJpg(resized, quality: 65));
}
