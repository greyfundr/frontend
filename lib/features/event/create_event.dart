// createvent.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CreateventPage extends StatefulWidget {
  const CreateventPage({super.key});

  @override
  State<CreateventPage> createState() => _CreateventPageState();
}

class _CreateventPageState extends State<CreateventPage> {
  final PageController _pageController = PageController();
  int currentStep = 0;

  // All event data stored here
  final Map<String, dynamic> eventData = {
    'role': null, // "owner" or "organizer"
    'ownerName': '',
    'ownerPhone': '',
    'eventName': '',
    'category': null,
    'bannerImages': <XFile>[],
  };

  // final ImagePicker _picker = ImagePicker();

  void nextPage() {
    if (currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            if (currentStep == 0) {
              Navigator.pop(context);
            } else {
              previousPage();
            }
          },
        ),
        title: const Text(
          "Create Event",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: List.generate(5, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index <= currentStep
                          ? Colors.teal
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Step ${currentStep + 1} of 5",
            style: const TextStyle(
              color: Colors.teal,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          // PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe, use buttons
              onPageChanged: (index) {
                setState(() => currentStep = index);
              },
              children: [
                Step1(eventData: eventData, onNext: nextPage),
                Step2(eventData: eventData, onNext: nextPage),
                Step3(eventData: eventData, onNext: nextPage),
                const Center(child: Text("Step 4 - Location", style: TextStyle(fontSize: 24))),
                const Center(child: Text("Step 5 - Review & Publish", style: TextStyle(fontSize: 24))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================== STEP 1 ======================
class Step1 extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final VoidCallback onNext;

  const Step1({super.key, required this.eventData, required this.onNext});

  @override
  State<Step1> createState() => _Step1State();
}

class _Step1State extends State<Step1> with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _heightAnim;

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _heightAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? role = widget.eventData['role'];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Event Role", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Pick your role in this event", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(child: _roleCard("Event Owner", Icons.person_outline, role == "owner", () {
                setState(() {
                  widget.eventData['role'] = "owner";
                  _animController.reverse();
                });
              })),
              const SizedBox(width: 16),
              Expanded(child: _roleCard("Event Organizer", Icons.groups_outlined, role == "organizer", () {
                setState(() {
                  widget.eventData['role'] = "organizer";
                  _animController.forward();
                });
              })),
            ],
          ),

          SizeTransition(
            sizeFactor: _heightAnim,
            child: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Event Owner's Details"),
                  const SizedBox(height: 16),
                  TextField(controller: nameCtrl, decoration: _inputDecoration("Owner's Full Name")),
                  const SizedBox(height: 16),
                  TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: _inputDecoration("Owner's Phone Number")),
                ],
              ),
            ),
          ),

          const Spacer(),
          _nextButton(
            enabled: role != null,
            onPressed: () {
              if (role == "organizer") {
                widget.eventData['ownerName'] = nameCtrl.text.trim();
                widget.eventData['ownerPhone'] = phoneCtrl.text.trim();
              }
              widget.onNext();
            },
          ),
        ],
      ),
    );
  }

  Widget _roleCard(String title, IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? Colors.teal : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? Colors.teal : Colors.grey.shade300, width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: selected ? Colors.teal : Colors.grey[600]),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? Colors.teal : Colors.black87)),
          ],
        ),
      ),
    );
  }
}

// ====================== STEP 2 ======================
class Step2 extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final VoidCallback onNext;

  const Step2({super.key, required this.eventData, required this.onNext});

  @override
  State<Step2> createState() => _Step2State();
}

// ====================== STEP 3 ======================
class Step3 extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final VoidCallback onNext;

  const Step3({super.key, required this.eventData, required this.onNext});

  @override
  State<Step3> createState() => _Step3State();
}

class _Step3State extends State<Step3> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController timeCtrl = TextEditingController();

  @override
  void dispose() {
    dateCtrl.dispose();
    timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (d != null) {
      setState(() {
        selectedDate = d;
        dateCtrl.text = DateFormat.yMMMMd().format(d);
      });
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (t != null) {
      setState(() {
        selectedTime = t;
        timeCtrl.text = t.format(context);
      });
    }
  }

  bool get canProceed => selectedDate != null && selectedTime != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Date and Time", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Choose a date and time for your event", style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 32),

          TextField(
            controller: dateCtrl,
            readOnly: true,
            onTap: _pickDate,
            decoration: _inputDecoration("Event Date"),
          ),
          const SizedBox(height: 24),

          TextField(
            controller: timeCtrl,
            readOnly: true,
            onTap: _pickTime,
            decoration: _inputDecoration("Event Time"),
          ),

          const Spacer(),
          _nextButton(
            enabled: canProceed,
            onPressed: () {
              // Save selected values into eventData
              if (selectedDate != null) widget.eventData['date'] = selectedDate!.toIso8601String();
              if (selectedTime != null) widget.eventData['time'] = selectedTime!.format(context);
              widget.onNext();
            },
          ),
        ],
      ),
    );
  }
}

class _Step2State extends State<Step2> {
  final TextEditingController nameCtrl = TextEditingController();
  String? category;
  List<XFile> images = [];

  final List<String> categories = [
    "Concert & Music", "Conference & Seminar", "Workshop & Training", "Party & Nightlife",
    "Fundraiser & Charity", "Sports & Fitness", "Food & Drink", "Art & Culture",
    "Fashion & Beauty", "Tech & Startup", "Religious & Spiritual", "Wedding & Celebration",
    "Comedy Show", "Other",
  ];

  bool get canProceed => nameCtrl.text.trim().isNotEmpty && category != null && images.isNotEmpty;

  Future<void> pickImages() async {
    final picked = await ImagePicker().pickMultiImage();
    // if (picked != null) {
      setState(() => images = picked);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Event Details", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Tell us about your event", style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 32),

          TextField(
            controller: nameCtrl,
            decoration: _inputDecoration("Event Name"),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),

          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: _inputDecoration("Event Category"),
            hint: const Text("Select category"),
            items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => category = v),
          ),
          const SizedBox(height: 24),

          const Text("Event Banner", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: pickImages,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: images.isEmpty ? Colors.grey.shade400 : Colors.teal, width: 2),
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[50],
              ),
              child: images.isEmpty
                  ? Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                      Icon(Icons.add_photo_alternate_outlined, size: 50, color: Colors.grey),
                      SizedBox(height: 12),
                      Text("Tap to add banner images", style: TextStyle(color: Colors.grey)),
                    ])
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                      itemCount: images.length,
                      itemBuilder: (_, i) => ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(images[i].path), fit: BoxFit.cover)),
                    ),
            ),
          ),

          const Spacer(),
          _nextButton(
            enabled: canProceed,
            onPressed: () {
              widget.eventData['eventName'] = nameCtrl.text.trim();
              widget.eventData['category'] = category;
              widget.eventData['bannerImages'] = images;
              widget.onNext();
            },
          ),
        ],
      ),
    );
  }
}

// ====================== SHARED WIDGETS ======================
InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.teal, width: 2), borderRadius: BorderRadius.circular(12)),
  );
}

Widget _nextButton({required bool enabled, required VoidCallback onPressed}) {
  return SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      child: const Text("NEXT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    ),
  );
}