class GymModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final double rating;
  final int reviewCount;
  final double distance;
  final String imageUrl;
  final String logoUrl;
  final String coverUrl;
  final bool isOpen;
  final String openingHours;
  final String closingHours;
  final String phone;
  final String about;
  final List<String> facilities;
  final List<String> photos;
  final double lat;
  final double lng;
  bool isFavorite;

  GymModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.imageUrl,
    required this.logoUrl,
    required this.coverUrl,
    required this.isOpen,
    required this.openingHours,
    required this.closingHours,
    required this.phone,
    required this.about,
    required this.facilities,
    required this.photos,
    required this.lat,
    required this.lng,
    this.isFavorite = false,
  });

  GymModel copyWith({
    bool? isFavorite,
    bool? isOpen,
  }) {
    return GymModel(
      id: id,
      name: name,
      address: address,
      city: city,
      rating: rating,
      reviewCount: reviewCount,
      distance: distance,
      imageUrl: imageUrl,
      logoUrl: logoUrl,
      coverUrl: coverUrl,
      isOpen: isOpen ?? this.isOpen,
      openingHours: openingHours,
      closingHours: closingHours,
      phone: phone,
      about: about,
      facilities: facilities,
      photos: photos,
      lat: lat,
      lng: lng,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String imageUrl;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
  });
}

class ProductModel {
  final String id;
  final String gymId;
  final String gymName;
  final String name;
  final String category;
  final String description;
  final double price;
  final double? discountPrice;
  final int? discountPercent;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> images;
  final int stock;
  final String sku;
  bool isFavorite;

  ProductModel({
    required this.id,
    required this.gymId,
    required this.gymName,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    this.discountPrice,
    this.discountPercent,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.images,
    required this.stock,
    required this.sku,
    this.isFavorite = false,
  });

  bool get hasDiscount => discountPrice != null && discountPercent != null;

  double get finalPrice => discountPrice ?? price;

  ProductModel copyWith({bool? isFavorite}) {
    return ProductModel(
      id: id,
      gymId: gymId,
      gymName: gymName,
      name: name,
      category: category,
      description: description,
      price: price,
      discountPrice: discountPrice,
      discountPercent: discountPercent,
      rating: rating,
      reviewCount: reviewCount,
      imageUrl: imageUrl,
      images: images,
      stock: stock,
      sku: sku,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class OfferModel {
  final String id;
  final String productId;
  final String gymId;
  final String gymName;
  final double gymDistance;
  final String productName;
  final String imageUrl;
  final double originalPrice;
  final double discountedPrice;
  final int discountPercent;
  final DateTime expiryDate;
  final String description;

  const OfferModel({
    required this.id,
    required this.productId,
    required this.gymId,
    required this.gymName,
    required this.gymDistance,
    required this.productName,
    required this.imageUrl,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercent,
    required this.expiryDate,
    required this.description,
  });

  double get savings => originalPrice - discountedPrice;
}

class CartItem {
  final String id;
  final ProductModel product;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.finalPrice * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final String productId;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    required this.productId,
  });
}

class OrderItem {
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  final int quantity;
  final String gymName;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.gymName,
  });

  double get total => price * quantity;
}

enum OrderStatus { processing, ready, completed, cancelled }

class OrderModel {
  final String id;
  final String orderNumber;
  final DateTime date;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final String deliveryAddress;
  final String paymentMethod;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
  });
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String location;
  final bool isGymOwner;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.location,
    this.isGymOwner = false,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? location,
    bool? isGymOwner,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      location: location ?? this.location,
      isGymOwner: isGymOwner ?? this.isGymOwner,
    );
  }
}

class PromoCode {
  final String code;
  final int discountPercent;
  final String description;
  final bool isValid;

  const PromoCode({
    required this.code,
    required this.discountPercent,
    required this.description,
    required this.isValid,
  });
}

class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String tag;
  final String color;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.tag,
    required this.color,
  });
}

class AddressModel {
  final String id;
  final String label;
  final String street;
  final String city;
  final String fullAddress;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.fullAddress,
    this.isDefault = false,
  });
}

class PaymentMethodModel {
  final String id;
  final String type; // 'card', 'cash', 'apple_pay'
  final String label;
  final String? lastFour;
  final String? cardBrand;
  final bool isDefault;

  const PaymentMethodModel({
    required this.id,
    required this.type,
    required this.label,
    this.lastFour,
    this.cardBrand,
    this.isDefault = false,
  });
}
