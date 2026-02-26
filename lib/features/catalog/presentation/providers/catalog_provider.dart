import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../data/models/product.dart';

// Search Query Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Selected Category Provider
final selectedCategoryProvider = StateProvider<ProductCategory?>((ref) => null);

// Products Provider
final productsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final category = ref.watch(selectedCategoryProvider);

  final result = await repository.getProducts(
    category: category,
    searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
  );

  return result.fold(
    (failure) {
      // Return mock products on failure (for demo)
      return repository.getMockProducts();
    },
    (products) => products.isEmpty ? repository.getMockProducts() : products,
  );
});

// Cart Provider
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      state = [
        ...state.sublist(0, existingIndex),
        state[existingIndex].copyWith(
          quantity: state[existingIndex].quantity + quantity,
        ),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, CartItem(product: product, quantity: quantity)];
    }
  }

  void removeFromCart(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    state = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
  }

  void clearCart() {
    state = [];
  }

  double get totalPrice {
    return state.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  int get totalItems {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

// Cart Item Model
class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
  });

  final Product product;
  final int quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

// Category Options
const List<CategoryOption> categoryOptions = [
  CategoryOption(
    category: null,
    name: 'All',
    icon: 'grid_view',
  ),
  CategoryOption(
    category: ProductCategory.supplements,
    name: 'Supplements',
    icon: 'medication',
  ),
  CategoryOption(
    category: ProductCategory.foods,
    name: 'Foods',
    icon: 'restaurant',
  ),
  CategoryOption(
    category: ProductCategory.equipment,
    name: 'Equipment',
    icon: 'fitness_center',
  ),
  CategoryOption(
    category: ProductCategory.books,
    name: 'Books',
    icon: 'menu_book',
  ),
];

class CategoryOption {
  const CategoryOption({
    required this.category,
    required this.name,
    required this.icon,
  });

  final ProductCategory? category;
  final String name;
  final String icon;
}
