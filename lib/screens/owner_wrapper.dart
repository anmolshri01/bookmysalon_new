import 'package:flutter/material.dart';
import '../services/salon_service.dart';
import 'create_salon_screen.dart';
import 'owner_dashboard.dart';

class OwnerWrapper extends StatefulWidget {
  const OwnerWrapper({super.key});

  @override
  State<OwnerWrapper> createState() => _OwnerWrapperState();
}

class _OwnerWrapperState extends State<OwnerWrapper> {
  late Future<String?> salonFuture;

  @override
  void initState() {
    super.initState();
    salonFuture = getSalonId();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: salonFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Error: ${snapshot.error}"),
            ),
          );
        }

        final salonId = snapshot.data;

        if (salonId == null) {
          return const CreateSalonScreen();
        }

        return OwnerDashboard(salonId: salonId);
      },
    );
  }
}