import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tracker/transaction_history/viewmodel/transaction_history_view_model.dart';
import '../../dashboard/viewmodel/dashboard_view_model.dart';

final authControllerProvider = Provider((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref ref;

  AuthController(this.ref);
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    ref.invalidate(dashboardViewModelProvider);
    ref.invalidate(transactionHistoryProvider);
  }
  Future<void> initializeUserSession() async {
    ref.invalidate(dashboardViewModelProvider);
    ref.invalidate(transactionHistoryProvider);
    await ref.read(dashboardViewModelProvider.notifier).initialize();
    await ref.read(transactionHistoryProvider.notifier).initialize();
  }
}
