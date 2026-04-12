import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'owner_wrapper.dart';

class CreateSalonScreen extends StatefulWidget {
  const CreateSalonScreen({super.key});

  @override
  State<CreateSalonScreen> createState() => _CreateSalonScreenState();
}

class _CreateSalonScreenState extends State<CreateSalonScreen> {

  final supabase = Supabase.instance.client;
  final TextEditingController nameController = TextEditingController();

  bool isLoading = false;

  Future<void> createSalon() async {
    setState(() => isLoading = true);

    final user = supabase.auth.currentUser;

    try {
      await supabase.from('salons').insert({
        'name': nameController.text.trim(),
        'owner_id': user!.id,
      });

      // ✅ Redirect after creation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OwnerWrapper()),
      );

    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create salon")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Your Salon")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Salon Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : createSalon,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Create Salon"),
            ),
          ],
        ),
      ),
    );
  }
}