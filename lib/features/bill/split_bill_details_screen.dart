import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_network_image copy.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/core/models/split_bill_details_model.dart';
import 'package:greyfundr/core/providers/socket_provider.dart';
import 'package:greyfundr/features/bill/sort_bill_bottom_sheet.dart';
import 'package:greyfundr/features/bill/split_bill_comments_sheet.dart';
import 'package:greyfundr/features/bill/split_notification_page.dart';
import 'package:greyfundr/features/new_split_bill/edit_split_bill_screen.dart';
import 'package:greyfundr/features/new_split_bill/split_bill_provider.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
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
  final ScrollController _pageScrollController = ScrollController();

  SocketProvider? _socketProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NewSplitBillProvider>(
        context,
        listen: false,
      );
      provider.getSplitBillDetails(splitBillId: widget.billId);
      _socketProvider = Provider.of<SocketProvider>(context, listen: false);
      _socketProvider?.subscribe('bill', widget.billId, () {
        provider.getSplitBillDetails(splitBillId: widget.billId);
      });
    });
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    _socketProvider?.unsubscribe('bill', widget.billId);
    super.dispose();
  }

  void _scrollPageToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_pageScrollController.hasClients) return;
      _pageScrollController.animateTo(
        _pageScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
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

    final totalParticipants = data.participants?.length ?? 0;
    final paidParticipants =
        data.participants
            ?.where((p) => p.status?.toLowerCase() == 'paid')
            .length ??
        0;
    final isSettled =
        totalParticipants > 0 && paidParticipants >= totalParticipants;
    final hasUnpaidParticipants =
        totalParticipants > 0 && paidParticipants < totalParticipants;

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
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

      controller: _pageScrollController,
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
                        fit: BoxFit.cover,
                        padding: 0,
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
                      if (isCreator && !isSettled)
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
                      if(isCreator && !isSettled)
                      InkWell(
                        onTap: () => Get.to(
                          SplitNotificationPage(billId: widget.billId),
                          transition: Transition.rightToLeft,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(
                              0xFF007A74,
                            ).withValues(alpha: 0.08),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Color(0xFF007A74),
                            size: 20,
                          ),
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
            child: _buildTabBar(totalParticipants),
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
              hasUnpaidParticipants,
            ),
          ),

          // Button
          if (!isSettled)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: _buildActionButton(
                context,
                isCreator,
                myShare,
                widget.billId,
                data.minPaymentAmount?.toString(),
                double.tryParse(myShare?.amountRemaining?.toString() ?? "0"),
                data.allowPartialPayment ?? false,
                data.title,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar(int participantCount) {
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
              if (tab == 'COMMENTS') {
                _scrollPageToBottom();
              }
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tab,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                        ),
                        if (tab == 'PARTICIPANT') ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$participantCount',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
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
    bool hasUnpaidParticipants,
  ) {
    switch (tab) {
      case 'ABOUT':
        return _buildAboutTab(data);
      case 'OFFERS':
        return _buildOffersTab();
      case 'PARTICIPANT':
        return _buildParticipantTab(
          context,
          data,
          isCreator,
          hasUnpaidParticipants,
        );
      case 'COMMENTS':
        return _buildCommentsTab(myShare);
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

  Widget _buildParticipantTab(
    BuildContext context,
    Data data,
    bool isCreator,
    bool hasUnpaidParticipants,
  ) {
    final participants = data.participants ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCreator && hasUnpaidParticipants) ...[
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

  Widget _buildCommentsTab(Participant? myShare) {
    return SplitBillCommentsView(
      billId: widget.billId,
      participantId: myShare?.id,
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
    final amountOwed = (p.amountOwed ?? 0).toDouble();
    final amountPaid = double.tryParse(p.amountPaid?.toString() ?? '0') ?? 0;
    final progress = amountOwed > 0
        ? (amountPaid / amountOwed).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          p.user?.image?.isNotEmpty ?? false
              ? CustomNetworkImage(imageUrl: p.user?.image ?? "", radius: 56)
              : Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF007A74).withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'G',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF007A74),
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Gap(5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₦${formatter.format(amountPaid)} Funded of ₦${formatter.format(amountOwed)}',
                  style: txStyle13,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF007A74),
                    ),
                  ),
                ),
              ],
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
    bool allowPartialPayment,
    String? billTitle,
  ) {
    final hasPaid = myShare?.status?.toLowerCase() == 'paid';
    final amountOwed =
        double.tryParse(myShare?.amountOwed.toString() ?? "0") ?? 0;
    final remaining = amountRemaining ?? 0;

    return Row(
      children: [
        if (isCreator)
          Expanded(
            child: CustomButton(
              height: 45,
              backgroundColor: appSecondaryColor,
              borderColor: appSecondaryColor,
              onTap: () {
                Get.to(EditSplitBillScreen(billId: widget.billId));
              },
              label: "Mange",
            ),
          ),
        Gap(10),
        if (!hasPaid)
          Expanded(
            child: CustomButton(
              onTap: () {
                if (hasPaid) return;
                showSortBillBottomSheet(
                  context: context,
                  billId: "$billId",
                  participantId: "${myShare?.id}",
                  amountOwed: amountOwed,
                  amountRemaining: remaining,
                  minPaymentAmount:
                      double.tryParse(minimumPaymentAmount ?? "0") ?? 0,
                  allowPartialPayment: allowPartialPayment,
                  billTitle: billTitle,
                );
              },
              height: 45,
              label: hasPaid ? 'PAID' : 'SORT BILL',
              backgroundColor: hasPaid
                  ? Colors.green.shade600
                  : const Color(0xFF007A74),
              borderColor: hasPaid
                  ? Colors.green.shade600
                  : const Color(0xFF007A74),
              enabled: true,
              icon: hasPaid
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}
