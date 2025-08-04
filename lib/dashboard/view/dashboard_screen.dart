import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../shared/theme/theme_provider.dart';
import '../viewmodel/dashboard_view_model.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            color: colorScheme.onBackground,
            onPressed: () {
              final summary = '''
Hi! Here’s my budget summary:
- Balance: PKR ${dashboard.balance.toStringAsFixed(0)}
- Income: PKR ${dashboard.totalIncome.toStringAsFixed(0)}
- Expense: PKR ${dashboard.totalExpense.toStringAsFixed(0)}
Shared via Budget App 📱
''';
              Share.share(summary);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            color: colorScheme.onBackground,
            onPressed: () => _showLogoutConfirmationDialog(context),
          )
        ],
      ),
      extendBodyBehindAppBar: true,

      drawer: Drawer(
        child: Consumer(
          builder: (context, ref, _) {
            final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: colorScheme.primary),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: dashboard.avatarUrl != null
                            ? NetworkImage(dashboard.avatarUrl!)
                            : null,
                        child: dashboard.avatarUrl == null
                            ? const Icon(Icons.person, size: 36)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dashboard.userName ?? 'Guest',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.fingerprint, color: colorScheme.onSurface),
                  title: Text('Add Fingerprint', style: textTheme.bodyMedium),
                  onTap: () async {
                    final auth = LocalAuthentication();
                    final canCheck = await auth.canCheckBiometrics;

                    if (!canCheck) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Biometric auth not available on this device")),
                      );
                      return;
                    }

                    try {
                      final didAuth = await auth.authenticate(
                        localizedReason: 'Authenticate using fingerprint',
                        options: const AuthenticationOptions(biometricOnly: true),
                      );

                      if (didAuth) {
                        final prefs = await SharedPreferences.getInstance();
                        final user = Supabase.instance.client.auth.currentUser;

                        final savedFingerprintUserId = prefs.getString('fingerprint_user_id');

                        if (savedFingerprintUserId == null && user != null) {
                          await prefs.setString('fingerprint_user_id', user.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Fingerprint registered successfully")),
                          );
                        } else if (user != null && savedFingerprintUserId == user.id) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Fingerprint authentication successful")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Fingerprint does not match the current user")),
                          );
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error during biometric auth: $e")),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person, color: colorScheme.onSurface),
                  title: Text('Profile', style: textTheme.bodyMedium),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/profile');
                  },
                ),
                ListTile(
                  leading: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: colorScheme.onSurface,
                  ),
                  title: Text('Dark Mode', style: textTheme.bodyMedium),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      ref.read(themeProvider.notifier).state =
                      value ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [colorScheme.surface, colorScheme.background]
                : [const Color(0xFFE0F7FA), const Color(0xFFF1F8E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, ${dashboard.userName ?? 'User'}",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current Balance",
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "PKR ${dashboard.balance.toStringAsFixed(0)}",
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _summaryCard(context, "Income", dashboard.totalIncome, Colors.green),
                    const SizedBox(width: 10),
                    _summaryCard(context, "Expense", dashboard.totalExpense, Colors.red),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Recent Transactions",
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _navButton(context, '/transactions', "View All"),
                          _navButton(context, '/categories', "Categories"),
                          _navButton(context, '/analytics', "Analytics"),
                          _navButton(context, '/spending-goals', "Goals"),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.read(dashboardViewModelProvider.notifier).refreshDashboard();
                    },
                    child: dashboard.transactions.isEmpty
                        ? ListView(
                      children: [
                        const SizedBox(height: 100),
                        Center(
                          child: Text(
                            "No transactions found.",
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    )
                        : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: dashboard.transactions.length,
                      itemBuilder: (context, index) {
                        final tx = dashboard.transactions[index];
                        final txColor = tx.type == 'income' ? Colors.green : Colors.red;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: Icon(
                              tx.type == 'income'
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: txColor,
                            ),
                            title: Text(tx.title, style: textTheme.bodyMedium),
                            subtitle: Text(
                              DateFormat.yMMMEd().format(tx.date),
                              style: textTheme.bodySmall,
                            ),
                            trailing: Text(
                              "PKR ${tx.amount.toStringAsFixed(0)}",
                              style: textTheme.bodyMedium?.copyWith(
                                color: txColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-transaction'),
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _summaryCard(BuildContext context, String label, double value, Color color) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(label, style: textTheme.bodySmall?.copyWith(color: color)),
            const SizedBox(height: 8),
            Text(
              "PKR ${value.toStringAsFixed(0)}",
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navButton(BuildContext context, String route, String label) {
    return TextButton(
      onPressed: () => context.push(route),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        minimumSize: const Size(0, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout Confirmation"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/');
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
