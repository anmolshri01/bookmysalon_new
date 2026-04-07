import 'package:flutter/material.dart';
import '../data/app_data.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favourites"),
      ),

      body: AppData.favouriteSalons.isEmpty
          ? const Center(
        child: Text("No favourites yet ❤️"),
      )
          : ListView.builder(
        itemCount: AppData.favouriteSalons.length,
        itemBuilder: (context, index) {
          final salon = AppData.favouriteSalons[index];

          return ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: Text(salon),
          );
        },
      ),
    );
  }
}