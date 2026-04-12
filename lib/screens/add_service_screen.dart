import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddServiceScreen extends StatefulWidget {
  final String salonId;
  const AddServiceScreen({
    super.key,
    required this.salonId,
  });

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {

  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final priceController = TextEditingController();

  bool isLoading = false;

  // ✅ STREAM FUNCTION
  Stream<List<Map<String, dynamic>>> getServices() {
    return supabase
        .from('services')
        .stream(primaryKey: ['id'])
        .eq('salon_id', widget.salonId);
  }

  // ✅ ADD SERVICE FUNCTION (UPDATED)
  Future<void> addService() async {

    final name = nameController.text.trim();
    final priceText = priceController.text.trim();

    // 🔒 Validation
    if (name.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    int? price = int.tryParse(priceText);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid price")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await supabase.from('services').insert({
        'name': name,
        'price': price,
        'salon_id': widget.salonId,
        'image': 'https://via.placeholder.com/150'
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Service Added")),
      );

      nameController.clear();
      priceController.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Service")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Service Name"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : addService,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Add Service"),
            ),

            const SizedBox(height: 20),

            // ✅ LIVE SERVICE LIST
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: getServices(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}"),
                    );
                  }

                  final services = snapshot.data ?? [];

                  if (services.isEmpty) {
                    return const Center(child: Text("No services found"));
                  }

                  return ListView.builder(
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];

                      return ListTile(
                        leading: Image.network(
                          service['image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(service['name']),
                        subtitle: Text("₹${service['price']}"),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}