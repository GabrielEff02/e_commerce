import 'dart:convert';
import 'dart:io';
import 'package:e_commerce/api/api.dart';
import 'package:e_commerce/constant/dialog_constant.dart';
import 'package:e_commerce/screen/auth/splash_screen.dart';
import 'package:e_commerce/screen/gabriel/core/app_export.dart';
import 'package:e_commerce/utils/local_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/screen/ocr_ktp/controller/kecamatan_controller.dart';
import 'package:e_commerce/screen/ocr_ktp/controller/kelurahan_controller.dart';
import 'package:e_commerce/screen/ocr_ktp/controller/kota_controller.dart';
import 'package:e_commerce/screen/ocr_ktp/controller/province_controller.dart';
import 'package:e_commerce/screen/ocr_ktp/identifier_ocr.dart';
import 'package:e_commerce/screen/ocr_ktp/model/kecamatan_model.dart';
import 'package:e_commerce/screen/ocr_ktp/model/kelurahan_model.dart';
import 'package:e_commerce/screen/ocr_ktp/model/kota_model.dart';
import 'dart:async';
import 'package:e_commerce/screen/ocr_ktp/model/ocr_result_model.dart';
import 'package:e_commerce/screen/ocr_ktp/model/provinsi_model.dart';
import 'package:e_commerce/screen/ocr_ktp/widget/image_picker.dart';
import 'package:e_commerce/screen/ocr_ktp/widget/textfield.dart';

class KtpOCR extends StatefulWidget {
  const KtpOCR({Key? key}) : super(key: key);

  @override
  State<KtpOCR> createState() => _KtpOCRState();
}

class _KtpOCRState extends State<KtpOCR> {
  final ProvinceController provinceController = Get.put(
    ProvinceController(),
  );
  final CityController cityController = Get.put(
    CityController(),
  );
  final KecamatanController kecamatanControl = Get.put(
    KecamatanController(),
  );
  final KelurahanController kelurahanControl = Get.put(
    KelurahanController(),
  );
  final TextEditingController nikController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController rtController = TextEditingController();
  final TextEditingController rwController = TextEditingController();
  final golDarahController = "".obs;
  final jenisKelaminController = "".obs;
  final agamaController = "".obs;
  final kewarganegaraanController = "".obs;
  final TextEditingController pekerjaanController = TextEditingController();
  final TextEditingController tempatlahirController = TextEditingController();
  final TextEditingController tgllahirController = TextEditingController();
  final statusPerkawinanController = "".obs;
  final result = Rxn<OcrResultModel>();

  Future<void> scanKtp() async {
    OcrResultModel? res;
    try {
      res = await MncIdentifierOcr.startCaptureKtp(
          withFlash: true, cameraOnly: true);
    } catch (e) {
      debugPrint('something goes wrong $e');
    }

    if (!mounted) return;
    result.value = res;

    // provinsi
    final prov = result.value?.ktp?.provinsi;
    final provFinal = findClosestMatch(prov!, provinceController.provinces);
    final selectedProvince = provinceController.provinces
        .firstWhere((province) => province.name == provFinal);
    provinceController.selectedProvince.value = selectedProvince;
    await cityController.fetchCities(selectedProvince.id);

    // kabupaten/kota
    if (provinceController.selectedProvince.value!.name.isNotEmpty &&
        result.value!.ktp!.kabKot != null) {
      final city = result.value?.ktp?.kabKot;
      final cityFinal = findClosestMatch(city!, cityController.cities);

      final selectedCity = cityController.cities.firstWhere(
        (city) => city.name == cityFinal,
      );
      cityController.selectedCity.value = selectedCity;
      await kecamatanControl
          .fetchKecamatanModel(cityController.selectedCity.value!.id);
      debugPrint('Error finding city: $cityFinal ');

      // Kecamatan
      if (cityController.selectedCity.value!.name.isNotEmpty &&
          result.value!.ktp!.kecamatan != null) {
        final kecamatan = result.value?.ktp?.kecamatan;
        final kecamatanFinal = findClosestMatch(
            kecamatan!, kecamatanControl.kecamatanModel.kecamatan);
        for (Kecamatan kecam in kecamatanControl.kecamatanModel.kecamatan) {
          if (kecam.nama == kecamatanFinal) {
            kecamatanControl.selectedKecamatan = kecam.id;
          }
        }
        await kelurahanControl
            .fetchKelurahanModel(kecamatanControl.selectedKecamatan!);

        // Kelurahan
        if (kecamatanControl.selectedKecamatan != 0 &&
            result.value!.ktp!.kelurahan != null) {
          final kelurahan = result.value?.ktp?.kelurahan;
          final kelurahanFinal = findClosestMatch(
              kelurahan!, kelurahanControl.kelurahanModel.kelurahan);
          kelurahanControl.selectedKelurahan = kelurahanFinal;
        }
      }
    }
    print(result.toJson());
  }

  int distanceCount(String a, String b) {
    final List<List<int>> dp = List.generate(
      a.length + 1,
      (_) => List.filled(b.length + 1, 0),
    );

    for (int i = 0; i <= a.length; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= b.length; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = (a[i - 1] == b[j - 1]) ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1, // Deletion
          dp[i][j - 1] + 1, // Insertion
          dp[i - 1][j - 1] + cost, // Substitution
        ].reduce((value, element) => value < element ? value : element);
      }
    }
    return dp[a.length][b.length];
  }

  String? findClosestMatch(String input, List<dynamic> candidates) {
    String? closestMatch;
    int lowestDistance = 999999;
    int distance = 0;
    for (var candidate in candidates) {
      if (candidate.runtimeType == City) {
        distance = distanceCount(
          input.toLowerCase(),
          candidate.name.toLowerCase(),
        );
      } else {
        distance = distanceCount(
          input.toLowerCase(),
          candidate.nama.toLowerCase(),
        );
      }
      if (distance < lowestDistance) {
        lowestDistance = distance;
        if (candidate.runtimeType == City) {
          closestMatch = candidate.name;
        } else {
          closestMatch = candidate.nama;
        }
      }
    }

    return closestMatch;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'OCR KTP',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
        child: Column(
          children: [
            widgetTextField(),
            const SizedBox(
              height: 12,
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFB3E5FC), // Light blue
                    Color.fromARGB(255, 61, 192, 253)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 4), // Shadow position
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors
                      .transparent, // Set to transparent to allow gradient
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(
                      vertical: 18, horizontal: 40), // Padding
                  elevation:
                      0, // Removing default shadow as we have custom shadow
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Are You Sure??"),
                      content: Text(
                          "Apakah anda sudah yakin data\nyang anda kirimkan sudah benar?"),
                      actions: <Widget>[
                        TextButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _postData(
                              {
                                'nik': nikController.text,
                                'nama': nameController.text,
                                'tempat_lahir': tempatlahirController.text,
                                'tanggal_lahir': tgllahirController.text,
                                'jenis_kelamin': jenisKelaminController.value,
                                'golongan_darah': golDarahController.value,
                                'alamat': alamatController.text,
                                'rt': rtController.text,
                                'rw': rwController.text,
                                'kelurahan': kelurahanControl.selectedKelurahan,
                                'kecamatan':
                                    kecamatanControl.selectedKecamatanName,
                                'kota': cityController.selectedCity.value!.name,
                                'provinsi': provinceController
                                    .selectedProvince.value!.name,
                                'agama': agamaController.value,
                                'status_perkawinan':
                                    statusPerkawinanController.value,
                                'pekerjaan': pekerjaanController.text,
                                'kewarganegaraan':
                                    kewarganegaraanController.value,
                              },
                            );
                          },
                        ),
                        TextButton(
                          child: Text("CANCEL"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  "Submit", // Button text
                  style: TextStyle(
                    fontSize: 18, // Font size
                    fontWeight: FontWeight.w600, // Font weight
                    letterSpacing: 1.5, // Spacing between letters
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding widgetDropDown() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [],
      ),
    );
  }

  DropdownMenuItem _menuList(value, text) {
    return DropdownMenuItem(
      value: value,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.adaptSize),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _postData(listController) async {
    DialogConstant.loading(context, 'Loading...');
    listController['username'] = await LocalData.getData('user');
    API.basePost(
      "/input_ktp.php",
      listController,
      {'Content-Type': 'application/json'},
      true,
      (result, error) {
        print(result);
        print(error);
        if (result != null && result['error'] != true) {
          setState(
            () {
              LocalData.saveData(
                'detailKTP',
                jsonEncode(listController),
              );
            },
          );
          Get.offAll(
            SplashScreen(),
          );
          Get.snackbar('Success', 'Profile updated successfully!',
              colorText: Colors.white,
              icon: const Icon(
                Icons.check,
                color: Colors.red,
              ),
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              backgroundColor: const Color.fromARGB(83, 0, 0, 0),
              snackPosition: SnackPosition.BOTTOM);
        } else {
          Navigator.pop(context);
          DialogConstant.alertError(result['message']);
        }
      },
    );
  }

  Column widgetTextField() {
    return Column(
      children: [
//*Mulai Field Scan KTP
        Obx(
          () => result.value != null
              ? Image.file(
                  File(
                    result.value!.imagePath.toString(),
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    scanKtp();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.adaptSize),
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.grey[100]!,
                        ],
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.upload_sharp,
                          size: 40,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          "Unggah KTP Anda disini",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
        ),
//*Selesai Unggah KTP
        Obx(
          () => result.value != null
              ? InkWell(
                  onTap: () {
                    scanKtp();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_sharp),
                      SizedBox(
                        width: 12,
                      ),
                      Text("Unggah Kembali") //*Jika ingin unggah kembali
                    ],
                  ),
                )
              : const SizedBox(
                  height: 4,
                ),
        ),
//*Editor TextForm
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => MyTextField(
                  inputType: 'number',
                  prefixIcon: true,
                  icon:
                      const Icon(Icons.badge_outlined, color: Colors.blueGrey),
                  initialData: result.value?.ktp?.nik,
                  controller: nikController,
                  title: "NIK",
                  maxLength: 16,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => MyTextField(
                    inputType: 'string',
                    prefixIcon: false,
                    icon: const Icon(Icons.person_outline, color: Colors.grey),
                    initialData: result.value?.ktp?.nama,
                    controller: nameController,
                    title: "Nama"),
              ),
              const SizedBox(height: 10),
              Obx(
                () => MyTextField(
                    inputType: 'string',
                    icon: const Icon(Icons.location_city_outlined,
                        color: Colors.orange),
                    initialData: result.value?.ktp?.tempatLahir,
                    controller: tempatlahirController,
                    title: "Tempat Lahir"),
              ),
              const SizedBox(height: 10),
              Obx(
                () => MyTextField(
                    inputType: 'date',
                    icon:
                        const Icon(Icons.event_outlined, color: Colors.purple),
                    initialData: result.value?.ktp?.tglLahir,
                    controller: tgllahirController,
                    title: "Tanggal Lahir"),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  "Jenis Kelamin",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
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
                  child: DropdownButtonFormField(
                    hint: const Text("Jenis Kelamin"),
                    value: jenisKelaminController.value.isEmpty
                        ? null
                        : jenisKelaminController.value,
                    items: [
                      {'text': "LAKI - LAKI", 'value': 'L'},
                      {'text': "PEREMPUAN", 'value': 'P'}
                    ]
                        .map(
                          (item) => _menuList(item['value'], item['text']),
                        )
                        .toList(),
                    onChanged: (newValue) {
                      jenisKelaminController.value = newValue;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                          jenisKelaminController.value.isEmpty
                              ? Icons.wc
                              : jenisKelaminController.value == "L"
                                  ? Icons.man
                                  : Icons.woman,
                          color: Colors.blueAccent),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  "Golongan Darah",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
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
                  child: DropdownButtonFormField(
                    hint: const Text("Golongan Darah"),
                    value: golDarahController.value.isEmpty
                        ? null
                        : golDarahController.value,
                    items: ['-', "A", "AB", "B", "O"]
                        .map(
                          (item) => _menuList(item, item),
                        )
                        .toList(),
                    onChanged: (newValue) {
                      golDarahController.value = newValue;
                    },
                    decoration: InputDecoration(
                      prefixIcon: golDarahController.value == "O"
                          ? const Icon(Icons.circle_outlined,
                              color: Colors.red) // O
                          : golDarahController.value == "A"
                              ? const Icon(Icons.looks_one_outlined,
                                  color: Colors.blue) // A
                              : golDarahController.value == "B"
                                  ? const Icon(Icons.looks_two_outlined,
                                      color: Colors.green) // B
                                  : golDarahController.value == "AB"
                                      ? const Icon(Icons.merge_type_outlined,
                                          color: Colors.purple) // AB
                                      : const Icon(Icons.bloodtype_outlined,
                                          color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => MyTextField(
                    inputType: 'string',
                    icon: const Icon(Icons.location_on_outlined,
                        color: Colors.redAccent),
                    initialData: result.value?.ktp?.alamat,
                    controller: alamatController,
                    title: "Alamat"),
              ),
              const SizedBox(height: 10),
              Obx(
                () => MyTextField(
                  inputType: 'number',
                  icon:
                      const Icon(Icons.home_work_outlined, color: Colors.teal),
                  initialData: result.value?.ktp?.rt,
                  controller: rtController,
                  title: "RT",
                  maxLength: 3,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => MyTextField(
                  inputType: 'number',
                  icon:
                      const Icon(Icons.home_work_outlined, color: Colors.teal),
                  initialData: result.value?.ktp?.rw,
                  controller: rwController,
                  title: "RW",
                  maxLength: 3,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  "Provinsi",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
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
                  child: DropdownButtonFormField(
                    hint: const Text("Pilih Provinsi"),
                    value: provinceController.selectedProvince.value?.name,
                    items: provinceController.provinces
                        .map(
                          (province) => _menuList(province.name, province.name),
                        )
                        .toList(),
                    onChanged: (newValue) {
                      final selectedProvince = provinceController.provinces
                          .firstWhere((province) => province.name == newValue);
                      provinceController.selectedProvince.value =
                          selectedProvince;
                      cityController.fetchCities(selectedProvince.id);

                      cityController.selectedCity.value = null;
                      kecamatanControl.selectedKecamatan = null;
                      kelurahanControl.selectedKelurahan = null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon:
                          Icon(Icons.pin_drop, color: Colors.blueAccent),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  "Kabupaten / Kota",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              Obx(
                () => Container(
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
                  child: DropdownButtonFormField(
                    hint: const Text("Pilih Kabupaten / Kota"),
                    value: cityController.selectedCity.value,
                    items: cityController.cities.map(
                      (city) {
                        return _menuList(city, city.name);
                      },
                    ).toList(),
                    onChanged: (value) {
                      cityController.selectedCity.value = value;
                      kecamatanControl.fetchKecamatanModel(
                          cityController.selectedCity.value!.id);

                      kecamatanControl.selectedKecamatan = null;
                      kelurahanControl.selectedKelurahan = null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon:
                          Icon(Icons.pin_drop, color: Colors.blueAccent),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  "Kecamatan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
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
                  child: DropdownButtonFormField(
                    hint: const Text("Pilih Kecamatan"),
                    value: kecamatanControl.selectedKecamatan,
                    items: kecamatanControl.kecamatanModel.kecamatan
                        .map(
                          (kecamatan) =>
                              _menuList(kecamatan.id, kecamatan.nama),
                        )
                        .toList(),
                    onChanged: (value) {
                      kecamatanControl.selectedKecamatan = value;
                      kecamatanControl.selectedKecamatanName = kecamatanControl
                          .kecamatanModel.kecamatan
                          .firstWhere((kecamatan) => kecamatan.id == value)
                          .nama;
                      kelurahanControl.fetchKelurahanModel(
                          kecamatanControl.selectedKecamatan!);
                      kelurahanControl.selectedKelurahan = null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon:
                          Icon(Icons.pin_drop, color: Colors.blueAccent),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  "Kelurahan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
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
                  child: DropdownButtonFormField(
                    value: kelurahanControl.selectedKelurahan,
                    hint: const Text("Pilih Kel/Desa"),
                    items: kelurahanControl.kelurahanModel.kelurahan
                        .map(
                          (kelurahan) =>
                              _menuList(kelurahan.nama, kelurahan.nama),
                        )
                        .toList(),
                    onChanged: (value) {
                      kelurahanControl.selectedKelurahan = value;
                    },
                    decoration: const InputDecoration(
                      prefixIcon:
                          Icon(Icons.pin_drop, color: Colors.blueAccent),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  "Agama",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
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
                  child: DropdownButtonFormField(
                    hint: const Text("Agama"),
                    value: agamaController.value.isEmpty
                        ? null
                        : agamaController.value,
                    items: [
                      "BUDDHA",
                      "HINDU",
                      "ISLAM",
                      "KONGHUCU",
                      "KATHOLIK",
                      "KRISTEN",
                    ]
                        .map(
                          (item) => _menuList(item, item),
                        )
                        .toList(),
                    onChanged: (newValue) {
                      agamaController.value = newValue;
                    },
                    decoration: InputDecoration(
                      prefixIcon: agamaController.value == "ISLAM"
                          ? const Icon(Icons.mosque, color: Colors.green)
                          : agamaController.value == "KRISTEN" ||
                                  agamaController.value == "KATHOLIK"
                              ? const Icon(Icons.church, color: Colors.blue)
                              : agamaController.value == "HINDU"
                                  ? const Icon(Icons.temple_hindu,
                                      color: Colors.orange)
                                  : agamaController.value == "BUDDHA"
                                      ? const Icon(Icons.temple_buddhist,
                                          color: Colors.yellow)
                                      : agamaController.value == "KONGHUCU"
                                          ? const Icon(Icons.balance,
                                              color: Colors.grey)
                                          : const Icon(Icons.account_balance,
                                              color: Colors.black54),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  "Status Perkawinan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
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
                  child: DropdownButtonFormField(
                    hint: const Text("Status Perkawinan"),
                    value: statusPerkawinanController.value.isEmpty
                        ? null
                        : statusPerkawinanController.value,
                    items: ["BELUM KAWIN", "KAWIN", "CERAI HIDUP", "CERAI MATI"]
                        .map(
                          (item) => _menuList(item, item),
                        )
                        .toList(),
                    onChanged: (newValue) {
                      statusPerkawinanController.value = newValue;
                    },
                    decoration: InputDecoration(
                      prefixIcon: statusPerkawinanController.value ==
                              "BELUM KAWIN"
                          ? const Icon(Icons.person_outline,
                              color: Colors.blueGrey)
                          : statusPerkawinanController.value == "KAWIN"
                              ? const Icon(Icons.favorite, color: Colors.red)
                              : statusPerkawinanController.value ==
                                      "CERAI HIDUP"
                                  ? const Icon(Icons.link_off,
                                      color: Colors.orange)
                                  : statusPerkawinanController.value ==
                                          "CERAI MATI"
                                      ? const Icon(Icons.heart_broken,
                                          color: Colors.purple)
                                      : const Icon(Icons.people_outline,
                                          color: Colors.black54),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
              Obx(
                () => MyTextField(
                    inputType: 'string',
                    icon: const Icon(Icons.work, color: Colors.black),
                    initialData: result.value?.ktp?.pekerjaan,
                    controller: pekerjaanController,
                    title: "Pekerjaan"),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  "Kewarganegaraan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
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
                  child: DropdownButtonFormField(
                    hint: const Text("Kewarganegaraam"),
                    value: kewarganegaraanController.value.isEmpty
                        ? null
                        : kewarganegaraanController.value,
                    items: ["WNA", "WNI"]
                        .map(
                          (item) => _menuList(item, item),
                        )
                        .toList(),
                    onChanged: (newValue) {
                      kewarganegaraanController.value = newValue;
                    },
                    decoration: InputDecoration(
                      prefixIcon: kewarganegaraanController.value == "WNI"
                          ? const Icon(Icons.flag, color: Colors.red)
                          : kewarganegaraanController.value == "WNA"
                              ? const Icon(Icons.public, color: Colors.blue)
                              : const Icon(Icons.help_outline,
                                  color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
