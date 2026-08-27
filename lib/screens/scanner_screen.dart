import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../models/bag.dart';
import '../services/api_service.dart';
import '../services/bag_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController? _scannerController;
  bool _isProcessing = false;
  bool _scannerActive = true;
  String? _lastScannedCode;
  Bag? _scannedBag;
  String? _scanError;
  bool _torchEnabled = false;

  static const Color _primaryIndigo = Color(0xFF6366F1);
  static const Color _successGreen = Color(0xFF10B981);
  static const Color _errorRed = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing || !_scannerActive) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    // Skip if same code scanned again
    if (code == _lastScannedCode && _scannedBag != null) return;

    setState(() {
      _isProcessing = true;
      _scanError = null;
      _scannedBag = null;
      _lastScannedCode = code;
    });

    try {
      final response = await BagService.scanBag(code);

      if (response['success'] == true && response['data'] != null) {
        final bag = Bag.fromJson(response['data']);
        setState(() {
          _scannedBag = bag;
          _scanError = null;
        });
      } else {
        setState(() {
          _scanError = response['message'] ?? 'Sac non trouve';
        });
      }
    } on ApiException catch (e) {
      setState(() {
        _scanError = e.message;
      });
    } catch (e) {
      setState(() {
        _scanError = 'Erreur: $e';
      });
    }

    setState(() {
      _isProcessing = false;
    });
  }

  void _resetScan() {
    setState(() {
      _scannedBag = null;
      _scanError = null;
      _lastScannedCode = null;
      _scannerActive = true;
    });
  }

  void _toggleTorch() {
    _scannerController?.toggleTorch();
    setState(() {
      _torchEnabled = !_torchEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDark),

            // Scanner area
            Expanded(
              flex: _scannedBag != null || _scanError != null ? 2 : 3,
              child: _buildScannerArea(isDark),
            ),

            // Result area
            if (_scannedBag != null || _scanError != null || _isProcessing)
              Expanded(
                flex: 3,
                child: _buildResultArea(isDark),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'Scanner',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const Spacer(),
          // Torch toggle
          GestureDetector(
            onTap: _toggleTorch,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _torchEnabled
                    ? _primaryIndigo.withAlpha(20)
                    : (isDark
                        ? Colors.white.withAlpha(8)
                        : Colors.black.withAlpha(5)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _torchEnabled ? Iconsax.flash_15 : Iconsax.flash_slash,
                color: _torchEnabled
                    ? _primaryIndigo
                    : (isDark ? Colors.white : Colors.black),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerArea(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _scannedBag != null
              ? _successGreen.withAlpha(100)
              : (_scanError != null
                  ? _errorRed.withAlpha(100)
                  : _primaryIndigo.withAlpha(60)),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: _scannerController,
            onDetect: _onBarcodeDetected,
          ),

          // Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withAlpha(100),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withAlpha(128),
              child: const Center(
                child: CircularProgressIndicator(
                  color: _primaryIndigo,
                  strokeWidth: 2,
                ),
              ),
            ),

          // Bottom instruction
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(153),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isProcessing
                      ? 'Recherche...'
                      : 'Scannez le code-barres du sac',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultArea(bool isDark) {
    if (_isProcessing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: _primaryIndigo,
              strokeWidth: 2,
            ),
            const SizedBox(height: 16),
            Text(
              'Recherche du sac...',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (_scanError != null) {
      return _buildErrorResult(isDark);
    }

    if (_scannedBag != null) {
      return _buildBagResult(isDark);
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorResult(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _errorRed.withAlpha(50)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _errorRed.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.close_circle,
              color: _errorRed,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sac non trouve',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _scanError!,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          if (_lastScannedCode != null) ...[
            const SizedBox(height: 8),
            Text(
              'Code: $_lastScannedCode',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _resetScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryIndigo,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Scanner a nouveau',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBagResult(bool isDark) {
    final bag = _scannedBag!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Success header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141414) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _successGreen.withAlpha(50)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _successGreen.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Iconsax.tick_circle,
                        color: _successGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bag.trackingNumber,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            bag.displayStatusLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: bag.displayStatusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: bag.displayStatusColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.box_1,
                            size: 14,
                            color: bag.displayStatusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${bag.packageCount}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: bag.displayStatusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Route
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withAlpha(5)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Iconsax.location,
                        size: 16,
                        color: _primaryIndigo,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bag.originName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                      ),
                      const Icon(
                        Iconsax.flag,
                        size: 16,
                        color: _successGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bag.destinationName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                if (bag.sealedAt != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Iconsax.calendar_1,
                        size: 14,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Scelle: ${_formatDateTime(bag.sealedAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Scan again button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _resetScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryIndigo,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Scanner un autre sac',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
