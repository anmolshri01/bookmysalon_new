import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// ✅ CORRECT CODE
Future<String?> getSalonId() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;

  final response = await Supabase.instance.client
      .from('salons')
      .select('id')
      .eq('owner_id', user.id)
      .maybeSingle();

  return response?['id'] as String?;
}