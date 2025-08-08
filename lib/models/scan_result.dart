import 'package:flutter/material.dart';
import 'package:app_color/theme.dart';

class ScanResult {
  final String status;
  final Color statusColor;
  final DateTime timestamp;
  final String? deviceId;
  final Map<String, dynamic>? additionalData;

  ScanResult({
    required this.status,
    required this.statusColor,
    required this.timestamp,
    this.deviceId,
    this.additionalData,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    Color statusColor;
    switch (json['status']) {
      case 'Normal':
        statusColor = AppColors.ledNormal;
        break;
      case 'Warning':
        statusColor = AppColors.ledWarning;
        break;
      case 'Critical':
        statusColor = AppColors.ledCritical;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return ScanResult(
      status: json['status'],
      statusColor: statusColor,
      timestamp: DateTime.parse(json['timestamp']),
      deviceId: json['deviceId'],
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'timestamp': timestamp.toIso8601String(),
    'deviceId': deviceId,
    'additionalData': additionalData,
  };
}
