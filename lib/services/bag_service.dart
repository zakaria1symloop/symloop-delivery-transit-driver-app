import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/bag.dart';
import 'api_service.dart';

class BagService {
  /// Fetch bags for the current driver with optional status filter
  static Future<List<Bag>> fetchBags({
    String? status,
    int? driverId,
  }) async {
    String endpoint = ApiConfig.bags;
    final params = <String, String>{};

    if (status != null) {
      params['status'] = status;
    }
    if (driverId != null) {
      params['transit_driver_id'] = driverId.toString();
    }

    if (params.isNotEmpty) {
      endpoint += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    debugPrint('Fetching bags: $endpoint');
    final response = await ApiService.get(endpoint);

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      // Handle paginated response or direct list
      List<dynamic> bagsList;
      if (data is List) {
        bagsList = data;
      } else if (data is Map && data['data'] != null) {
        bagsList = data['data'] as List;
      } else {
        bagsList = [];
      }
      return bagsList.map((json) => Bag.fromJson(json)).toList();
    }

    return [];
  }

  /// Fetch a single bag by ID
  static Future<Bag?> fetchBag(int id) async {
    final endpoint = ApiConfig.bagShow.replaceAll('{id}', id.toString());
    final response = await ApiService.get(endpoint);

    if (response['success'] == true && response['data'] != null) {
      return Bag.fromJson(response['data']);
    }
    return null;
  }

  /// Scan a bag by tracking number
  static Future<Map<String, dynamic>> scanBag(
    String trackingNumber, {
    String action = 'scan',
  }) async {
    final response = await ApiService.post(
      ApiConfig.bagScan,
      body: {
        'tracking_number': trackingNumber,
        'action': action,
      },
    );
    return response;
  }

  /// Fetch driver manifests (trips)
  static Future<List<Map<String, dynamic>>> fetchManifests({
    String? status,
  }) async {
    String endpoint = ApiConfig.manifests;
    if (status != null) {
      endpoint += '?status=$status';
    }

    final response = await ApiService.get(endpoint);

    if (response['success'] == true && response['data'] != null) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    return [];
  }

  /// Fetch active manifest
  static Future<Map<String, dynamic>?> fetchActiveManifest() async {
    try {
      final response = await ApiService.get(ApiConfig.manifestActive);
      if (response['success'] == true && response['data'] != null) {
        return Map<String, dynamic>.from(response['data']);
      }
    } catch (e) {
      debugPrint('fetchActiveManifest error: $e');
    }
    return null;
  }

  /// Fetch manifest trip overview
  static Future<Map<String, dynamic>?> fetchTripOverview(int manifestId) async {
    final endpoint =
        ApiConfig.manifestTripOverview.replaceAll('{id}', manifestId.toString());
    try {
      final response = await ApiService.get(endpoint);
      if (response['success'] == true && response['data'] != null) {
        return Map<String, dynamic>.from(response['data']);
      }
    } catch (e) {
      debugPrint('fetchTripOverview error: $e');
    }
    return null;
  }
}
