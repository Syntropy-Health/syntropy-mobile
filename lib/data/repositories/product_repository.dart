import 'package:dartz/dartz.dart';

import '../../core/utils/failure.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../datasources/remote/supabase_client.dart';
import '../models/product.dart';

class ProductRepository {
  ProductRepository({required this.supabaseClient});

  final SupabaseClientWrapper supabaseClient;

  Future<Result<List<Product>>> getProducts({
    ProductCategory? category,
    String? searchQuery,
    int? limit,
  }) async {
    try {
      Map<String, dynamic>? filters;
      if (category != null) {
        filters = {'category': category.name};
      }

      final results = await supabaseClient.fetch(
        'products',
        filters: filters,
        orderBy: 'rating',
        ascending: false,
        limit: limit,
      );

      var products = results.map((map) => Product.fromJson(map)).toList();

      // Apply search filter locally if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        products = products.where((p) {
          return p.name.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query) ||
              (p.tags?.any((t) => t.toLowerCase().contains(query)) ?? false);
        }).toList();
      }

      return Right(products);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get products', 'ProductRepo', e, stackTrace);
      return Left(ServerFailure(message: 'Failed to get products: $e'));
    }
  }

  Future<Result<Product?>> getProduct(String id) async {
    try {
      final result = await supabaseClient.fetchOne('products', id);
      if (result == null) {
        return const Right(null);
      }
      return Right(Product.fromJson(result));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get product', 'ProductRepo', e, stackTrace);
      return Left(ServerFailure(message: 'Failed to get product: $e'));
    }
  }

  Future<Result<List<Product>>> getRecommendedProducts(
    List<String> healthBenefits,
  ) async {
    try {
      // Fetch all products and filter by health benefits
      final results = await supabaseClient.fetch(
        'products',
        orderBy: 'rating',
        ascending: false,
      );

      final products = results.map((map) => Product.fromJson(map)).where((p) {
        if (p.healthBenefits == null) return false;
        return p.healthBenefits!
            .any((benefit) => healthBenefits.contains(benefit));
      }).toList();

      return Right(products);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get recommended products',
        'ProductRepo',
        e,
        stackTrace,
      );
      return Left(ServerFailure(message: 'Failed to get recommended: $e'));
    }
  }

  Future<Result<List<Product>>> getProductsByTags(List<String> tags) async {
    try {
      final results = await supabaseClient.fetch('products');

      final products = results.map((map) => Product.fromJson(map)).where((p) {
        if (p.tags == null) return false;
        return p.tags!.any((tag) => tags.contains(tag));
      }).toList();

      return Right(products);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get by tags', 'ProductRepo', e, stackTrace);
      return Left(ServerFailure(message: 'Failed to get by tags: $e'));
    }
  }

  // Mock data for offline/demo mode
  List<Product> getMockProducts() {
    return [
      const Product(
        id: '1',
        name: 'Vitamin D3 5000 IU',
        description: 'High-potency vitamin D3 for immune support and bone health',
        category: ProductCategory.supplements,
        price: 24.99,
        rating: 4.8,
        reviewCount: 1250,
        tags: ['vitamin-d', 'immune', 'bone-health'],
        healthBenefits: ['immune support', 'bone density', 'mood'],
      ),
      const Product(
        id: '2',
        name: 'Omega-3 Fish Oil',
        description: 'Pure wild-caught fish oil with EPA and DHA',
        category: ProductCategory.supplements,
        price: 29.99,
        rating: 4.7,
        reviewCount: 890,
        tags: ['omega-3', 'heart', 'brain'],
        healthBenefits: ['heart health', 'brain function', 'inflammation'],
      ),
      const Product(
        id: '3',
        name: 'Magnesium Glycinate',
        description: 'Highly absorbable magnesium for sleep and relaxation',
        category: ProductCategory.supplements,
        price: 19.99,
        rating: 4.9,
        reviewCount: 2100,
        tags: ['magnesium', 'sleep', 'relaxation'],
        healthBenefits: ['sleep quality', 'muscle relaxation', 'stress'],
      ),
    ];
  }
}
