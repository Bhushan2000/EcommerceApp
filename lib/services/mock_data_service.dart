import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';

class MockDataService {
  static List<CategoryModel> getCategories() {
    return [
      CategoryModel(
        id: 'cat_electronics',
        name: 'Electronics',
        iconName: 'devices',
        imageUrl:
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&auto=format&fit=crop&q=80',
        productCount: 12,
      ),
      CategoryModel(
        id: 'cat_fashion',
        name: 'Fashion',
        iconName: 'clothing',
        imageUrl:
            'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=500&auto=format&fit=crop&q=80',
        productCount: 18,
      ),
      CategoryModel(
        id: 'cat_home',
        name: 'Home & Living',
        iconName: 'furniture',
        imageUrl:
            'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=500&auto=format&fit=crop&q=80',
        productCount: 8,
      ),
      CategoryModel(
        id: 'cat_beauty',
        name: 'Beauty',
        iconName: 'beauty',
        imageUrl:
            'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=500&auto=format&fit=crop&q=80',
        productCount: 9,
      ),
      CategoryModel(
        id: 'cat_sports',
        name: 'Sports & Fitness',
        iconName: 'fitness',
        imageUrl:
            'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500&auto=format&fit=crop&q=80',
        productCount: 14,
      ),
      CategoryModel(
        id: 'cat_jewelry',
        name: 'Jewelry & Watches',
        iconName: 'jewelry',
        imageUrl:
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&auto=format&fit=crop&q=80',
        productCount: 6,
      ),
    ];
  }

  static List<ProductModel> getProducts() {
    return [
      ProductModel(
        id: 'prod_1',
        title: 'Sony WH-1000XM5 Wireless Headphones',
        description:
            'Industry-leading noise canceling with two processors and eight microphones. Ultra-comfortable lightweight design with soft fit leather, 30-hour battery life, and crystal-clear hands-free calling.',
        price: 349.99,
        originalPrice: 399.99,
        categoryId: 'cat_electronics',
        categoryName: 'Electronics',
        images: [
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=800&auto=format&fit=crop&q=80',
        ],
        rating: 4.8,
        reviewCount: 320,
        stock: 35,
        availableColors: ['Midnight Black', 'Silver Cloud', 'Navy Blue'],
        availableSizes: ['Standard'],
        isFeatured: true,
        isFlashSale: true,
        tags: ['audio', 'wireless', 'bluetooth', 'premium'],
        reviews: [
          ReviewModel(
            id: 'rev_1',
            userId: 'user_alex',
            userName: 'Alex Morgan',
            rating: 5.0,
            comment:
                'The noise canceling is phenomenal! Battery lasts for days on a single charge.',
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
          ReviewModel(
            id: 'rev_2',
            userId: 'user_sarah',
            userName: 'Sarah Jenkins',
            rating: 4.5,
            comment:
                'Super comfortable during long flights. Sound quality is crisp and bass is deep.',
            createdAt: DateTime.now().subtract(const Duration(days: 8)),
          ),
        ],
      ),
      ProductModel(
        id: 'prod_2',
        title: 'Apple Watch Series 9 GPS',
        description:
            'Smarter, brighter, mightier. Features the S9 chip, a magic new double tap gesture to interact with your watch without touching the screen, and advanced health sensors.',
        price: 389.00,
        originalPrice: 429.00,
        categoryId: 'cat_electronics',
        categoryName: 'Electronics',
        images: [
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=800&auto=format&fit=crop&q=80',
        ],
        rating: 4.9,
        reviewCount: 512,
        stock: 20,
        availableColors: ['Starlight', 'Midnight', 'Silver', 'Product(RED)'],
        availableSizes: ['41mm', '45mm'],
        isFeatured: true,
        isFlashSale: false,
        tags: ['smartwatch', 'apple', 'fitness', 'tech'],
      ),
      ProductModel(
        id: 'prod_3',
        title: 'Minimalist Italian Leather Jacket',
        description:
            'Crafted from supple full-grain Italian lambskin with custom matte silver hardware and quilted interior lining. A timeless silhouette built to age gracefully.',
        price: 289.50,
        originalPrice: 350.00,
        categoryId: 'cat_fashion',
        categoryName: 'Fashion',
        images: [
          'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1521223890158-f9f7c3d5d504?w=800&auto=format&fit=crop&q=80',
        ],
        rating: 4.7,
        reviewCount: 145,
        stock: 14,
        availableColors: ['Vintage Cognac', 'Obsidian Black'],
        availableSizes: ['S', 'M', 'L', 'XL'],
        isFeatured: true,
        isFlashSale: true,
        tags: ['outerwear', 'leather', 'winter', 'luxury'],
      ),
      ProductModel(
        id: 'prod_4',
        title: 'Ergonomic Scandinavian Lounge Chair',
        description:
            'Inspired by mid-century Nordic architecture. Features contoured oak bentwood, high-resilience foam cushioning, and textured boucle upholstery.',
        price: 499.00,
        originalPrice: 599.00,
        categoryId: 'cat_home',
        categoryName: 'Home & Living',
        images: [
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&auto=format&fit=crop&q=80',
        ],
        rating: 4.6,
        reviewCount: 88,
        stock: 8,
        availableColors: ['Natural Cream', 'Slate Grey', 'Olive'],
        availableSizes: ['Standard'],
        isFeatured: false,
        isFlashSale: false,
        tags: ['furniture', 'nordic', 'decor', 'comfort'],
      ),
      ProductModel(
        id: 'prod_5',
        title: 'Nike Air Zoom Pegasus 40',
        description:
            'A springy ride for any run. Engineered mesh offers breathability and lightweight structure, while responsive Zoom Air units energize every stride.',
        price: 130.00,
        originalPrice: 150.00,
        categoryId: 'cat_sports',
        categoryName: 'Sports & Fitness',
        images: [
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=800&auto=format&fit=crop&q=80',
        ],
        rating: 4.8,
        reviewCount: 680,
        stock: 45,
        availableColors: ['Sport Red', 'Triple White', 'Phantom Black'],
        availableSizes: ['8', '9', '10', '11', '12'],
        isFeatured: true,
        isFlashSale: false,
        tags: ['shoes', 'running', 'nike', 'athletic'],
      ),
      ProductModel(
        id: 'prod_6',
        title: 'L\'Occitane Organic Botanical Skincare Set',
        description:
            'Hydrate and revitalize your natural glow. Infused with organic immortelle essential oil, hyaluronic acid, and shea butter for radiant, youthful skin.',
        price: 85.00,
        originalPrice: 110.00,
        categoryId: 'cat_beauty',
        categoryName: 'Beauty',
        images: [
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1608248597359-002d29505c8d?w=800&auto=format&fit=crop&q=80',
        ],
        rating: 4.9,
        reviewCount: 210,
        stock: 30,
        availableColors: ['Default'],
        availableSizes: ['Standard Gift Box'],
        isFeatured: false,
        isFlashSale: true,
        tags: ['skincare', 'organic', 'beauty', 'gift'],
      ),
      ProductModel(
        id: 'prod_7',
        title: 'Fujifilm X-T5 Mirrorless Camera Body',
        description:
            '40.2MP X-Trans CMOS 5 HR sensor, 5-axis in-body image stabilization up to 7.0 stops, 6.2K 30p movie recording, and classic dial-based analog control layout.',
        price: 1699.00,
        originalPrice: 1799.00,
        categoryId: 'cat_electronics',
        categoryName: 'Electronics',
        images: [
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800&auto=format&fit=crop&q=80',
        ],
        rating: 4.9,
        reviewCount: 94,
        stock: 5,
        availableColors: ['Silver / Black', 'All Black'],
        availableSizes: ['Body Only'],
        isFeatured: true,
        isFlashSale: false,
        tags: ['camera', 'photography', '4k', 'fujifilm'],
      ),
      ProductModel(
        id: 'prod_8',
        title: 'Handcrafted Ceramic Dripper & Mug Set',
        description:
            'Artisan glazed stoneware designed for pour-over coffee connoisseurs. Includes slow-drip conical brewer, matching 350ml ribbed mug, and bamboo coaster.',
        price: 48.00,
        originalPrice: 60.00,
        categoryId: 'cat_home',
        categoryName: 'Home & Living',
        images: [
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800&auto=format&fit=crop&q=80',
        ],
        rating: 4.7,
        reviewCount: 67,
        stock: 22,
        availableColors: ['Speckled Sand', 'Matte Sage'],
        availableSizes: ['350ml'],
        isFeatured: false,
        isFlashSale: false,
        tags: ['coffee', 'kitchen', 'ceramic', 'handmade'],
      ),
    ];
  }
}
