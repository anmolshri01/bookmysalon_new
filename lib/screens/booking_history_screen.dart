import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    // 🔥 SAFETY CHECK
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('bookings')
            .stream(primaryKey: ['id'])
            .eq('user_id', user.id),

        builder: (context, snapshot) {
          // ⏳ LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ ERROR
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final bookings = snapshot.data ?? [];

          // 📭 EMPTY
          if (bookings.isEmpty) {
            return const Center(child: Text("No bookings yet"));
          }

          // ✅ LIST
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];

              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_month, color: Colors.purple),

                  title: Text(
                    b['services'] ?? 'Service',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date: ${b['booking_date'] ?? ''}"),
                      Text("Time: ${b['booking_time'] ?? ''}"),

                      // 🔥 OPTIONAL (if you store price)
                      if (b['total_price'] != null)
                        Text("₹${b['total_price']}"),
                    ],
                  ),

                  trailing: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),

                    // ❌ CANCEL BOOKING
                    onPressed: () async {
                      try {
                        await supabase
                            .from('bookings')
                            .delete()
                            .eq('id', b['id']);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Booking cancelled")),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
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