import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/core/services/truckOwner_service.dart';
import 'package:http/http.dart' as http;

class AddTruckPage extends StatefulWidget {
  const AddTruckPage({super.key});

  @override
  State<AddTruckPage> createState() => _AddTruckPageState();
}

class _AddTruckPageState extends State<AddTruckPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cuisineController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;
  File? _selectedImage;
  bool isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
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
    if (_formKey.currentState!.validate() && _selectedImage != null) {
      setState(() {
        isSubmitting = true;
      });

      try {
        final uploadedUrl = await _uploadImage(_selectedImage!);
        if (uploadedUrl == null) {
          _showMessage('❌ Failed to upload image.');
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token') ?? '';

        final truckData = {
          "truck_name": _nameController.text.trim(),
          "cuisine_type": _cuisineController.text.trim(),
          "description": _descriptionController.text.trim(),
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
          _showMessage('❌ Failed to add truck.');
        }
      } finally {
        setState(() {
          isSubmitting = false;
        });
      }
    } else {
      _showMessage('❌ Please complete all fields and select a logo.');
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
            const Text(
              'Truck Added Successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                borderRadius: BorderRadius.circular(30),
              ),
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
        title: const Text('Add Truck'),
        backgroundColor: const Color.fromARGB(255, 255, 132, 39),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, 'Truck Name'),
              const SizedBox(height: 12),
              _buildTextField(_cuisineController, 'Cuisine Type'),
              const SizedBox(height: 12),
              _buildTextField(_descriptionController, 'Description'),
              const SizedBox(height: 12),
              _buildTextField(_addressController, 'Address'),
              const SizedBox(height: 12),
              _buildTimePicker('Opening Time', true),
              const SizedBox(height: 12),
              _buildTimePicker('Closing Time', false),
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
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Add Truck',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildTimePicker(String label, bool isOpenTime) {
    final time = isOpenTime ? _openTime : _closeTime;
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(time == null ? label : time.format(context)),
      trailing: const Icon(Icons.access_time),
      onTap: () => _selectTime(isOpenTime),
    );
  }

  Future<void> _selectTime(bool isOpenTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
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
            ? const Center(child: Text('Tap to select truck logo'))
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
      ),
    );
  }
}
