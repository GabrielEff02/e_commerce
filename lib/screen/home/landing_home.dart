import 'package:e_commerce/api/notification_api.dart';
import 'package:e_commerce/screen/gabriel/notifications/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/screen/home/view/landing_screen.dart';
import 'package:e_commerce/screen/home/view/profile_screen.dart';
import 'package:e_commerce/screen/home/view/wheel_fortune.dart';
import 'package:e_commerce/widget/material/button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LandingHome extends StatefulWidget {
  const LandingHome({Key? key}) : super(key: key);

  @override
  State<LandingHome> createState() => _LandingHomeState();
}

class _LandingHomeState extends State<LandingHome> {
  PageController controllers = PageController();

  // Button state
  bool buttonPressed1 = true;
  bool buttonPressed2 = false;
  bool buttonPressed3 = false;

  @override
  void dispose() {
    controllers.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (NotificationApi.notificationId != 0) {
      Get.to(NotificationScreen());
    }
  }

  void _navigateToPage(int pageIndex) {
    setState(() {
      buttonPressed1 = pageIndex == 0;
      buttonPressed2 = pageIndex == 1;
      buttonPressed3 = pageIndex == 2;
    });
    // Menggunakan animateToPage dengan durasi dan curve untuk transisi yang lebih smooth
    controllers.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 500), // Durasi transisi
      curve: Curves.easeInOut, // Efek curve untuk transisi halus
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView
          PageView(
            controller: controllers,
            physics: BouncingScrollPhysics(),
            children: const <Widget>[
              LandingScreen(),
              SpiningWheel(),
              ProfileScreen(),
            ],
            onPageChanged: (val) {
              setState(() {
                buttonPressed1 = val == 0;
                buttonPressed2 = val == 1;
                buttonPressed3 = val == 2;
              });
            },
          ),
          // Neumorphic buttons for navigation
          Positioned(
            bottom: 10,
            left: 50,
            right: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        _navigateToPage(0), // Navigate to LandingScreen
                    child: buttonPressed1
                        ? ButtonTapped(
                            icon: Icons.home,
                            color: Colors.amber,
                          )
                        : MyButton(
                            icon: Icons.home,
                            color: Colors.amber,
                          ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        _navigateToPage(1), // Navigate to SpinningWheel
                    child: buttonPressed2
                        ? ButtonTapped(
                            icon: FontAwesomeIcons.bullseye, color: Colors.blue)
                        : MyButton(
                            icon: FontAwesomeIcons.bullseye,
                            color: Colors.blue),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        _navigateToPage(2), // Navigate to ProfileScreen
                    child: buttonPressed3
                        ? ButtonTapped(
                            icon: Icons.account_circle, color: Colors.red)
                        : MyButton(
                            icon: Icons.account_circle, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
