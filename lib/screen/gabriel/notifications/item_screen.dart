import 'package:e_commerce/screen/gabriel/checkouts/main_checkouts.dart';
import 'package:e_commerce/api/api.dart';
import '../core/app_export.dart';

class ItemScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const ItemScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(data);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Product Detail',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.grey.shade200,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Main Content
          SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product Image with Shadow and Glow
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.shade100,
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 10,
                          offset: Offset(-10, -10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        '${API.BASE_URL}/images/${data['image_url']}',
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Unified Info Card with Glassmorphism
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.7),
                        Colors.grey.shade200.withOpacity(0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        data['product_name'] ?? 'Unknown Product',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Price
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: Colors.deepPurple),
                          Text(
                            '${data['price'] is int ? (data['price'] ?? '0').toStringAsFixed(2) : (int.tryParse(data['price'] ?? '0') ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Quantity
                      Row(
                        children: [
                          Icon(Icons.inventory, color: Colors.black54),
                          const SizedBox(width: 5),
                          Text(
                            'Quantity: ${data['quantity'] ?? 0}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Description
                      Text(
                        data['product_description'] ??
                            'No description available.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Floating Action Button with Animation using floatingActionButtonAnimator
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mainCheckouts(
              filterCategory: data['category_id'] is String
                  ? data['category_id']
                  : data['category_id'].toString());
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.shopping_cart, color: Colors.white),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}
