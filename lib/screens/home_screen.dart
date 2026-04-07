import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../utils/location_helper.dart';
import '../utils/distance_helper.dart';
import 'salon_detail_screen.dart';
import 'booking_history_screen.dart'; // ✅ ADDED

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

  // 📍 GET LOCATION + NAME
  Future<void> loadLocation() async {
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
      );

      userLat = position.latitude;
      userLng = position.longitude;

      print("LAT: ${position.latitude}, LNG: ${position.longitude}");

      String name = await getLocationName(
        position.latitude,
        position.longitude,
      );

      setState(() {
        locationText = name;
      });
    } catch (e) {
      print("Location error: $e");

      setState(() {
        locationText = "Error getting location";
      });
    }
  }

  // 📡 FETCH SALONS
  Stream<List<Map<String, dynamic>>> getSalonsStream() {
    return supabase.from('salons').stream(primaryKey: ['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // 🔥 APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "BookMySalon",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            Text(
              locationText,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),

        // ✅ UPDATED ACTIONS
        actions: [
          const Icon(Icons.notifications_none, color: Colors.black),

          const SizedBox(width: 10),

          // 📋 BOOKING HISTORY BUTTON
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

          const SizedBox(width: 10),
        ],
      ),

      body: Column(
        children: [
          // 🔍 SEARCH BAR
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

          // 🧩 CATEGORY CHIPS
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

          // 🎯 OFFER BANNER
          Container(
            margin: const EdgeInsets.all(12),
            height: 120,
            width: double.infinity,
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

          // 💇 SALON LIST
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getSalonsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final salons = snapshot.data!;

                final filteredSalons = selectedCategory == "All"
                    ? salons
                    : salons
                    .where((s) => s['category'] == selectedCategory)
                    .toList();

                if (filteredSalons.isEmpty) {
                  return const Center(child: Text("No salons found"));
                }

                return ListView.builder(
                  itemCount: filteredSalons.length,
                  itemBuilder: (context, index) {
                    final data = filteredSalons[index];
                    return _salonCard(data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🧩 CATEGORY CHIP
  Widget _chip(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
        });
      },
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

  // 💇 SALON CARD
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
            BoxShadow(color: Colors.black12, blurRadius: 6)
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
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    distance == 0
                        ? "Calculating..."
                        : "${distance.toStringAsFixed(1)} km away",
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      Text(" ${data['rating'] ?? ''}"),
                      const Spacer(),
                      const Icon(Icons.favorite_border, color: Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}