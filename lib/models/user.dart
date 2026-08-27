class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String userType;
  final String? status;
  final int? wilayaId;
  final String? wilayaName;
  final String? vehiclePlate;
  final String? vehicleType;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.userType,
    this.status,
    this.wilayaId,
    this.wilayaName,
    this.vehiclePlate,
    this.vehicleType,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      userType: json['user_type'] ?? 'transit_chauffeur',
      status: json['status'],
      wilayaId: json['wilaya_id'],
      wilayaName: json['wilaya'] != null ? json['wilaya']['name'] : null,
      vehiclePlate: json['vehicle_plate'],
      vehicleType: json['vehicle_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'user_type': userType,
      'status': status,
      'wilaya_id': wilayaId,
      'vehicle_plate': vehiclePlate,
      'vehicle_type': vehicleType,
    };
  }
}
