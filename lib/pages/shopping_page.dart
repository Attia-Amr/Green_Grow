import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    home: ShoppingPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class ShoppingPage extends StatefulWidget {
  @override
  _ShoppingPageState createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, String>> products = [];
  List<String> cartItems = [];

  @override
  void initState() {
    super.initState();    
    _loadProducts();
  }

  void _loadProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? productsData = prefs.getString('products');
    if (productsData != null) {
      List<dynamic> decodedData = json.decode(productsData);
      setState(() {
        products = decodedData.map((e) => Map<String, String>.from(e)).toList();
      });
    }
  }

  void _saveProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedData = json.encode(products);
    await prefs.setString('products', encodedData);
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromARGB(255, 26, 66, 27),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void addToCart(String itemName) async {
    if (!cartItems.contains(itemName)) {
      setState(() {
        cartItems.add(itemName); 
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('cartItems', cartItems);

      showSnackBar("Added to cart: $itemName");
    } else {
      showSnackBar("This item is already in your cart");
    }
  }

  void removeProductFromList(String productName) async {
    setState(() {
      products.removeWhere((product) => product['name'] == productName);
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedData = json.encode(products);
    await prefs.setString('products', encodedData);
  }

  void goToCartPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartPage(
          cartItems: cartItems,
          onPaymentComplete: (purchasedProducts) {
            for (var product in purchasedProducts) {
              removeProductFromList(product);
            }
          },
        ),
      ),
    );
  }

  void goToSellingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SellProductPage(
          onProductAdded: _loadProducts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 242, 242), // تغيير اللون الخلفي هنا
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(95),
        child: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(top: 18),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
              color: Color.fromARGB(255, 243, 242, 242),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: const Text(
              'Shopping',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Color.fromARGB(255, 238, 241, 240),
                shadows: [
                  Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black),
                ],
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 18, right: 10),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: goToCartPage,
                  ),
                  if (cartItems.isNotEmpty)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: Colors.red,
                        child: Text(
                          '${cartItems.length}',
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 15, 77, 48),
                  Color.fromARGB(255, 5, 14, 8),
                ],
                stops: [0.3, 6.0],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search for crops or fertilizers...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.68,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: product['imagePath'] != null
                                ? Image.file(
                                    File(product['imagePath']!),
                                    height: 90,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'images/corn.jpg',
                                    height: 90,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            product['name'] ?? '',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text('Quantity: ${product['quantity']}', style: TextStyle(fontSize: 12)),
                          Text('Price: ${product['price']}', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_offer, color: const Color.fromARGB(255, 61, 150, 64), size: 16),
                              const SizedBox(width: 4),
                              Text('Organic', style: TextStyle(color: Color.fromARGB(255, 61, 150, 64), fontSize: 12)),
                            ],
                          ),
                          Spacer(),
                       ElevatedButton(
  onPressed: () => addToCart(product['name']!),
  child: Text(
    "Add to Cart",
    style: TextStyle(color: Color.fromARGB(255, 30, 109, 35)), // لون النص زيتي
  ),
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    textStyle: TextStyle(fontSize: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
)

                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
ElevatedButton(
  onPressed: goToSellingPage,
  child: Text(
    'Selling',
    style: TextStyle(
      color: Colors.white,  // White text
      fontSize: 24,  // Increase font size
      fontWeight: FontWeight.bold,  // Make the text bold
    ),
  ),
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(vertical: 10), // Adjusted height, no horizontal padding needed
    backgroundColor: Color.fromARGB(255, 0, 77, 40), // Olive green background
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(13), // Rounded corners
    ),
    minimumSize: Size(double.infinity, 50), // Make button take up full width and set height
  ),
),




          ],
        ),
      ),
    );
  }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class CartPage extends StatefulWidget {
  final List<String> cartItems;
  final Function(List<String>) onPaymentComplete;

  CartPage({required this.cartItems, required this.onPaymentComplete});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<String, double> productPrices = {};
  Map<String, int> productQuantities = {};
  // Map<String, String> productImages = {}; // صور المنتجات

  List<String> cart = [];

  @override
  void initState() {
    super.initState();
    _loadProductPrices();
    _loadCartItems();
  }

  Future<void> _loadProductPrices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? productsData = prefs.getString('products');
    if (productsData != null) {
      List<dynamic> decodedData = json.decode(productsData);
      for (var product in decodedData) {
        final Map<String, dynamic> item = Map<String, dynamic>.from(product);
        final name = item['name'];
        final price = double.tryParse(item['price'].toString()) ?? 0;
        final imageUrl = item['imageUrl'] ?? '';
        productPrices[name] = price;
        productQuantities[name] = 1;
        // productImages[name] = imageUrl;
      }
      setState(() {});
    }
  }

  Future<void> _loadCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedCart = prefs.getStringList('cartItems');
    if (savedCart != null && savedCart.isNotEmpty) {
      setState(() {
        cart = savedCart;
      });
    }
  }

  Future<void> _saveCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cartItems', cart);
  }

  double get subtotal {
    double sum = 0;
    for (var item in cart) {
      sum += (productPrices[item] ?? 0) * (productQuantities[item] ?? 1);
    }
    return sum;
  }

  double get delivery => 4.0;
  double get tax => subtotal * 0.032;
  double get total => subtotal + delivery + tax;

  void increaseQty(String item) {
    setState(() {
      productQuantities[item] = (productQuantities[item] ?? 1) + 1;
    });
  }

  void decreaseQty(String item) {
    setState(() {
      if ((productQuantities[item] ?? 1) > 1) {
        productQuantities[item] = (productQuantities[item] ?? 1) - 1;
      }
    });
  }

  void removeItem(String item) {
    setState(() {
      cart.remove(item);
    });
    _saveCartItems();
  }
void _showPaymentDialog() {
  TextEditingController cardController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController expiryController = TextEditingController();
  TextEditingController cvvController = TextEditingController();

  String selectedPaymentMethod = '';

  showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.lock, color: Color.fromARGB(255, 26, 65, 28)),
                SizedBox(width: 8),
                Text(
                  "Secure Payment",
                  style: TextStyle(color: Color.fromARGB(255, 30, 78, 33)),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Payment Methods
                  Column(
                    children: [
                      _buildPaymentOption(
                        title: 'Credit Card',
                        icon: Icons.credit_card,
                        isSelected: selectedPaymentMethod == 'Credit Card',
                        onTap: () => setState(() => selectedPaymentMethod = 'Credit Card'),
                      ),
                      SizedBox(height: 10),
                      _buildPaymentOption(
                        title: 'Apple Pay',
                        icon: Icons.phone_iphone,
                        isSelected: selectedPaymentMethod == 'Apple Pay',
                        onTap: () => setState(() => selectedPaymentMethod = 'Apple Pay'),
                      ),
                      SizedBox(height: 10),
                      _buildPaymentOption(
                        title: 'PayPal',
                        icon: Icons.account_balance_wallet,
                        isSelected: selectedPaymentMethod == 'PayPal',
                        onTap: () => setState(() => selectedPaymentMethod = 'PayPal'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Show Card Form if Credit Card is selected
                  if (selectedPaymentMethod == 'Credit Card')
                    Column(
                      children: [
                        TextField(
                          controller: cardController,
                          decoration: InputDecoration(
                            labelText: 'Card Number',
                            hintText: 'XXXX-XXXX-XXXX-XXXX',
                            prefixIcon: Icon(Icons.credit_card),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            counterText: '',
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Card Holder Name',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: expiryController,
                                decoration: InputDecoration(
                                  labelText: 'MM/YY',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  counterText: '',
                                ),
                                keyboardType: TextInputType.datetime,
                                maxLength: 5,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: cvvController,
                                decoration: InputDecoration(
                                  labelText: 'CVV',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  counterText: '',
                                ),
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                maxLength: 4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  // Horizontal Scroll for Apple Pay and PayPal
                  if (selectedPaymentMethod == 'Apple Pay' || selectedPaymentMethod == 'PayPal')
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                selectedPaymentMethod == 'Apple Pay'
                                    ? "Apple Pay selected. Proceed to confirm order."
                                    : "PayPal selected. Proceed to confirm order.",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(color: const Color.fromARGB(255, 48, 47, 47))),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedPaymentMethod.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please select a payment method")),
                    );
                    return;
                  }
                  if (selectedPaymentMethod == 'Credit Card') {
                    if (cardController.text.isEmpty ||
                        nameController.text.isEmpty ||
                        expiryController.text.isEmpty ||
                        cvvController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please fill in all card fields")),
                      );
                      return;
                    }
                  }

                  // Close Payment Dialog
                  Navigator.pop(context);

                  // Complete Payment
                  widget.onPaymentComplete(cart);
                  setState(() {
                    cart.clear();
                  });
                  _saveCartItems();

                  // Show Success Dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: Colors.white,
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Color.fromARGB(255, 30, 120, 40), size: 80),
                            SizedBox(height: 20),
                            Text(
                              "Purchase Successful!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 30, 80, 35),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Thank you for your order.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        actions: [
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "OK",
                                style: TextStyle(color: Color.fromARGB(255, 25, 65, 30)),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 22, 58, 24),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  "Confirm Order",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _buildPaymentOption({
  required String title,
  required IconData icon,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: isSelected ? const Color.fromARGB(255, 25, 66, 32) : Colors.grey),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? const Color.fromARGB(255, 217, 228, 217) : Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: isSelected ? const Color.fromARGB(255, 40, 97, 42) : Colors.black54),
          SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color.fromARGB(255, 25, 65, 26) : Colors.black,
            ),
          ),
        ],
      ),
    ),
  );
}





///////////////////////////////////////////////////////////////////////////////////////////////////

  Widget buildCartItem(String item) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            // child: Image.network(
            //   productImages[item] ?? '',
            //   width: 60,
            //   height: 60,
            //   fit: BoxFit.cover,
            //   errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported),
            // ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                SizedBox(height: 4),
                Text('\$${productPrices[item]?.toStringAsFixed(2) ?? "N/A"}', style: TextStyle(letterSpacing: 1.2)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () => decreaseQty(item),
              ),
              Text('${productQuantities[item] ?? 1}', style: TextStyle(letterSpacing: 1.2)),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => increaseQty(item),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => removeItem(item),
          )
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 20 : 18, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, letterSpacing: 1.2)),
        Text('\$${value.toStringAsFixed(2)}', style: TextStyle(fontSize: isTotal ? 20 : 18, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, letterSpacing: 1.2)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 242, 242), // تغيير لون خلفية الـ body إلى الأبيض
         appBar: PreferredSize(
        preferredSize: Size.fromHeight(85),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.white,
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: const Text(
                'AddCart',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Color.fromARGB(255, 238, 241, 240),
                  shadows: [
                    Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black)
                  ],
                ),
              ),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 15, 77, 48),
                    Color.fromARGB(255, 5, 14, 8),
                  ],
                  stops: [0.3, 6.0],
                  end: Alignment.topLeft,
                  begin: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: cart.map((item) => buildCartItem(item)).toList(),
              ),
            ),
            Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPriceRow("Subtotal", subtotal),
                _buildPriceRow("Tax (3.2%)", tax),
                _buildPriceRow("Delivery", delivery),
                SizedBox(height: 25),
                _buildPriceRow("Total", total, isTotal: true),
                SizedBox(height: 40),
                Align(
                  alignment: Alignment.center, // لتوسيط الزر
                  child: ElevatedButton(
                    onPressed: _showPaymentDialog,
                    child: Text(
                      'Proceed to Payment',
                      style: TextStyle(
                        color: Colors.white, // تغيير لون النص داخل الزر
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 23, 58, 25),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 60),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////




class SellProductPage extends StatefulWidget {
  final Function onProductAdded;

  SellProductPage({required this.onProductAdded});

  @override
  _SellProductPageState createState() => _SellProductPageState();
}

class _SellProductPageState extends State<SellProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    String name = nameController.text;
    String price = priceController.text;
    String quantity = quantityController.text;

    if (name.isEmpty || price.isEmpty || quantity.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, String>> products = [];

    String? productsData = prefs.getString('products');
    if (productsData != null) {
      List<dynamic> decoded = json.decode(productsData);
      products = decoded.map((e) => Map<String, String>.from(e)).toList();
    }

    Map<String, String> newProduct = {
      'name': name,
      'price': price,
      'quantity': quantity,
      'imagePath': _image!.path,
      'seller': FirebaseAuth.instance.currentUser?.email ?? 'Anonymous'
    };

    products.add(newProduct);
    await prefs.setString('products', json.encode(products));

    widget.onProductAdded();
    Navigator.pop(context);
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // رمادي فاتح
        appBar: PreferredSize(
        preferredSize: Size.fromHeight(85),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.white,
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: const Text(
                'Selling',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Color.fromARGB(255, 238, 241, 240),
                  shadows: [
                    Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black)
                  ],
                ),
              ),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 15, 77, 48),
                    Color.fromARGB(255, 5, 14, 8),
                  ],
                  stops: [0.3, 6.0],
                  end: Alignment.topLeft,
                  begin: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField("Product Name", nameController),
            _buildTextField("Price", priceController, keyboardType: TextInputType.number),
            _buildTextField("Quantity", quantityController, keyboardType: TextInputType.number),

            SizedBox(height: 12),
            _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_image!, height: 160, fit: BoxFit.cover),
                  )
                : OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.image_outlined),
                    label: Text("Select Image"),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 19, 46, 20),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Submit Product", style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}