import 'package:e_commerce/api/api.dart';
import 'package:e_commerce/screen/gabriel/notifications/item_screen.dart';
import 'package:get/get.dart';

import "../../../core/app_export.dart";
import 'package:intl/intl.dart';

class List1ItemWidget extends StatefulWidget {
  const List1ItemWidget({
    Key? key,
    this.data,
    this.color,
    required this.onQuantityChanged, // Callback to notify quantity changes
  }) : super(key: key);

  final bool? color;
  final Map<String, dynamic>? data;
  final void Function(dynamic updatedData) onQuantityChanged;

  @override
  _List1ItemWidgetState createState() => _List1ItemWidgetState();

  dynamic getData() {
    return data;
  }
}

class _List1ItemWidgetState extends State<List1ItemWidget> {
  late TextEditingController _controller;
  int _quantity = 0;
  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: 0.toString());
  }

  void _increment() {
    if (_quantity < widget.data!['quantity']) {
      setState(() {
        _quantity++;
        _controller.text = _quantity.toString();
        _notifyQuantityChange();
      });
    }
  }

  void _decrement() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
        _controller.text = _quantity.toString();
        _notifyQuantityChange();
      });
    }
  }

  void _onChanged(String value) {
    _controller.text = (int.parse(_controller.text)).toString();
    int? newValue = int.tryParse(value);
    if (newValue != null) {
      if (newValue < 0) {
        setState(() {
          _quantity = 0;
          _controller.text = _quantity.toString();
        });
      } else if (newValue > widget.data!['quantity']) {
        setState(() {
          _quantity = widget.data!['quantity'];
          _controller.text = _quantity.toString();
        });
      } else {
        setState(() {
          _quantity = newValue;
        });
      }
      _notifyQuantityChange();
    }
    if (_controller.text.isEmpty) {
      _controller.text = 0.toString();
    }
  }

  void _notifyQuantityChange() {
    widget.data!['quantity_selected'] = _quantity;
    widget.onQuantityChanged(widget.data!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color!
          ? const Color.fromARGB(255, 250, 221, 133)
          : Colors.blue[50]!,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              print(widget.data!);
              Get.to(ItemScreen(
                data: widget.data!.map((key, value) =>
                        MapEntry(key.toString(), value.toString()))
                    as Map<String, dynamic>,
              ));
            },
            child: CustomImageView(
              imagePath: "${API.BASE_URL}/images/${widget.data!['image_url']}",
              height: 225.v,
              width: double.infinity,
              alignment: Alignment.center,
              fit: BoxFit.fill,
            ),
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 18.v),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data!['product_name'],
                      style: const TextStyle(
                          color: Color.fromARGB(255, 6, 136, 112),
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Quantity: ${widget.data!['quantity']}",
                              style: TextStyle(
                                  color: !widget.color!
                                      ? const Color.fromARGB(255, 9, 0, 139)
                                      : const Color.fromARGB(255, 162, 7, 7),
                                  fontSize: 14),
                              textAlign: TextAlign.start,
                            ),
                            Text(
                              "Price: ${currencyFormatter.format(widget.data!['price'])}",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: widget.color!
                                      ? const Color.fromARGB(255, 9, 0, 139)
                                      : const Color.fromARGB(255, 162, 7, 7)),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.adaptSize)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                iconSize: 16,
                                onPressed: _decrement,
                              ),
                              Container(
                                alignment: Alignment.center,
                                width: 40, // Mengurangi lebar TextField
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  controller: _controller,
                                  keyboardType: TextInputType.number,
                                  onChanged: _onChanged,
                                  style: const TextStyle(
                                      fontSize: 14), // Mengurangi ukuran teks
                                  decoration: const InputDecoration(
                                    border: InputBorder
                                        .none, // Menghilangkan garis di bawah TextField
                                    isDense:
                                        true, // Mengurangi padding TextField
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                iconSize: 16, // Mengurangi ukuran ikon
                                onPressed: _increment,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ])),
        ],
      ),
    );
  }
}
