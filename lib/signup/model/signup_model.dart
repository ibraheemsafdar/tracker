
class SignupModel {
  final String name;

  final String email;
  final String password;
  final String confirmPassword;

  SignupModel({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  SignupModel copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
  }) {
    return SignupModel(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}
