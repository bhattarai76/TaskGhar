// lib/pages/booking_form_page.dart
import 'package:flutter/material.dart';

class BookingFormPage extends StatefulWidget {
  final String serviceName;
  final Map<String, dynamic> provider;

  const BookingFormPage({super.key, required this.serviceName, required this.provider});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedTime = 'Morning (7 AM - 12 PM)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request ${widget.provider['name']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Card(
              color: Colors.deepPurple.withOpacity(0.05),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.gavel, color: Colors.deepPurple, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Hiring for: ${widget.serviceName}\nRate: ${widget.provider['rate']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Location Input
            const Text('Your Location (Tole / Ward No.)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'e.g., Gorahi-15, Bharatpur Tole',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on, color: Colors.deepPurple),
              ),
            ),
            const SizedBox(height: 20),

            // Contact Number
            const Text('Contact Phone Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'e.g., 98XXXXXXXX',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone, color: Colors.deepPurple),
              ),
            ),
            const SizedBox(height: 20),

            // Preferred Time Slot
            const Text('Preferred Time Slot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedTime,
              decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.access_time, color: Colors.deepPurple)),
              items: <String>['Morning (7 AM - 12 PM)', 'Afternoon (12 PM - 4 PM)', 'Evening (4 PM - 7 PM)']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() { _selectedTime = newValue!; });
              },
            ),
            const SizedBox(height: 20),

            // Task Description
            const Text('Describe the Work Needed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Provide some details about the issue so the professional understands what tools to bring...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_locationController.text.isEmpty || _phoneController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill out location and contact info!'), backgroundColor: Colors.redAccent),
                    );
                    return;
                  }
                  // Action when link request is fired
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Request Transmitted!'),
                      content: Text('TaskGhar has bridged your request over to ${widget.provider['name']}. Please wait for them to contact you directly.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close dialog
                            Navigator.pop(context); // Go back to listings
                          },
                          child: const Text('OK'),
                        )
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Send Connection Request', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}