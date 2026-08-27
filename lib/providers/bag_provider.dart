import 'package:flutter/material.dart';
import '../models/bag.dart';
import '../services/bag_service.dart';

class BagProvider with ChangeNotifier {
  List<Bag> _allBags = [];
  List<Bag> _inTransitBags = [];
  List<Bag> _completedBags = [];
  List<Map<String, dynamic>> _manifests = [];
  Map<String, dynamic>? _activeManifest;
  bool _isLoading = false;
  String? _error;

  List<Bag> get allBags => _allBags;
  List<Bag> get inTransitBags => _inTransitBags;
  List<Bag> get completedBags => _completedBags;
  List<Map<String, dynamic>> get manifests => _manifests;
  Map<String, dynamic>? get activeManifest => _activeManifest;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Stats
  int get totalInTransit => _inTransitBags.length;
  int get totalCompleted => _completedBags.length;
  int get totalPackagesInTransit {
    return _inTransitBags.fold(0, (sum, bag) => sum + bag.packageCount);
  }

  int get totalPackagesCompleted {
    return _completedBags.fold(0, (sum, bag) => sum + bag.packageCount);
  }

  int get totalBags => _allBags.length;

  /// Load all bags for the driver
  Future<void> loadBags({int? driverId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch bags in transit
      _inTransitBags = await BagService.fetchBags(
        status: 'in_transit',
        driverId: driverId,
      );

      // Fetch completed bags (arrived + unpacked + delivered)
      _completedBags = await BagService.fetchBags(
        status: 'arrived_destination,unpacked,delivered',
        driverId: driverId,
      );

      // Combine all
      _allBags = [..._inTransitBags, ..._completedBags];

      debugPrint(
        'Loaded bags: ${_inTransitBags.length} in transit, '
        '${_completedBags.length} completed',
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading bags: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load manifests for the driver
  Future<void> loadManifests() async {
    try {
      _manifests = await BagService.fetchManifests();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading manifests: $e');
    }
  }

  /// Load active manifest
  Future<void> loadActiveManifest() async {
    try {
      _activeManifest = await BagService.fetchActiveManifest();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading active manifest: $e');
    }
  }

  /// Scan a bag by tracking number
  Future<Map<String, dynamic>> scanBag(String trackingNumber) async {
    try {
      final result = await BagService.scanBag(trackingNumber);
      return result;
    } catch (e) {
      debugPrint('Error scanning bag: $e');
      rethrow;
    }
  }

  /// Refresh all data
  Future<void> refresh({int? driverId}) async {
    await loadBags(driverId: driverId);
    await loadManifests();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
