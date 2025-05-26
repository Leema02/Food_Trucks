import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/menu_service.dart';
import 'package:easy_localization/easy_localization.dart';

class EditMenuItemPage extends StatefulWidget {
  final Map<String, dynamic> item;
  const EditMenuItemPage({super.key, required this.item});

  @override
  State<EditMenuItemPage> createState() => _EditMenuItemPageState();
}

class _EditMenuItemPageState extends State<EditMenuItemPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _caloriesController;

  File? _selectedImage;
  bool isAvailable = true;
  bool isVegan = false;
  bool isSpicy = false;
  bool isSubmitting = false;
  String? token;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item['name']);
    _descriptionController =
        TextEditingController(text: widget.item['description']);
    _priceController =
        TextEditingController(text: widget.item['price'].toString());
    _categoryController = TextEditingController(text: widget.item['category']);
    _caloriesController =
        TextEditingController(text: widget.item['calories']?.toString() ?? '');
    isAvailable = widget.item['isAvailable'] ?? true;
    isVegan = widget.item['isVegan'] ?? false;
    isSpicy = widget.item['isSpicy'] ?? false;
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
  }

  String getFullImageUrl(String path) {
    return path.startsWith('http') ? path : 'http://10.0.2.2:5000$path';
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
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
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_complete_all_fields'.tr())),
      );
      return;
    }

    if (token == null) return;

    setState(() => isSubmitting = true);
    String imageUrl = widget.item['image_url'];

    if (_selectedImage != null) {
      final uploadedUrl = await _uploadImage(_selectedImage!);
      if (uploadedUrl != null) imageUrl = uploadedUrl;
    }

    final data = {
      "name": _nameController.text.trim(),
      "description": _descriptionController.text.trim(),
      "price": double.tryParse(_priceController.text) ?? 0.0,
      "category": _categoryController.text.trim(),
      "calories": int.tryParse(_caloriesController.text),
      "isVegan": isVegan,
      "isSpicy": isSpicy,
      "image_url": imageUrl,
      "isAvailable": isAvailable,
    };

    final response =
        await MenuService.updateMenuItem(widget.item['_id'], data, token!);
    setState(() => isSubmitting = false);

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed_to_update_item'.tr())),
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
        title: Text('edit_menu_item'.tr()),
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
              TextFormField(
                controller: _caloriesController,
                decoration: InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                title: Text('Vegan'),
                value: isVegan,
                onChanged: (val) => setState(() => isVegan = val),
              ),
              SwitchListTile(
                title: Text('Spicy'),
                value: isSpicy,
                onChanged: (val) => setState(() => isSpicy = val),
              ),
              SwitchListTile(
                title: Text('available'.tr()),
                value: isAvailable,
                onChanged: (value) => setState(() => isAvailable = value),
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
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : Image.network(
                          getFullImageUrl(widget.item['image_url']),
                          fit: BoxFit.cover,
                        ),
                ),
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
                    : Text('save_changes'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
