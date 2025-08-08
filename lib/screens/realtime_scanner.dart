import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:network_led_scanner/models/scan_result.dart';
import 'package:network_led_scanner/services/led_detector_service.dart';
import 'package:network_led_scanner/utils/colors.dart';

class RealtimeScannerScreen extends StatefulWidget {
  const RealtimeScannerScreen({super.key});

  @override
  _RealtimeScannerScreenState createState() => _RealtimeScannerScreenState();
}

class _RealtimeScannerScreenState extends State<RealtimeScannerScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isScanning = false;
  ScanResult? _lastResult;
  List<ScanResult> _history = [];
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      ),
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture;
    setState(() {});
  }

  void _toggleScanning() {
    if (_isScanning) {
      _stopScanning();
    } else {
      _startScanning();
    }
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _lastResult = ScanResult(
        status: 'Scanning...',
        statusColor: AppColors.primary,
        timestamp: DateTime.now(),
      );
    });

    _scanTimer = Timer.periodic(const Duration(milliseconds: 800), (
      timer,
    ) async {
      if (!_isScanning) {
        timer.cancel();
        return;
      }

      try {
        final result = await LedDetectorService.scanFrame(_controller);
        setState(() {
          _lastResult = result;
          _history.insert(0, result);
          if (_history.length > 20) {
            _history.removeLast();
          }
        });
      } catch (e) {
        debugPrint('Scan error: $e');
      }
    });
  }

  void _stopScanning() {
    _scanTimer?.cancel();
    setState(() {
      _isScanning = false;
      _lastResult = ScanResult(
        status: 'Scan Stopped',
        statusColor: AppColors.textSecondary,
        timestamp: DateTime.now(),
      );
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                _buildDetectionOverlay(),
                _buildHistoryPanel(),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleScanning,
        icon: Icon(_isScanning ? Icons.stop : Icons.play_arrow),
        label: Text(_isScanning ? 'STOP' : 'SCAN'),
        backgroundColor: _isScanning
            ? AppColors.ledCritical
            : AppColors.primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDetectionOverlay() {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'LED STATUS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _lastResult?.statusColor ?? AppColors.textSecondary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_lastResult?.statusColor ??
                                    AppColors.textSecondary)
                                .withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _lastResult?.status ?? 'Ready to scan',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryPanel() {
    if (_history.isEmpty) return const SizedBox();

    return Positioned(
      bottom: 100,
      right: 16,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECENT SCANS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._history
                .take(3)
                .map(
                  (result) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: result.statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result.status,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${result.timestamp.hour}:${result.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  void _showInstructions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'How to Scan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInstructionStep(
              number: 1,
              title: 'Position Your Device',
              description:
                  'Hold your camera close to the network equipment LED',
            ),
            _buildInstructionStep(
              number: 2,
              title: 'Start Scanning',
              description: 'Tap the SCAN button to begin detection',
            ),
            _buildInstructionStep(
              number: 3,
              title: 'View Results',
              description: 'LED status will appear at the top of the screen',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('GOT IT'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep({
    required int number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
