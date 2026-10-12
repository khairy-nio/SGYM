import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/main/main_shell.dart';
import '../../features/home/home_screen.dart';
import '../../features/gyms/gyms_screen.dart';
import '../../features/gyms/gym_detail_screen.dart';
import '../../features/products/products_screen.dart';
import '../../features/products/product_detail_screen.dart';
import '../../features/offers/offers_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/checkout/order_success_screen.dart';
import '../../features/orders/orders_screen.dart';

import '../../features/profile/profile_screen.dart';
import '../../features/profile/settings_screen.dart';
import '../../features/profile/favorites_screen.dart';
import '../../features/profile/addresses_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/home/location_screen.dart';
import '../../features/gym_owner/owner_shell.dart';
import '../../features/gym_owner/owner_dashboard_screen.dart';
import '../../features/gym_owner/owner_products_screen.dart';
import '../../features/gym_owner/owner_orders_screen.dart';
import '../../features/gym_owner/owner_offers_screen.dart';
import '../../features/gym_owner/add_product_screen.dart';
import '../../features/gym_owner/ai_image_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);
  final isOwner = ref.watch(gymOwnerModeProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = auth != null;
      final loc = state.uri.path;

      if (loc == '/splash' || loc == '/onboarding') return null;

      final authRoutes = ['/login', '/signup', '/forgot-password'];
      if (!isLoggedIn && !authRoutes.contains(loc)) {
        return '/login';
      }
      if (isLoggedIn && authRoutes.contains(loc)) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/location', builder: (_, __) => const LocationScreen()),

      // Main app shell with bottom nav
      ShellRoute(
        builder: (_, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/explore', builder: (_, __) => const GymsScreen()),
          GoRoute(path: '/offers', builder: (_, __) => const OffersScreen()),
          GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // Gym Owner shell
      ShellRoute(
        builder: (_, state, child) => OwnerShell(child: child),
        routes: [
          GoRoute(path: '/owner/dashboard', builder: (_, __) => const OwnerDashboardScreen()),
          GoRoute(path: '/owner/products', builder: (_, __) => const OwnerProductsScreen()),
          GoRoute(path: '/owner/orders', builder: (_, __) => const OwnerOrdersScreen()),
          GoRoute(path: '/owner/offers', builder: (_, __) => const OwnerOffersScreen()),
        ],
      ),

      // Detail screens (no shell)
      GoRoute(
        path: '/gym/:id',
        builder: (_, state) => GymDetailScreen(gymId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/gyms/:id',
        builder: (_, state) => GymDetailScreen(gymId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (_, state) => ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/products', builder: (_, __) => const ProductsScreen()),
      GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
      GoRoute(path: '/order-success', builder: (_, state) {
        final orderNumber = state.uri.queryParameters['orderNumber'] ?? '#GYM10248';
        return OrderSuccessScreen(orderNumber: orderNumber);
      }),
      GoRoute(
        path: '/order/:id',
        builder: (_, state) => OrderDetailScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen()),
      GoRoute(path: '/addresses', builder: (_, __) => const AddressesScreen()),
      GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
      GoRoute(path: '/add-product', builder: (_, __) => const AddProductScreen()),
      GoRoute(path: '/ai-image', builder: (_, __) => const AiImageScreen()),
      GoRoute(path: '/owner/profile', builder: (_, __) => const ProfileScreen()),
    ],
  );
});
