import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/auth_service.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {

  final nameController = TextEditingController();
  String gender = "Male";
  File? image;

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Profile")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                image != null ? FileImage(image!) : null,
                child: image == null
                    ? const Icon(Icons.camera_alt)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue: gender,
              items: ["Male", "Female", "Other"]
                  .map((g) => DropdownMenuItem(
                value: g,
                child: Text(g),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    gender = value;
                  });
                }
              },
              decoration: const InputDecoration(labelText: "Gender"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;

                final navigator = Navigator.of(context);

                await AuthService.saveProfile(
                  name: nameController.text,
                  gender: gender,
                  imagePath: image?.path,
                );

                navigator.pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(),
                  ),
                );
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}