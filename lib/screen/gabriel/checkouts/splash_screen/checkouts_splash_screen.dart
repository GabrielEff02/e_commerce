import 'package:e_commerce/api/api.dart';
import 'package:e_commerce/screen/auth/splash_screen.dart';

import '../../checkouts/main_checkouts.dart';

import '../../core/app_export.dart';

class CheckoutsSplashScreen extends StatelessWidget {
  const CheckoutsSplashScreen({Key? key}) : super(key: key);
  static Map<String, dynamic> profileData = {};
  static List<dynamic> productData = [];

  static void getData(BuildContext context) async {
    profileData =
        await CheckoutsData.getInitData(MainCheckoutsApp.filterCategory);
    Future.delayed(const Duration(seconds: 1), () {
      if (profileData.isNotEmpty) {
        productData = profileData['productData'];
        profileData = profileData['profileData'][0];
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.showItemsScreen);
        } else {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.notFoundScreen,
            arguments: AppRoutes
                .checkoutsSplashScreen, // Pass the route as an argument
          );
        }
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.notFoundScreen,
          arguments: AppRoutes.initialRoute, // Pass the route as an argument
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    getData(context);
    // Navigate to the SecondSplash screen after a delay

    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image:
                  NetworkImage("${API.BASE_URL}/images/${SplashScreen.path1}"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
