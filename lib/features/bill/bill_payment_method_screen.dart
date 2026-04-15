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
  final double minPaymentAmount;
  final bool payingRemainingAmount;

  const BillPaymentMethodScreen({
    super.key,
    required this.participantId,
    required this.billID,
    required this.amount,
    this.minPaymentAmount = 0,
    this.payingRemainingAmount = false,
  });

  @override
  State<BillPaymentMethodScreen> createState() =>
      _BillPaymentMethodScreenState();
}

class _BillPaymentMethodScreenState extends State<BillPaymentMethodScreen> {
  String _selectedPaymentMethod = 'wallet';
  late TextEditingController _amountController;
  late double _amountToPay;

  @override
  void initState() {
    super.initState();
    _amountToPay = widget.amount;
    _amountController = TextEditingController(
      text: widget.amount.toStringAsFixed(2),
    );
    Future.delayed(Duration.zero, () {
      final walletProvider = Provider.of<WalletProvider>(
        context,
        listen: false,
      );
      walletProvider.fetchUserWallet();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
                        (widget.minPaymentAmount > 0 || widget.payingRemainingAmount)
                            ? 'Amount to Pay (Partial allowed)'
                            : 'Total Amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(6),
                      (widget.minPaymentAmount > 0 || widget.payingRemainingAmount)
                          ? TextFormField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [NumberTextInputFormatter()],
                              style: txStyle24SemiBold,
                              autofocus: true,
                              decoration: InputDecoration(
                                prefixText: '₦',
                                prefixStyle: txStyle24SemiBold,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              onChanged: (val) {
                                final text = val.replaceAll(',', '');
                                setState(() {
                                  _amountToPay = double.tryParse(text) ?? 0.0;
                                });
                              },
                            )
                          : Text(
                              convertStringToCurrency(widget.amount.toString()),
                              style: txStyle24SemiBold,
                            ),
                      if (widget.minPaymentAmount > 0 && !widget.payingRemainingAmount) ...[
                        const Gap(4),
                        Text(
                          'Min: ${convertStringToCurrency(widget.minPaymentAmount.toString())} • Max: ${convertStringToCurrency(widget.amount.toString())}',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                _amountToPay < widget.minPaymentAmount ||
                                    _amountToPay > widget.amount
                                ? Colors.red
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                      if (widget.payingRemainingAmount) ...[
                        const Gap(4),
                        Text(
                          'Max: ${convertStringToCurrency(widget.amount.toString())}',
                          style: TextStyle(
                            fontSize: 11,
                            color: _amountToPay > widget.amount
                                ? Colors.red
                                : Colors.grey[600],
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
                      if (widget.minPaymentAmount > 0 && !widget.payingRemainingAmount) {
                        if (_amountToPay < widget.minPaymentAmount) {
                          showErrorToast(
                            'Amount cannot be less than minimum allowed',
                          );
                          return;
                        }
                      }
                      if (widget.minPaymentAmount > 0 || widget.payingRemainingAmount) {
                        if (_amountToPay > widget.amount) {
                          showErrorToast(
                            'Amount cannot be greater than total owed',
                          );
                          return;
                        }
                      }

                      if (_selectedPaymentMethod == 'wallet') {
                        if (walletBalance < _amountToPay) {
                          showErrorToast('Insufficient wallet balance');
                          return;
                        }

                        showCustomBottomSheet(
                          EnterPinSheet(
                            amountToPay: _amountToPay,
                            participantId: widget.participantId,
                            billID: widget.billID,
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
                              amount: _amountToPay.toString(),
                            );

                        if (authUrl.isEmpty) {
                          showErrorToast('Unable to open Paystack checkout');
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
  const EnterPinSheet({
    super.key,
    required this.participantId,
    required this.billID,
    required this.amountToPay,
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
                    );

                if (success) {
                  Get.close(1);
                  newSplitBillProvider.getMySplitBills();
                  newSplitBillProvider.getSplitBillInvites();
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
