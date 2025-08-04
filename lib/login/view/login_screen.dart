import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodel/login_view_model.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  Future<void> _authenticateWithBiometrics(BuildContext context) async {
    final LocalAuthentication auth = LocalAuthentication();
    final bool canCheck = await auth.canCheckBiometrics;

    if (!canCheck) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Biometric authentication not available")),
      );
      return;
    }

    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Authenticate with fingerprint',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        final prefs = await SharedPreferences.getInstance();
        final storedUserId = prefs.getString('fingerprint_user_id');

        if (storedUserId != null) {
          context.go('/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No fingerprint login registered.")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Authentication error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = ref.watch(loginViewModelProvider);
    final loginVM = ref.read(loginViewModelProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgroud.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          onChanged: loginVM.updateEmail,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(color: Colors.white),
                            prefixIcon:
                            const Icon(Icons.email, color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          obscureText: true,
                          onChanged: loginVM.updatePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.white),
                            prefixIcon:
                            const Icon(Icons.lock, color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              loginVM.login(context, ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Login'),
                        ),
                        const SizedBox(height: 16),
                        IconButton(
                          icon: const Icon(Icons.fingerprint,
                              color: Colors.white, size: 36),
                          onPressed: () => _authenticateWithBiometrics(context),
                          tooltip: 'Login with Fingerprint',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
