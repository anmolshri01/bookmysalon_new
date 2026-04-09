import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerBookingsScreen extends StatelessWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(title: const Text("Salon Bookings")),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('bookings')
            .stream(primaryKey: ['id']),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {

              final data = bookings[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['services'] ?? ''),
                  subtitle: Text(
                    "${data['booking_date']} | ${data['booking_time']}",
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