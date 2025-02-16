import 'package:e_commerce/api/api.dart';

import '../../checkouts/shopping_cart_screen/shopping_cart_controller/shopping_cart_controller.dart';
import '../../../../constant/dialog_constant.dart';
import '../../checkouts/splash_screen/checkouts_splash_screen.dart';
import '../../core/app_export.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({Key? key, required this.items}) : super(key: key);

  final List<dynamic> items;

  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  late num totalQuantityFinal = 0;
  late num totalPriceFinal = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Shopping Cart",
          style: CustomTextStyle.titleLargeBlack900,
        ),
        actions: [
          IconButton(
              onPressed: () {
                showAreYouSureDialog(context, () => submitItems(widget.items));
              },
              icon: Icon(
                Icons.check,
                weight: 20.adaptSize,
                color: appTheme.green700,
              ))
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.v, vertical: 10.v),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: appTheme.gray30099,
                  borderRadius: BorderRadius.all(Radius.circular(10.h)),
                ),
                child: FutureBuilder<Widget>(
                  future: widget.items.isNotEmpty
                      ? _showProductCards(context, widget.items)
                      : Future.value(Container()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData) {
                      return Container();
                    }
                    return snapshot.data!;
                  },
                ),
              ),
            ),
            _buildStickyBottomSection(context),
          ],
        ),
      ),
    );
  }

  void submitItems(items) {
    if (items.toString().isNotEmpty) {
      Map<String, dynamic> postTransaction = {
        'total_amount': items[0]["total price"]
      };
      ShoppingCartController().postTransactions(
          context: context,
          callback: (result, error) {
            if (result != null && result['error'] != true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color.fromARGB(88, 0, 0, 0),
                  content: Row(
                    children: [
                      Icon(
                        Icons.check,
                        color: Colors.red,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Transaction Success!!!',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              DialogConstant.alertError(error.toString());
            }
            ;
          },
          postTransaction: postTransaction,
          postTransactionDetail: items);
    }
  }

  Widget _buildStickyBottomSection(BuildContext context) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Price:',
                    style: CustomTextStyle.titleMediumBlack900),
                Text(currencyFormatter.format(totalPriceFinal),
                    style: CustomTextStyle.titleMediumRed700)
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Balance:', style: CustomTextStyle.titleMediumBlack900),
                Text(
                  currencyFormatter
                      .format(CheckoutsSplashScreen.profileData['point']),
                  style: CustomTextStyle.titleMediumBlack900,
                ),
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Remain Balance:',
                        style: CustomTextStyle.titleMediumBlack900),
                    Text(
                      currencyFormatter.format(
                          CheckoutsSplashScreen.profileData['point'] -
                              totalPriceFinal),
                      style: CustomTextStyle.titleMediumGreen700,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.adaptSize,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Quantity:',
                        style: CustomTextStyle.lableLargeBlack900500),
                    Text(
                      currencyFormatter.format(totalQuantityFinal),
                      style: CustomTextStyle.lableLargeGreen700500,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<Widget> _showProductCards(
      BuildContext context, List<dynamic> items) async {
    totalQuantityFinal = 0;
    totalPriceFinal = 0;
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    items.sort((a, b) => a['product_id'].compareTo(b['product_id']));
    List<Map<String, dynamic>> filteredItems = items
        .where((item) =>
            item['quantity_selected'] > 0) // Filter where quantity > 0
        .map((item) {
      return {
        'image': "${API.BASE_URL}/images/${item['image_url']}",
        'product': item['product_name'],
        'product description': item['product_description'],
        'quantity': item['quantity_selected'],
        'price': item['price'],
        'total price': item['price'] * item['quantity_selected']
      };
    }).toList();

    if (filteredItems.isNotEmpty) {
      List<Widget> cards = filteredItems.map((product) {
        setState(() {
          // Update total quantities and prices in setState
          totalQuantityFinal += product['quantity'];
          totalPriceFinal += product['total price'];
        });

        // Return product card widget
        return _cardProductWidget(product, currencyFormatter);
      }).toList();

      // Return ListView with the cards as children
      return ListView(children: cards);
    } else {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.notFoundScreen,
        arguments: AppRoutes.shoppingCartScreen,
      );
      return Container();
    }
  }

  Widget _cardProductWidget(
      Map<String, dynamic> product, NumberFormat currencyFormatter) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.network(
              product['image'],
              width: 50,
              height: 50,
            ),
            SizedBox(width: 5.adaptSize),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      product['product'],
                      style: CustomTextStyle.titleSmallBlack900,
                    ),
                  ),
                  SizedBox(height: 3.adaptSize),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "\tprice: ${product['price']}",
                      style: CustomTextStyle.bodySmallBlack900,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "\tqty: ${product['quantity'].toString()}",
                      style: CustomTextStyle.bodySmallBlack900,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 5.adaptSize),
            Text(
              currencyFormatter.format(product['total price']),
              style: CustomTextStyle.titleMediumBlack900,
            ),
          ],
        ),
      ),
    );
  }

  void showAreYouSureDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text("Are you sure?"),
            ],
          ),
          content: Text("Are you sure you want to proceed with this action?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onConfirm(); // Call the confirmation action
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 70, 242, 216)),
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
