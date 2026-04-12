import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_service_screen.dart';
import 'owner_bookings_screen.dart';

final supabase = Supabase.instance.client;

class OwnerDashboard extends StatefulWidget {
  final String salonId; // 🔥 UUID (IMPORTANT)

  const OwnerDashboard({super.key, required this.salonId});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  double revenue = 0;
  int totalBookings = 0;
  int todayBookings = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  // ✅ LOAD DASHBOARD DATA
  Future<void> loadDashboard() async {
    try {
      print("Fetching dashboard for salon: ${widget.salonId}");

      // 🔥 FETCH BOOKINGS
      final bookings = await supabase
          .from('bookings')
          .select()
          .eq('salon_id', widget.salonId);

      totalBookings = bookings.length;

      // 🔥 REVENUE
      double tempRevenue = 0;
      for (var b in bookings) {
        tempRevenue += (b['total_price'] ?? 0);
      }
      revenue = tempRevenue;

      // 🔥 TODAY BOOKINGS
      final today = DateTime.now().toIso8601String().split('T')[0];

      final todayData = await supabase
          .from('bookings')
          .select()
          .eq('salon_id', widget.salonId)
          .eq('booking_date', today); // ✅ FIXED COLUMN

      todayBookings = todayData.length;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Dashboard error: $e");
      setState(() => isLoading = false);
    }
  }

  // ✅ UI CARD
  Widget dashboardCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(blurRadius: 5, color: Colors.black12, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.deepPurple),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 LOADING
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Owner Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              loadDashboard();
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔥 STATS
            Row(
              children: [
                Expanded(
                  child: dashboardCard(
                    "Revenue",
                    "₹$revenue",
                    Icons.attach_money,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: dashboardCard(
                    "Bookings",
                    "$totalBookings",
                    Icons.book,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: dashboardCard("Today", "$todayBookings", Icons.today),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 🔥 ACTION BUTTONS
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddServiceScreen(salonId: widget.salonId),
                  ),
                );
              },
              child: const Text("Add Service"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        OwnerBookingsScreen(salonId: widget.salonId),
                  ),
                );
              },
              child: const Text("View Bookings"),
            ),
          ],
        ),
      ),
    );
  }
}
