import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import 'slot_booking_screen.dart';

class SalonDetailScreen extends StatefulWidget {
  final Map<String, dynamic> salon;

  const SalonDetailScreen({super.key, required this.salon});

  @override
  State<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> selectedServices = []; // ✅ moved here
  double totalPrice = 0;

  // 📡 Fetch services from Supabase
  Stream<List<Map<String, dynamic>>> getServices() {
    return supabase
        .from('services')
        .stream(primaryKey: ['id'])
        .eq('salon_id', widget.salon['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // 🔥 BOOK BUTTON
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ TOTAL PRICE
            Text(
              "Total: ₹${totalPrice.toInt()}",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  if (selectedServices.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Select at least one service"),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SlotBookingScreen(
                            serviceName: selectedServices
                                .map((e) => e["name"])
                                .join(", "),
                            salonName: widget.salon['name'],
                            salonId: widget.salon['id'], // ✅ FIXED
                          ),
                    ),
                  );
                },
                child: const Text(
                  "Book Now",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 HERO IMAGE
            Stack(
              children: [
                Image.network(
                  widget.salon['image'] ?? '',
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.28,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),

                Positioned(
                  top: 40,
                  left: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // 📄 SALON INFO
                Positioned(
                  bottom: 15,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.salon['name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "${widget.salon['rating'] ?? ''}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.white70),
                          const SizedBox(width: 4),
                          const Text(
                            "Nearby",
                            style:
                            TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Premium salon with expert professionals and hygienic environment.",
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Services",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // 💇 SERVICES
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: getServices(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final services = snapshot.data!;

                if (services.isEmpty) {
                  return const Center(
                      child: Text("No services available"));
                }

                return GridView.builder(
                  itemCount: services.length,
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final service = services[index];

                    final isSelected =
                    selectedServices.contains(service);

                    return InkWell(
                      borderRadius:
                      BorderRadius.circular(15),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedServices.remove(service);
                            totalPrice -=
                                (service["price"] as num)
                                    .toDouble();
                          } else {
                            selectedServices.add(service);
                            totalPrice +=
                                (service["price"] as num)
                                    .toDouble();
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(15),
                          color: isSelected
                              ? Colors.deepPurple.shade50
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? Colors.deepPurple
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius:
                              const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: Image.network(
                                service["image"] ?? '',
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                            Padding(
                              padding:
                              const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service["name"] ?? '',
                                    style: const TextStyle(
                                        fontWeight:
                                        FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "₹${service["price"]}",
                                    style: const TextStyle(
                                      color:
                                      Colors.deepPurple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}