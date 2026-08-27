class ApiConfig {
  // NestJS backend on the production VPS (routes are versioned under /api/v1)
  static const String baseUrl = 'http://72.60.190.211:4000/api/v1';

  // Authentication Endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Bag Endpoints
  static const String bags = '/bags';
  static const String bagScan = '/bags/scan';
  static const String bagShow = '/bags/{id}';

  // Manifest Endpoints (trips as manifests for driver)
  static const String manifests = '/manifests';
  static const String manifestActive = '/manifests/active';
  static const String manifestShow = '/manifests/{id}';
  static const String manifestStartLoading = '/manifests/{id}/start-loading';
  static const String manifestScanBag = '/manifests/{id}/scan-bag';
  static const String manifestStartTransit = '/manifests/{id}/start-transit';
  static const String manifestComplete = '/manifests/{id}/complete';
  static const String manifestTripOverview = '/manifests/{id}/trip-overview';
  static const String manifestWaypoints = '/manifests/{id}/waypoints';

  // Logistics Endpoints
  static const String trips = '/logistics/trips';
  static const String tripManifest = '/logistics/trips/{id}/manifest';
}
