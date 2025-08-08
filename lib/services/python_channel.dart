import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:server_scanning/models/scan_result.dart';

class PythonChannel {
  static const MethodChannel _channel = const MethodChannel(
    'com.example.server_scanning/python',
  );

  static Future<ScanResult> analyzeFrame(List<int> imageBytes) async {
    try {
      // Jika Python berjalan sebagai local server
      final result = await _channel.invokeMethod('analyze_frame', {
        'image': imageBytes,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return ScanResult.fromJson(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      return ScanResult(
        status: 'Error: ${e.message}',
        statusColor: Colors.red,
        timestamp: DateTime.now(),
      );
    }
  }
}
