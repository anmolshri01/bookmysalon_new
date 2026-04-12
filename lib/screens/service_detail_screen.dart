import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/app_data.dart';

class Review {
  final String name;
  final int rating;
  final String comment;

  Review({
    required this.name,
    required this.rating,
    required this.comment,
  });
}

class ServiceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> service;
  final String salonName;
  final String salonId;

  const ServiceDetailScreen({
    super.key,
    required this.service,
    required this.salonName,
    required this.salonId,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  List<Review> reviews = [];
  final supabase = Supabase.instance.client;

  bool isSelected = false; // ✅ Fixed: use bool instead of list.contains()
  double totalPrice = 0;

  bool get canReview {
    return AppData.bookedServices.contains(widget.service['name']);
  }

  // ✅ Fixed toggle using bool flag
  void toggleService() {
    setState(() {
      if (isSelected) {
        isSelected = false;
        totalPrice -= (widget.service['price'] as num?)?.toDouble() ?? 0;
      } else {
        isSelected = true;
        totalPrice += (widget.service['price'] as num?)?.toDouble() ?? 0;
      }
    });
  }

  // ✅ Booking function
  Future<void> bookService() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login first")),
      );
      return;
    }

    if (!isSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select service first")),
      );
      return;
    }

    try {
      // ✅ Insert booking
      final booking = await supabase
          .from('bookings')
          .insert({
        'user_id': user.id,
        'salon_id': widget.salonId,
        'total_price': totalPrice,
        'booking_date': DateTime.now().toIso8601String(),
      })
          .select()
          .single();

      final bookingId = booking['id'];

      // ✅ Insert booking service
      await supabase.from('booking_services').insert({
        'booking_id': bookingId,
        'service_id': widget.service['id'],
        'price': widget.service['price'],
      });

      // ✅ Update AppData so user can review this service
      AppData.bookedServices.add(widget.service['name']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking Successful ✅")),
        );
      }

      setState(() {
        isSelected = false;
        totalPrice = 0;
      });
    } catch (e) {
      debugPrint("Booking error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  // ✅ Review dialog
  void showAddReviewDialog() {
    if (!canReview) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must book this service to review"),
        ),
      );
      return;
    }

    final nameController = TextEditingController();
    final commentController = TextEditingController();
    int rating = 5;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Review for ${widget.service['name']}"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration:
                      const InputDecoration(labelText: "Your Name"),
                    ),
                    TextField(
                      controller: commentController,
                      decoration:
                      const InputDecoration(labelText: "Your Review"),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            Icons.star,
                            color: index < rating
                                ? Colors.orange
                                : Colors.grey,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isEmpty ||
                        commentController.text.isEmpty) {
                      return;
                    }
                    setState(() {
                      reviews.add(
                        Review(
                          name: nameController.text,
                          rating: rating,
                          comment: commentController.text,
                        ),
                      );
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return Scaffold(
      appBar: AppBar(
        title: Text(service['name'] ?? 'Service Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service['name'] ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "₹${service['price']}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            // ✅ Add/Remove button
            ElevatedButton(
              onPressed: toggleService,
              child: Text(isSelected ? "Remove Service" : "Add Service"),
            ),

            const SizedBox(height: 20),

            Text(
              "Total: ₹$totalPrice",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 20),

            // ✅ Book button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: bookService,
                child: const Text("Book Now"),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Review button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: showAddReviewDialog,
                icon: const Icon(Icons.star_outline),
                label: const Text("Add Review"),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Reviews list
            if (reviews.isNotEmpty) ...[
              const Text(
                "Reviews",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Card(
                      child: ListTile(
                        title: Text(review.name),
                        subtitle: Text(review.comment),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 16),
                            Text(review.rating.toString()),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}