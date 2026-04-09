import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('bookings')
            .stream(primaryKey: ['id'])
            .eq('user_id', user!.id), // 🔥 user specific

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!;

          if (bookings.isEmpty) {
            return const Center(child: Text("No bookings yet"));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(b['services'] ?? ''),
                  subtitle: Text(
                    "${b['booking_date']} | ${b['booking_time']}",
                  ),

                  trailing: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),

                    // ❌ CANCEL BOOKING
                    onPressed: () async {
                      await supabase
                          .from('bookings')
                          .delete()
                          .eq('id', b['id']);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Booking cancelled")),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}