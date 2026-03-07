import 'package:flutter/material.dart';


import 'package:greyfundr/core/models/split_bill_model.dart';

import 'package:greyfundr/features/bill/pathsforbill/sbuscreen.dart';

// import 'package:greyfundr/core/models/split_user_model.dart';

class SortBillOptionsScreen extends StatefulWidget {
  final SplitBill bill;
  final String amountToPay;

  const SortBillOptionsScreen({
    super.key,
    required this.bill,
    required this.amountToPay,
  });

  @override
  State<SortBillOptionsScreen> createState() => _SortBillOptionsScreenState();
}

class _SortBillOptionsScreenState extends State<SortBillOptionsScreen> {

  late final TextEditingController donorController;

  @override
  void initState() {
    super.initState();

    print('checking widget.bill');
    print(widget.bill);

    // Initialize once with the passed amount
    donorController = TextEditingController(text: widget.amountToPay);

    // Place cursor at the end so user can edit easily
    donorController.selection = TextSelection.fromPosition(
      TextPosition(offset: donorController.text.length),
    );
  }

  @override
  void dispose() {
    donorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFC),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8, top: 8),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Image.asset(
              'assets/images/arrow_back.png',
              width: 24,
              height: 24,
            ),
          ),
        ),
        title: const Text(
          "Sort Bill",
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      // THE KEY FIX: SingleChildScrollView + Padding
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Smooth iOS feel
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pay Now",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              "Type amount you want to pay",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),

            // Amount Field
            TextField(
              controller: donorController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Image.asset(
                    'assets/images/naira.png',
                    width: 24,
                    height: 24,
                    color: Color.fromARGB(
                      255,
                      11,
                      87,
                      84,
                    ), // Optional: tint if needed
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                hintText: "0.00",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 18),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFD0F8F6),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF007A74),
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Select Payment Method",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF979696),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),

            // Paystack
            _buildPaymentRow(
              image: 'assets/images/paystack.png',
              title: 'Paystack',
              onTap: () => _showSnack("Paystack Selected"),
            ),
            const Divider(
              height: 1,
              thickness: 0.7,
              color: Color(0xFFE0E0E0),
              endIndent: 44,
            ),

            // GreyFundr Wallet
            _buildPaymentRow(
              image: 'assets/images/greyfundrpay.png',
              title: 'GreyFundr Wallet',
              onTap: () => _showSnack("GreyFundr Wallet Selected"),
            ),
            const Divider(
              height: 1,
              thickness: 0.7,
              color: Color(0xFFE0E0E0),
              endIndent: 44,
            ),

            const SizedBox(height: 16),

            // Split Bill
            // _buildActionCard(
            //   title: "Split Bill",
            //   subtitle: "Share this bill with friends",
            //   imageAsset: "assets/images/split_bill_icon.png",
            //   backgroundColor: Colors.orange.shade600,
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => SplitBillScreenUpdate()),
            //     );
            //   },
            // ),

            // Champion
            _buildActionCard(
              title: "Become a Champion",
              subtitle: "Top the donor list & get featured",
              imageAsset: "assets/images/champion_icon.png",
              backgroundColor: const Color(0xFFFFD700), // Gold
              onTap: () => _showSnack("Champion mode activated"),
            ),

            // Transfer Bill
            _buildActionCard(
              title: "Transfer Bill",
              subtitle: "Send this bill to someone else",
              imageAsset: "assets/images/transfer_bill_icon.png",
              backgroundColor: Colors.purple.shade600,
              onTap: () => _showSnack("Transfer Bill selected"),
            ),

            // Pay Later
            _buildActionCard(
              title: "Pay Later",
              subtitle: "Save this bill & pay anytime",
              imageAsset: "assets/images/pay_later_icon.png",
              backgroundColor: Colors.grey.shade700,
              onTap: () => _showSnack("Bill saved for later"),
            ),
            // Extra bottom padding so last item isn't stuck to edge
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // PERFECTLY ALIGNED + SMALL LEFT PADDING FOR PAYSTACK & GREYFUNDR
  Widget _buildPaymentRow({
    required String image,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      splashColor: const Color(0xFF007A74).withOpacity(0.3),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            const SizedBox(
              width: 12,
            ), // ← THIS IS THE MAGIC: small left padding
            // Circular Icon - now slightly indented
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFF007A74).withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: ClipOval(
                  child: Image.asset(
                    image,
                    fit: BoxFit.contain,
                    width: 36,
                    height: 36,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FINAL VERSION: All action cards use custom PNG images
  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required String imageAsset, // ← Now REQUIRED (custom image)
    required Color backgroundColor, // Color for the icon background
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: backgroundColor.withOpacity(0.25),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Custom Image with colored background
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: backgroundColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Image.asset(
                    imageAsset,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    // Optional: tint the image if it's white/gray
                    // color: backgroundColor,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF007A74),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
