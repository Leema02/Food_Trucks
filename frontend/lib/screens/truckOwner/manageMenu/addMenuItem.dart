import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/menu_service.dart';
import 'package:easy_localization/easy_localization.dart';

class AddMenuItemPage extends StatefulWidget {
  final String truckId;
  const AddMenuItemPage({super.key, required this.truckId});

  @override
  State<AddMenuItemPage> createState() => _AddMenuItemPageState();
}

class _AddMenuItemPageState extends State<AddMenuItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  File? _selectedImage;
  bool isAvailable = true;
  bool isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  String getFullImageUrl(String path) {
    return path.startsWith('http') ? path : 'http://10.0.2.2:5000$path';
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    final uri = Uri.parse('http://10.0.2.2:5000/api/upload');
    var request = http.MultipartRequest('POST', uri);
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));
    var response = await request.send();

    if (response.statusCode == 200) {
      final resBody = await response.stream.bytesToString();
      final resData = jsonDecode(resBody);
      return getFullImageUrl(resData['url']);
    } else {
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('plz_fill_all_fields'.tr())),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    setState(() => isSubmitting = true);
    final uploadedUrl = await _uploadImage(_selectedImage!);
    if (uploadedUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('image_upload_failed'.tr())),
      );
      setState(() => isSubmitting = false);
      return;
    }

    final data = {
      "truck_id": widget.truckId,
      "name": _nameController.text.trim(),
      "description": _descriptionController.text.trim(),
      "price": double.tryParse(_priceController.text) ?? 0.0,
      "category": _categoryController.text.trim(),
      "image_url": uploadedUrl,
      "isAvailable": isAvailable,
    };

    final response = await MenuService.addMenuItem(token, data);
    setState(() => isSubmitting = false);

    if (response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed_to_add_menu_item').tr()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 222, 182),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 136, 0),
        foregroundColor: Colors.black,
        title: Text('add_menu_item'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'item_name'.tr()),
                validator: (value) => value == null || value.isEmpty
                    ? 'enter_item_name'.tr()
                    : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'description'.tr()),
                maxLines: 2,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'price'.tr()),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'enter_price'.tr() : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'category'.tr()),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _selectedImage == null
                      ? Center(child: Text('tap_to_select_image'.tr()))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text('available'.tr()),
                value: isAvailable,
                onChanged: (value) {
                  setState(() => isAvailable = value);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('add_item'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
