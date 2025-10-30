class User {
  late int userId;
  late String firstName;
  late String surname;
  late String email;
  late int roleId;
  late int? ptId;
  late String? imageProfile;
  late String? phone;

  User(
      {required this.userId,
      required this.firstName,
      required this.surname,
      required this.email,
      required this.roleId,
      this.ptId,
      this.imageProfile,
      this.phone});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        userId: json['userId'],
        firstName: json['firstName'],
        surname: json['surname'],
        email: json['email'],
        roleId: json['roleId'],
        ptId: json['ptId'],
        imageProfile: json['imageProfile'] ?? '',
        phone: json['phone'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'surname': surname,
      'email': email,
      'roleId': roleId,
      'ptId': ptId,
      'imageProfile': imageProfile,
      'phone': phone
    };
  }
}

class UserProfile {
  late int userId;
  late String firstName;
  late String surname;
  late String email;
  late int roleId;
  late DateTime? birthDate;
  late String? province;
  late String? country;
  late String? city;
  late String? address;
  late int? zipCode;
  late String? imageProfile;

  UserProfile({
    required this.userId,
    required this.firstName,
    required this.surname,
    required this.email,
    required this.roleId,
    this.address,
    this.city,
    this.province,
    this.imageProfile,
    this.birthDate,
    this.zipCode,
    this.country,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'],
      firstName: json['firstName'],
      surname: json['surname'],
      email: json['email'],
      roleId: json['roleId'],
      province: json['province'],
      city: json['city'],
      country: json['country'],
      address: json['address'],
      zipCode: json['zipCode'],
      birthDate:
          json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      imageProfile: json['imageProfile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'surname': surname,
      'email': email,
      'roleId': roleId,
      'province': province,
      'city': city,
      'country': country,
      'address': address,
      'zipCode': zipCode,
      'birthDate': birthDate?.toIso8601String(),
      'imageProfile': imageProfile
    };
  }
}

class AddProfile {
  final int userId;
  final String? address;
  final String? city;
  final String? province;
  final String? country;
  final int? zipCode;
  final String? imageProfile;
  final DateTime? birthDate;
  final String? phone;

  AddProfile({
    required this.userId,
    required this.address,
    required this.city,
    required this.province,
    required this.country,
    required this.zipCode,
    this.imageProfile,
    this.birthDate,
    this.phone,
  });

  /// Costruttore da JSON
  factory AddProfile.fromJson(Map<String, dynamic> json) {
    return AddProfile(
      userId: json['userId'] ,
      address: json['address'] ,
      city: json['city'] ,
      province: json['province'] ,
      country: json['country'] ,
      zipCode: json['zipCode'] ,
      imageProfile: json['imageProfile'],
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : null,
      phone: json['phone'] ,
    );
  }

  /// Converti l’oggetto in JSON (per mandarlo alla tua API)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'address': address,
      'city': city,
      'province': province,
      'country': country,
      'zipCode': zipCode,
      'imageProfile': imageProfile,
      'birthDate': birthDate?.toIso8601String().split('T')[0], // yyyy-MM-dd
      'phone': phone,
    };
  }
}

