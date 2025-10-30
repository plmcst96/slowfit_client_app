class Register {
  String firstName;
  String surname;
  String email;
  String password;
  int roleId;
  int? ptId;

  Register({
    required this.firstName,
    required this.surname,
    required this.email,
    required this.password,
    required this.roleId,
    this.ptId
  });

  factory Register.fromJson(Map<String, dynamic> json) {
    return Register(
      firstName: json['firstName'],
      surname: json['surname'],
      email: json['email'],
      password: json['password'],
      roleId: json['roleId'] ?? 1,
      ptId: json['ptId'] ?? null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'surname': surname,
      'email': email,
      'password': password,
      'roleId': roleId,
      'ptId':ptId
    };
  }
}
