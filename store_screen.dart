import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:ascendant_reach/services/storage_service.dart';
import 'package:ascendant_reach/models/member.dart';
import 'package:ascendant_reach/models/product.dart';
import 'package:ascendant_reach/models/transaction.dart';
import 'package:ascendant_reach/services/translation_service.dart';
import 'package:ascendant_reach/widgets/common_app_bar.dart';
import 'package:ascendant_reach/widgets/credit_card_widget.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  Member? _currentMember;
  List<Product> _products = [];
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Mobile Phones', 'Phone Accessories', 'Shoes', 'Computers', 'Computer Accessories', 'Men\'s Clothing', 'Women\'s Clothing'];

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  void _loadStoreData() {
    setState(() {
      _currentMember = StorageService.getCurrentMember();
      _products = _getSampleProducts();
    });
  }

  List<Product> _getSampleProducts() {
    final imageUrls = [
      'https://pixabay.com/get/ge0b92d326627493052e451a684ccf4899f3c0f4c5195cc5ddbd2f0fe56c7279ce4249f68970e2db2ff23f0f3ba6f9823c97c007be7a306710ed393e5d370f7f2_1280.jpg',
      'https://pixabay.com/get/gce924e55a63c702000dc9ea0c37281c990835e8a51d7b74678e0d5251ad365dc57d19e9f631a61a48314a9ef8ce1e98f35404c47b1e571833c636a3f4e55f19e_1280.jpg',
      'https://pixabay.com/get/gc1b99887eb0406845eadb111acdf885f6e18bf2b7299d85de3b183f465ec23bba2a49d46063aa67d1674b49037fff339fd9033f21f4903d8f98a2c5281badaa4_1280.jpg',
      'https://pixabay.com/get/gc1b4e00dcd8d45ebd8a09697040200219678f53f65ea6237b8d1ba93ea72989a1a6b91451b4e8559e717b262147ed3f3074224b1860884f511b894edc00bbfb9_1280.jpg',
      'https://pixabay.com/get/g147052cce2482027939c6e3118b9d26f3c7a15ac6c9e5e750a78d9946642906097db52bf6f83c7be4337bb89e1453e0caf0c64ca3bd3476d7f04c443f7f1952c_1280.jpg',
      'https://pixabay.com/get/g1ecd95619a1c181b4201d304bb000ad8fdd34b960e426ec6c11a573ce2c7ab7be7f4088bc1a787a908911dd7bcfa93e2da94a04c33a792b8e13fd22300350928_1280.jpg',
    ];
    
    return [
      // Mobile Phones
      Product(
        id: '1',
        name: 'iPhone 15 Pro Max',
        description: 'Latest Apple iPhone with advanced camera system and A17 Pro chip',
        pointsRequired: 2500,
        priceInMoney: 1299.0,
        category: 'Mobile Phones',
        imageUrl: imageUrls[0],
        isAvailable: true,
        stock: 8,
        features: ['A17 Pro Chip', '48MP Camera System', '1TB Storage', 'Titanium Design'],
      ),
      Product(
        id: '2',
        name: 'Samsung Galaxy S24 Ultra',
        description: 'Premium Android smartphone with S Pen and advanced features',
        pointsRequired: 2200,
        priceInMoney: 1199.0,
        category: 'Mobile Phones',
        imageUrl: imageUrls[0],
        isAvailable: true,
        stock: 12,
        features: ['S Pen Included', '200MP Camera', '12GB RAM', 'AI Features'],
      ),
      
      // Phone Accessories
      Product(
        id: '3',
        name: 'Wireless Charging Stand',
        description: 'Fast wireless charging stand for all Qi-enabled devices',
        pointsRequired: 120,
        priceInMoney: 59.99,
        category: 'Phone Accessories',
        imageUrl: imageUrls[1],
        isAvailable: true,
        stock: 25,
        features: ['15W Fast Charging', 'Adjustable Angle', 'LED Indicator', 'Universal Compatibility'],
      ),
      Product(
        id: '4',
        name: 'Premium Bluetooth Headphones',
        description: 'Professional noise-cancelling wireless headphones',
        pointsRequired: 180,
        priceInMoney: 89.99,
        category: 'Phone Accessories',
        imageUrl: imageUrls[1],
        isAvailable: true,
        stock: 15,
        features: ['Active Noise Cancelling', '40H Battery', 'Hi-Res Audio', 'Comfortable Design'],
      ),
      
      // Shoes
      Product(
        id: '5',
        name: 'Nike Air Jordan Retro',
        description: 'Classic basketball sneakers with premium leather and comfort',
        pointsRequired: 350,
        priceInMoney: 175.0,
        category: 'Shoes',
        imageUrl: imageUrls[2],
        isAvailable: true,
        stock: 20,
        features: ['Premium Leather', 'Air Cushioning', 'Classic Design', 'Durable Construction'],
      ),
      Product(
        id: '6',
        name: 'Adidas Ultraboost Running Shoes',
        description: 'High-performance running shoes with responsive cushioning',
        pointsRequired: 280,
        priceInMoney: 140.0,
        category: 'Shoes',
        imageUrl: imageUrls[2],
        isAvailable: true,
        stock: 18,
        features: ['Boost Midsole', 'Primeknit Upper', 'Continental Rubber', 'Responsive Feel'],
      ),
      
      // Computers
      Product(
        id: '7',
        name: 'MacBook Pro 16-inch',
        description: 'Professional laptop with M3 Pro chip for demanding workflows',
        pointsRequired: 4500,
        priceInMoney: 2399.0,
        category: 'Computers',
        imageUrl: imageUrls[3],
        isAvailable: true,
        stock: 5,
        features: ['M3 Pro Chip', '18GB RAM', '512GB SSD', 'Liquid Retina XDR Display'],
      ),
      Product(
        id: '8',
        name: 'Dell XPS 13 Laptop',
        description: 'Ultra-portable laptop with stunning InfinityEdge display',
        pointsRequired: 3200,
        priceInMoney: 1599.0,
        category: 'Computers',
        imageUrl: imageUrls[3],
        isAvailable: true,
        stock: 10,
        features: ['Intel Core i7', '16GB RAM', '1TB SSD', '13.4" 4K Display'],
      ),
      
      // Computer Accessories
      Product(
        id: '9',
        name: 'Mechanical Gaming Keyboard',
        description: 'RGB backlit mechanical keyboard for gaming and productivity',
        pointsRequired: 200,
        priceInMoney: 99.99,
        category: 'Computer Accessories',
        imageUrl: imageUrls[3],
        isAvailable: true,
        stock: 30,
        features: ['Cherry MX Switches', 'RGB Lighting', 'USB-C Connection', 'Programmable Keys'],
      ),
      Product(
        id: '10',
        name: '4K Gaming Monitor',
        description: '27-inch 4K gaming monitor with high refresh rate',
        pointsRequired: 800,
        priceInMoney: 399.99,
        category: 'Computer Accessories',
        imageUrl: imageUrls[3],
        isAvailable: true,
        stock: 12,
        features: ['4K Resolution', '144Hz Refresh', 'HDR Support', 'USB-C Hub'],
      ),
      
      // Men's Clothing
      Product(
        id: '11',
        name: 'Premium Business Suit',
        description: 'Tailored business suit for professional occasions',
        pointsRequired: 600,
        priceInMoney: 299.99,
        category: 'Men\'s Clothing',
        imageUrl: imageUrls[4],
        isAvailable: true,
        stock: 15,
        features: ['Wool Blend', 'Tailored Fit', 'Professional Cut', 'Wrinkle Resistant'],
      ),
      Product(
        id: '12',
        name: 'Casual Polo Shirt Set',
        description: 'Set of 3 premium cotton polo shirts in different colors',
        pointsRequired: 180,
        priceInMoney: 89.99,
        category: 'Men\'s Clothing',
        imageUrl: imageUrls[4],
        isAvailable: true,
        stock: 25,
        features: ['100% Cotton', 'Breathable Fabric', '3 Colors', 'Classic Fit'],
      ),
      
      // Women's Clothing
      Product(
        id: '13',
        name: 'Designer Evening Dress',
        description: 'Elegant evening dress perfect for special occasions',
        pointsRequired: 450,
        priceInMoney: 225.0,
        category: 'Women\'s Clothing',
        imageUrl: imageUrls[5],
        isAvailable: true,
        stock: 12,
        features: ['Designer Cut', 'Premium Fabric', 'Elegant Style', 'Multiple Sizes'],
      ),
      Product(
        id: '14',
        name: 'Professional Blazer',
        description: 'Stylish blazer for business and professional settings',
        pointsRequired: 320,
        priceInMoney: 159.99,
        category: 'Women\'s Clothing',
        imageUrl: imageUrls[5],
        isAvailable: true,
        stock: 18,
        features: ['Professional Cut', 'Versatile Style', 'Quality Material', 'Perfect Fit'],
      ),
      Product(
        id: '15',
        name: 'Comfortable Activewear Set',
        description: 'High-performance activewear for fitness and leisure',
        pointsRequired: 150,
        priceInMoney: 75.0,
        category: 'Women\'s Clothing',
        imageUrl: imageUrls[5],
        isAvailable: true,
        stock: 22,
        features: ['Moisture Wicking', 'Stretchy Fabric', 'Yoga Friendly', 'Stylish Design'],
      ),
    ];
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'All') return _products;
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  void _purchaseProduct(Product product) {
    if (_currentMember == null) return;

    showDialog(
      context: context,
      builder: (context) => _PurchaseDialog(
        product: product,
        currentMember: _currentMember!,
        onPurchase: _processPurchase,
      ),
    );
  }

  void _processPurchase(Product product, String paymentMethod, String? walletType) {
    if (_currentMember == null) return;
    
    Member updatedMember;
    String paymentSource;
    
    // Process payment based on method
    if (paymentMethod == 'wallet') {
      double walletBalance;
      switch (walletType) {
        case 'Main Balance':
          walletBalance = _currentMember!.walletBalance;
          break;
        case 'Earning Wallet':
          walletBalance = _currentMember!.earningWallet;
          break;
        case 'Investment Wallet':
          walletBalance = _currentMember!.investmentWallet;
          break;
        case 'Wallet Commission Products':
          walletBalance = _currentMember!.walletCommissionProducts;
          break;
        default:
          walletBalance = _currentMember!.walletBalance;
      }
      
      if (walletBalance < product.priceInMoney) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(TranslationService.translate('insufficient_wallet_balance')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Deduct from selected wallet
      switch (walletType) {
        case 'Main Balance':
          updatedMember = _currentMember!.copyWith(
            walletBalance: _currentMember!.walletBalance - product.priceInMoney,
          );
          break;
        case 'Earning Wallet':
          updatedMember = _currentMember!.copyWith(
            earningWallet: _currentMember!.earningWallet - product.priceInMoney,
          );
          break;
        case 'Investment Wallet':
          updatedMember = _currentMember!.copyWith(
            investmentWallet: _currentMember!.investmentWallet - product.priceInMoney,
          );
          break;
        case 'Wallet Commission Products':
          updatedMember = _currentMember!.copyWith(
            walletCommissionProducts: _currentMember!.walletCommissionProducts - product.priceInMoney,
          );
          break;
        default:
          updatedMember = _currentMember!.copyWith(
            walletBalance: _currentMember!.walletBalance - product.priceInMoney,
          );
      }
      
      paymentSource = walletType ?? 'Main Balance';
    } else {
      // Other payment methods (credit card, etc.) - just create transaction record
      updatedMember = _currentMember!;
      paymentSource = paymentMethod;
    }
    
    StorageService.saveCurrentMember(updatedMember);
    
    // Create transaction record
    final transaction = Transaction(
      id: const Uuid().v4(),
      memberId: _currentMember!.id,
      type: TransactionType.purchase,
      amount: product.priceInMoney,
      currency: 'USD',
      status: TransactionStatus.completed,
      description: 'Product purchase: ${product.name} (${TranslationService.translate('payment_method')}: $paymentSource)',
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
      metadata: {'productId': product.id, 'paymentMethod': paymentMethod, 'walletType': walletType},
    );
    
    final transactions = StorageService.getTransactions();
    transactions.add(transaction);
    StorageService.saveTransactions(transactions);
    
    setState(() {
      _currentMember = updatedMember;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(TranslationService.translate('order_placed')),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _subscribeToProductSharing() {
    if (_currentMember == null) return;

    // Check if user has enough balance
    if (_currentMember!.walletBalance < 10.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance. You need \$10 to subscribe for product sharing.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscribe to Product Sharing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🛍️ Product Sharing Subscription', 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 12),
            const Text('• Monthly subscription: \$10'),
            const Text('• Share products with referral links'),
            const Text('• Earn 10% commission on all sales'),
            const Text('• Access to exclusive product catalog'),
            const Text('• Monthly analytics reports'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subscription Details:', 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Cost: \$10.00'),
                  Text('Duration: 30 days'),
                  Text('Commission Rate: 10% per sale'),
                  Text('Your Balance: \$${_currentMember!.walletBalance.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processSubscription();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Subscribe Now'),
          ),
        ],
      ),
    );
  }

  void _processSubscription() {
    final subscriptionCost = 10.0;
    final expiryDate = DateTime.now().add(const Duration(days: 365)); // Yearly subscription
    
    // Deduct subscription fee
    final updatedMember = _currentMember!.copyWith(
      walletBalance: _currentMember!.walletBalance - subscriptionCost,
      hasProductSharingSubscription: true,
      subscriptionExpiryDate: expiryDate,
    );
    
    StorageService.saveCurrentMember(updatedMember);
    
    // Create transaction record
    final transaction = Transaction(
      id: const Uuid().v4(),
      memberId: _currentMember!.id,
      type: TransactionType.subscriptionFee,
      amount: subscriptionCost,
      currency: 'USD',
      status: TransactionStatus.completed,
      description: 'Product Sharing Subscription (1 year)',
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
      metadata: {'subscriptionType': 'product_sharing', 'expiryDate': expiryDate.toIso8601String()},
    );
    
    final transactions = StorageService.getTransactions();
    transactions.add(transaction);
    StorageService.saveTransactions(transactions);
    
    setState(() {
      _currentMember = updatedMember;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Successfully subscribed to Product Sharing!', 
              style: TextStyle(fontWeight: FontWeight.w600)),
            Text('Expires: ${DateFormat('MMM dd, yyyy').format(expiryDate)}'),
            const Text('You can now earn 10% commission on all product sales!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareProduct(Product product) {
    if (_currentMember == null) return;

    final referralLink = 'https://gowin-store.app/product/${product.id}?ref=${_currentMember!.referralCode}';
    final shareMessage = '''
🛍️ CHECK OUT THIS AMAZING PRODUCT!

${product.name}
${product.description}

💰 Price: \$${product.priceInMoney.toStringAsFixed(2)}
⭐ Points: ${product.pointsRequired}

🔗 Shop now with my referral link:
$referralLink

When you purchase through my link, I earn 10% commission to support my GO-WIN journey!

#GoWinInternational #ProductShare #OnlineShopping
    ''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share ${product.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Referral Link:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  referralLink,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Share Message:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  shareMessage,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would use platform sharing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Referral link copied to clipboard!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Copy & Share'),
          ),
        ],
      ),
    );
  }

  bool _isSubscriptionActive() {
    if (_currentMember == null || !_currentMember!.hasProductSharingSubscription) {
      return false;
    }
    
    if (_currentMember!.subscriptionExpiryDate == null) {
      return false;
    }
    
    return DateTime.now().isBefore(_currentMember!.subscriptionExpiryDate!);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentMember == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('GO-WIN Store'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          if (!_isSubscriptionActive())
            IconButton(
              onPressed: _subscribeToProductSharing,
              icon: const Icon(Icons.share),
              tooltip: 'Subscribe to Product Sharing',
            ),
          if (_isSubscriptionActive())
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'SHARING',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildPointsHeader(),
          if (!_isSubscriptionActive())
            _buildSubscriptionBanner(),
          if (_isSubscriptionActive())
            _buildActiveSubscriptionBanner(),
          _buildCategoryFilter(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  Widget _buildPointsHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.stars,
            color: Theme.of(context).colorScheme.onSecondary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Points',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_currentMember!.points}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Wallet Balance',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.8),
                ),
              ),
              Text(
                '\$${_currentMember!.walletBalance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.share, color: Colors.blue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unlock Product Sharing',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Subscribe for \$10/month to share products and earn 10% commission',
                          style: TextStyle(color: Colors.blue.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _subscribeToProductSharing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Subscribe Now - \$10'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSubscriptionBanner() {
    final expiryDate = _currentMember!.subscriptionExpiryDate!;
    final daysRemaining = expiryDate.difference(DateTime.now()).inDays;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.verified, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Sharing Active',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '$daysRemaining days remaining • Earning 10% commission',
                      style: TextStyle(color: Colors.green.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (daysRemaining <= 7)
                ElevatedButton(
                  onPressed: _subscribeToProductSharing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Renew', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = category);
                }
              },
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected 
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    final filteredProducts = _filteredProducts;
    
    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No products in this category',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) => _buildProductCard(filteredProducts[index]),
    );
  }

  Widget _buildProductCard(Product product) {
    final canAfford = _currentMember!.points >= product.pointsRequired;
    final hasActiveSubscription = _isSubscriptionActive();
    
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _showProductDetails(product),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.store,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  if (hasActiveSubscription)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _shareProduct(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.stars,
                          size: 16,
                          color: canAfford ? Theme.of(context).colorScheme.secondary : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.pointsRequired}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: canAfford ? Theme.of(context).colorScheme.secondary : Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        if (product.stock <= 5)
                          Text(
                            'Only ${product.stock} left',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red[600],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseOptions(Product product) {
    showDialog(
      context: context,
      builder: (context) => _PurchaseDialog(
        product: product,
        currentMember: _currentMember!,
        onPurchase: _handlePurchase,
      ),
    );
  }
  
  void _handlePurchase(Product product, String paymentMethod, String walletType) {
    switch (paymentMethod) {
      case 'points':
        _purchaseProduct(product);
        break;
      case 'wallet':
        _purchaseWithWallet(product, walletType);
        break;
      case 'external':
        _purchaseWithExternalPayment(product);
        break;
    }
  }

  void _purchaseWithWallet(Product product, String walletType) {
    Member updatedMember;
    
    switch (walletType) {
      case 'Main Balance':
        if (_currentMember!.walletBalance < product.priceInMoney) {
          _showInsufficientFundsMessage();
          return;
        }
        updatedMember = _currentMember!.copyWith(
          walletBalance: _currentMember!.walletBalance - product.priceInMoney,
        );
        break;
      case 'Earning Wallet':
        if (_currentMember!.earningWallet < product.priceInMoney) {
          _showInsufficientFundsMessage();
          return;
        }
        updatedMember = _currentMember!.copyWith(
          earningWallet: _currentMember!.earningWallet - product.priceInMoney,
        );
        break;
      case 'Investment Wallet':
        if (_currentMember!.investmentWallet < product.priceInMoney) {
          _showInsufficientFundsMessage();
          return;
        }
        updatedMember = _currentMember!.copyWith(
          investmentWallet: _currentMember!.investmentWallet - product.priceInMoney,
        );
        break;
      case 'Wallet Commission Products':
        if (_currentMember!.walletCommissionProducts < product.priceInMoney) {
          _showInsufficientFundsMessage();
          return;
        }
        updatedMember = _currentMember!.copyWith(
          walletCommissionProducts: _currentMember!.walletCommissionProducts - product.priceInMoney,
        );
        break;
      default:
        return;
    }
    
    StorageService.saveCurrentMember(updatedMember);
    
    // Create transaction record
    final transaction = Transaction(
      id: const Uuid().v4(),
      memberId: _currentMember!.id,
      type: TransactionType.purchase,
      amount: product.priceInMoney,
      currency: 'USD',
      status: TransactionStatus.completed,
      description: 'Product purchase with $walletType: ${product.name}',
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
      metadata: {'productId': product.id, 'paymentMethod': walletType},
    );
    
    final transactions = StorageService.getTransactions();
    transactions.add(transaction);
    StorageService.saveTransactions(transactions);
    
    setState(() {
      _currentMember = updatedMember;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully purchased ${product.name} with $walletType!'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _purchaseWithExternalPayment(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('External payment selected for ${product.name}'),
            Text('Amount: \$${product.priceInMoney.toStringAsFixed(2)}'),
            Text('Please contact support to complete this purchase.'),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
      ),
    );
  }
  
  void _showInsufficientFundsMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Insufficient funds in selected wallet'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _purchaseWithMoney(Product product) {
    // Deduct money from wallet instead of points
    final updatedMember = _currentMember!.copyWith(
      walletBalance: _currentMember!.walletBalance - product.priceInMoney,
    );
    
    StorageService.saveCurrentMember(updatedMember);
    
    // Create transaction record
    final transaction = Transaction(
      id: const Uuid().v4(),
      memberId: _currentMember!.id,
      type: TransactionType.purchase,
      amount: product.priceInMoney,
      currency: 'USD',
      status: TransactionStatus.completed,
      description: 'Product purchase with wallet: ${product.name}',
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
      metadata: {'productId': product.id, 'paymentMethod': 'wallet'},
    );
    
    final transactions = StorageService.getTransactions();
    transactions.add(transaction);
    StorageService.saveTransactions(transactions);
    
    setState(() {
      _currentMember = updatedMember;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully purchased ${product.name} with wallet balance!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showProductDetails(Product product) {
    final canAfford = _currentMember!.points >= product.pointsRequired;
    final canAffordWithWallet = _currentMember!.walletBalance >= product.priceInMoney;
    final hasActiveSubscription = _isSubscriptionActive();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(product.name)),
            if (hasActiveSubscription)
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  _shareProduct(product);
                },
                icon: const Icon(Icons.share, color: Colors.blue),
                tooltip: 'Share with referral link',
              ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.store, size: 48),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                product.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Features:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...product.features.map((feature) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature)),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.stars, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text(
                    '${product.pointsRequired} points OR \$${product.priceInMoney.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              if (!canAfford && !canAffordWithWallet) ...[
                const SizedBox(height: 8),
                Text(
                  'You need ${product.pointsRequired - _currentMember!.points} more points OR \$${(product.priceInMoney - _currentMember!.walletBalance).toStringAsFixed(2)} more in wallet',
                  style: TextStyle(color: Colors.red[600]),
                ),
              ],
              if (hasActiveSubscription) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.share, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You can earn 10% commission (\$${(product.priceInMoney * 0.1).toStringAsFixed(2)}) by sharing this product!',
                          style: TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (canAfford || canAffordWithWallet)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showPurchaseOptions(product);
              },
              child: const Text('Purchase'),
            ),
        ],
      ),
    );
  }
}

class _PurchaseDialog extends StatefulWidget {
  final Product product;
  final Member currentMember;
  final Function(Product product, String paymentMethod, String walletType) onPurchase;

  const _PurchaseDialog({
    required this.product,
    required this.currentMember,
    required this.onPurchase,
  });

  @override
  State<_PurchaseDialog> createState() => _PurchaseDialogState();
}

class _PurchaseDialogState extends State<_PurchaseDialog> {
  String _selectedPaymentMethod = 'wallet';
  String _selectedWallet = 'Main Balance';
  int _quantity = 1;
  String _selectedQuality = 'Standard';
  String _deliveryMethod = 'Standard Shipping';
  final _addressController = TextEditingController();
  
  final List<String> _qualityOptions = ['Standard', 'Premium', 'Deluxe'];
  final List<String> _deliveryOptions = ['Standard Shipping', 'Express Shipping', 'Premium Delivery', 'Pick-up Location'];
  final Map<String, double> _deliveryFees = {
    'Standard Shipping': 5.99,
    'Express Shipping': 12.99,
    'Premium Delivery': 24.99,
    'Pick-up Location': 0.0,
  };
  final Map<String, double> _qualityMultipliers = {
    'Standard': 1.0,
    'Premium': 1.25,
    'Deluxe': 1.5,
  };
  
  Map<String, double> _getAvailableWallets() {
    return {
      'Main Balance': widget.currentMember.walletBalance,
      'Earning Wallet': widget.currentMember.earningWallet,
      'Investment Wallet': widget.currentMember.investmentWallet,
      'Wallet Commission Products': widget.currentMember.walletCommissionProducts,
    };
  }
  
  double get _basePrice => widget.product.priceInMoney * _qualityMultipliers[_selectedQuality]!;
  double get _totalPrice => (_basePrice * _quantity) + (_deliveryFees[_deliveryMethod] ?? 0.0);
  
  String get _bonusOffer {
    if (_quantity >= 5) return 'Buy 5+: Get 20% discount on next purchase + Free Premium Shipping';
    if (_quantity >= 3) return 'Buy 3+: Get 15% discount on next purchase + Express Shipping';
    if (_quantity >= 2) return 'Buy 2+: Get 10% discount on accessories';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final availableWallets = _getAvailableWallets();
    final selectedWalletBalance = availableWallets[_selectedWallet] ?? 0.0;
    final canAffordWithWallet = selectedWalletBalance >= _totalPrice;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      TranslationService.translate('purchase') + ': ${widget.product.name}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.product.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.store),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.product.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 2,
                                ),
                                Text(
                                  '${TranslationService.translate('category')}: ${widget.product.category}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                                Text(
                                  '${TranslationService.translate('stock')}: ${widget.product.stock} ${TranslationService.translate('available')}',
                                  style: TextStyle(color: Colors.green[600], fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quantity Selection
                    Text(
                      TranslationService.translate('quantity') + ':',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          style: IconButton.styleFrom(
                            backgroundColor: _quantity > 1 ? Theme.of(context).primaryColor : Colors.grey[300],
                            foregroundColor: _quantity > 1 ? Colors.white : Colors.grey,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _quantity.toString(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: _quantity < widget.product.stock ? () => setState(() => _quantity++) : null,
                          icon: const Icon(Icons.add_circle_outline),
                          style: IconButton.styleFrom(
                            backgroundColor: _quantity < widget.product.stock ? Theme.of(context).primaryColor : Colors.grey[300],
                            foregroundColor: _quantity < widget.product.stock ? Colors.white : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (_quantity >= 2)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                '🎁 ${TranslationService.translate('bonus')}: $_bonusOffer',
                                style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w500),
                                maxLines: 2,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Quality Selection
                    Text(
                      TranslationService.translate('quality') + ':',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _qualityOptions.map((quality) {
                        final isSelected = quality == _selectedQuality;
                        final multiplier = _qualityMultipliers[quality]!;
                        return FilterChip(
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(quality),
                              Text(
                                '+${((multiplier - 1) * 100).toInt()}%',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) => setState(() => _selectedQuality = quality),
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                          selectedColor: Theme.of(context).colorScheme.primaryContainer,
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Delivery Method
                    Text(
                      TranslationService.translate('delivery_method') + ':',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: _deliveryOptions.map((delivery) {
                        final fee = _deliveryFees[delivery]!;
                        final isSelected = delivery == _deliveryMethod;
                        return RadioListTile<String>(
                          dense: true,
                          title: Row(
                            children: [
                              Icon(
                                delivery == 'Express Shipping' ? Icons.flash_on :
                                delivery == 'Premium Delivery' ? Icons.star :
                                delivery == 'Pick-up Location' ? Icons.store :
                                Icons.local_shipping,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(delivery, style: const TextStyle(fontSize: 14))),
                              Text(
                                fee == 0 ? TranslationService.translate('free') : '+\$${fee.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: fee == 0 ? Colors.green : Theme.of(context).primaryColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          value: delivery,
                          groupValue: _deliveryMethod,
                          onChanged: (value) => setState(() => _deliveryMethod = value!),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Delivery Address
                    Text(
                      TranslationService.translate('delivery_address') + ':',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: TranslationService.translate('enter_delivery_address'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Payment Method Selection
                    Text(
                      TranslationService.translate('payment_method') + ':',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    
                    // Wallet Payment
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('${TranslationService.translate('wallet')} (\$${_totalPrice.toStringAsFixed(2)})'),
                        ],
                      ),
                      value: 'wallet',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                    ),
                    
                    if (_selectedPaymentMethod == 'wallet') ...[
                      Container(
                        margin: const EdgeInsets.only(left: 16, top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              TranslationService.translate('select_wallet') + ':',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            ...availableWallets.entries.map((wallet) {
                              final balance = wallet.value;
                              final canAfford = balance >= _totalPrice;
                              return RadioListTile<String>(
                                dense: true,
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        TranslationService.translate(wallet.key.toLowerCase().replaceAll(' ', '_')),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: canAfford ? null : Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '\$${balance.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: canAfford ? Colors.green : Colors.red,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                value: wallet.key,
                                groupValue: _selectedWallet,
                                onChanged: canAfford ? (value) => setState(() => _selectedWallet = value!) : null,
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                    
                    // Credit LiveGood Payment
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(Icons.credit_card, color: Colors.green),
                          const SizedBox(width: 8),
                          Text('${TranslationService.translate('credit_livegood')} (\$${_totalPrice.toStringAsFixed(2)})'),
                        ],
                      ),
                      subtitle: Text(TranslationService.translate('livegood_payment_desc'), style: const TextStyle(fontSize: 12)),
                      value: 'credit_livegood',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                    ),
                    
                    // Cash Payment
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(Icons.money, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text('${TranslationService.translate('cash')} (\$${_totalPrice.toStringAsFixed(2)})'),
                        ],
                      ),
                      subtitle: Text(TranslationService.translate('cash_payment_desc'), style: const TextStyle(fontSize: 12)),
                      value: 'cash',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                    ),
                    
                    // Credit Card Payment
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(Icons.payment, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text('${TranslationService.translate('credit_card')} (\$${_totalPrice.toStringAsFixed(2)})'),
                        ],
                      ),
                      subtitle: Text(TranslationService.translate('card_payment_desc'), style: const TextStyle(fontSize: 12)),
                      value: 'credit_card',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Price Breakdown
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TranslationService.translate('price_breakdown'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          _buildPriceRow('${TranslationService.translate('base_price')} x $_quantity', '\$${(_basePrice * _quantity).toStringAsFixed(2)}'),
                          _buildPriceRow('${TranslationService.translate('quality')}: $_selectedQuality', '+${((_qualityMultipliers[_selectedQuality]! - 1) * widget.product.priceInMoney * _quantity).toStringAsFixed(2)}'),
                          _buildPriceRow('${TranslationService.translate('delivery')}: $_deliveryMethod', _deliveryFees[_deliveryMethod]! == 0 ? TranslationService.translate('free') : '+\$${_deliveryFees[_deliveryMethod]!.toStringAsFixed(2)}'),
                          const Divider(),
                          _buildPriceRow(
                            TranslationService.translate('total'),
                            '\$${_totalPrice.toStringAsFixed(2)}',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(TranslationService.translate('cancel')),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _canProceedWithPurchase() ? () {
                        Navigator.pop(context);
                        widget.onPurchase(widget.product, _selectedPaymentMethod, _selectedWallet);
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(TranslationService.translate('place_order')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }
  
  bool _canProceedWithPurchase() {
    if (_addressController.text.trim().isEmpty && _deliveryMethod != 'Pick-up Location') {
      return false;
    }
    
    switch (_selectedPaymentMethod) {
      case 'wallet':
        final selectedWalletBalance = _getAvailableWallets()[_selectedWallet] ?? 0.0;
        return selectedWalletBalance >= _totalPrice;
      case 'credit_livegood':
      case 'cash':
      case 'credit_card':
        return true;
      default:
        return false;
    }
  }
  
  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}