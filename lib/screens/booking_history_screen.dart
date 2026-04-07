import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {

  final supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> getBookings() {
    final user = supabase.auth.currentUser;

    return supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('user_id', user!.id)
        .order('created_at', ascending: false);
  }

  // ❌ CANCEL BOOKING
  Future<void> cancelBooking(int id) async {
    await supabase
        .from('bookings')
        .delete()
        .eq('id', id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getBookings(),
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
              final data = bookings[index];

              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(data['services'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date: ${data['booking_date']}"),
                      Text("Time: ${data['booking_time']}"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () async {
                      await cancelBooking(data['id']);
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