import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:greyfundr/core/providers/campaign_provider.dart';
import 'package:greyfundr/features/home/home_screen.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:provider/provider.dart';

class CampaignApprovalPage extends StatefulWidget {
  final String campaignId;
  final String? shareTitle;

  const CampaignApprovalPage({
    super.key,
    required this.campaignId,
    this.shareTitle,
  });

  @override
  State<CampaignApprovalPage> createState() => _CampaignApprovalPageState();
}

class _CampaignApprovalPageState extends State<CampaignApprovalPage> {
  bool _isApproved = false;
  int _stakeholdersApproved = 0;
  int _totalStakeholders = 0;

  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollApprovalStatus();
    _pollingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) _pollApprovalStatus();
    });
  }

  Future<void> _pollApprovalStatus() async {
    if (widget.campaignId.isEmpty || !mounted) return;
    try {
      final provider = Provider.of<CampaignProvider>(context, listen: false);
      final decoded = await provider.getCampaignApproval(widget.campaignId);
      if (decoded == null || !mounted) return;
      if (decoded is! List || decoded.isEmpty) return;

      final item = decoded[0];
      if (item is! Map<String, dynamic>) return;

      final champions =
          int.tryParse(item['champions']?.toString() ?? '0') ?? 0;
      final hosts = int.tryParse(item['host']?.toString() ?? '0') ?? 0;
      final approved =
          int.tryParse(item['approved']?.toString() ?? '0') ?? 0;
      final totalApproved =
          int.tryParse(item['total_approved']?.toString() ?? '0') ?? 0;
      final waiting = champions + hosts;

      if (!mounted) return;
      setState(() {
        _totalStakeholders = waiting;
        _stakeholdersApproved = totalApproved;
        _isApproved = approved == 1;
      });

      if (_isApproved && waiting > 0 && totalApproved >= waiting) {
        _pollingTimer?.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Campaign fully approved → now LIVE!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Polling error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLive = _isApproved &&
        _totalStakeholders > 0 &&
        _stakeholdersApproved >= _totalStakeholders;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildStatusHeader(isLive),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepItem('Posted to your GreyFundr', true),
                  const SizedBox(height: 16),
                  _buildStepItem('Shared with team for review', true),
                  const SizedBox(height: 16),
                  _buildStepItem(
                    'Pending approval from Stakeholder(s)',
                    _stakeholdersApproved >= _totalStakeholders &&
                        _totalStakeholders > 0,
                    trailing: Text(
                      '$_stakeholdersApproved/$_totalStakeholders',
                      style: const TextStyle(
                        color: appPrimaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStepItem(
                    isLive
                        ? 'Hurray! Your Campaign is LIVE'
                        : 'Awaiting approval from Greyfundr',
                    isLive,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            CustomPaint(
              size: const Size(double.infinity, 60),
              painter: _WavePainter(isLive),
            ),
            Container(
              color: const Color.fromARGB(255, 255, 254, 254),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Champion Your Campaign with Others',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildActionButton(
                    icon: Icons.content_copy_rounded,
                    label: 'Copy Link',
                    isActive: isLive,
                    onTap: () {
                      final share = widget.shareTitle ?? widget.campaignId;
                      Clipboard.setData(ClipboardData(text: share));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link copied to clipboard'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () =>
                          Get.offAll(() => const HomeScreen()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Back to Donation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(bool isLive) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isLive
                ? const Color(0xFFE0F7FA)
                : const Color(0xFFF5F5F5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isLive ? Icons.check : Icons.schedule,
            size: 30,
            color: isLive ? appPrimaryColor : const Color(0xFFB0BEC5),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isLive ? 'Campaign Approved' : 'Pending Approval',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isLive ? appPrimaryColor : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(String text, bool isCompleted, {Widget? trailing}) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted ? appPrimaryColor : const Color(0xFFE0E0E0),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isCompleted ? Colors.black87 : Colors.grey,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isActive ? onTap : null,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive ? appPrimaryColor : const Color(0xFFBDBDBD),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.black87 : const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final bool isActive;
  _WavePainter(this.isActive);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive ? appPrimaryColor : const Color(0xFFBDBDBD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.5,
        0,
        size.width,
        size.height * 0.5,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      isActive != oldDelegate.isActive;
}
