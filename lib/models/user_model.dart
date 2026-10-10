class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get fullAddress {
    final parts = [street, city, state, zipCode, country]
        .where((p) => p != null && p.trim().isNotEmpty)
        .toList();
    return parts.isEmpty ? 'No address specified' : parts.join(', ');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, {String? id}) {
    return AppUser(
      id: id ?? map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      phoneNumber: map['phoneNumber'],
      street: map['street'],
      city: map['city'],
      state: map['state'],
      zipCode: map['zipCode'],
      country: map['country'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
