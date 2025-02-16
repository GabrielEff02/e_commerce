import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../constant/decoration_constant.dart';
import '../../constant/dialog_constant.dart';
import '../../constant/image_constant.dart';
import '../../constant/text_constant.dart';
import '../../controller/auth_controller.dart';
import '../../widget/material/button_green_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<RegisterScreen> {
  AuthController registercontroller = AuthController();

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
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.05),
              Center(
                  child: Image.asset(ImageConstant.cart_logo,
                      height: size.height * 0.15)),
              SizedBox(height: 45),
              Text(
                'Daftar',
                style: TextConstant.regular.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              SizedBox(height: 20),
              // Name Field
              buildTextField('Nama', registercontroller.edtNama, 25),
              SizedBox(height: 20),
              // Email Field
              buildTextField('Email', registercontroller.edtEmail, 50,
                  keyboardType: TextInputType.emailAddress),
              SizedBox(height: 20),
              // Phone Field
              buildTextField('No. Telepon', registercontroller.edtPhone, 12,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(12),
                    FilteringTextInputFormatter.deny(
                        RegExp('[\\-|\\,|\\.|\\#|\\*]'))
                  ]),
              SizedBox(height: 20),
              // Username Field
              buildTextField('Username', registercontroller.edtUsername, 20),
              SizedBox(height: 20),
              // Password Field
              buildTextField('Kata Sandi', registercontroller.edtPass, 25,
                  obscureText: true),
              SizedBox(height: 20),
              // Confirm Password Field
              buildTextField('Konfirmasi Kata Sandi',
                  registercontroller.edtConfirmPass, 25,
                  obscureText: true),
              SizedBox(height: 35),
              ButtonGreenWidget(
                text: 'Daftar',
                onClick: () {
                  // Validate fields
                  String email = registercontroller.edtEmail.text.trim();
                  if (email.isEmpty) {
                    DialogConstant.alertError('Email tidak boleh kosong');
                    return;
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                    DialogConstant.alertError('Masukkan email yang valid');
                    return;
                  }

                  String phoneNumber = registercontroller.edtPhone.text.trim();
                  if (phoneNumber.isEmpty) {
                    DialogConstant.alertError('No. Telepon tidak boleh kosong');
                    return;
                  }
                  if (phoneNumber.length < 10 || phoneNumber.length > 12) {
                    DialogConstant.alertError(
                        'No. Telepon harus antara 10 dan 12 digit');
                    return;
                  }

                  String password = registercontroller.edtPass.text.trim();
                  if (password.isEmpty) {
                    DialogConstant.alertError('Kata Sandi tidak boleh kosong');
                    return;
                  }
                  if (password.length < 8) {
                    DialogConstant.alertError(
                        'Kata Sandi harus minimal 8 karakter');
                    return;
                  }

                  String confirmPassword =
                      registercontroller.edtConfirmPass.text.trim();
                  if (confirmPassword.isEmpty) {
                    DialogConstant.alertError(
                        'Konfirmasi Kata Sandi tidak boleh kosong');
                    return;
                  }
                  if (password != confirmPassword) {
                    DialogConstant.alertError(
                        'Kata Sandi dan Konfirmasi tidak cocok');
                    return;
                  }

                  registercontroller.validationRegister(
                    context: context,
                    callback: (result, error) {
                      if (result != null && result['error'] != true) {
                        Get.back();
                        DialogConstant.alertError('Pendaftaran Berhasil');
                      }
                      if (result['error'] == true) {
                        DialogConstant.alertError(result['message']);
                      }
                      if (error != null) {
                        DialogConstant.alertError('Pendaftaran Gagal');
                      }
                    },
                  );
                },
              ),
              SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: RichText(
                    text: TextSpan(
                      text: 'Sudah punya akun ? ',
                      style: TextConstant.regular,
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Login',
                            style: TextConstant.regular
                                .copyWith(color: Colors.green)),
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

  // Helper method to build text fields
  Widget buildTextField(
      String label, TextEditingController controller, int maxLength,
      {TextInputType keyboardType = TextInputType.text,
      bool obscureText = false,
      List<TextInputFormatter>? inputFormatters}) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextConstant.regular.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 15),
          ),
          SizedBox(height: 8),
          Container(
            height: 50,
            child: TextField(
              maxLength: maxLength,
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              inputFormatters: inputFormatters,
              decoration: DecorationConstant.inputDecor().copyWith(
                  hintText: "Masukkan $label",
                  counterText: '',
                  contentPadding: EdgeInsets.only(top: 0)),
            ),
          )
        ],
      ),
    );
  }
}
