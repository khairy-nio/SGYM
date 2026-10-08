import 'package:flutter/material.dart';
import '../../shared/widgets/shared_widgets.dart';

class OwnerProductsScreen extends StatelessWidget {
  const OwnerProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Products')),
      body: const EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No Products Yet',
        message: 'Add your first product to start selling.',
      ),
    );
  }
}
