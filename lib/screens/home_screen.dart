import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../utils/location_helper.dart';
import '../utils/distance_helper.dart';
import 'salon_detail_screen.dart';
import 'booking_history_screen.dart';
import 'owner_dashboard.dart';

double userLat = 0;
double userLng = 0;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "All";
  String locationText = "Detecting...";

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    loadLocation();
  }

  // 📍 FIXED LOCATION FUNCTION
  Future<void> loadLocation() async {
    print("Getting location...");

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          locationText = "Permission denied";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 5));

      print("Location fetched");

      userLat = position.latitude;
      userLng = position.longitude;

      try {
        String name = await getLocationName(
          position.latitude,
          position.longitude,
        );

        setState(() {
          locationText = name ?? "Unknown location";
        });
      } catch (e) {
        print("Geocoding error: $e");

        setState(() {
          locationText = "Ahmedabad";
        });
      }
    } catch (e) {
      print("Location error: $e");

      setState(() {
        locationText = "Using default location";
        userLat = 23.0225;
        userLng = 72.5714;
      });
    }
  }

  // 📡 SALONS STREAM
  Stream<List<Map<String, dynamic>>> getSalonsStream() {
    return supabase.from('salons').stream(primaryKey: ['id']);
  }

  // 🧑‍💼 GET OWNER SALON ID
  Future<String?> getOwnerSalonId() async {
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    final response = await supabase
        .from('salons')
        .select('id')
        .eq('owner_id', user.id)
        .limit(1)
        .maybeSingle();

    return response?['id']; // UUID → String
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "BookMySalon",
              style: TextStyle(color: Colors.black),
            ),
            Text(
              locationText,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard, color: Colors.black),
            onPressed: () async {
              final salonId = await getOwnerSalonId();

              if (!context.mounted) return;

              if (salonId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No salon found")),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OwnerDashboard(salonId: salonId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BookingHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search salons...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🧩 CATEGORY
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chip("All"),
                _chip("Haircut"),
                _chip("Beard"),
                _chip("Facial"),
                _chip("Spa"),
              ],
            ),
          ),

          // 🎯 BANNER
          Container(
            margin: const EdgeInsets.all(12),
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.pink],
              ),
            ),
            child: const Center(
              child: Text(
                "50% OFF ON FIRST BOOKING",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),

          // 💇 SALONS
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getSalonsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final salons = snapshot.data!;

                final filtered = selectedCategory == "All"
                    ? salons
                    : salons
                    .where((s) => s['category'] == selectedCategory)
                    .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No salons found"));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _salonCard(filtered[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🧩 CHIP
  Widget _chip(String label) {
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selectedCategory == label ? Colors.purple : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selectedCategory == label ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // 💇 CARD
  Widget _salonCard(Map<String, dynamic> data) {
    double lat = (data['location_lat'] ?? 0).toDouble();
    double lng = (data['location_lng'] ?? 0).toDouble();

    double distance = calculateDistance(userLat, userLng, lat, lng);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SalonDetailScreen(salon: data),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                data['image'] ?? '',
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 70,
                    width: 70,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                data['name'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}