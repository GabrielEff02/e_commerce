import 'package:e_commerce/screen/home/landing_home.dart';
import 'package:e_commerce/screen/home/view/landing_screen.dart';
import 'package:e_commerce/utils/local_data.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/app_export.dart';
import 'widgets/list1_item_widget.dart';
import '../splash_screen/checkouts_splash_screen.dart';

class ShowItemsScreen extends StatefulWidget {
  const ShowItemsScreen({Key? key}) : super(key: key);

  @override
  _ShowItemsScreenState createState() => _ShowItemsScreenState();
}

class _ShowItemsScreenState extends State<ShowItemsScreen> {
  String name = '';
  bool _isAscending = true;
  List<dynamic> selectedItems = [];
  int totalPrice = 0;
  @override
  void initState() {
    super.initState();
    getFullName();
  }

  Future<void> getFullName() async {
    final names = await LocalData.getData("full_name");
    setState(() {
      name = names;
    });
  }

  void _sortData() {
    CheckoutsSplashScreen.productData.sort((a, b) {
      double priceA = double.parse(a["price"].toString());
      double priceB = double.parse(b["price"].toString());
      return _isAscending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });
  }

  void _onQuantityChanged(dynamic updatedData) {
    setState(() {
      if (updatedData['quantity'] > 0) {
        final existingIndex =
            selectedItems.indexWhere((item) => item == updatedData);
        if (existingIndex != -1) {
          selectedItems[existingIndex] = updatedData;
        } else {
          selectedItems.add(updatedData);
        }
      } else {
        selectedItems.removeWhere((item) => item == updatedData);
      }

      totalPrice = 0;
      for (var item in selectedItems) {
        totalPrice +=
            (item['price'] as int) * (item['quantity_selected'] as int);
      }
      if (totalPrice > 0) {
        selectedItems[0]['total price'] = totalPrice;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: appTheme.whiteA700,
      appBar: WidgetHelper.appbarWidget(
        () {
          Get.offAll(LandingHome());
        },
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Hello $name!!!", style: CustomTextStyle.titleSmallBlack900),
          Text(
            'Points: ${currencyFormatter.format(CheckoutsSplashScreen.profileData['point'])}',
            style: CustomTextStyle.titleSmallBlack900,
          )
        ]),
        actions: [
          IconButton(
            icon: Icon(
              _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: appTheme.blueGray800,
            ),
            onPressed: () {
              setState(() {
                _isAscending = !_isAscending; // Toggle sorting
                _sortData(); // Panggil fungsi sorting
              });
            },
          ),
        ],
      ),
      body: Scrollbar(
        interactive: true,
        thickness: 7.v,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: EdgeInsets.only(bottom: totalPrice > 0 ? 75.adaptSize : 0),
            child: salesReport(context),
          ),
        ),
      ),
      bottomSheet: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        height: totalPrice > 0 ? 75.adaptSize : 0,
        child: totalPrice > 0
            ? Padding(
                padding: EdgeInsets.all(10.adaptSize),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15.h),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Total Price: ",
                              style: CustomTextStyle.bodyMediumBlueGray600,
                            ),
                            TextSpan(
                              text: currencyFormatter.format(totalPrice),
                              style:
                                  CheckoutsSplashScreen.profileData['point'] <
                                          totalPrice
                                      ? CustomTextStyle.bodyLargeRed700
                                      : CustomTextStyle.bodyLargeGreen700,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (CheckoutsSplashScreen.profileData['point'] >=
                        totalPrice)
                      Padding(
                        padding: EdgeInsets.only(right: 15.h),
                        child: IconButton(
                          icon: Icon(
                            Icons.shopping_cart,
                            color: appTheme.black900,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.shoppingCartScreen,
                              arguments: selectedItems,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Widget salesReport(BuildContext context) {
    bool color = true;
    return Column(
      children: [
        for (var widget in CheckoutsSplashScreen.productData)
          List1ItemWidget(
              key: ValueKey(widget['product_id']),
              data: widget,
              color: color = !color,
              onQuantityChanged: _onQuantityChanged),
      ],
    );
  }
}

void showExitConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Exit'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Get.to(LandingScreen());
            },
            child: const Text('Exit'),
          ),
        ],
      );
    },
  );
}
