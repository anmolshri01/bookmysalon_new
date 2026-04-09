import 'package:flutter/material.dart';
import 'slot_booking_screen.dart';
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
  final String serviceName;
  final String salonName;
  final int salonId; // ✅ added

  const ServiceDetailScreen({
    super.key,
    required this.serviceName,
    required this.salonName,
    required this.salonId, // ✅ added
  });

  @override
  State<ServiceDetailScreen> createState() =>
      _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  List<Review> reviews = [];

  bool get canReview {
    return AppData.bookedServices.contains(widget.serviceName);
  }

  // ⭐ ADD REVIEW
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
              title: Text("Review for ${widget.serviceName}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Your Name",
                    ),
                  ),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: "Your Review",
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ⭐ STAR RATING
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        commentController.text.isNotEmpty) {
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
                    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.serviceName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Professional service with expert staff and premium products.",
            ),

            const SizedBox(height: 20),

            // ⭐ REVIEW HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Reviews",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                canReview
                    ? TextButton(
                  onPressed: showAddReviewDialog,
                  child: const Text("Write Review"),
                )
                    : const Text(
                  "Book service to review",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ⭐ REVIEWS LIST
            Expanded(
              child: reviews.isEmpty
                  ? const Center(child: Text("No reviews yet"))
                  : ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];

                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(review.name),
                    subtitle: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                            review.rating,
                                (index) => const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(review.comment),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 🔥 BOOK BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SlotBookingScreen(
                        salonName: widget.salonName,
                        serviceName: widget.serviceName,
                        salonId: widget.salonId, // ✅ FIXED
                      ),
                    ),
                  );
                },
                child: const Text("Book Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}