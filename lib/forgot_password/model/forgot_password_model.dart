
class ForgotPasswordModel {
  final String email;

  ForgotPasswordModel({required this.email});

  ForgotPasswordModel copyWith({String? email}) {
    return ForgotPasswordModel(email: email ?? this.email);
  }
}
