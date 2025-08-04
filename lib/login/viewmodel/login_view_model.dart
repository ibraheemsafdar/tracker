import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth_controller.dart';
import '../model/login_model.dart';

class LoginViewModel extends StateNotifier<LoginModel> {
  LoginViewModel() : super(LoginModel(email: '', password: ''));

  void updateEmail(String email) => state = state.copyWith(email: email);
  void updatePassword(String password) => state = state.copyWith(password: password);

  Future<void> login(BuildContext context, WidgetRef ref) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: state.email,
        password: state.password,
      );

      final user = response.user;
      if (user != null && context.mounted) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('fingerprint_user_id', user.id);


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fingerprint login enabled for next time")),
        );

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
        title: const Text("Login Failed"),
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

final loginViewModelProvider =
StateNotifierProvider<LoginViewModel, LoginModel>((ref) {
  return LoginViewModel();
});
