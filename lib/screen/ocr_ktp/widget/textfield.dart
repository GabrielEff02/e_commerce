import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextField extends StatelessWidget {
  final String? initialData;
  final String? title;
  final bool? prefixIcon;
  final TextEditingController? controller;
  final Icon icon;
  final String inputType;
  final int? maxLength;

  MyTextField({
    Key? key,
    this.initialData,
    this.controller,
    this.title,
    this.prefixIcon = true,
    required this.icon,
    required this.inputType,
    this.maxLength,
  }) : super(key: key) {
    if (initialData != null) {
      controller?.text = initialData!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            title ?? "",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey[100]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: _getKeyboardType(),
            inputFormatters: _getInputFormatters(),
            maxLength: maxLength,
            onChanged: (value) {
              if (inputType == "string") {
                controller?.text = value.toUpperCase();
                controller?.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller!.text.length),
                );
              }
            },
            readOnly: inputType == "date",
            onTap: () {
              if (inputType == "date") {
                _selectDate(context);
              }
            },
            decoration: InputDecoration(
              counterText: "",
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.purple),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(15),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(15),
              ),
              hintText: "Masukkan ${title ?? ''}",
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              prefixIcon: prefixIcon == true ? icon : null,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  TextInputType _getKeyboardType() {
    if (inputType == "number") return TextInputType.number;
    return TextInputType.text;
  }

  List<TextInputFormatter> _getInputFormatters() {
    List<TextInputFormatter> formatters = [];
    if (inputType == "number") {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    if (maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(maxLength));
    }
    return formatters;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller?.text = "${picked.day}-${picked.month}-${picked.year}";
    }
  }
}
