import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greyfundr/shared/text_style.dart'; // ← assuming you have txStyle18SemiBold or similar

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // or your app's background color
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // flat modern look
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 24,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Create AN Event',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // You can add your intro text or form fields here
              Text(
                'Event Start',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Create an event where people can digitally contribute to a shared fund. Perfect for parties, trips, or any group activity!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              SizedBox(height: 32),

              // Placeholder for your actual content (form, amount input, participants, etc.)
              Center(
                child: Text(
                  'Start Now',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),

              // Add your input fields, buttons, participant list, etc. here
            ],
          ),
        ),
      ),
    );
  }
}