class UserEntity {
  final String id;
  final String phone;
  final String? role;
  final String? fullName;
  final String? location;
  final String? businessName;
  final String? businessType;

  UserEntity({
    required this.id,
    required this.phone,
    this.role,
    this.fullName,
    this.location,
    this.businessName,
    this.businessType,
  });

  bool get isProfileComplete =>
      role != null && fullName != null && location != null;

  UserEntity copyWith({
    String? id,
    String? phone,
    String? role,
    String? fullName,
    String? location,
    String? businessName,
    String? businessType,
  }) {
    return UserEntity(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      location: location ?? this.location,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'role': role,
      'fullName': fullName,
      'location': location,
      'businessName': businessName,
      'businessType': businessType,
    };
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String?,
      fullName: json['fullName'] as String?,
      location: json['location'] as String?,
      businessName: json['businessName'] as String?,
      businessType: json['businessType'] as String?,
    );
  }
}
