import 'package:flutter/material.dart';

class Bag {
  final int id;
  final String trackingNumber;
  final String? name;
  final String status;
  final String? routingType;
  final int? tripId;
  final int packageCount;

  // Origin
  final int? originSellingPointId;
  final Map<String, dynamic>? originSellingPoint;

  // Destination
  final int? destinationWilayaId;
  final Map<String, dynamic>? destinationWilaya;
  final int? destinationSellingPointId;
  final Map<String, dynamic>? destinationSellingPoint;

  // Final destination (multi-hop)
  final int? finalDestinationWilayaId;
  final Map<String, dynamic>? finalDestinationWilaya;

  // Trip info
  final Map<String, dynamic>? trip;

  // Creator
  final Map<String, dynamic>? creator;

  // Timestamps
  final String? sealedAt;
  final String? receivedAt;
  final String? createdAt;
  final String? updatedAt;

  // Notes
  final String? notes;

  // Status label & color from backend
  final String? statusLabel;
  final String? statusColor;

  Bag({
    required this.id,
    required this.trackingNumber,
    this.name,
    required this.status,
    this.routingType,
    this.tripId,
    this.packageCount = 0,
    this.originSellingPointId,
    this.originSellingPoint,
    this.destinationWilayaId,
    this.destinationWilaya,
    this.destinationSellingPointId,
    this.destinationSellingPoint,
    this.finalDestinationWilayaId,
    this.finalDestinationWilaya,
    this.trip,
    this.creator,
    this.sealedAt,
    this.receivedAt,
    this.createdAt,
    this.updatedAt,
    this.notes,
    this.statusLabel,
    this.statusColor,
  });

  factory Bag.fromJson(Map<String, dynamic> json) {
    return Bag(
      id: json['id'],
      trackingNumber: json['tracking_number'] ?? '',
      name: json['name'],
      status: json['status'] ?? 'pending',
      routingType: json['routing_type'],
      tripId: json['trip_id'],
      packageCount: json['package_count'] ?? json['packages_count'] ?? 0,
      originSellingPointId: json['origin_selling_point_id'],
      originSellingPoint: json['origin_selling_point'] != null
          ? Map<String, dynamic>.from(json['origin_selling_point'])
          : null,
      destinationWilayaId: json['destination_wilaya_id'],
      destinationWilaya: json['destination_wilaya'] != null
          ? Map<String, dynamic>.from(json['destination_wilaya'])
          : null,
      destinationSellingPointId: json['destination_selling_point_id'],
      destinationSellingPoint: json['destination_selling_point'] != null
          ? Map<String, dynamic>.from(json['destination_selling_point'])
          : null,
      finalDestinationWilayaId: json['final_destination_wilaya_id'],
      finalDestinationWilaya: json['final_destination_wilaya'] != null
          ? Map<String, dynamic>.from(json['final_destination_wilaya'])
          : null,
      trip: json['trip'] != null
          ? Map<String, dynamic>.from(json['trip'])
          : null,
      creator: json['creator'] != null
          ? Map<String, dynamic>.from(json['creator'])
          : null,
      sealedAt: json['sealed_at'],
      receivedAt: json['received_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      notes: json['notes'],
      statusLabel: json['status_label'],
      statusColor: json['status_color'],
    );
  }

  // ---------- Display Helpers ----------

  String get originName {
    if (originSellingPoint != null) {
      return originSellingPoint!['name'] ?? originSellingPoint!['code'] ?? 'N/A';
    }
    return 'N/A';
  }

  String get originCode {
    return originSellingPoint?['code'] ?? '';
  }

  String get destinationName {
    if (destinationSellingPoint != null) {
      return destinationSellingPoint!['name'] ??
          destinationSellingPoint!['code'] ??
          'N/A';
    }
    if (destinationWilaya != null) {
      return destinationWilaya!['name'] ?? 'N/A';
    }
    return 'N/A';
  }

  String get destinationCode {
    return destinationSellingPoint?['code'] ?? '';
  }

  String get destinationWilayaName {
    return destinationWilaya?['name'] ?? '';
  }

  String get finalDestinationName {
    if (finalDestinationWilaya != null) {
      return finalDestinationWilaya!['name'] ?? '';
    }
    return '';
  }

  String get tripName {
    if (trip != null) {
      return trip!['name'] ?? 'Trip #${trip!['id']}';
    }
    return '';
  }

  String get displayStatusLabel {
    if (statusLabel != null && statusLabel!.isNotEmpty) return statusLabel!;
    return _statusLabels[status] ?? status;
  }

  Color get displayStatusColor {
    return _statusColors[status] ?? const Color(0xFF6B7280);
  }

  IconData get displayStatusIcon {
    return _statusIcons[status] ?? Icons.help_outline;
  }

  bool get isInTransit => status == 'in_transit';
  bool get isArrived => status == 'arrived_destination';
  bool get isUnpacked => status == 'unpacked';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted =>
      status == 'arrived_destination' ||
      status == 'unpacked' ||
      status == 'delivered';

  // ---------- Static Maps ----------

  static const Map<String, String> _statusLabels = {
    'pending': 'En attente',
    'operator_accepted': 'Accepte',
    'ready_for_dispatch': 'Pret a expedier',
    'sent_to_provider': 'Envoye prestataire',
    'provider_validated': 'Valide prestataire',
    'in_transit': 'En transit',
    'arrived_destination': 'Arrive destination',
    'hub_entrant': 'Hub entrant',
    'hub_sortant': 'Hub sortant',
    'unpacked': 'Deballe',
    'delivered': 'Livre',
    'cancelled': 'Annule',
  };

  static const Map<String, Color> _statusColors = {
    'pending': Color(0xFF6B7280),
    'operator_accepted': Color(0xFF8B5CF6),
    'ready_for_dispatch': Color(0xFFF59E0B),
    'sent_to_provider': Color(0xFFEC4899),
    'provider_validated': Color(0xFFD946EF),
    'in_transit': Color(0xFF3B82F6),
    'arrived_destination': Color(0xFF10B981),
    'hub_entrant': Color(0xFF06B6D4),
    'hub_sortant': Color(0xFF14B8A6),
    'unpacked': Color(0xFF10B981),
    'delivered': Color(0xFF059669),
    'cancelled': Color(0xFFEF4444),
  };

  static const Map<String, IconData> _statusIcons = {
    'pending': Icons.hourglass_empty,
    'operator_accepted': Icons.check_circle_outline,
    'ready_for_dispatch': Icons.local_shipping_outlined,
    'sent_to_provider': Icons.send_outlined,
    'provider_validated': Icons.verified_outlined,
    'in_transit': Icons.route,
    'arrived_destination': Icons.location_on,
    'hub_entrant': Icons.input,
    'hub_sortant': Icons.output,
    'unpacked': Icons.unarchive,
    'delivered': Icons.done_all,
    'cancelled': Icons.cancel_outlined,
  };
}
