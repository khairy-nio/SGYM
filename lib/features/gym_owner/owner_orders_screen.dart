import 'package:flutter/material.dart';
import '../../shared/widgets/shared_widgets.dart';

class OwnerOrdersScreen extends StatelessWidget {
  const OwnerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No Orders',
        message: 'You have no recent orders.',
      ),
    );
  }
}
