import 'package:flutter/material.dart';
import '../screens/booking_history_screen.dart';
import '../screens/favourite_screen.dart';
import '../screens/profile_setup_screen.dart';
import '../screens/login_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [

          // 🔝 HEADER
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
            ),
            accountName: const Text("Anmol"),
            accountEmail: const Text("anmol@email.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.deepPurple),
            ),
          ),

          // 📜 MENU ITEMS

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileSetupScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.book),
            title: const Text("My Bookings"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BookingHistoryScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text("Favourites"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FavouriteScreen(),
                ),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}