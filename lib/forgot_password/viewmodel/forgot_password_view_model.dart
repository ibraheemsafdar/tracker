
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/forgot_password_model.dart';

class ForgotPasswordViewModel extends StateNotifier<ForgotPasswordModel> {
  ForgotPasswordViewModel() : super(ForgotPasswordModel(email: ''));

  void updateEmail(String email) =>
      state = state.copyWith(email: email);

  Future<void> resetPassword(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(state.email);
      if (context.mounted) {
        _showDialog(
          context,
          title: "Password Reset",
          content: "Check your email for a reset link.",
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showDialog(
          context,
          title: "Error",
          content: e.toString(),
        );
      }
    }
  }

  void _showDialog(BuildContext context, {required String title, required String content}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
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

final forgotPasswordViewModelProvider =
StateNotifierProvider<ForgotPasswordViewModel, ForgotPasswordModel>((ref) {
  return ForgotPasswordViewModel();
});
