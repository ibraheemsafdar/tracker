import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

Future<bool> authenticateWithBiometrics(BuildContext context) async {
  final LocalAuthentication auth = LocalAuthentication();

  final bool canCheck = await auth.canCheckBiometrics;

  if (!canCheck) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Biometric authentication not available")),
    );
    return false;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication successful")),
      );
    }

    return didAuthenticate;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Authentication error: $e")),
    );
    return false;
  }
}
