import 'package:e_commerce/screen/gabriel/core/app_export.dart';
import 'package:get/get.dart';

import '../../../../../utils/local_data.dart';
import '../../../../../api/api.dart';
import '../../../../../constant/dialog_constant.dart';

class ShoppingCartController {
  Future<void> postTransactions(
      {BuildContext? context,
      void callback(result, exception)?,
      Map<String, dynamic>? postTransaction,
      List<dynamic>? postTransactionDetail}) async {
    var header = <String, String>{};

    header['Content-Type'] = 'application/json';
    String username = await LocalData.getData("user");
    postTransaction!['username'] = username;
    postTransaction['address_id'] =
        int.parse(await LocalData.getData("address"));
    DialogConstant.loading(context!, 'Transaction on Process...');

    API.basePost('/update_transaction.php', postTransaction, header, true,
        (result, error) {
      for (dynamic transaction in postTransactionDetail!) {
        final postDetail = {
          'username': username,
          'product_id': transaction['product_id'],
          'quantity': transaction['quantity_selected'],
          'total_price':
              transaction['price'] * transaction['quantity_selected'],
        };
        API.basePost('/update_transaction_detail.php', postDetail, header, true,
            (result, error) async {
          if (error != null) {
            callback!(null, error);
          } else {
            LocalData.saveData('point',
                '${int.parse(await LocalData.getData('point')) - (transaction['price'] * transaction['quantity_selected'])}');
          }
        });
      }
      Future.delayed(Duration(seconds: 4), () {
        Get.back();
        Navigator.pushNamed(
          context,
          AppRoutes.checkoutsSplashScreen,
        );
        if (error != null) {
          callback!(null, error);
        }
        if (result != null) {
          callback!(result, null);
        }
      });
    });
  }
}
