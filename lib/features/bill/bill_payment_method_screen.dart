import 'package:greyfundr/components/custom_pin_input.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/providers/wallet_provider.dart';
import 'package:greyfundr/features/new_split_bill/split_bill_provider.dart';
import 'package:greyfundr/features/home/add_money_sheet.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:provider/provider.dart';

class BillPaymentMethodScreen extends StatefulWidget {
  final String participantId;
  final String billID;
  final double amount;
  final String? comment;
  final String? onBehalfOfParticipantId;

  const BillPaymentMethodScreen({
    super.key,
    required this.participantId,
    required this.billID,
    required this.amount,
    this.comment,
    this.onBehalfOfParticipantId,
  });

  @override
  State<BillPaymentMethodScreen> createState() =>
      _BillPaymentMethodScreenState();
}

class _BillPaymentMethodScreenState extends State<BillPaymentMethodScreen> {
  String _selectedPaymentMethod = 'wallet';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final walletProvider = Provider.of<WalletProvider>(
        context,
        listen: false,
      );
      walletProvider.fetchUserWallet();
    });
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(
      (value ?? '').toString().replaceAll(',', ''),
    );
    return parsed ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final newSplitBillProvider = Provider.of<NewSplitBillProvider>(context);

    final walletBalance = _toDouble(
      walletProvider.walletModel?.balance?.available,
    );

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F8FA),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        title: const Text(
          'Payment Method',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xffECECF2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount to Pay',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        convertStringToCurrency(widget.amount.toString()),
                        style: txStyle24SemiBold,
                      ),
                      if (widget.comment != null &&
                          widget.comment!.isNotEmpty) ...[
                        const Gap(10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xffF7F8FA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 14,
                                color: Colors.grey[700],
                              ),
                              const Gap(8),
                              Expanded(
                                child: Text(
                                  widget.comment!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[800],
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Gap(18),
                const Text(
                  'Choose Payment Method',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const Gap(10),
                _PaymentMethodTile(
                  title: 'Wallet',
                  subtitle: 'Pay instantly from GreyFundr wallet',
                  imagePath: 'assets/images/grey_wallet.png',
                  rightText:
                      'Bal: ${convertStringToCurrency(walletBalance.toStringAsFixed(0))}',
                  isSelected: _selectedPaymentMethod == 'wallet',
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = 'wallet';
                    });
                  },
                ),
                const Gap(10),
                _PaymentMethodTile(
                  title: 'Paystack',
                  subtitle: 'Card / Bank payment',
                  imagePath: 'assets/images/paystack.png',
                  rightText: '',
                  isSelected: _selectedPaymentMethod == 'paystack',
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = 'paystack';
                    });
                  },
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final amountToPay = widget.amount;
                      if (amountToPay <= 0) {
                        showErrorToast('Enter a valid amount');
                        return;
                      }

                      if (_selectedPaymentMethod == 'wallet') {
                        if (walletBalance < amountToPay) {
                          showErrorToast('Insufficient wallet balance');
                          return;
                        }

                        showCustomBottomSheet(
                          EnterPinSheet(
                            amountToPay: amountToPay,
                            participantId: widget.participantId,
                            billID: widget.billID,
                            comment: widget.comment,
                            onBehalfOfParticipantId:
                                widget.onBehalfOfParticipantId,
                          ),
                          context,
                        );
                        return;
                      }

                      if (_selectedPaymentMethod == 'paystack') {
                        final authUrl = await newSplitBillProvider
                            .payForSPlitBillWithPaystack(
                              participantId: widget.participantId,
                              billId: widget.billID,
                              amount: amountToPay.toString(),
                              onBehalfOfParticipantId:
                                  widget.onBehalfOfParticipantId,
                            );

                        if (authUrl.isEmpty) {
                          // showErrorToast('Unable to open Paystack checkout');
                          return;
                        }

                        if (!mounted) return;
                        showCustomBottomSheet(
                          PaystackUrlSheet(
                            title: "Complete Payment",
                            url: authUrl,
                            onSuccess: () {
                              Get.close(1);
                              newSplitBillProvider.getMySplitBills();
                              newSplitBillProvider.getSplitBillInvites();
                              if (widget.comment != null &&
                                  widget.comment!.isNotEmpty) {
                                newSplitBillProvider.addParticipantComment(
                                  billId: widget.billID,
                                  participantId: widget.participantId,
                                  content: widget.comment!,
                                );
                              }
                            },
                            onError: () {
                              showErrorToast('Paystack payment was canceled');
                            },
                          ),
                          context,
                        );
                        return;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appPrimaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _selectedPaymentMethod == 'wallet'
                          ? 'Pay With Wallet'
                          : 'Continue With Paystack',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EnterPinSheet extends StatelessWidget {
  final String participantId;
  final String billID;
  final double amountToPay;
  final String? comment;
  final String? onBehalfOfParticipantId;
  const EnterPinSheet({
    super.key,
    required this.participantId,
    required this.billID,
    required this.amountToPay,
    this.comment,
    this.onBehalfOfParticipantId,
  });

  @override
  Widget build(BuildContext context) {
    final newSplitBillProvider = Provider.of<NewSplitBillProvider>(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enter Transaction PIN",
              style: txStyle20Bold.copyWith(color: Colors.black),
            ),
            const Gap(8),
            const Text(
              "Please enter your 6-digit transaction PIN to confirm this payment.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const Gap(24),
            PINCodeInput2(
              inputLenght: 4,
              onComplete: (pin) async {
                Get.back();
                final success = await newSplitBillProvider
                    .payForSPlitBillWithWallet(
                      participantId: participantId,
                      billId: billID,
                      amount: amountToPay.toString(),
                      transactionPin: pin,
                      onBehalfOfParticipantId: onBehalfOfParticipantId,
                    );

                if (success) {
                  Get.close(1);
                  newSplitBillProvider.getMySplitBills();
                  newSplitBillProvider.getSplitBillInvites();
                  if (comment != null && comment!.isNotEmpty) {
                    newSplitBillProvider.addParticipantComment(
                      billId: billID,
                      participantId: participantId,
                      content: comment!,
                    );
                  }
                }
              },
            ),
            const Gap(24),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final String rightText;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.rightText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? appPrimaryColor : const Color(0xffE8E8EF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 38,
                height: 38,
                color: const Color(0xffF7F8FA),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
            ),
            const Gap(8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rightText,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const Gap(6),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? appPrimaryColor
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: CircleAvatar(
                            radius: 4,
                            backgroundColor: appPrimaryColor,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
