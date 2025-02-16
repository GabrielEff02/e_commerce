import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:barcode/barcode.dart';
import 'package:e_commerce/api/api.dart';
import 'package:e_commerce/api/notification_api.dart';
import 'package:e_commerce/constant/text_constant.dart';
import 'package:e_commerce/screen/auth/splash_screen.dart';
import 'package:e_commerce/screen/gabriel/notifications/item_screen.dart';
import 'package:e_commerce/screen/gabriel/notifications/notification_screen.dart';
import 'package:e_commerce/screen/gabriel/request_item/request_item_screen/request_item_screen.dart';
import 'package:e_commerce/utils/local_data.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../NavBar.dart';

import '../../../controller/landing_controller.dart';
import '../../../screen/gabriel/checkouts/main_checkouts.dart';
import '../../../screen/gabriel/core/app_export.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  final LandingScreenController controller = Get.put(LandingScreenController());

  static List<dynamic> productData = [];

  Map<String, dynamic> categoryData = {};
  late AnimationController _controller;
  late Animation<double> _swingAnimation;

  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _swingAnimation = Tween<double>(begin: -0.3, end: 0.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );

    if (SplashScreen.notificationData['count'] != null &&
        SplashScreen.notificationData['count'] > 0) {
      _controller.repeat(reverse: true);
    }

    getCategoryData();
    getProductData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> getCategoryData() async {
    await SplashScreen.getSplashData();

    final fetchData = await LandingScreenData.getCategoryData();
    setState(() {
      categoryData.addAll(<String, dynamic>{'All': 'All'});

      categoryData.addEntries(fetchData.entries);
      controller.categoryData.value = fetchData;
    });
  }

  Future<void> getProductData() async {
    final fetchData = await CheckoutsData.getInitData("all");

    fetchData['productData'].shuffle(Random());
    setState(() {
      productData = fetchData['productData'].take(10).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Center(
            child: Text(
              "Simply Yours",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(NotificationScreen());
            },
            icon: SplashScreen.notificationData['count'] != null &&
                    SplashScreen.notificationData['count'] > 0
                ? Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _swingAnimation.value, // Swing effect
                            child: child,
                          );
                        },
                        child: Icon(
                          Icons.notifications,
                          color: const Color(0xFF0095FF),
                          size: 35.0,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 20.0,
                            minHeight: 20.0,
                          ),
                          child: Center(
                            child: Text(
                              SplashScreen.notificationData['count'].toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Icon(
                    Icons.notifications,
                    color: const Color.fromARGB(255, 78, 175, 245),
                    size: 35.0,
                  ), // Jika tidak ada notifikasi, ikon biasa
          )
        ],
      ),
      // drawer: NavBar(),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: [
                  Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 12.v, horizontal: 20.h),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<Uint8List>(
                              future: LocalData.getProfilePicture(
                                  "profile_picture"),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return const Icon(Icons.error);
                                } else if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return const Icon(
                                      Icons.error); // If no image data
                                }

                                return ClipOval(
                                  child: Image.memory(
                                    snapshot.data!,
                                    width: 80.0,
                                    height: 80.0,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder(
                                      future: LocalData.getData('user'),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data.toString(),
                                          style: TextConstant.medium.copyWith(
                                            color: Colors.black87,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 5),
                                    FutureBuilder(
                                      future: LocalData.getData('email'),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data.toString(),
                                          style: TextConstant.medium.copyWith(
                                            color: Colors.black87,
                                            fontSize: 13,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 2),
                                    FutureBuilder(
                                      future: LocalData.getData('phone'),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data.toString(),
                                          style: TextConstant.medium.copyWith(
                                            color: Colors.black87,
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 2),
                                    FutureBuilder(
                                      future: LocalData.getData('phone'),
                                      builder: (context, snapshot) {
                                        return Text(
                                          "{Nomor Member}",
                                          style: TextConstant.medium.copyWith(
                                            color: Colors.black87,
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FutureBuilder(
                              future: Future.wait([
                                LocalData.getData('point'),
                                LocalData.getData('balance'),
                              ]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator(); // Loading indicator
                                } else if (snapshot.hasError) {
                                  return Text(
                                      "Error: ${snapshot.error}"); // Tangani error dengan aman
                                } else if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return Text("No data available");
                                }

                                var point = snapshot.data![0];
                                var balance = snapshot.data![1];
                                return Expanded(
                                    child: itemMenu(
                                        point: true, value: [point, balance]));
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => _showBarcodePopup(context, false),
                              child: itemMenu(
                                title: "Barcode",
                                icon: FontAwesomeIcons.barcode,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showBarcodePopup(context, true),
                              child: itemMenu(
                                  title: "QR Code", icon: Icons.qr_code_2),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.v),
                  CarouselWidget(),
                  categoryData.isNotEmpty
                      ? categoryColumn(categoryData)
                      : Container(),
                  Column(
                    children: productRow(productData),
                  ),
                  SizedBox(height: 80.v)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryColumn(Map<String, dynamic> categoryData) {
    List<Widget> rows = [];

    List<String> categories = categoryData.keys.toList();

    for (int i = 0; i < categories.length; i += 4) {
      List<String> rowCategories = categories.sublist(
        i,
        (i + 4 > categories.length) ? categories.length : i + 4,
      );
      rows.add(categoryRow(rowCategories, categoryData,
          lastItem: i + 4 > categories.length));
      // rows.add()
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: rows,
      ),
    );
  }

  Widget itemMenu(
      {String? title,
      IconData? icon,
      bool point = false,
      List<String>? value}) {
    final decoration = point
        ? BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFF8E2C8).withValues(alpha: 100),
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
          )
        : BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFFF6F61), Color(0xFFFFB74D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                spreadRadius: 1,
                offset: Offset(0, 4),
              ),
            ],
          );
    return Container(
      decoration: decoration,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.only(bottom: 10),
      child: point
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Current Points",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      value![0].isEmpty ? '0' : value[0],
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(width: 2, height: 50, color: Colors.grey),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Gatzu Balance",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      value[1].isEmpty ? '0' : value[1],
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Icon(icon, color: Colors.black87),
                SizedBox(width: 15),
                Text(
                  title!,
                  style: TextConstant.medium.copyWith(
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
    );
  }

  void _showBarcodePopup(BuildContext context, bool isQRCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: LocalData.getData('phone'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Icon(Icons.error));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Icon(Icons.error)); // If no data
            }

            final code = isQRCode
                ? Barcode.qrCode().toSvg(snapshot.data.toString())
                : Barcode.code39().toSvg(snapshot.data.toString());

            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 1.0, end: 1.1),
              duration: const Duration(milliseconds: 500),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Dialog(
                    child: Container(
                      height: 400,
                      decoration: const BoxDecoration(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: SvgPicture.string(code,
                                  height: isQRCode ? 200 : 250,
                                  width: isQRCode ? 200 : 200,
                                  fit:
                                      isQRCode ? BoxFit.cover : BoxFit.contain),
                            ),
                            const SizedBox(height: 10),
                            if (isQRCode) // Display text only for QR Code
                              Text(
                                snapshot.data.toString(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  List<Widget> productRow(List productData) {
    List<Widget> rows = [];

    for (int i = 0; i < productData.length; i += 2) {
      rows.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildProductCard(context, productData[i]),
              ),
              if (i + 1 < productData.length) SizedBox(width: 16),
              if (i + 1 < productData.length)
                Expanded(
                  child: _buildProductCard(context, productData[i + 1]),
                )
              else
                SizedBox(width: 16),
            ],
          ),
        ),
      );
    }

    return rows;
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(ItemScreen(data: product.map((key, value) {
                return MapEntry(key, value.toString());
              })));
            },
            child: CustomImageView(
              imagePath: "${API.BASE_URL}/images/${product['image_url']}",
              height: 150, // Adjust image height as needed
              width: double.infinity,
              alignment: Alignment.center,
            ),
          ),
          SizedBox(height: 12), // Space between image and text
          Text(
            maxLines: 2,
            product['product_name'], // Product name
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18, // Increase font size
              color: Colors.black87, // Darker text color
            ),
          ),
          SizedBox(height: 4), // Space between name and price
          Text(
            'Price: \$${product['price']}', // Product price
            style: TextStyle(
              fontSize: 16, // Font size for price
              color: Colors.green, // Green color for price
            ),
          ),
          SizedBox(height: 4), // Space between price and quantity
          Text(
            'Quantity: ${product['quantity']}', // Product quantity
            style: TextStyle(
              fontSize: 14, // Font size for quantity
              color: Colors.grey[600], // Grey color for quantity
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryRow(List<String> categories, Map<String, dynamic> categoryData,
      {Icon? icon, bool? lastItem}) {
    // Your existing categoryRow code
    List<Widget> categoryWidgets = categories.map((category) {
      return categoryImage(categoryData[category], category);
    }).toList();
    if (lastItem == true) {
      categoryWidgets.add(
        InkWell(
          onTap: () => Get.to(() => RequestedItemScreen()),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appTheme.gray200,
                ),
                child: Icon(Icons.request_page),
              ),
              Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Text("Request"))
            ],
          ),
        ),
      );
    }
    while (categoryWidgets.length < 4) {
      categoryWidgets
          .add(Container(width: 50)); // Empty container for alignment
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categoryWidgets,
    );
  }

  Widget categoryImage(String base64Image, String category) {
    return InkWell(
      onTap: () {
        (category != 'All')
            ? mainCheckouts(filterCategory: category.split(' ').last)
            : mainCheckouts();
      },
      child: Column(
        children: [
          (category != 'All')
              ? Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          MemoryImage(base64Decode(base64Image.split(',')[1])),
                    ),
                    shape: BoxShape.circle,
                    color: appTheme.gray200,
                  ),
                )
              : Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: appTheme.gray200,
                  ),
                  child: Icon(
                    Icons.format_list_bulleted,
                  ),
                ),
          Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Text(category.split(' ').first))
        ],
      ),
    );
  }
}
