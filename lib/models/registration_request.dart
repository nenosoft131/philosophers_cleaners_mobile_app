import 'user_role.dart';

class RegistrationRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String? number;
  final String? address;
  final UserRole userRole;
  final String password;

  RegistrationRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.number,
    this.address,
    required this.userRole,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'user_role': userRole.value,
      'hashed_password': password,
    };

    if (number != null && number!.isNotEmpty) {
      json['number'] = number;
    }

    if (address != null && address!.isNotEmpty) {
      json['address'] = address;
    }

    return json;
  }
}
