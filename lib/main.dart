import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/supebase/supabase_client.dart';
import 'routes/app_router.dart';
import 'shared/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseManager.initialize();

  runApp(
    const ProviderScope(
      child: TrackerApp(),
    ),
  );
}

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.red,
  useMaterial3: true,
  textTheme: const TextTheme().apply(
    fontFamily: 'OpenSans',
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.red,
  useMaterial3: true,
  textTheme: const TextTheme().apply(
    fontFamily: 'OpenSans',

  ),
);

class TrackerApp extends ConsumerWidget {
  const TrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Tracker',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
