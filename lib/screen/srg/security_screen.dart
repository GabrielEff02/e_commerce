import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../constant/decoration_constant.dart';
import '../../../constant/dialog_constant.dart';
import '../../../constant/image_constant.dart';
import '../../../constant/text_constant.dart';
import '../../../controller/auth_controller.dart';
import '../../../screen/home/landing_home.dart';
import '../../../widget/material/button_green_widget.dart';

// AuthController authController = new AuthController();
AuthController authController = Get.put(AuthController());

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () => Get.back(),
            child: Icon(CupertinoIcons.back, color: Colors.black87)),
      ),
      body: Obx(
        () => Container(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Image.asset(ImageConstant.ilus_forgot_pass,
                        height: size.height * 0.20)),
                SizedBox(height: 25),
                Text(
                  'Ubah\nKata Sandi?',
                  style: TextConstant.regular.copyWith(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                SizedBox(height: 30),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kata Sandi Baru',
                        style: TextConstant.regular.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            fontSize: 15),
                      ),
                      Container(
                        height: 40,
                        child: TextField(
                          maxLength: 25,
                          controller: authController.changePass,
                          obscureText: authController.openPassOTP2.value,
                          decoration: DecorationConstant.inputDecor().copyWith(
                            hintText: "Masukkan Kata Sandi Baru",
                            counterText: '',
                            contentPadding: EdgeInsets.only(top: 0),
                            suffixIcon: GestureDetector(
                                onTap: () => authController.viewPassOTP(
                                    2, !authController.openPassOTP2.value),
                                child: Icon(
                                  authController.openPassOTP2.value
                                      ? CupertinoIcons.eye_slash
                                      : CupertinoIcons.eye,
                                  size: 20,
                                  color: Colors.grey.shade400,
                                )),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () => authController.sendOtpSMS(
                      context: context,
                      callback: (result, error) {
                        DialogConstant.alertError(
                            'Kode Verifikasi telah dikirimkan!');
                      }),
                  child: RichText(
                    text: TextSpan(
                      text: 'Kirim',
                      style: TextConstant.regular
                          .copyWith(color: Colors.green, fontSize: 14),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' kode otentikasi Whatsapp ke nomor Anda..',
                          style:
                              TextStyle(fontSize: 14.0, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  child: Row(
                    children: [
                      Icon(Icons.numbers,
                          size: 24, color: Colors.grey.shade400),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          height: 40,
                          child: TextField(
                            controller: authController.otpCode,
                            maxLength: 4,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(12),
                              FilteringTextInputFormatter.deny(
                                  RegExp('[\\-|\\,|\\.|\\#|\\*]'))
                            ],
                            decoration: DecorationConstant.inputDecor()
                                .copyWith(
                                    hintText: "Masukkan kode otentikasi",
                                    counterText: '',
                                    contentPadding: EdgeInsets.only(top: 0)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 30),
                ButtonGreenWidget(
                  text: 'Submit',
                  onClick: () => authController.validationOtp(
                    context: context,
                    callback: (result, error) {
                      if (result != null && result['error'] != true) {
                        authController.edtPass.text = "";
                        authController.changePass.text = "";
                        authController.otpCode.text = "";
                        DialogConstant.showSnackBar(
                            "Kata Sandi berhasil diubah!");
                        Get.offAll(LandingHome());
                      } else {
                        DialogConstant.alertError('Kode Verifikasi Salah!');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
