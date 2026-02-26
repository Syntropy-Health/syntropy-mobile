import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

enum ProductCategory { supplements, foods, equipment, books, other }

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String description,
    required ProductCategory category,
    required double price,
    String? imageUrl,
    String? affiliateUrl,
    double? rating,
    int? reviewCount,
    List<String>? tags,
    List<String>? healthBenefits,
    @Default(true) bool isAvailable,
    Map<String, dynamic>? metadata,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

extension ProductExtension on Product {
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'price': price,
      'image_url': imageUrl,
      'affiliate_url': affiliateUrl,
      'rating': rating,
      'review_count': reviewCount,
      'tags': tags?.join(','),
      'health_benefits': healthBenefits?.join(','),
      'is_available': isAvailable ? 1 : 0,
    };
  }

  static Product fromDbMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      category: ProductCategory.values.byName(map['category'] as String),
      price: (map['price'] as num).toDouble(),
      imageUrl: map['image_url'] as String?,
      affiliateUrl: map['affiliate_url'] as String?,
      rating: (map['rating'] as num?)?.toDouble(),
      reviewCount: map['review_count'] as int?,
      tags: (map['tags'] as String?)?.split(','),
      healthBenefits: (map['health_benefits'] as String?)?.split(','),
      isAvailable: (map['is_available'] as int?) == 1,
    );
  }
}
