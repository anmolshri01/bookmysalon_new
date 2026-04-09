import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerService {
  final supabase = Supabase.instance.client;

  Future<int?> getSalonId() async {
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    final data = await supabase
        .from('salon_owners')
        .select('salon_id')
        .eq('user_id', user.id)
        .maybeSingle();

    return data?['salon_id'];
  }
}