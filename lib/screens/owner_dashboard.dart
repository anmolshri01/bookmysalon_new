import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_service_screen.dart';
import 'owner_bookings_screen.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Salon Dashboard"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            _dashboardButton(
              context,
              "Add Services",
              Icons.add,
              const AddServiceScreen(salon: {},),
            ),

            _dashboardButton(
              context,
              "View Bookings",
              Icons.calendar_month,
              const OwnerBookingsScreen(),
            ),

          ],
        ),
      ),
    );
  }

  Widget _dashboardButton(
      BuildContext context,
      String title,
      IconData icon,
      Widget screen,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddServiceScreen(
                salon: {'id': 1}, // ✅ temporary static data
              ),
            ),
          );
        },
      ),
    );
  }
}