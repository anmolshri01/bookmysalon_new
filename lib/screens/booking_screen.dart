import 'package:flutter/material.dart';
import '../data/app_data.dart';

class BookingScreen extends StatefulWidget {
  final String service;

  const BookingScreen({super.key, required this.service});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {

  static Map<String, List<String>> bookedSlots = {};

  DateTime? selectedDate;
  String? selectedTime;

  final List<String> timeSlots = [
    "10:00 AM",
    "11:00 AM",
    "12:00 PM",
    "2:00 PM",
    "3:00 PM",
    "4:00 PM"
  ];

  @override
  Widget build(BuildContext context) {

    String dateKey =
        selectedDate?.toString().split(" ")[0] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🧾 Service Title
            Text(
              "Book ${widget.service}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // 📅 Date Card
            GestureDetector(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                    selectedTime = null;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.deepPurple.shade50,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate == null
                          ? "Select Date"
                          : selectedDate.toString().split(" ")[0],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today)
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ⏰ Time Slots Title
            const Text(
              "Select Time Slot",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // ⏰ Time Grid
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: timeSlots.map((time) {

                bool isBooked =
                    bookedSlots[dateKey]?.contains(time) ?? false;

                bool isSelected = selectedTime == time;

                return GestureDetector(
                  onTap: (selectedDate == null || isBooked)
                      ? null
                      : () {
                    setState(() {
                      selectedTime = time;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isBooked
                          ? Colors.grey
                          : isSelected
                          ? Colors.green
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.deepPurple),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        color: isBooked
                            ? Colors.deepPurple
                            : isSelected
                            ? Colors.deepPurple
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const Spacer(),

            // ✅ Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (!AppData.bookedServices.contains(widget.service)) {
                    AppData.bookedServices.add(widget.service);
                  }

                  if (selectedDate != null && selectedTime != null) {

                    bookedSlots.putIfAbsent(dateKey, () => []);

                    if (bookedSlots[dateKey]!
                        .contains(selectedTime)) {

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Slot already booked ❌"),
                        ),
                      );

                    } else {

                      bookedSlots[dateKey]!.add(selectedTime!);

                      if (!AppData.bookedServices.contains(widget.service)) {
                        AppData.bookedServices.add(widget.service);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Booked on $dateKey at $selectedTime ✅",
                          ),
                        ),
                      );

                      setState(() {});
                    }

                  } else {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Select date & time"),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Confirm Booking",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}