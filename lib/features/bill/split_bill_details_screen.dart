import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_network_image copy.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/core/models/split_bill_details_model.dart';
import 'package:greyfundr/features/bill/bill_payment_method_screen.dart';
import 'package:greyfundr/features/new_split_bill/edit_split_bill_screen.dart';
import 'package:greyfundr/features/new_split_bill/split_bill_provider.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SplitBillDetailsScreen extends StatefulWidget {
  final String billId;

  const SplitBillDetailsScreen({super.key, required this.billId});

  @override
  State<SplitBillDetailsScreen> createState() => _SplitBillDetailsScreenState();
}

class _SplitBillDetailsScreenState extends State<SplitBillDetailsScreen> {
  String selectedTab = 'ABOUT';
  final formatter = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NewSplitBillProvider>(
        context,
        listen: false,
      );
      provider.getSplitBillDetails(splitBillId: widget.billId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NewSplitBillProvider>(context);
    final currentUserId = UserLocalStorageService().getUserData()?.id;
    final isCreator =
        provider.splitBillDetails?.data?.creatorId == currentUserId;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveState(
        state: provider.splitBillDetailsState,
        busyWidget: UiBusyWidget(),
        successWidget: SafeArea(
          top: false,
          child: _buildContent(
            context,
            provider.splitBillDetails,
            isCreator,
            currentUserId,
          ),
        ),
        errorWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load bill details'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  provider.getSplitBillDetails(splitBillId: widget.billId);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SplitBillDetailsModel? model,
    bool isCreator,
    String? currentUserId,
  ) {
    if (model?.data == null) {
      return const Center(child: Text('No data available'));
    }

    final data = model!.data!;
    final totalAmount = data.totalAmount ?? 0;
    final totalCollected = data.totalCollected ?? 0;

    final collectedPercent = totalAmount > 0
        ? totalCollected / totalAmount
        : 0.0;

    // Find current user's share
    final myShare = data.participants?.firstWhereOrNull(
      (p) => p.userId == currentUserId,
    );

    // Find the creator
    final creator = data.participants?.firstWhereOrNull(
      (p) => p.role?.toLowerCase() == 'creator',
    );

    final creatorName =
        creator?.user?.firstName ?? creator?.guestName ?? 'Creator';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Image Section
          Stack(
            children: [
              Container(
                height: SizeConfig.heightOf(35),
                width: double.infinity,
                color: Colors.grey[200],
                child: data.imageUrl != null && data.imageUrl!.isNotEmpty
                    ? CustomNetworkImageSqr(
                        imageUrl: data.imageUrl ?? "",
                        height: SizeConfig.heightOf(35),
                        width: double.infinity,
                      )
                    : const Center(
                        child: Icon(Icons.image, size: 64, color: Colors.grey),
                      ),
              ),
              // Gradient Overlay
              Container(
                height: SizeConfig.heightOf(35),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.6),
                      Colors.white,
                    ],
                  ),
                ),
              ),
              // Header Actions
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.widthOf(4),
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                            size: 22,
                          ),
                        ),
                      ),
                      if (isCreator)
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(
                                  EditSplitBillScreen(billId: widget.billId),
                                );
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.black87,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Progress bars (Paid + Accepted)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  data.title ?? 'Untitled Bill',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Amount info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₦${formatter.format(totalAmount)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF007A74),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Due Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.dueDate != null
                              ? DateFormat('MMM dd, yyyy').format(data.dueDate!)
                              : 'N/A',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Creator Info
                if (creator != null) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      creator.user?.image?.isNotEmpty ?? false
                          ? CustomNetworkImage(
                              imageUrl: creator.user?.image ?? "",
                              radius: 40,
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(
                                  0xFF007A74,
                                ).withValues(alpha: 0.1),
                              ),
                              child: Center(
                                child: Text(
                                  creatorName.isNotEmpty
                                      ? creatorName[0].toUpperCase()
                                      : 'C',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF007A74),
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Created By',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              creatorName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),

                // Collected progress
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF007A74).withValues(alpha: 0.16),
                        const Color(0xFF007A74).withValues(alpha: 0.08),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF007A74).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Amount Collected Progress',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${(collectedPercent * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF007A74),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: LinearProgressIndicator(
                          minHeight: 9,
                          value: collectedPercent.clamp(0.0, 1.0),
                          backgroundColor: Colors.white,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF007A74),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Raised: ₦${formatter.format(totalCollected)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Target: ₦${formatter.format(totalAmount)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: _buildTabBar(),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: _buildTabContent(
              context,
              selectedTab,
              data,
              isCreator,
              currentUserId,
              myShare,
            ),
          ),

          // Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: _buildActionButton(
              context,
              isCreator,
              myShare,
              widget.billId,
              data.minPaymentAmount?.toString(),
              double.tryParse(myShare?.amountRemaining?.toString() ?? "0"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['ABOUT', 'OFFERS', 'PARTICIPANT', 'COMMENTS'];
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: tabs.map((tab) {
          final isSelected = selectedTab == tab;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTab = tab;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSelected ? 4 : 0),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xff8e96a399) : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    String tab,
    Data data,
    bool isCreator,
    String? currentUserId,
    Participant? myShare,
  ) {
    switch (tab) {
      case 'ABOUT':
        return _buildAboutTab(data);
      case 'OFFERS':
        return _buildOffersTab();
      case 'PARTICIPANT':
        return _buildParticipantTab(context, data, isCreator);
      case 'COMMENTS':
        return _buildCommentsTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildAboutTab(Data data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data.description ?? 'No description provided',
          style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5),
        ),
        const SizedBox(height: 24),
        _buildInfoRow('Split Method', data.splitMethod ?? 'N/A'),
        _buildInfoRow('Status', data.status ?? 'N/A'),
        _buildInfoRow(
          'Total Collected',
          '₦${formatter.format(data.totalCollected ?? 0)}',
        ),
        _buildInfoRow(
          'Remaining',
          '₦${formatter.format((data.totalAmount ?? 0) - (data.totalCollected ?? 0))}',
        ),
      ],
    );
  }

  Widget _buildOffersTab() {
    return Center(
      child: Text(
        'No offers available',
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildParticipantTab(BuildContext context, Data data, bool isCreator) {
    final participants = data.participants ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCreator) ...[
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF007A74).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF007A74).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: Color(0xFF007A74),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Remind participants who have not paid their share.',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Provider.of<NewSplitBillProvider>(
                      context,
                      listen: false,
                    ).sendSplitBillReminder(data.id ?? widget.billId);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007A74),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Remind',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (participants.isEmpty)
          Center(
            child: Text(
              'No participants',
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
        else
          ...participants.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildParticipantRow(p),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentsTab() {
    return Center(
      child: Text('No comments yet', style: TextStyle(color: Colors.grey[600])),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantRow(Participant p) {
    final name = p.user?.firstName ?? p.guestName ?? 'Guest';
    final amount = p.amountOwed ?? 0;
    final status = p.status?.toLowerCase() ?? 'pending';
    final isPaid = status == 'paid';
    final amountPaid = double.tryParse(p.amountPaid?.toString() ?? '0') ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          p.user?.image?.isNotEmpty ?? false
              ? CustomNetworkImage(
                  imageUrl: p.user?.image ?? "",
                  radius: 40,
                )
              : Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF007A74).withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF007A74),
                      ),
                    ),
                  ),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                if (!isPaid)
                  Text(
                    '₦${formatter.format(amount)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      // decoration: (amountPaid > 0 && !isPaid) ? TextDecoration.lineThrough : null,
                    ),
                  ),
                if (amountPaid > 0) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Paid: ₦${formatter.format(amountPaid)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF007A74),
                        ),
                      ),
                      if (!isPaid) ...[
                        const SizedBox(width: 6),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '₦${formatter.format(amount - amountPaid)} left',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isPaid
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isPaid ? 'Paid' : capitalizeFirstText(status),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isPaid ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    bool isCreator,
    Participant? myShare,
    String? billId,
    String? minimumPaymentAmount,
    double? amountRemaining,
  ) {
    final hasPaid = myShare?.status?.toLowerCase() == 'paid';

    if (isCreator) {
      // return CustomButton(
      //   onTap: () {
      //     showSuccessToast('Manage split feature coming soon');
      //   },
      //   height: 52,
      //   label: 'MANAGE SPLIT',
      //   backgroundColor: const Color(0xFF007A74),
      //   borderColor: const Color(0xFF007A74),
      //   enabled: true,
      // );
      return const SizedBox();
    } else {
      return CustomButton(
        onTap: () {
          if (hasPaid) return;
          // showSuccessToast('Proceeding to payment');
          Get.to(
            BillPaymentMethodScreen(
              participantId: "${myShare?.id}",
              billID: "${billId}",
              minPaymentAmount:
                  double.tryParse(minimumPaymentAmount ?? "0") ?? 0,
              payingRemainingAmount:
                  (amountRemaining != null && amountRemaining > 0)
                  ? true
                  : false,
              amount: (amountRemaining != null && amountRemaining > 0)
                  ? amountRemaining
                  : (double.tryParse(myShare?.amountOwed.toString() ?? "0") ??
                        0),
            ),
            transition: Transition.rightToLeft,
          );
        },
        height: 52,
        label: hasPaid ? 'PAID' : 'SORT BILL',
        backgroundColor: hasPaid
            ? Colors.green.shade600
            : const Color(0xFF007A74),
        borderColor: hasPaid ? Colors.green.shade600 : const Color(0xFF007A74),
        enabled: true,
        icon: hasPaid
            ? const Icon(Icons.check_circle, color: Colors.white, size: 20)
            : null,
      );
    }
  }
}
