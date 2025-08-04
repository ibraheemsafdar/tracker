

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://adayjwryovdcudbiuipe.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFkYXlqd3J5b3ZkY3VkYml1aXBlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM3NTc4OTAsImV4cCI6MjA2OTMzMzg5MH0.kjaoYYllNUp2NIpPMn5z_oIn2Y7CUQidtfiJBfWT8Fo',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
