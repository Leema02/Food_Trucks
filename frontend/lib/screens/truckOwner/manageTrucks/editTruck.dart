import 'dart:io';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/core/constants/supported_cities.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/core/services/truckOwner_service.dart';

class EditTruckPage extends StatefulWidget {
  final Map<String, dynamic> truck;

  const EditTruckPage({super.key, required this.truck});

  @override
  State<EditTruckPage> createState() => _EditTruckPageState();
}

class _EditTruckPageState extends State<EditTruckPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cuisineController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _openTimeController;
  late TextEditingController _closeTimeController;

  File? _selectedImage;
  String? _uploadedImageUrl;
  String? selectedCity;
  final ImagePicker _picker = ImagePicker();
  bool isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.truck['truck_name']);
    _cuisineController =
        TextEditingController(text: widget.truck['cuisine_type']);
    _descriptionController =
        TextEditingController(text: widget.truck['description'] ?? '');
    _addressController = TextEditingController(
        text: widget.truck['location']?['address_string'] ?? '');
    _openTimeController = TextEditingController(
        text: widget.truck['operating_hours']?['open'] ?? '');
    _closeTimeController = TextEditingController(
        text: widget.truck['operating_hours']?['close'] ?? '');
    _uploadedImageUrl = widget.truck['logo_image_url'];
    selectedCity = widget.truck['city'];
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => isUploadingImage = true);
      await _uploadImage(File(pickedFile.path));
      setState(() => isUploadingImage = false);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    final uri = Uri.parse('http://10.0.2.2:5000/api/upload');
    var request = http.MultipartRequest('POST', uri);
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        final resBody = await response.stream.bytesToString();
        final resData = jsonDecode(resBody);

        setState(() {
          _uploadedImageUrl = resData['url'];
          _selectedImage = imageFile;
        });

        _showMessage('image_upload_success'.tr());
      } else {
        _showMessage('image_upload_failed'.tr());
      }
    } catch (e) {
      _showMessage('${'upload_failed'.tr()}: ${e.toString()}');
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate() && selectedCity != null) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final updatedTruck = {
        "truck_name": _nameController.text.trim(),
        "cuisine_type": _cuisineController.text.trim(),
        "description": _descriptionController.text.trim(),
        "city": selectedCity,
        "location": {
          "address_string": _addressController.text.trim(),
        },
        "operating_hours": {
          "open": _openTimeController.text.trim(),
          "close": _closeTimeController.text.trim(),
        },
        "logo_image_url": _uploadedImageUrl ?? '',
      };

      final response = await TruckOwnerService.updateTruck(
          widget.truck['_id'], updatedTruck, token);

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        _showMessage('failed_to_update_truck'.tr());
      }
    } else {
      _showMessage('please_complete_all_fields'.tr());
    }
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
      backgroundColor: const Color(0xFFFFF7ED),
      appBar: AppBar(
        title: Text('edit_truck'.tr()),
        backgroundColor: const Color.fromARGB(255, 255, 134, 28),
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
              _buildTextField(_openTimeController, 'opening_time_hint'.tr()),
              const SizedBox(height: 12),
              _buildTextField(_closeTimeController, 'closing_time_hint'.tr()),
              const SizedBox(height: 12),
              _buildImagePicker(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isUploadingImage ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 134, 28),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isUploadingImage
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'save_changes'.tr(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              )
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
      items: supportedCities.map((city) {
        return DropdownMenuItem(value: city, child: Text(city));
      }).toList(),
      onChanged: (value) => setState(() => selectedCity = value),
      validator: (value) =>
          value == null || value.isEmpty ? 'required_field'.tr() : null,
    );
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
        child: isUploadingImage
            ? const Center(child: CircularProgressIndicator())
            : (_selectedImage != null)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                : (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _uploadedImageUrl!.startsWith('http')
                              ? _uploadedImageUrl!
                              : 'http://10.0.2.2:5000$_uploadedImageUrl',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(child: Text('tap_to_select_logo'.tr())),
      ),
    );
  }
}
