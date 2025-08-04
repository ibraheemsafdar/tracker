// lib/signup/viewmodel/signup_view_model.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/signup_model.dart';
import '../../auth_controller.dart';

class SignupViewModel extends StateNotifier<SignupModel> {
  SignupViewModel()
      : super(SignupModel(name: '', email: '', password: '', confirmPassword: ''));

  void updateName(String name) =>
      state = state.copyWith(name: name);

  void updateEmail(String email) =>
      state = state.copyWith(email: email);

  void updatePassword(String password) =>
      state = state.copyWith(password: password);

  void updateConfirmPassword(String confirmPassword) =>
      state = state.copyWith(confirmPassword: confirmPassword);


  Future<void> signUp(BuildContext context, WidgetRef ref) async {
    if (state.password != state.confirmPassword) {
      _showErrorDialog(context, "Passwords do not match.");
      return;
    }

    if (state.name.trim().isEmpty) {
      _showErrorDialog(context, "Name cannot be empty.");
      return;
    }

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: state.email,
        password: state.password,
        data: {
          'name': state.name,
        },
      );

      if (response.user != null && context.mounted) {

        await ref.read(authControllerProvider).initializeUserSession();

        context.go('/dashboard');
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, e.toString());
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Signup Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

final signupViewModelProvider =
StateNotifierProvider<SignupViewModel, SignupModel>((ref) {
  return SignupViewModel();
});
