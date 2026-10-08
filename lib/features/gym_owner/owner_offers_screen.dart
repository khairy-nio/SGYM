import 'package:flutter/material.dart';
import '../../shared/widgets/shared_widgets.dart';

class OwnerOffersScreen extends StatelessWidget {
  const OwnerOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Offers')),
      body: const EmptyState(
        icon: Icons.local_offer_outlined,
        title: 'No Active Offers',
        message: 'Create offers to attract more customers.',
      ),
    );
  }
}
