import 'package:e_commerce/screen/ocr_ktp/view/home.dart';
import 'package:e_commerce/screen/gabriel/checkouts/shopping_cart_screen/shopping_cart_screen.dart';
import 'package:e_commerce/screen/gabriel/checkouts/splash_screen/checkouts_splash_screen.dart';
import 'package:e_commerce/screen/gabriel/request_item/request_item_screen/request_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screen/gabriel/checkouts/main_checkouts.dart';

class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Foxie'),
            accountEmail: Text('foxie123@gmail.com'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  'https://img.freepik.com/premium-photo/fox-wallpapers-hd-iphone-android_881308-133.jpg',
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                      'https://t4.ftcdn.net/jpg/06/54/18/11/360_F_654181147_c5rztTDZh7aGSFF9w8A9LUJQw2kVCz4b.jpg')),
            ),
          ),

          // ListTile(
          //   leading: Icon(Icons.person),
          //   title: Text('Friends'),
          //   onTap: () => null,
          // ),

          // ListTile(
          //   leading: Icon(Icons.notifications),
          //   title: Text('Request'),
          //   onTap: () => null,
          //   trailing: ClipOval(
          //     child: Container(
          //       color: Colors.red,
          //       width: 20,
          //       height: 20,
          //       child: Center(
          //         child: Text(
          //           '8',
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 12,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Checkouts Cart'),
            // onTap: () => Get.to(() => CheckoutsSplashScreen()),
            onTap: () => mainCheckouts(),
          ),
          ListTile(
            leading: Icon(Icons.request_page),
            title: Text('Request Item'),
            onTap: () => Get.to(() => RequestedItemScreen()),
          ),
          ListTile(
            leading: Icon(Icons.card_membership_outlined),
            title: Text('KTP OCR'),
            onTap: () => Get.to(() => KtpOCR()),
          ),

          Divider(),
        ],
      ),
    );
  }
}
