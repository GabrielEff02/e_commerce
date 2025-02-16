import 'dart:convert';

import 'package:e_commerce/api/notification_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../api/api.dart';
import '../constant/dialog_constant.dart';
import '../utils/local_data.dart';

class AuthController extends GetxController {
  RxBool openPassLogin = true.obs;
  RxBool openPassOTP1 = true.obs;
  RxBool openPassOTP2 = true.obs;

  // RxString userName = "".obs;
  TextEditingController edtNama = TextEditingController();
  TextEditingController edtEmail = TextEditingController();
  TextEditingController edtUsername = TextEditingController();
  TextEditingController edtPass = TextEditingController();
  TextEditingController edtPhone = TextEditingController();
  TextEditingController edtConfirmPass = TextEditingController();
  TextEditingController changePass = TextEditingController();
  TextEditingController verifyCode = TextEditingController();
  TextEditingController otpCode = TextEditingController();

  List maskEmail = [];

  changeOpenPassLogin(bool val) {
    openPassLogin.value = val;
  }

  viewPassOTP(int tipe, bool val) {
    tipe == 1 ? openPassOTP1.value = val : openPassOTP2.value = val;
  }

  validation({BuildContext? context, void callback(result, exception)?}) {
    if (edtPhone.text == '') {
      DialogConstant.alertError('Nomor Telephone tidak boleh kosong!');
    } else if (edtPass.text == '') {
      DialogConstant.alertError('Password tidak boleh kosong!');
    } else {
      postLogin(
          context: context,
          callback: (result, error) => callback!(result, error));
    }
  }

  postLogin({BuildContext? context, void callback(result, exception)?}) {
    DialogConstant.loading(context!, 'Loading...');

    var post = Map<String, dynamic>();
    var header = Map<String, String>();

    header['Content-Type'] = 'application/json';
    post['phone'] = edtPhone.text;
    post['password'] = edtPass.text;
    post['fcmToken'] = NotificationApi.fCMToken;

    bool isCompleted =
        false; // Flag untuk melacak apakah respons sudah diterima
    Future.delayed(Duration(seconds: 20), () {
      if (!isCompleted) {
        isCompleted = true;
        Get.back();
        callback!(null, 'Request timed out');
      }
    });
    API.basePost('/login.php', post, header, true, (result, error) {
      if (!isCompleted) {
        isCompleted = true;

        if (result != null) {
          Future.delayed(Duration(seconds: 3), () {
            print(result);
            if (result['error'] == true) {
              Get.back();

              callback!(null, result['message']);
              return;
            }
            List dataUser = result['data'];
            if (dataUser.length > 1) {
              LocalData.saveData('detailKTP', jsonEncode(dataUser[1]));
            }
            LocalData.saveData('user', dataUser[0]['username'] ?? "");
            LocalData.saveData('loginDate', DateTime.now().toString());
            LocalData.saveData('password', post['password'] ?? "");
            LocalData.saveData('email', dataUser[0]['email'] ?? "");
            LocalData.saveData('address', dataUser[0]['default_address'] ?? "");
            LocalData.saveData('phone', dataUser[0]['phone'] ?? "");
            LocalData.saveData('point', dataUser[0]['point'] ?? "");
            LocalData.saveData('chance', dataUser[0]['spin_chance'] ?? "");
            LocalData.saveData(
                'profile_picture', dataUser[0]['profile_picture'] ?? "");
            LocalData.saveData('full_name',
                "${dataUser[0]['first_name']} ${dataUser[0]['last_name'] ?? ""}");

            if (dataUser[0]['email'].contains('@')) {
              List<String> maskEmail = dataUser[0]['email'].split('@');
              if (maskEmail[0].length > 5) {
                maskEmail[0] =
                    maskEmail[0].substring(0, maskEmail[0].length - 5) +
                        "*****";
              } else {
                maskEmail[0] = "*****";
              }
              LocalData.saveData(
                  'maskEmail', maskEmail[0] + '@' + maskEmail[1]);
            } else {
              LocalData.saveData('maskEmail', "*****@****");
              print('Invalid email format');
            }

            callback!(result, null);
          });
        }
      }
    });
  }

  validationRegister(
      {BuildContext? context, void callback(result, exception)?}) {
    if (edtNama.text == '') {
      Get.back();

      DialogConstant.alertError('Nama tidak boleh kosong!');
    } else if (edtEmail.text == '') {
      Get.back();

      DialogConstant.alertError('Email tidak boleh kosong!');
    } else if (edtUsername.text == '') {
      Get.back();
      DialogConstant.alertError('Username tidak boleh kosong!');
    } else if (edtPass.text == '') {
      Get.back();
      DialogConstant.alertError('Password tidak boleh kosong!');
    } else if (edtConfirmPass.text == '') {
      Get.back();
      DialogConstant.alertError('Konfirmasi Password tidak boleh kosong!');
    } else if (edtPass.text != edtConfirmPass.text) {
      Get.back();
      DialogConstant.alertError('Password dan Konfirmasi Password tidak sama!');
    } else {
      postRegister(
          context: context,
          callback: (result, error) {
            callback!(result, error);
          });
    }
  }

  postRegister({BuildContext? context, void callback(result, exception)?}) {
    var post = new Map<String, dynamic>();
    var header = new Map<String, String>();

    header['Content-Type'] = 'application/json';
    post['first_name'] = edtNama.text;
    post['email'] = edtEmail.text;
    post['username'] = edtUsername.text;
    post['password'] = edtPass.text;
    post['phone'] = edtPhone.text;

    DialogConstant.loading(context!, 'Loading...');

    API.basePost('/register.php', post, header, true, (result, error) {
      Get.back();
      if (error != null) {
        callback!(null, error);
      }
      if (result != null) {
        callback!(result, null);
      }
    });
  }

  validationVerify({BuildContext? context, void callback(result, exception)?}) {
    if (verifyCode.text == '') {
      Get.back();
      DialogConstant.alertError('Kode verifikasi kosong!');
    } else {
      postVerifyWhatsapp(
          context: context,
          callback: (result, error) => callback!(result, error));
    }
  }

  sendVerifyCode(
      {BuildContext? context,
      void callback(result, exception)?,
      Map<String, dynamic>? post}) async {
    var header = new Map<String, String>();
    var post = Map<String, dynamic>();
    header['Content-Type'] = 'application/json';
    post['userx'] = await LocalData.getData('user');

    DialogConstant.loading(context!, 'Mengirim kode Verifikasi...');

    API.basePost('/auth-sms.php', post, header, true, (result, error) {
      Get.back();
      if (error != null) {
        callback!(null, error);
      }
      if (result != null) {
        callback!(result, null);
      }
    });
  }

  postVerifyWhatsapp(
      {BuildContext? context, void callback(result, exception)?}) async {
    var post = new Map<String, dynamic>();
    var header = new Map<String, String>();

    header['Content-Type'] = 'application/json';
    post['userx'] = await LocalData.getData('user');
    post['codex'] = verifyCode.text;

    DialogConstant.loading(context!, 'Check Verification...');

    API.basePost('/get-verify-sms.php', post, header, true, (result, error) {
      Get.back();
      if (error != null) {
        callback!(null, error);
      }
      if (result != null) {
        callback!(result, null);
      }
    });
  }

  sendOtpSMS({BuildContext? context, void callback(result, exception)?}) async {
    var post = new Map<String, dynamic>();
    var header = new Map<String, String>();

    header['Content-Type'] = 'application/json';
    post['phonex'] = await LocalData.getData('phone');

    DialogConstant.loading(context!, 'Sending OTP...');

    API.basePost('/auth-sms.php', post, header, true, (result, error) {
      Get.back();
      print(result);
      print(error);
      if (error != null) {
        callback!(null, error);
      }
      if (result != null) {
        callback!(result, null);
      }
    });
  }

  validationOtp({BuildContext? context, void callback(result, exception)?}) {
    if (otpCode.text == '') {
      Get.back();
      DialogConstant.alertError('Kode OTP kosong!');
    } else if (changePass.text == '') {
      Get.back();
      DialogConstant.alertError('Password baru tidak boleh kosong!');
    } else {
      postOtpCode(
          context: context,
          callback: (result, error) => callback!(result, error));
    }
  }

  postOtpCode(
      {BuildContext? context, void callback(result, exception)?}) async {
    var post = new Map<String, dynamic>();
    var header = new Map<String, String>();

    header['Content-Type'] = 'application/json';
    if (await LocalData.containsKey('user')) {
      post['userx'] = await LocalData.getData('user');
    } else {
      post['phonex'] = await LocalData.getData('phone');
    }
    post['newpass'] = changePass.text;
    post['codex'] = otpCode.text;

    DialogConstant.loading(context!, 'Verifying OTP..');

    API.basePost('/get-verify-sms.php', post, header, true, (result, error) {
      Get.back();
      if (error != null) {
        callback!(null, error);
      }
      if (result != null) {
        callback!(result, null);
      }
    });
  }
}
