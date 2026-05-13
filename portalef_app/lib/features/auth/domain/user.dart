import 'user_role.dart';

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final int id;
  final String name;
  final String email;
  final UserRole role;

  factory User.fromJson(Map<String, Object?> json) {
    return User(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      role: userRoleFromApi((json['role'] as String?) ?? 'ALUNO'),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': userRoleToApi(role),
    };
  }
}

