import 'package:flutter/material.dart';
import 'package:myapp/core/services/truck_capacity_service.dart';

class ManageCapacityPage extends StatefulWidget {
  final String truckId;

  const ManageCapacityPage({super.key, required this.truckId});

  @override
  State<ManageCapacityPage> createState() => _ManageCapacityPageState();
}

class _ManageCapacityPageState extends State<ManageCapacityPage> {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  int? currentSavedValue;

  @override
  void initState() {
    super.initState();
    _loadCapacity();
  }

  Future<void> _loadCapacity() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final capacity = await TruckCapacityService.getCapacity(widget.truckId);
    if (capacity != null) {
      _controller.text = capacity.toString();
      currentSavedValue = capacity;
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveCapacity() async {
    final value = int.tryParse(_controller.text);
    if (value == null || value < 1) {
      setState(() {
        errorMessage = 'Please enter a valid number greater than 0.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final success =
        await TruckCapacityService.setCapacity(widget.truckId, value);

    setState(() {
      isLoading = false;
      if (success) {
        currentSavedValue = value;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Capacity saved successfully!')),
        );
      } else {
        errorMessage = 'Failed to save capacity.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Capacity'),
        backgroundColor: Colors.orange.shade800,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'Enter the maximum number of orders this truck can handle in parallel:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Concurrent Orders',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    onPressed: _saveCapacity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                  if (currentSavedValue != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Current capacity: $currentSavedValue',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  if (errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Text(errorMessage!,
                        style: const TextStyle(color: Colors.red)),
                  ]
                ],
              ),
            ),
    );
  }
}
