import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:greyfundr/core/api/auth_api/auth_api.dart';
import 'package:greyfundr/core/api/auth_api/auth_api_impl.dart';
import 'package:greyfundr/features/bill/pathsforbill/sboscreen.dart';
import 'package:greyfundr/core/models/split_bill_model.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/shared/notification.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/core/providers/wallet_provider.dart';
import 'package:greyfundr/features/home/add_money_sheet.dart';
import 'package:gap/gap.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/features/settings/settings_screen.dart';
import 'package:greyfundr/features/splitbill/split_bill_screen.dart';
import 'package:greyfundr/features/charity/charity_screen.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:greyfundr/services/custom_alert.dart';
import 'package:provider/provider.dart';
import 'package:get/route_manager.dart';



class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

// Concave clipper (unchanged)
class ConcaveBottomClipper extends CustomClipper<Path> {
  final double depth;

  const ConcaveBottomClipper({this.depth = 30});

  

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - depth)
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height,
        size.width * 0.5,
        size.height - 0,
      )
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height,
        0,
        size.height - depth,
      )
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _BillScreenState extends State<BillScreen> {
  final AuthApi _authApi = AuthApiImpl();

  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = true;
  double _previousScrollOffset = 0.0;
  bool _isBalanceVisible = true;

  List<SplitBill> _splitBills = [];
  bool _isLoading = false;
  String? _errorMessage;

  String selectedTab = 'Bill';

  // For Sort Bill modal
  final TextEditingController donorController = TextEditingController();
  String? nickname;
  String? donorName;
  String? comment;

  late UserProvider _userProvider; 

   Widget _billSummaryColumn(String label, String amount) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      Text(amount, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    ],
  );
}

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _scrollController.addListener(_scrollListener);
    _fetchSplitBills();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    donorController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final currentOffset = _scrollController.offset;
    final delta = currentOffset - _previousScrollOffset;

    if (delta.abs() < 5) {
      _previousScrollOffset = currentOffset;
      return;
    }

    const double threshold = 30.0;

    if (delta > 0 && currentOffset > threshold) {
      if (!_isHeaderCollapsed) setState(() => _isHeaderCollapsed = true);
    } else if (delta < 0 && currentOffset < 100) {
      if (_isHeaderCollapsed) setState(() => _isHeaderCollapsed = false);
    }

    _previousScrollOffset = currentOffset;
  }

  Future<void> _fetchSplitBills() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bills = await _authApi.getMySplitBills();

      if (mounted) {
        setState(() {
          _splitBills = bills;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load bills";
          _isLoading = false;
        });
      }
    }
  }

  String formatAmount(dynamic amount) {
    final numValue = int.tryParse(amount.toString()) ?? 0;
    return NumberFormat("#,###").format(numValue);
  }

  final formatter = NumberFormat('#,##0.00');

  Widget _headerTabButton(String title, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (title == 'Charity') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CharityScreen()),
          );
        } else if (title == 'Lifestyle') {
          // Add lifestyle screen later if needed
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: isActive ? 15 : 13,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 3,
              width: isActive ? 24 : 16,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSortBillModal(SplitBill bill) {
  donorController.clear();
  nickname = null;
  donorName = null;
  comment = null;

  final currentUserId = _userProvider.userProfileModel?.id ?? '';

  // Find this user's participation
  final participant = bill.participants.firstWhere(
    (p) => p.userId == currentUserId,
    orElse: () => Participant(
      id: 'fallback_${DateTime.now().millisecondsSinceEpoch}',  // or just ''
      inviteCode: '',
      amountOwed: 0.0,
      amountPaid: 0.0,
      paid: false,
      status: 'UNKNOWN',
      // guestName: null,
      // guestPhone: null,
      // ... match your actual required fields
    ),
  );

  final progress = bill.amount > 0 ? bill.amountRaised / bill.amount : 0.0;
  final remainingAmount = participant.amountOwed - bill.amountRaised;

    final formattedPaid = formatter.format(bill.amountRaised);
    final formattedTotal = formatter.format(bill.amount);
    final formattedOwed = formatter.format(participant.amountOwed);
    final formattedRemaining = formatter.format(remainingAmount);

    final championsCount = bill.participants.where((p) => p.paid).length;
    final backersCount = bill.participants.where((p) => p.amountPaid > 0).length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, modalSetState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.92,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 48,
                    height: 6,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    bill.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Progress Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                            children: [
                              TextSpan(
                                text: formattedPaid,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              const TextSpan(text: " raised of "),
                              TextSpan(
                                text: formattedOwed,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007A74)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.people, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  "${bill.totalParticipants} Split${bill.totalParticipants == 1 ? '' : 's'}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Support text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "You are supporting ${bill.title}. Your donation will help reach the goal.",
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
                const SizedBox(height: 24),

                // Amount input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: donorController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: "Enter Amount",
                      labelStyle: const TextStyle(color: Colors.grey),
                      helperText: remainingAmount > 0 ? "Max: ₦${formattedRemaining}" : null,
                      helperStyle: const TextStyle(color: Color(0xFF007A74), fontSize: 12),
                      prefixText: "₦ ",
                      prefixStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Optional fields (nickname, on behalf of, comment)
                _buildOptionRow(
                  iconPath: "assets/images/add-circle.png",
                  defaultText: "Use my Nickname or Be Anonymous",
                  value: nickname,
                  onTap: () => _showInputDialog(
                    title: "Enter Nickname",
                    hint: "e.g. Davido",
                    controller: TextEditingController(text: nickname ?? ""),
                    onSave: (val) => setState(() => nickname = val.isEmpty ? null : val),
                  ),
                  onDelete: () => setState(() => nickname = null),
                ),

                _buildOptionRow(
                  iconPath: "assets/images/add-circle.png",
                  defaultText: "Donating On Behalf Of",
                  value: donorName,
                  onTap: () => _showInputDialog(
                    title: "Donating On Behalf Of",
                    hint: "e.g. My Mom, Church, Team",
                    controller: TextEditingController(text: donorName ?? ""),
                    onSave: (val) => setState(() => donorName = val.isEmpty ? null : val),
                  ),
                  onDelete: () => setState(() => donorName = null),
                ),

                _buildOptionRow(
                  iconPath: "assets/images/add-circle.png",
                  defaultText: "Add Comment",
                  value: comment,
                  onTap: () => _showInputDialog(
                    title: "Add a Comment",
                    hint: "Your comment will appear publicly",
                    controller: TextEditingController(text: comment ?? ""),
                    maxLines: 3,
                    onSave: (val) => setState(() => comment = val.isEmpty ? null : val),
                  ),
                  onDelete: () => setState(() => comment = null),
                ),

                const SizedBox(height: 32),

                // Continue button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final amountText = donorController.text.trim();
                        if (amountText.isEmpty) return;

                        final amount = double.tryParse(amountText.replaceAll(',', ''));
                        if (amount == null || amount <= 0) return;

                        if (remainingAmount > 0 && amount > remainingAmount) {
                          CustomMessageModal.show(
                            context: context,
                            message: "Amount cannot exceed ₦${formattedRemaining}",
                            isSuccess: false,
                          );
                          return;
                        }

                        // Proceed to next screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SortBillOptionsScreen(
                              bill: bill,
                              amountToPay: amountText,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007A74),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionRow({
    required String iconPath,
    required String defaultText,
    required String? value,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    final hasValue = value != null && value.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: InkWell(
        onTap: hasValue ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: hasValue ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              if (hasValue)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
                )
              else
                Image.asset(iconPath, width: 24, height: 24, color: const Color(0xFF007A74)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  hasValue ? value! : defaultText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showInputDialog({
    required String title,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    required Function(String) onSave,
  }) async {
    controller.clear();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) onSave(val);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _featureIcon(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: txStyle12.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildBillCard({
    required SplitBill bill,
    required String title,
    required String timeLeft,
    required String amountPaid,
    required String totalAmount,
    required double progress,
    required String remainingAmount,
    required String splits,
    required String champions,
    required String backers,
    required String progressPercent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
  children: [

  CustomNetworkImage(imageUrl: "imageUrl", radius: 40),


    const SizedBox(width: 12),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                timeLeft,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    ),
    ElevatedButton(
      onPressed: () => showSortBillModal(bill),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF007A74),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: const Text("Sort Bill", style: TextStyle(fontSize: 13)),
    ),
  ],
),




          const SizedBox(height: 16),
          Text(
            "$amountPaid paid of $totalAmount",
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007A74)),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      progressPercent,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.people_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(splits, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(width: 16),
                  Icon(Icons.emoji_events_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(champions, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(width: 16),
                  Icon(Icons.favorite_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(backers, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
              Text(
                remainingAmount,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    var userProfile = userProvider.userProfileModel;
    var walletModel = walletProvider.walletModel;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Animated Header
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: double.infinity,
              height: _isHeaderCollapsed ? 170 : 300,
              child: ClipPath(
                clipper: const ConcaveBottomClipper(depth: 30),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF007A74), Color(0xFF1D2D2C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Top Bar
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_isHeaderCollapsed)
                                Row(
                                  children: [
                                       CustomOnTap(
                  onTap: () {
                    Get.to(
                      SettingsScreen(),
                      transition: Transition.rightToLeft,
                    );
                  },
                  child: Row(
                    children: [
                      CustomNetworkImage(imageUrl: "imageUrl", radius: 40),
                      Gap(5),
                     
                    ],
                  ),
                ),
                      Gap(10),

                                    _headerTabButton('Bill', true),
                                    _headerTabButton('Charity', false),
                                    _headerTabButton('Lifestyle', false),
                                    Gap(10),

                                        CustomOnTap(
                  onTap: () {
                    Get.to(
                      NotificationScreen(),
                      // transition: Transition.rightToLeft,
                    );
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/svgs/notification.svg"),
                      Gap(5),
                     
                    ],
                  ),
                ),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                  
                                   CustomOnTap(
                  onTap: () {
                    Get.to(
                      SettingsScreen(),
                      transition: Transition.rightToLeft,
                    );
                  },
                  child: Row(
                    children: [
                      CustomNetworkImage(imageUrl: "imageUrl", radius: 40),
                      Gap(5),
                     
                    ],
                  ),
                ),
                                   
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Hello!", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                        Text(
                            "${userProfile?.firstName} ${userProfile?.lastName}",
                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              Row(
                                children: [
                                  CustomOnTap(
                  onTap: () {
                    Get.to(
                      NotificationScreen(),
                      // transition: Transition.rightToLeft,
                    );
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/svgs/notification.svg"),
                      Gap(5),
                     
                    ],
                  ),
                ),
                                   
                                ],
                              ),
                            ],
                          ),

                        ),
                      ),

                      // Collapsible Section
                      AnimatedOpacity(
                        opacity: _isHeaderCollapsed ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Offstage(
                          offstage: _isHeaderCollapsed,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 70, left: 20, right: 20),
                            child: Column(
                              children: [
                                // Points + Trophy
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text("Total Point", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                        Text("0Pts", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                        Text("10 points to your next star", style: TextStyle(color: Colors.white70, fontSize: 10)),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: Image.asset('assets/images/trophy.png', width: 40, height: 40),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(color: Colors.white24, height: 24),

                                // Balance + Add Money
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Total Balance", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                        Row(
                                          children: [
                                            Text(
                                              _isBalanceVisible ? "₦0.00" : "••••••",
                                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 12),
                                            GestureDetector(
                                              onTap: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                                              child: Icon(
                                                _isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                                color: Colors.white70,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "You owe: ₦0.00",
                                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    InkWell(
                    onTap: () {
                      showCustomBottomSheet(AddMoneySheet(), context);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/svgs/add_money.svg",
                          height: 30,
                        ),
                        Text("Add Money", style: txStyle12wt),
                      ],
                    ),
                  ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Total Bills + Create Button
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        top: _isHeaderCollapsed ? 60 : 200,
                        left: 20,
                        right: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Total Bills", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                const Text("₦0.00", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                Row(
                                  children: [
                                    _billSummaryColumn("Champion", "₦0.00"),
                                    const SizedBox(width: 24),
                                    _billSummaryColumn("Split", "₦0.00"),
                                    const SizedBox(width: 24),
                                    _billSummaryColumn("Backed", "₦0.00"),
                                  ],
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SplitBillScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B35),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("Create Bill", style: TextStyle(fontSize: 14)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Feature Icons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _featureIcon("Pay Bill", Icons.receipt, Colors.amber),
                  _featureIcon("Transfer Bill", Icons.swap_horiz, Colors.pink),
                  _featureIcon("Split Bill", Icons.call_split, Colors.green),
                  _featureIcon("Request Bill", Icons.request_page, Colors.orange),
                  _featureIcon("Scan Bill", Icons.qr_code_scanner, Colors.blue),
                ],
              ),
            ),

            // Collapsible Horizontal Bills
            AnimatedOpacity(
              opacity: _isHeaderCollapsed ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 400),
              child: AnimatedSlide(
                offset: _isHeaderCollapsed ? const Offset(0, -0.5) : Offset.zero,
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOut,
                child: Offstage(
                  offstage: _isHeaderCollapsed,
                  child: SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _horizontalBillCard(
                          name: "Hip Replacement",
                          subtitle: "Angel needs hip replacement",
                          amount: "24 million naira",
                        ),
                        _horizontalBillCard(
                          name: "Sandra's Wedding",
                          subtitle: "My Wedding is coming soon",
                          amount: "85 million",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Tab Selector
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedTab = 'Bill'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedTab == 'Bill' ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Bill",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: selectedTab == 'Bill' ? FontWeight.bold : FontWeight.normal,
                            color: selectedTab == 'Bill' ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedTab = 'Request'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedTab == 'Request' ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Request",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: selectedTab == 'Request' ? FontWeight.bold : FontWeight.normal,
                            color: selectedTab == 'Request' ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedTab = 'History'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedTab == 'History' ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "History",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: selectedTab == 'History' ? FontWeight.bold : FontWeight.normal,
                            color: selectedTab == 'History' ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bills List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchSplitBills,
                color: const Color(0xFF007A74),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _splitBills.isEmpty
                        ? const Center(child: Text("No split bills found", style: TextStyle(fontSize: 16, color: Colors.grey)))
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _splitBills.length,
                            itemBuilder: (context, index) {
                              final bill = _splitBills[index];
                              final progress = bill.amount > 0 ? bill.amountRaised / bill.amount : 0.0;

                              final daysLeft = bill.dueDate.difference(DateTime.now()).inDays;
                              final timeLeft = daysLeft > 0 ? "$daysLeft Day${daysLeft == 1 ? '' : 's'} left" : "Overdue";

                              final paidFormatted = formatter.format(bill.amountRaised);
                              final totalFormatted = formatter.format(bill.amount);
                              final remaining = bill.amount - bill.amountRaised;
                              final remainingFormatted = formatter.format(remaining);

                              final championsCount = bill.participants.where((p) => p.paid).length;
                              final backersCount = bill.participants.where((p) => p.amountPaid > 0).length;

                              return _buildBillCard(
                                bill: bill,
                                title: bill.title,
                                timeLeft: timeLeft,
                                amountPaid: paidFormatted,
                                totalAmount: totalFormatted,
                                progress: progress,
                                remainingAmount: remainingFormatted,
                                splits: "${bill.totalParticipants} Split${bill.totalParticipants == 1 ? '' : 's'}",
                                champions: "$championsCount Champion${championsCount == 1 ? '' : 's'}",
                                backers: "$backersCount Backer${backersCount == 1 ? '' : 's'}",
                                progressPercent: "${(progress * 100).toInt()}%",
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
     
    );
  }
  Widget _horizontalBillCard({
    required String name,
    required String subtitle,
    required String amount,
  }) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 232, 232, 232),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
            
             CustomNetworkImage(imageUrl: "imageUrl", radius: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 26, 25, 25),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color.fromARGB(179, 121, 121, 121),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Color.fromARGB(179, 37, 60, 48),
                    fontSize: 9,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size(60, 30),
            ),
            child: const Text(
              "Sort Bill",
              style: TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}