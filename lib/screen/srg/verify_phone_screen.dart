import 'package:e_commerce/screen/ocr_ktp/view/home.dart';
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
import '../../../utils/local_data.dart';
import '../../../widget/material/button_green_widget.dart';

AuthController authController = new AuthController();
bool verifCode = true;

class VerifyPhoneScreen extends StatelessWidget {
  const VerifyPhoneScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (verifCode) {
      authController.sendVerifyCode(
          context: context,
          callback: (result, error) {
            DialogConstant.alertError('Kode Verifikasi telah dikirimkan!');
          });
      verifCode = false;
    }

    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Image.asset(ImageConstant.ilus_forgot_pass,
                      height: size.height * 0.20)),
              SizedBox(height: 45),
              Text(
                'Belum\nVerifikasi?',
                style: TextConstant.regular.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              SizedBox(height: 30),
              FutureBuilder(
                  future: LocalData.getData('phone'),
                  builder: (context, snapshot) {
                    return Text(
                      'Silahkan masukkan kode verifikasi yang telah dikirim ke Whatsapp Anda (' +
                          snapshot.data.toString() +
                          ')',
                      style: TextConstant.regular
                          .copyWith(fontSize: 14, color: Colors.black87),
                    );
                  }),
              SizedBox(height: 45),
              Container(
                child: Row(
                  children: [
                    Icon(Icons.numbers, size: 24, color: Colors.grey.shade400),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        height: 40,
                        child: TextField(
                          controller: authController.verifyCode,
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(12),
                            FilteringTextInputFormatter.deny(
                                RegExp('[\\-|\\,|\\.|\\#|\\*]'))
                          ],
                          decoration: DecorationConstant.inputDecor().copyWith(
                              hintText: "Masukkan kode verifikasi",
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
                onClick: () => authController.validationVerify(
                    context: context,
                    callback: (result, error) {
                      if (result != null && result['error'] != true) {
                        // Get.offAll(LandingHome());
                        Get.offAll(KtpOCR());
                      } else {
                        DialogConstant.alertError(result['message']);
                      }
                    }),
              ),
              SizedBox(height: 15),
              Center(
                child: GestureDetector(
                  onTap: () => authController.sendVerifyCode(
                      context: context,
                      callback: (result, error) {
                        DialogConstant.alertError(
                            'Kode Verifikasi telah dikirimkan!');
                      }),
                  child: RichText(
                    text: TextSpan(
                      text: 'Kirim',
                      style: TextConstant.regular.copyWith(color: Colors.green),
                      children: <TextSpan>[
                        TextSpan(
                            text: ' Ulang kode?', style: TextConstant.regular),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
