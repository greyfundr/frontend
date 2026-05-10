import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_pin_input.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/models/all_campaign_response_model.dart' hide Image;
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/core/providers/wallet_provider.dart';
import 'package:greyfundr/features/charity/charity_provider.dart';
import 'package:greyfundr/features/home/add_money_sheet.dart' hide PaymentSuccessScreen;
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:greyfundr/widgets/campaigndetails/donation_bottom_sheet.dart';
import 'package:provider/provider.dart';

class CharityPaymentMethodScreen extends StatefulWidget {
  final CampaignDatum campaign;
  final double amount;

  const CharityPaymentMethodScreen({
    super.key,
    required this.campaign,
    required this.amount,
  });

  @override
  State<CharityPaymentMethodScreen> createState() =>
      _CharityPaymentMethodScreenState();
}

class _CharityPaymentMethodScreenState
    extends State<CharityPaymentMethodScreen> {
  String _selectedPaymentMethod = 'wallet';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<WalletProvider>(context, listen: false).fetchUserWallet();
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
    final charityProvider = Provider.of<CharityProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final currentUserId = userProvider.userProfileModel?.id;
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
                      'Donation Amount',
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
                    const Gap(4),
                    Text(
                      'Supporting: ${widget.campaign.title ?? 'this campaign'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                onTap: () =>
                    setState(() => _selectedPaymentMethod = 'wallet'),
              ),
              const Gap(10),
              _PaymentMethodTile(
                title: 'Paystack',
                subtitle: 'Card / Bank payment',
                imagePath: 'assets/images/paystack.png',
                rightText: '',
                isSelected: _selectedPaymentMethod == 'paystack',
                onTap: () =>
                    setState(() => _selectedPaymentMethod = 'paystack'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: charityProvider.donationIsProcessing
                      ? null
                      : () => _onPay(
                            charityProvider: charityProvider,
                            currentUserId: currentUserId,
                            walletBalance: walletBalance,
                          ),
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
    );
  }

  Future<void> _onPay({
    required CharityProvider charityProvider,
    required String? currentUserId,
    required double walletBalance,
  }) async {
    if (_selectedPaymentMethod == 'wallet') {
      if (walletBalance < widget.amount) {
        showErrorToast('Insufficient wallet balance');
        return;
      }

      showCustomBottomSheet(
        EnterDonationPinSheet(
          campaign: widget.campaign,
          amount: widget.amount,
          currentUserId: currentUserId,
        ),
        context,
      );
      return;
    }

    if (_selectedPaymentMethod == 'paystack') {
      final authUrl = await charityProvider.donateWithPaystack(
        campaign: widget.campaign,
        currentUserId: currentUserId,
        amount: widget.amount.toInt(),
      );

      if (authUrl.isEmpty) {
        showErrorToast('Unable to open Paystack checkout');
        return;
      }

      if (!mounted) return;
      showCustomBottomSheet(
        PaystackUrlSheet(
          title: 'Complete Donation',
          url: authUrl,
          onSuccess: () {
            Get.close(1);
            _showDonationSuccess();
          },
          onError: () {
            showErrorToast('Paystack payment was canceled');
          },
        ),
        context,
      );
    }
  }

  void _showDonationSuccess() {
    showDialog(
      context: context,
      builder: (_) => PaymentSuccessScreen(
        amount: widget.amount.toStringAsFixed(0),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).maybePop();
    });
  }
}

class EnterDonationPinSheet extends StatelessWidget {
  final CampaignDatum campaign;
  final double amount;
  final String? currentUserId;

  const EnterDonationPinSheet({
    super.key,
    required this.campaign,
    required this.amount,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final charityProvider = Provider.of<CharityProvider>(context);

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
              'Enter Transaction PIN',
              style: txStyle20Bold.copyWith(color: Colors.black),
            ),
            const Gap(8),
            const Text(
              'Please enter your 4-digit transaction PIN to confirm this donation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const Gap(24),
            PINCodeInput2(
              inputLenght: 4,
              onComplete: (pin) async {
                Get.back();
                final success = await charityProvider.donateWithWallet(
                  campaign: campaign,
                  currentUserId: currentUserId,
                  amount: amount.toInt(),
                  transactionPin: pin,
                );

                if (success) {
                  Get.close(1);
                  showDialog(
                    context: Get.context!,
                    builder: (_) => PaymentSuccessScreen(
                      amount: amount.toStringAsFixed(0),
                    ),
                  );
                  Future.delayed(const Duration(seconds: 3), () {
                    Navigator.of(Get.context!, rootNavigator: true)
                        .maybePop();
                  });
                  charityProvider.getAllCampaigns(refresh: true);
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
                  style: const TextStyle(
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
