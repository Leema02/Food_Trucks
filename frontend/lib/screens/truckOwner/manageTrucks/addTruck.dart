import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/core/constants/supported_cities.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/core/services/truckOwner_service.dart';

class AddTruckPage extends StatefulWidget {
  const AddTruckPage({super.key});

  @override
  State<AddTruckPage> createState() => _AddTruckPageState();
}

class _AddTruckPageState extends State<AddTruckPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  String? selectedCity;
  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;
  File? _selectedImage;
  bool isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    final uri = Uri.parse('http://192.168.10.7:5000/api/upload');
    var request = http.MultipartRequest('POST', uri);
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));
    var response = await request.send();

    if (response.statusCode == 200) {
      final resBody = await response.stream.bytesToString();
      final resData = jsonDecode(resBody);
      return resData['url'];
    } else {
      return null;
    }
  }

  Future<void> _addTruck() async {
    if (_formKey.currentState!.validate() &&
        _selectedImage != null &&
        selectedCity != null) {
      setState(() => isSubmitting = true);

      try {
        final uploadedUrl = await _uploadImage(_selectedImage!);
        if (uploadedUrl == null) {
          _showMessage('failed_to_add_truck'.tr());
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token') ?? '';

        final truckData = {
          "truck_name": _nameController.text.trim(),
          "cuisine_type": _cuisineController.text.trim(),
          "description": _descriptionController.text.trim(),
          "city": selectedCity, // store key
          "location": {
            "address_string": _addressController.text.trim(),
          },
          "operating_hours": {
            "open": _openTime?.format(context) ?? '',
            "close": _closeTime?.format(context) ?? '',
          },
          "logo_image_url": uploadedUrl,
        };

        final response = await TruckOwnerService.addTruck(token, truckData);
        if (response.statusCode == 201) {
          await _showSuccessPopup();
        } else {
          _showMessage('failed_to_add_truck'.tr());
        }
      } finally {
        setState(() => isSubmitting = false);
      }
    } else {
      _showMessage('fill_all_fields_image_city'.tr());
    }
  }

  Future<void> _showSuccessPopup() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.deepOrange, size: 60),
            const SizedBox(height: 10),
            Text(
              'truck_added_successfully'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text('OK', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.orange,
      content: Text(message, textAlign: TextAlign.center),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 222, 182),
      appBar: AppBar(
        title: Text('add_truck'.tr()),
        backgroundColor: const Color.fromARGB(255, 255, 132, 39),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, 'truck_name'.tr()),
              const SizedBox(height: 12),
              _buildTextField(_cuisineController, 'cuisine_type'.tr()),
              const SizedBox(height: 12),
              _buildTextField(_descriptionController, 'description'.tr()),
              const SizedBox(height: 12),
              _buildTextField(_addressController, 'address'.tr()),
              const SizedBox(height: 12),
              _buildCityDropdown(),
              const SizedBox(height: 12),
              _buildTimePicker('opening_time'.tr(), true),
              const SizedBox(height: 12),
              _buildTimePicker('closing_time'.tr(), false),
              const SizedBox(height: 12),
              _buildImagePicker(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isSubmitting ? null : _addTruck,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 253, 136, 40),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'add_truck'.tr(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'required_field'.tr() : null,
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCity,
      decoration: InputDecoration(
        labelText: 'city'.tr(),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: supportedCities.map((cityKey) {
        return DropdownMenuItem(
          value: cityKey,
          child: Text(cityKey.tr()), // Translated name
        );
      }).toList(),
      onChanged: (value) => setState(() => selectedCity = value),
      validator: (value) =>
          value == null || value.isEmpty ? 'required_field'.tr() : null,
    );
  }

  Widget _buildTimePicker(String label, bool isOpenTime) {
    final time = isOpenTime ? _openTime : _closeTime;
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(time == null ? label : time.format(context)),
      trailing: const Icon(Icons.access_time),
      onTap: () => _selectTime(isOpenTime),
    );
  }

  Future<void> _selectTime(bool isOpenTime) async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
      });
    }
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
        ),
        child: _selectedImage == null
            ? Center(child: Text('tap_to_select_logo'.tr()))
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
      ),
    );
  }
}
