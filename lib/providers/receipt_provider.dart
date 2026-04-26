import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/receipt_scan_service.dart';

final receiptScanServiceProvider = Provider<ReceiptScanService>((ref) {
  return ReceiptScanService();
});