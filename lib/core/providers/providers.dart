import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/models.dart';
import '../../data/mock/mock_data.dart';

// ── THEME ──────────────────────────────────────────────────────────────────

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isDarkMode') ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', state);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>(
  (ref) => ThemeNotifier(),
);

// ── AUTH ──────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier() : super(null) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      state = MockData.mockUser;
    }
  }

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    state = MockData.mockUser;
  }

  Future<void> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    state = MockData.mockUser.copyWith(name: 'Mohamed G.');
  }

  Future<void> loginWithFacebook() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    state = MockData.mockUser.copyWith(name: 'Mohamed F.');
  }

  Future<void> loginWithApple() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    state = MockData.mockUser;
  }

  Future<void> loginWithBiometric() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    state = MockData.mockUser;
  }

  Future<void> signUp(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    state = MockData.mockUser.copyWith(name: name, email: email);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    state = null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    state = null;
  }

  bool get isLoggedIn => state != null;
}

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>(
  (ref) => AuthNotifier(),
);

// ── LOCATION ──────────────────────────────────────────────────────────────

final locationProvider = StateProvider<String>((ref) => 'Nasr City');

// ── GYMS ──────────────────────────────────────────────────────────────────

class GymsNotifier extends StateNotifier<List<GymModel>> {
  GymsNotifier() : super(MockData.gyms);

  void toggleFavorite(String gymId) {
    state = state.map((gym) {
      if (gym.id == gymId) {
        return gym.copyWith(isFavorite: !gym.isFavorite);
      }
      return gym;
    }).toList();
  }

  List<GymModel> get favorites => state.where((g) => g.isFavorite).toList();

  List<GymModel> getByCity(String city) {
    if (city.isEmpty) return state;
    return state.where((g) => g.city.toLowerCase().contains(city.toLowerCase())).toList();
  }

  List<GymModel> search(String query) {
    if (query.isEmpty) return state;
    final q = query.toLowerCase();
    return state.where((g) =>
      g.name.toLowerCase().contains(q) ||
      g.city.toLowerCase().contains(q) ||
      g.address.toLowerCase().contains(q)
    ).toList();
  }
}

final gymsProvider = StateNotifierProvider<GymsNotifier, List<GymModel>>(
  (ref) => GymsNotifier(),
);

final gymByIdProvider = Provider.family<GymModel?, String>((ref, id) {
  return ref.watch(gymsProvider).firstWhere((g) => g.id == id, orElse: () => MockData.gyms.first);
});

// ── PRODUCTS ──────────────────────────────────────────────────────────────

class ProductsNotifier extends StateNotifier<List<ProductModel>> {
  ProductsNotifier() : super(MockData.products);

  void toggleFavorite(String productId) {
    state = state.map((p) {
      if (p.id == productId) {
        return p.copyWith(isFavorite: !p.isFavorite);
      }
      return p;
    }).toList();
  }

  List<ProductModel> get favorites => state.where((p) => p.isFavorite).toList();

  List<ProductModel> getByGym(String gymId) =>
      state.where((p) => p.gymId == gymId).toList();

  List<ProductModel> getByCategory(String category) {
    if (category.isEmpty || category == 'all') return state;
    return state.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
  }

  List<ProductModel> search(String query) {
    if (query.isEmpty) return state;
    final q = query.toLowerCase();
    return state.where((p) =>
      p.name.toLowerCase().contains(q) ||
      p.category.toLowerCase().contains(q) ||
      p.gymName.toLowerCase().contains(q)
    ).toList();
  }

  List<ProductModel> get discounted => state.where((p) => p.hasDiscount).toList();
}

final productsProvider = StateNotifierProvider<ProductsNotifier, List<ProductModel>>(
  (ref) => ProductsNotifier(),
);

final productByIdProvider = Provider.family<ProductModel?, String>((ref, id) {
  final products = ref.watch(productsProvider);
  try {
    return products.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
});

// ── OFFERS ────────────────────────────────────────────────────────────────

final offersProvider = Provider<List<OfferModel>>((ref) => MockData.offers);

// ── BANNERS ───────────────────────────────────────────────────────────────

final bannersProvider = Provider<List<BannerModel>>((ref) => MockData.banners);

// ── CART ──────────────────────────────────────────────────────────────────

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(ProductModel product) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);
    if (existingIndex != -1) {
      final updated = state[existingIndex].copyWith(
        quantity: state[existingIndex].quantity + 1,
      );
      final newState = [...state];
      newState[existingIndex] = updated;
      state = newState;
    } else {
      state = [...state, CartItem(id: product.id, product: product)];
    }
  }

  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    state = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
  }

  void clear() {
    state = [];
  }

  double get subtotal =>
      state.fold(0, (sum, item) => sum + item.totalPrice);

  int get totalItems =>
      state.fold(0, (sum, item) => sum + item.quantity);

  bool isInCart(String productId) =>
      state.any((item) => item.product.id == productId);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider.notifier).subtotal;
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider.notifier).totalItems;
});

// ── ORDERS ────────────────────────────────────────────────────────────────

class OrdersNotifier extends StateNotifier<List<OrderModel>> {
  OrdersNotifier() : super(MockData.orders);

  void addOrder(OrderModel order) {
    state = [order, ...state];
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, List<OrderModel>>(
  (ref) => OrdersNotifier(),
);

// ── SEARCH ────────────────────────────────────────────────────────────────

class SearchNotifier extends StateNotifier<String> {
  SearchNotifier() : super('');

  void update(String query) => state = query;
  void clear() => state = '';
}

final searchProvider = StateNotifierProvider<SearchNotifier, String>(
  (ref) => SearchNotifier(),
);

final recentSearchesProvider = StateProvider<List<String>>(
  (ref) => ['Whey Protein', 'Pre Workout', 'Pulse Fitness', 'Gym Gloves'],
);

// ── CHECKOUT ─────────────────────────────────────────────────────────────

class CheckoutNotifier extends StateNotifier<Map<String, dynamic>> {
  CheckoutNotifier() : super({
    'selectedAddress': MockData.addresses.first,
    'selectedPayment': MockData.paymentMethods.first,
    'promoCode': null,
    'promoDiscount': 0.0,
    'deliveryFee': 50.0,
  });

  void setAddress(AddressModel address) {
    state = {...state, 'selectedAddress': address};
  }

  void setPayment(PaymentMethodModel payment) {
    state = {...state, 'selectedPayment': payment};
  }

  void applyPromo(PromoCode promo) {
    state = {...state, 'promoCode': promo, 'promoDiscount': promo.discountPercent / 100};
  }

  void removePromo() {
    state = {...state, 'promoCode': null, 'promoDiscount': 0.0};
  }

  void reset() {
    state = {
      'selectedAddress': MockData.addresses.first,
      'selectedPayment': MockData.paymentMethods.first,
      'promoCode': null,
      'promoDiscount': 0.0,
      'deliveryFee': 50.0,
    };
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, Map<String, dynamic>>(
  (ref) => CheckoutNotifier(),
);

// ── GYM OWNER ─────────────────────────────────────────────────────────────

final gymOwnerModeProvider = StateProvider<bool>((ref) => false);

final ownerProductsProvider = StateProvider<List<ProductModel>>(
  (ref) => MockData.products.where((p) => p.gymId == 'gym_001').toList(),
);

// ── ONBOARDING ────────────────────────────────────────────────────────────

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboardingCompleted') ?? false;
});
