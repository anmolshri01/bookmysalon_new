import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerBookingsScreen extends StatefulWidget {
  final String salonId;
  const OwnerBookingsScreen({
    super.key,
    required this.salonId,
  });

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Salon Bookings")),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('bookings')
            .stream(primaryKey: ['id'])
            .eq('salon_id', widget.salonId), // 🔥 IMPORTANT FILTER

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!;

          if (bookings.isEmpty) {
            return const Center(child: Text("No bookings found"));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data = bookings[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['services'] ?? 'No Service'),
                  subtitle: Text(
                    "${data['booking_date']} | ${data['booking_time']}",
                  ),

                  // 🔥 STATUS DISPLAY
                  trailing: Text(
                    data['status'] ?? 'pending',
                    style: TextStyle(
                      color: data['status'] == 'completed'
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
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