import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:greyfundr/core/models/campaign_model.dart';
import 'package:provider/provider.dart';
import 'package:greyfundr/core/providers/campaign_provider.dart';
import 'package:greyfundr/features/home/home_screen.dart';

class CampaignApprovalPage extends StatefulWidget {
  final Campaign campaign;

  const CampaignApprovalPage({
    super.key,
    required this.campaign,
  });

  @override
  State<CampaignApprovalPage> createState() => _CampaignApprovalPageState();
}

class _CampaignApprovalPageState extends State<CampaignApprovalPage> {
  Map<String, dynamic>? currentUser;
  int campaignId = 0;
  bool isApproved = false;
  int stakeholdersApproved = 0;
  int totalStakeholders = 0;

  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndCreateCampaign();
    _startPollingApprovalStatus();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentUserAndCreateCampaign() async {
    try {
      final campaignProvider = Provider.of<CampaignProvider>(context, listen: false);
      final decodedProfile = await campaignProvider.fetchCurrentUserProfile();

      if (decodedProfile != null && mounted) {
        setState(() {
          currentUser = decodedProfile['data'] as Map<String, dynamic>? ??
              decodedProfile['user'] as Map<String, dynamic>? ??
              decodedProfile;
        });
      }

      if (currentUser != null && currentUser!['id'] != null && mounted) {
        await _createCampaign(currentUser!['id']);
      }
    } catch (e) {
      debugPrint('Error loading user or creating campaign: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize: $e')),
        );
      }
    }
  }

  Future<void> _createCampaign(dynamic userId) async {
    try {
      final campaignProvider = Provider.of<CampaignProvider>(context, listen: false);
      final decoded = await campaignProvider.createCampaign(widget.campaign, userId.toString());
      print('CampaignApprovalPage._createCampaign -> provider returned: $decoded');

      if (decoded != null && decoded['id'] != null && mounted) {
        setState(() {
          campaignId = int.tryParse(decoded['id'].toString()) ?? 0;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Campaign saved successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('CampaignApprovalPage._createCampaign -> unexpected create response: $decoded');
      }
    } catch (e) {
      debugPrint('Campaign creation failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save campaign: $e')),
        );
      }
    }
  }

  Future<void> _pollCampaignApproval() async {
  if (campaignId == 0 || !mounted) return;

    try {
      final campaignProvider = Provider.of<CampaignProvider>(context, listen: false);
      final decoded = await campaignProvider.getCampaignApproval(campaignId.toString());

    if (decoded == null || !mounted) return;

    // Assume list with at least one item (your original behavior)
    if (decoded is! List || decoded.isEmpty) {
      debugPrint("Warning: approval response is not a list or is empty");
      return;
    }

    final item = decoded[0];
    if (item is! Map<String, dynamic>) {
      debugPrint("Warning: first item is not a map");
      return;
    }

    final champions     = int.tryParse(item['champions']?.toString() ?? '0') ?? 0;
    final hosts         = int.tryParse(item['host']?.toString() ?? '0')     ?? 0;
    final approved      = int.tryParse(item['approved']?.toString() ?? '0') ?? 0;
    final totalApproved = int.tryParse(item['total_approved']?.toString() ?? '0') ?? 0;

    final waiting = champions + hosts;

    setState(() {
      totalStakeholders    = waiting;
      stakeholdersApproved = totalApproved;
      isApproved           = approved == 1;
    });

    if (isApproved && waiting > 0 && totalApproved >= waiting) {
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
    debugPrint("Polling error: $e");
  }
}

  void _startPollingApprovalStatus() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) _pollCampaignApproval();
    });

    // Initial check
    _pollCampaignApproval();
  }

  Map<String, dynamic>? _parseResponse(dynamic response) {
    try {
      if (response is String) {
        return jsonDecode(response) as Map<String, dynamic>?;
      }
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      debugPrint('Response parsing error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool campaignLive =
        isApproved && totalStakeholders > 0 && stakeholdersApproved >= totalStakeholders;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildStatusHeader(campaignLive),
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
                    stakeholdersApproved >= totalStakeholders,
                    trailing: Text(
                      '$stakeholdersApproved/$totalStakeholders',
                      style: const TextStyle(
                        color: Color(0xFF00ACC1),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStepItem(
                    campaignLive ? 'Hurray! Your Campaign is LIVE' : 'Awaiting approval from Greyfundr',
                    campaignLive,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            CustomPaint(
              size: const Size(double.infinity, 60),
              painter: WavePainter(campaignLive),
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
                    isActive: campaignLive,
                    onTap: () {
                      final link =
                          'https://back-end-z3es.onrender.com/api/v1/campaigns/${widget.campaign.sharetitle ?? ''}';
                      Clipboard.setData(ClipboardData(text: link));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied to clipboard')),
                      );
                    },
                  ),
                  // ← Add more action buttons here if needed
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00ACC1),
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

  Widget _buildStatusHeader(bool campaignLive) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: campaignLive ? const Color(0xFFE0F7FA) : const Color(0xFFF5F5F5),
            shape: BoxShape.circle,
          ),
          child: campaignLive
              ? const Icon(Icons.check, size: 30, color: Color(0xFFB0BEC5))
              : const Icon(Icons.schedule, size: 30, color: Color(0xFFB0BEC5)),
        ),
        const SizedBox(height: 16),
        Text(
          campaignLive ? 'Campaign Approved' : 'Pending Approval',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: campaignLive ? const Color(0xFF00ACC1) : Colors.black87,
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
            color: isCompleted ? const Color(0xFF00ACC1) : const Color(0xFFE0E0E0),
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
        ?trailing,
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
              color: isActive ? const Color(0xFF00ACC1) : const Color(0xFFBDBDBD),
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

class WavePainter extends CustomPainter {
  final bool isActive;

  WavePainter(this.isActive);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive ? const Color(0xFF00ACC1) : const Color(0xFFBDBDBD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.5, 0, size.width, size.height * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => isActive != oldDelegate.isActive;
}